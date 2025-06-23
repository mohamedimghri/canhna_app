import 'package:flutter/material.dart';

class DashboardGuide extends StatefulWidget {
  const DashboardGuide({super.key});

  @override
  State<DashboardGuide> createState() => _DashboardGuideState();
}

class _DashboardGuideState extends State<DashboardGuide> {
  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      appBar: AppBar(
        title:Text("Guide")
      ) ,
    );
  }
}