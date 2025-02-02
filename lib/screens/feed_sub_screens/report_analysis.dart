import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:navigaurd/backend/providers/report.dart';
import 'package:navigaurd/constants/colors.dart';
import 'package:navigaurd/screens/widgets/appbar.dart';

class ReportAnalysisScreen extends StatefulWidget {
  const ReportAnalysisScreen({super.key});

  @override
  State<ReportAnalysisScreen> createState() => _ReportAnalysisScreenState();
}

class _ReportAnalysisScreenState extends State<ReportAnalysisScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      Provider.of<ReportDataProvider>(context, listen: false).fetchReport();
    });
  }

  @override
  Widget build(BuildContext context) {
    final reportProvider = Provider.of<ReportDataProvider>(context);
    final reports = reportProvider.report;

    return Scaffold(
      appBar: const CustomAppbar(label: "Reports"),
      body: reportProvider.isLoading
          ? const Center(child: CircularProgressIndicator(color: blueColor))
          : reports == null
              ? const Center(child: Text("No accident reports available"))
              : ListView.builder(
                  padding: const EdgeInsets.all(10),
                  itemCount: reports.length,
                  itemBuilder: (context, index) {
                    final report = reports[index];

                    return InkWell(
                      child: Card(
                        margin: const EdgeInsets.only(bottom: 10),
                        elevation: 4,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                      
                              if (report.photosList != null && report.photosList!.isNotEmpty)
                                SizedBox(
                                  height: 150,
                                  child: ClipRRect(
                                          borderRadius: BorderRadius.circular(8),
                                          child: Image.network(
                                            report.photosList![0]!,
                                            width: double.infinity,
                                            height: 150,
                                            fit: BoxFit.cover,
                                            errorBuilder: (context, error, stackTrace) =>
                                                Image.asset("assets/maps/something_went_wrong.png",
                                                  width: double.infinity,
                                                  height: 150,
                                                )
                                          ),
                                        ),
                                ),
                      
                              Text(
                                report.town ?? "Unknown Town",
                                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 5),
                              Text(
                                report.description ?? "No description available",
                                style: TextStyle(fontSize: 14, color: Colors.grey[800]),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                      
                              const SizedBox(height: 8),
                              Text(
                                "🕒 Reported on: ${report.time}",
                                style: TextStyle(fontSize: 12, color: Colors.blueGrey[800]),
                              ),
                      
                              const SizedBox(height: 8),
                              Text(
                                "📍 Location: (${report.coordinates?.latitude ?? 0.0}, ${report.coordinates?.longitude ?? 0.0})",
                                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                      ),
                      onTap: () {
                        
                      },
                    );
                  },
                ),
    );
  }
}
