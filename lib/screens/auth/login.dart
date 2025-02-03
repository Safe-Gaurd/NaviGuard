import 'package:delightful_toast/toast/utils/enums.dart';
import 'package:flutter/material.dart';
import 'package:navigaurd/backend/auth/auth_methods.dart';
import 'package:navigaurd/constants/colors.dart';
import 'package:navigaurd/constants/toast.dart';
import 'package:navigaurd/screens/auth/forgot_password.dart';
import 'package:navigaurd/screens/auth/signup.dart';
import 'package:navigaurd/screens/auth/widgets/custom_auth_buttons.dart';
import 'package:navigaurd/screens/auth/widgets/customtextformfield.dart';
import 'package:navigaurd/screens/home/home.dart';
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => LoginScreenState();
}

class LoginScreenState extends State<LoginScreen> 
{
  TextEditingController email=TextEditingController();
  TextEditingController password=TextEditingController();
  bool obscureText=true;
  Widget hashing=const Icon(Icons.visibility);
  bool isLoading = false;
  bool isgoogleLoading=false;
  final formKey = GlobalKey<FormState>();
  final AuthService authService = AuthService();

  @override
  void dispose() {
    email.dispose();
    password.dispose();
    super.dispose();
  }

  void loginWithEmail() async{
    if (!formKey.currentState!.validate())
    {
      toastMessage(
            context: context,
            message: "Please Fill All Fields",
            leadingIcon: const Icon(Icons.message),
          toastColor: Colors.yellow[300],
          borderColor: Colors.orange,
          position: DelightSnackbarPosition.top
          );
      return;
    }

    setState(() {
      isLoading=true;
    });
    String res=await authService.handleLoginWithEmail(email: email.text, password: password.text);
    if(res=="success")
    {
      Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => const HomeScreen(isLoginOrSignUp: true,)));
    }
    else
    {
      toastMessage(
            context: context,
            message: "Invalid Email Or Password",
            leadingIcon: const Icon(Icons.error),
            toastColor: Colors.red[200],
            borderColor: Colors.red,
            position: DelightSnackbarPosition.top
          );
    }
    setState(() {
      isLoading = false;
    });

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10.0),
            child: Form(
              key: formKey,
              child: Column(
                children: [
                  
                  const SizedBox(height: 20.0),
                  const Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        "W",
                        style: TextStyle(
                          fontSize: 50.0,
                          fontWeight: FontWeight.bold
                        ),
                      ),
                      Text(
                        "elcome back!",
                        style: TextStyle(fontSize: 30.0, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  Transform.translate(
                    offset: const Offset(0, -14), 
                    child: const Text(
                      "Access your account to continue your journey",
                      style: TextStyle(
                        fontSize: 16.5,
                        fontWeight: FontWeight.bold,
                        color: blueColor,
                      ),
                    ),
                  ),

                  Image.asset(
                    "assets/auth/login.jpg",
                    width: 300, 
                    height: 310, 
                  ),
              
                  CustomTextFormField(
                    label: "Email", 
                    hinttext: "Enter Your Email", 
                    controller: email,
                    prefixicon: Icons.email_rounded,
                    validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Email is required';
                          } else if (!RegExp(r'^[^@]+@[^@]+\.[^@]+')
                              .hasMatch(value)) {
                            return 'Enter a valid email';
                          }
                          return null;
                        },
                  ),
              
              
                  CustomTextFormField(
                    label: "password", 
                    hinttext: "Enter Your Password", 
                    controller: password,
                    prefixicon: Icons.lock,
                    isobsure: obscureText,
                    suffixicon: IconButton(onPressed: (){
                      obscureText =!obscureText;
                      hashing=obscureText ? const Icon(Icons.visibility) : const Icon(Icons.visibility_off);
                      setState(() {});
                    },
                    icon: hashing),
                    validator: (value){
                      if (value == null || value.isEmpty) {
                            return 'Password is required';
                          }
                      return null;
                    }
                  ),

                  const SizedBox(height: 10,),
                  LoginSignupButtons(
                          label: "LogIn",
                          onTap: loginWithEmail,
                          isLoading: isLoading,
                          backgroundColor: Colors.blue[500],
                        ),
              
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (context) => const ForgotPassword())), 
                      child: const Text("Forgot Password", style: TextStyle(color: Colors.red, fontSize: 15),)),
                  ),
              
                  const Text("Or",style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),),
              
                  const SizedBox(height: 20,),
                  LoginSignupButtons(
                    imagepath: "assets/auth/google.jpg", 
                    label: "Login With Google", 
                    onTap: (){
                      setState(() {
                        isgoogleLoading=true;
                      });

                      String res=authService.handleSignUpWithGoogle().toString();
                      if(res=="success")
                      {
                        Navigator.of(context).push(MaterialPageRoute(builder: (context) => const HomeScreen()));
                        return;
                      }
                      toastMessage(context: context, message: res);
                      isLoading = !isgoogleLoading;
                    }),

                  const SizedBox(height: 10,),
                  TextButton(onPressed: (){
                          Navigator.of(context).push(MaterialPageRoute(builder: (context) => const SignupScreen()));
                        }, 
                            child: const Text("Don't have an Account?", style: TextStyle(color: Colors.black54, fontSize: 15, fontWeight: FontWeight.bold),))
              
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}