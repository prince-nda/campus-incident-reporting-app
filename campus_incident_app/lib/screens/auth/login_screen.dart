import 'package:flutter/material.dart';
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
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
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
    showSnack(context, err ?? 'Reset link sent. Check your inbox.', error: err != null);
  }

  @override
  Widget build(BuildContext context) {
    final busy = context.watch<AuthProvider>().busy;
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Form(
                key: _form,
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                        color: AppColors.pine, borderRadius: BorderRadius.circular(12)),
                    child: const Icon(Icons.report_problem_outlined,
                        color: Colors.white, size: 28),
                  ),
                  const SizedBox(height: 20),
                  Text(AppConfig.appName,
                      style: Theme.of(context).textTheme.headlineSmall),
                  const SizedBox(height: 4),
                  const Text('Report campus issues. Track the fix.',
                      style: TextStyle(color: AppColors.slate)),
                  const SizedBox(height: 28),
                  TextFormField(
                    controller: _email,
                    keyboardType: TextInputType.emailAddress,
                    autofillHints: const [AutofillHints.email],
                    decoration: const InputDecoration(
                        labelText: 'ALU email', prefixIcon: Icon(Icons.mail_outline)),
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
                        icon: Icon(_hide ? Icons.visibility_outlined : Icons.visibility_off_outlined),
                        onPressed: () => setState(() => _hide = !_hide),
                      ),
                    ),
                    validator: (v) => Validators.required(v, 'Password'),
                    onFieldSubmitted: (_) => _submit(),
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(onPressed: _forgot, child: const Text('Forgot password?')),
                  ),
                  const SizedBox(height: 8),
                  AppButton(label: 'Log in', loading: busy, onPressed: _submit),
                  const SizedBox(height: 16),
                  Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                    const Text('New here?', style: TextStyle(color: AppColors.slate)),
                    TextButton(
                      onPressed: () => Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const RegisterScreen())),
                      child: const Text('Create an account'),
                    ),
                  ]),
                ]),
              ),
            ),
          ),
        ),
      ),
    );
  }
}