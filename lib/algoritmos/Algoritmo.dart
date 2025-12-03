import 'package:despachador_procesos/algoritmos/clases.dart';

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

  void tick();

  Algoritmo(){
    reset();
    inicializarTabla();
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

          if (bytesRestantes > tamMarco){
            marco.bytesOcupados = tamMarco;
            marco.bytesLibres = 0;
            bytesRestantes -= tamMarco;
          }
          else {
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
}