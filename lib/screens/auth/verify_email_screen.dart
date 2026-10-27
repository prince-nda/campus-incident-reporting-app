import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../providers/auth_provider.dart';
import '../../utils/ui.dart';
import '../../widgets/app_button.dart';

/// Blocks the app until the ALU email is verified.
class VerifyEmailScreen extends StatelessWidget {
  const VerifyEmailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                const Icon(Icons.mark_email_unread_outlined,
                    size: 54, color: AppColors.pine),
                const SizedBox(height: 16),
                Text('Verify your email',
                    style: Theme.of(context).textTheme.headlineSmall),
                const SizedBox(height: 8),
                Text(
                  'We sent a verification link to\n${auth.user?.email ?? ''}\n'
                      'Open it, then come back and tap the button below.',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: AppColors.slate, height: 1.4),
                ),
                const SizedBox(height: 24),
                AppButton(
                  label: "I've verified my email",
                  loading: auth.busy,
                  onPressed: () async {
                    final ok = await context.read<AuthProvider>().checkVerified();
                    if (!ok && context.mounted) {
                      showSnack(context,
                          'Not verified yet. Check your inbox and spam folder.',
                          error: true);
                    }
                  },
                ),
                const SizedBox(height: 10),
                OutlinedButton(
                  onPressed: auth.busy
                      ? null
                      : () async {
                    final err =
                    await context.read<AuthProvider>().resendVerification();
                    if (context.mounted) {
                      showSnack(context, err ?? 'Verification email sent.',
                          error: err != null);
                    }
                  },
                  child: const Text('Resend email'),
                ),
                TextButton(
                  onPressed: () => context.read<AuthProvider>().signOut(),
                  child: const Text('Use a different account'),
                ),
              ]),
            ),
          ),
        ),
      ),
    );
  }
}