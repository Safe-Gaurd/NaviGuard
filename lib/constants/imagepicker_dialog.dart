import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:navigaurd/backend/providers/user_provider.dart';
import 'package:navigaurd/backend/providers/report.dart';

class ImagepickerDialog {
  void showImagePicker<T extends ChangeNotifier>(
      BuildContext context, T provider) {
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
                  leading: const Icon(Icons.photo_library),
                  title: const Text(
                    'Gallery',
                    style: TextStyle(
                        fontSize: 16,
                        color: Colors.black,
                        fontWeight: FontWeight.bold),
                  ),
                  onTap: () {
                    if (provider is UserProvider) {
                      provider.selectImage(ImageSource.gallery);
                    } else if (provider is ReportDataProvider) {
                      provider.selectImage(ImageSource.gallery);
                    }
                    Navigator.of(context).pop();
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.camera_alt),
                  title: const Text(
                    'Camera',
                    style: TextStyle(
                        fontSize: 16,
                        color: Colors.black,
                        fontWeight: FontWeight.bold),
                  ),
                  onTap: () {
                    if (provider is UserProvider) {
                      provider.selectImage(ImageSource.camera);
                    } else if (provider is ReportDataProvider) {
                      provider.selectImage(ImageSource.camera);
                    }
                    Navigator.of(context).pop();
                  },
                ),
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
