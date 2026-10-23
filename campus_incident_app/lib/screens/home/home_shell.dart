import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/app_config.dart';
import '../../providers/auth_provider.dart';
import '../../utils/ui.dart';
import '../incidents/incident_list_screen.dart';
import '../profile/profile_screen.dart';
import '../staff/staff_dashboard_screen.dart';
import 'home_screen.dart';

/// Bottom-navigation shell. Students get Home / Reports / Profile;
/// staff get Dashboard / Reports / Profile and a Deep Pine app bar.
class HomeShell extends StatefulWidget {
  const HomeShell({super.key});
  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final staff = context.watch<AuthProvider>().isStaff;
    final titles = [staff ? 'Staff dashboard' : AppConfig.appName, 'Reports', 'Profile'];
    final pages = [
      staff
          ? const StaffDashboardScreen()
          : HomeScreen(onSeeAll: () => setState(() => _index = 1)),
      const IncidentListScreen(),
      const ProfileScreen(),
    ];

    return Scaffold(
      appBar: AppBar(title: Text(titles[_index])),
      body: IndexedStack(index: _index, children: pages),
      floatingActionButton: (!staff && _index != 2)
          ? FloatingActionButton.extended(
              onPressed: () => openReport(context),
              icon: const Icon(Icons.add),
              label: const Text('Report an issue'),
            )
          : null,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: [
          NavigationDestination(
            icon: Icon(staff ? Icons.dashboard_outlined : Icons.home_outlined),
            selectedIcon: Icon(staff ? Icons.dashboard : Icons.home),
            label: staff ? 'Dashboard' : 'Home',
          ),
          const NavigationDestination(
            icon: Icon(Icons.list_alt_outlined),
            selectedIcon: Icon(Icons.list_alt),
            label: 'Reports',
          ),
          const NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}