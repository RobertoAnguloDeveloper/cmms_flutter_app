// lib/screens/modules/form_management/form_submission_detail_screen.dart

import 'package:flutter/material.dart';
import '../../../models/Permission_set.dart';
import '../../../services/api_model_services/api_form_services/form_submission_view_service.dart';

class FormSubmissionDetailScreen extends StatefulWidget {
  final int submissionId;
  final String formTitle;
  final PermissionSet permissionSet;
  final Map<String, dynamic> sessionData;

  const FormSubmissionDetailScreen({
    Key? key,
    required this.submissionId,
    required this.formTitle,
    required this.permissionSet,
    required this.sessionData,
  }) : super(key: key);

  @override
  _FormSubmissionDetailScreenState createState() => _FormSubmissionDetailScreenState();
}

class _FormSubmissionDetailScreenState extends State<FormSubmissionDetailScreen> {
  final FormSubmissionViewService _submissionService = FormSubmissionViewService();
  bool isLoading = true;
  Map<String, dynamic>? submissionDetails;

  @override
  void initState() {
    super.initState();
    _loadSubmissionDetails();
  }

  Future<void> _loadSubmissionDetails() async {
    try {
      setState(() => isLoading = true);
      final details = await _submissionService.getSubmissionDetails(
        context,
        widget.submissionId,
      );
      setState(() {
        submissionDetails = details;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading submission details: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          widget.formTitle,
          style: const TextStyle(color: Colors.black),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Container(
        color: const Color(0xFFE3F2FD),
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : submissionDetails == null
            ? const Center(child: Text('No details available'))
            : SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSubmissionHeader(),
              const SizedBox(height: 16),
              _buildAnswersList(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSubmissionHeader() {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Submitted by: ${submissionDetails!['submitted_by']}',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Date: ${submissionDetails!['submitted_date']}',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnswersList() {
    final answers = submissionDetails!['answers'] as List;
    return Column(
      children: answers.map((answer) => _buildAnswerCard(answer)).toList(),
    );
  }

  Widget _buildAnswerCard(Map<String, dynamic> answer) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              answer['question'],
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              answer['answer'],
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
