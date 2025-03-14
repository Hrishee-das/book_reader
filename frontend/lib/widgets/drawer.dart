import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../screens/login_screen.dart';

class AppDrawer extends StatelessWidget {
  final String name;
  final String email;

  const AppDrawer({super.key, required this.name, required this.email});

  Future<void> _logout(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => LoginScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.white, // Solid white background
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + 20,
              bottom: 20,
            ),
            alignment: Alignment.center,
            child: Column(
              children: [
                CircleAvatar(
                  backgroundColor: Colors.blue[100], // Light blue circle
                  radius: 40,
                  child: Icon(
                    Icons.person,
                    size: 40,
                    color: Colors.blue[800],
                  ), // Darker blue icon
                ),
                SizedBox(height: 10),
                Text(
                  name,
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                ),
                SizedBox(height: 5),
                Text(
                  email,
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
          Divider(height: 1, color: Colors.grey[300]), // Subtle divider
          ListTile(
            leading: Icon(Icons.logout, color: Colors.red),
            title: Text('Logout', style: TextStyle(fontSize: 16)),
            onTap: () => _logout(context),
          ),
          Spacer(),
          Padding(
            padding: const EdgeInsets.only(bottom: 20.0),
            child: Text(
              "Version 1.0.0",
              style: TextStyle(color: Colors.grey[600]),
            ),
          ),
        ],
      ),
    );
  }
}
