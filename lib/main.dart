import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'Home.dart';

void main() async{
  await Supabase.initialize(
    url: 'https://vtlnqaahmvsphumucwrh.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InZ0bG5xYWFobXZzcGh1bXVjd3JoIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDI5Nzc2NjQsImV4cCI6MjA1ODU1MzY2NH0.gzWpIRzIRReyQoX3jJNdKCxlFc-vdEGUJmHHH8PpIE8',
  );


  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: '3Frame',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: HomePage(),
    );
  }

}

