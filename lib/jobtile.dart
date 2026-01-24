import 'package:flutter/material.dart';
import 'package:job_application_manager/job.dart';

class JobTile extends StatelessWidget {
  final Job job;
  final VoidCallback onTap;

  const JobTile({required this.job, required this.onTap});

  @override
  Widget build(BuildContext context) {
    /* -------- 1st row: Company ↔ Job title -------- */
    Widget topRow = Row(
      children: [
        Expanded(
            child: Text(job.companyName,
                style: const TextStyle(
                    fontSize: 16, decoration: TextDecoration.underline))),
        Text(job.jobTitle, style: const TextStyle(fontWeight: FontWeight.bold)),
      ],
    );

    /* -------- 2nd row: Pay ↔ Job type -------- */
    final min = job.minAnnualWage;
    final max = job.maxAnnualWage;
    final payRange =
        '\$${min.toString().replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (m) => ',')}' // 90,000 → 90,000
        ' - '
        '\$${max.toString().replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (m) => ',')}';
    Widget secondRow = Row(
      children: [
        Expanded(child: Text(payRange)),
        Text(job.jobType),
      ],
    );

    /* -------- 3rd row: Date ↔ Status -------- */
    final date =
        DateTime.fromMillisecondsSinceEpoch(job.dateSinceEpoch).toLocal();
    final dateStr =
        'Date Applied: ${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}-${date.year}';
    Widget thirdRow = Row(
      children: [
        Expanded(child: Text(dateStr)),
        Text(job.status),
      ],
    );

    return InkWell(
      onTap: onTap,
      child: Card(
        elevation: 1, // a lighter shadow fits smaller cards
        child: Padding(
          padding: const EdgeInsets.symmetric(
              vertical: 12, horizontal: 8), // smaller padding
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [topRow, secondRow, thirdRow],
          ),
        ),
      ),
    );
  }
}
