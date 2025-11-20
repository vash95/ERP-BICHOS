import 'package:erp_farm/screens/racksScreen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/data_provider.dart';

class EspeciesScreen extends StatelessWidget {
  final String salaId;
  const EspeciesScreen({super.key, required this.salaId});
  @override
  Widget build(BuildContext context) {
    final prov = Provider.of<DataProvider>(context);
    final sala = prov.salas.firstWhere((s) => s.id == salaId);
    final bool tieneRatas = sala.especies.any((e) => e.nombre == 'Ratas');
    final bool tieneRatones = sala.especies.any((e) => e.nombre == 'Ratones');
    List<String> disponibles = [];
    if (!tieneRatas) disponibles.add('Ratas');
    if (!tieneRatones) disponibles.add('Ratones');

    return Scaffold(
      appBar: AppBar(title: Text('Especies en ${sala.nombre}')),
      body: ListView.builder(
        itemCount: sala.especies.length,
        itemBuilder: (ctx, i) {
          final especie = sala.especies[i];
          final bool esRata = especie.nombre == 'Ratas';
          return Card(
            color: esRata ? Colors.grey[200] : Colors.amber[50],
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: esRata ? Colors.grey[800] : Colors.amber[700],
                child: Icon(esRata ? Icons.pest_control_rodent : Icons.pest_control_rodent, color: Colors.white),
              ),
              title: Text(especie.nombre, style: const TextStyle(fontWeight: FontWeight.bold)),
              trailing: IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () => prov.deleteEspecie(salaId, especie.id),
              ),
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => RacksScreen(salaId: salaId, especieId: especie.id))),
            ),
          );
        },
      ),
      floatingActionButton: disponibles.isEmpty ? null : FloatingActionButton.extended(
        onPressed: () {
          showDialog(
            context: context,
            builder: (ctx) => SimpleDialog(
              title: const Text('Selecciona tipo', textAlign: TextAlign.center),
              children: disponibles.map((op) => SimpleDialogOption(
                padding: const EdgeInsets.all(20),
                child: Center(child: Text(op, style: const TextStyle(fontSize: 18))),
                onPressed: () { prov.addEspecie(salaId, op); Navigator.pop(ctx); },
              )).toList(),
            ),
          );
        },
        label: const Text('Añadir Especie'), icon: const Icon(Icons.add),
      ),
    );
  }
}