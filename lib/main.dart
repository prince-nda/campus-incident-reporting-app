import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/app_config.dart';
import 'core/theme/app_theme.dart';
import 'firebase_options.dart';
import 'providers/auth_provider.dart';
import 'providers/incident_provider.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/verify_email_screen.dart';
import 'screens/home/home_shell.dart';
import 'services/auth_service.dart';
import 'services/incident_service.dart';
import 'services/storage_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const CampusFixApp());
}

class CampusFixApp extends StatelessWidget {
  const CampusFixApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider(AuthService())),
        ChangeNotifierProxyProvider<AuthProvider, IncidentProvider>(
          create: (_) => IncidentProvider(IncidentService(), StorageService()),
          update: (_, auth, incidents) => incidents!..attach(auth),
        ),
      ],
      child: Consumer<AuthProvider>(
        builder: (_, auth, __) => MaterialApp(
          title: AppConfig.appName,
          debugShowCheckedModeBanner: false,
          theme: buildTheme(staff: auth.isStaff),
          home: const AuthGate(),
        ),
      ),
    );
  }
}

/// Routes by session state: loading -> login -> verify email -> app.
class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    if (auth.initializing) return const _Splash();
    if (!auth.isLoggedIn) return const LoginScreen();
    if (!auth.isVerified) return const VerifyEmailScreen();
    if (auth.profile == null) return const _ProfileMissing();
    return const HomeShell();
  }
}

class _Splash extends StatelessWidget {
  const _Splash();
  @override
  Widget build(BuildContext context) =>
      const Scaffold(body: Center(child: CircularProgressIndicator()));
}

class _ProfileMissing extends StatelessWidget {
  const _ProfileMissing();
  @override
  Widget build(BuildContext context) => Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              const Text('We could not load your profile.'),
              const SizedBox(height: 12),
              OutlinedButton(
                onPressed: () => context.read<AuthProvider>().signOut(),
                child: const Text('Log out'),
              ),
            ]),
          ),
        ),
      );
}