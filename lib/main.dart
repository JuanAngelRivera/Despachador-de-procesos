import 'dart:math';
import 'package:despachador_procesos/algoritmos/Algoritmo.dart';
import 'package:despachador_procesos/algoritmos/FIFO.dart';
import 'package:despachador_procesos/algoritmos/LIFO.dart';
import 'package:despachador_procesos/algoritmos/LJF.dart';
import 'package:despachador_procesos/algoritmos/clases.dart';
import 'package:despachador_procesos/algoritmos/RoundRobin.dart';
import 'package:despachador_procesos/algoritmos/RoundRobinLIFO.dart';
import 'package:despachador_procesos/algoritmos/SJF.dart';
import 'package:despachador_procesos/utils/Estilos.dart';
import 'package:despachador_procesos/utils/FileManager.dart';
import 'package:despachador_procesos/utils/ToolBarDelegateWidget.dart';
import 'package:despachador_procesos/utils/cpu_widget.dart';
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
  int algoritmoSeleccionado =
      0; //0 = FIFO, 1 = LIFO, 2 = SJF, 3 = LJF, 4 = Round Robin
  bool iniciado = false;
  int _nextPid = 1;
  Algoritmo? algoritmo;
  final Random _random = Random();
  late FileManager fileManager;
  late List<String> preview = [];

  void _agregarProceso() {
    setState(() {
      procesos.add(
        Proceso(
          pid: _nextPid,
          duracion: _random.nextInt(10) + 1,
          llegada: _random.nextInt(10) + 2,
          bytes: _random.nextInt(56) + 200,
        ),
      );
      _nextPid++;
    });
  }

  List<String> determinarEstado(int pid) {
  if (algoritmo!.salida.any((p) => p.pid == pid)) {
    return ["Finalizado", "Salida"];
  }

  if (algoritmo!.procesoCPU?.pid == pid) {
    return ["En ejecucion", "CPU"];
  }

  if (algoritmo!.cola.any((p) => p.pid == pid)) {
    return ["En espera", "Memoria"];
  }

  if (algoritmo!.swapping.any((p) => p.pid == pid)) {
    return ["En espera", "Swapping"];
  }

  bool enMemoria = algoritmo!.tablaPaginas.any(
    (pagina) => pagina.marcos.any((m) => m.pid == pid),
  );

  if (enMemoria) {
    return ["En espera", "Memoria"];
  }

  return ["Finalizado", "Salida"];
}

  @override
  void initState() {
    super.initState();
    algoritmo = FIFO();
  }

  @override
  Widget build(BuildContext context) {
    final barraSimulador = Container(
      height: 110,
      padding: EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        border: Border(bottom: BorderSide(color: Colors.white, width: 1)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            decoration: Estilos.temaContainers.copyWith(color: Estilos.rosa),
            padding: const EdgeInsets.all(8),
            width: 200,
            child: Center(
              child: Text(
                "Despachador de procesos",
                textAlign: TextAlign.center,
                softWrap: true,
                overflow: TextOverflow.visible,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
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
                Text("Añadir proceso", style: Estilos.titulo),
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
                Text("Algoritmos", style: Estilos.titulo),
                const SizedBox(height: 6),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ElevatedButton(
                      onPressed: algoritmoSeleccionado == 0
                          ? null
                          : () {
                              if (iniciado) return;
                              setState(() {
                                algoritmoSeleccionado = 0;
                              });
                            },
                      style: Estilos.botones,
                      child: const Text("FIFO"),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: algoritmoSeleccionado == 1
                          ? null
                          : () {
                              if (iniciado) return;
                              setState(() {
                                algoritmoSeleccionado = 1;
                              });
                            },
                      style: Estilos.botones,
                      child: const Text("LIFO"),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: algoritmoSeleccionado == 2
                          ? null
                          : () {
                              if (iniciado) return;
                              setState(() {
                                algoritmoSeleccionado = 2;
                              });
                            },
                      style: Estilos.botones,
                      child: const Text("SJF"),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: algoritmoSeleccionado == 3
                          ? null
                          : () {
                              if (iniciado) return;
                              setState(() {
                                algoritmoSeleccionado = 3;
                              });
                            },
                      style: Estilos.botones,
                      child: const Text("LSF"),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: algoritmoSeleccionado == 4
                          ? null
                          : () {
                              if (iniciado) return;
                              setState(() {
                                algoritmoSeleccionado = 4;
                              });
                            },
                      style: Estilos.botones,
                      child: const Text(
                        "Round Robin\nFIFO",
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: algoritmoSeleccionado == 5
                          ? null
                          : () {
                              if (iniciado) return;
                              setState(() {
                                algoritmoSeleccionado = 5;
                              });
                            },
                      style: Estilos.botones,
                      child: const Text(
                        "Round Robin\nLIFO",
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Timer
          Container(
            decoration: Estilos.temaContainers,
            padding: const EdgeInsets.all(8),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("Timer", style: Estilos.titulo),
                    const SizedBox(height: 6),
                    Text(algoritmo?.tiempo.toString() ?? "0"),
                    algoritmoSeleccionado == 4 || algoritmoSeleccionado == 5
                        ? Text("Quantum: ${algoritmo!.quantum}")
                        : SizedBox(),
                  ],
                ),
                algoritmoSeleccionado == 4 || algoritmoSeleccionado == 5
                    ? Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          ElevatedButton(
                            style: Estilos.botones,
                            onPressed: iniciado
                                ? null
                                : () {
                                    setState(() {
                                      if (algoritmo!.quantumMax > 0) {
                                        algoritmo!.quantumMax--;
                                        algoritmo!.quantum =
                                            algoritmo!.quantumMax;
                                      }
                                    });
                                  },
                            child: Text("-"),
                          ),
                          SizedBox(height: 8),
                          ElevatedButton(
                            style: Estilos.botones,
                            onPressed: iniciado
                                ? null
                                : () {
                                    setState(() {
                                      algoritmo!.quantumMax++;
                                      algoritmo!.quantum =
                                          algoritmo!.quantumMax;
                                    });
                                  },
                            child: Text("+"),
                          ),
                        ],
                      )
                    : SizedBox(),
              ],
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
                Text("Controles", style: Estilos.titulo),
                const SizedBox(height: 6),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        if (procesos.isEmpty) {
                          showDialog(
                            context: context,
                            builder: (BuildContext context) => AlertDialog(
                              content: Text("Añade almenos un proceso"),
                              backgroundColor: Colors.white,
                              actions: [
                                ElevatedButton(
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                  style: Estilos.botones,
                                  child: Text("OK"),
                                ),
                              ],
                            ),
                          );
                          return;
                        }
                        if (algoritmo!.quantumMax <= 0 &&
                            (algoritmoSeleccionado == 4 ||
                                algoritmoSeleccionado == 5)) {
                          showDialog(
                            context: context,
                            builder: (BuildContext context) => AlertDialog(
                              content: Text("Pon almenos 1 de quantum"),
                              backgroundColor: Colors.white,
                              actions: [
                                ElevatedButton(
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                  child: Text("OK"),
                                ),
                              ],
                            ),
                          );
                          return;
                        }
                        if (algoritmo!.tiempo == 0 &&
                            algoritmo!.procesosFaltantes == 0) {
                          int aux = algoritmo!.quantumMax;
                          switch (algoritmoSeleccionado) {
                            case 0:
                              algoritmo = FIFO();
                              break;
                            case 1:
                              algoritmo = LIFO();
                              break;
                            case 2:
                              algoritmo = SJF();
                              break;
                            case 3:
                              algoritmo = LJF();
                              break;
                            case 4:
                              algoritmo = RoundRobin();
                              algoritmo!.quantumMax = aux;
                              break;
                            case 5:
                              algoritmo = RoundRobinLIFO();
                              algoritmo!.quantumMax = aux;
                              break;
                          }

                          algoritmo!.cargarProcesos(procesos);
                          iniciado = true;
                        }
                        algoritmo!.tick();
                        setState(() {
                          preview = algoritmo!.previewTick();
                        });
                      },
                      style: Estilos.botones,
                      child: const Text("Siguiente"),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          iniciado = false;
                          algoritmo!.reset();
                        });
                      },
                      style: Estilos.botones,
                      child: const Text("Cancelar"),
                    ),
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
                      child: const Text("Borrar todo"),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );

    return Scaffold(
      backgroundColor: Colors.grey.shade900,
      body: CustomScrollView(
        slivers: [
          SliverPersistentHeader(
            pinned: true,
            delegate: ToolbarDelegate(barraSimulador),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  SizedBox(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Column(
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // tabla de procesos
                                SizedBox(
                                  width:
                                      MediaQuery.of(context).size.width * 0.3,
                                  child: Container(
                                    decoration: Estilos.temaContainers,
                                    padding: const EdgeInsets.all(8),
                                    child: Column(
                                      children: [
                                        Text("Procesos", style: Estilos.titulo),
                                        const SizedBox(height: 8),
                                        SizedBox(
                                          child: SingleChildScrollView(
                                            scrollDirection: Axis.vertical,
                                            child: DataTable(
                                              headingRowColor:
                                                  WidgetStatePropertyAll(
                                                    Colors.black,
                                                  ),
                                              headingTextStyle:
                                                  Estilos.tituloTabla,
                                              border: TableBorder.all(
                                                color: Colors.black,
                                              ),
                                              columns: const [
                                                DataColumn(label: Text("PID")),
                                                DataColumn(
                                                  label: Text("Llegada"),
                                                ),
                                                DataColumn(
                                                  label: Text("Duración"),
                                                ),
                                                DataColumn(
                                                  label: Text("Tamaño"),
                                                ),
                                              ],
                                              rows: procesos.map((p) {
                                                return DataRow(
                                                  color: WidgetStatePropertyAll(
                                                    Colors.white,
                                                  ),
                                                  cells: [
                                                    DataCell(
                                                      Text(p.pid.toString()),
                                                    ),
                                                    DataCell(
                                                      Text(
                                                        p.llegada.toString(),
                                                      ),
                                                    ),
                                                    DataCell(
                                                      Text(
                                                        p.duracion.toString(),
                                                      ),
                                                    ),
                                                    DataCell(
                                                      Text(
                                                        "${p.bytes.toString()} bytes",
                                                      ),
                                                    ),
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

                                SizedBox(
                                  width:
                                      MediaQuery.of(context).size.width * 0.05,
                                ),

                                //Tabla central
                                SizedBox(
                                  width:
                                      MediaQuery.of(context).size.width * 0.3,
                                  child: Container(
                                    decoration: Estilos.temaContainers,
                                    padding: const EdgeInsets.all(8),
                                    child: Column(
                                      children: [
                                        Text(
                                          "Tabla de estado de procesos",
                                          style: Estilos.titulo,
                                        ),
                                        const SizedBox(height: 8),
                                        SizedBox(
                                          child: SingleChildScrollView(
                                            scrollDirection: Axis.vertical,
                                            child: DataTable(
                                              headingRowColor:
                                                  WidgetStatePropertyAll(
                                                    Colors.black,
                                                  ),
                                              headingTextStyle:
                                                  Estilos.tituloTabla,
                                              border: TableBorder.all(
                                                color: Colors.black,
                                              ),

                                              columns: [
                                                const DataColumn(
                                                  label: Text("PID"),
                                                ),
                                                const DataColumn(
                                                  label: Text("Estado"),
                                                ),
                                                const DataColumn(
                                                  label: Text("Ubicación"),
                                                ),
                                                DataColumn(
                                                  label: Text(
                                                    algoritmoSeleccionado ==
                                                                4 ||
                                                            algoritmoSeleccionado ==
                                                                5
                                                        ? "Remain"
                                                        : "Duración",
                                                  ),
                                                ),
                                              ],
                                              rows: algoritmo!.administrador.map((
                                                p,
                                              ) {
                                                Color color;
                                                switch (determinarEstado(
                                                  p.pid,
                                                )[0]) {
                                                  case "En ejecucion":
                                                    color =
                                                        Colors.green.shade100;
                                                    break;
                                                  case "Finalizado":
                                                    color =
                                                        Colors.grey.shade300;
                                                    break;
                                                  case "Bloqueado":
                                                    color = Colors.red.shade100;
                                                    break;
                                                  case "En espera":
                                                    color =
                                                        Colors.blue.shade100;
                                                    break;
                                                  default:
                                                    color = Colors.white;
                                                }

                                                return DataRow(
                                                  color:
                                                      WidgetStateProperty.resolveWith(
                                                        (_) => color,
                                                      ),
                                                  cells: [
                                                    DataCell(
                                                      Text(p.pid.toString()),
                                                    ),
                                                    DataCell(
                                                      Text(
                                                        determinarEstado(
                                                          p.pid,
                                                        )[0],
                                                      ),
                                                    ),
                                                    DataCell(
                                                      Text(
                                                        determinarEstado(
                                                          p.pid,
                                                        )[1],
                                                      ),
                                                    ),
                                                    DataCell(
                                                      Text(
                                                        p.duracion.toString(),
                                                      ),
                                                    ),
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

                                SizedBox(
                                  width:
                                      MediaQuery.of(context).size.width * 0.05,
                                ),
                              ],
                            ),

                            SizedBox(
                              height: MediaQuery.of(context).size.height * 0.05,
                            ),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              spacing: 10,
                              children: [
                                //actualizacion rafaga
                                Container(
                                  decoration: Estilos.temaContainers,
                                  padding: EdgeInsets.all(8),
                                  width: 200,
                                  height: MediaQuery.of(context).size.height * 0.4,
                                  child: preview.isEmpty
                                  ? SizedBox(width: 200,)
                                  : ListView.builder(
                                    itemCount: preview.length,
                                    itemBuilder: (context, index) {
                                      return Text(
                                        "• ${preview[index]}",
                                        style: TextStyle(
                                          color: Colors.black,
                                          fontSize: 14,
                                        ),
                                      );
                                    },
                                  ),
                                ),

                                // tabla particion
                                Container(
                                  padding: EdgeInsets.all(8),
                                  decoration: Estilos.temaContainers,
                                  width:
                                      MediaQuery.of(context).size.width * 0.4,
                                  child: Column(
                                    children: [
                                      Text(
                                        "Tabla de partición estática primer ajuste",
                                        style: Estilos.titulo,
                                        textAlign: TextAlign.center,
                                      ),
                                      DataTable(
                                        dataRowMaxHeight: 30,
                                        dataRowMinHeight: 20,
                                        headingRowColor: WidgetStatePropertyAll(
                                          Colors.black,
                                        ),
                                        headingTextStyle: Estilos.tituloTabla,
                                        border: TableBorder.all(
                                          color: Colors.black,
                                        ),
                                        columns: [
                                          const DataColumn(
                                            label: Text("Página"),
                                          ),
                                          const DataColumn(
                                            label: Text("Marco"),
                                          ),
                                          const DataColumn(
                                            label: Text("Proceso"),
                                          ),
                                          const DataColumn(
                                            label: Text("Ocupado"),
                                          ),
                                          const DataColumn(
                                            label: Text("Libre"),
                                          ),
                                        ],
                                        rows: algoritmo!.tablaPaginas.expand((
                                          pagina,
                                        ) {
                                          return pagina.marcos.map((marco) {
                                            Color color = Colors.grey.shade300;
                                            if (marco.bytesOcupados != 0)
                                              color = Colors.white;
                                            if (algoritmo!.cola.isNotEmpty) {
                                              if (marco.pid ==
                                                  algoritmo!.cola.first.pid)
                                                color = Colors.blue.shade100;
                                            }
                                            return DataRow(
                                              color:
                                                  WidgetStateColor.resolveWith(
                                                    (_) => color,
                                                  ),
                                              cells: [
                                                DataCell(
                                                  Text(
                                                    (pagina.pagina + 1)
                                                        .toString(),
                                                  ),
                                                ),
                                                DataCell(
                                                  Text(
                                                    (marco.marco + 1)
                                                        .toString(),
                                                  ),
                                                ),
                                                DataCell(
                                                  Text(
                                                    marco.pid == -1
                                                        ? "--"
                                                        : marco.pid.toString(),
                                                  ),
                                                ),
                                                DataCell(
                                                  Text(
                                                    marco.bytesOcupados
                                                        .toString(),
                                                  ),
                                                ),
                                                DataCell(
                                                  Text(
                                                    marco.bytesLibres
                                                        .toString(),
                                                  ),
                                                ),
                                              ],
                                            );
                                          });
                                        }).toList(),
                                      ),
                                    ],
                                  ),
                                ),

                                Column(
                                  spacing: 10,
                                  children: [
                                    //siguiente Proceso
                                    Container(
                                      padding: EdgeInsets.all(8),
                                      decoration: Estilos.temaContainers,
                                      width:
                                          MediaQuery.of(context).size.width *
                                          0.1,
                                      child: DataTable(
                                        headingRowColor: WidgetStatePropertyAll(
                                          Colors.black,
                                        ),
                                        headingTextStyle: Estilos.tituloTabla,
                                        border: TableBorder.all(
                                          color: Colors.black,
                                        ),
                                        columns: [
                                          const DataColumn(
                                            label: Text(
                                              "Siguiente",
                                              softWrap: true,
                                              maxLines: 3,
                                              overflow: TextOverflow.visible,
                                            ),
                                          ),
                                        ],
                                        rows: [
                                          DataRow(
                                            color: WidgetStatePropertyAll(Colors.white),
                                            cells: [
                                              DataCell(
                                                Text(
                                                  algoritmo!.cola.isNotEmpty
                                                      ? algoritmo!
                                                            .cola
                                                            .first
                                                            .pid
                                                            .toString()
                                                      : "--",
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),

                                    //swapping
                                    Container(
                                      padding: EdgeInsets.all(8),
                                      decoration: Estilos.temaContainers,
                                      width:
                                          MediaQuery.of(context).size.width *
                                          0.1,
                                      child: DataTable(
                                        headingRowColor: WidgetStatePropertyAll(
                                          Colors.black,
                                        ),
                                        headingTextStyle: Estilos.tituloTabla,
                                        border: TableBorder.all(
                                          color: Colors.black,
                                        ),
                                        columns: [
                                          const DataColumn(
                                            label: Text("Swapping"),
                                          ),
                                        ],
                                        rows: algoritmo!.swapping
                                            .map(
                                              (row) => DataRow(
                                                color: WidgetStatePropertyAll(
                                                  Colors.white,
                                                ),
                                                cells: [
                                                  DataCell(
                                                    Text(row.pid.toString()),
                                                  ),
                                                ],
                                              ),
                                            )
                                            .toList(),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),

                        SizedBox(
                          width: MediaQuery.of(context).size.width * 0.1,
                          child: Container(
                            decoration: Estilos.temaContainers,
                            padding: const EdgeInsets.fromLTRB(8, 16, 8, 8),
                            child: Column(
                              children: [
                                //cpu
                                Container(
                                  padding: EdgeInsets.all(8),
                                  child: CpuWidget(
                                    cpu: algoritmo!.procesoCPU)),

                                const Divider(height: 20, color: Colors.black),

                                // Salida
                                SizedBox(
                                  child: Container(
                                    decoration: Estilos.temaContainers,
                                    padding: const EdgeInsets.all(8),
                                    child: Column(
                                      children: [
                                        SizedBox(
                                          child: SingleChildScrollView(
                                            scrollDirection: Axis.vertical,
                                            child: DataTable(
                                              headingRowColor:
                                                  WidgetStatePropertyAll(
                                                    Colors.black,
                                                  ),
                                              headingTextStyle:
                                                  Estilos.tituloTabla,
                                              border: TableBorder.all(
                                                color: Colors.black,
                                              ),
                                              columns: const [
                                                DataColumn(
                                                  label: Text("Salida"),
                                                ),
                                              ],
                                              rows: algoritmo!.salida
                                                  .map(
                                                    (p) => DataRow(
                                                      color:
                                                          WidgetStatePropertyAll(
                                                            Colors.white,
                                                          ),
                                                      cells: [
                                                        DataCell(
                                                          Text(
                                                            p.pid.toString(),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  )
                                                  .toList(),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(
                          height: MediaQuery.of(context).size.height * 0.1,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}