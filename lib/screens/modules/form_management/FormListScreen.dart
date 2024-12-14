import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../components/AddButton.dart';
import '../../../components/drawer_menu/DrawerMenu.dart';
import '../../../models/Permission_set.dart';
import '../../../services/api_model_services/api_form_services/FormApiService.dart';
import 'answer_form_management/FormAnswerDialog.dart';
import 'form_management_helpers/FormDetailHelper.dart';
import 'form_management_helpers/FormRegisterHelper.dart';

class FormListScreen extends StatefulWidget {
  final PermissionSet permissionSet;
  final Map<String, dynamic> sessionData;

  const FormListScreen({
    Key? key,
    required this.permissionSet,
    required this.sessionData,
  }) : super(key: key);

  @override
  _FormListScreenState createState() => _FormListScreenState();
}

class _FormListScreenState extends State<FormListScreen> {
  final FormApiService _formApiService = FormApiService();
  List<dynamic> forms = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchForms();
  }

  Future<void> _fetchForms() async {
    if (!mounted) return;

    setState(() {
      isLoading = true;
    });

    try {
      final fetchedForms = await _formApiService.fetchForms(context);
      if (mounted) {
        setState(() {
          forms = fetchedForms;
          isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
      print('Error fetching forms: $e');
    }
  }

  void _viewFormDetails(Map<String, dynamic> form) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FormDetailHelper(
          form: form,
          onFormDeleted: () {
            _fetchForms();
          },
        ),
      ),
    );
    if (result == true) {
      _fetchForms();
    }
  }

  String _formatDate(String dateString) {
    final date = DateTime.parse(dateString);
    return DateFormat('dd/MM/yyyy').format(date);
  }

  bool _hasQuestions(Map<String, dynamic> form) {
    final questions = form['questions'] as List? ?? [];
    return questions.isNotEmpty;
  }

  void _showEmptyFormDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Empty form'),
          content: const Text('This form has no available questions'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      drawer: DrawerMenu(
        onItemTapped: (index) {
          Navigator.pop(context);
        },
        parentContext: context,
        permissionSet: widget.permissionSet,
        sessionData: widget.sessionData,
      ),
      body: Container(
        color: const Color(0xFFE3F2FD),
        child: Column(
          children: [
            Expanded(
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : forms.isEmpty
                  ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.list_alt,
                      size: 64,
                      color: Colors.grey,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'No forms available.',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'You can create one using the Add button below.',
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
                      itemCount: forms.length,
                      itemBuilder: (context, index) {
                        final form = forms[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: InkWell(
                                  onTap: () {
                                    _viewFormDetails(form);
                                  },
                                  borderRadius: BorderRadius.circular(12),
                                  child: Card(
                                    elevation: 1,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    color: Color.fromARGB(255, 255, 255, 255),
                                    child: Padding(
                                      padding: const EdgeInsets.all(16),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            form['title'] ?? 'No Title',
                                            style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.blue,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            'Created: ${_formatDate(form['created_at'])}',
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey[600],
                                            ),
                                          ),
                                          Text(
                                            'Last modification: ${_formatDate(form['updated_at'])}',
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey[600],
                                            ),
                                          ),
                                          Text(
                                            'Created by: ${form['created_by']['fullname']}',
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey[600],
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            form['description'] ??
                                                'No description',
                                            style: TextStyle(
                                              fontSize: 14,
                                              color: Colors.grey[800],
                                            ),
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Column(
                                children: [
                                  const SizedBox(height: 42),
                                  ElevatedButton(
                                    onPressed: () {
                                      if (_hasQuestions(form)) {
                                        showDialog(
                                          context: context,
                                          builder: (BuildContext context) {
                                            return FormAnswerDialog(
                                              form: form,
                                            );
                                          },
                                        );
                                      } else {
                                        _showEmptyFormDialog();
                                      }
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Color.fromARGB(255, 255, 255, 255),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      padding: const EdgeInsets.all(20),
                                      elevation: 1,
                                    ),
                                    child: const Icon(
                                      Icons.check_circle_outline,
                                      color: Colors.blue,
                                      size: 32,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      }),
            ),
            const SizedBox(height: 16),
            Align(
              alignment: Alignment.center,
              child: AddButton(
                onPressed: () {
                  FormRegisterHelper.showFormDialog(context, _fetchForms);
                },
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
