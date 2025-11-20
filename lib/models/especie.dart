import 'package:erp_farm/models/rack.dart';

class Especie {
  String id;
  String nombre;
  List<Rack> racks;

  Especie({required this.id, required this.nombre, List<Rack>? racks}) : racks = racks ?? [];

  Map<String, dynamic> toMap() => {
    'id': id, 'nombre': nombre,
    'racks': racks.map((x) => x.toMap()).toList(),
  };

  factory Especie.fromMap(Map<String, dynamic> map) => Especie(
    id: map['id'], nombre: map['nombre'],
    racks: List<Rack>.from(map['racks']?.map((x) => Rack.fromMap(x)) ?? []),
  );
}