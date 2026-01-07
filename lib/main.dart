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
      debugShowCheckedModeBanner: false,
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
  // NEW: current filter & sort settings
  String _filterBy = 'id'; // id | companyName | dateApplied
  bool _descending = false; // false → ascending, true → descending

  @override
  initState() {
    super.initState();
    _loadJobs();
  }

  Future<void> _loadJobs() async {
    final jobs = await DatabaseHelper.instance.queryAllJobsSorted(
      orderBy: _filterBy,
      descending: _descending,
    );
    setState(() => _jobs = jobs);
  }

  // Show the dialog that contains the add‑job form
  void _showAddJobDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AddJobDialog(onFinished: _loadJobs),
    );
  }

  void _showJobDetail(Job job) {
    showDialog(
      context: context,
      builder: (_) => JobDetailDialog(
        job: job,
        onDeleted: _loadJobs, // refresh after delete
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.secondary,
        title: Text(widget.title),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Row(
              children: [
                // ① Sort‑by column selector
                DropdownButton<String>(
                  value: _filterBy,
                  icon: const Icon(Icons.filter_list, color: Colors.white),
                  underline: const SizedBox(),
                  onChanged: (String? newValue) {
                    if (newValue == null) return;
                    setState(() => _filterBy = newValue);
                    _loadJobs(); // refresh list
                  },
                  items: const [
                    DropdownMenuItem(value: 'id', child: Text('ID')),
                    DropdownMenuItem(
                        value: 'companyName', child: Text('Company')),
                    DropdownMenuItem(
                        value: 'dateApplied', child: Text('Date Applied')),
                  ],
                ),
                const SizedBox(width: 12),

                // ② Asc/Desc selector
                DropdownButton<bool>(
                  value: _descending,
                  icon: const Icon(Icons.sort, color: Colors.white),
                  underline: const SizedBox(),
                  onChanged: (bool? desc) {
                    if (desc == null) return;
                    setState(() => _descending = desc);
                    _loadJobs();
                  },
                  items: const [
                    DropdownMenuItem(value: false, child: Text('Asc')),
                    DropdownMenuItem(value: true, child: Text('Desc')),
                  ],
                ),
              ],
            ),
          )
        ],
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
