import 'package:erp_farm/providers/data_provider.dart';
import 'package:erp_farm/screens/customSplashScreen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';



void main() {
  // Asegúrate de inicializar Flutter antes de cargar cosas
  WidgetsFlutterBinding.ensureInitialized();

  runApp(
    MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => DataProvider())],
      // Cambiamos el home a nuestro nuevo Splash
      child: const MaterialApp(
        debugShowCheckedModeBanner: false,
        home: CustomSplashScreen(),
      ),
    ),
  );
}









