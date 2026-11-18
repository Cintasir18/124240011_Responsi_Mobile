
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'screens/login_screen.dart';
import 'screens/main_screen.dart';
import 'services/session_service.dart';
import 'services/notification_services.dart';
import 'theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();

  await Hive.openBox('cart');

  await NotificationService.initialize();

  final String? savedUsername =
      await SessionService.getUsername();

  runApp(
    TokoOnlineApp(
      initialUsername: savedUsername,
    ),
  );
}

class TokoOnlineApp extends StatelessWidget {
  final String? initialUsername;

  const TokoOnlineApp({
    super.key,
    required this.initialUsername,
  });

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Shopedia',

      theme: AppTheme.light,

      home: initialUsername == null ||
              initialUsername!.isEmpty
          ? const LoginScreen()
          : MainScreen(
              username: initialUsername!,
            ),
    );
  }
}
