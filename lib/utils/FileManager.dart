import 'dart:async';
import 'dart:io';

class FileManager {
  final projectDir = '${Directory.current.path}/salida';
  final rutaIndex = 'index.ojv';
  String prefijo = '';
  String rutaFAT = 'FAT.ojv';
  String encabezado = '''
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
| ID Proceso   | Ruta                                                                                                                           | Fecha de creación         | Tamaño       |
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
''';

  Future<String> crearArchivo(String nombreArchivo, String? contenido) async {
    final ruta = '$projectDir/$nombreArchivo';
    final archivo = File(ruta);
    await archivo.writeAsString(contenido ?? "🐑");
    return ruta;
  }

  Future<bool> existeArchivo(String rutaArchivo) async {
    final archivo = File('$projectDir/$rutaArchivo');
    if (await archivo.exists()) return true;
    return false;
  }

  Future<String> leerArchivo(String rutaArchivo) async {
    final archivo = File('$projectDir/$rutaArchivo');
    return await archivo.readAsString();
  }

  Future<String> crearIndice() async {
    String prefijo = 'R0.';
    await crearArchivo(rutaIndex, prefijo);
    return prefijo;
  }

  Future<String> actualizarIndice() async {
    String prefijoViejo = await leerArchivo(rutaIndex);
    String prefijoNuevo = prefijoViejo.replaceRange(
      1,
      null,
      '${int.parse(prefijoViejo.substring(1, prefijoViejo.length - 1)) + 1}.',
    );
    await crearArchivo(rutaIndex, prefijoNuevo);
    return prefijoNuevo;
  }

  Future<String> crearArchivoProceso(int id) async {
    return await crearArchivo('$prefijo$id.ovg', null);
  }

  Future<void> crearFAT() async {
    await crearArchivo(rutaFAT, encabezado);
  }

  Future<String> generarFila(String ruta, int id) async {
    final File archivo = File(ruta);
    final info = await archivo.stat();
    final fecha = info.changed.toString();
    final tam = info.size.toString();

    return '| ${'$prefijo$id'.padRight(12)} '
        '| ${ruta.padRight(126)} '
        '| ${fecha.toString().padRight(25)} '
        '| ${tam.toString().padRight(12)} |\n';
  }

  Future<void> actualizarFAT(String contenidoNuevo) async {
    final bool existeFAT = await existeArchivo(rutaFAT);
    if (!existeFAT) {
      await crearFAT();
    }

    final contenidoActual = await leerArchivo(rutaFAT);
    await crearArchivo(rutaFAT, '$contenidoActual$contenidoNuevo');
  }
}