import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class HymedCareAppColor {
  static const Color blue = Color(0xFF254BD2);
  static const Color white = Color(0xFFFFFFFF);
  static TextStyle h =
      GoogleFonts.openSans(color: HymedCareAppColor.blue, fontSize: 16);
}

class HymedCareAppFont {
  static TextStyle fon16 =
      GoogleFonts.openSans(color: HymedCareAppColor.blue, fontSize: 16);
}

class Strings {
  static const String appName = 'Hymedcare';
  static const String login = 'Login';
  static const String logoName = 'assets/images/hymedcare-logo.png';
  static const String email = 'Email';
  static const String password = 'Password';
  static const String confirmPassword = 'Confirm Password';
  static const String rememberMe = 'Remember me';
  static const String forgotPassword = 'Forgot Password?';
  static const String dontHaveAccount = 'Don\'t have an account?';
  static const String register = 'Sign Up';
  static const String firstName = 'First Name';
  static const String lastName = 'Last Name';
  static const String alreadyHaveAccount = 'Already have an account?';

  static String doctor = 'Doctor';
  static String resetPassword = 'Reset Password';

  static String phoneNumber = 'Phone Number';
}

class ErrorMessages {
  static const String email = 'Please enter your email';
  static const String password = 'Please enter your password';
  static const String confirmPassword = 'Please confirm your password';
  static const String firstName = 'Please enter your first name';
  static const String lastName = 'Please enter your last name';
}


class UserModels {
  static const String doctor = 'Doctor';
}
