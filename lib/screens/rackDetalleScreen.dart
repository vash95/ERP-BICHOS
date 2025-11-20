import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/hueco.dart';
import '../models/model.dart';
import '../models/rack.dart';
import '../providers/data_provider.dart';

class RackDetalleScreen extends StatelessWidget {
  final String salaId, especieId, rackId;
  const RackDetalleScreen({super.key, required this.salaId, required this.especieId, required this.rackId});
  @override
  Widget build(BuildContext context) {
    final prov = Provider.of<DataProvider>(context);
    final sala = prov.salas.firstWhere((s) => s.id == salaId);
    final especie = sala.especies.firstWhere((e) => e.id == especieId);
    final rack = especie.racks.firstWhere((r) => r.id == rackId);

    return Scaffold(
      appBar: AppBar(title: Text('${rack.nombre} (${rack.tipo.name})')),
      body: GridView.builder(
        padding: const EdgeInsets.all(10),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 4, crossAxisSpacing: 10, mainAxisSpacing: 10),
        itemCount: rack.huecos.length,
        itemBuilder: (ctx, i) {
          final h = rack.huecos[i];
          return InkWell(
            onTap: () => _showEditDialog(context, prov, rack, h),
            child: Container(
              decoration: BoxDecoration(color: Colors.blue[50], border: Border.all(color: Colors.blue), borderRadius: BorderRadius.circular(8)),
              child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                Text('H-${i + 1}', style: const TextStyle(color: Colors.grey)),
                if(rack.tipo == TipoRack.cebo) Text('A:${h.adultos}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                if(rack.tipo == TipoRack.cria) ...[
                  Text('M:${h.machos} H:${h.hembras}', style: const TextStyle(fontSize: 11)),
                  Text('C:${h.crias} D:${h.destetados}', style: const TextStyle(fontSize: 11)),
                ]
              ]),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () => prov.addOneHueco(salaId, especieId, rackId), // Añadir celda extra
      ),
    );
  }

  void _showEditDialog(BuildContext context, DataProvider prov, Rack rack, Hueco hueco) {
    final a = TextEditingController(text: '${hueco.adultos}');
    final m = TextEditingController(text: '${hueco.machos}');
    final h = TextEditingController(text: '${hueco.hembras}');
    final c = TextEditingController(text: '${hueco.crias}');
    final d = TextEditingController(text: '${hueco.destetados}');

    showDialog(context: context, builder: (ctx) => AlertDialog(
      title: const Text('Editar Hueco'),
      content: SingleChildScrollView(child: Column(children: [
        if (rack.tipo == TipoRack.cebo) TextField(controller: a, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Adultos')),
        if (rack.tipo == TipoRack.cria) ...[
          TextField(controller: m, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Machos')),
          TextField(controller: h, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Hembras')),
          TextField(controller: c, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Crías')),
          TextField(controller: d, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Destetados')),
        ]
      ])),
      actionsAlignment: MainAxisAlignment.spaceBetween,
      actions: [
        IconButton(icon: const Icon(Icons.delete, color: Colors.red), onPressed: () { prov.deleteHueco(salaId, especieId, rackId, hueco.id); Navigator.pop(ctx); }),
        ElevatedButton(onPressed: () {
          prov.updateHueco(salaId, especieId, rackId, hueco.id, Hueco(
              id: hueco.id, adultos: int.tryParse(a.text)??0, machos: int.tryParse(m.text)??0, hembras: int.tryParse(h.text)??0, crias: int.tryParse(c.text)??0, destetados: int.tryParse(d.text)??0
          ));
          Navigator.pop(ctx);
        }, child: const Text('Guardar'))
      ],
    ));
  }
}