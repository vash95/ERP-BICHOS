class Hueco {
  String id;
  int adultos, machos, hembras, crias, destetados;

  Hueco({
    required this.id,
    this.adultos = 0, this.machos = 0, this.hembras = 0, this.crias = 0, this.destetados = 0,
  });

  // Convertir a Mapa (JSON)
  Map<String, dynamic> toMap() => {
    'id': id, 'adultos': adultos, 'machos': machos, 'hembras': hembras, 'crias': crias, 'destetados': destetados
  };

  // Crear desde Mapa (JSON)
  factory Hueco.fromMap(Map<String, dynamic> map) => Hueco(
    id: map['id'],
    adultos: map['adultos'] ?? 0, machos: map['machos'] ?? 0, hembras: map['hembras'] ?? 0, crias: map['crias'] ?? 0, destetados: map['destetados'] ?? 0,
  );
}