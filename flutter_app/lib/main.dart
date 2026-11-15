import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/constants/app_colors.dart';
import 'core/utils/notification_helper.dart';
import 'presentation/providers/flood_provider.dart';
import 'presentation/screens/main_navigation_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inisialisasi channel notifikasi lokal
  try {
    await NotificationHelper.initialize();
  } catch (_) {}

  runApp(const FloodWarningApp());
}

class FloodWarningApp extends StatelessWidget {
  const FloodWarningApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => FloodProvider()),
      ],
      child: MaterialApp(
        title: 'Peringatan Banjir Desa Rahong',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          brightness: Brightness.dark,
          scaffoldBackgroundColor: AppColors.backgroundBase,
          colorScheme: const ColorScheme.dark(
            primary: AppColors.royalPurpleRadiant,
            onPrimary: Colors.white,
            secondary: AppColors.paleGold,
            onSecondary: AppColors.royalPurpleDeep,
            surface: AppColors.surfaceCard,
            onSurface: AppColors.textPrimary,
            background: AppColors.backgroundBase,
            onBackground: AppColors.textPrimary,
            outline: AppColors.borderSubtle,
          ),
          fontFamily: 'Roboto',
          appBarTheme: const AppBarTheme(
            backgroundColor: AppColors.royalPurpleDeep,
            elevation: 0,
            scrolledUnderElevation: 0,
            iconTheme: IconThemeData(color: AppColors.paleGold),
            titleTextStyle: TextStyle(
              color: AppColors.textHeader,
              fontSize: 16,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.3,
            ),
          ),
          cardTheme: CardThemeData(
            color: AppColors.surfaceCard,
            elevation: 3,
            shadowColor: Colors.black54,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: const BorderSide(color: AppColors.borderSubtle, width: 1),
            ),
          ),
          navigationBarTheme: NavigationBarThemeData(
            backgroundColor: AppColors.royalPurpleDeep,
            indicatorColor: AppColors.royalPurplePrimary.withOpacity(0.5),
            labelTextStyle: MaterialStateProperty.resolveWith((states) {
              if (states.contains(MaterialState.selected)) {
                return const TextStyle(
                  color: AppColors.paleGold,
                  fontWeight: FontWeight.bold,
                  fontSize: 11.5,
                );
              }
              return const TextStyle(
                color: AppColors.textMuted,
                fontWeight: FontWeight.normal,
                fontSize: 11.5,
              );
            }),
            iconTheme: MaterialStateProperty.resolveWith((states) {
              if (states.contains(MaterialState.selected)) {
                return const IconThemeData(color: AppColors.paleGold, size: 24);
              }
              return const IconThemeData(color: AppColors.textMuted, size: 22);
            }),
          ),
        ),
        // ── 16:9 Scale & Responsive Layout Optimizer ──
        builder: (context, child) {
          final mediaQuery = MediaQuery.of(context);
          // Batasi textScaleFactor agar tidak merusak layout pada layar 16:9
          final clampedMediaQuery = mediaQuery.copyWith(
            textScaler: mediaQuery.textScaler.clamp(
              minScaleFactor: 0.85,
              maxScaleFactor: 1.15,
            ),
          );

          return MediaQuery(
            data: clampedMediaQuery,
            child: Container(
              color: AppColors.midnightNavy, // Latar kontras saat dibuka di layar lebar
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(
                    maxWidth: 480, // Standar lebar proporsional 16:9 smartphone
                  ),
                  child: child!,
                ),
              ),
            ),
          );
        },
        home: const MainNavigationScreen(),
      ),
    );
  }
}
