import 'package:despachador_procesos/algoritmos/Algoritmo.dart';

class FIFO extends Algoritmo{   
  @override
    void tick(){
      if(procesosFaltantes != 0){
        tiempo++;
        if(procesoCPU != null){
          procesoCPU?.duracion--;

          if(procesoCPU?.duracion == 0){
            salida.add(procesoCPU!);
            procesosFaltantes--;
            procesoCPU = null;
          }
        }

      final procesosQueLlegaron = procesos.where((p) => p.llegada == tiempo).toList();

      if(procesosQueLlegaron.isNotEmpty){
        cola.addAll(procesosQueLlegaron);
        administrador.addAll(procesosQueLlegaron);
        procesos.removeWhere((p) => p.llegada == tiempo);
      }
        
      if(procesoCPU == null){
        if(cola.isNotEmpty){
          procesoCPU = cola.first;
          cola.removeAt(0);
        }
      }
    }
  }
}