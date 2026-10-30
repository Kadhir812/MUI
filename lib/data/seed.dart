import 'models.dart';

FinancialData seedData() {
  final holdings = [
    Holding(
      id: 'h1',
      name: 'Infosys',
      type: 'Stocks',
      units: 60,
      cost: 1400,
      price: 1620,
      history: [84000, 87000, 90000, 92400, 94800, 97200],
      purchaseDate: DateTime(2026, 5, 1),
    ),
    Holding(
      id: 'h2',
      name: 'HDFC Bank',
      type: 'Stocks',
      units: 80,
      cost: 1500,
      price: 1700,
      history: [120000, 123200, 128000, 126400, 132000, 136000],
      purchaseDate: DateTime(2026, 5, 1),
    ),
    Holding(
      id: 'h3',
      name: 'Nifty 50 Index Fund',
      type: 'Mutual funds',
      units: 5000,
      cost: 40,
      price: 46,
      history: [200000, 207000, 212000, 216000, 223000, 230000],
      purchaseDate: DateTime(2026, 5, 1),
    ),
    Holding(
      id: 'h4',
      name: 'Flexi Cap Fund',
      type: 'Mutual funds',
      units: 2000,
      cost: 75,
      price: 81,
      history: [150000, 152000, 155000, 153000, 158000, 162000],
      purchaseDate: DateTime(2026, 5, 1),
    ),
    Holding(
      id: 'h5',
      name: 'Growth Fixed Deposit',
      type: 'Fixed deposits',
      units: 1,
      cost: 200000,
      price: 200000,
      history: [200000, 200000, 200000, 200000, 200000, 200000],
      purchaseDate: DateTime(2026, 5, 1),
      rate: 7,
      maturity: DateTime(2027, 5, 1),
      maturityValue: 214000,
    ),
  ];
  final entries = <Entry>[];
  const merchants = [
    'Fresh Basket',
    'The Good Bowl',
    'Everyday Store',
    'Metro & rides',
    'Rent',
    'Apollo Pharmacy',
    'Streaming & cloud',
  ];
  const sept = [6200.0, 3800.0, 2900.0, 2100.0, 12000.0, 950.0, 799.0];
  const oct = [6800.0, 6200.0, 3300.0, 2350.0, 12000.0, 1100.0, 799.0];
  for (final month in [8, 9, 10]) {
    for (var c = 0; c < categories.length; c++) {
      final total = month == 10
          ? oct[c]
          : month == 9
          ? sept[c]
          : sept[c] * .95;
      final count = c == 4 || c == 6 ? 1 : 3;
      for (var j = 0; j < count; j++) {
        entries.add(
          Entry(
            id: 't-$month-$c-$j',
            merchant: merchants[c],
            amount:
                ((total * 100).round() ~/ count +
                    (j == count - 1 ? (total * 100).round() % count : 0)) /
                100,
            date: DateTime(2026, month, c == 4 ? 1 : 4 + j * 10 + c % 3),
            category: categories[c],
            account: c == 1 || c == 2 ? 'Credit card' : 'Everyday account',
          ),
        );
      }
    }
    entries.add(
      Entry(
        id: 'salary-$month',
        merchant: 'Salary',
        amount: 85000,
        date: DateTime(2026, month, 1),
        category: 'Income',
        kind: 'income',
      ),
    );
    entries.add(
      Entry(
        id: 'transfer-$month',
        merchant: 'Savings allocation',
        amount: 15000,
        date: DateTime(2026, month, 2),
        category: 'Transfer',
        kind: 'transfer',
      ),
    );
  }
  return FinancialData(
    entries: entries,
    holdings: holdings,
    goals: [
      Goal(
        id: 'g1',
        name: 'Emergency fund',
        target: 300000,
        saved: 150000,
        deadline: DateTime(2027, 4, 30),
        monthly: 18000,
        contributions: [20000, 20000, 25000, 25000, 30000, 30000],
      ),
      Goal(
        id: 'g2',
        name: 'Japan, slowly',
        target: 180000,
        saved: 60000,
        deadline: DateTime(2027, 10, 30),
        monthly: 10000,
        contributions: [10000, 10000, 10000, 10000, 10000, 10000],
      ),
    ],
  );
}
