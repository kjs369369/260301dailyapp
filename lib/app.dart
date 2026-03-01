import 'package:flutter/material.dart';

import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';

class DailyApp extends StatelessWidget {
  const DailyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: '매일 습관',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark,
      routerConfig: goRouter,
      locale: const Locale('ko', 'KR'),
    );
  }
}
