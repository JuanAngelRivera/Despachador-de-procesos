import 'dart:io';

class FileManager{
  final projectDir = '${Directory.current.path}/salida';
  final rutaIndex = 'index';
  String prefijo = '';

  Future<void> crearArchivo(String nombreArchivo, String? contenido) async {
    final archivo = File('$projectDir/$nombreArchivo.ojv');
    await archivo.writeAsString(contenido  ?? "🐑");
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
    String prefijo = 'P0.';
    await crearArchivo(rutaIndex, prefijo);
    return prefijo;
  }

  Future<String> actualizarIndice() async {
    String prefijoViejo = await leerArchivo('$rutaIndex.ojv');
    String prefijoNuevo = prefijoViejo.replaceRange(1, null, '${int.parse(prefijoViejo.substring(1, prefijoViejo.length - 1)) + 1}.');
    await crearArchivo(rutaIndex, prefijoNuevo);
    return prefijoNuevo;
  }
}