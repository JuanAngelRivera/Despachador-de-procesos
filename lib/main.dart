import 'dart:math';
import 'package:despachador_procesos/algoritmos/Algoritmo.dart';
import 'package:despachador_procesos/algoritmos/FIFO.dart';
import 'package:despachador_procesos/algoritmos/LIFO.dart';
import 'package:despachador_procesos/algoritmos/LJF.dart';
import 'package:despachador_procesos/algoritmos/Proceso.dart';
import 'package:despachador_procesos/algoritmos/RoundRobin.dart';
import 'package:despachador_procesos/algoritmos/RoundRobinLIFO.dart';
import 'package:despachador_procesos/algoritmos/SJF.dart';
import 'package:despachador_procesos/utils/Estilos.dart';
import 'package:flutter/material.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Despachador de procesos',
      theme: ThemeData(useMaterial3: true),
      home: const DispatcherTable(),
    );
  }
}

class DispatcherTable extends StatefulWidget {
  const DispatcherTable({super.key});
  @override
  _DispatcherTableState createState() => _DispatcherTableState();
}

class _DispatcherTableState extends State<DispatcherTable> {
  List<Proceso> procesos = [];
  int algoritmoSeleccionado = 0; //0 = FIFO, 1 = LIFO, 2 = SJF, 3 = LJF, 4 = Round Robin
  bool iniciado = false;
  int _nextPid = 1;
  Algoritmo? algoritmo;
  final Random _random = Random();

  void _agregarProceso() {
    setState(() {
      procesos.add(
        Proceso(
          pid: _nextPid,
          duracion: _random.nextInt(10) + 1,
          llegada: _random.nextInt(10) + 1,
          bytes: _random.nextInt(256) + 1
        ),
      );
      _nextPid++;
    });
  }

List<String> determinarEstado(int pid){
  Proceso? proceso = algoritmo!.cola.singleWhere((p) => p.pid == pid, orElse: () => 
  Proceso(pid: -1, duracion: -1, llegada: -1, bytes: -1));
  if(proceso.bloqueado){
    return ["Bloqueado", "Memoria"];
  }

  if(algoritmo!.procesoCPU != null && algoritmo!.procesoCPU!.pid == pid){
    return ["En ejecucion", "CPU"];
  }
  if(algoritmo!.salida.any((p) => p.pid == pid)){
    return ["Finalizado", "Salida"];
  }
  return ["En espera", "Memoria"];
}      

  @override
  void initState(){
    super.initState();
    algoritmo = FIFO();
  }
  
  @override
  Widget build(BuildContext context) {
    
    return Scaffold(
      backgroundColor: Colors.grey.shade900,
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            IntrinsicHeight(  
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    decoration: Estilos.temaContainers.copyWith(color: Color.fromARGB(255, 235, 24, 137)),
                    padding: const EdgeInsets.all(8),
                    child: Center(  
                      child: Text("Despachador de procesos", textAlign: TextAlign.center, style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                      ),),
                    ),
                  ),
              
                  // Boton añadir
                  Container(
                    decoration: Estilos.temaContainers,
                    padding: const EdgeInsets.all(4),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        Text("Añadir proceso", style: Estilos.titulo,),
                        const SizedBox(height: 6),
                        ElevatedButton(
                          onPressed: iniciado == true ? null : _agregarProceso,
                          style: Estilos.botones,
                          child: const Text("Añadir"),
                        ),
                      ],
                    ),
                  ),
              
                  // Algoritmos
                  Container(
                    decoration: Estilos.temaContainers,
                    padding: const EdgeInsets.all(4),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text("Algoritmos", style: Estilos.titulo,),
                        const SizedBox(height: 6),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            ElevatedButton(
                              onPressed: algoritmoSeleccionado == 0 ? null : (){
                                if(iniciado) return;
                                setState((){algoritmoSeleccionado = 0;});}, 
                              style: Estilos.botones,
                              child: const Text("FIFO")
                            ),
                            const SizedBox(width: 8),
                            ElevatedButton(
                              onPressed: algoritmoSeleccionado == 1 ? null : (){
                                if(iniciado) return;
                                setState((){algoritmoSeleccionado = 1;});},
                              style: Estilos.botones,
                              child: const Text("LIFO")),
                            const SizedBox(width: 8),
                            ElevatedButton(
                              onPressed: algoritmoSeleccionado == 2 ? null : (){
                                if(iniciado) return;
                                setState((){algoritmoSeleccionado = 2;});},
                              style: Estilos.botones,
                              child: const Text("SJF")),
                            const SizedBox(width: 8),
                            ElevatedButton(
                              onPressed: algoritmoSeleccionado == 3 ? null : (){
                                if(iniciado) return;
                                setState((){algoritmoSeleccionado = 3;});},
                              style: Estilos.botones,
                              child: const Text("LSF")),
                            const SizedBox(width: 8),
                            ElevatedButton(
                              onPressed: algoritmoSeleccionado == 4 ? null : (){
                                if(iniciado) return;
                                setState((){algoritmoSeleccionado = 4;});},
                              style: Estilos.botones,
                              child: const Text("Round Robin\nFIFO", textAlign: TextAlign.center,)),
                            const SizedBox(width: 8),
                            ElevatedButton(
                              onPressed: algoritmoSeleccionado == 5 ? null : (){
                                if(iniciado) return;
                                setState((){algoritmoSeleccionado = 5;});},
                              style: Estilos.botones,
                              child: const Text("Round Robin\nLIFO", textAlign: TextAlign.center,)),
                          ],
                        ),
                      ],
                    ),
                  ),
              
                  // Timer
                  Container(
                    decoration: Estilos.temaContainers,
                    padding: const EdgeInsets.all(4),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text("Timer", style: Estilos.titulo,),
                            const SizedBox(height: 6),
                            Text(algoritmo?.tiempo.toString() ?? "0"),
                            algoritmoSeleccionado == 4 || algoritmoSeleccionado == 5 ? Text("Quantum: ${algoritmo!.quantum}") : SizedBox(),
                          ],
                        ),
                        algoritmoSeleccionado == 4 || algoritmoSeleccionado == 5 ? Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            ElevatedButton(
                              style: Estilos.botones,
                              onPressed: iniciado ? null : (){
                                setState(() {
                                  if(algoritmo!.quantumMax > 0){
                                    algoritmo!.quantumMax--;
                                    algoritmo!.quantum = algoritmo!.quantumMax;
                                    }});
                              }, 
                              child: Text("-")),
                            SizedBox(height: 8,),
                            ElevatedButton(
                              style: Estilos.botones,
                              onPressed: iniciado ? null : (){
                                setState(() {
                                  algoritmo!.quantumMax++;
                                  algoritmo!.quantum = algoritmo!.quantumMax;
                                });
                              }, 
                              child: Text("+"))
                          ],
                        ) : SizedBox()
                      ]
                    ),
                  ),
              
                  // Controles
                  Container(
                    decoration: Estilos.temaContainers,
                    padding: const EdgeInsets.all(4),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text("Controles", style: Estilos.titulo,),
                        const SizedBox(height: 6),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            ElevatedButton(
                              onPressed: () {
                                if(procesos.isEmpty) {
                                  showDialog(context: context, builder: (BuildContext context) => AlertDialog(
                                    content: Text("Añade almenos un proceso"), 
                                    backgroundColor: Colors.white, 
                                    actions: [
                                      ElevatedButton(onPressed: (){Navigator.of(context).pop();}, child: Text("OK"))
                                  ],));
                                  return;
                                  }
                                if(algoritmo!.quantumMax <= 0 && (algoritmoSeleccionado == 4 || algoritmoSeleccionado == 5)) {
                                  showDialog(context: context, builder: (BuildContext context) => AlertDialog(
                                    content: Text("Pon almenos 1 de quantum"), 
                                    backgroundColor: Colors.white, 
                                    actions: [
                                      ElevatedButton(onPressed: (){Navigator.of(context).pop();}, child: Text("OK"))
                                  ],));
                                  return;
                                  }
                                if(algoritmo!.tiempo == 0 && algoritmo!.procesosFaltantes == 0)
                                {
                                  int aux = algoritmo!.quantumMax;
                                  print("PRIMERA ITERACION -> CREANDO CLASE");
                                  switch (algoritmoSeleccionado){
                                    case 0:
                                      algoritmo = FIFO();
                                      print("FIFO SELECCIONADO");
                                      break;
                                    case 1:
                                      algoritmo = LIFO();
                                      print("LIFO SELECCIONADO");
                                      break;
                                    case 2:
                                      algoritmo = SJF();
                                      print("SJF SELECCIONADO");
                                      break;
                                    case 3:
                                      algoritmo = LJF();
                                      print("LJF SELECCIONANDO");
                                      break;
                                    case 4:
                                      algoritmo = RoundRobin();
                                      print("ROUND ROBIN SELECCIONADO");
                                      algoritmo!.quantumMax = aux;
                                      break;
                                    case 5:
                                      algoritmo = RoundRobinLIFO();
                                      print("ROUND ROBIN LIFO SELECCIONADO");
                                      algoritmo!.quantumMax = aux;
                                      break;
                                  }
              
                                  algoritmo!.cargarProcesos(procesos);
                                  iniciado = true;
                                  print("PROCESOS CARGADOS");
                                }
                                algoritmo!.tick();
                                setState(() {});
                              },
                              style: Estilos.botones, 
                              child: const Text("Siguiente")),
                            const SizedBox(width: 8),
                            ElevatedButton(
                              onPressed: () {
                                setState(() {
                                  iniciado = false;
                                  algoritmo!.reset();
                                });
                              }, 
                              style: Estilos.botones,
                              child: const Text("Cancelar")),
                            const SizedBox(width: 8),
                            ElevatedButton(
                              onPressed: () {
                              setState(() {
                                procesos.clear();
                                _nextPid = 1;
                                algoritmo!.reset();
                                iniciado = false;
                              });
                            }, 
                            style: Estilos.botones,
                            child: const Text("Borrar todo")),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 30),
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  //Tabla procesos
                  Expanded(
                    flex: 2,
                    child: Container(
                      decoration: Estilos.temaContainers,
                      padding: const EdgeInsets.all(8),
                      child: Column(
                        children: [
                          Text("Procesos", style: Estilos.titulo),
                          const SizedBox(height: 8),
                          Expanded(
                            child: SingleChildScrollView(
                              scrollDirection: Axis.vertical,
                              child: DataTable(
                                headingRowColor: WidgetStatePropertyAll(Colors.black),
                                headingTextStyle: Estilos.tituloTabla,
                                border: TableBorder.all(color: Colors.black),
                                columns: const [
                                  DataColumn(label: Text("PID")),
                                  DataColumn(label: Text("Llegada")),
                                  DataColumn(label: Text("Duración")),
                                ],
                                rows: procesos.map((p) {
                                  return DataRow(
                                    color: WidgetStatePropertyAll(Colors.white),
                                    cells: [
                                    DataCell(Text(p.pid.toString())),
                                    DataCell(Text(p.llegada.toString())),
                                    DataCell(Text(p.duracion.toString())),
                                  ]);
                                }).toList(),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(width: 16),

                  //Tabla central
                  Expanded(
                    flex: 2,
                    child: Container(
                      decoration: Estilos.temaContainers,
                      padding: const EdgeInsets.all(8),
                      child: Column(
                        children: [
                          Text("Tabla de estado de procesos", style: Estilos.titulo,),
                          const SizedBox(height: 8),
                          Expanded(
                            child: SingleChildScrollView(
                              scrollDirection: Axis.vertical,
                              child: DataTable(
                                headingRowColor: WidgetStatePropertyAll(Colors.black),
                                headingTextStyle: Estilos.tituloTabla,
                                border: TableBorder.all(color: Colors.black),

                                columns: [
                                  const DataColumn(label: Text("PID")),
                                  const DataColumn(label: Text("Estado")),
                                  const DataColumn(label: Text("Ubicación")),
                                  DataColumn(label: Text(algoritmoSeleccionado == 4 || algoritmoSeleccionado == 5 ? "Remain" : "Duración")),
                                ],
                                rows: 
                                  algoritmo!.administrador.map((p) {
                                    Color color;
                                    switch (determinarEstado(p.pid)[0]) {
                                      case "En ejecucion":
                                        color = Colors.green.shade100;
                                        break;
                                      case "Finalizado":
                                        color = Colors.grey.shade300;
                                        break;
                                      case "Bloqueado":
                                        color = Colors.red.shade100;
                                        break;
                                      case "En espera":
                                        color = Colors.blue.shade100;
                                        break;
                                      default:
                                        color = Colors.white;
                                    }

                                    return DataRow(
                                      color: WidgetStateProperty.resolveWith((_) => color),
                                      cells: [
                                        DataCell(Text(p.pid.toString())),
                                        DataCell(Text(determinarEstado(p.pid)[0])),
                                        DataCell(Text(determinarEstado(p.pid)[1])),
                                        DataCell(Text(p.duracion.toString())),
                                      ],
                                    );
                                  }).toList(),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(width: 16),

                  // CPU
                  Expanded(
                    flex: 1,
                    child: Container(
                      decoration: Estilos.temaContainers,
                      padding: const EdgeInsets.fromLTRB(8, 16, 8, 8),
                      child: Column(
                        children: [
                          DataTable(
                            headingRowColor: WidgetStatePropertyAll(Colors.black),
                            headingTextStyle: Estilos.tituloTabla,
                            border: TableBorder.all(color: Colors.black),
                            columns: const [DataColumn(label: Text("CPU"))],
                            rows: [DataRow(
                              color: WidgetStatePropertyAll(Colors.white),
                              cells: [
                                DataCell(
                                  Text(
                                    algoritmo!.procesoCPU?.pid.toString() ?? "--", 
                                    textAlign: TextAlign.center,
                                    ))
                                  ])
                                ],
                          ),
                          const Divider(height: 20, color: Colors.black,),
                          Expanded(
                            child: SingleChildScrollView(
                              scrollDirection: Axis.vertical,
                              child: DataTable(
                                headingRowColor: WidgetStatePropertyAll(Colors.black),
                                headingTextStyle: Estilos.tituloTabla,
                                border: TableBorder.all(color: Colors.black),
                                columns: const [DataColumn(label: Text("Memoria"))],
                                rows: algoritmo!.cola.map((p) => 
                                DataRow(
                                  color: WidgetStatePropertyAll(Colors.white),
                                  cells: [
                                  DataCell(Text(p.pid.toString()))
                                ])).toList(),
                            ),
                            ),
                          )
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(width: 16),

                  // Salida
                  Expanded(
                    flex: 1,
                    child: Container(
                      decoration: Estilos.temaContainers,
                      padding: const EdgeInsets.all(8),
                      child: Column(
                        children: [
                          Expanded(
                            child: SingleChildScrollView(
                              scrollDirection: Axis.vertical,
                              child: DataTable(
                              headingRowColor: WidgetStatePropertyAll(Colors.black),
                              headingTextStyle: Estilos.tituloTabla,
                              border: TableBorder.all(color: Colors.black),
                              columns: const [DataColumn(label: Text("Salida"))],
                              rows: algoritmo!.salida.map((p) => 
                                DataRow(
                                  color: WidgetStatePropertyAll(Colors.white),
                                  cells: [
                                  DataCell(Text(p.pid.toString())),
                              ])).toList()),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}