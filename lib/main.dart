import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app.dart';
import 'data/store.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final store = FinanceStore(PreferencesRepository());
  await store.load();
  runApp(
    ProviderScope(
      overrides: [storeProvider.overrideWith((ref) => store)],
      child: const StillApp(),
    ),
  );
}
