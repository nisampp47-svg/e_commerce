
import 'package:e_commerce/screen/auth/signup_screen.dart';
import 'package:flutter/cupertino.dart';

import 'login_screen.dart';

class LoginRegister extends StatefulWidget {

  final void Function()? onTap;
  const LoginRegister({super.key, this.onTap});

  @override
  State<LoginRegister> createState() => _LoginRegisterState();
}

class _LoginRegisterState extends State<LoginRegister> {

  bool isLogin = true;

  void toggleScreens() {
    setState(() {
      isLogin = !isLogin;
    });
  }


  @override
  Widget build(BuildContext context) {
   return isLogin
    ? LoginScreen(onTap: toggleScreens,)
    : SignupScreen(onTap: toggleScreens,);
  }
}
