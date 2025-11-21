import 'package:flutter/material.dart';
import 'core/constants/app_router.dart';
import 'core/theme/app_colors.dart';
import 'core/di/service_locator.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await setupLocator(); // register dependencies
  runApp(const FoxScopeApp());
}

class FoxScopeApp extends StatelessWidget {
  const FoxScopeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'FoxScope',
      theme: ThemeData(
        primaryColor: AppColors.primary,
        scaffoldBackgroundColor: Colors.white,
        fontFamily: 'Roboto',
      ),
      routerConfig: AppRouter.router,
    );
  }
}
