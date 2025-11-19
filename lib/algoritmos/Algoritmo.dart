import 'package:despachador_procesos/main.dart';

abstract class Algoritmo{
  void cargarProcesos(List<Proceso> procesos){
    this.procesos = procesos.map((p) => Proceso.copy(p)).toList();
    this.procesos.sort((a, b) => a.llegada.compareTo(b.llegada));
    procesosFaltantes = procesos.length;
  }

  List<Proceso> procesos = [];
  List<Proceso> cola = [];
  List<Proceso> administrador = [];
  List<Proceso> salida = [];
  Proceso? procesoCPU;
  int tiempo = 0;
  int procesosFaltantes = 0;
  int quantumMax = 0;
  int quantum = 0;

  void tick();

  void reset(){
    procesos.clear();
    administrador.clear();
    cola.clear();
    salida.clear();
    procesoCPU = null;
    tiempo = 0;
    procesosFaltantes = 0;
    quantum = 0;
    quantumMax = 0;
  }
}