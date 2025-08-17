import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../providers/auth_provider.dart';
import 'login_screen.dart';

class MineScreen extends StatelessWidget {
  Future<void> _showSignOutConfirmation(BuildContext context) async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);

    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Sign Out'),
          content: Text('Are you sure you want to sign out?'),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: Text('Sign Out'),
              onPressed: () async {
                Navigator.of(context).pop(); // Сначала закрываем диалог
                try {
                  await Provider.of<AuthProvider>(context, listen: false).signOut();
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => LoginScreen()),
                  );
                } catch (e) {
                  scaffoldMessenger.showSnackBar(
                    SnackBar(content: Text('Error signing out: ${e.toString()}')),
                  );
                }
              },
            ),
          ],
        );
      },
    );
  }


  @override
  Widget build(BuildContext context) {
    final appProvider = Provider.of<AppProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);
    final theme = Theme.of(context);
    final user = authProvider.user;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: ListView(
          padding: EdgeInsets.all(16),
          children: [
            Row(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: theme.cardColor,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 5,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.person,
                    size: 40,
                    color: theme.textTheme.bodyLarge?.color,
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user?.email ?? 'No email',
                        style: theme.textTheme.bodyLarge?.copyWith(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (user?.emailVerified == false)
                        Text(
                          'Email not verified',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontSize: 14,
                            color: Colors.red,
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
            _buildSectionTitle("Account", theme),
            _buildMenuItem(Icons.person, "Profile", theme),
            _buildMenuItem(Icons.payment, "Payment Methods", theme),
            SizedBox(height: 20),
            _buildSectionTitle("Account Actions", theme),
            ListTile(
              leading: Icon(Icons.logout, color: Colors.red),
              title: Text(
                "Sign Out",
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: Colors.red,
                ),
              ),
              onTap: () => _showSignOutConfirmation(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Text(
        title,
        style: theme.textTheme.bodyLarge?.copyWith(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: theme.textTheme.bodyMedium?.color,
        ),
      ),
    );
  }

  Widget _buildMenuItem(IconData icon, String title, ThemeData theme) {
    return ListTile(
      leading: Icon(icon, color: theme.textTheme.bodyMedium?.color),
      title: Text(
        title,
        style: theme.textTheme.bodyLarge,
      ),
      trailing: Icon(Icons.chevron_right, color: theme.textTheme.bodyMedium?.color),
    );
  }
} 