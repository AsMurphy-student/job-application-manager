class Job {
  final int? id;
  final String companyName;
  final String jobTitle;
  final String jobDescription;
  final int minAnnualWage;
  final int maxAnnualWage;
  final String location;
  final String jobType;
  final int dateSinceEpoch;
  final String status;
  final int interviewsCompleted;

  Job({
    this.id,
    required this.companyName,
    required this.jobTitle,
    required this.jobDescription,
    required this.minAnnualWage,
    required this.maxAnnualWage,
    required this.location,
    required this.jobType,
    required this.dateSinceEpoch,
    required this.status,
    required this.interviewsCompleted,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'companyName': companyName,
      'jobTitle': jobTitle,
      'jobDescription': jobDescription,
      'minAnnualWage': minAnnualWage,
      'maxAnnualWage': maxAnnualWage,
      'location': location,
      'jobType': jobType,
      'dateSinceEpoch': dateSinceEpoch,
      'status': status,
      'interviewsCompleted': interviewsCompleted
    };
  }

  factory Job.fromMap(Map<String, dynamic> map) {
    return Job(
        id: map['id'],
        companyName: map['companyName'],
        jobTitle: map['jobTitle'],
        jobDescription: map['jobDescription'],
        minAnnualWage: map['minAnnualWage'],
        maxAnnualWage: map['maxAnnualWage'],
        location: map['location'],
        jobType: map['jobType'],
        dateSinceEpoch: map['dateSinceEpoch'],
        status: map['status'],
        interviewsCompleted: map['interviewsCompleted']);
  }
}
