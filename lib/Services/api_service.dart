import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/job_model.dart';

class ApiService {
  static const String baseUrl = 'https://dummyjson.com/products';

  // Fetch all jobs
  Future<List<JobModel>> fetchJobs() async {
    try {
      final response = await http.get(Uri.parse(baseUrl));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List products = data['products'];

        return products.map((json) => JobModel.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load jobs');
      }
    } catch (e) {
      print('Error fetching jobs: $e');
      throw Exception('Failed to load jobs: $e');
    }
  }

  // Fetch single job by ID
  Future<JobModel> fetchJobById(int id) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/$id'));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return JobModel.fromJson(data);
      } else {
        throw Exception('Failed to load job details');
      }
    } catch (e) {
      print('Error fetching job details: $e');
      throw Exception('Failed to load job details: $e');
    }
  }
}
