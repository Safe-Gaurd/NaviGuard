import 'package:delightful_toast/toast/utils/enums.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:navigaurd/backend/providers/user_provider.dart';
import 'package:navigaurd/constants/colors.dart';
import 'package:navigaurd/constants/toast.dart';
import 'package:navigaurd/screens/auth/widgets/customtextformfield.dart';
import 'package:navigaurd/screens/widgets/buttons/elevated.dart';

class EditProfileScreen extends StatelessWidget {
  const EditProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<UserProvider>(
      builder: (context, provider, child) {
        return provider.isLoading
        ? const Center(
          child: CircularProgressIndicator()
          )
        : Scaffold(
          resizeToAvoidBottomInset: true,
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
                      provider.profileImage != null
                          ? CircleAvatar(
                              radius: 60,
                              backgroundImage:
                                  MemoryImage(provider.profileImage!))
                          : CircleAvatar(
                              radius: 60,
                              backgroundColor: blueColor,
                              child: Text(
                                provider.user.name[0],
                                style: const TextStyle(
                                    fontSize: 40, fontWeight: FontWeight.bold),
                              ),
                  ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: CircleAvatar(
                          backgroundColor: Colors.white,
                          child: IconButton(
                            onPressed: () {
                              showImagePicker(context, provider);
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
          ),
          const SizedBox(height: 20),
          CustomTextFormField(
            controller: locationController,
            label: "Location",
            hinttext: provider.user.location!,
            prefixicon: Icons.location_on,
          ),
          
          const SizedBox(height: 20),
          SizedBox(
            width: 180,
            child:provider.isUpdate
                  ? const Center(
                      child: CupertinoActivityIndicator(),
                    )
                  : CustomElevatedButton(
                    foregroundColor: Colors.white,
                    backgroundColor: Colors.blue,
                    text: "Update",
                    onPressed: () async {
                      String res = await provider.updateUserDetails(
                        name: nameController.text, 
                        email: emailController.text, 
                        phonenumber: phoneNumberController.text, 
                        photoURL: provider.photoURL ?? provider.user.photoURL!, 
                        location: locationController.text
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


  void showImagePicker(BuildContext context, UserProvider provider) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24.0),
          ),
          child: Container(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Select Image',
                  style: TextStyle(
                      color: Colors.blue,
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16.0),
                ListTile(
                  leading: const Icon(
                    Icons.photo_library,
                    // color: Colors.blue,
                  ),
                  title: const Text(
                    'Gallery',
                    style: TextStyle(
                        fontSize: 16,
                        color: Colors.black,
                        fontWeight: FontWeight.bold),
                  ),
                  onTap: () {
                    provider.selectImage(ImageSource.gallery);
                    Navigator.of(context).pop();
                  },
                ),
                ListTile(
                  leading: const Icon(
                    Icons.camera_alt,
                    // color: Colors.blue,
                  ),
                  title: const Text(
                    'Camera',
                    style: TextStyle(
                        fontSize: 16,
                        color: Colors.black,
                        fontWeight: FontWeight.bold),
                  ),
                  onTap: () {
                    provider.selectImage(ImageSource.camera);
                    Navigator.of(context).pop();
                  },
                ),
                // const SizedBox(height: 16.0),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancel'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
