import 'package:flutter/material.dart';

import '../../../../../components/SnackBarUtil.dart';
import '../../../../../services/api_model_services/RoleApiService.dart';

class RoleRegisterHelper extends StatefulWidget {
  const RoleRegisterHelper({Key? key}) : super(key: key);

  @override
  _RoleHelperState createState() => _RoleHelperState();
}

class _RoleHelperState extends State<RoleRegisterHelper> {
  final TextEditingController controllerName = TextEditingController();
  final TextEditingController controllerDescription = TextEditingController();
  final RoleApiService roleApiService = RoleApiService();
  bool isSuperUser = false;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  void _saveRole() async {
    if (_formKey.currentState!.validate()) {
      Map<String, dynamic> roleData = {
        "name": controllerName.text,
        "description": controllerDescription.text,
        "is_super_user": isSuperUser,
      };

      try {
        await roleApiService.registerRole(
          context,
          roleData,
          (successMessage) {
            SnackBarUtil.showCustomSnackBar(
              context: context,
              message: successMessage,
              duration: const Duration(milliseconds: 500),
            );
            Navigator.of(context).pop(true);
          },
          (errorMessage) {
            showDialog(
              context: context,
              builder: (context) {
                return AlertDialog(
                  title: const Text(
                    'Error',
                    style: TextStyle(fontSize: 22),
                  ),
                  content: Text(
                    errorMessage,
                    style: const TextStyle(fontSize: 18),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text(
                        'OK',
                        style: TextStyle(fontSize: 18),
                      ),
                    ),
                  ],
                );
              },
            );
          },
        );
      } catch (e) {
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: const Text(
                'Unexpected Error',
                style: TextStyle(fontSize: 22),
              ),
              content: Text(
                'An unexpected error occurred: $e',
                style: const TextStyle(fontSize: 18),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    'OK',
                    style: TextStyle(fontSize: 18),
                  ),
                ),
              ],
            );
          },
        );
      }
    }
  }

  @override
  void dispose() {
    controllerName.dispose();
    controllerDescription.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.0),
      ),
      elevation: 10,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 30.0),
        width: 420,
        height: 480,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20.0),
        ),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                TextFormField(
                  controller: controllerName,
                  decoration: InputDecoration(
                    labelText: 'Role Name',
                    labelStyle: const TextStyle(fontSize: 18),
                    border: OutlineInputBorder(),
                    contentPadding:
                        const EdgeInsets.symmetric(vertical: 15.0, horizontal: 18.0),
                  ),
                  style: const TextStyle(fontSize: 16),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter the role name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: controllerDescription,
                  decoration: InputDecoration(
                    labelText: 'Description',
                    labelStyle: const TextStyle(fontSize: 18),
                    border: OutlineInputBorder(),
                    contentPadding:
                        const EdgeInsets.symmetric(vertical: 15.0, horizontal: 18.0),
                  ),
                  maxLines: 3,
                  style: const TextStyle(fontSize: 16),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter the description';
                    }
                    return null;
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
                ElevatedButton(
                  onPressed: _saveRole,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 34, 118, 186),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      vertical: 22.0,
                      horizontal: 32.0,
                    ),
                    textStyle: const TextStyle(fontSize: 18),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Icon(Icons.save, size: 24),
                      SizedBox(width: 10),
                      Text('Save Role'),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
