import 'package:flutter/material.dart';

class TransportScreen extends StatefulWidget {
  const TransportScreen({super.key});

  @override
  State<TransportScreen> createState() => _TransportScreenState();
}

class _TransportScreenState extends State<TransportScreen> {
  @override
  Widget build(BuildContext context) {
   return  Scaffold(
      appBar: AppBar(
        title: Text("transportation"),
      ),
      body: Text("d"),
    );
  }
}