import 'package:flutter/material.dart';

import 'router.dart';
import 'theme.dart';

class VolunteerConnectApp extends StatelessWidget {
  const VolunteerConnectApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Volunteer Connect',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      themeMode: ThemeMode.light,
      routerConfig: AppRouter.router,
    );
  }
}