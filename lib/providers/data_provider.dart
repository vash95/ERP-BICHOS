import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:uuid/uuid.dart';

import '../models/especie.dart';
import '../models/hueco.dart';
import '../models/model.dart';
import '../models/rack.dart';
import '../models/sala.dart';

class DataProvider with ChangeNotifier {
  List<Sala> _salas = [];
  List<Sala> get salas => _salas;
  final Uuid uuid = const Uuid();

  // Cargar datos al iniciar
  DataProvider() {
    _loadData();
  }

  // --- PERSISTENCIA (GUARDAR Y CARGAR) ---
  Future<void> _saveData() async {
    final prefs = await SharedPreferences.getInstance();
    final String data = json.encode(_salas.map((s) => s.toMap()).toList());
    await prefs.setString('mis_datos_animalario', data);
  }

  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.containsKey('mis_datos_animalario')) {
      final String? data = prefs.getString('mis_datos_animalario');
      if (data != null) {
        final List<dynamic> decoded = json.decode(data);
        _salas = decoded.map((item) => Sala.fromMap(item)).toList();
        notifyListeners();
      }
    }
  }

  // --- GESTIÓN DE SALAS ---
  void addSala(String nombre) {
    _salas.add(Sala(id: uuid.v4(), nombre: nombre));
    _saveData(); notifyListeners();
  }

  void deleteSala(String id) {
    _salas.removeWhere((s) => s.id == id);
    _saveData(); notifyListeners();
  }

  // --- GESTIÓN DE ESPECIES ---
  void addEspecie(String salaId, String nombreEspecie) {
    final sala = _salas.firstWhere((s) => s.id == salaId);
    if (!sala.especies.any((e) => e.nombre == nombreEspecie)) {
      sala.especies.add(Especie(id: uuid.v4(), nombre: nombreEspecie));
      _saveData(); notifyListeners();
    }
  }

  void deleteEspecie(String salaId, String especieId) {
    final sala = _salas.firstWhere((s) => s.id == salaId);
    sala.especies.removeWhere((e) => e.id == especieId);
    _saveData(); notifyListeners();
  }

  // --- GESTIÓN DE RACKS ---
  void addRack(String salaId, String especieId, String nombreRack, TipoRack tipo, int cantidadHuecos) {
    final sala = _salas.firstWhere((s) => s.id == salaId);
    final especie = sala.especies.firstWhere((e) => e.id == especieId);
    List<Hueco> nuevosHuecos = List.generate(cantidadHuecos, (_) => Hueco(id: uuid.v4()));
    especie.racks.add(Rack(id: uuid.v4(), nombre: nombreRack, tipo: tipo, huecos: nuevosHuecos));
    _saveData(); notifyListeners();
  }

  void deleteRack(String salaId, String especieId, String rackId) {
    final sala = _salas.firstWhere((s) => s.id == salaId);
    final especie = sala.especies.firstWhere((e) => e.id == especieId);
    especie.racks.removeWhere((r) => r.id == rackId);
    _saveData(); notifyListeners();
  }

  // --- GESTIÓN DE HUECOS (CELDAS) ---
  void updateHueco(String salaId, String especieId, String rackId, String huecoId, Hueco nuevosDatos) {
    final sala = _salas.firstWhere((s) => s.id == salaId);
    final especie = sala.especies.firstWhere((e) => e.id == especieId);
    final rack = especie.racks.firstWhere((r) => r.id == rackId);
    final index = rack.huecos.indexWhere((h) => h.id == huecoId);
    if (index != -1) {
      rack.huecos[index] = nuevosDatos;
      _saveData(); notifyListeners();
    }
  }

  void deleteHueco(String salaId, String especieId, String rackId, String huecoId) {
    final sala = _salas.firstWhere((s) => s.id == salaId);
    final especie = sala.especies.firstWhere((e) => e.id == especieId);
    final rack = especie.racks.firstWhere((r) => r.id == rackId);
    rack.huecos.removeWhere((h) => h.id == huecoId);
    _saveData(); notifyListeners();
  }

  void addOneHueco(String salaId, String especieId, String rackId) {
    final sala = _salas.firstWhere((s) => s.id == salaId);
    final especie = sala.especies.firstWhere((e) => e.id == especieId);
    final rack = especie.racks.firstWhere((r) => r.id == rackId);
    rack.huecos.add(Hueco(id: uuid.v4()));
    _saveData(); notifyListeners();
  }

  // --- EXPORTACIÓN Y ESTADÍSTICAS ---
  Map<String, dynamic> obtenerEstadisticas() {
    // Contadores de Población por Especie y Categoría
    int totalRatas = 0;
    int totalRatones = 0;
    int totalCrias = 0;
    int totalHembras = 0;
    int totalMachos = 0;
    int totalDestetados = 0;
    int totalCebo = 0; // Se asume que 'adultos' en el código original son 'cebo' o reproductores no clasificados.

    // Contadores de Instalaciones y Máximos
    int totalHuecos = 0;
    int maxCrias = -1;
    String ubicacionMVP = "Ninguna";

    // Variables auxiliares para cálculos avanzados
    int hembrasReproductoras = 0; // Usado para el cálculo de productividad
    int totalDestetadosParaTasa = 0;

    for (var sala in _salas) {
      for (var especie in sala.especies) {
        // Uso de una constante para mayor robustez (asumiendo que 'Ratas' es la constante)
        const String NOMBRE_RATAS = 'Ratas';
        bool esRata = especie.nombre == NOMBRE_RATAS;

        for (var rack in especie.racks) {
          for (var hueco in rack.huecos) {
            totalHuecos++; // Cuenta de recursos (Huecos)

            // Acumulación de categorías
            totalCrias += hueco.crias;
            totalHembras += hueco.hembras;
            totalMachos += hueco.machos;
            totalDestetados += hueco.destetados;
            totalCebo += hueco.adultos;

            // Criterios para métricas avanzadas
            if (hueco.hembras > 0) {
              hembrasReproductoras += hueco.hembras;
            }
            if (hueco.destetados > 0) {
              // Suponemos que estos destetados provienen de un pool de crías reciente
              totalDestetadosParaTasa += hueco.destetados;
            }

            // Cálculo de población por hueco
            int poblacion = hueco.crias + hueco.hembras + hueco.machos + hueco.destetados + hueco.adultos;

            if (esRata) {
              totalRatas += poblacion;
            } else {
              totalRatones += poblacion;
            }

            // Identificación del Máximo Productor (MVP)
            if (hueco.crias > maxCrias) {
              maxCrias = hueco.crias;
              // Se añade el nombre del Hueco para precisión (asumiendo que Hueco tiene una propiedad 'nombre')
              // Si 'Hueco' no tiene nombre, usar un ID o simplemente 'Hueco #[índice]'
              String nombreHueco = hueco.id;
              ubicacionMVP = "${sala.nombre} > ${rack.nombre} > $nombreHueco";
            }
          }
        }
      }
    }

    // CÁLCULOS FINALES DE MÉTRICAS AVANZADAS
    int poblacionTotal = totalRatas + totalRatones;

    // Ratio Macho:Hembra (para evitar división por cero)
    double ratioMachoHembra = totalHembras > 0 ? totalMachos / totalHembras : 0.0;

    // Promedio de Crías por Hembra (Productividad)
    double promedioCriasPorHembra = hembrasReproductoras > 0 ? totalCrias / hembrasReproductoras : 0.0;

    // Tasa de Destete (Supervivencia: Destetados / (Crías + Destetados en el ciclo) - una aproximación
    int nacidosTotal = totalCrias + totalDestetadosParaTasa; // Asumiendo que las crías y los destetados representan el ciclo actual
    double tasaDestete = nacidosTotal > 0 ? totalDestetadosParaTasa / nacidosTotal : 0.0;


    // RETORNO DEL MAPA DE ESTADÍSTICAS AMPLIADO
    return {
      // ESTADÍSTICAS BÁSICAS DE CONTEO
      'ratas': totalRatas,
      'ratones': totalRatones,
      'poblacion_total': poblacionTotal,
      'crias': totalCrias,
      'hembras': totalHembras,
      'machos': totalMachos,
      'destetados': totalDestetados,
      'cebo': totalCebo,

      // ESTADÍSTICAS DE INSTALACIONES Y DENSIDAD
      'total_huecos': totalHuecos,
      'poblacion_por_hueco': totalHuecos > 0 ? poblacionTotal / totalHuecos : 0.0,

      // ESTADÍSTICAS DE PRODUCTIVIDAD Y RATIOS
      'ratio_macho_hembra': ratioMachoHembra,
      'promedio_crias_por_hembra': promedioCriasPorHembra,
      'tasa_destete': tasaDestete, // Devuelve un valor entre 0 y 1. Multiplicar por 100 para porcentaje.

      // MVP (MEJOR PRODUCTOR)
      'mvp_crias': maxCrias == -1 ? 0 : maxCrias,
      'mvp_ubicacion': ubicacionMVP,
    };
  }

  Future<void> exportarDatos() async {
    String csv = "Sala,Especie,Rack,Tipo,Hueco_ID,Machos,Hembras,Crias,Destetados,Adultos_Cebo\n";
    for (var sala in _salas) {
      for (var especie in sala.especies) {
        for (var rack in especie.racks) {
          for (int i = 0; i < rack.huecos.length; i++) {
            final h = rack.huecos[i];
            csv += "${sala.nombre},${especie.nombre},${rack.nombre},${rack.tipo.name},H-${i+1},${h.machos},${h.hembras},${h.crias},${h.destetados},${h.adultos}\n";
          }
        }
      }
    }
    final directory = await getTemporaryDirectory();
    final path = "${directory.path}/datos_animalario.csv";
    final file = File(path);
    await file.writeAsString(csv);
    await Share.shareXFiles([XFile(path)], text: 'Exportación Animalario');
  }
}