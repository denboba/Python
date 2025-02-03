import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import '../constants/string_constants.dart';
import '../provider/auth_provider.dart';
import '../widgets/avatar.dart';
import '../features/home/home_page.dart';

class HymedCareSignupPage extends StatefulWidget {
  const HymedCareSignupPage({super.key});

  @override
  HymedCareSignupPageState createState() => HymedCareSignupPageState();
}

class HymedCareSignupPageState extends State<HymedCareSignupPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  bool _isObscured = true;
  bool isDoctor = false;


  Future<void> _register() async {
    final firstName = _firstNameController.text.trim();
    final lastName = _lastNameController.text.trim();
    final email = _emailController.text.trim();
    final phoneNumber = _phoneNumberController.text.trim();
    final password = _passwordController.text.trim();
    final confirmPassword = _confirmPasswordController.text.trim();

    if (password != confirmPassword) {
      showCupertinoDialog(
        context: context,
        builder: (context) => CupertinoAlertDialog(
          title: const Text('Error'),
          content: const Text('Passwords do not match'),
          actions: <Widget>[
            CupertinoDialogAction(
              child: const Text('OK'),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
      );
      return;
    }

    try {
      await Provider.of<HymedCareAuthProvider>(context, listen: false).registerWithRole(
        firstName: firstName,
        lastName: lastName,
        email: email,
        password: password,
        role: isDoctor ? 'Doctor' : 'Patient',
        phoneNumber: phoneNumber,
      );

      // Clear the fields after successful registration
      _firstNameController.clear();
      _lastNameController.clear();
      _emailController.clear();
      _phoneNumberController.clear();
      _passwordController.clear();
      _confirmPasswordController.clear();

      if (mounted) {
        Navigator.pushReplacement(
          context,
          CupertinoPageRoute(builder: (context) => const HomePage()),
        );
      }

      showCupertinoDialog(
        context: context,
        builder: (context) => CupertinoAlertDialog(
          title: const Text('Success'),
          content: const Text('Verification email sent. Please verify your email.'),
          actions: <Widget>[
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
          title: const Text('Signup Failed'),
          content: Text(e.toString()),
          actions: <Widget>[
            CupertinoDialogAction(
              child: const Text('OK'),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
      );
    }
   // Navigator.pop(context);
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _phoneNumberController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      child: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(32.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    const CupertinoAvatar(name: Strings.logoName, size: 100),
                    SizedBox(height: 20),
                    const Text(
                      'Welcome to ${Strings.appName}',
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                        color: HymedCareAppColor.blue,
                      ),
                    ),
                    SizedBox(height: 40),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        CupertinoTextField(
                          controller: _firstNameController,
                          placeholder: Strings.firstName,
                          decoration: _borderDecoration(),
                        ),
                        const SizedBox(height: 20),
                        CupertinoTextField(
                          controller: _lastNameController,
                          placeholder: Strings.lastName,
                          decoration: _borderDecoration(),
                        ),
                        const SizedBox(height: 20),
                        CupertinoTextField(
                          controller: _emailController,
                          placeholder: Strings.email,
                          decoration: _borderDecoration(),
                        ),
                        const SizedBox(height: 20),
                        // phoneNumber with country code
                        CupertinoTextField(
                          controller: _phoneNumberController,
                          placeholder: Strings.phoneNumber,
                          decoration: _borderDecoration(),
                        ),
                        const SizedBox(height: 20),
                        CupertinoTextField(
                          controller: _passwordController,
                          placeholder: Strings.password,
                          obscureText: _isObscured,
                          suffix: _obscurePassword(_isObscured),
                          decoration: _borderDecoration(),
                        ),
                        const SizedBox(height: 20),
                        CupertinoTextField(
                          controller: _confirmPasswordController,
                          placeholder: Strings.confirmPassword,
                          obscureText: _isObscured,
                          suffix: _obscurePassword(_isObscured),
                          decoration: _borderDecoration(),
                        ),
                        const SizedBox(height: 20),
                        Row(children: [
                          Expanded(
                            child: Text(
                              "Are you ${Strings.doctor}?",
                              style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: HymedCareAppColor.blue),
                            ),
                          ),
                          CupertinoSwitch(
                            activeTrackColor: HymedCareAppColor.blue,
                            value: isDoctor,
                            onChanged: (bool value) {
                              setState(() {
                                isDoctor = value;
                              });
                            },
                          ),
                        ]),
                        const SizedBox(height: 20),
                        CupertinoButton(
                          color: HymedCareAppColor.blue,
                          onPressed: _register,
                          child: const Text(
                            Strings.register,
                            style: TextStyle(
                              color: HymedCareAppColor.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        GestureDetector(
                          onTap: () {
                            Navigator.pop(context);
                          },
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                "Already have an account?",
                                style: TextStyle(
                                  color: HymedCareAppColor.blue,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
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

  CupertinoButton _obscurePassword(bool isObscured) {
    if (isObscured) {
      return
        CupertinoButton(
          child: const Icon(CupertinoIcons.eye, color: HymedCareAppColor.blue),
          onPressed: () {
            setState(() {
              _isObscured = !_isObscured;
            });
          },
        );
    }
    else{
      return CupertinoButton(
        child: const Icon(CupertinoIcons.eye_slash, color: CupertinoColors.inactiveGray),
        onPressed: () {
          setState(() {
            _isObscured = !_isObscured;
          });
        },
      );
    }
  }
}
