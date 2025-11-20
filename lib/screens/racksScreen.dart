import 'package:erp_farm/screens/rackDetalleScreen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/model.dart';
import '../models/rack.dart';
import '../providers/data_provider.dart';

class RacksScreen extends StatelessWidget {
  final String salaId, especieId;
  const RacksScreen({super.key, required this.salaId, required this.especieId});
  @override
  Widget build(BuildContext context) {
    final prov = Provider.of<DataProvider>(context);
    final sala = prov.salas.firstWhere((s) => s.id == salaId);
    final especie = sala.especies.firstWhere((e) => e.id == especieId);
    final bool esRata = especie.nombre == 'Ratas';

    return Scaffold(
      appBar: AppBar(
        title: Text('Racks de ${especie.nombre}'),
        backgroundColor: esRata ? Colors.grey[400] : Colors.amber[200],
      ),
      body: ListView.builder(
        itemCount: especie.racks.length,
        itemBuilder: (ctx, i) {
          final rack = especie.racks[i];
          return Card(
            child: ListTile(
              leading: const Icon(Icons.grid_view),
              title: Text(rack.nombre),
              subtitle: Text('${rack.tipo.name.toUpperCase()} - ${rack.huecos.length} huecos'),
              trailing: IconButton(
                icon: const Icon(Icons.delete_outline, color: Colors.red),
                onPressed: () => prov.deleteRack(salaId, especieId, rack.id),
              ),
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => RackDetalleScreen(salaId: salaId, especieId: especieId, rackId: rack.id))),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () => _showAddRackDialog(context, prov),
      ),
    );
  }

  void _showAddRackDialog(BuildContext context, DataProvider prov) {
    final nameCtrl = TextEditingController();
    final huecosCtrl = TextEditingController(text: '20');
    TipoRack tipo = TipoRack.cebo;
    showDialog(context: context, builder: (ctx) => StatefulBuilder(builder: (ctx, setState) => AlertDialog(
      title: const Text('Nuevo Rack'),
      content: Column(mainAxisSize: MainAxisSize.min, children: [
        TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Nombre')),
        TextField(controller: huecosCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Cantidad huecos')),
        Row(children: [
          Expanded(child: RadioListTile(title: const Text('Cebo'), value: TipoRack.cebo, groupValue: tipo, onChanged: (v) => setState(() => tipo = v!))),
          Expanded(child: RadioListTile(title: const Text('Cría'), value: TipoRack.cria, groupValue: tipo, onChanged: (v) => setState(() => tipo = v!))),
        ])
      ]),
      actions: [ElevatedButton(onPressed: () { if(nameCtrl.text.isNotEmpty) { prov.addRack(salaId, especieId, nameCtrl.text, tipo, int.parse(huecosCtrl.text)); Navigator.pop(ctx); }}, child: const Text('Guardar'))],
    )));
  }
}