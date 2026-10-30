import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/router.dart';
import 'core/theme.dart';
import 'data/store.dart';

class StillApp extends ConsumerStatefulWidget {
  const StillApp({super.key});
  @override
  ConsumerState<StillApp> createState() => _StillAppState();
}

class _StillAppState extends ConsumerState<StillApp> {
  late final router = makeRouter();
  @override
  void dispose() {
    router.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final store = ref.watch(storeProvider);
    return MaterialApp.router(
      title: 'Still · Your money, clearly',
      debugShowCheckedModeBanner: false,
      theme: appTheme(false),
      darkTheme: appTheme(true),
      themeMode: store.dark ? ThemeMode.dark : ThemeMode.light,
      themeAnimationDuration: Duration.zero,
      routerConfig: router,
    );
  }
}
