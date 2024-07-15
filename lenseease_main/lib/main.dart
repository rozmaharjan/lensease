import 'package:flutter/material.dart';
import 'package:lenseease_main/core/app.dart';
import 'package:lenseease_main/features/home/widgets/bottom_navbar.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => BottomNavBarProvider()),
      ],
      child: const App(),
    ),
  );
}
