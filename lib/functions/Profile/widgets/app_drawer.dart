// app_drawer.dart
import 'package:flutter/material.dart';
import 'package:bookwise/functions/Profile/functions/logout.dart';
import 'package:bookwise/functions/Profile/screens/settings.dart';
import 'package:bookwise/functions/Profile/functions/profilepicupload.dart';

class AppDrawer extends StatelessWidget {
  final Map<String, dynamic> userDetails;

  const AppDrawer({Key? key, required this.userDetails}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          DrawerHeader(
            decoration: const BoxDecoration(
              color: Colors.blue,
            ),
            child: GestureDetector(
              onTap: () => uploadProfileImage(context),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                 CircleAvatar(
  radius: 30,
  backgroundImage: userDetails['photoURL'] != null
      ? NetworkImage(userDetails['photoURL'])
      : null,
  child: userDetails['photoURL'] == null
      ? Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.grey, // You can change this to any color you prefer
          ),
        )
      : null,
),

                  const SizedBox(height: 10),
                  Text(
                    userDetails['username'] ?? 'Username',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '@${userDetails['nickname'] ?? 'username'}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('Settings'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const Settings()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.exit_to_app),
            title: const Text('Logout'),
            onTap: () {
              logout(context);
            },
          ),
        ],
      ),
    );
  }
}
