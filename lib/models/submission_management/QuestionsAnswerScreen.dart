import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../components/drawer_menu/DrawerMenu.dart';
import '../../../models/Permission_set.dart';
import '../../../services/api_model_services/api_form_services/AnswerApiService.dart';
import '../../../services/api_model_services/api_form_services/FormApiService.dart';
import '../../screens/modules/form_submission/Components/DynamicQuestionInput.dart';



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
    return DynamicQuestionInput(
      question: question,
      currentValue: answers[question['id']],
      onAnswerChanged: (value) {
        setState(() {
          answers[question['id']] = value;
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
