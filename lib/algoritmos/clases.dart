class Proceso {
  final int pid;
  int duracion;
  final int llegada;
  bool bloqueado = false;
  final int bytes;

  Proceso({
    required this.pid,
    required this.duracion,
    required this.llegada,
    required this.bytes,
  });

  Proceso.copy(Proceso original)
    : pid = original.pid,
      llegada = original.llegada,
      duracion = original.duracion,
      bytes = original.bytes;
}

class EntradaPagina {
  int pagina;
  int marco;
  int pid;
  bool ocupado;

  EntradaPagina({
    required this.pagina,
    required this.marco,
    required this.pid,
    required this.ocupado,
  });
}

class Marco {
  int marco;
  int pid;
  int bytesOcupados;
  int bytesLibres;

  Marco({
    required this.marco,
    this.pid = -1,
    this.bytesOcupados = 0,
    required this.bytesLibres,
  });
}

class Pagina {
  int pagina;
  List<Marco> marcos;

  Pagina({required this.pagina, required this.marcos});

  Pagina copy() {
    return Pagina(pagina: pagina, marcos: marcos);
  }
}