import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import '../constants/string_constants.dart';
import '../provider/auth_provider.dart';
import 'login_page.dart';

class ResetPasswordPage extends StatefulWidget {
  const ResetPasswordPage({super.key});

  @override
  ResetPasswordPageState createState() => ResetPasswordPageState();
}

class ResetPasswordPageState extends State<ResetPasswordPage> {
  final TextEditingController _emailController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _resetPassword(BuildContext context) async {
    try {
      await Provider.of<HymedCareAuthProvider>(context, listen: false)
          .resetPassword(_emailController.text.trim());
      showCupertinoDialog(
        context: context,
        builder: (context) => CupertinoAlertDialog(
          title: const Text('Password Reset'),
          content: const Text('A password reset link has been sent to your email.'),
          actions: [
            CupertinoDialogAction(
              child: const Text('OK'),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
      );
    } catch (e) {
          showCupertinoDialog(
            context: context,
            builder: (context) => CupertinoAlertDialog(
              title: const Text('Error'),
              content: Text(e.toString()),
              actions: [
                CupertinoDialogAction(
                  child: const Text('OK'),
                  onPressed: () => Navigator.pop(context),
                ),
              ]
            )
          );

        }
  }
  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: const Text("Reset Password"),
        backgroundColor: CupertinoColors.systemGrey6,
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              const SizedBox(height: 60),
              const Text(
                "Reset Your Password",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: HymedCareAppColor.blue,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                "Enter your email address below to receive a password reset link.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: CupertinoColors.systemGrey,
                ),
              ),
              const SizedBox(height: 30),
              CupertinoTextField(
                controller: _emailController,
                placeholder: "Email Address",
                keyboardType: TextInputType.emailAddress,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: HymedCareAppColor.blue,
                    width: 1.4,
                  ),
                  borderRadius: BorderRadius.circular(10.0),
                ),
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 20),
              CupertinoButton(
                color: HymedCareAppColor.blue,
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: const Text(
                  "Send Reset Link",
                  style: TextStyle(
                    color: CupertinoColors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                onPressed: () {
                  _resetPassword(context);
                  Navigator.pushReplacement(
                    context,
                    CupertinoPageRoute(
                      builder: (context) => const TelemedLoginPage(),
                    ),
                  );
                },
              ),
              const SizedBox(height: 20),
              CupertinoButton(
                child: const Text(
                  "Back to Login",
                  style: TextStyle(
                    color: HymedCareAppColor.blue,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    CupertinoPageRoute(
                      builder: (context) => const TelemedLoginPage(),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
