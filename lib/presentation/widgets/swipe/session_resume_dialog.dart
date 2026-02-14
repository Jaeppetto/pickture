import 'package:flutter/material.dart';

import 'package:pickture/l10n/app_localizations.dart';

class SessionResumeDialog extends StatelessWidget {
  const SessionResumeDialog({super.key});

  static Future<bool?> show(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (_) => const SessionResumeDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return AlertDialog(
      title: Text(l10n.resumeSessionTitle),
      content: Text(l10n.resumeSessionDescription),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(l10n.startFresh),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(true),
          child: Text(l10n.resumeSession),
        ),
      ],
    );
  }
}
