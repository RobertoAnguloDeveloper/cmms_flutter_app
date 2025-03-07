
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../services/api_model_services/UserApiService.dart';

class DynamicQuestionInput extends StatefulWidget {
  final Map<String, dynamic> question;
  final Function(dynamic) onAnswerChanged;
  final dynamic currentValue;
  final Map<String, dynamic> sessionData;

  const DynamicQuestionInput({
    Key? key,
    required this.question,
    required this.onAnswerChanged,
    this.currentValue,
    required this.sessionData,
  }) : super(key: key);

  @override
  _DynamicQuestionInputState createState() => _DynamicQuestionInputState();
}

class _DynamicQuestionInputState extends State<DynamicQuestionInput> {
  late TextEditingController _textController;
  List<dynamic> _users = []; // Para almacenar la lista de usuarios
  bool _isLoadingUsers = false; // Para mostrar un indicador de carga

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController(text: widget.currentValue?.toString());

    // Si la pregunta es de tipo usuario, cargar los usuarios
    if (widget.question['type']?.toString().toLowerCase() == 'user') {
      _loadUsers();
    }
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  bool get isRequired => widget.question['is_required'] ?? true; // Default to true
  bool get isSuperUser => widget.sessionData['role']?['is_super_user'] ?? false;

  Future<void> _loadUsers() async {
    if (_users.isNotEmpty) return; // Si ya se cargaron los usuarios, no hacer nada

    setState(() {
      _isLoadingUsers = true;
    });

    try {
      final UserApiService userService = UserApiService();

      if (isSuperUser) {
        // Si es superusuario, cargar todos los usuarios
        _users = await userService.fetchAllUsers(context);
      } else {
        // Si no es superusuario, cargar solo los usuarios de su entorno
        final int environmentId = widget.sessionData['environment_id'] ?? 0;
        if (environmentId > 0) {
          _users = await userService.fetchUsersByEnvironment(context, environmentId);
        } else {
          // Si no hay ID de entorno, cargar todos los usuarios activos como fallback
          _users = await userService.fetchUsers(context);
        }
      }
    } catch (e) {
      print('Error loading users: $e');
      // Mostrar un mensaje de error
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading users: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingUsers = false;
        });
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    final questionType = widget.question['type']?.toString().toLowerCase() ?? '';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (!isRequired)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(4),
            ),
            child: const Text(
              'Optional',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        const SizedBox(height: 8),
        _buildInputByType(questionType),
      ],
    );
  }

  Widget _buildInputByType(String questionType) {
    switch (questionType) {
      case 'checkbox':
        return _buildCheckboxInput();
      case 'multiple_choice':
      case 'multiple_choices':
        return _buildMultipleChoiceInput();
      case 'radio':
        return _buildMultipleChoiceInput();
      case 'date':
        return _buildDateInput();
      case 'datetime': // Nueva opción para datetime
        return _buildDateTimeInput();
      case 'user': // Nuevo tipo de pregunta para seleccionar usuario
        return _buildUserSelectionInput();
      case 'signature':
        return _buildSignatureInput();
      case 'file_upload':
        return _buildFileUploadInput();
      case 'linear_scale':
        return _buildLinearScaleInput();
      default:
        return _buildTextInput();
    }
  }

  Widget _buildUserSelectionInput() {
    if (_isLoadingUsers) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_users.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey),
          borderRadius: BorderRadius.circular(8.0),
          color: Colors.grey[100],
        ),
        child: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.orange),
            const SizedBox(width: 8.0),
            const Expanded(
              child: Text(
                'No users available. Please try again later.',
                style: TextStyle(color: Colors.grey),
              ),
            ),
            TextButton(
              onPressed: _loadUsers,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    // Ordenar usuarios por nombre para facilitar la búsqueda
    _users.sort((a, b) => (a['full_name'] ?? '').compareTo(b['full_name'] ?? ''));

    // Encontrar el usuario seleccionado actualmente
    int selectedUserId = 0;

    // Si el valor actual es un entero, asumimos que es el ID del usuario
    if (widget.currentValue != null) {
      if (widget.currentValue is int) {
        selectedUserId = widget.currentValue;
      } else if (widget.currentValue is Map) {
        // Si es un mapa con información del usuario, obtenemos el ID
        selectedUserId = widget.currentValue['id'] ?? 0;
      } else {
        // Intentar parsear como entero
        try {
          selectedUserId = int.parse(widget.currentValue.toString());
        } catch (e) {
          print('Error parsing user ID: $e');
        }
      }
    }

    return InputDecorator(
      decoration: InputDecoration(
        border: const OutlineInputBorder(),
        suffixIcon: const Icon(Icons.person),
        hintText: 'Select user',
        filled: true,
        fillColor: Colors.white,
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<int>(
          isExpanded: true,
          value: selectedUserId != 0 ? selectedUserId : null,
          hint: const Text('Select user'),
          onChanged: (int? newValue) {
            if (newValue != null) {
              // Encontrar el usuario completo en la lista
              Map<String, dynamic>? selectedUser;
              for (var user in _users) {
                if (user['id'] == newValue) {
                  selectedUser = Map<String, dynamic>.from(user);
                  break;
                }
              }

              // Si se ha implementado la opción para guardar el objeto usuario completo:
              if (selectedUser != null) {
                // Guardar tanto el ID como la información del usuario
                widget.onAnswerChanged({
                  'id': newValue,
                  'userInfo': selectedUser,
                  'displayName': selectedUser['full_name'] ?? selectedUser['username'] ?? 'User $newValue'
                });
              } else {
                // Si por alguna razón no se encuentra, solo guardamos el ID
                widget.onAnswerChanged(newValue);
              }
            } else {
              widget.onAnswerChanged(null);
            }
          },
          items: _users.map<DropdownMenuItem<int>>((user) {
            return DropdownMenuItem<int>(
              value: user['id'],
              child: Text(
                user['full_name'] ?? user['username'] ?? 'Unknown user',
                overflow: TextOverflow.ellipsis,
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildCheckboxInput() {
    final options = widget.question['possible_answers'] as List? ?? [];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: options.map((option) {
        final bool isSelected = widget.currentValue?.contains(option['id']) ?? false;
        return CheckboxListTile(
          title: Text(option['value']),
          value: isSelected,
          onChanged: (bool? value) {
            List<int> currentSelections = List<int>.from(widget.currentValue ?? []);
            if (value == true) {
              currentSelections.add(option['id']);
            } else {
              currentSelections.remove(option['id']);
            }
            widget.onAnswerChanged(currentSelections);
          },
        );
      }).toList(),
    );
  }

  Widget _buildMultipleChoiceInput() {
    final options = widget.question['possible_answers'] as List? ?? [];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: options.map((option) {
        return RadioListTile<int>(
          title: Text(option['value']),
          value: option['id'],
          groupValue: widget.currentValue,
          onChanged: (value) {
            widget.onAnswerChanged(value);
          },
        );
      }).toList(),
    );
  }

  Widget _buildDateInput() {
    return InkWell(
      onTap: () async {
        final DateTime? picked = await showDatePicker(
          context: context,
          initialDate: widget.currentValue != null
              ? DateTime.parse(widget.currentValue)
              : DateTime.now(),
          firstDate: DateTime(1900),
          lastDate: DateTime(2100),
        );
        if (picked != null) {
          widget.onAnswerChanged(DateFormat('yyyy-MM-dd').format(picked));
        }
      },
      child: InputDecorator(
        decoration: InputDecoration(
          border: const OutlineInputBorder(),
          suffixIcon: const Icon(Icons.calendar_today),
          hintText: 'Select date',
          filled: true,
          fillColor: Colors.white,
        ),
        child: Text(
          widget.currentValue != null
              ? DateFormat('dd/MM/yyyy').format(DateTime.parse(widget.currentValue))
              : 'Select date',
          style: TextStyle(
            color: widget.currentValue != null ? Colors.black : Colors.grey[600],
          ),
        ),
      ),
    );
  }

  Widget _buildDateTimeInput() {
    return InkWell(
      onTap: () async {
        // Primero, seleccionar la fecha
        final DateTime? pickedDate = await showDatePicker(
          context: context,
          initialDate: widget.currentValue != null
              ? DateTime.parse(widget.currentValue)
              : DateTime.now(),
          firstDate: DateTime(1900),
          lastDate: DateTime(2100),
        );

        if (pickedDate != null) {
          // Después, seleccionar la hora
          final TimeOfDay? pickedTime = await showTimePicker(
            context: context,
            initialTime: widget.currentValue != null
                ? TimeOfDay.fromDateTime(DateTime.parse(widget.currentValue))
                : TimeOfDay.now(),
          );

          // Si tanto la fecha como la hora fueron seleccionadas
          if (pickedTime != null) {
            final DateTime combinedDateTime = DateTime(
              pickedDate.year,
              pickedDate.month,
              pickedDate.day,
              pickedTime.hour,
              pickedTime.minute,
            );

            // Formatear como ISO 8601 para almacenar
            widget.onAnswerChanged(combinedDateTime.toIso8601String());
          }
        }
      },
      child: InputDecorator(
        decoration: InputDecoration(
          border: const OutlineInputBorder(),
          suffixIcon: const Icon(Icons.event_available), // Icono diferente para datetime
          hintText: 'Select date and time',
          filled: true,
          fillColor: Colors.white,
        ),
        child: Text(
          widget.currentValue != null
              ? DateFormat('dd/MM/yyyy HH:mm').format(DateTime.parse(widget.currentValue))
              : 'Select date and time',
          style: TextStyle(
            color: widget.currentValue != null ? Colors.black : Colors.grey[600],
          ),
        ),
      ),
    );
  }

  Widget _buildSignatureInput() {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Center(
        child: Text('Signature pad will be implemented here'),
      ),
    );
  }

  Widget _buildFileUploadInput() {
    return ElevatedButton.icon(
      onPressed: () {
        // Implement file upload logic
      },
      icon: const Icon(Icons.upload_file),
      label: const Text('Upload File'),
    );
  }

  Widget _buildLinearScaleInput() {
    return Slider(
      value: (widget.currentValue ?? 0).toDouble(),
      min: 0,
      max: 10,
      divisions: 10,
      label: widget.currentValue?.toString() ?? '0',
      onChanged: (value) {
        widget.onAnswerChanged(value.round());
      },
    );
  }

  Widget _buildTextInput() {
    return TextField(
      controller: _textController,
      decoration: const InputDecoration(
        border: OutlineInputBorder(),
        hintText: 'Enter your answer',
        filled: true,
        fillColor: Colors.white,
      ),
      onChanged: widget.onAnswerChanged,
      maxLines: widget.question['type'] == 'paragraph' ? 3 : 1,
    );
  }
}