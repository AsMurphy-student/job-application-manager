// Generated using GPT OSS
// Reviewed by me
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:job_application_manager/database_helper.dart';
import 'package:job_application_manager/job.dart';

class JobDetailDialog extends StatelessWidget {
  final Job job;
  final VoidCallback onDeleted; // called after a successful delete

  const JobDetailDialog({
    Key? key,
    required this.job,
    required this.onDeleted,
  }) : super(key: key);

  /* ---------- DATE HELPERS ---------- */
  String get formattedDate {
    final dt = DateTime.fromMillisecondsSinceEpoch(job.dateSinceEpoch);
    return DateFormat('MM-dd-yyyy').format(dt);
  }

  /* ---------- DELETE LOGIC ---------- */
  Future<void> _delete(BuildContext context) async {
    if (job.id == null) return;
    await DatabaseHelper.instance.deleteJob(job.id!);
    Navigator.of(context).pop();            // close dialog
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Job deleted')),
    );
    onDeleted();                            // refresh the list
  }

  /* ---------- UI ---------- */
  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.all(12),
      child: SizedBox(
        width: double.maxFinite,
        height: MediaQuery.of(context).size.height * 0.8, // 80% of screen
        child: Column(
          children: [
            /* ---- 1. App bar with close icon ---- */
            AppBar(
              title: Text(job.companyName),
              automaticallyImplyLeading: false,
              actions: [
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
              backgroundColor: Theme.of(context).colorScheme.primary,
              surfaceTintColor: Theme.of(context).colorScheme.primary,
            ),
            /* ---- 2. Body (description) ---- */
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(12),
                child: Text(
                  job.jobDescription ?? '',
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ),
            /* ---- 3. Bottom buttons ---- */
            ButtonBar(
              alignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: () => _delete(context),
                  style: TextButton.styleFrom(
                    foregroundColor: Theme.of(context).colorScheme.error,
                  ),
                  child: const Text('Delete'),
                ),
                ElevatedButton(
                  onPressed: () {
                    /* TODO: Update logic – leave empty for now */
                  },
                  child: const Text('Update'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}