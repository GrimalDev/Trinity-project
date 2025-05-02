import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart' as lucide;
import 'package:provider/provider.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:trinity/config/routes.dart';
import 'package:trinity/screens/home_page.dart';
import 'package:trinity/stores/user_store.dart';
import 'package:trinity/utils/api/auth.dart';
import 'package:trinity/utils/api/user.dart';
import 'package:trinity/utils/firebase_utils.dart';

class LoginPage extends StatefulWidget {
  final AuthService? authService;
  final UserApi? userApi;
  const LoginPage({super.key, this.authService, this.userApi});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  final TextEditingController _nomController = TextEditingController();
  final TextEditingController _prenomController = TextEditingController();
  bool obscure = true;
  bool isSignUp = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF18181B),
      body: SingleChildScrollView(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 50),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Trinity",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 45,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 30),
              Center(
                child: SizedBox(
                  width: 270,
                  child: Row(
                    children: [
                      buildTabButton("Login", !isSignUp, () {
                        setState(() => isSignUp = false);
                      }),
                      buildTabButton("Register", isSignUp, () {
                        setState(() => isSignUp = true);
                      }),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 30),
              Center(
                child: Container(
                  width: 360,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1F1F22),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.white, width: 0.5),
                  ),
                  child: Column(
                    children: [
                      if (isSignUp) ...[
                        buildTextInput(
                          _nomController,
                          "Last name",
                          lucide.LucideIcons.user,
                        ),
                        const SizedBox(height: 15),
                        buildTextInput(
                          _prenomController,
                          "First name",
                          lucide.LucideIcons.user,
                        ),
                        const SizedBox(height: 15),
                      ],
                      buildTextInput(
                        _emailController,
                        "Email",
                        lucide.LucideIcons.mail,
                      ),
                      const SizedBox(height: 15),
                      buildPasswordInput(),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: 160,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: Colors.black,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child:
                              isLoading
                                  ? Row(
                                    mainAxisSize: MainAxisSize.min,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      SizedBox(
                                        width: 16,
                                        height: 16,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                                Colors.black,
                                              ),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      const Flexible(
                                        child: Text(
                                          "Loading...",
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ],
                                  )
                                  : Text(
                                    isSignUp ? "Register" : "Login",
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                          onPressed: () {
                            if (isSignUp) {
                              handleRegisterSubmit();
                            } else {
                              handleLoginSubmit();
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  //  fonction pour login
  void handleLoginSubmit() async {
    final authService = widget.authService ?? AuthService();
    final userApi = widget.userApi ?? UserApi();

    setState(() {
      isLoading = true;
    });

    debugPrint("Email: ${_emailController.text}");
    debugPrint("Password: ${_passwordController.text}");

    try {
      final password = hashPassword(_passwordController.text);
      debugPrint("Password: $password");
      debugPrint("test login");
      final response = await authService.login(_emailController.text, password);

      if (!mounted) return;

      if (response.statusCode == 200) {
        debugPrint("login successful");

        final userStore = Provider.of<UserStore>(context, listen: false);

        final userInformation = await userApi.getUser();

        userStore.setUser(userInformation);
        debugPrint("user set in store");

        userStore.setUser(userInformation);

        await Future.delayed(const Duration(milliseconds: 200));

        if (!mounted) return;

        // Skip Firebase initialization in test environment
        if (!const bool.fromEnvironment('FLUTTER_TEST', defaultValue: false)) {
          await initFirebase(context);
          if (!mounted) return;
        }

        try {
          if (const bool.fromEnvironment('FLUTTER_TEST', defaultValue: false)) {
            // In test environment, use simple navigation
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => HomePage()),
            );
          } else {
            // In real app, use AppRoutes
            AppRoutes.of(context).navigateTo(AppRoutes.home);
          }
        } catch (e) {
          // Fallback navigation if AppRoutes fails
          debugPrint('Navigation error: $e');
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => HomePage()),
          );
        }
      }
    } catch (e) {
      debugPrint("login failed ${e.toString()}");
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          // content: Text("Login failed: ${e.toString()}"),
          content: Text("Login failed: invalid email or password"),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  // fonction pour register
  void handleRegisterSubmit() async {
    final authService = widget.authService ?? AuthService();

    setState(() {
      isLoading = true;
    });

    debugPrint("Nom: ${_nomController.text}");
    debugPrint("Prénom: ${_prenomController.text}");
    debugPrint("Email: ${_emailController.text}");
    debugPrint("Mot de passe: ${_passwordController.text}");

    try {
      final password = hashPassword(_passwordController.text);

      final response = await authService.register(
        firstName: _prenomController.text,
        lastName: _nomController.text,
        email: _emailController.text,
        password: password,
      );

      if (!mounted) return;

      if (response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Registration successful! Please log in now."),
            duration: Duration(seconds: 3),
          ),
        );

        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const LoginPage()),
          (route) => false,
        );
      }
    } catch (e) {
      if (!mounted) return;

      debugPrint("Error during registration: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Registration failed: ${e.toString()}"),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Widget buildTextInput(
    TextEditingController controller,
    String placeholder,
    IconData icon,
  ) {
    return SizedBox(
      width: 280,
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.white, width: 0.5),
          borderRadius: BorderRadius.circular(8),
        ),
        child: ShadInput(
          controller: controller,
          placeholder: Text(placeholder),
          leading: Padding(
            padding: const EdgeInsets.all(4.0),
            child: Icon(icon),
          ),
        ),
      ),
    );
  }

  Widget buildPasswordInput() {
    return SizedBox(
      width: 280,
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.white, width: 0.5),
          borderRadius: BorderRadius.circular(8),
        ),
        child: ShadInput(
          controller: _passwordController,
          placeholder: const Text('Password'),
          obscureText: obscure,
          leading: const Padding(
            padding: EdgeInsets.all(4.0),
            child: Icon(lucide.LucideIcons.lock),
          ),
          trailing: ShadIconButton(
            icon: Icon(
              obscure ? lucide.LucideIcons.eyeOff : lucide.LucideIcons.eye,
            ),
            onPressed: () {
              setState(() => obscure = !obscure);
            },
          ),
        ),
      ),
    );
  }

  Widget buildTabButton(String text, bool isActive, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isActive ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            text,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isActive ? Colors.black : Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  String hashPassword(String password) {
    final bytes = utf8.encode(password);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }
}
