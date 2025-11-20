import 'hueco.dart';

enum TipoRack { cria, cebo }

class Rack {
  String id;
  String nombre;
  TipoRack tipo;
  List<Hueco> huecos;

  Rack({required this.id, required this.nombre, required this.tipo, required this.huecos});

  Map<String, dynamic> toMap() => {
    'id': id, 'nombre': nombre, 'tipo': tipo.name,
    'huecos': huecos.map((x) => x.toMap()).toList(),
  };

  factory Rack.fromMap(Map<String, dynamic> map) => Rack(
    id: map['id'], nombre: map['nombre'],
    tipo: TipoRack.values.firstWhere((e) => e.name == map['tipo'], orElse: () => TipoRack.cebo),
    huecos: List<Hueco>.from(map['huecos']?.map((x) => Hueco.fromMap(x)) ?? []),
  );
}