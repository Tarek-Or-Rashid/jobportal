class JobModel {
  final int id;
  final String title;
  final String company;
  final String location;
  final String salary;
  final String description;
  final String? image;

  JobModel({
    required this.id,
    required this.title,
    required this.company,
    required this.location,
    required this.salary,
    required this.description,
    this.image,
  });

  // Convert to Map for SQLite
  Map<String, dynamic> toMap(String userEmail) {
    return {
      'user_email': userEmail,
      'job_id': id,
      'title': title,
      'company': company,
      'location': location,
      'salary': salary,
      'description': description,
      'image': image,
    };
  }

  // Convert from Map (SQLite)
  factory JobModel.fromMap(Map<String, dynamic> map) {
    return JobModel(
      id: map['job_id'] ?? map['id'],
      title: map['title'],
      company: map['company'],
      location: map['location'],
      salary: map['salary'],
      description: map['description'],
      image: map['image'],
    );
  }

  // Convert from API JSON
  factory JobModel.fromJson(Map<String, dynamic> json) {
    return JobModel(
      id: json['id'],
      title: json['title'] ?? 'No Title',
      company: json['brand'] ?? 'Unknown Company',
      location: json['category'] ?? 'Remote',
      salary: '\$${json['price']}/month',
      description: json['description'] ?? 'No description available',
      image: json['thumbnail'],
    );
  }
}
