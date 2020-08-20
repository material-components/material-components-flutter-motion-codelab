import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:reply/router.dart';

import 'colors.dart';
import 'model/email_store.dart';
import 'model/router_provider.dart';

class ReplyApp extends StatefulWidget {
  const ReplyApp({Key? key}) : super(key: key);

  @override
  ReplyAppState createState() => ReplyAppState();
}

class ReplyAppState extends State<ReplyApp> {
  final RouterProvider _replyState = RouterProvider(const ReplyHomePath());
  final ReplyRouteInformationParser _routeInformationParser =
      ReplyRouteInformationParser();
  late final ReplyRouterDelegate _routerDelegate;

  @override
  void initState() {
    super.initState();
    _routerDelegate = ReplyRouterDelegate(replyState: _replyState);
  }

  @override
  void dispose() {
    _routerDelegate.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<EmailStore>.value(value: EmailStore()),
      ],
      child: Selector<EmailStore, ThemeMode>(
          selector: (context, emailStore) => emailStore.themeMode,
          builder: (context, themeMode, child) {
            return MaterialApp.router(
              routeInformationParser: _routeInformationParser,
              routerDelegate: _routerDelegate,
              themeMode: themeMode,
              title: 'Reply',
              darkTheme: _buildReplyDarkTheme(context),
              theme: _buildReplyLightTheme(context),
            );
          }),
    );
  }
}

ThemeData _buildReplyLightTheme(BuildContext context) {
  final base = ThemeData.light();
  return base.copyWith(
    bottomSheetTheme: BottomSheetThemeData(
      backgroundColor: ReplyColors.blue700,
      modalBackgroundColor: Colors.white.withOpacity(0.7),
    ),
    cardColor: ReplyColors.white50,
    chipTheme: _buildChipTheme(
      ReplyColors.blue700,
      ReplyColors.lightChipBackground,
      Brightness.light,
    ),
    colorScheme: const ColorScheme.light(
      primary: ReplyColors.blue700,
      secondary: ReplyColors.orange500,
      surface: ReplyColors.white50,
      error: ReplyColors.red400,
      onPrimary: ReplyColors.white50,
      onSecondary: ReplyColors.black900,
      onBackground: ReplyColors.black900,
      onSurface: ReplyColors.black900,
      onError: ReplyColors.black900,
      background: ReplyColors.blue50,
    ),
    textTheme: _buildReplyLightTextTheme(base.textTheme),
    scaffoldBackgroundColor: ReplyColors.blue50,
    bottomAppBarTheme: const BottomAppBarTheme(
      color: ReplyColors.blue700,
    ),
  );
}

ThemeData _buildReplyDarkTheme(BuildContext context) {
  final base = ThemeData.dark();
  return base.copyWith(
    bottomSheetTheme: BottomSheetThemeData(
      backgroundColor: ReplyColors.darkDrawerBackground,
      modalBackgroundColor: Colors.black.withOpacity(0.7),
    ),
    cardColor: ReplyColors.darkCardBackground,
    chipTheme: _buildChipTheme(
      ReplyColors.blue200,
      ReplyColors.darkChipBackground,
      Brightness.dark,
    ),
    colorScheme: const ColorScheme.dark(
      primary: ReplyColors.blue200,
      secondary: ReplyColors.orange300,
      surface: ReplyColors.black800,
      error: ReplyColors.red200,
      onPrimary: ReplyColors.black900,
      onSecondary: ReplyColors.black900,
      onBackground: ReplyColors.white50,
      onSurface: ReplyColors.white50,
      onError: ReplyColors.black900,
      background: ReplyColors.black900,
    ),
    textTheme: _buildReplyDarkTextTheme(base.textTheme),
    scaffoldBackgroundColor: ReplyColors.black900,
    bottomAppBarTheme: const BottomAppBarTheme(
      color: ReplyColors.darkBottomAppBarBackground,
    ),
  );
}

ChipThemeData _buildChipTheme(
  Color primaryColor,
  Color chipBackground,
  Brightness brightness,
) {
  return ChipThemeData(
    backgroundColor: primaryColor.withOpacity(0.12),
    disabledColor: primaryColor.withOpacity(0.87),
    selectedColor: primaryColor.withOpacity(0.05),
    secondarySelectedColor: chipBackground,
    padding: const EdgeInsets.all(4),
    shape: const StadiumBorder(),
    labelStyle: GoogleFonts.workSansTextTheme().bodyMedium!.copyWith(
          color: brightness == Brightness.dark
              ? ReplyColors.white50
              : ReplyColors.black900,
        ),
    secondaryLabelStyle: GoogleFonts.workSansTextTheme().bodyMedium!,
    brightness: brightness,
  );
}

TextTheme _buildReplyLightTextTheme(TextTheme base) {
  return base.copyWith(
    headlineMedium: GoogleFonts.workSans(
      fontWeight: FontWeight.w600,
      fontSize: 34,
      letterSpacing: 0.4,
      height: 0.9,
      color: ReplyColors.black900,
    ),
    headlineSmall: GoogleFonts.workSans(
      fontWeight: FontWeight.bold,
      fontSize: 24,
      letterSpacing: 0.27,
      color: ReplyColors.black900,
    ),
    titleLarge: GoogleFonts.workSans(
      fontWeight: FontWeight.w600,
      fontSize: 20,
      letterSpacing: 0.18,
      color: ReplyColors.black900,
    ),
    titleSmall: GoogleFonts.workSans(
      fontWeight: FontWeight.w600,
      fontSize: 14,
      letterSpacing: -0.04,
      color: ReplyColors.black900,
    ),
    bodyLarge: GoogleFonts.workSans(
      fontWeight: FontWeight.normal,
      fontSize: 18,
      letterSpacing: 0.2,
      color: ReplyColors.black900,
    ),
    bodyMedium: GoogleFonts.workSans(
      fontWeight: FontWeight.normal,
      fontSize: 14,
      letterSpacing: -0.05,
      color: ReplyColors.black900,
    ),
    bodySmall: GoogleFonts.workSans(
      fontWeight: FontWeight.normal,
      fontSize: 12,
      letterSpacing: 0.2,
      color: ReplyColors.black900,
    ),
  );
}

TextTheme _buildReplyDarkTextTheme(TextTheme base) {
  return base.copyWith(
    headlineMedium: GoogleFonts.workSans(
      fontWeight: FontWeight.w600,
      fontSize: 34,
      letterSpacing: 0.4,
      height: 0.9,
      color: ReplyColors.white50,
    ),
    headlineSmall: GoogleFonts.workSans(
      fontWeight: FontWeight.bold,
      fontSize: 24,
      letterSpacing: 0.27,
      color: ReplyColors.white50,
    ),
    titleLarge: GoogleFonts.workSans(
      fontWeight: FontWeight.w600,
      fontSize: 20,
      letterSpacing: 0.18,
      color: ReplyColors.white50,
    ),
    titleSmall: GoogleFonts.workSans(
      fontWeight: FontWeight.w600,
      fontSize: 14,
      letterSpacing: -0.04,
      color: ReplyColors.white50,
    ),
    bodyLarge: GoogleFonts.workSans(
      fontWeight: FontWeight.normal,
      fontSize: 18,
      letterSpacing: 0.2,
      color: ReplyColors.white50,
    ),
    bodyMedium: GoogleFonts.workSans(
      fontWeight: FontWeight.normal,
      fontSize: 14,
      letterSpacing: -0.05,
      color: ReplyColors.white50,
    ),
    bodySmall: GoogleFonts.workSans(
      fontWeight: FontWeight.normal,
      fontSize: 12,
      letterSpacing: 0.2,
      color: ReplyColors.white50,
    ),
  );
}
