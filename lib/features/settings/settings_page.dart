import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/store.dart';
import '../../ui/components.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(storeProvider);
    return PageFrame(
      title: 'Your preferences',
      children: [
        const Text(
          'Make yourself\nat home.',
          style: TextStyle(fontSize: 32, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 24),
        Panel(
          child: Column(
            children: [
              SwitchListTile.adaptive(
                contentPadding: EdgeInsets.zero,
                title: const Text('Dark appearance'),
                subtitle: const Text('Warm, softer contrast for evening use'),
                value: s.dark,
                onChanged: s.busy ? null : (v) => s.setDark(v),
              ),
              const Divider(),
              SwitchListTile.adaptive(
                contentPadding: EdgeInsets.zero,
                title: const Text('Hide financial values'),
                subtitle: const Text(
                  'Conceal balances, charts, and assistant amounts',
                ),
                value: s.hidden,
                onChanged: s.busy ? null : (v) => s.setHidden(v),
              ),
            ],
          ),
        ),
        const SectionTitle('About this demo'),
        const Panel(
          child: Column(
            children: [
              DataRowTile('Reference date', '30 Oct 2026'),
              DataRowTile('Currency', 'INR'),
              DataRowTile('Connections', 'None'),
              DataRowTile('Assistant', 'Local simulation'),
            ],
          ),
        ),
        const Notice(
          'Still stores sample edits and expenses you add on this device. No bank connection, account sign-in, external AI service, or analytics is used. It is not a production banking app.',
        ),
        const SizedBox(height: 20),
        const Muted(
          'Accessibility follows your system text size, screen reader, and reduced-motion settings. Chart values also appear as labelled rows.',
        ),
        const SizedBox(height: 24),
        if (s.canUndo)
          OutlinedButton(
            onPressed: s.busy
                ? null
                : () =>
                      reportChange(context, s, s.undo(), 'Last change undone'),
            child: const Text('Undo last data change'),
          ),
        TextButton(
          onPressed: s.busy
              ? null
              : () async {
                  final confirmed = await showDialog<bool>(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: const Text('Reset sample data?'),
                      content: const Text(
                        'Goal edits, transaction categories, and expenses you added are removed. Your appearance and privacy preferences stay unchanged. You can undo this reset.',
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(ctx, false),
                          child: const Text('Cancel'),
                        ),
                        FilledButton(
                          onPressed: () => Navigator.pop(ctx, true),
                          child: const Text('Reset demo'),
                        ),
                      ],
                    ),
                  );
                  if (confirmed == true && context.mounted) {
                    await reportChange(
                      context,
                      s,
                      s.reset(),
                      'Sample data restored',
                    );
                  }
                },
          child: const Text('Reset demo data'),
        ),
      ],
    );
  }
}
