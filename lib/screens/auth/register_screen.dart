import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class RegisterScreen extends StatefulWidget {

  const RegisterScreen({
    super.key,
  });

  @override
  State<RegisterScreen> createState() =>
      _RegisterScreenState();
}

class _RegisterScreenState
    extends State<RegisterScreen> {

  final _emailController =
      TextEditingController();

  final _passwordController =
      TextEditingController();

  @override
  void dispose() {

    _emailController.dispose();

    _passwordController.dispose();

    super.dispose();
  }

  Future<void> _register() async {

    final email =
        _emailController.text.trim();

    final password =
        _passwordController.text.trim();

    if (email.isEmpty ||
        password.isEmpty) {

      ScaffoldMessenger.of(context)
          .showSnackBar(

        const SnackBar(
          content: Text(
            'Please enter email and password',
          ),
        ),
      );

      return;
    }

    try {

      await Supabase.instance.client
          .auth
          .signUp(

        email: email,
        password: password,
      );

      ScaffoldMessenger.of(context)
          .showSnackBar(

        const SnackBar(
          content: Text(
            'Account created! Please login',
          ),
        ),
      );

      Navigator.pop(context);

    } catch (e) {

      ScaffoldMessenger.of(context)
          .showSnackBar(

        SnackBar(
          content: Text(
            e.toString(),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(
        title: const Text(
          'Create Account',
        ),
      ),

      body: Padding(

        padding:
            const EdgeInsets.all(24),

        child: Column(

          crossAxisAlignment:
              CrossAxisAlignment.stretch,

          children: [

            const SizedBox(
              height: 24,
            ),

            // ✅ LOGO
            Center(
              child: Image.asset(
                'assets/images/logo.png',

                width: 380,
              ),
            ),

            const SizedBox(
              height: 4,
            ),

            // ✅ TITLE
            const Text(

              'Create Account',

              textAlign: TextAlign.center,

              style: TextStyle(
                fontSize: 26,
                fontWeight:
                    FontWeight.bold,
              ),
            ),

            const SizedBox(
              height: 24,
            ),

            // ✅ EMAIL
            TextField(

              controller:
                  _emailController,

              decoration:
                  InputDecoration(

                labelText: 'Email',

                border:
                    OutlineInputBorder(

                  borderRadius:
                      BorderRadius.circular(
                    12,
                  ),
                ),
              ),
            ),

            const SizedBox(
              height: 16,
            ),

            // ✅ PASSWORD
            TextField(

              controller:
                  _passwordController,

              obscureText: true,

              decoration:
                  InputDecoration(

                labelText: 'Password',

                border:
                    OutlineInputBorder(

                  borderRadius:
                      BorderRadius.circular(
                    12,
                  ),
                ),
              ),
            ),

            const SizedBox(
              height: 24,
            ),

            // ✅ BUTTON
            ElevatedButton(

              onPressed: _register,

              style:
                  ElevatedButton.styleFrom(

                backgroundColor:
                    const Color(
                  0xFF6A3FC7,
                ),

                foregroundColor:
                    Colors.white,

                padding:
                    const EdgeInsets.symmetric(
                  vertical: 16,
                ),

                shape:
                    RoundedRectangleBorder(

                  borderRadius:
                      BorderRadius.circular(
                    12,
                  ),
                ),
              ),

              child: const Text(

                'Create Account',

                style: TextStyle(
                  fontSize: 16,
                  fontWeight:
                      FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}