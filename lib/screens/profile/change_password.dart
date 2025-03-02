import 'package:flutter/material.dart';
import 'package:navigaurd/screens/auth/widgets/customtextformfield.dart';
import 'package:navigaurd/screens/widgets/buttons/elevated.dart';
import 'package:navigaurd/screens/widgets/nav_bars/appbar.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _obscureCurrentPassword = true;
  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;

  final TextEditingController _currentPasswordController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppbar(label: "Change Password"),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 20),
                // Current Password
                CustomTextFormField(
                  label: 'Current Password',
                  hinttext: 'Enter your current password',
                  controller: _currentPasswordController,
                  isobsure: _obscureCurrentPassword,
                  keyboard: TextInputType.visiblePassword,
                  prefixicon: Icons.lock_outline,
                  suffixicon: IconButton(
                    icon: Icon(
                      _obscureCurrentPassword
                          ? Icons.visibility_off
                          : Icons.visibility,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscureCurrentPassword = !_obscureCurrentPassword;
                      });
                    },
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your current password';
                    }
                    return null;
                  },
                ),
                // New Password
                CustomTextFormField(
                  label: 'New Password',
                  hinttext: 'Enter your new password',
                  controller: _newPasswordController,
                  isobsure: _obscureNewPassword,
                  keyboard: TextInputType.visiblePassword,
                  prefixicon: Icons.lock_outline,
                  suffixicon: IconButton(
                    icon: Icon(
                      _obscureNewPassword
                          ? Icons.visibility_off
                          : Icons.visibility,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscureNewPassword = !_obscureNewPassword;
                      });
                    },
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a new password';
                    }
                    if (value.length < 8) {
                      return 'Password must be at least 8 characters long';
                    }
                    return null;
                  },
                ),
                // Confirm New Password
                CustomTextFormField(
                  label: 'Confirm New Password',
                  hinttext: 'Confirm your new password',
                  controller: _confirmPasswordController,
                  isobsure: _obscureConfirmPassword,
                  keyboard: TextInputType.visiblePassword,
                  prefixicon: Icons.lock_outline,
                  suffixicon: IconButton(
                    icon: Icon(
                      _obscureConfirmPassword
                          ? Icons.visibility_off
                          : Icons.visibility,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscureConfirmPassword = !_obscureConfirmPassword;
                      });
                    },
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please confirm your new password';
                    }
                    if (value != _newPasswordController.text) {
                      return 'Passwords do not match';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 30),
                // Submit Button
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 7.0),
                  child: CustomElevatedButton(
                    text: "Change Password",
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        // Password change logic would go here
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Password changed successfully'),
                            backgroundColor: Colors.green,
                          ),
                        );
                      }
                    },
                    
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}