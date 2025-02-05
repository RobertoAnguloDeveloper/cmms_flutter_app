// lib/screens/form_management/form_submissions_view_screen.dart

/*
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../components/drawer_menu/DrawerMenu.dart';
import '../../../models/Permission_set.dart';
import '../../../models/form_submission/answer_view.dart';
import '../../../models/form_submission/form_submission_view.dart';
import '../../../services/api_model_services/api_form_services/form_submission_view_service.dart';

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
  _FormSubmissionsViewScreenState createState() =>
      _FormSubmissionsViewScreenState();
}

class _FormSubmissionsViewScreenState
    extends State<FormSubmissionsViewScreen> {
  final FormSubmissionViewService _submissionService =
  FormSubmissionViewService();

  // We store a typed List<FormSubmissionView> here.
  List<FormSubmissionView> submissions = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSubmissions();
  }

  Future<void> _loadSubmissions() async {
    try {
      setState(() => isLoading = true);

      // Because our new getFormSubmissions returns List<FormSubmissionView>,
      // we can assign directly now.
      final data = await _submissionService.getFormSubmissions(widget.formId);

      setState(() {
        submissions = data;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading submissions: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'Submissions - ${widget.formTitle}',
          style: const TextStyle(color: Colors.black),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
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
            : submissions.isEmpty
            ? const Center(
          child: Text(
            'No submissions found',
            style: TextStyle(fontSize: 18),
          ),
        )
            : ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: submissions.length,
          itemBuilder: (context, index) {
            final submission = submissions[index];
            return _buildSubmissionCard(submission);
          },
        ),
      ),
    );
  }

  Widget _buildSubmissionCard(FormSubmissionView submission) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ExpansionTile(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Submitted by: ${submission.submittedBy}',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              'Date: ${DateFormat('dd/MM/yyyy HH:mm').format(submission.submittedAt)}',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: submission.answers
                  .map((answer) => _buildAnswerWidget(answer))
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnswerWidget(AnswerView answer) {
    return Container(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            answer.question,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            answer.answer,
            style: const TextStyle(fontSize: 16),
          ),
          const Divider(),
        ],
      ),
    );
  }
}
*/

/*


// lib/screens/form_management/form_submissions_view_screen.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../components/drawer_menu/DrawerMenu.dart';
import '../../../models/Permission_set.dart';
import '../../../models/form_submission/answer_view.dart';
import '../../../models/form_submission/form_submission_view.dart';
import '../../../services/api_model_services/api_form_services/form_submission_view_service.dart';

/// A separate screen to show the detail of a single submission (answers, etc.)
class SubmissionDetailScreen extends StatelessWidget {
  final FormSubmissionView submission;

  const SubmissionDetailScreen({Key? key, required this.submission})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    // This layout mimics your second screenshot style
    return Scaffold(
      appBar: AppBar(
        title: Text(submission.formTitle.isEmpty
            ? 'Submission Detail'
            : submission.formTitle),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Container(
        color: const Color(0xFFE3F2FD),
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Example: Show a card with form description or something else
            Card(
              color: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListTile(
                title: Text(
                  'Submitted by: ${submission.submittedBy}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  'Date: ${DateFormat('dd/MM/yyyy HH:mm').format(submission.submittedAt)}',
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Show each answer in a pinkish card, like second screenshot
            ...submission.answers.map(
                  (answer) => Card(
                color: const Color(0xFFF8E1FF), // pastel/pinkish background
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                margin: const EdgeInsets.only(bottom: 16),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        answer.question,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        answer.answer,
                        style: const TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

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
  _FormSubmissionsViewScreenState createState() =>
      _FormSubmissionsViewScreenState();
}

class _FormSubmissionsViewScreenState
    extends State<FormSubmissionsViewScreen> {
  final FormSubmissionViewService _submissionService =
  FormSubmissionViewService();

  List<FormSubmissionView> submissions = [];
  List<FormSubmissionView> filteredSubmissions = [];
  bool isLoading = true;

  // For the dropdown filter, we track the selected user
  String? _selectedUser;

  @override
  void initState() {
    super.initState();
    _loadSubmissions();
  }

  Future<void> _loadSubmissions() async {
    try {
      setState(() => isLoading = true);
      final data = await _submissionService.getFormSubmissions(widget.formId);

      // Keep them in memory for filtering
      submissions = data;
      filteredSubmissions = data;

      setState(() => isLoading = false);
    } catch (e) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading submissions: $e')),
      );
    }
  }

  // Filter logic by submittedBy user
  void _filterSubmissionsByUser(String? user) {
    if (user == null || user.isEmpty) {
      // Show all
      setState(() {
        _selectedUser = null;
        filteredSubmissions = submissions;
      });
    } else {
      setState(() {
        _selectedUser = user;
        filteredSubmissions =
            submissions.where((s) => s.submittedBy == user).toList();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Prepare a list of unique user names
    final users = submissions.map((s) => s.submittedBy).toSet().toList()
      ..sort();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'Submissions - ${widget.formTitle}',
          style: const TextStyle(color: Colors.black),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
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
            : filteredSubmissions.isEmpty
            ? const Center(
          child: Text(
            'No submissions found',
            style: TextStyle(fontSize: 18),
          ),
        )
            : Column(
          children: [
            // --- DROPDOWN to filter by user ---
            Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  const Text(
                    'Filter by user:',
                    style: TextStyle(fontSize: 16),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: DropdownButton<String>(
                      isExpanded: true,
                      value: _selectedUser,
                      hint: const Text('All users'),
                      items: [
                        const DropdownMenuItem<String>(
                          value: '',
                          child: Text('All users'),
                        ),
                        ...users.map((user) =>
                            DropdownMenuItem<String>(
                              value: user,
                              child: Text(user),
                            ))
                      ],
                      onChanged: (value) {
                        _filterSubmissionsByUser(value);
                      },
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),

            // --- LIST of Submissions ---
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: filteredSubmissions.length,
                itemBuilder: (context, index) {
                  final submission = filteredSubmissions[index];
                  return _buildSubmissionCard(submission);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// This card style is closer to your "first screenshot":
  /// - A colored Card (lavender or pink)
  /// - 'Submitted by' as title, 'Date' with an icon, forward arrow
  /// - On tap, navigates to detail screen
  Widget _buildSubmissionCard(FormSubmissionView submission) {
    return Card(
      color: const Color(0xFFFFE0F0), // Pinkish-lavender background
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          // Go to detail screen
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => SubmissionDetailScreen(submission: submission),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Submission info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      // If your FormSubmissionView has formTitle, you could show it:
                      submission.formTitle.isEmpty
                          ? "Submission #${submission.submissionId}"
                          : submission.formTitle,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Submitted by: ${submission.submittedBy}",
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[700],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.calendar_today,
                            size: 16, color: Colors.grey[600]),
                        const SizedBox(width: 4),
                        Text(
                          DateFormat('dd/MM/yyyy HH:mm')
                              .format(submission.submittedAt),
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // Arrow forward icon
              const Icon(Icons.arrow_forward_ios, color: Colors.blue),
            ],
          ),
        ),
      ),
    );
  }
}
*/

/*
// lib/screens/form_management/form_submissions_view_screen.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../components/drawer_menu/DrawerMenu.dart';
import '../../../models/Permission_set.dart';
import '../../../models/form_submission/answer_view.dart';
import '../../../models/form_submission/form_submission_view.dart';
import '../../../services/api_model_services/api_form_services/form_submission_view_service.dart';

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
  _FormSubmissionsViewScreenState createState() =>
      _FormSubmissionsViewScreenState();
}

class _FormSubmissionsViewScreenState
    extends State<FormSubmissionsViewScreen> {
  final FormSubmissionViewService _submissionService =
  FormSubmissionViewService();

  // A typed list of submissions
  List<FormSubmissionView> submissions = [];
  bool isLoading = true;

  // If you had a Dropdown to filter (by user or something), you can keep it:
  String? _selectedFilter; // example: to store a user or status
  List<String> _filterOptions = []; // the list of filter choices

  @override
  void initState() {
    super.initState();
    _loadSubmissions();
  }

  Future<void> _loadSubmissions() async {
    try {
      setState(() => isLoading = true);

      final data = await _submissionService.getFormSubmissions(widget.formId);

      setState(() {
        submissions = data;
        isLoading = false;

        // If you want to build a filter based on "submittedBy", for example:
        _filterOptions = data.map((s) => s.submittedBy).toSet().toList()
          ..sort();
        // Insert an option for "All" if you like:
        // _filterOptions.insert(0, 'All');
      });
    } catch (e) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading submissions: $e')),
      );
    }
  }

  // If you really need a filter function:
  List<FormSubmissionView> get filteredSubmissions {
    if (_selectedFilter == null || _selectedFilter == 'All') {
      return submissions;
    } else {
      // Example: filter by 'submittedBy'
      return submissions
          .where((s) => s.submittedBy == _selectedFilter)
          .toList();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // ---- AppBar ----
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'Submissions - ${widget.formTitle}',
          style: const TextStyle(color: Colors.black),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),

      // ---- Drawer ----
      drawer: DrawerMenu(
        onItemTapped: (index) => Navigator.pop(context),
        parentContext: context,
        permissionSet: widget.permissionSet,
        sessionData: widget.sessionData,
      ),

      // ---- Body ----
      body: Container(
        color: const Color(0xFFE3F2FD),
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : (submissions.isEmpty
            ? const Center(
          child: Text(
            'No submissions found',
            style: TextStyle(fontSize: 18),
          ),
        )
            : Column(
          children: [
            // If you want a Dropdown at the top for filtering:
            Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  const Text(
                    'Filter by user:',
                    style: TextStyle(fontSize: 16),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: DropdownButton<String>(
                      isExpanded: true,
                      hint: const Text('All'),
                      value: _selectedFilter,
                      onChanged: (value) {
                        setState(() {
                          _selectedFilter = value;
                        });
                      },
                      items: [
                        const DropdownMenuItem(
                          value: 'All',
                          child: Text('All'),
                        ),
                        ..._filterOptions.map(
                              (option) => DropdownMenuItem(
                            value: option,
                            child: Text(option),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // The list of submissions (with expansion tile "dropdown")
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: filteredSubmissions.length,
                itemBuilder: (context, index) {
                  final submission = filteredSubmissions[index];
                  return _buildSubmissionCard(submission);
                },
              ),
            ),
          ],
        )),
      ),
    );
  }

  /// Creates a pastel Card with an ExpansionTile (the “dropdown”),
  /// showing submission info at the top, and the question/answers inside.
  Widget _buildSubmissionCard(FormSubmissionView submission) {
    return Card(
      // pastel background (lavender/pink, etc.)
      color: const Color(0xFFFFE0F0),
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ExpansionTile(
        // This "tile" is the dropdown portion
        // Leading Title
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // If your FormSubmissionView has a formTitle, you can display it:
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
            const SizedBox(height: 4),
            Text(
              'Submitted by: ${submission.submittedBy}',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.calendar_today,
                    size: 16, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(
                  DateFormat('dd/MM/yyyy HH:mm')
                      .format(submission.submittedAt),
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ],
        ),
        // The content that appears when user expands the tile
        children: [
          Container(
            color: Colors.white, // or pastel
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: submission.answers
                  .map((answer) => _buildAnswerWidget(answer))
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }

  /// Renders a single Q&A pair in a nice style
  Widget _buildAnswerWidget(AnswerView answer) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            answer.question,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            answer.answer,
            style: const TextStyle(fontSize: 16),
          ),
          const Divider(),
        ],
      ),
    );
  }
}
*/

/*
// lib/screens/form_management/form_submissions_view_screen.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../components/drawer_menu/DrawerMenu.dart';
import '../../../models/Permission_set.dart';
import '../../../models/form_submission/answer_view.dart';
import '../../../models/form_submission/form_submission_view.dart';
import '../../../services/api_model_services/api_form_services/form_submission_view_service.dart';

/// Screen that shows a detailed view of a single submission
/// after the user taps the card (excluding the arrow).
class SubmissionDetailScreen extends StatelessWidget {
  final FormSubmissionView submission;

  const SubmissionDetailScreen({Key? key, required this.submission})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Example detail screen showing who submitted, when, and all answers
    return Scaffold(
      appBar: AppBar(
        title: Text(
          submission.formTitle.isNotEmpty
              ? submission.formTitle
              : "Submission Detail",
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Container(
        color: const Color(0xFFE3F2FD),
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              child: ListTile(
                title: Text(
                  'Submitted by: ${submission.submittedBy}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  'Date: ${DateFormat('dd/MM/yyyy HH:mm').format(submission.submittedAt)}',
                ),
              ),
            ),
            const SizedBox(height: 16),
            ...submission.answers.map(
                  (answer) => Card(
                color: const Color(0xFFFDE7E8), // Light pink
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
                        answer.question,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        answer.answer,
                        style: const TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Main screen that lists all submissions for a particular form.
/// We use a custom expansion card that toggles Q&A by arrow, but navigates on card tap.
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
  _FormSubmissionsViewScreenState createState() =>
      _FormSubmissionsViewScreenState();
}

class _FormSubmissionsViewScreenState
    extends State<FormSubmissionsViewScreen> {
  final FormSubmissionViewService _submissionService =
  FormSubmissionViewService();

  List<FormSubmissionView> submissions = [];
  List<FormSubmissionView> filteredSubmissions = [];
  bool isLoading = true;

  // Example: we keep a "user" filter in a dropdown
  String? _selectedUser;
  List<String> _users = [];

  @override
  void initState() {
    super.initState();
    _loadSubmissions();
  }

  Future<void> _loadSubmissions() async {
    try {
      setState(() => isLoading = true);

      // Load from service
      final data = await _submissionService.getFormSubmissions(widget.formId);

      submissions = data;
      filteredSubmissions = data;

      // Build user list for the dropdown filter
      _users = submissions.map((s) => s.submittedBy).toSet().toList()..sort();

      setState(() => isLoading = false);
    } catch (e) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading submissions: $e')),
      );
    }
  }

  void _filterByUser(String? user) {
    if (user == null || user.isEmpty || user == 'All') {
      setState(() {
        _selectedUser = 'All';
        filteredSubmissions = submissions;
      });
    } else {
      setState(() {
        _selectedUser = user;
        filteredSubmissions =
            submissions.where((s) => s.submittedBy == user).toList();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Setup a list of users with an "All" option
    final dropdownItems = <DropdownMenuItem<String>>[
      const DropdownMenuItem(
        value: 'All',
        child: Text('All'),
      ),
      ..._users.map(
            (user) => DropdownMenuItem(
          value: user,
          child: Text(user),
        ),
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'Submissions - ${widget.formTitle}',
          style: const TextStyle(color: Colors.black),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
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
            : filteredSubmissions.isEmpty
            ? const Center(
          child: Text(
            'No submissions found',
            style: TextStyle(fontSize: 18),
          ),
        )
            : Column(
          children: [
            // Filter row
            Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  const Text('Filter by user:',
                      style: TextStyle(fontSize: 16)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: DropdownButton<String>(
                      isExpanded: true,
                      value: _selectedUser ?? 'All',
                      items: dropdownItems,
                      onChanged: _filterByUser,
                    ),
                  ),
                ],
              ),
            ),
            // Submissions list
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: filteredSubmissions.length,
                itemBuilder: (context, index) {
                  final submission = filteredSubmissions[index];
                  return _CustomExpansionCard(
                    submission: submission,
                    onCardTap: () {
                      // Navigate to detail screen
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => SubmissionDetailScreen(
                            submission: submission,
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// A custom widget that replicates an "ExpansionTile" but allows
/// - Tapping the card to navigate
/// - Tapping the arrow to expand/collapse
class _CustomExpansionCard extends StatefulWidget {
  final FormSubmissionView submission;
  final VoidCallback onCardTap;

  const _CustomExpansionCard({
    Key? key,
    required this.submission,
    required this.onCardTap,
  }) : super(key: key);

  @override
  State<_CustomExpansionCard> createState() => _CustomExpansionCardState();
}

class _CustomExpansionCardState extends State<_CustomExpansionCard> {
  bool _expanded = false;

  void _toggleExpand() {
    setState(() {
      _expanded = !_expanded;
    });
  }

  @override
  Widget build(BuildContext context) {
    final submission = widget.submission;

    return Card(
      color: const Color(0xFFFFE0F0), // Pastel pink
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          // The top portion of the card
          InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: widget.onCardTap, // <-- Tapping card => navigate
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              child: Row(
                children: [
                  // Left side: main info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // If your model includes a formTitle:
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
                            Icon(Icons.calendar_today,
                                size: 16, color: Colors.grey[600]),
                            const SizedBox(width: 4),
                            Text(
                              DateFormat('dd/MM/yyyy HH:mm')
                                  .format(submission.submittedAt),
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  // Right side: arrow icon
                  IconButton(
                    icon: Icon(
                      _expanded
                          ? Icons.keyboard_arrow_up
                          : Icons.keyboard_arrow_down,
                      color: Colors.blue,
                    ),
                    onPressed: () {
                      // Tapping arrow => expand/collapse
                      _toggleExpand();
                    },
                  ),
                ],
              ),
            ),
          ),
          // If expanded, show answer widgets
          if (_expanded)
            Container(
              color: Colors.white,
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: submission.answers
                    .map((answer) => _buildAnswerWidget(answer))
                    .toList(),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildAnswerWidget(AnswerView answer) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            answer.question,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            answer.answer,
            style: const TextStyle(fontSize: 16),
          ),
          const Divider(),
        ],
      ),
    );
  }
}

 */

/*
// lib/screens/form_management/form_submissions_view_screen.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../components/drawer_menu/DrawerMenu.dart';
import '../../../models/Permission_set.dart';
import '../../../models/form_submission/answer_view.dart';
import '../../../models/form_submission/form_submission_view.dart';
import '../../../services/api_model_services/api_form_services/form_submission_view_service.dart';

/// Screen that shows a detailed view of a single submission
/// after the user taps the card (excluding the arrow).
class SubmissionDetailScreen extends StatelessWidget {
  final FormSubmissionView submission;

  const SubmissionDetailScreen({Key? key, required this.submission})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Displays all answers in a single scrollable "form" style
    return Scaffold(
      appBar: AppBar(
        title: Text(
          submission.formTitle.isNotEmpty
              ? submission.formTitle
              : "Submission Detail",
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Container(
        color: const Color(0xFFE3F2FD),
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Top card with submission info
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              child: ListTile(
                title: Text(
                  'Submitted by: ${submission.submittedBy}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  'Date: ${DateFormat('dd/MM/yyyy HH:mm').format(submission.submittedAt)}',
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Each question/answer in a pastel container
            ...submission.answers.map(
                  (answer) => Container(
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: const Color(0xFFFDE7E8), // Light pink pastel
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      answer.question,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      answer.answer,
                      style: const TextStyle(fontSize: 16),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Main screen that lists all submissions for a particular form.
/// We have a custom expansion card that toggles Q&A by arrow,
/// and a tap on the card navigates to SubmissionDetailScreen.
/// The expansion region itself is made more "compact" like QuestionsAnswerScreen.
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
  _FormSubmissionsViewScreenState createState() =>
      _FormSubmissionsViewScreenState();
}

class _FormSubmissionsViewScreenState
    extends State<FormSubmissionsViewScreen> {
  final FormSubmissionViewService _submissionService =
  FormSubmissionViewService();

  List<FormSubmissionView> submissions = [];
  List<FormSubmissionView> filteredSubmissions = [];
  bool isLoading = true;

  // Example user filter in a dropdown
  String? _selectedUser;
  List<String> _users = [];

  @override
  void initState() {
    super.initState();
    _loadSubmissions();
  }

  Future<void> _loadSubmissions() async {
    try {
      setState(() => isLoading = true);

      // Load from service
      final data = await _submissionService.getFormSubmissions(widget.formId);

      submissions = data;
      filteredSubmissions = data;

      // Build user list for the dropdown
      _users = submissions.map((s) => s.submittedBy).toSet().toList()
        ..sort();

      setState(() => isLoading = false);
    } catch (e) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading submissions: $e')),
      );
    }
  }

  void _filterByUser(String? user) {
    if (user == null || user.isEmpty || user == 'All') {
      setState(() {
        _selectedUser = 'All';
        filteredSubmissions = submissions;
      });
    } else {
      setState(() {
        _selectedUser = user;
        filteredSubmissions =
            submissions.where((s) => s.submittedBy == user).toList();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Build dropdown items
    final dropdownItems = <DropdownMenuItem<String>>[
      const DropdownMenuItem(
        value: 'All',
        child: Text('All'),
      ),
      ..._users.map(
            (user) => DropdownMenuItem(
          value: user,
          child: Text(user),
        ),
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'Submissions - ${widget.formTitle}',
          style: const TextStyle(color: Colors.black),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
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
            : filteredSubmissions.isEmpty
            ? const Center(
          child: Text(
            'No submissions found',
            style: TextStyle(fontSize: 18),
          ),
        )
            : Column(
          children: [
            // Filter row
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 8,
              ),
              child: Row(
                children: [
                  const Text(
                    'Filter by user:',
                    style: TextStyle(fontSize: 16),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: DropdownButton<String>(
                      isExpanded: true,
                      value: _selectedUser ?? 'All',
                      items: dropdownItems,
                      onChanged: _filterByUser,
                    ),
                  ),
                ],
              ),
            ),
            // Submissions list
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: filteredSubmissions.length,
                itemBuilder: (context, index) {
                  final submission = filteredSubmissions[index];
                  return _CustomExpansionCard(
                    submission: submission,
                    onCardTap: () {
                      // Navigate to detail screen
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => SubmissionDetailScreen(
                            submission: submission,
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// A custom widget that mimics an "ExpansionTile" but in the expanded region,
/// we display a "compact form" style for all Q&A (like QuestionsAnswerScreen).
class _CustomExpansionCard extends StatefulWidget {
  final FormSubmissionView submission;
  final VoidCallback onCardTap;

  const _CustomExpansionCard({
    Key? key,
    required this.submission,
    required this.onCardTap,
  }) : super(key: key);

  @override
  State<_CustomExpansionCard> createState() => _CustomExpansionCardState();
}

class _CustomExpansionCardState extends State<_CustomExpansionCard> {
  bool _expanded = false;

  void _toggleExpand() {
    setState(() {
      _expanded = !_expanded;
    });
  }

  @override
  Widget build(BuildContext context) {
    final submission = widget.submission;

    return Card(
      color: const Color(0xFFFFE0F0), // pastel pink
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          // The top portion of the card
          InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: widget.onCardTap, // Tapping card => navigate to detail
            child: Padding(
              padding:
              const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              child: Row(
                children: [
                  // Left side: main info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Show formTitle or submissionId
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
                            Icon(Icons.calendar_today,
                                size: 16, color: Colors.grey[600]),
                            const SizedBox(width: 4),
                            Text(
                              DateFormat('dd/MM/yyyy HH:mm')
                                  .format(submission.submittedAt),
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  // Right side: arrow icon
                  IconButton(
                    icon: Icon(
                      _expanded
                          ? Icons.keyboard_arrow_up
                          : Icons.keyboard_arrow_down,
                      color: Colors.blue,
                    ),
                    onPressed: _toggleExpand, // Toggle expand
                  ),
                ],
              ),
            ),
          ),

          // If expanded, show a "compact form" layout for all Q&A
          if (_expanded)
            Container(
              color: Colors.white,
              padding: const EdgeInsets.all(16),
              child: Column(
                children: submission.answers.map((answer) {
                  return Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFDE7E8), // Light pastel
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          answer.question,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          answer.answer,
                          style: const TextStyle(fontSize: 16),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
        ],
      ),
    );
  }
}



*/

// lib/screens/form_management/form_submissions_view_screen.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../components/drawer_menu/DrawerMenu.dart';
import '../../../models/Permission_set.dart';
import '../../../models/form_submission/answer_view.dart';
import '../../../models/form_submission/form_submission_view.dart';
import '../../../services/api_model_services/api_form_services/form_submission_view_service.dart';

/// If the user taps the card, we show a detail screen with all answers
class SubmissionDetailScreen extends StatelessWidget {
  final FormSubmissionView submission;
  final PermissionSet permissionSet;
  final Map<String, dynamic> sessionData;

  const SubmissionDetailScreen({
    Key? key,
    required this.submission,
    required this.permissionSet,
    required this.sessionData,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Display a single scrollable form of Q&A
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      drawer: DrawerMenu(
        onItemTapped: (index) => Navigator.pop(context),
        parentContext: context,
        permissionSet: permissionSet,
        sessionData: sessionData,
      ),
      body: Container(
        color: const Color(0xFFE3F2FD),
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Basic info about the submission
            Card(
              color: Colors.white, // Fondo blanco
              elevation: 4, // Puedes aumentar la elevación para un efecto de sombra más fuerte
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16), // Borde más redondeado
              ),
              margin: const EdgeInsets.symmetric(vertical: 12), // Espacio entre las cards
              child: ListTile(
                contentPadding: const EdgeInsets.all(16), // Agrega padding interno para mayor espacio
                title: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Form Title: ${submission.formTitle.isNotEmpty ? submission.formTitle : "No title"}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 22, // Aumento del tamaño del texto
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 8), // Espacio entre el título y el resto
                    Text(
                      'Submitted by: ${submission.submittedBy}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18, // Aumento del tamaño del texto
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
                subtitle: Text(
                  'Date: ${DateFormat('dd/MM/yyyy HH:mm').format(submission.submittedAt)}',
                  style: const TextStyle(
                    fontSize: 16, // Aumento del tamaño del texto
                    color: Colors.grey,
                  ),
                ),
              ),
            ),


            const SizedBox(height: 16),

            // Show each Q&A in a pastel container
            ...submission.answers.map((answer) {
              return Container(
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: const Color(0xFFB3E5FC), // Azul celeste
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.3), // Sombra gris tenue
                      spreadRadius: 2,
                      blurRadius: 5,
                      offset: const Offset(0, 3), // Desplazamiento de la sombra
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      answer.question,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      answer.answer,
                      style: const TextStyle(fontSize: 16),
                    ),
                  ],
                ),
              );

            }).toList(),
          ],
        ),
      ),
    );
  }
}

/// Main screen: lists the submissions for a form, one pastel card per submission.
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
  _FormSubmissionsViewScreenState createState() =>
      _FormSubmissionsViewScreenState();
}

class _FormSubmissionsViewScreenState extends State<FormSubmissionsViewScreen> {
  final FormSubmissionViewService _submissionService =
      FormSubmissionViewService();

  List<FormSubmissionView> submissions = [];
  List<FormSubmissionView> filteredSubmissions = [];
  bool isLoading = true;

  // Example filter by user in a Dropdown
  String? _selectedUser;
  List<String> _users = [];
  TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _searchByUserName(String query) {
    setState(() {
      if (query.isEmpty) {
        filteredSubmissions = submissions;
      } else {
        filteredSubmissions = submissions
            .where((s) =>
                s.submittedBy.toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
    });
  }

  @override
  void initState() {
    super.initState();
    _loadSubmissions();
  }

  Future<void> _loadSubmissions() async {
    try {
      setState(() => isLoading = true);

      // This call now returns one FormSubmissionView per submission
      final data = await _submissionService.getFormSubmissions(widget.formId);

      submissions = data;
      filteredSubmissions = data;

      // Build list of unique "submittedBy" for filtering
      _users = submissions.map((s) => s.submittedBy).toSet().toList()..sort();

      setState(() => isLoading = false);
    } catch (e) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading submissions: $e')),
      );
    }
  }

  void _filterByUser(String? user) {
    if (user == null || user == 'All') {
      setState(() {
        _selectedUser = 'All';
        filteredSubmissions = submissions;
      });
    } else {
      setState(() {
        _selectedUser = user;
        filteredSubmissions =
            submissions.where((s) => s.submittedBy == user).toList();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final dropdownItems = <DropdownMenuItem<String>>[
      const DropdownMenuItem(
        value: 'All',
        child: Text('All'),
      ),
      ..._users.map((user) => DropdownMenuItem(
            value: user,
            child: Text(user),
          ))
    ];

    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
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
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
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
                          // 📦 Combina el Dropdown con el TextField
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            decoration: BoxDecoration(
                              border: Border.all(
                                  color: Colors.transparent), // Sin borde
                              borderRadius: BorderRadius.circular(12),
                              color: Colors.white,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black
                                      .withOpacity(0.1), // Color de la sombra
                                  spreadRadius:
                                      1, // Cuánto se expande la sombra
                                  blurRadius: 5, // Desenfoque de la sombra
                                  offset: const Offset(
                                      0, 3), // Desplazamiento de la sombra
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                // 🔽 Dropdown integrado (sin opción "All")
                                DropdownButton<String>(
                                  value: _selectedUser,
                                  hint: const Text(
                                      "Select user"), // Texto por defecto
                                  items: _users.map((user) {
                                    return DropdownMenuItem(
                                      value: user,
                                      child: Text(user),
                                    );
                                  }).toList(),
                                  onChanged: (value) {
                                    setState(() {
                                      _selectedUser = value;
                                      _searchController.text = value ??
                                          ''; // Actualiza el campo de búsqueda
                                      _searchByUserName(value ??
                                          ''); // Filtra automáticamente
                                    });
                                  },
                                  underline:
                                      const SizedBox(), // Oculta la línea inferior
                                  icon: const Icon(Icons.arrow_drop_down),
                                ),
                                const VerticalDivider(), // Separador visual
                                // 🔍 TextField de búsqueda
                                Expanded(
                                  child: TextField(
                                    controller: _searchController,
                                    decoration: const InputDecoration(
                                      hintText: 'Enter user name...',
                                      border: InputBorder.none, // Sin borde
                                      prefixIcon: Icon(Icons.search),
                                    ),
                                    onChanged: _searchByUserName,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    // 📋 Mostrar lista o mensaje vacío
                    Expanded(
                      child: filteredSubmissions.isEmpty
                          ? const Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.list_alt, // 📋 Ícono restaurado
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
                                return _CustomExpansionCard(
                                  submission: submission,
                                  onCardTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => SubmissionDetailScreen(
                                          submission: submission,
                                          permissionSet: widget.permissionSet,
                                          sessionData: widget.sessionData,
                                        ),
                                      ),
                                    );
                                  },
                                );
                              },
                            ),
                    )
                  ],
                ),
        ));
  }
}

/// An "ExpansionTile"-like card. One card per submission.
/// Tapping the arrow expands a "compact form"; tapping the card navigates.
class _CustomExpansionCard extends StatefulWidget {
  final FormSubmissionView submission;
  final VoidCallback onCardTap;

  const _CustomExpansionCard({
    Key? key,
    required this.submission,
    required this.onCardTap,
  }) : super(key: key);

  @override
  State<_CustomExpansionCard> createState() => _CustomExpansionCardState();
}

class _CustomExpansionCardState extends State<_CustomExpansionCard> {
  bool _expanded = false;

  void _toggleExpand() {
    setState(() {
      _expanded = !_expanded;
    });
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.submission;

    return Card(
      color: Colors.white, // pastel pink
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: widget.onCardTap, // navigate on card tap
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              child: Row(
                children: [
                  // Left side: Title, user, date
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          s.formTitle.isNotEmpty
                              ? s.formTitle
                              : 'Submission #${s.submissionId}',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Submitted by: ${s.submittedBy}',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[700],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(Icons.calendar_today,
                                size: 16, color: Colors.grey[600]),
                            const SizedBox(width: 4),
                            Text(
                              DateFormat('dd/MM/yyyy HH:mm')
                                  .format(s.submittedAt),
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  // Expand arrow
                  IconButton(
                    icon: Icon(
                      _expanded
                          ? Icons.keyboard_arrow_up
                          : Icons.keyboard_arrow_down,
                      color: Colors.blue,
                    ),
                    onPressed: _toggleExpand,
                  )
                ],
              ),
            ),
          ),
          // If expanded, show Q&A in pastel containers (compact form)
          if (_expanded)
            Container(
              color: Colors.white,
              padding: const EdgeInsets.all(16),
              child: Column(
                children: s.answers.map((answer) {
                  return Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFB3E5FC),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          answer.question,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          answer.answer,
                          style: const TextStyle(fontSize: 16),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
        ],
      ),
    );
  }
}
