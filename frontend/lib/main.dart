import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:sign_bridge/features/auth/providers/auth_provider.dart';
import 'package:sign_bridge/features/translate/providers/translation_provider.dart';
import 'package:sign_bridge/features/settings/providers/settings_provider.dart';
import 'package:sign_bridge/features/splash/screens/splash_screen.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => TranslationProvider()),
        ChangeNotifierProvider(create: (_) => SettingsProvider()),
      ],
      child: Consumer<SettingsProvider>(
        builder: (context, settings, _) {
          return ScreenUtilInit(
            designSize: const Size(390, 844),
            minTextAdapt: true,
            splitScreenMode: true,
            builder: (context, child) {
              return MaterialApp(
                debugShowCheckedModeBanner: false,
                title: 'SignBridge',
                themeMode: settings.isDarkMode ? ThemeMode.dark : ThemeMode.light,
                theme: ThemeData(
                  colorScheme: ColorScheme.fromSeed(
                    seedColor: const Color(0xFF2B2D5D),
                    brightness: Brightness.light,
                  ),
                  scaffoldBackgroundColor: const Color(0xFFF5F7FF),
                  useMaterial3: true,
                  fontFamily: 'Roboto',
                ),
                darkTheme: ThemeData(
                  colorScheme: ColorScheme.fromSeed(
                    seedColor: const Color(0xFF4B6CF7),
                    brightness: Brightness.dark,
                  ),
                  scaffoldBackgroundColor: const Color(0xFF121424),
                  cardColor: const Color(0xFF1E2138),
                  useMaterial3: true,
                  fontFamily: 'Roboto',
                ),
                home: const SplashScreen(),
              );
            },
          );
        },
      ),
    );
  }
}