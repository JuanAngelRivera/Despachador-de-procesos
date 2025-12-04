import 'package:despachador_procesos/algoritmos/clases.dart';
import 'package:despachador_procesos/utils/Estilos.dart';
import 'package:flutter/material.dart';

class CpuWidget extends StatelessWidget {
  final Proceso? cpu;
  const CpuWidget({super.key, required this.cpu});

  @override
  Widget build(BuildContext context) {
    return DataTable(
      headingRowColor: WidgetStatePropertyAll(Colors.black),
      headingTextStyle: Estilos.tituloTabla,
      border: TableBorder.all(color: Colors.black),
      columns: const [
        DataColumn(
          label: Text("CPU")),
      ],
      rows: [
        DataRow(
          color: WidgetStatePropertyAll(Colors.white),
          cells: [
            DataCell(Text(cpu?.pid.toString() ?? "--")),
          ],
        ),
      ],
    );
  }
}
