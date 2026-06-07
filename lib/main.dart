import 'package:flutter/material.dart';
import 'dart:io';
import 'dart:convert';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter + PHP',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _nombreController = TextEditingController();
  final _emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  
  String _respuesta = '';
  bool _cargando = false;
  
  final String phpUrl = 'http://prueba0001.free.je/test.php';

  Future<void> _enviarDatos() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _cargando = true;
      _respuesta = '';
    });

    final client = HttpClient();
    try {
      final url = Uri.parse(phpUrl);
      final request = await client.postUrl(url);
      request.headers.set('Content-Type', 'application/x-www-form-urlencoded');
      
      final body = 'nombre=${Uri.encodeComponent(_nombreController.text)}&email=${Uri.encodeComponent(_emailController.text)}';
      request.write(body);
      
      final response = await request.close();
      final responseBody = await response.transform(utf8.decoder).join();
      
      setState(() {
        _respuesta = responseBody;
      });
    } catch (e) {
      setState(() {
        _respuesta = 'Error: $e';
      });
    } finally {
      client.close();
      setState(() {
        _cargando = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Prueba Flutter + PHP')),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nombreController,
                decoration: const InputDecoration(labelText: 'Nombre'),
                validator: (value) => value == null || value.isEmpty ? 'Requerido' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Email'),
                validator: (value) => value == null || !value.contains('@') ? 'Email válido' : null,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _cargando ? null : _enviarDatos,
                child: Text(_cargando ? 'Enviando...' : 'Enviar'),
              ),
              const SizedBox(height: 24),
              const Text('Respuesta:'),
              Expanded(child: SingleChildScrollView(child: Text(_respuesta))),
            ],
          ),
        ),
      ),
    );
  }
}
