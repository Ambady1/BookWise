import 'package:bookwise/functions/loginandsignup/screens/login.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class MyProfile extends StatelessWidget {
  const MyProfile({Key? key}) : super(key: key);

  Future<void> _logout(BuildContext context) async {
    try {
      await FirebaseAuth.instance.signOut();
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (context) =>
                const LoginPage()), // Navigate to the login screen after logout
      );
    } catch (e) {
      print('Error logging out: $e');
      // Handle error if needed
    }
  }

  @override
  Widget build(BuildContext context) {
    User? user = FirebaseAuth.instance.currentUser;
    String userName = user?.displayName ?? user?.displayName ?? user?.email ?? 'Guest';

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        title: const Text(
          'Profile',
          style: TextStyle(color: Colors.black87),
        ),
        leading: Builder(
          builder: (context) => PopupMenuButton(
            icon: Icon(Icons.menu, color: Colors.black87),
            itemBuilder: (context) => [
              PopupMenuItem(
                child: ListTile(
                  title: Text('Logout'),
                  leading: Icon(Icons.exit_to_app),
                  onTap: () {
                    _logout(context);
                    // Call logout function here
                  },
                ),
              ),
            ],
          ),
        ),
        backgroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const Row(
                children: [
                  CircleAvatar(
                    radius: 50,
                    // backgroundImage: AssetImage('49457.jpg'),
                  )
                ],
              ),
              Container(
                padding: const EdgeInsets.all(10),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          child: Text(
                            userName,
                            style: TextStyle(
                                color: Colors.grey[800],
                                fontSize: 10,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                        Container(
                          child: Text(
                            '@vaiz',
                            style: TextStyle(
                                color: Colors.blueGrey[400],
                                fontSize: 8,
                                fontWeight: FontWeight.w600),
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Container(
                          height: 40,
                          width: 40,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(50),
                            border:
                                Border.all(width: 1, color: Colors.blueGrey),
                          ),
                          child: Center(
                              child: Icon(
                            Icons.message,
                            color: Colors.blueGrey[400],
                          )),
                        ),
                        Container(
                          width: 70,
                          height: 40,
                          padding: const EdgeInsets.only(left: 20),
                          child: TextButton(
                            style: ButtonStyle(
                              shape: MaterialStateProperty.all<
                                  RoundedRectangleBorder>(
                                RoundedRectangleBorder(
                                  side: const BorderSide(
                                    color: Colors.blue,
                                    width: 1,
                                    style: BorderStyle.solid,
                                  ),
                                  borderRadius: BorderRadius.circular(50),
                                ),
                              ),
                              backgroundColor:
                                  MaterialStateProperty.resolveWith<Color>(
                                (Set<MaterialState> states) {
                                  if (states.contains(MaterialState.disabled)) {
                                    return Colors.blue; // Disabled color
                                  }
                                  return Colors.blue; // Normal color
                                },
                              ),
                            ),
                            onPressed: () {
                              // Add onPressed functionality here
                            },
                            child: const Text(
                              'Follow',
                              style: TextStyle(color: Colors.white,fontSize:8 ),
                              
                            ),
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.only(top: 20),
                child: Divider(
                  thickness: 1,
                  color: Colors.blueGrey[200],
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Container(
                    padding:const  EdgeInsets.only(top: 30),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          child: const Text(
                            '203',
                            style: TextStyle(
                                fontWeight: FontWeight.w800, fontSize: 20),
                          ),
                        ),
                        Container(
                          child:const  Text(
                            'Followers',
                            style:
                                TextStyle(fontSize: 15, color: Colors.blueGrey),
                          ),
                        )
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.only(top: 30),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          child: const Text(
                            '932',
                            style: TextStyle(
                                fontWeight: FontWeight.w800, fontSize: 20),
                          ),
                        ),
                        Container(
                          child: const Text(
                            'Following',
                            style:
                                TextStyle(fontSize: 15, color: Colors.blueGrey),
                          ),
                        )
                      ],
                    ),
                  ),
                  Container(
                    padding:const  EdgeInsets.only(top: 30),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          child:const  Text(
                            '30',
                            style: TextStyle(
                                fontWeight: FontWeight.w800, fontSize: 20),
                          ),
                        ),
                        Container(
                          child:const  Text(
                            'Projects',
                            style:
                                TextStyle(fontSize: 15, color: Colors.blueGrey),
                          ),
                        )
                      ],
                    ),
                  ),
                ],
              ),
              Container(
                padding:const  EdgeInsets.only(top: 20),
                child: Divider(
                  thickness: 1,
                  color: Colors.blueGrey[200],
                ),
              ),
              Container(
                padding: const EdgeInsets.only(top: 20),
                child: Divider(
                  thickness: 1,
                  color: Colors.blueGrey[200],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
