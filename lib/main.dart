import 'package:flutter/material.dart';
import 'package:job_application_manager/form.dart';
import 'package:job_application_manager/job_detail_dialog.dart';
import 'package:job_application_manager/jobtile.dart';
import 'package:job_application_manager/theme.dart';

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
      theme: deepBurgundyTheme,
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

  void _showJobDetail(Job job) {
    showDialog(
      context: context,
      builder: (_) => JobDetailDialog(
        job: job,
        onDeleted: _fetchJobs, // refresh after delete
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.secondary,
        title: Text(widget.title),
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(4),
        itemCount: _jobs.length,
        gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: 300, // <-- maximum tile width
          mainAxisSpacing: 4,
          crossAxisSpacing: 4,
          childAspectRatio: 1.5, // keep tiles roughly square
        ),
        itemBuilder: (_, idx) {
          final job = _jobs[idx];
          return JobTile(job: job, onTap: () => _showJobDetail(job));
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddJobDialog(context),
        tooltip: 'Add Job',
        child: const Icon(Icons.add),
      ),
    );
  }
}
