import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../store/lock_notifier.dart';

class LockGate extends StatefulWidget {
  final Widget child;

  const LockGate({super.key, required this.child});

  @override
  State<LockGate> createState() => _LockGateState();
}

class _LockGateState extends State<LockGate> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (!mounted) return;
    final lock = Provider.of<LockNotifier>(context, listen: false);
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive) {
      lock.resetAuthentication();
    }
  }

  @override
  Widget build(BuildContext context) {
    final lock = context.watch<LockNotifier>();
    final showLock = lock.lockEnabled && !lock.isAuthenticated;
    return Stack(
      children: [
        widget.child,
        if (showLock)
          Positioned.fill(
            child: Overlay(
              initialEntries: [
                OverlayEntry(builder: (_) => const _LockScreenOverlay()),
              ],
            ),
          ),
      ],
    );
  }
}

class _LockScreenOverlay extends StatefulWidget {
  const _LockScreenOverlay();

  @override
  State<_LockScreenOverlay> createState() => _LockScreenOverlayState();
}

class _LockScreenOverlayState extends State<_LockScreenOverlay> {
  final TextEditingController _controller = TextEditingController();
  String? _error;
  bool _loading = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final notifier = context.read<LockNotifier>();
    final password = _controller.text.trim();
    if (password.isEmpty) {
      setState(() => _error = 'Parolni kiriting');
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
    });
    final success = await notifier.authenticate(password);
    if (!mounted) return;
    setState(() => _loading = false);
    if (!success) {
      setState(() => _error = 'Parol noto‘g‘ri');
    } else {
      _controller.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black,
      child: Center(
        child: Material(
          color: Colors.white,
          borderRadius: BorderRadius.circular(26),
          elevation: 24,
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.lock_outline, size: 48, color: Colors.indigo),
                const SizedBox(height: 12),
                Text(
                  'Parolni kiriting',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 8),
                Text(
                  'Ilovangizni himoya qilish uchun parolni kiriting.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _controller,
                  obscureText: true,
                  decoration: InputDecoration(
                    hintText: 'Parol',
                    errorText: _error,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onSubmitted: (_) => _submit(),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: _loading ? null : _submit,
                    child: _loading
                        ? const SizedBox(
                            height: 18,
                            width: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Kirish'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
