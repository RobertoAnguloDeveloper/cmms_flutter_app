import 'package:flutter/material.dart';

import '../../../../services/api_model_services/UserApiService.dart';

class UserSelectionDialog extends StatefulWidget {
  final Function refreshFormDetails;
  final int formQuestionId;

  const UserSelectionDialog({
    Key? key,
    required this.refreshFormDetails,
    required this.formQuestionId,
  }) : super(key: key);

  @override
  _UserSelectionDialogState createState() => _UserSelectionDialogState();
}

class _UserSelectionDialogState extends State<UserSelectionDialog> {
  final UserApiService _userApiService = UserApiService();
  List<dynamic> _users = [];
  bool _isLoading = true;
  dynamic _selectedUser;

  @override
  void initState() {
    super.initState();
    _fetchAllUsers();
  }

  Future<void> _fetchAllUsers() async {
    try {
      final users = await _userApiService.fetchUsers(context);
      setState(() {
        _users = users;
        _isLoading = false;
      });
    } catch (e) {
      print('Error fetching users: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.0),
      ),
      child: Container(
        padding: const EdgeInsets.all(16.0),
        width: 320,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Seleccionar Usuario',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            _isLoading
              ? const CircularProgressIndicator()
              : DropdownButtonFormField<dynamic>(
                  value: _selectedUser,
                  hint: const Text('Elige un usuario'),
                  items: _users.map((user) {
                    return DropdownMenuItem<dynamic>(
                      value: user,
                      child: Text(user['full_name'] ?? 'No name'),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedUser = value;
                    });
                  },
                ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancelar'),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _selectedUser == null ? null : () async {
                    // Aquí puedes manejar el caso en que se seleccione el usuario.
                    // Por ejemplo, si necesitas asignar esta "respuesta" al formQuestion, 
                    // llamas a un servicio o actualizas el estado del formulario.
                    // Luego refrescas el detalle del formulario:
                    widget.refreshFormDetails();

                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 34, 118, 186),
                  ),
                  child: const Text('Seleccionar'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
