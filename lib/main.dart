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
      title: 'Job Application Manager',
      theme: deepBurgundyTheme,
      home: const MyHomePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<Job> _jobs = [];
  List<Job> _allJobs = [];
  // NEW: current filter & sort settings
  String _filterBy = 'id'; // id | companyName | dateApplied
  bool _descending = true; // false → ascending, true → descending

  final List<String> _selectedStatuses = ['InProgress', 'Completed'];
  final List<String> _allStatuses = [
    'InProgress',
    'Completed',
    'Rejected',
    'Ghosted',
  ];

  @override
  initState() {
    super.initState();
    _loadJobs();
  }

  Future<void> _loadJobs() async {
    final jobs = await DatabaseHelper.instance.queryJobsByFilter(
      orderBy: _filterBy,
      descending: _descending,
      statuses: _selectedStatuses,
    );
    setState(() => _jobs = jobs);
    final allJobs = await DatabaseHelper.instance.queryJobsByFilter(
      orderBy: _filterBy,
      descending: _descending,
      statuses: ['InProgress', 'Completed', 'Rejected', 'Ghosted'],
    );
    setState(() => _allJobs = allJobs);
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

  void _toggleStatus(String status) {
    setState(() {
      if (_selectedStatuses.contains(status)) {
        _selectedStatuses.remove(status);
      } else {
        _selectedStatuses.add(status);
      }
    });
    _loadJobs(); // re‑query with the new status list
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.secondary,
        title: Text('Job Application Manager | ${_allJobs.length} Jobs Added'),
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
          ),
          PopupMenuButton<int>(
            icon: const Icon(Icons.event_note,
                color: Colors.white), // looks like a “status” icon
            itemBuilder: (context) {
              return _allStatuses.asMap().entries.map((entry) {
                final int idx = entry.key;
                final String status = entry.value;
                final bool isSelected = _selectedStatuses.contains(status);

                return PopupMenuItem<int>(
                  value: idx,
                  child: Row(
                    children: [
                      Checkbox(
                        value: isSelected,
                        onChanged: (_) =>
                            _toggleStatus(status), // defined below
                      ),
                      Text(status),
                    ],
                  ),
                );
              }).toList();
            },
            onSelected: (_) {}, // actual work is done in _toggleStatus
          ),
        ],
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(4),
        itemCount: _jobs.length,
        gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: 350,
          mainAxisSpacing: 4,
          crossAxisSpacing: 4,
          childAspectRatio: 1.5,
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
