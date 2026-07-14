import 'package:flutter/material.dart';
import '../app/routes.dart';
import '../app/theme/colors.dart';

void main() {
  runApp(const LabelOcrApp());
}

class LabelOcrApp extends StatelessWidget {
  const LabelOcrApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Label OCR Mapper',
      debugShowCheckedModeBanner: false,
      theme: AppColors.lightTheme,
      darkTheme: AppColors.darkTheme,
      themeMode: ThemeMode.light,
      routerConfig: appRouter,
    );
  }
}
