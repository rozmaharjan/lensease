import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:khalti_flutter/khalti_flutter.dart';
import 'package:lenseease_main/config/router/app_router.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return KhaltiScope(
      publicKey: "test_public_key_242aa7bbaf1742539c8a51ee00aba0e2",
      enabledDebugging: true,
      builder: (context, navKey) {
        return PopScope(
          canPop: false,
          child: MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'Lensease',
            theme: ThemeData(
              textTheme: GoogleFonts.libreBaskervilleTextTheme(
                Theme.of(context).textTheme,
              ).copyWith(
                bodyLarge: GoogleFonts.amethysta(),
                bodyMedium: GoogleFonts.amethysta(),
              ),
            ),
            localizationsDelegates: const [
              KhaltiLocalizations.delegate,
            ],
            initialRoute: AppRoute.splashRoute,
            routes: AppRoute.getApplicationRoute(),
            navigatorKey: navKey,
          ),
        );
      },
    );
  }
}
