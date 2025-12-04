import 'package:despachador_procesos/algoritmos/Algoritmo.dart';

class FIFO extends Algoritmo {
  @override
  void tick() async {
    if (procesosFaltantes == 0) return;

    tiempo++;

    if (procesoCPU != null) {
      procesoCPU!.duracion--;

      if (procesoCPU!.duracion == 0) {
        salida.add(procesoCPU!);
        String ruta = await fileManager.crearArchivoProceso(procesoCPU!.pid);
        String contenidoNuevo = await fileManager.generarFila(
          ruta,
          procesoCPU!.pid,
        );
        liberarMemoria(procesoCPU!.pid);
        fileManager.actualizarFAT(contenidoNuevo);
        procesosFaltantes--;
        procesoCPU = null;
      }
    }

    final procesosQueLlegaron = procesos
        .where((p) => p.llegada == tiempo)
        .toList();

    if (procesosQueLlegaron.isNotEmpty) {
      for (var p in procesosQueLlegaron) {
        administrador.add(p);

        bool cargado = cargarProcesoEnMemoria(p);

        if (cargado) {
          cola.add(p);
        } else {
          swapping.add(p);
        }
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