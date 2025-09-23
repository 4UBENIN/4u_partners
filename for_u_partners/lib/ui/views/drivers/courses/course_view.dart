import 'package:flutter/material.dart';

class CourseView extends StatelessWidget {
  const CourseView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nouvelle Course'),
      ),
      body: const Center(
        child: Text('Écran de nouvelle course'),
      ),
    );
  }
}
