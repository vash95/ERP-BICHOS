import 'package:erp_farm/screens/statsScreen.dart';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../providers/data_provider.dart';
import 'especiesScreen.dart';

class SalasScreen extends StatelessWidget {
  const SalasScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final prov = Provider.of<DataProvider>(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestión de Salas'),
        actions: [
          IconButton(icon: const Icon(Icons.info_outline), onPressed: () => showInfoDialog(context)),
          IconButton(icon: const Icon(Icons.bar_chart), onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const StatsScreen()))),
          IconButton(icon: const Icon(Icons.download), onPressed: () => prov.exportarDatos()),
        ],
      ),
      body: ListView.builder(
        itemCount: prov.salas.length,
        itemBuilder: (ctx, i) {
          final sala = prov.salas[i];
          return ListTile(
            title: Text(sala.nombre, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text('${sala.especies.length} especies activas'),
            trailing: IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () => prov.deleteSala(sala.id),
            ),
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => EspeciesScreen(salaId: sala.id))),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () {
          final ctrl = TextEditingController();
          showDialog(
            context: context,
            builder: (_) => AlertDialog(
              title: const Text('Nueva Sala'),
              content: TextField(controller: ctrl, decoration: const InputDecoration(labelText: 'Nombre')),
              actions: [
                ElevatedButton(
                    onPressed: () { if(ctrl.text.isNotEmpty) { prov.addSala(ctrl.text); Navigator.pop(context); }},
                    child: const Text('Crear')
                )
              ],
            ),
          );
        },
      ),
    );
  }
  Future<void> showInfoDialog(BuildContext context) async {
    final PackageInfo info = await PackageInfo.fromPlatform();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Acerca de Animalario'),
        content: SingleChildScrollView(
          child: ListBody(
            children: <Widget>[
              Text('Nombre de la App: ${info.appName}'),
              Text('Versión: ${info.version}'),
              const SizedBox(height: 15),
              const Text('Desarrollador: Borja Rabadán'),
              const SizedBox(height: 20),

              // Botón/Enlace a LinkedIn
              TextButton.icon(
                icon: const Icon(Icons.link),
                label: const Text('LinkedIn del Creador', style: TextStyle(decoration: TextDecoration.underline)),
                onPressed: () {
                  _launchUrl('https://www.linkedin.com/in/borja-rabadán-martín-7569abb9');
                  Navigator.of(ctx).pop();
                },
              ),

              // Botón para salir/cerrar
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: const Text('Cerrar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Future<void> _launchUrl(String url) async {
  final Uri uri = Uri.parse(url);

  // 1. Verifica si el enlace puede ser abierto por el sistema
  if (await canLaunchUrl(uri)) {
    // 2. Lanza (abre) el enlace en el navegador
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  } else {
    // Manejo de errores si el sistema no puede abrir la URL (muy raro)
    print('No se pudo abrir el enlace: $url');
    // Opcional: mostrar un mensaje de error al usuario (ej: ScaffoldMessenger)
  }
}