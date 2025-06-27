import 'package:canhna_app/services/auth/auth_gate.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  await Supabase.initialize(
    anonKey:"eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im9uc3V0a2dvdmRrcHJha21oY2ZtIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDk0NzI2MzIsImV4cCI6MjA2NTA0ODYzMn0.1y954crnGrChPECjQ58j0HVxN-YTVg6MiDZrF4WFmFc",
    url: "https://onsutkgovdkprakmhcfm.supabase.co",
  );


  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(fontFamily: 'Poppins'),
      home: AuthGate(),
    );
  }
}
