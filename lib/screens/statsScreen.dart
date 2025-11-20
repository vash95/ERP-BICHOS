import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../providers/data_provider.dart';



class StatsScreen extends StatelessWidget {
  const StatsScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final prov = Provider.of<DataProvider>(context);
    final st = prov.obtenerEstadisticas();
    return Scaffold(
      appBar: AppBar(title: const Text('Estadísticas')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [

          // --- 1. POBLACIÓN GENERAL Y RESUMEN ---

          // Total de Ratas vs. Ratones (EXISTENTE)
          Row(children: [
            Expanded(child: _CardStat('Ratas', '${st['ratas']}', Colors.grey[800]!)),
            Expanded(child: _CardStat('Ratones', '${st['ratones']}', Colors.amber[800]!)),
          ]),

          const SizedBox(height: 20),

          // Población Total y Densidad (NUEVO)
          const Text('Población General', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),

          GridView.count(
            shrinkWrap: true,
            crossAxisCount: 2,
            childAspectRatio: 2.5, // Ajuste para texto más largo
            physics: const NeverScrollableScrollPhysics(), // Evita scroll interno
            children: [
              _CardStat('Pob. Total', '${st['poblacion_total']}', Colors.indigo),
              _CardStat('Pob. / Hueco',
                  '${(st['poblacion_por_hueco'] as double).toStringAsFixed(2)}', // Mostrar 2 decimales
                  Colors.teal),
              _CardStat('Total Huecos', '${st['total_huecos']}', Colors.brown),
              _CardStat('Cebo/Adultos', '${st['cebo']}', Colors.red[800]!),
            ],
          ),

          // --- 2. DESGLOSE POR CATEGORÍA ---

          const SizedBox(height: 20),
          const Text('Desglose por Categoría', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),

          // Desglose (EXISTENTE)
          GridView.count(
            shrinkWrap: true,
            crossAxisCount: 2,
            childAspectRatio: 2,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              _CardStat('Machos', '${st['machos']}', Colors.blue),
              _CardStat('Hembras', '${st['hembras']}', Colors.pink),
              _CardStat('Crías', '${st['crias']}', Colors.green),
              _CardStat('Destetados', '${st['destetados']}', Colors.orange),
            ],
          ),

          // --- 3. PRODUCTIVIDAD Y GESTIÓN REPRODUCTIVA ---

          const SizedBox(height: 20),
          const Text('Productividad y Ratios', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),

          GridView.count(
            shrinkWrap: true,
            crossAxisCount: 1, // Una sola columna para los indicadores de productividad
            childAspectRatio: 4,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              _CardStat('Ratio M:H',
                  '1 : ${(st['ratio_macho_hembra'] as double).toStringAsFixed(2)}', // Formato 1 : X.XX
                  Colors.deepPurple),
              _CardStat('Crías/Hembra',
                  '${(st['promedio_crias_por_hembra'] as double).toStringAsFixed(2)}',
                  Colors.lightGreen),
              _CardStat('Tasa Destete',
                  '${((st['tasa_destete'] as double) * 100).toStringAsFixed(1)}%', // Mostrar como porcentaje (X.X%)
                  Colors.cyan),
            ],
          ),

          // --- 4. MEJOR PRODUCTOR (MVP) ---

          const SizedBox(height: 20),
          // MVP (EXISTENTE)
          ListTile(
            title: const Text('Mejor Jaula (Crías)', style: TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text('${st['mvp_ubicacion']}'),
            trailing: Text('${st['mvp_crias']} crías', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            leading: const Icon(Icons.emoji_events, color: Colors.amber, size: 40),
          ),
        ],
      ),
    );
  }
}

class _CardStat extends StatelessWidget {
  final String t, v; final Color c;
  const _CardStat(this.t, this.v, this.c);

  @override
  Widget build(BuildContext context) {
    // Ya NO usa Expanded, solo devuelve el Card
    return Card(
        color: c.withOpacity(0.1),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(children: [
            Text(v, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: c)),
            Text(t)
          ]),
        ));
  }
}