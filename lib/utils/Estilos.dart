import 'package:flutter/material.dart';

class Estilos {
  static final BoxDecoration temaContainers = BoxDecoration(
    color: Colors.grey.shade400,
    borderRadius: BorderRadius.circular(10),
  );

  static final TextStyle tituloTabla = TextStyle(
    color: Colors.white,
    fontWeight: FontWeight.w500,
  );

  static final TextStyle titulo = TextStyle(
    fontWeight: FontWeight.bold,
    fontFamily: "Roboto",
    fontSize: 16,
  );

  static final ButtonStyle botones = ButtonStyle(
    alignment: Alignment.center,
    foregroundColor: WidgetStateProperty.resolveWith<Color>((
      Set<WidgetState> states,
    ) {
      if (states.contains(WidgetState.pressed)) {
        return Colors.white;
      } else if (states.contains(WidgetState.disabled)) {
        return Colors.white;
      }
      return Colors.white;
    }),
    backgroundColor: WidgetStateProperty.resolveWith<Color>((
      Set<WidgetState> states,
    ) {
      if (states.contains(WidgetState.pressed)) {
        return Color.fromARGB(255, 235, 24, 137);
      } else if (states.contains(WidgetState.disabled)) {
        return const Color.fromARGB(255, 235, 24, 137);
      }
      return Colors.black;
    }),
  );
}
