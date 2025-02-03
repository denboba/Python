import 'package:flutter/cupertino.dart';
import 'package:hymedcare/auth/reset_password.dart';
import 'package:hymedcare/auth/signup_page.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../provider/auth_provider.dart';
import '../constants/string_constants.dart';
import '../features/home/home_page.dart';

class TelemedLoginPage extends StatefulWidget {
  const TelemedLoginPage({super.key});

  @override
  State<TelemedLoginPage> createState() => _TelemedLoginPageState();
}

class _TelemedLoginPageState extends State<TelemedLoginPage> {
  bool _isRememberMe = false;
  bool _isObscured = true;
  bool _isLoading = false;

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _attemptAutoLogin();
  }

  Future<void> _attemptAutoLogin() async {
    final prefs = await SharedPreferences.getInstance();
    final savedEmail = prefs.getString('savedEmail');
    final savedPassword = prefs.getString('savedPassword');


    if (savedEmail != null && savedPassword != null) {
      try {
        await Provider.of<HymedCareAuthProvider>(context, listen: false)
            .login(savedEmail, savedPassword);

        Navigator.pushReplacement(
          context,
          CupertinoPageRoute(builder: (context) => const HomePage()),
        );
      } catch (e) {
        await prefs.remove('savedEmail');
        await prefs.remove('savedPassword');
      }
    }
  }

  Future<void> _login(BuildContext context) async {
    try {
     final authProvider =  Provider.of<HymedCareAuthProvider>(context, listen: false);
      await authProvider
          .login(_emailController.text, _passwordController.text);

      final prefs = await SharedPreferences.getInstance();
      if (_isRememberMe) {
        await prefs.setString('savedEmail', _emailController.text);
        await prefs.setString('savedPassword', _passwordController.text);
      }
     await prefs.setString("userId", authProvider.currentUserId);
      Navigator.pushReplacement(
        context,
        CupertinoPageRoute(builder: (context) => const HomePage()),
      );
    } catch (e) {
      showCupertinoDialog(
        context: context,
        builder: (context) => CupertinoAlertDialog(
          title: const Text('Login Failed'),
          content: Text(e.toString()),
          actions: [
            CupertinoDialogAction(
              child: const Text('OK'),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
      );
    }
  }
  //login with google
  void _loginWithGoogle(BuildContext context) {
    //Provider.of<HymedCareAuthProvider>(context, listen: false).loginWithGoogle();

  }





  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              SizedBox(
                width: 400,
                height: 200,
                child: Lottie.asset("assets/animation/doctors.json"),
              ),
              const SizedBox(height: 30),
              Center(
                child: Text(
                  Strings.appName,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: HymedCareAppColor.blue,
                  ),
                ),
              ),
              const SizedBox(height: 30),
              CupertinoTextField(
                placeholder: Strings.email,
                controller: _emailController,
                decoration: _borderDecoration(),
                suffix: CupertinoButton(
                    child: const Icon(CupertinoIcons.mail_solid,
                        color: HymedCareAppColor.blue),
                    onPressed: () {},

                ),
              ),
              const SizedBox(height: 10),
              CupertinoTextField(
                placeholder: Strings.password,
                obscureText: _isObscured,
                controller: _passwordController,
                decoration: _borderDecoration(),
                suffix: _obscurePassword(),
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround
                ,
                children: <Widget>[
                  Row(
                    children: [
                      CupertinoSwitch(
                        activeTrackColor: HymedCareAppColor.blue,
                        value: _isRememberMe,
                        onChanged: (bool value) {
                          setState(() {
                            _isRememberMe = value;
                          });
                        },
                      ),
                      const Text(
                        Strings.rememberMe,
                        style: TextStyle(
                          color: HymedCareAppColor.blue,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                  CupertinoButton(
                    padding: EdgeInsets.zero,
                    onPressed: () {
                      Navigator.push(
                        context,
                        CupertinoPageRoute(
                          builder: (context) => const ResetPasswordPage(),
                        ),
                      );
                    },
                    child: const Text(
                      Strings.forgotPassword,
                      style: TextStyle(
                        color: HymedCareAppColor.blue,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              CupertinoButton(
                color: HymedCareAppColor.blue,
                onPressed: () => _login(context),
                child: const Text(
                  Strings.login,
                  style: TextStyle(
                      color: CupertinoColors.white,
                      fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  const Text(
                    Strings.dontHaveAccount,
                    style: TextStyle(fontSize: 14, color: HymedCareAppColor.blue, fontWeight: FontWeight.bold),
                  ),
                  SizedBox( width: 10),
                  CupertinoButton(
                    padding: EdgeInsets.zero,
                    onPressed: () {
                      Navigator.push(
                        context,
                        CupertinoPageRoute(
                          builder: (context) => const HymedCareSignupPage(),
                        ),
                      );
                    },
                    child: const Text(
                      Strings.register,
                      style: TextStyle(
                        color: HymedCareAppColor.blue,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                children: <Widget>[
                  const Expanded(child: CupertinoDivider()),
                  SizedBox(
                    width: 20),
                  const Text("Or"),
                  SizedBox(
                      width: 20),
                  const Expanded(child: CupertinoDivider()),
                ],
              ),
              const SizedBox(height: 20),
              CupertinoButton(
                color: HymedCareAppColor.blue,
                onPressed: () {
                  _loginWithGoogle(context);

                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 40,
                      height: 30,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: HymedCareAppColor.blue,
                        image: DecorationImage(
                          image: AssetImage('assets/images/google.png'),
                          fit: BoxFit.cover,
                        )
                      ),
                    ),
                    const SizedBox(width: 10),
                    const Text("Sign in with Google", style: TextStyle(color: CupertinoColors.white, fontWeight: FontWeight.bold),),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  CupertinoButton _obscurePassword() {
    return CupertinoButton(
      child: Icon(
        _isObscured ? CupertinoIcons.eye : CupertinoIcons.eye_slash,
        color: _isObscured
            ? HymedCareAppColor.blue
            : CupertinoColors.inactiveGray,
      ),
      onPressed: () {
        setState(() {
          _isObscured = !_isObscured;
        });
      },
    );
  }

  BoxDecoration _borderDecoration() {
    return BoxDecoration(
      border: Border.all(
        color: HymedCareAppColor.blue,
        width: 1.4,
      ),
      borderRadius: BorderRadius.circular(10.0),
    );
  }
}

class CupertinoDivider extends StatelessWidget {
  const CupertinoDivider({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 1.0,
      color: CupertinoColors.inactiveGray,
    );
  }
}
