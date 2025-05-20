import 'package:flutter/material.dart';
import 'api_service.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'JSONBin.io Tester',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
      ),
      home: const MyHomePage(title: 'Tester JSONBin.io'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final _nameController = TextEditingController();
  final _binIdController = TextEditingController();
  String _result = '';

  final ApiService apiService = ApiService();

  void _create() async {
    final name = _nameController.text.trim();

    if (name.isEmpty == null) {
      setState(() {
        _result = 'Veuillez remplir correctement tous les champs.';
      });
      return;
    }

    final data = {'nom': name};
    final response = await apiService.create(data, binName: '$name');

    setState(() {
      _result = 'ID : $response';
    });
  }

  void _read() async {
    final binId = _binIdController.text.trim();
    if (binId.isEmpty) {
      setState(() => _result = 'Veuillez entrer un ID de bin.');
      return;
    }
    final response = await apiService.read(binId);
    setState(() => _result = response);
  }

  void _update() async {
    final binId = _binIdController.text.trim();
    final name = _nameController.text.trim();

    if (binId.isEmpty || name.isEmpty == null) {
      setState(() => _result = 'Veuillez remplir tous les champs.');
      return;
    }

    final data = {'nom': name};
    final response = await apiService.update(binId, data);
    setState(() => _result = response);
  }

  void _delete() async {
    final binId = _binIdController.text.trim();
    if (binId.isEmpty) {
      setState(() => _result = 'Veuillez entrer un ID de bin.');
      return;
    }
    final response = await apiService.delete(binId);
    setState(() => _result = response);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: _binIdController,
                decoration: const InputDecoration(labelText: 'ID du Bin'),
              ),
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Nom'),
              ),
              const SizedBox(height: 20),
              Wrap(
                spacing: 8,
                children: [
                  ElevatedButton(
                    onPressed: _create,
                    child: const Text('Créer'),
                  ),
                  ElevatedButton(
                    onPressed: _read,
                    child: const Text('Lire'),
                  ),
                  ElevatedButton(
                    onPressed: _update,
                    child: const Text('Modifier'),
                  ),
                  ElevatedButton(
                    onPressed: _delete,
                    child: const Text('Supprimer'),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Text(
                'Résultat :',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              Text(
                _result,
                style: const TextStyle(fontSize: 16, color: Colors.black87),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
