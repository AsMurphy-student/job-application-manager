import 'package:flutter/material.dart';
import 'package:job_application_manager/database_helper.dart';
import 'package:job_application_manager/job.dart';

/// This Class was generated using GPT OSS
/// And also double checked by myself

/// A dialog that contains a form for adding a new job.
class AddJobDialog extends StatefulWidget {
  final Job? existingJob;
  final VoidCallback onFinished;

  const AddJobDialog({super.key, this.existingJob, required this.onFinished});

  @override
  State<AddJobDialog> createState() => _AddJobDialogState();
}

class _AddJobDialogState extends State<AddJobDialog> {
  // Text controllers
  final _companyNameController = TextEditingController();
  final _jobTitleController = TextEditingController();
  final _jobDescriptionController = TextEditingController();
  final _minAnnualWageController = TextEditingController();
  final _maxAnnualWageController = TextEditingController();
  final _locationController = TextEditingController();
  final _interviewsCompletedController = TextEditingController();

  // Dropdown values
  String _jobType = 'Remote';
  String _status = 'InProgress';

  // Date selection
  DateTime? _selectedDate;

  // Orignal Job if editing
  late Job _originalJob;

  @override
  void dispose() {
    _companyNameController.dispose();
    _jobTitleController.dispose();
    _jobDescriptionController.dispose();
    _minAnnualWageController.dispose();
    _maxAnnualWageController.dispose();
    _locationController.dispose();
    _interviewsCompletedController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    // If the dialog is opened for editing, load the original job.
    if (widget.existingJob != null) {
      _originalJob = widget.existingJob!;

      // Text fields
      _companyNameController.text = _originalJob.companyName;
      _jobTitleController.text = _originalJob.jobTitle;
      _jobDescriptionController.text = _originalJob.jobDescription;
      _minAnnualWageController.text = _originalJob.minAnnualWage.toString();
      _maxAnnualWageController.text = _originalJob.maxAnnualWage.toString();
      _locationController.text = _originalJob.location;
      _interviewsCompletedController.text =
          _originalJob.interviewsCompleted.toString();

      // Dropdowns
      _jobType = _originalJob.jobType;
      _status = _originalJob.status;

      // Date picker (if a date is stored)
      if (_originalJob.dateSinceEpoch > 0) {
        _selectedDate =
            DateTime.fromMillisecondsSinceEpoch(_originalJob.dateSinceEpoch);
      } else {
        _selectedDate = null;
      }
    }
  }

  // Helper to reset all fields
  void _clearFields() {
    _companyNameController.clear();
    _jobTitleController.clear();
    _jobDescriptionController.clear();
    _minAnnualWageController.clear();
    _maxAnnualWageController.clear();
    _locationController.clear();
    _interviewsCompletedController.clear();
    setState(() {
      _jobType = 'InPerson';
      _status = 'InProgress';
      _selectedDate = null;
    });
  }

  /// Returns true if at least one editable field differs from the original Job.
  bool _hasChanged() {
    // 1. Text fields – compare the plain string
    if (_companyNameController.text != (_originalJob.companyName)) {
      return true;
    }
    if (_jobTitleController.text != (_originalJob.jobTitle)) return true;
    if (_jobDescriptionController.text != (_originalJob.jobDescription)) {
      return true;
    }

    // 2. Numeric fields – parse and compare
    final minWage = int.tryParse(_minAnnualWageController.text) ?? 0;
    if (minWage != (_originalJob.minAnnualWage)) return true;

    final maxWage = int.tryParse(_maxAnnualWageController.text) ?? 0;
    if (maxWage != (_originalJob.maxAnnualWage)) return true;

    final interviews = int.tryParse(_interviewsCompletedController.text) ?? 0;
    if (interviews != (_originalJob.interviewsCompleted)) return true;

    // 3. String fields
    if (_locationController.text != (_originalJob.location)) return true;

    // 4. Dropdowns
    if (_jobType != (_originalJob.jobType)) return true;
    if (_status != (_originalJob.status)) return true;

    // 5. Date – compare epoch milliseconds
    final epochFromField = _selectedDate?.millisecondsSinceEpoch ?? 0;
    if (epochFromField != (_originalJob.dateSinceEpoch)) return true;

    // If none of the above returned true, nothing changed
    return false;
  }

  // Show a date picker and store the selected date
  Future<void> _pickDate(BuildContext context) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? now,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _handleUpload() async {
    // ① Quick validation (required fields, numeric parsing, etc.)
    try {
      // ② Build a Job instance *only* to pass to the DB helper
      final newJob = Job(
        id: widget.existingJob?.id,
        companyName: _companyNameController.text,
        jobTitle: _jobTitleController.text,
        jobDescription: _jobDescriptionController.text,
        minAnnualWage: int.parse(_minAnnualWageController.text),
        maxAnnualWage: int.parse(_maxAnnualWageController.text),
        location: _locationController.text,
        jobType: _jobType,
        dateSinceEpoch: _selectedDate?.millisecondsSinceEpoch ?? 0,
        status: _status,
        interviewsCompleted: int.parse(_interviewsCompletedController.text),
      );

      // ③ If we’re editing, guard against a no‑op update
      if (widget.existingJob != null) {
        if (!_hasChanged()) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('No changes detected')),
          );
          return; // Abort the database call
        }

        // ④ Perform the UPDATE
        // newJob.id = widget.existingJob!.id; // keep the original PK
        await DatabaseHelper.instance.updateJob(newJob);
      } else {
        // ⑤ Otherwise, perform an INSERT
        await DatabaseHelper.instance.insertJob(newJob);
      }

      widget.onFinished(); // refresh list in parent
      if (!mounted) return;
      Navigator.of(context).pop(); // close the dialog
    } catch (e) {
      // ⑥ Handle parsing or other errors
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all fields correctly')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add New Job'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Company Name
            TextField(
              controller: _companyNameController,
              decoration: const InputDecoration(labelText: 'Company Name'),
            ),
            // Job Title
            TextField(
              controller: _jobTitleController,
              decoration: const InputDecoration(labelText: 'Job Title'),
            ),
            // Job Description
            ConstrainedBox(
              constraints:
                  const BoxConstraints(maxWidth: 400), // <-- max width you like
              child: TextField(
                controller: _jobDescriptionController,
                decoration: const InputDecoration(
                  labelText: 'Job Description',
                ),
                minLines: 4,
                maxLines: 10,
              ),
            ),
            // Min Annual Wage
            TextField(
              controller: _minAnnualWageController,
              decoration: const InputDecoration(
                labelText: 'Min Annual Wage',
                prefixText: '\$',
              ),
              keyboardType: TextInputType.number,
            ),
            // Max Annual Wage
            TextField(
              controller: _maxAnnualWageController,
              decoration: const InputDecoration(
                labelText: 'Max Annual Wage',
                prefixText: '\$',
              ),
              keyboardType: TextInputType.number,
            ),
            // Location
            TextField(
              controller: _locationController,
              decoration: const InputDecoration(labelText: 'Location'),
            ),
            // Job Type
            DropdownButtonFormField<String>(
              value: _jobType,
              items: const [
                DropdownMenuItem(value: 'InPerson', child: Text('InPerson')),
                DropdownMenuItem(value: 'Remote', child: Text('Remote')),
                DropdownMenuItem(value: 'Hybrid', child: Text('Hybrid')),
              ],
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _jobType = value;
                  });
                }
              },
              decoration: const InputDecoration(labelText: 'Job Type'),
            ),
            // Date Since Epoch
            InkWell(
              onTap: () => _pickDate(context),
              child: InputDecorator(
                decoration: const InputDecoration(
                  labelText: 'Date',
                ),
                child: Text(
                  _selectedDate == null
                      ? 'Select date'
                      : '${_selectedDate!.toLocal()}'.split(' ')[0],
                ),
              ),
            ),
            // Status
            DropdownButtonFormField<String>(
              value: _status,
              items: const [
                DropdownMenuItem(
                    value: 'InProgress', child: Text('InProgress')),
                DropdownMenuItem(value: 'Rejected', child: Text('Rejected')),
                DropdownMenuItem(value: 'Ghosted', child: Text('Ghosted')),
                DropdownMenuItem(value: 'Completed', child: Text('Completed')),
              ],
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _status = value;
                  });
                }
              },
              decoration: const InputDecoration(labelText: 'Status'),
            ),
            // Interviews Completed
            TextField(
              controller: _interviewsCompletedController,
              decoration:
                  const InputDecoration(labelText: 'Interviews Completed'),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            _clearFields();
            Navigator.of(context).pop();
          },
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _handleUpload,
          child: const Text('Upload'),
        ),
      ],
    );
  }
}
