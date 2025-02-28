import 'package:flutter/material.dart';
import 'package:navigaurd/constants/colors.dart';
import 'package:navigaurd/constants/toast.dart';
import 'package:navigaurd/screens/auth/widgets/customtextformfield.dart';
import 'package:navigaurd/screens/widgets/appbar.dart';
import 'package:navigaurd/screens/widgets/buttons/elevated.dart';

class InsuranceScreen extends StatefulWidget {
  const InsuranceScreen({super.key});

  @override
  State<InsuranceScreen> createState() => _InsuranceScreenState();
}

class _InsuranceScreenState extends State<InsuranceScreen> {
  final TextEditingController name = TextEditingController();
  final TextEditingController email = TextEditingController();
  final TextEditingController password = TextEditingController();
  final TextEditingController phonenum = TextEditingController();
  final TextEditingController address = TextEditingController();
  final TextEditingController dob = TextEditingController();
  final TextEditingController insuranceType = TextEditingController();

  bool obscureText = false;
  bool isLoading = false;

  final formKey = GlobalKey<FormState>();

  void signUpInsurance() async {
    if (!formKey.currentState!.validate()) {
      toastMessage(
        context: context,
        message: 'Please fill all fields!',
        leadingIcon: const Icon(Icons.message),
        toastColor: Colors.yellow[300],
        borderColor: Colors.orange,
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      // String res = await authService.handleInsuranceSignUp(
      //   name: name.text.trim(),
      //   email: email.text.trim(),
      //   password: password.text.trim(),
      //   phoneNumber: phonenum.text.trim(),
      //   address: address.text.trim(),
      //   dob: dob.text.trim(),
      //   insuranceType: insuranceType.text.trim(),
      // );
      String res = "";

      if (res == "") {
        toastMessage(
          context: context,
          message: "Insurance has been applied successfully",
          leadingIcon: const Icon(Icons.message),
          toastColor: Colors.green[800],
          borderColor: Colors.green,
        );
        Navigator.of(context).pop();
      } else {
        toastMessage(
          context: context,
          message: "Please Fill All Fields",
          leadingIcon: const Icon(Icons.message),
          toastColor: Colors.yellow[300],
          borderColor: Colors.orange,
        );
      }
    } catch (e) {
      toastMessage(
        context: context,
        message: e.toString(),
        leadingIcon: const Icon(Icons.error),
        toastColor: Colors.red[200],
        borderColor: Colors.red,
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppbar(label: "Insurance"),
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Form(
              key: formKey,
              child: Column(
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: const [
                      Text(
                        "S",
                        style: TextStyle(
                          fontSize: 55,
                        ),
                      ),
                      Text(
                        "ecure your future with the right\n insurance today",
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  // const SizedBox(height: 20),
                  Image.asset(
                    "assets/home/insurance.jpg",
                    width: 270,
                    height: 240,
                  ),
                  // const SizedBox(height: 20),
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
                    isobsure: true,
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
                      } else if (value.length < 8) {
                        return 'Password must be at least 8 characters';
                      }
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
                  CustomTextFormField(
                    label: "Address",
                    hinttext: "Enter Your Address",
                    controller: address,
                    prefixicon: Icons.home,
                    validator: (value) => value == null || value.isEmpty
                        ? 'Address is required'
                        : null,
                  ),
                  CustomTextFormField(
                    label: "Date of Birth",
                    hinttext: "Enter Your Date of Birth",
                    controller: dob,
                    prefixicon: Icons.calendar_today,
                    keyboard: TextInputType.datetime,
                    validator: (value) => value == null || value.isEmpty
                        ? 'Date of birth is required'
                        : null,
                  ),
                  CustomTextFormField(
                    label: "Insurance Type",
                    hinttext: "Enter Type of Insurance",
                    controller: insuranceType,
                    prefixicon: Icons.security,
                    validator: (value) => value == null || value.isEmpty
                        ? 'Insurance type is required'
                        : null,
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  CustomElevatedButton(
                      text: "Submit", onPressed: signUpInsurance),
                  const SizedBox(
                    height: 20,
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