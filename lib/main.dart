import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // The app uses DateFormat / NumberFormat with the 'id_ID' locale in
  // several places (admin dashboard, order list, checkout, etc.). intl
  // lazily loads locale data, but only after initializeDateFormatting()
  // has been called for that locale — otherwise it throws
  // LocaleDataException at runtime. Initialize it once at startup.
  await initializeDateFormatting('id_ID', null);
  Intl.defaultLocale = 'id_ID';
  runApp(const SummitApp());
}
