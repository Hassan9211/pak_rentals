import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'core/theme.dart';
import 'core/routes.dart';
import 'services/user_state.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: AppColors.bgElevated,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  // Load saved login state before app starts
  await UserState().loadFromStorage();

  runApp(const PakRentalsApp());
}

class PakRentalsApp extends StatelessWidget {
  const PakRentalsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pak Rentals',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark,
      // Always start from splash — it handles routing internally
      initialRoute: AppRoutes.splash,
      routes: AppRoutes.routes,
    );
  }
}
