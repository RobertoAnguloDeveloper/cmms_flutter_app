import 'package:flutter/material.dart';

import '../../../../../components/SnackBarUtil.dart';
import '../../../../../services/api_model_services/RoleApiService.dart';

class RoleDetailsHelper extends StatefulWidget {
  final Map<String, dynamic> role;
  final VoidCallback onRoleUpdated;

  const RoleDetailsHelper({
    Key? key,
    required this.role,
    required this.onRoleUpdated,
  }) : super(key: key);

  @override
  _RoleDetailsScreenState createState() => _RoleDetailsScreenState();
}

class _RoleDetailsScreenState extends State<RoleDetailsHelper> {
  late TextEditingController nameController;
  late TextEditingController descriptionController;
  late bool isSuperUser;
  String? nameErrorText;
  String? descriptionErrorText;

  final RoleApiService roleApiService = RoleApiService();

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: widget.role['name'] ?? '');
    descriptionController =
        TextEditingController(text: widget.role['description'] ?? '');
    isSuperUser = widget.role['is_super_user'] ?? false;
  }

  Future<void> _updateRole() async {
    final name = nameController.text.trim();
    final description = descriptionController.text.trim();

    setState(() {
      nameErrorText = name.isEmpty ? 'Role name cannot be empty' : null;
      descriptionErrorText =
          description.isEmpty ? 'Description cannot be empty' : null;
    });

    if (name.isEmpty || description.isEmpty) {
      return;
    }

    final updatedData = {
      "name": name,
      "description": description,
      "is_super_user": isSuperUser,
    };

    try {
      final response = await roleApiService.updateRole(
        context,
        widget.role['id'],
        updatedData,
      );

      if (response['status'] == 200) {
        SnackBarUtil.showCustomSnackBar(
          context: context,
          message: 'Role updated successfully',
          duration: const Duration(milliseconds: 500),
        );

        widget.onRoleUpdated();
        Navigator.of(context).pop();
      } else if (response['status'] == 400 && response.containsKey('error')) {
        if (response['error'] == 'A role with this name already exists') {
          setState(() {
            nameErrorText = 'This role name is already in use.';
          });
        } else {
          SnackBarUtil.showCustomSnackBar(
            context: context,
            message: 'Error: ${response['message']}',
            duration: const Duration(milliseconds: 1500),
          );
        }
      } else {
        SnackBarUtil.showCustomSnackBar(
          context: context,
          message: 'Error: ${response['message']}',
          duration: const Duration(milliseconds: 1500),
        );
      }
    } catch (e) {
      SnackBarUtil.showCustomSnackBar(
        context: context,
        message: 'Error: $e',
        duration: const Duration(milliseconds: 1500),
      );
    }
  }

  Future<void> _deleteRole() async {
    try {
      final response =
          await roleApiService.deleteRole(context, widget.role['id']);

      if (response['status'] == 200 || response['status'] == 204) {
        SnackBarUtil.showCustomSnackBar(
          context: context,
          message: 'Role deleted successfully',
          duration: const Duration(milliseconds: 500),
        );

        widget.onRoleUpdated();
        Navigator.of(context).pop();
      } else if (response['error'] == 'Cannot delete role with active users') {
        final activeUsers = response['active_users']['users'] as List<dynamic>;
        final userDetails = activeUsers.map((user) {
          return '- ${user['full_name']} (${user['email']})';
        }).join('\n');

        final suggestion = response['suggestion'];

        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Cannot Delete Role'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'This role is associated with the active user(s):',
                    style: TextStyle(fontSize: 18),
                  ),

                  // const SizedBox(height: 10),
                  // Text(
                  //   userDetails,
                  //   style: const TextStyle(fontSize: 14),
                  // ),
                  // const SizedBox(height: 20),
                  // Text(
                  //   suggestion,
                  //   style: const TextStyle(fontStyle: FontStyle.italic),
                  // ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('OK'),
                ),
              ],
            );
          },
        );
      } else {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Error'),
              content: Text('An error occurred: ${response['message']}'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('OK'),
                ),
              ],
            );
          },
        );
      }
    } catch (e) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Error'),
            content: Text('An error occurred: $e'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
            ],
          );
        },
      );
    }
  }

  void _confirmDeleteRole() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm deletion'),
          content: Text(
            'Are you sure you want to delete the role "${widget.role['name']}"?',
            style: TextStyle(fontSize: 18),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _deleteRole();
              },
              child: const Text('Delete', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.0),
      ),
      elevation: 10,
      child: Container(
        padding: const EdgeInsets.all(24.0),
        width: 400,
        height: 460,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20.0),
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: 'Role Name',
                  labelStyle: TextStyle(fontSize: 18),
                  border: OutlineInputBorder(),
                  contentPadding: const EdgeInsets.symmetric(
                      vertical: 15.0, horizontal: 18.0),
                  errorText: nameErrorText,
                ),
                style: const TextStyle(fontSize: 16),
                onChanged: (value) {
                  if (nameErrorText != null) {
                    setState(() {
                      nameErrorText = null;
                    });
                  }
                },
              ),
              const SizedBox(height: 20),
              TextField(
                controller: descriptionController,
                decoration: InputDecoration(
                  labelText: 'Description',
                  labelStyle: const TextStyle(fontSize: 18),
                  border: const OutlineInputBorder(),
                  contentPadding: const EdgeInsets.symmetric(
                      vertical: 15.0, horizontal: 18.0),
                  errorText: descriptionErrorText,
                ),
                maxLines: 3,
                style: const TextStyle(fontSize: 16),
                onChanged: (value) {
                  if (descriptionErrorText != null) {
                    setState(() {
                      descriptionErrorText = null;
                    });
                  }
                },
              ),
              const SizedBox(height: 20),
              CheckboxListTile(
                title: const Text(
                  'Is Super User',
                  style: TextStyle(fontSize: 18),
                ),
                value: isSuperUser,
                onChanged: (bool? value) {
                  setState(() {
                    isSuperUser = value ?? false;
                  });
                },
                controlAffinity: ListTileControlAffinity.leading,
                contentPadding: const EdgeInsets.symmetric(horizontal: 0.0),
              ),
              const SizedBox(height: 40),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  ElevatedButton(
                    onPressed: _confirmDeleteRole,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      padding: const EdgeInsets.symmetric(
                          vertical: 20.0, horizontal: 30.0),
                      textStyle: const TextStyle(fontSize: 18),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Icon(Icons.delete, color: Colors.white),
                        SizedBox(width: 8),
                        Text('Delete', style: TextStyle(color: Colors.white)),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: _updateRole,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 34, 118, 186),
                      padding: const EdgeInsets.symmetric(
                          vertical: 20.0, horizontal: 30.0),
                      textStyle: const TextStyle(fontSize: 18),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Icon(Icons.save, color: Colors.white),
                        SizedBox(width: 12),
                        Text('Save', style: TextStyle(color: Colors.white)),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
