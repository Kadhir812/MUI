import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../ui/components.dart';

class ConnectionRequestPage extends StatefulWidget {
  const ConnectionRequestPage({super.key, required this.type});

  final String type;

  @override
  State<ConnectionRequestPage> createState() => _ConnectionRequestPageState();
}

class _ConnectionRequestPageState extends State<ConnectionRequestPage> {
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final details = _connectionDetails(widget.type);
    if (details == null) {
      return const PageFrame(
        title: 'Connection unavailable',
        children: [
          Notice('This connection type is not available in the demo.'),
        ],
      );
    }

    return PageFrame(
      title: details.title,
      children: [
        Text(
          details.heading,
          style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 12),
        const Notice(
          'UI preview only. Do not enter real financial identifiers. Nothing on this screen is sent or saved.',
        ),
        const SectionTitle('Details to prepare'),
        Form(
          key: _formKey,
          child: Column(
            children: [
              for (final field in details.fields) ...[
                TextFormField(
                  key: ValueKey('connection-${field.id}'),
                  keyboardType: field.keyboardType,
                  textCapitalization: field.capitalization,
                  decoration: InputDecoration(
                    labelText: field.label,
                    hintText: field.hint,
                  ),
                  validator: (value) => value == null || value.trim().isEmpty
                      ? 'Enter ${field.label.toLowerCase()}'
                      : null,
                ),
                const SizedBox(height: 12),
              ],
            ],
          ),
        ),
        Panel(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Document to keep ready',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 6),
              Muted(details.document),
              const SizedBox(height: 12),
              Muted(details.verification),
            ],
          ),
        ),
        FilledButton(
          key: const ValueKey('connection-continue'),
          onPressed: () {
            if (_formKey.currentState?.validate() != true) return;
            showDialog<void>(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('Preview only'),
                content: const Text(
                  'No connection was made. Your entries were not sent or saved. A real setup must continue through the official provider with your consent.',
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Got it'),
                  ),
                ],
              ),
            );
          },
          child: const Text('Continue'),
        ),
        TextButton(onPressed: () => context.pop(), child: const Text('Cancel')),
      ],
    );
  }
}

class _ConnectionDetails {
  const _ConnectionDetails({
    required this.title,
    required this.heading,
    required this.fields,
    required this.document,
    required this.verification,
  });

  final String title;
  final String heading;
  final List<_ConnectionField> fields;
  final String document;
  final String verification;
}

class _ConnectionField {
  const _ConnectionField(
    this.id,
    this.label, {
    this.hint,
    this.keyboardType,
    this.capitalization = TextCapitalization.none,
  });

  final String id;
  final String label;
  final String? hint;
  final TextInputType? keyboardType;
  final TextCapitalization capitalization;
}

_ConnectionDetails? _connectionDetails(String type) => switch (type) {
  'mutual-funds' => const _ConnectionDetails(
    title: 'Mutual funds',
    heading: 'Find your fund records.',
    fields: [
      _ConnectionField(
        'pan',
        'PAN',
        hint: 'ABCDE1234F',
        capitalization: TextCapitalization.characters,
      ),
      _ConnectionField(
        'registered-contact',
        'Registered email or mobile',
        hint: 'Used for provider verification',
        keyboardType: TextInputType.emailAddress,
      ),
    ],
    document:
        'A recent Consolidated Account Statement (CAS) from CAMS or KFintech can help confirm your folios and holdings.',
    verification:
        'A real provider may verify using the PAN and the email/mobile registered with your fund house. The exact steps vary.',
  ),
  'stocks' => const _ConnectionDetails(
    title: 'Stocks & demat',
    heading: 'Prepare your demat details.',
    fields: [
      _ConnectionField('broker', 'Broker name'),
      _ConnectionField('pan', 'PAN', hint: 'ABCDE1234F'),
      _ConnectionField('demat-id', 'Client ID or DP ID'),
    ],
    document:
        'A recent demat holdings statement or Consolidated Account Statement (CAS) can help identify your holdings.',
    verification:
        'A real broker connection should use the broker’s official authorization and consent flow. Never share a trading password, PIN, or OTP here.',
  ),
  'fixed-deposits' => const _ConnectionDetails(
    title: 'Fixed deposits',
    heading: 'Identify your deposit.',
    fields: [
      _ConnectionField('bank', 'Bank or deposit provider'),
      _ConnectionField('holder', 'Account holder name'),
      _ConnectionField(
        'deposit-reference',
        'Deposit reference (last 4 digits)',
      ),
    ],
    document:
        'Keep your FD advice, deposit receipt, or a recent statement from the bank/provider ready.',
    verification:
        'A real bank connection should use the bank’s official consent or secure document-verification flow. Do not share bank login details.',
  ),
  _ => null,
};
