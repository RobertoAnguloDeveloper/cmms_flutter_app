import 'package:flutter/material.dart';

import '../../../../../components/SnackBarUtil.dart';
import '../../../../../services/api_model_services/PermissionApiService.dart';

class PermissionDetailsScreen extends StatefulWidget {
  final Map<String, dynamic> permission;
  final VoidCallback onPermissionUpdated;

  const PermissionDetailsScreen({
    Key? key,
    required this.permission,
    required this.onPermissionUpdated,
  }) : super(key: key);

  @override
  _PermissionDetailsScreenState createState() =>
      _PermissionDetailsScreenState();
}

class _PermissionDetailsScreenState extends State<PermissionDetailsScreen> {
  late TextEditingController controllerName;
  late TextEditingController controllerDescription;
  String? nameErrorText;
  String? descriptionErrorText;
  final PermissionApiService permissionApiService = PermissionApiService();

  @override
  void initState() {
    super.initState();
    controllerName = TextEditingController(text: widget.permission['name']);
    controllerDescription =
        TextEditingController(text: widget.permission['description']);
  }

  Future<void> _updatePermission() async {
    final name = controllerName.text.trim();
    final description = controllerDescription.text.trim();

    setState(() {
      nameErrorText = name.isEmpty ? 'Permission name cannot be empty' : null;
      descriptionErrorText =
          description.isEmpty ? 'Description cannot be empty' : null;
    });

    if (name.isEmpty || description.isEmpty) {
      return;
    }

    final updatedData = {
      "name": controllerName.text,
      "description": controllerDescription.text,
    };

    try {
      final response = await permissionApiService.updatePermission(
        context,
        widget.permission['id'],
        updatedData,
      );

      if (response['status'] == 200) {
        SnackBarUtil.showCustomSnackBar(
          context: context,
          message: 'Permission updated successfully',
          duration: const Duration(milliseconds: 500),
        );

        widget.onPermissionUpdated();
        Navigator.of(context).pop();
      } else if (response['status'] == 400 && response.containsKey('error')) {
        if (response['error'] == 'A permission with this name already exists') {
          setState(() {
            nameErrorText = 'A permission with this name already exists';
          });
        } else {
          // SnackBarUtil.showCustomSnackBar(
          //   context: context,
          //   message: 'Error: ${response['message']}',
          //   duration: const Duration(milliseconds: 1500),
          // );
        }
      } else {
        // ScaffoldMessenger.of(context).showSnackBar(
        //   SnackBar(content: Text('Error: ${response['message']}')),
        // );
      }
    } catch (e) {
      // ScaffoldMessenger.of(context).showSnackBar(
      //   SnackBar(content: Text('Error: $e')),
      // );
    }
  }

  Future<void> _deletePermission() async {
    try {
      final response = await permissionApiService.deletePermission(
          context, widget.permission['id']);

      if (response['status'] == 200 || response['status'] == 204) {
        SnackBarUtil.showCustomSnackBar(
          context: context,
          message: 'Permission deleted successfully',
          duration: const Duration(milliseconds: 500),
        );

        widget.onPermissionUpdated();
        Navigator.of(context).pop();
      } else if (response['status'] == 400) {
        final errorMessage =
            response['error'] ?? 'An unexpected error occurred';

        if (errorMessage.contains('Cannot delete permission')) {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: const Text('Cannot Delete Permission'),
                content: Text(
                  errorMessage,
                  style: const TextStyle(fontSize: 16),
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
                content: Text('An error occurred: $errorMessage'),
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
      } else {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Error'),
              content: Text(
                  'An unexpected error occurred: ${response['message'] ?? 'Unknown error'}'),
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

  @override
  void dispose() {
    controllerName.dispose();
    controllerDescription.dispose();
    super.dispose();
  }

  void _confirmDeletePermission(
      BuildContext outerContext, Map<String, dynamic> permission) {
    final permissionName = permission['name'] ?? 'Permiso';

    showDialog(
      context: outerContext,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm deletion'),
          content: Text(
              'Are you sure you want to delete the permission? "$permissionName"?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _deletePermission();
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
        height: 380,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20.0),
        ),
        child: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: controllerName,
                decoration: InputDecoration(
                  labelText: 'Permission Name',
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
              const SizedBox(height: 10),
              TextField(
                controller: controllerDescription,
                decoration: InputDecoration(
                  labelText: 'Description',
                  labelStyle: TextStyle(fontSize: 18),
                  border: OutlineInputBorder(),
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
              const SizedBox(height: 40),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      _confirmDeletePermission(context, widget.permission);
                    },
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
                    onPressed: _updatePermission,
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
