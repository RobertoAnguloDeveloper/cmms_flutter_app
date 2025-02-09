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
