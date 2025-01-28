import 'package:intl/intl.dart';

String formattedDate =DateFormat('EEEE d, MMMM yyyy').format(DateTime.now());
String formattedTime = DateFormat('hh:mm a').format(DateTime.now());