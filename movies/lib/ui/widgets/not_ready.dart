import 'package:flutter/material.dart';
import 'package:flutter_application_1/ui/theme/theme.dart';

class NotReady extends StatelessWidget {
  const NotReady({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        color: screenBackground,
        child: const Center(child: CircularProgressIndicator()),
      ),
    );
  }
}
