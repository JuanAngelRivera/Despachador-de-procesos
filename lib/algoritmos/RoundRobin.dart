import 'package:despachador_procesos/algoritmos/Algoritmo.dart';

class RoundRobin extends Algoritmo{   
  @override
    void tick(){
      if(procesosFaltantes != 0){
        tiempo++;

        final procesosQueLlegaron = procesos.where((p) => p.llegada == tiempo).toList();
        if(procesosQueLlegaron.isNotEmpty){
          cola.addAll(procesosQueLlegaron);
          administrador.addAll(procesosQueLlegaron);
          procesos.removeWhere((p) => p.llegada == tiempo);
        }

        if(procesoCPU != null){
          procesoCPU?.duracion--;
          quantum--;

          if(procesoCPU?.duracion == 0){
            salida.add(procesoCPU!);
            procesosFaltantes--;
            procesoCPU = null;
          }
          else{
            if(quantum == 0){   
              procesoCPU!.bloqueado = true;
              cola.add(procesoCPU!);
              procesoCPU = null;
            }
          }
        }
        
      if(procesoCPU == null){
        if(cola.isNotEmpty){
          procesoCPU = cola.first;
          cola.removeAt(0);
          quantum = quantumMax;

          if(procesoCPU!.bloqueado){
            procesoCPU!.bloqueado = false;

            for(var p in administrador){
              if(p.bloqueado){
                p.bloqueado = false;
              }
            }
          }
        }
      }
    }
  }
}