import 'package:flutter/material.dart';

class ColorDemo extends StatelessWidget {
  const ColorDemo({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = <String, Color>{
      'Colors.red': Colors.red,
      'Color(0xFFC13437)': const Color(0xFFC13437),
      'Color.fromARGB(255, 33, 150, 243)': const Color.fromARGB(255, 33, 150, 243),
      'Color.fromRGBO(76, 175, 80, 1.0)': const Color.fromRGBO(76, 175, 80, 1.0),
      'Colors.grey avec 50% d\'opacité': Colors.grey.withValues(alpha: 0.5),
    };
    return SafeArea(
      child: Column(
        children: colors.entries.map((e) {
          return Container(
            height: 60,
            width: double.infinity,
            color: e.value,
            alignment: Alignment.center,
            child: Text(e.key, style: const TextStyle(color: Colors.black)),
          );
        }).toList(),
      ),
    );
  }
}