import 'package:erp_farm/screens/salasScreen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';


class CustomSplashScreen extends StatefulWidget {
  const CustomSplashScreen({super.key});
  @override
  State<CustomSplashScreen> createState() => _CustomSplashScreenState();
}

class _CustomSplashScreenState extends State<CustomSplashScreen> {
  @override
  void initState() {
    super.initState();
    _startApp();
  }

  void _startApp() async {
    // 1. Espera a que el DataProvider cargue los datos (que sucede en su constructor)
    // 2. Añade un retraso mínimo para que el usuario vea el logo
    await Future.delayed(const Duration(seconds: 2));

    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const SalasScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Usa el icono que acabamos de generar
            Image.asset(
                'assets/app_icon/icono_animalario.png',
                width: 150,
                height: 150
            ),
            const SizedBox(height: 20),
            const Text(
                'Animalario',
                style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold)
            ),
            const SizedBox(height: 50),
            const CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}