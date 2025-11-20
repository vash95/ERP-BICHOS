import 'especie.dart';

class Sala {
  String id;
  String nombre;
  List<Especie> especies;

  Sala({required this.id, required this.nombre, List<Especie>? especies}) : especies = especies ?? [];

  Map<String, dynamic> toMap() => {
    'id': id, 'nombre': nombre,
    'especies': especies.map((x) => x.toMap()).toList(),
  };

  factory Sala.fromMap(Map<String, dynamic> map) => Sala(
    id: map['id'], nombre: map['nombre'],
    especies: List<Especie>.from(map['especies']?.map((x) => Especie.fromMap(x)) ?? []),
  );
}