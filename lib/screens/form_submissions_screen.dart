// lib/screens/form_management/form_submissions_screen.dart
import 'package:cmms_app/screens/submission_detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../components/drawer_menu/DrawerMenu.dart';
import '../../models/Permission_set.dart';
import '../services/form_submission_service.dart';

class FormSubmissionsViewScreen extends StatefulWidget {
  final int formId;
  final String formTitle;
  final PermissionSet permissionSet;
  final Map<String, dynamic> sessionData;

  const FormSubmissionsViewScreen({
    Key? key,
    required this.formId,
    required this.formTitle,
    required this.permissionSet,
    required this.sessionData,
  }) : super(key: key);

  @override
  _FormSubmissionsViewScreenState createState() => _FormSubmissionsViewScreenState();
}

class _FormSubmissionsViewScreenState extends State<FormSubmissionsViewScreen> {
  final FormSubmissionService _submissionService = FormSubmissionService();
  List<FormSubmission> submissions = [];
  List<FormSubmission> filteredSubmissions = [];
  bool isLoading = true;

  // Filters
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();
    _loadSubmissions();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _dateController.dispose();
    super.dispose();
  }

  Future<void> _loadSubmissions() async {
    try {
      setState(() => isLoading = true);
      final data = await _submissionService.getFormSubmissions(widget.formId, context);
      setState(() {
        submissions = data;
        filteredSubmissions = data;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading submissions: $e')),
        );
      }
    }
  }

  void _searchByUserName(String query) {
    _applyFilters(userQuery: query);
  }

  void _applyFilters({String? userQuery, DateTime? date}) {
    // Apply user filter if provided
    if (userQuery != null) {
      _searchController.text = userQuery;
    }

    // Apply date filter if provided
    if (date != null) {
      _selectedDate = date;
      _dateController.text = DateFormat('dd/MM/yyyy').format(date);
    }

    // Filter submissions based on user and date criteria
    List<FormSubmission> filtered = submissions.where((submission) {
      bool matchesUser = true;
      if (_searchController.text.isNotEmpty) {
        matchesUser = submission.submittedBy.toLowerCase().contains(_searchController.text.toLowerCase());
      }

      bool matchesDate = true;
      if (_selectedDate != null) {
        matchesDate = submission.submittedAt.year == _selectedDate!.year &&
            submission.submittedAt.month == _selectedDate!.month &&
            submission.submittedAt.day == _selectedDate!.day;
      }

      return matchesUser && matchesDate;
    }).toList();

    setState(() {
      filteredSubmissions = filtered;
    });
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2015),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Colors.blue,
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      _applyFilters(date: picked);
    }
  }

  void _clearDateFilter() {
    setState(() {
      _selectedDate = null;
      _dateController.clear();
      _applyFilters();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          widget.formTitle,
          style: const TextStyle(color: Colors.black87),
        ),
      ),
      drawer: DrawerMenu(
        onItemTapped: (index) => Navigator.pop(context),
        parentContext: context,
        permissionSet: widget.permissionSet,
        sessionData: widget.sessionData,
      ),
      body: Container(
        color: const Color(0xFFE3F2FD),
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : Column(
          children: [
            // User filter
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Search by user',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.blue,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          spreadRadius: 1,
                          blurRadius: 5,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: TextField(
                      controller: _searchController,
                      decoration: const InputDecoration(
                        hintText: 'Enter user name...',
                        border: InputBorder.none,
                        prefixIcon: Icon(Icons.search),
                        suffixIcon: Icon(Icons.person_outline),
                      ),
                      onChanged: _searchByUserName,
                    ),
                  ),
                ],
              ),
            ),

            // Date filter
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Filter by date',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.blue,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          spreadRadius: 1,
                          blurRadius: 5,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.calendar_today),
                          onPressed: () => _selectDate(context),
                        ),
                        const VerticalDivider(),
                        Expanded(
                          child: TextField(
                            controller: _dateController,
                            decoration: const InputDecoration(
                              hintText: 'Select date...',
                              border: InputBorder.none,
                            ),
                            readOnly: true,
                            onTap: () => _selectDate(context),
                          ),
                        ),
                        if (_selectedDate != null)
                          IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: _clearDateFilter,
                          ),
                      ],
                    ),
                  ),

                  // Show filter result count if filtered
                  if (filteredSubmissions.length != submissions.length)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4
                        ),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade100,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          'Showing ${filteredSubmissions.length} of ${submissions.length} submissions',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.blue.shade800,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // Submission list
            Expanded(
              child: filteredSubmissions.isEmpty
                  ? const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.list_alt,
                      size: 64,
                      color: Colors.grey,
                    ),
                    SizedBox(height: 16),
                    Text(
                      'No submissions available.',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Once someone submits a form, you\'ll see it here.',
                      style: TextStyle(
                        fontSize: 24,
                        color: Colors.grey,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              )
                  : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: filteredSubmissions.length,
                itemBuilder: (context, index) {
                  final submission = filteredSubmissions[index];
                  return _buildSubmissionCard(submission, context);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubmissionCard(FormSubmission submission, BuildContext context) {
    return Card(
      color: Colors.white,
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () async {
          // Navigate to detail view
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => SubmissionDetailScreen(
                submission: submission,
                permissionSet: widget.permissionSet,
                sessionData: widget.sessionData,
              ),
            ),
          );

          // If submission was deleted, reload
          if (result == true) {
            _loadSubmissions();
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                submission.formTitle.isNotEmpty
                    ? submission.formTitle
                    : 'Submission #${submission.submissionId}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Submitted by: ${submission.submittedBy}',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[700],
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.calendar_today, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text(
                    DateFormat('dd/MM/yyyy HH:mm').format(submission.submittedAt),
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                  if (submission.attachments.isNotEmpty) ...[
                    const SizedBox(width: 12),
                    Icon(Icons.attachment, size: 16, color: Colors.blue[600]),
                    const SizedBox(width: 4),
                    Text(
                      '${submission.attachments.length} attachment${submission.attachments.length > 1 ? 's' : ''}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.blue[600],
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}