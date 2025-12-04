import 'package:despachador_procesos/algoritmos/Algoritmo.dart';

class FIFO extends Algoritmo {
  @override
  void tick() {
    if (procesosFaltantes == 0) return;

    tiempo++;

    if (procesoCPU != null) {
      procesoCPU!.duracion--;

      if (procesoCPU!.duracion == 0) {
        salida.add(procesoCPU!);
        fileManager.crearArchivoProceso(procesoCPU!.pid);
        procesosFaltantes--;
        procesoCPU = null;
      }
    }

    final procesosQueLlegaron = procesos
        .where((p) => p.llegada == tiempo)
        .toList();

    if (procesosQueLlegaron.isNotEmpty) {
      for (var p in procesosQueLlegaron){

        if (procesoCPU == null){
          procesoCPU = p;
          administrador.add(p);
          continue;
        }

        bool cargado = cargarProcesoEnMemoria(p);
        
        if (cargado) {
          cola.add(p);
          print("proceso cargado");
        } else {
          swapping.add(p);
          print("swapping");
        }
        administrador.add(p);
      }
      procesos.removeWhere((p) => p.llegada == tiempo);
    }

    if (procesoCPU == null && cola.isNotEmpty) {
      procesoCPU = cola.removeAt(0);
      liberarMemoria(procesoCPU!.pid);
    }
    cargarSwappingPendiente();
  }
}