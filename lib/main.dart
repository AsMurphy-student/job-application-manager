import 'package:flutter/material.dart';
import 'package:job_application_manager/form.dart';

import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'database_helper.dart';
import 'job.dart';

// Look into this for SQL
// https://docs.flutter.dev/app-architecture/design-patterns/sql

void main() async {
  databaseFactory = databaseFactoryFfi;
  // Initialize the database and insert users
  WidgetsFlutterBinding.ensureInitialized();
  await DatabaseHelper.instance.initDb();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
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
  List<Job> _jobs = [];

  @override
  initState() {
    super.initState();
    _fetchJobs();
  }

  Future<void> _fetchJobs() async {
    final jobMaps = await DatabaseHelper.instance.queryAllJobs();
    setState(() {
      _jobs = jobMaps.map((jobMap) => Job.fromMap(jobMap)).toList();
    });
  }

  // Show the dialog that contains the add‑job form
  void _showAddJobDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AddJobDialog(onJobAdded: _fetchJobs),
    );
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: ListView.builder(
          itemCount: _jobs.length,
          itemBuilder: (context, index) {
            return ListTile(
              title: Text(_jobs[index].companyName),
              subtitle: Text(_jobs[index].jobTitle),
            );
          }),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddJobDialog(context),
        tooltip: 'Add Job',
        child: const Icon(Icons.add),
      ),
    );
  }
}
