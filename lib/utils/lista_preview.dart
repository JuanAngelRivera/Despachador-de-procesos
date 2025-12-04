import 'package:despachador_procesos/algoritmos/clases.dart';
import 'package:flutter/material.dart';

class ListaPreview extends StatefulWidget {
  final List<Proceso>? procesosCola;
  final List<Proceso>? procesosSalida;
  const ListaPreview({
    super.key,
    this.procesosCola,
    this.procesosSalida});

  @override
  State<ListaPreview> createState() => _ListaPreviewState();
}

class _ListaPreviewState extends State<ListaPreview> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: SizedBox(),
    );
  }
}