final demoDate = DateTime(2026, 10, 30);

const categories = [
  'Groceries',
  'Dining',
  'Shopping',
  'Transport',
  'Home',
  'Health',
  'Subscriptions',
];

class Entry {
  const Entry({
    required this.id,
    required this.merchant,
    required this.amount,
    required this.date,
    required this.category,
    this.account = 'Everyday account',
    this.kind = 'expense',
    this.status = 'Completed',
    this.note = '',
  });
  final String id, merchant, category, account, kind, status, note;
  final double amount;
  final DateTime date;
  Entry withCategory(String value) => Entry(
    id: id,
    merchant: merchant,
    amount: amount,
    date: date,
    category: value,
    account: account,
    kind: kind,
    status: status,
    note: note,
  );
  bool get isSpend => kind == 'expense' || kind == 'refund';
  double get spend => kind == 'expense'
      ? amount
      : kind == 'refund'
      ? -amount
      : 0;
}

class Holding {
  const Holding({
    required this.id,
    required this.name,
    required this.type,
    required this.units,
    required this.cost,
    required this.price,
    required this.history,
    required this.purchaseDate,
    this.rate,
    this.maturity,
    this.maturityValue,
  });
  final String id, name, type;
  final double units, cost, price;
  final List<double> history;
  final DateTime purchaseDate;
  final double? rate, maturityValue;
  final DateTime? maturity;
  double get invested => units * cost;
  double get value => units * price;
  double get gain => value - invested;
  double get returnPercent => invested == 0 ? 0 : gain / invested * 100;
}

class Goal {
  const Goal({
    required this.id,
    required this.name,
    required this.target,
    required this.saved,
    required this.deadline,
    required this.monthly,
    required this.contributions,
  });
  final String id, name;
  final double target, saved, monthly;
  final DateTime deadline;
  final List<double> contributions;
  double get remaining => (target - saved).clamp(0, double.infinity);
  double get progress => (saved / target).clamp(0, 1);
  int get monthsLeft {
    final months =
        (deadline.year - demoDate.year) * 12 + deadline.month - demoDate.month;
    return months < 1 ? 1 : months;
  }

  double get requiredMonthly => remaining / monthsLeft;
  Goal copyWith({
    String? name,
    double? target,
    double? monthly,
    DateTime? deadline,
  }) => Goal(
    id: id,
    name: name ?? this.name,
    target: target ?? this.target,
    saved: saved,
    deadline: deadline ?? this.deadline,
    monthly: monthly ?? this.monthly,
    contributions: contributions,
  );
  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'target': target,
    'saved': saved,
    'deadline': deadline.toIso8601String(),
    'monthly': monthly,
    'contributions': contributions,
  };
  factory Goal.fromJson(Map<String, dynamic> j) => Goal(
    id: j['id'],
    name: j['name'],
    target: (j['target'] as num).toDouble(),
    saved: (j['saved'] as num).toDouble(),
    deadline: DateTime.parse(j['deadline']),
    monthly: (j['monthly'] as num).toDouble(),
    contributions: (j['contributions'] as List)
        .map((n) => (n as num).toDouble())
        .toList(),
  );
}

class FinancialData {
  FinancialData({
    required this.entries,
    required this.goals,
    required this.holdings,
  });
  final List<Entry> entries;
  final List<Goal> goals;
  final List<Holding> holdings;
  static const everyday = 186500.0;
  static const savings = 210000.0;
  static const liabilities = 48500.0;
  double get investmentValue => holdings.fold(0, (s, h) => s + h.value);
  double get invested => holdings.fold(0, (s, h) => s + h.invested);
  double get assets => everyday + savings + investmentValue;
  double get netWorth => assets - liabilities;
  double get allocatedSavings => goals.fold(0, (s, g) => s + g.saved);
  List<Entry> spending(int month, {String? category}) =>
      entries
          .where(
            (e) =>
                e.date.month == month &&
                e.date.year == 2026 &&
                e.isSpend &&
                (category == null || e.category == category),
          )
          .toList()
        ..sort((a, b) => b.date.compareTo(a.date));
  double spendTotal(int month, {String? category}) =>
      spending(month, category: category).fold(0, (s, e) => s + e.spend);
  Map<String, double> categoryTotals(int month) => {
    for (final c in categories) c: spendTotal(month, category: c),
  };
  List<double> get portfolioHistory => List.generate(
    6,
    (i) => holdings.fold<double>(0, (sum, h) => sum + h.history[i]),
  );
  // Cash and liabilities are monthly snapshots; goals are allocations of savings.
  List<double> get wealthHistory {
    const cash = [315000.0, 330000.0, 350000.0, 365000.0, 378300.0, 396500.0];
    const debt = [64000.0, 61000.0, 58000.0, 55000.0, 51000.0, 48500.0];
    return List.generate(6, (i) => portfolioHistory[i] + cash[i] - debt[i]);
  }
}
