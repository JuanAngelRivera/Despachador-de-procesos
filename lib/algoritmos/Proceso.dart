class Proceso {
  final int pid;
  int duracion;
  final int llegada;
  bool bloqueado = false;
  final int bytes;

  Proceso({required this.pid, required this.duracion, required this.llegada, required this.bytes});

  Proceso.copy(Proceso original)
  : pid = original.pid,
    llegada = original.llegada,
    duracion = original.duracion,
    bytes = original.bytes;
}