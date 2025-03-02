import 'package:delightful_toast/toast/utils/enums.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:navigaurd/constants/imagepicker_dialog.dart';
import 'package:navigaurd/enum/enums.dart';
import 'package:provider/provider.dart';
import 'package:navigaurd/backend/providers/user_provider.dart';
import 'package:navigaurd/constants/colors.dart';
import 'package:navigaurd/constants/toast.dart';
import 'package:navigaurd/screens/auth/widgets/customtextformfield.dart';
import 'package:navigaurd/screens/widgets/buttons/elevated.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  Officer? selectedOfficer;

  @override
  Widget build(BuildContext context) {
    return Consumer<UserProvider>(
      builder: (context, provider, child) {
        return provider.isLoading
        ? const Center(
          child: CircularProgressIndicator()
          )
        : Scaffold(
          appBar: AppBar(
            backgroundColor: blueColor,
            title: const Text(
              'Edit Profile',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
              ),
            ),
          ),
          body: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  const SizedBox(height: 10),
                  Stack(
                    children: [
                      provider.isLoading
                      ? const CircularProgressIndicator(color: blueColor,)
                      : provider.photoURL==null
                        ? CircleAvatar(
                            radius: 60,
                            backgroundColor: blueColor,
                            child: Text(
                              provider.user.name[0],
                              style: const TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
                            ),
                          )
                        : CircleAvatar(
                            radius: 60,
                            backgroundImage: NetworkImage(provider.photoURL!),
                          ),

                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: CircleAvatar(
                          backgroundColor: Colors.white,
                          child: IconButton(
                            onPressed: () {
                              ImagepickerDialog().showImagePicker(context, provider);
                            },
                            icon: const Icon(Icons.edit),
                          ),
                        ),
                      )
                    ],
                  ),
                  const SizedBox(height: 20),
                  buildProfileForm(context, provider),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget buildProfileForm(
      BuildContext context, UserProvider provider) {
    final nameController = TextEditingController(text: provider.user.name);
    final emailController = TextEditingController(text: provider.user.email);
    final phoneNumberController =TextEditingController(text: provider.user.phonenumber);
    final locationController=TextEditingController(text: provider.user.location);

    return Container(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          CustomTextFormField(
            controller: nameController,
            label: "Name",
            hinttext: provider.user.name,
            prefixicon: Icons.person,
          ),
          const SizedBox(height: 20),
          CustomTextFormField(
            controller: emailController,
            label: "E-mail",
            hinttext: provider.user.email,
            prefixicon: Icons.email,
          ),
          const SizedBox(height: 20),
          CustomTextFormField(
            controller: phoneNumberController,
            label: "Phone Number",
            hinttext: provider.user.phonenumber,
            prefixicon: Icons.phone,
            keyboard: TextInputType.number,
          ),
          const SizedBox(height: 20),
          CustomTextFormField(
            controller: locationController,
            label: "Location",
            hinttext: provider.user.location!,
            prefixicon: Icons.location_on,
          ),

          const SizedBox(height: 20,),

          if (provider.user.officerTitle != "User")
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
                                padding: const EdgeInsets.symmetric(horizontal: 12.0),
                                child: Icon(Icons.security),
                              ),
                              Expanded(
                                child: DropdownButton<Officer>(
                                  value: selectedOfficer,
                                  isExpanded: true,
                                  hint: Text(
                                    provider.user.officerTitle,
                                    style: TextStyle(
                                      color: Colors.black54,
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
          
          const SizedBox(height: 20),
          SizedBox(
            width: 180,
            child:provider.isUpdate
                  ? const Center(
                      child: CircularProgressIndicator(color: blueColor,),
                    )
                  : CustomElevatedButton(
                    foregroundColor: Colors.white,
                    backgroundColor: Colors.blue,
                    text: "Update",
                    onPressed: () async {
                      String selectedOfficerTitle=getOfficerTitle(selectedOfficer!);

                      String res = await provider.updateUserDetails(
                        name: nameController.text, 
                        email: emailController.text, 
                        phonenumber: phoneNumberController.text, 
                        location: locationController.text,
                        officerTtitle: selectedOfficerTitle,
                      );
                          
                      if (res == 'update') {
                        toastMessage(context: context, message:'Profile Updated Successfully', position: DelightSnackbarPosition.top);
                      } else {
                        toastMessage(context: context, message:'Retry again, profile not updated', position: DelightSnackbarPosition.top);
                      }
                    },
                  ),
                ),
        ]
      ),
    );
  }
}
