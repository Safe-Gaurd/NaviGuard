import 'package:delightful_toast/toast/utils/enums.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:navigaurd/constants/imagepicker_dialog.dart';
import 'package:provider/provider.dart';
import 'package:navigaurd/backend/providers/report.dart';
import 'package:navigaurd/constants/colors.dart';
import 'package:navigaurd/constants/toast.dart';
import 'package:navigaurd/screens/auth/widgets/customtextformfield.dart';
import 'package:navigaurd/screens/widgets/appbar.dart';
import 'package:navigaurd/screens/widgets/buttons/elevated.dart';

class AccidentReportScreen extends StatefulWidget {
  final LatLng coordinates;
  const AccidentReportScreen({super.key, required this.coordinates});

  @override
  State<AccidentReportScreen> createState() => _AccidentReportScreenState();
}

class _AccidentReportScreenState extends State<AccidentReportScreen> {
  final TextEditingController landMarkController = TextEditingController();
  final TextEditingController townController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  bool isLoading = false;
  String res = "";
  bool isImageLoading = false;

  @override
  void dispose() {
    landMarkController.dispose();
    townController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  Future<void> submitReport() async {
    if (!formKey.currentState!.validate()) {
      toastMessage(
        context: context,
        message: "Please fill all fields",
        leadingIcon: const Icon(Icons.warning),
        toastColor: Colors.yellow[300],
        borderColor: Colors.orange,
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      ReportDataProvider reportProvider = Provider.of(context, listen: false);
      res = await reportProvider.addReport(
        landMark: landMarkController.text,
        town: townController.text,
        coordinates: widget.coordinates,
        description: descriptionController.text,
      );

      if (res == "success") {
        toastMessage(
          context: context,
          message: "Report submitted successfully",
          position: DelightSnackbarPosition.top,
          leadingIcon: const Icon(Icons.check),
          toastColor: Colors.green[500],
          borderColor: Colors.green,
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      toastMessage(
        context: context,
        message: "Something went wrong: ${e.toString()}",
        leadingIcon: const Icon(Icons.error),
        toastColor: Colors.red[300],
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
    ReportDataProvider reportProvider =
        Provider.of<ReportDataProvider>(context);

    return Scaffold(
      appBar: const CustomAppbar(label: "Report An Accident"),
      body: SingleChildScrollView(
        child: Form(
          key: formKey,
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              children: [
                const SizedBox(height: 30),
                Container(
                  width: 350,
                  height: 180,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(30.0),
                    border: Border.all(width: 1),
                    image: const DecorationImage(
                      image: AssetImage("assets/maps/accident.jpg"),
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Align(
                  alignment: AlignmentDirectional.centerEnd,
                  child: IconButton(
                    onPressed: () async {
                      setState(() {
                        isImageLoading = true;
                      });
                      ImagepickerDialog()
                          .showImagePicker(context, reportProvider);
                      setState(() {
                        if (reportProvider.photosList.isNotEmpty) {
                          isImageLoading = false;
                        }
                      });
                    },
                    icon: const Icon(Icons.camera_alt),
                  ),
                ),
                if (isImageLoading && reportProvider.photosList.isEmpty)
                  const Center(
                    child: CircularProgressIndicator(color: Colors.blue),
                  ),
                if (reportProvider.photosList.isNotEmpty)
                  Container(
                    height: 50,
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: reportProvider.photosList.map((photoUrl) {
                        return Container(
                          margin: const EdgeInsets.symmetric(horizontal: 5),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            children: [
                              Text(
                                photoUrl.split('/').last,
                                style: const TextStyle(
                                    fontSize: 14, fontWeight: FontWeight.w500),
                              ),
                              const SizedBox(width: 5),
                              GestureDetector(
                                onTap: () {
                                  setState(() {
                                    reportProvider.photosList.remove(photoUrl);
                                    isImageLoading = false;
                                  });
                                },
                                child: const Icon(Icons.close,
                                    size: 18, color: Colors.red),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                const SizedBox(height: 20),
                CustomTextFormField(
                  label: "Landmark",
                  hinttext: "Enter the nearest landmark",
                  controller: landMarkController,
                  prefixicon: Icons.holiday_village,
                  validator: (value) =>
                      value!.isEmpty ? "This field is required" : null,
                ),
                CustomTextFormField(
                  label: "Town/City",
                  hinttext: "Enter the name of the city/town",
                  controller: townController,
                  prefixicon: Icons.location_city,
                  validator: (value) =>
                      value!.isEmpty ? "This field is required" : null,
                ),
                CustomTextFormField(
                  label: "Description",
                  hinttext: "Enter the description of the accident",
                  controller: descriptionController,
                  prefixicon: Icons.description,
                  validator: (value) =>
                      value!.isEmpty ? "This field is required" : null,
                ),
                const SizedBox(height: 15),
                Text(
                  "Location: (${widget.coordinates.latitude}, ${widget.coordinates.longitude})",
                  style: const TextStyle(
                      fontSize: 14,
                      color: Colors.black,
                      fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                isLoading
                    ? const CircularProgressIndicator(color: blueColor)
                    : CustomElevatedButton(
                        text: "Submit Report",
                        onPressed: submitReport,
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
