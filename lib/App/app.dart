import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sadid/App/routes.dart';
import 'Binding.dart';
import 'CustomTheme.dart';
import 'Translation.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(430, 932),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (_, __) => GetMaterialApp(
        debugShowCheckedModeBanner: false,
        translations: AppTranslation(),
        locale: Locale('en', 'US'),
        fallbackLocale: Locale('en', 'US'),
        theme: customTheme,
        initialBinding: InitialBinding(),
        getPages: routes.pages,
        initialRoute: routes.navbar_screen,
      ),
    );
  }
}