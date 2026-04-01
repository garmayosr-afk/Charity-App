import 'package:flutter/material.dart';
import '../auth/login_page.dart';
import '../../widgets/background.dart';
import '../../widgets/card.dart';

class UserPage extends StatelessWidget {
  const UserPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Select Your Role"),
        centerTitle: true,
      ),
      body: Background(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  const Text(
                    "Choose how you'd like to use SOS Village",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 24,
                      fontFamily: 'Roboto',
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 40),
                  RoleCard(
                    icon: Icons.person,
                    color: Colors.blue,
                    title: "I Want To Donate",
                    description:
                        "Support orphanages by making donations, sponsoring children, or funding specific projects",
                    buttonText: "Continue as Donator",
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) {
                          return const LoginPage();
                        }),
                      );
                    },
                  ),
                  const SizedBox(height: 20),
                  RoleCard(
                    icon: Icons.home,
                    color: Colors.lightGreen,
                    title: "I Represent an Orphanage",
                    description:
                        "Register your orphanage to receive donations, manage needs, and connect with donors",
                    buttonText: "Continue as Orphanage",
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) {
                          return const LoginPage();
                        }),
                      );
                    },
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
