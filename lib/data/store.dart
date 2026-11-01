import '../core/formatters.dart';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'models.dart';
import 'seed.dart';

abstract class SnapshotRepository {
  Future<String?> read();
  Future<void> write(String snapshot);
}

class PreferencesRepository implements SnapshotRepository {
  final SharedPreferencesAsync preferences = SharedPreferencesAsync();
  @override
  Future<String?> read() => preferences.getString('still.demo.v1');
  @override
  Future<void> write(String snapshot) =>
      preferences.setString('still.demo.v1', snapshot);
}

class MemoryRepository implements SnapshotRepository {
  String? value;
  @override
  Future<String?> read() async => value;
  @override
  Future<void> write(String snapshot) async {
    value = snapshot;
  }
}

final storeProvider = ChangeNotifierProvider<FinanceStore>(
  (ref) => throw UnimplementedError('Override at startup'),
);

class FinanceStore extends ChangeNotifier {
  FinanceStore(this.repository);
  final SnapshotRepository repository;
  FinancialData data = seedData();
  bool dark = false, hidden = false, busy = false;
  String? error;
  String? _undo;
  bool get canUndo => _undo != null;
  String amount(num v, {bool decimals = false}) =>
      hidden ? '••••' : money(v, decimals: decimals);
  Future<void> load() async {
    try {
      final raw = await repository.read();
      if (raw != null) _restore(raw);
    } catch (_) {
      error =
          'Saved demo could not be loaded. Sample data is available; reset the demo to replace the saved copy.';
    }
    notifyListeners();
  }

  String _snapshot() => jsonEncode({
    'schema': 2,
    'dark': dark,
    'hidden': hidden,
    'categories': {for (final e in data.entries) e.id: e.category},
    'goals': data.goals.map((g) => g.toJson()).toList(),
    'manualEntries': data.entries
        .where((entry) => entry.isManual)
        .map((entry) => entry.toJson())
        .toList(),
  });
  void _restore(String raw) {
    final j = jsonDecode(raw) as Map<String, dynamic>;
    final schema = j['schema'];
    if (schema != 1 && schema != 2) {
      throw const FormatException('Unsupported snapshot');
    }
    final fresh = seedData();
    final overrides = j['categories'] as Map<String, dynamic>;
    final goals = (j['goals'] as List)
        .map((g) => Goal.fromJson(Map<String, dynamic>.from(g)))
        .toList();
    final manualEntries = schema == 2
        ? (j['manualEntries'] as List)
              .map((entry) => Entry.fromJson(Map<String, dynamic>.from(entry)))
              .toList()
        : <Entry>[];
    if (manualEntries.any(
      (entry) =>
          !entry.isManual ||
          entry.id.isEmpty ||
          entry.merchant.trim().isEmpty ||
          entry.merchant.length > 80 ||
          !const ['expense', 'income'].contains(entry.kind) ||
          !entry.amount.isFinite ||
          entry.amount <= 0 ||
          entry.amount > 1000000000 ||
          entry.date.isAfter(demoDate) ||
          entry.note.length > 200 ||
          entry.kind == 'expense' &&
              (!categories.contains(entry.category) ||
                  !const [
                    'Everyday account',
                    'Credit card',
                  ].contains(entry.account)) ||
          entry.kind == 'income' &&
              (entry.category != 'Income' ||
                  !const [
                    'Everyday account',
                    'Savings account',
                  ].contains(entry.account)),
    )) {
      throw const FormatException('Invalid manual transaction');
    }
    if (goals.any(
      (g) =>
          g.target <= 0 ||
          !g.target.isFinite ||
          g.monthly < 0 ||
          !g.monthly.isFinite,
    )) {
      throw const FormatException('Invalid goal');
    }
    data = FinancialData(
      entries:
          fresh.entries
              .map(
                (e) => overrides.containsKey(e.id)
                    ? e.withCategory(overrides[e.id])
                    : e,
              )
              .toList()
            ..addAll(manualEntries),
      holdings: fresh.holdings,
      goals: goals,
    );
    dark = j['dark'] == true;
    hidden = j['hidden'] == true;
  }

  Future<bool> _commit(void Function() change, {bool undoable = true}) async {
    if (busy) return false;
    final previous = _snapshot();
    busy = true;
    error = null;
    notifyListeners();
    try {
      change();
      await repository.write(_snapshot());
      if (undoable) _undo = previous;
      busy = false;
      notifyListeners();
      return true;
    } catch (_) {
      _restore(previous);
      busy = false;
      error =
          'Could not save the change. Your previous values have been restored. Please try again.';
      notifyListeners();
      return false;
    }
  }

  Future<bool> setHidden(bool value) =>
      _commit(() => hidden = value, undoable: false);
  Future<bool> setDark(bool value) =>
      _commit(() => dark = value, undoable: false);
  Future<bool> categorize(String id, String category) => _commit(() {
    if (!categories.contains(category)) throw ArgumentError('Invalid category');
    final index = data.entries.indexWhere((e) => e.id == id);
    if (index < 0 || !data.entries[index].isSpend) {
      throw ArgumentError('Not an expense');
    }
    data.entries[index] = data.entries[index].withCategory(category);
  });
  Future<bool> addExpense({
    required String merchant,
    required double amount,
    required DateTime date,
    required String category,
    required String account,
    String note = '',
  }) {
    final normalizedMerchant = merchant.trim();
    if (normalizedMerchant.isEmpty ||
        normalizedMerchant.length > 80 ||
        !amount.isFinite ||
        amount <= 0 ||
        amount > 1000000000 ||
        date.isAfter(demoDate) ||
        !categories.contains(category) ||
        !const ['Everyday account', 'Credit card'].contains(account) ||
        note.length > 200) {
      error = 'Check the expense details and try again.';
      notifyListeners();
      return Future.value(false);
    }

    final baseId = 'manual-${DateTime.now().microsecondsSinceEpoch}';
    var id = baseId;
    var suffix = 1;
    while (data.entries.any((entry) => entry.id == id)) {
      id = '$baseId-$suffix';
      suffix++;
    }
    return _commit(() {
      data.entries.add(
        Entry(
          id: id,
          merchant: normalizedMerchant,
          amount: amount,
          date: date,
          category: category,
          account: account,
          kind: 'expense',
          note: note.trim(),
          isManual: true,
        ),
      );
    });
  }

  Future<bool> addIncome({
    required String source,
    required double amount,
    required DateTime date,
    required String account,
    String note = '',
  }) {
    final normalizedSource = source.trim();
    if (normalizedSource.isEmpty ||
        normalizedSource.length > 80 ||
        !amount.isFinite ||
        amount <= 0 ||
        amount > 1000000000 ||
        date.isAfter(demoDate) ||
        !const ['Everyday account', 'Savings account'].contains(account) ||
        note.length > 200) {
      error = 'Check the income details and try again.';
      notifyListeners();
      return Future.value(false);
    }

    final baseId = 'income-${DateTime.now().microsecondsSinceEpoch}';
    var id = baseId;
    var suffix = 1;
    while (data.entries.any((entry) => entry.id == id)) {
      id = '$baseId-$suffix';
      suffix++;
    }
    return _commit(() {
      data.entries.add(
        Entry(
          id: id,
          merchant: normalizedSource,
          amount: amount,
          date: date,
          category: 'Income',
          account: account,
          kind: 'income',
          note: note.trim(),
          isManual: true,
        ),
      );
    });
  }

  Future<bool> saveGoal(Goal goal) => _commit(() {
    if (goal.name.trim().isEmpty ||
        goal.target <= 0 ||
        !goal.target.isFinite ||
        goal.target < goal.saved ||
        goal.monthly < 0 ||
        !goal.monthly.isFinite ||
        !goal.deadline.isAfter(demoDate)) {
      throw ArgumentError('Invalid goal');
    }
    final i = data.goals.indexWhere((g) => g.id == goal.id);
    if (i < 0) {
      data.goals.add(goal);
    } else {
      data.goals[i] = goal;
    }
  });
  Future<bool> undo() async {
    final previous = _undo;
    if (previous == null || busy) return false;
    final currentDark = dark, currentHidden = hidden;
    final ok = await _commit(() {
      _restore(previous);
      dark = currentDark;
      hidden = currentHidden;
    }, undoable: false);
    if (ok) {
      _undo = null;
      notifyListeners();
    }
    return ok;
  }

  Future<bool> reset() => _commit(() {
    data = seedData();
  });
}
