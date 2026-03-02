import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'themes/app_theme.dart';
import 'pages/login_page.dart';
import 'pages/register_page.dart';
import 'pages/home_page.dart';
import 'pages/account_page.dart';
import 'pages/bin_details_page.dart';
import 'pages/report_page.dart';
import 'pages/add_bin_page.dart';
import 'models/bin.dart';
import 'services/supabase_service.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

Future<void> main() async  {

  WidgetsFlutterBinding.ensureInitialized();

  try {
    await dotenv.load(fileName: ".env");
  } catch (e, stackTrace) {
    debugPrint('Error loading .env file: $e\n$stackTrace');
    rethrow;
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Binner',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      initialRoute: '/home',
      routes: {
        '/login': (context) => const LoginPage(),
        '/register': (context) => const RegisterPage(),
        '/home': (context) => const HomePage(),
        '/account': (context) => const AccountPage(),
      },
      onGenerateRoute: (settings) {
        // Handle routes with arguments
        if (settings.name == '/bin_details') {
          final bin = settings.arguments as Bin;
          return MaterialPageRoute(
            builder: (context) => BinDetailsPage(bin: bin),
          );
        }
        if (settings.name == '/report') {
          return MaterialPageRoute(builder: (context) => const ReportPage());
        }
        if (settings.name == '/add_bin') {
          return MaterialPageRoute(builder: (context) => const AddBinPage());
        }
        return null;
      },
    );
  }
}
