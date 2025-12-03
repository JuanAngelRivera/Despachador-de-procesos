import 'package:despachador_procesos/algoritmos/Proceso.dart';

abstract class Algoritmo {
  List<Proceso> procesos = [];
  List<Proceso> cola = [];
  List<Proceso> administrador = [];
  List<Proceso> salida = [];
  Proceso? procesoCPU;
  int tiempo = 0;
  int procesosFaltantes = 0;
  int quantumMax = 0;
  int quantum = 0;

  List<EntradaPagina> tablaPaginas = [];
  int marcos = 16;
  int tamPagina = 256;
  List<Proceso> swapping = [];

  void tick();

  void reset() {
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

  bool cargarProcesoEnMemoria(Proceso proceso) {
    int paginas = (proceso.bytes / tamPagina).ceil();
    int marcosDisponibles = tablaPaginas.where((e) => !e.ocupado).length;

    if (marcosDisponibles < paginas) {
      return false;
    }

    int paginasAsignadas = 0;

    for (
      int i = 0;
      i < tablaPaginas.length && paginasAsignadas < paginas;
      i++
    ) {
      if (!tablaPaginas[i].ocupado) {
        tablaPaginas[i].ocupado = true;
        tablaPaginas[i].pid = proceso.pid;
        tablaPaginas[i].pagina = paginasAsignadas;
        paginasAsignadas++;
      }
    }
    return true;
  }

  void gestionarLlegada(Proceso proceso) {
    bool cabe = cargarProcesoEnMemoria(proceso);
    if (cabe) {
      cola.add(proceso);
    } else {
      swapping.add(proceso);
    }
  }

  void liberarMemoria(int pid) {
    for (var entrada in tablaPaginas) {
      if (entrada.pid == pid) {
        entrada.ocupado = false;
        entrada.pid = -1;
        entrada.pagina = -1;
      }
    }

    _cargarSwappingPendiente();
  }

  void _cargarSwappingPendiente() {
    List<Proceso> cargados = [];

    for (var proceso in swapping) {
      if (cargarProcesoEnMemoria(proceso)) {
        cola.add(proceso);
        cargados.add(proceso);
      }
    }
    swapping.removeWhere((p) => cargados.contains(p));
  }

  void cargarProcesos(List<Proceso> procesos) {
    this.procesos = procesos.map((p) => Proceso.copy(p)).toList();

    this.procesos.sort((a, b) => a.llegada.compareTo(b.llegada));

    procesosFaltantes = this.procesos.length;

    tablaPaginas = List.generate(
      marcos,
      (i) => EntradaPagina(pagina: -1, marco: i, pid: -1, ocupado: false),
    );

    for (var p in this.procesos) {
      gestionarLlegada(p);
    }
  }
}
