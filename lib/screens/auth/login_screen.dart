import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../core/app_config.dart';
import '../../core/theme/app_colors.dart';
import '../../core/validators.dart';
import '../../providers/auth_provider.dart';
import '../../utils/ui.dart';
import '../../widgets/app_button.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _form = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _hide = true;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_form.currentState!.validate()) return;
    final err = await context
        .read<AuthProvider>()
        .signIn(_email.text, _password.text);
    if (err != null && mounted) showSnack(context, err, error: true);
  }

  Future<void> _forgot() async {
    final ctrl = TextEditingController(text: _email.text);
    final email = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Reset password'),
        content: TextField(
          controller: ctrl,
          keyboardType: TextInputType.emailAddress,
          decoration: const InputDecoration(labelText: 'ALU email'),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          TextButton(
              onPressed: () => Navigator.pop(ctx, ctrl.text),
              child: const Text('Send link')),
        ],
      ),
    );
    if (email == null || !mounted) return;
    if (Validators.aluEmail(email) != null) {
      showSnack(context, 'Enter your ALU email first.', error: true);
      return;
    }
    final err = await context.read<AuthProvider>().resetPassword(email);
    if (!mounted) return;
    showSnack(context, err ?? 'Reset link sent. Check your inbox.',
        error: err != null);
  }

  @override
  Widget build(BuildContext context) {
    final busy = context.watch<AuthProvider>().busy;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        body: SingleChildScrollView(
          child: Column(children: [
            const _Hero(),
            Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 420),
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Form(
                    key: _form,
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          TextFormField(
                            controller: _email,
                            keyboardType: TextInputType.emailAddress,
                            autofillHints: const [AutofillHints.email],
                            decoration: const InputDecoration(
                                labelText: 'ALU email',
                                prefixIcon: Icon(Icons.mail_outline)),
                            validator: Validators.aluEmail,
                          ),
                          const SizedBox(height: 14),
                          TextFormField(
                            controller: _password,
                            obscureText: _hide,
                            autofillHints: const [AutofillHints.password],
                            decoration: InputDecoration(
                              labelText: 'Password',
                              prefixIcon: const Icon(Icons.lock_outline),
                              suffixIcon: IconButton(
                                icon: Icon(_hide
                                    ? Icons.visibility_outlined
                                    : Icons.visibility_off_outlined),
                                onPressed: () => setState(() => _hide = !_hide),
                              ),
                            ),
                            validator: (v) => Validators.required(v, 'Password'),
                            onFieldSubmitted: (_) => _submit(),
                          ),
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                                onPressed: _forgot,
                                child: const Text('Forgot password?')),
                          ),
                          const SizedBox(height: 8),
                          AppButton(
                              label: 'Log in', loading: busy, onPressed: _submit),
                          const SizedBox(height: 16),
                          Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text('New here?',
                                    style: TextStyle(color: AppColors.slate)),
                                TextButton(
                                  onPressed: () => Navigator.of(context).push(
                                      MaterialPageRoute(
                                          builder: (_) => const RegisterScreen())),
                                  child: const Text('Create an account'),
                                ),
                              ]),
                        ]),
                  ),
                ),
              ),
            ),
          ]),
        ),
      ),
    );
  }
}

/// Campus photo with a flat Deep Pine tint so the white text stays readable.
class _Hero extends StatelessWidget {
  const _Hero();

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.of(context).padding.top;
    return SizedBox(
      height: 240 + top,
      width: double.infinity,
      child: Stack(fit: StackFit.expand, children: [
        Image.asset(
          'assets/images/campus.jpg',
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => Container(color: AppColors.pine),
        ),
        Container(color: AppColors.deepPine.withValues(alpha: 0.5)),
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12)),
                child: const Icon(Icons.report_problem_outlined,
                    color: AppColors.pine, size: 26),
              ),
              const SizedBox(height: 14),
              Text(AppConfig.appName,
                  style: Theme.of(context)
                      .textTheme
                      .headlineSmall
                      ?.copyWith(color: Colors.white)),
              const SizedBox(height: 4),
              const Text('Report campus issues. Track the fix.',
                  style: TextStyle(color: Colors.white70)),
            ],
          ),
        ),
      ]),
    );
  }
}