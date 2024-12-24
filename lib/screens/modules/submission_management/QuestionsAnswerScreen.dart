/*import 'package:cmms_app/components/drawer_menu/DrawerMenu.dart';
import 'package:cmms_app/models/Permission_set.dart';
import 'package:flutter/material.dart';
import '../../../services/api_model_services/api_form_services/AnswerApiService.dart';

class QuestionsAnswerScreen extends StatefulWidget {
  final int formId; // ID del formulario
  final String formTitle; // Título del formulario
  final String? formDescription; // Descripción del formulario
  final PermissionSet permissionSet;
  final Map<String, dynamic> sessionData;

  const QuestionsAnswerScreen({
    Key? key,
    required this.formId,
    required this.formTitle,
    this.formDescription,
       required this.permissionSet,
    required this.sessionData,
  }) : super(key: key);

  @override
  _QuestionsAnswerScreenState createState() => _QuestionsAnswerScreenState();
}

class _QuestionsAnswerScreenState extends State<QuestionsAnswerScreen> {
  final AnswerApiService _answerApiService = AnswerApiService();
  bool isLoading = true;
  List<dynamic> questions = [];
  Map<int, dynamic> answers = {}; // Mapa para almacenar las respuestas ingresadas

  @override
  void initState() {
    super.initState();
    _fetchQuestions();
  }

  Future<void> _fetchQuestions() async {
    try {
      setState(() {
        isLoading = true;
      });

      final formData = await _answerApiService.getFormWithQuestions(
        context,
        widget.formId,
      );

      setState(() {
        questions = formData['questions'] ?? [];
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading questions: $e')),
      );
    }
  }

  void _submitAnswers() async {
    try {
      // Validar respuestas antes de enviar
      for (var question in questions) {
        if (question['is_required'] && !answers.containsKey(question['id'])) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Please answer the question: ${question['text']}'),
            ),
          );
          return;
        }
      }

      // Simular el envío de respuestas
      for (var entry in answers.entries) {
        print('Question ID: ${entry.key}, Answer: ${entry.value}');
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Answers submitted successfully')),
      );

      Navigator.pop(context); // Volver a la pantalla anterior
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error submitting answers: $e')),
      );
    }
  }

  Widget _buildQuestionField(Map<String, dynamic> question) {
    switch (question['type']) {
      case 'checkbox':
        return _buildCheckboxQuestion(question);
      default:
        return _buildTextQuestion(question);
    }
  }

  Widget _buildCheckboxQuestion(Map<String, dynamic> question) {
    final possibleAnswers = question['possible_answers'] as List? ?? [];
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              question['text'],
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            ...possibleAnswers.map((answer) {
              final isSelected = answers[question['id']] == answer['id'];
              return CheckboxListTile(
                title: Text(answer['value']),
                value: isSelected,
                onChanged: (bool? selected) {
                  setState(() {
                    if (selected == true) {
                      answers[question['id']] = answer['id'];
                    } else {
                      answers.remove(question['id']);
                    }
                  });
                },
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildTextQuestion(Map<String, dynamic> question) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              question['text'],
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            TextField(
              decoration: const InputDecoration(
                hintText: 'Enter your answer',
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                setState(() {
                  answers[question['id']] = value.trim();
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      /*appBar: AppBar(
        title: Text(widget.formTitle),
        backgroundColor: Colors.blue,
      ),*/

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
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                if (widget.formDescription != null)
                  Text(
                    widget.formDescription!,
                    style: const TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                const SizedBox(height: 16),
                ...questions.map((question) => _buildQuestionField(question)),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _submitAnswers,
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 50),
                    backgroundColor: Colors.blue,
                  ),
                  child: const Text(
                    'Submit Answers',
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                ),
              ],
            ),
    );
  }
}*/

import 'package:intl/intl.dart';
/*
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../components/drawer_menu/DrawerMenu.dart';
import '../../../models/Permission_set.dart';
import '../../../services/api_model_services/api_form_services/AnswerApiService.dart';
import '../../../services/api_model_services/api_form_services/FormApiService.dart';

class QuestionsAnswerScreen extends StatefulWidget {
  final int formId;
  final String formTitle;
  final String? formDescription;
  final PermissionSet permissionSet;
  final Map<String, dynamic> sessionData;

  const QuestionsAnswerScreen({
    Key? key,
    required this.formId,
    required this.formTitle,
    this.formDescription,
    required this.permissionSet,
    required this.sessionData,
  }) : super(key: key);

  @override
  _QuestionsAnswerScreenState createState() => _QuestionsAnswerScreenState();
}

class _QuestionsAnswerScreenState extends State<QuestionsAnswerScreen> {
  final FormApiService _formApiService = FormApiService();
  final AnswerApiService _answerApiService = AnswerApiService();

  bool isLoading = true;
  List<dynamic> forms = [];
  List<dynamic> questions = [];
  Map<int, dynamic> answers = {};

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
      _showErrorSnackBar('Error fetching forms: $e');
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message))
    );
  }

  String _formatDate(String dateString) {
    final date = DateTime.parse(dateString);
    return DateFormat('dd/MM/yyyy').format(date);
  }

  bool _hasQuestions(Map<String, dynamic> form) {
    final questions = form['questions'] as List? ?? [];
    return questions.isNotEmpty;
  }

  Future<void> _loadFormQuestions(int formId) async {
    try {
      setState(() => isLoading = true);

      final formData = await _answerApiService.getFormWithQuestions(
        context,
        formId,
      );

      setState(() {
        questions = formData['questions'] ?? [];
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      _showErrorSnackBar('Error loading questions: $e');
    }
  }

  Widget _buildFormCard(Map<String, dynamic> form) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              color: Colors.white,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
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
                    if (form['created_by'] != null)
                      Text(
                        'Created by: ${form['created_by']['fullname']}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    const SizedBox(height: 8),
                    Text(
                      form['description'] ?? 'No description',
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
          const SizedBox(width: 8),
          Column(
            children: [
              const SizedBox(height: 42),
              ElevatedButton(
                onPressed: () {
                  if (_hasQuestions(form)) {
                    _loadFormQuestions(form['id']);
                  } else {
                    _showErrorSnackBar('This form has no questions available');
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.all(20),
                  elevation: 0,
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
  }

  @override
  Widget build(BuildContext context) {
    bool canViewForms = widget.permissionSet.hasPermission('view_forms') ||
        widget.permissionSet.hasPermission('view_public_forms');

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Available Forms',
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
        child: !canViewForms
            ? const Center(
          child: Text(
            'You do not have permission to view forms',
            style: TextStyle(fontSize: 16),
          ),
        )
            : isLoading
            ? const Center(child: CircularProgressIndicator())
            : forms.isEmpty
            ? const Center(
          child: Text(
            'No forms available',
            style: TextStyle(fontSize: 16),
          ),
        )
            : ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: forms.length,
          itemBuilder: (context, index) => _buildFormCard(forms[index]),
        ),
      ),
    );
  }
}*/

import 'package:flutter/material.dart';
import '../../../components/drawer_menu/DrawerMenu.dart';
import '../../../models/Permission_set.dart';
import '../../../services/api_model_services/api_form_services/AnswerApiService.dart';
import '../../../services/api_model_services/api_form_services/FormApiService.dart';

class QuestionsAnswerScreen extends StatefulWidget {
  final int formId;
  final String formTitle;
  final String? formDescription;
  final PermissionSet permissionSet;
  final Map<String, dynamic> sessionData;

  const QuestionsAnswerScreen({
    Key? key,
    required this.formId,
    required this.formTitle,
    this.formDescription,
    required this.permissionSet,
    required this.sessionData,

  }) : super(key: key);

  @override
  _QuestionsAnswerScreenState createState() => _QuestionsAnswerScreenState();
}

class _QuestionsAnswerScreenState extends State<QuestionsAnswerScreen> {
  final FormApiService _formApiService = FormApiService();
  final AnswerApiService _answerApiService = AnswerApiService();

  bool isLoading = true;
  List<dynamic> forms = [];
  List<dynamic> questions = [];
  Map<int, dynamic> answers = {};
  bool showQuestions = false;
  Map<String, dynamic>? selectedForm;

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
      _showErrorSnackBar('Error fetching forms: $e');
    }
  }

  void _showErrorSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message))
    );
  }

  String _formatDate(String dateString) {
    final date = DateTime.parse(dateString);
    return DateFormat('dd/MM/yyyy').format(date);
  }

  bool _hasQuestions(Map<String, dynamic> form) {
    final questions = form['questions'] as List? ?? [];
    return questions.isNotEmpty;
  }

  Future<void> _loadFormQuestions(Map<String, dynamic> form) async {
    try {
      setState(() {
        isLoading = true;
        selectedForm = form;
      });

      final formData = await _answerApiService.getFormWithQuestions(
        context,
        form['id'],
      );

      setState(() {
        questions = formData['questions'] ?? [];
        showQuestions = true;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      _showErrorSnackBar('Error loading questions: $e');
    }
  }

  Widget _buildFormCard(Map<String, dynamic> form) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: InkWell(
          onTap: () {
            if (_hasQuestions(form)) {
              _loadFormQuestions(form);
            } else {
              _showErrorSnackBar('This form has no questions available');
            }
          },
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  form['title'] ?? 'No Title',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  form['description'] ?? 'No description',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[700],
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Icon(Icons.calendar_today, size: 16, color: Colors.grey[600]),
                    const SizedBox(width: 4),
                    Text(
                      _formatDate(form['created_at']),
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                    const Spacer(),
                    Icon(Icons.arrow_forward, color: Colors.blue),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildQuestionCard(Map<String, dynamic> question) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    question['text'] ?? 'No question text',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                if (question['is_required'] == true)
                  const Text(
                    '*',
                    style: TextStyle(
                      color: Colors.red,
                      fontSize: 20,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            _buildAnswerField(question),
          ],
        ),
      ),
    );
  }

  Widget _buildAnswerField(Map<String, dynamic> question) {
    final questionType = question['type']?.toString().toLowerCase() ?? '';

    switch (questionType) {
      case 'checkbox':
        return _buildCheckboxAnswer(question);
      case 'radio':
      case 'multiple_choice':
        return _buildRadioAnswer(question);
      case 'date':
        return _buildDateAnswer(question);
      default:
        return _buildTextAnswer(question);
    }
  }

  Widget _buildCheckboxAnswer(Map<String, dynamic> question) {
    final options = question['possible_answers'] as List? ?? [];
    return Column(
      children: options.map((option) {
        final isSelected = answers[question['id']] == option['id'];
        return CheckboxListTile(
          title: Text(option['value']),
          value: isSelected,
          onChanged: (bool? value) {
            setState(() {
              if (value == true) {
                answers[question['id']] = option['id'];
              } else {
                answers.remove(question['id']);
              }
            });
          },
        );
      }).toList(),
    );
  }

  Widget _buildRadioAnswer(Map<String, dynamic> question) {
    final options = question['possible_answers'] as List? ?? [];
    return Column(
      children: options.map((option) {
        return RadioListTile(
          title: Text(option['value']),
          value: option['id'],
          groupValue: answers[question['id']],
          onChanged: (value) {
            setState(() {
              answers[question['id']] = value;
            });
          },
        );
      }).toList(),
    );
  }

  Widget _buildDateAnswer(Map<String, dynamic> question) {
    return InkWell(
      onTap: () async {
        final date = await showDatePicker(
          context: context,
          initialDate: DateTime.now(),
          firstDate: DateTime(1900),
          lastDate: DateTime(2100),
        );
        if (date != null) {
          setState(() {
            answers[question['id']] = DateFormat('yyyy-MM-dd').format(date);
          });
        }
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(Icons.calendar_today, color: Colors.blue),
            const SizedBox(width: 8),
            Text(
              answers[question['id']] ?? 'Select date',
              style: TextStyle(
                color: answers[question['id']] != null ? Colors.black : Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextAnswer(Map<String, dynamic> question) {
    return TextField(
      decoration: InputDecoration(
        hintText: 'Enter your answer',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      onChanged: (value) {
        setState(() {
          answers[question['id']] = value.trim();
        });
      },
    );
  }

  Future<void> _submitAnswers() async {
    try {
      for (var question in questions) {
        if (question['is_required'] == true && !answers.containsKey(question['id'])) {
          _showErrorSnackBar('Please answer: ${question['text']}');
          return;
        }
      }

      // TODO: Implementar el envío de respuestas al backend
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Answers submitted successfully'))
      );

      setState(() {
        showQuestions = false;
        selectedForm = null;
        answers.clear();
      });

    } catch (e) {
      _showErrorSnackBar('Error submitting answers: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    String appBarTitle = showQuestions
        ? (selectedForm != null ? selectedForm!['title'] : 'Fill Form')
        : 'Available Forms';

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: Builder(
          builder: (BuildContext context) {
            return IconButton(
              icon: Icon(
                  showQuestions ? Icons.arrow_back : Icons.menu,
                  color: Colors.black
              ),
              onPressed: showQuestions
                  ? () {
                setState(() {
                  showQuestions = false;
                  selectedForm = null;
                  answers.clear();
                });
              }
                  : () {
                Scaffold.of(context).openDrawer();
              },
            );
          },
        ),
        title: Text(
          appBarTitle,
          style: const TextStyle(color: Colors.black),
        ),
      ),
      drawer: !showQuestions ? DrawerMenu(
        onItemTapped: (index) {
          Navigator.of(context).pop(); // Cierra el drawer
        },
        parentContext: context,
        permissionSet: widget.permissionSet,
        sessionData: widget.sessionData,
      ) : null,
      body: Container(
        color: const Color(0xFFE3F2FD),
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : showQuestions
            ? ListView(
          padding: const EdgeInsets.all(16),
          children: [
            if (selectedForm?['description'] != null)
              Card(
                elevation: 0,
                color: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    selectedForm!['description'],
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[800],
                    ),
                  ),
                ),
              ),
            const SizedBox(height: 16),
            ...questions.map((q) => _buildQuestionCard(q)).toList(),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _submitAnswers,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
                backgroundColor: Colors.blue,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Submit Answers',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        )
            : ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: forms.length,
          itemBuilder: (context, index) => _buildFormCard(forms[index]),
        ),
      ),
    );
  }
}
