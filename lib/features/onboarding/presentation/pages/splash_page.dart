import 'package:flutter/material.dart';
import 'package:foxscope/core/utils/account_storage.dart';
import 'package:foxscope/core/utils/result.dart';
import 'package:foxscope/features/auth/data/models/user.dart';
import 'package:foxscope/features/auth/data/repositories/auth_repository.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  var splashTimeElapsed = false;
  Result<User>? authenticatedUser;

  @override
  void initState() {
    super.initState();

    Future.delayed(const Duration(seconds: 4), () {
      splashTimeElapsed = true;
      gotoNextPage();
    });

    authUserIfExist();
  }

  void authUserIfExist() async {
    final credentials =
        await AccountStorage(UserMapper()).getUserNameAndPassword();

    if (credentials == null) {
      authenticatedUser = Result(null);
      gotoNextPage();
    }
    //
    else {
      authenticatedUser = await AuthRepository().login(
        username: credentials.value1,
        password: credentials.value2,
      );

      gotoNextPage();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Image.asset(
          'assets/images/splash.png',
          width: 180,
          height: 180,
        ),
      ),
    );
  }

  void gotoNextPage() {
    if (!splashTimeElapsed) return;
    if (authenticatedUser == null) return;

    if (authenticatedUser?.result == null) {
      context.go('/onboarding');
    }
    //
    else {
      context.go('/home', extra: authenticatedUser?.result?.userId);
    }
  }
}
