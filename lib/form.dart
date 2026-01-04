import 'package:flutter/material.dart';
import 'package:job_application_manager/database_helper.dart';
import 'package:job_application_manager/job.dart';

/// This Class was generated using GPT OSS
/// And also double checked by myself

/// A dialog that contains a form for adding a new job.
class AddJobDialog extends StatefulWidget {
  final VoidCallback onJobAdded;

  const AddJobDialog({Key? key, required this.onJobAdded}) : super(key: key);

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

  // Handle upload button press
  Future<void> _handleUpload() async {
    try {
      final job = Job(
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

      print(job);

      await DatabaseHelper.instance.insertJob(job);
      widget.onJobAdded(); // refresh the list
      Navigator.of(context).pop();
    } catch (e) {
      // Simple error handling: show a snackbar
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
            TextField(
              controller: _jobDescriptionController,
              decoration: const InputDecoration(labelText: 'Job Description'),
              minLines: 4,
              maxLines: 10,
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
