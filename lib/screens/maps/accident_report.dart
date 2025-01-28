import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:delightful_toast/toast/utils/enums.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:navigaurd/backend/models/report.dart';
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
  String res="";

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

    // Set loading state
    setState(() {
      isLoading = true;
    });

    try {
      // Access the provider
      final reportProvider = Provider.of<ReportDataProvider>(context, listen: false);

      // Create a new report data object
      final newReport = ReportDataModel(
        landMark: landMarkController.text,
        town: townController.text,
        description: descriptionController.text,
        coordinates: widget.coordinates,
        time: Timestamp.now().toString(),
      );

      String id = '${widget.coordinates.latitude},${widget.coordinates.longitude}';
      // Save the report using the provider
      res=await reportProvider.addReportDescription(
        id: id,
        reportEach: newReport,
      );

      if(res=="done")
      {
        toastMessage(
          context: context,
          message: "Report submitted successfully",
          leadingIcon: const Icon(Icons.check),
          position: DelightSnackbarPosition.top,
          toastColor: Colors.green[500],
          borderColor: Colors.green,
        );
      }
      Navigator.of(context).pop(); // Close the screen
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
    return Scaffold(
      appBar: const CustomAppbar(label: "Report An Accident"),
      body: SingleChildScrollView(
        child: Form(
          key: formKey,
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              children: [
                Image.asset(
                  "assets/maps/accident.jpg",
                  width: 300,
                  height: 200,
                ),
                CustomTextFormField(
                  label: "Landmark",
                  hinttext: "Enter the nearest landmark",
                  controller: landMarkController,
                  prefixicon: Icons.holiday_village,
                  validator: (value) => value!.isEmpty ? "This field is required" : null,
                ),
                CustomTextFormField(
                  label: "Town/City",
                  hinttext: "Enter the name of the city/town",
                  controller: townController,
                  prefixicon: Icons.location_city,
                  validator: (value) => value!.isEmpty ? "This field is required" : null,
                ),
                CustomTextFormField(
                  label: "Description",
                  hinttext: "Enter the description of the accident",
                  controller: descriptionController,
                  prefixicon: Icons.description,
                  validator: (value) => value!.isEmpty ? "This field is required" : null,
                ),
                Text(
                  "Location: (${widget.coordinates.latitude}, ${widget.coordinates.longitude})",
                  style: const TextStyle(fontSize: 14, color: Colors.grey),
                ),
                const SizedBox(height: 10),
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
