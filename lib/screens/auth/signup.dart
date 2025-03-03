import 'package:delightful_toast/toast/utils/enums.dart';
import 'package:flutter/material.dart';
import 'package:navigaurd/constants/colors.dart';
import 'package:navigaurd/constants/toast.dart';
import 'package:navigaurd/enum/enums.dart';
import 'package:navigaurd/screens/auth/login.dart';
import 'package:navigaurd/screens/auth/widgets/custom_auth_buttons.dart';
import 'package:navigaurd/screens/auth/widgets/customtextformfield.dart';
import 'package:navigaurd/backend/auth/auth_methods.dart';
import 'package:navigaurd/screens/home/home.dart';

class SignupScreen extends StatefulWidget {
  final bool? isUser;

  const SignupScreen({
    super.key,
    this.isUser,
  });

  @override
  State<SignupScreen> createState() => SignupScreenState();
}

class SignupScreenState extends State<SignupScreen> {
  final TextEditingController name = TextEditingController();
  final TextEditingController email = TextEditingController();
  final TextEditingController password = TextEditingController();
  final TextEditingController phonenum = TextEditingController();

  final formKey = GlobalKey<FormState>();
  final AuthService authService = AuthService();

  bool obscureText = true;
  bool isLoading = false;
  bool isgoogleLoading = false;
  Officer? selectedOfficer;

  @override
  void dispose() {
    email.dispose();
    password.dispose();
    phonenum.dispose();
    name.dispose();
    super.dispose();
  }

  void signUpEmail() async {
    if (!formKey.currentState!.validate()) {
      toastMessage(
          context: context,
          message: 'Fill All Fields!',
          leadingIcon: const Icon(Icons.message),
          toastColor: Colors.yellow[300],
          borderColor: Colors.orange,
          position: DelightSnackbarPosition.top);
      return;
    }

    setState(() {
      isLoading = true;
    });

    String selectedOfficerTitle = getOfficerTitle(selectedOfficer!);

    try {
      String res = await authService.handleSignUpWithEmail(
          email: email.text.trim(),
          password: password.text.trim(),
          name: name.text.trim(),
          phoneNumber: phonenum.text.trim(),
          officerTitle: selectedOfficerTitle);

      if (res == "success") {
        Navigator.of(context).push(
          MaterialPageRoute(
              builder: (context) => const HomeScreen(
                    isLoginOrSignUp: true,
                  )),
        );
      } else {
        toastMessage(
            context: context,
            message: res,
            leadingIcon: const Icon(Icons.message),
            toastColor: Colors.yellow[300],
            borderColor: Colors.orange,
            position: DelightSnackbarPosition.top);
      }
    } catch (e) {
      toastMessage(
          context: context,
          message: e.toString(),
          leadingIcon: const Icon(Icons.error),
          toastColor: Colors.red[200],
          borderColor: Colors.red,
          position: DelightSnackbarPosition.top);
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> signUpWithGoogle() async {
    setState(() {
      isgoogleLoading = true;
    });
    try {
      String res = await authService.handleSignUpWithGoogle();

      if (res == "success") {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
      } else {
        toastMessage(
            context: context,
            message: res,
            leadingIcon: const Icon(Icons.error),
            toastColor: Colors.red[200],
            borderColor: Colors.red,
            position: DelightSnackbarPosition.top);
      }
    } catch (e) {
      toastMessage(
          context: context,
          message: e.toString(),
          leadingIcon: const Icon(Icons.error),
          toastColor: Colors.red[200],
          borderColor: Colors.red,
          position: DelightSnackbarPosition.top);
    } finally {
      setState(() {
        isgoogleLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18.0),
            child: Form(
              key: formKey,
              child: Column(
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      const Text(
                        "O",
                        style: TextStyle(
                          fontSize: 60.0,
                        ),
                      ),
                      Transform.translate(
                        offset: const Offset(0, -4),
                        child: const Text(
                          "nboard!",
                          style: TextStyle(
                              fontSize: 30.0, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                  Transform.translate(
                    offset: const Offset(0, -22),
                    child: const Text(
                      "Create an account to start your journey",
                      style: TextStyle(
                        fontSize: 18.0,
                        fontWeight: FontWeight.bold,
                        color: blueColor,
                      ),
                    ),
                  ),
                  Image.asset(
                    "assets/auth/signup.jpg",
                    width: screenWidth * 0.65,
                    height: screenHeight * .25,
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  CustomTextFormField(
                    label: "Name",
                    hinttext: "Enter Your Name",
                    controller: name,
                    prefixicon: Icons.person_2,
                    validator: (value) => value == null || value.isEmpty
                        ? 'Name is required'
                        : null,
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
                    label: "Password",
                    hinttext: "Enter Your Password",
                    controller: password,
                    prefixicon: Icons.lock,
                    isobsure: obscureText,
                    suffixicon: IconButton(
                      onPressed: () {
                        setState(() {
                          obscureText = !obscureText;
                        });
                      },
                      icon: Icon(obscureText
                          ? Icons.visibility
                          : Icons.visibility_off),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Password is required';
                      }
                      //  else if (value.length < 8) {
                      //   return 'Password must be at least 8 characters';
                      // } else if (!RegExp(r'[A-Z]').hasMatch(value)) {
                      //   return 'Password must contain at least one uppercase letter';
                      // } else if (!RegExp(r'\d').hasMatch(value)) {
                      //   return 'Password must contain at least one number';
                      // } else if (!RegExp(r'[!@#$%^&*(),.?":{}|<>]')
                      //     .hasMatch(value)) {
                      //   return 'Password must contain at least one special character';
                      // }
                      return null;
                    },
                  ),
                  CustomTextFormField(
                    label: "Phone Number",
                    hinttext: "Enter Your Mobile Number",
                    controller: phonenum,
                    prefixicon: Icons.phone,
                    keyboard: TextInputType.phone,
                    validator: (value) =>
                        value == null || value.isEmpty || value.length < 10
                            ? 'Please enter a valid phone number'
                            : null,
                  ),
                  if (!widget.isUser!)
                    Padding(
                      padding: const EdgeInsets.all(7.0),
                      child: DropdownButtonHideUnderline(
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(20.0),
                            border: Border.all(color: Colors.grey),
                          ),
                          child: Row(
                            children: [
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12.0),
                                child: Icon(Icons.security),
                              ),
                              Expanded(
                                child: DropdownButton<Officer>(
                                  value: selectedOfficer,
                                  isExpanded: true,
                                  hint: const Text(
                                    'Select Officer Type',
                                    style: TextStyle(
                                      color: Colors.black87,
                                      fontWeight: FontWeight.normal,
                                    ),
                                  ),
                                  items: Officer.values.map((officer) {
                                    return DropdownMenuItem<Officer>(
                                      value: officer,
                                      child: Row(
                                        children: [
                                          Text(
                                            getOfficerTitle(officer),
                                            style: const TextStyle(
                                              fontSize: 16,
                                            ),
                                          ),
                                          const SizedBox(width: 10),
                                          Icon(getOfficerIcon(officer)),
                                        ],
                                      ),
                                    );
                                  }).toList(),
                                  onChanged: (Officer? newValue) {
                                    setState(() {
                                      selectedOfficer = newValue;
                                    });
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  SizedBox(
                    height: screenHeight * .01,
                  ),
                  LoginSignupButtons(
                    label: "SignUP",
                    onTap: signUpEmail,
                    isLoading: isLoading,
                    backgroundColor: Colors.blue[500],
                  ),
                  SizedBox(
                    height: screenHeight * .015,
                  ),
                  const Text(
                    "Or",
                    style: TextStyle(
                        color: Colors.black, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(
                    height: screenHeight * .015,
                  ),
                  LoginSignupButtons(
                    imagepath: "assets/auth/google.jpg",
                    label: "SignUP With Google",
                    onTap: signUpWithGoogle,
                    isLoading: isgoogleLoading,
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => LoginScreen(
                                isUser: widget.isUser,
                              )));
                    },
                    child: const Text(
                      "Already Have an Account?",
                      style: TextStyle(color: Colors.red, fontSize: 15),
                    ),
                  ),
                  SizedBox(
                    height: screenHeight * .05,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
