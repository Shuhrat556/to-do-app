import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/app_language.dart';
import '../store/language_notifier.dart';
import '../store/lock_notifier.dart';
import '../store/task_store.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final store = context.watch<TaskStore>();
    final language = context.watch<LanguageNotifier>();
    final t = language.translate;
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.indigo.shade900,
        elevation: 4,
        title: Text(t('settings_title')),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.indigo.shade900,
              Colors.indigo.shade700,
              Colors.indigo.shade500,
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 8),
                Text(
                  t('settings_description'),
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(color: Colors.white70),
                ),
                const SizedBox(height: 16),
                Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 3,
                  color: Colors.white.withOpacity(0.08),
                  child: SwitchListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    title: Text(t('toggle_title')),
                    subtitle: Text(t('toggle_subtitle')),
                    value: store.useAlarmTone,
                    onChanged: store.updateReminderStyle,
                    activeThumbColor: Colors.indigoAccent,
                    activeColor: Colors.indigo.shade100,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  t('toggle_info'),
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: Colors.white60),
                ),
                const SizedBox(height: 20),
                _LockSettingsCard(),
                const SizedBox(height: 20),
                Text(
                  t('language_section_title'),
                  style: Theme.of(
                    context,
                  ).textTheme.titleMedium?.copyWith(color: Colors.white),
                ),
                const SizedBox(height: 6),
                Text(
                  t('language_section_description'),
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: Colors.white70),
                ),
                const SizedBox(height: 12),
                FilledButton.tonal(
                  onPressed: () =>
                      _showLanguageSelection(context, language, t),
                  child: Text(t('language_section_button')),
                ),
                const SizedBox(height: 8),
                Text(
                  language.current.displayName,
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall
                      ?.copyWith(color: Colors.white70),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _LockSettingsCard extends StatelessWidget {
  const _LockSettingsCard();

  @override
  Widget build(BuildContext context) {
    final lock = context.watch<LockNotifier>();
    final t = context.watch<LanguageNotifier>().translate;
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      elevation: 3,
      color: Colors.white.withOpacity(0.06),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                const Icon(Icons.lock, color: Colors.indigo),
                const SizedBox(width: 8),
                Text(
                  t('lock_card_title'),
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const Spacer(),
                Chip(
                  label: Text(
                    lock.lockEnabled
                        ? t('lock_card_status_enabled')
                        : t('lock_card_status_disabled'),
                    style: const TextStyle(color: Colors.indigo),
                  ),
                  backgroundColor: Colors.indigo.shade50,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              lock.lockEnabled
                  ? t('lock_card_description_enabled')
                  : t('lock_card_description_disabled'),
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: Colors.white70),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _showLockSetupDialog(context, lock, t),
                    child: Text(
                      lock.lockEnabled
                          ? t('lock_card_button_primary_update')
                          : t('lock_card_button_primary'),
                    ),
                  ),
                ),
                if (lock.lockEnabled) ...[
                  const SizedBox(width: 8),
                  OutlinedButton(
                    onPressed: () => _showLockDisableDialog(context, lock, t),
                    child: Text(t('lock_card_button_secondary')),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}

Future<void> _showLockSetupDialog(
  BuildContext context,
  LockNotifier lock,
  String Function(String) t,
) async {
  final passwordController = TextEditingController();
  final confirmController = TextEditingController();
  String? error;
  await showDialog(
    context: context,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: Text(
              lock.lockEnabled
                  ? t('lock_dialog_title_update')
                  : t('lock_dialog_title_new'),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: passwordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: t('lock_dialog_password'),
                  ),
                ),
                TextField(
                  controller: confirmController,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: t('lock_dialog_confirm'),
                  ),
                ),
                if (error != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: Text(
                      error!,
                      style: const TextStyle(color: Colors.red),
                    ),
                  ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(t('dialog_cancel')),
              ),
              ElevatedButton(
                onPressed: () async {
                  final password = passwordController.text.trim();
                  final confirm = confirmController.text.trim();
                  if (password.isEmpty || confirm.isEmpty) {
                    setState(() => error = t('lock_dialog_empty'));
                    return;
                  }
                  if (password != confirm) {
                    setState(() => error = t('lock_dialog_mismatch'));
                    return;
                  }
                  await lock.enableLock(password);
                  if (context.mounted) {
                    Navigator.of(context).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(t('lock_dialog_saved'))),
                    );
                  }
                },
                child: Text(
                  lock.lockEnabled
                      ? t('lock_card_button_primary_update')
                      : t('lock_card_button_primary'),
                ),
              ),
            ],
          );
        },
      );
    },
  );
}

Future<void> _showLockDisableDialog(
  BuildContext context,
  LockNotifier lock,
  String Function(String) t,
) async {
  final controller = TextEditingController();
  String? error;
  await showDialog(
    context: context,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: Text(t('lock_dialog_disable_title')),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: controller,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: t('lock_dialog_password'),
                  ),
                ),
                if (error != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: Text(
                      error!,
                      style: const TextStyle(color: Colors.red),
                    ),
                  ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(t('dialog_cancel')),
              ),
              ElevatedButton(
                onPressed: () async {
                  final valid = await lock.disableLock(controller.text.trim());
                  if (!valid) {
                    setState(() => error = t('lock_dialog_disable_error'));
                    return;
                  }
                  if (context.mounted) {
                    Navigator.of(context).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(t('lock_dialog_disable_success'))),
                    );
                  }
                },
                child: Text(t('lock_dialog_disable_button')),
              ),
            ],
          );
        },
      );
    },
  );
}

Future<void> _showLanguageSelection(
  BuildContext context,
  LanguageNotifier language,
  String Function(String, [Map<String, String>?]) t,
) async {
  await showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (context) {
      return SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Text(
                t('language_section_title'),
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            ...AppLanguage.values.map(
              (lang) {
                return RadioListTile<AppLanguage>(
                  value: lang,
                  groupValue: language.current,
                  title: Text(lang.displayName),
                  onChanged: (_) async {
                    await language.setLanguage(lang);
                    if (!context.mounted) return;
                    Navigator.of(context).pop();
                  },
                );
              },
            ),
            const SizedBox(height: 12),
          ],
        ),
      );
    },
  );
}
