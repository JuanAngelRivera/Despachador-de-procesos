import 'package:despachador_procesos/algoritmos/FIFO.dart';
import 'package:despachador_procesos/algoritmos/clases.dart';
import 'package:despachador_procesos/utils/FileManager.dart';

abstract class Algoritmo {
  List<Proceso> procesos = [];
  List<Proceso> cola = [];
  List<Proceso> administrador = [];
  List<Proceso> salida = [];
  Proceso? procesoCPU;
  late int tiempo;
  late int procesosFaltantes;
  late int quantumMax;
  late int quantum;

  List<Pagina> tablaPaginas = [];
  int totalPaginas = 4;
  int marcosPorPagina = 4;
  int tamMarco = 64;

  List<Proceso> swapping = [];
  FileManager fileManager = FileManager();

  void tick();

  Algoritmo() {
    reset();
    inicializarTabla();
    obtenerIndice();
  }

  void obtenerIndice() async {
    fileManager = FileManager();
    bool existeIndice = await fileManager.existeArchivo("index.ojv");
    if (!existeIndice) {
      fileManager.prefijo = await fileManager.crearIndice();
    } else {
      fileManager.prefijo = await fileManager.actualizarIndice();
    }
  }

  void reset() {
    procesos.clear();
    cola.clear();
    administrador.clear();
    salida.clear();
    procesoCPU = null;
    tiempo = 0;
    procesosFaltantes = 0;
    quantumMax = 0;
    quantum = 0;
    tablaPaginas.clear();
    swapping.clear();
  }

  void inicializarTabla() {
    tablaPaginas = List.generate(totalPaginas, (paginaIndex) {
      return Pagina(
        pagina: paginaIndex,
        marcos: List.generate(marcosPorPagina, (marcoIndex) {
          return Marco(marco: marcoIndex, bytesLibres: tamMarco);
        }),
      );
    });
  }

  bool cargarProcesoEnMemoria(Proceso p) {
    int tamPaginaCompleta = marcosPorPagina * tamMarco;

    if (p.bytes > tamPaginaCompleta) {
      return false;
    }

    for (var pagina in tablaPaginas) {
      int bytesOcupados = pagina.marcos.fold(
        0,
        (sum, m) => sum + m.bytesOcupados,
      );
      int bytesLibresPagina = tamPaginaCompleta - bytesOcupados;

      if (bytesLibresPagina >= p.bytes) {
        int bytesRestantes = p.bytes;

        for (var marco in pagina.marcos) {
          if (bytesRestantes == 0) return true;
          if (marco.bytesOcupados != 0) continue;

          marco.pid = p.pid;

          if (bytesRestantes > tamMarco) {
            marco.bytesOcupados = tamMarco;
            marco.bytesLibres = 0;
            bytesRestantes -= tamMarco;
          } else {
            marco.bytesOcupados = bytesRestantes;
            marco.bytesLibres = tamMarco - marco.bytesOcupados;
            bytesRestantes = 0;
          }
        }
        return true;
      }
    }
    return false;
  }

  void cargarProcesos(List<Proceso> procesosInput) {
    procesos = procesosInput.map((p) => Proceso.copy(p)).toList();

    procesos.sort((a, b) => a.llegada.compareTo(b.llegada));

    procesosFaltantes = procesos.length;

    tablaPaginas = List.generate(
      totalPaginas,
      (paginaIndex) => Pagina(
        pagina: paginaIndex,
        marcos: List.generate(
          marcosPorPagina,
          (marcoIndex) => Marco(marco: marcoIndex, bytesLibres: tamMarco),
        ),
      ),
    );
  }

  void liberarMemoria(int pid) {
    for (var pagina in tablaPaginas) {
      for (var marco in pagina.marcos) {
        if (marco.pid == pid) {
          marco.pid = -1;
          marco.bytesOcupados = 0;
          marco.bytesLibres = tamMarco;
        }
      }
    }
  }

  void cargarSwappingPendiente() {
    List<Proceso> cargados = [];

    for (var proceso in swapping) {
      bool cargado = cargarProcesoEnMemoria(proceso);
      if (cargado) {
        cola.add(proceso);
        cargados.add(proceso);
      }
    }
    swapping.removeWhere((p) => cargados.contains(p));
  }

  Algoritmo clonar() {
    var copia = this.runtimeType == FIFO
        ? FIFO()
        : throw Exception("Clon no implementado para este algoritmo");

    copia.tiempo = tiempo;
    copia.procesosFaltantes = procesosFaltantes;
    copia.quantum = quantum;
    copia.quantumMax = quantumMax;

    copia.procesos = procesos.map((p) => Proceso.copy(p)).toList();
    copia.cola = cola.map((p) => Proceso.copy(p)).toList();
    copia.administrador = administrador.map((p) => Proceso.copy(p)).toList();
    copia.salida = salida.map((p) => Proceso.copy(p)).toList();
    copia.procesoCPU = procesoCPU != null ? Proceso.copy(procesoCPU!) : null;
    copia.swapping = swapping.map((p) => Proceso.copy(p)).toList();
    copia.tablaPaginas = tablaPaginas.map((pag) => pag.copy()).toList();
    return copia;
  }

  Algoritmo tickVirtual() {
    var copia = clonar();
    copia.tick();
    return copia;
  }

  List<String> previewTick() {
    List<String> eventos = [];

    final siguienteTiempo = tiempo + 1;

    if (procesoCPU != null) {
      if (procesoCPU!.duracion == 1) {
        eventos.add("P${procesoCPU!.pid} saldrá del CPU");
      }
    }

    final llegan = procesos.where((p) => p.llegada == siguienteTiempo).toList();
    for (var p in llegan) {
      eventos.add("P${p.pid} llegará al sistema");
    }

    final cpuEstaraLibre = (procesoCPU == null) || (procesoCPU!.duracion == 1);

    if (cpuEstaraLibre && cola.isNotEmpty) {
      eventos.add("P${cola.first.pid} entrará al CPU");
    }

    for (var p in llegan) {
      bool cabe = cabeEnMemoriaPreview(p);

      bool entraDirectoCpu = cpuEstaraLibre && cola.isEmpty;

      if (entraDirectoCpu) {
        eventos.add("P${p.pid} pasará directo al CPU");
        continue;
      }

      if (cabe) {
        eventos.add("P${p.pid} entrará a memoria");
      } else {
        eventos.add("P${p.pid} irá a swapping");
      }
    }

    return eventos;
  }

  bool cabeEnMemoriaPreview(Proceso p) {
    int tamPaginaCompleta = marcosPorPagina * tamMarco;

    if (p.bytes > tamPaginaCompleta) return false;

    for (var pagina in tablaPaginas) {
      int bytesOcupados = pagina.marcos.fold(
        0,
        (sum, m) => sum + m.bytesOcupados,
      );
      int libres = tamPaginaCompleta - bytesOcupados;

      if (libres >= p.bytes) {
        return true;
      }
    }

    return false;
  }
}