/*import 'package:flutter/material.dart';

import '../../../components/drawer_menu/DrawerMenu.dart';
import '../../../models/Permission_set.dart';
import '../../../services/api_model_services/api_form_services/form_submission_view_service.dart';

class FormSubmissionsListScreen extends StatefulWidget {
  final PermissionSet permissionSet;
  final Map<String, dynamic> sessionData;

  const FormSubmissionsListScreen({
    Key? key,
    required this.permissionSet,
    required this.sessionData,
  }) : super(key: key);

  @override
  _FormSubmissionsListScreenState createState() => _FormSubmissionsListScreenState();
}

class _FormSubmissionsListScreenState extends State<FormSubmissionsListScreen> {
  final FormSubmissionViewService _submissionService = FormSubmissionViewService();
  bool isLoading = true;
  List<dynamic> submissions = [];
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _loadSubmissions();
  }

  Future<void> _loadSubmissions() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final data = await _submissionService.getAllSubmissions(context);

      setState(() {
        submissions = data['answers'] ?? [];
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = e.toString();
        isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading submissions: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Form Submissions', style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: Builder(builder: (BuildContext context) {
          return IconButton(
            icon: const Icon(Icons.menu, color: Colors.black),
            onPressed: () {
              Scaffold.of(context).openDrawer();
            },
          );
        }),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.black),
            onPressed: _loadSubmissions,
          ),
        ],
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
            : errorMessage != null
            ? _buildErrorWidget()
            : submissions.isEmpty
            ? const Center(
          child: Text(
            'No form submissions found',
            style: TextStyle(fontSize: 18),
          ),
        )
            : _buildSubmissionsListView(),
      ),
    );
  }

  Widget _buildErrorWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 48, color: Colors.red),
          const SizedBox(height: 16),
          const Text('Error loading submissions', style: TextStyle(fontSize: 18)),
          const SizedBox(height: 8),
          ElevatedButton(
            onPressed: _loadSubmissions,
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildSubmissionsListView() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: submissions.length,
      itemBuilder: (context, index) {
        final submission = submissions[index];
        return _buildSubmissionCard(submission);
      },
    );
  }

  Widget _buildSubmissionCard(dynamic submission) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        title: Text(
          submission['question'] ?? 'No Question',
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            Text(
              'Answer: ${submission['answer'] ?? 'No Answer'}',
              style: const TextStyle(fontSize: 16, color: Colors.black87),
            ),
            const SizedBox(height: 4),
            Text(
              'Type: ${submission['question_type'] ?? 'Unknown'}',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }
}*/




/*
// lib/screens/modules/form_management/form_submissions_list_screen.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Opcional, en caso de formatear fechas
import '../../../components/drawer_menu/DrawerMenu.dart';
import '../../../models/Permission_set.dart';
import '../../../services/api_model_services/api_form_services/form_submission_view_service.dart';

class FormSubmissionsListScreen extends StatefulWidget {
  final PermissionSet permissionSet;
  final Map<String, dynamic> sessionData;

  const FormSubmissionsListScreen({
    Key? key,
    required this.permissionSet,
    required this.sessionData,
  }) : super(key: key);

  @override
  _FormSubmissionsListScreenState createState() => _FormSubmissionsListScreenState();
}

class _FormSubmissionsListScreenState extends State<FormSubmissionsListScreen> {
  final FormSubmissionViewService _submissionService = FormSubmissionViewService();

  bool isLoading = true;
  String? errorMessage;
  List<dynamic> submissions = [];

  @override
  void initState() {
    super.initState();
    _loadSubmissions();
  }

  Future<void> _loadSubmissions() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final data = await _submissionService.getAllSubmissions(context);
      setState(() {
        submissions = data['answers'] ?? [];
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = e.toString();
        isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading submissions: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // AppBar similar a QuestionsAnswerScreen: blanco, sin elevation
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Form Submissions',
          style: TextStyle(color: Colors.black),
        ),
        leading: Builder(builder: (BuildContext context) {
          return IconButton(
            icon: const Icon(Icons.menu, color: Colors.black),
            onPressed: () {
              Scaffold.of(context).openDrawer();
            },
          );
        }),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.black),
            onPressed: _loadSubmissions,
          ),
        ],
      ),
      // Drawer
      drawer: DrawerMenu(
        onItemTapped: (index) => Navigator.pop(context),
        parentContext: context,
        permissionSet: widget.permissionSet,
        sessionData: widget.sessionData,
      ),
      // Fondo azul claro
      body: Container(
        color: const Color(0xFFE3F2FD),
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : errorMessage != null
            ? _buildErrorWidget()
            : submissions.isEmpty
            ? const Center(
          child: Text(
            'No form submissions found',
            style: TextStyle(fontSize: 18),
          ),
        )
            : _buildSubmissionsListView(),
      ),
    );
  }

  Widget _buildErrorWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 48, color: Colors.red),
          const SizedBox(height: 16),
          const Text('Error loading submissions', style: TextStyle(fontSize: 18)),
          const SizedBox(height: 8),
          ElevatedButton(
            onPressed: _loadSubmissions,
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildSubmissionsListView() {
    // Similar a la forma en que QuestionsAnswerScreen construye su lista
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: submissions.length,
      itemBuilder: (context, index) {
        final item = submissions[index];
        return _buildSubmissionCard(item);
      },
    );
  }

  Widget _buildSubmissionCard(dynamic submission) {
    // Tarjeta estilo similar a QuestionsAnswerScreen
    return Card(
      // QAS: color blanco, sin elevación notoria
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      margin: const EdgeInsets.only(bottom: 16),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: _buildSubmissionContent(submission),
      ),
    );
  }

  Widget _buildSubmissionContent(dynamic submission) {
    // Muestra question, answer, question_type, etc.
    // Si deseas agruparlos por "form_submission", necesitarías más lógica,
    // pero aquí replicamos "QuestionsAnswerScreen" con un card por item.

    final question = submission['question'] ?? 'No Question';
    final answer = submission['answer'] ?? 'No Answer';
    final type = submission['question_type'] ?? 'Unknown';

    // La info de form_submission la encuentras en submission['form_submission']
    // Podrías extraer "submitted_by", "submitted_at", etc. si quieres mostrarlos aquí.

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Título
        Text(
          question,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        // Respuesta
        Text(
          'Answer: $answer',
          style: const TextStyle(fontSize: 15, color: Colors.black87),
        ),
        const SizedBox(height: 4),
        // Tipo
        Text(
          'Type: $type',
          style: TextStyle(fontSize: 14, color: Colors.grey[700]),
        ),

        // Si quieres mostrar quién envió y cuándo, puedes hacerlo:
        const SizedBox(height: 8),
        if (submission['form_submission'] != null) ...[
          Divider(color: Colors.grey[400]),
          Text(
            'Submitted by: ${submission['form_submission']['submitted_by'] ?? 'Unknown'}',
            style: TextStyle(fontSize: 14, color: Colors.grey[700]),
          ),
          const SizedBox(height: 4),
          Text(
            'Submitted at: ${_formatSubmissionDate(submission['form_submission']['submitted_at'])}',
            style: TextStyle(fontSize: 14, color: Colors.grey[700]),
          ),
        ],
      ],
    );
  }

  // Ejemplo de formateo de fecha
  String _formatSubmissionDate(String? dateStr) {
    if (dateStr == null) return 'N/A';
    final parsed = DateTime.tryParse(dateStr);
    if (parsed == null) return dateStr;
    return DateFormat('dd/MM/yyyy HH:mm').format(parsed);
  }
}


*/



// lib/screens/modules/form_management/form_submissions_list_screen.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../components/drawer_menu/DrawerMenu.dart';
import '../../../models/Permission_set.dart';
import '../../../services/api_model_services/api_form_services/form_submission_view_service.dart';
import 'form_submissions_view_screen.dart';

class FormSubmissionsListScreen extends StatefulWidget {
  final PermissionSet permissionSet;
  final Map<String, dynamic> sessionData;

  const FormSubmissionsListScreen({
    Key? key,
    required this.permissionSet,
    required this.sessionData,
  }) : super(key: key);

  @override
  _FormSubmissionsListScreenState createState() => _FormSubmissionsListScreenState();
}

class _FormSubmissionsListScreenState extends State<FormSubmissionsListScreen> {
  final FormSubmissionViewService _submissionService = FormSubmissionViewService();
  List<dynamic> forms = [];
  List<dynamic> filteredForms = [];
  bool isLoading = true;
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadForms();
    searchController.addListener(_onSearchChanged);
  }

  Future<void> _loadForms() async {
    try {
      setState(() => isLoading = true);

      // Este método debe existir en tu servicio y debe traer todas las respuestas
      // o información suficiente para agrupar por formulario.
      final data = await _submissionService.getAllSubmissions(context);

      // Agrupar envíos por form_id
      Map<int, dynamic> formGroups = {};
      for (var submission in data['answers']) {
        int formId = submission['form_id'];
        if (!formGroups.containsKey(formId)) {
          formGroups[formId] = {
            'id': formId,
            'title': submission['form_title'],
            'description': submission['form_description'],
            'created_at': submission['created_at'],
            'submissions_count': 0,
          };
        }
        formGroups[formId]['submissions_count']++;
      }

      setState(() {
        forms = formGroups.values.toList();
        filteredForms = forms;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      _showSnackBar('Error loading forms: $e');
    }
  }

  void _onSearchChanged() {
    final query = searchController.text.toLowerCase();
    setState(() {
      filteredForms = forms.where((form) =>
          form['title'].toString().toLowerCase().contains(query)
      ).toList();
    });
  }

  void _showSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  Widget _buildFormCard(Map<String, dynamic> form) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => FormSubmissionsViewScreen(
                formId: form['id'],
                formTitle: form['title'],
                permissionSet: widget.permissionSet,
                sessionData: widget.sessionData,
              ),
            ),
          ).then((_) => _loadForms()); // Actualiza la lista al volver
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                form['title'] ?? 'Untitled Form',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                form['description'] ?? 'No description',
                style: TextStyle(fontSize: 14, color: Colors.grey[700]),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(Icons.description, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 8),
                  Text(
                    '${form['submissions_count']} submissions',
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                  const Spacer(),
                  const Icon(Icons.arrow_forward, color: Colors.blue),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu, color: Colors.black),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        title: const Text(
          'Form Submissions',
          style: TextStyle(color: Colors.black),
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
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              TextField(
                controller: searchController,
                decoration: InputDecoration(
                  hintText: 'Search forms',
                  prefixIcon: const Icon(Icons.search),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : filteredForms.isEmpty
                    ? const Center(child: Text('No forms found'))
                    : ListView.builder(
                  itemCount: filteredForms.length,
                  itemBuilder: (context, index) {
                    return _buildFormCard(filteredForms[index]);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

