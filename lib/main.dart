import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'utils/constants.dart';
import 'providers/app_state.dart';
import 'screens/main_scaffold.dart';

void main() {
  runApp(const VinceApp());
}

class VinceApp extends StatelessWidget {
  const VinceApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AppState()),
      ],
      child: Consumer<AppState>(
        builder: (context, appState, _) {
          return MaterialApp(
            title: "Vince's App",
            debugShowCheckedModeBanner: false,
            // Mode Logic: 0=Light, 1=System, 2=Dark
            themeMode: appState.themeMode == 1 
                ? ThemeMode.system 
                : (appState.themeMode == 2 ? ThemeMode.dark : ThemeMode.light),
            theme: _buildLightTheme(),
            darkTheme: _buildDarkTheme(),
            home: const MainScaffold(),
          );
        },
      ),
    );
  }

  ThemeData _buildLightTheme() {
    final base = ThemeData.light();
    return base.copyWith(
      primaryColor: kPrimaryColor,
      scaffoldBackgroundColor: kBackgroundColor,
      colorScheme: const ColorScheme.light(
        primary: kPrimaryColor,
        secondary: kUnpaidContainerColor,
        surface: kSurfaceColor,
        error: kErrorColor,
        onSurface: kTextPrimary,
      ),
      textTheme: GoogleFonts.poppinsTextTheme(base.textTheme),
      // FIXED: Used CardThemeData instead of CardTheme
      cardTheme: CardThemeData(
        color: kSurfaceColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(kBorderRadius)),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: kPrimaryColor,
        foregroundColor: kTextOnPrimary,
        elevation: 0,
      ),
    );
  }

  ThemeData _buildDarkTheme() {
    final base = ThemeData.dark();
    return base.copyWith(
      primaryColor: kPrimaryColorDark,
      scaffoldBackgroundColor: kBackgroundColorDark,
      colorScheme: const ColorScheme.dark(
        primary: kPrimaryColorDark,
        secondary: kUnpaidContainerColorDark,
        surface: kSurfaceColorDark,
        error: kErrorColor,
        onSurface: kTextPrimaryDark,
      ),
      textTheme: GoogleFonts.poppinsTextTheme(base.textTheme).apply(
        bodyColor: kTextPrimaryDark,
        displayColor: kTextPrimaryDark,
      ),
      // FIXED: Used CardThemeData instead of CardTheme
      cardTheme: CardThemeData(
        color: kSurfaceColorDark,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(kBorderRadius)),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: kSurfaceColorDark,
        foregroundColor: kTextPrimaryDark,
        elevation: 0,
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: kSurfaceColorDark,
      ),
    );
  }
}