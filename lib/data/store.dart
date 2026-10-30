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
    'schema': 1,
    'dark': dark,
    'hidden': hidden,
    'categories': {for (final e in data.entries) e.id: e.category},
    'goals': data.goals.map((g) => g.toJson()).toList(),
  });
  void _restore(String raw) {
    final j = jsonDecode(raw) as Map<String, dynamic>;
    if (j['schema'] != 1) throw const FormatException('Unsupported snapshot');
    final fresh = seedData();
    final overrides = j['categories'] as Map<String, dynamic>;
    final goals = (j['goals'] as List)
        .map((g) => Goal.fromJson(Map<String, dynamic>.from(g)))
        .toList();
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
      entries: fresh.entries
          .map(
            (e) => overrides.containsKey(e.id)
                ? e.withCategory(overrides[e.id])
                : e,
          )
          .toList(),
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
