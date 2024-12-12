import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../../components/SnackBarUtil.dart';
import '../../../../../services/api_model_services/UserApiService.dart';

class UserRegisterHelper {
  static void showRegisterUserDialog({
    required BuildContext context,
    required List<dynamic> roles,
    required List<dynamic> environments,
    required Function fetchUsers,
  }) {
    final TextEditingController controllerName = TextEditingController();
    final TextEditingController controllerSurname = TextEditingController();
    final TextEditingController controllerEmail = TextEditingController();
    final TextEditingController controllerContact = TextEditingController();
    final TextEditingController controllerUsername = TextEditingController();
    final TextEditingController controllerPassword = TextEditingController();

    String? selectedRole;
    String? selectedEnvironment;
    String? usernameError;
    String? emailError;

    final GlobalKey<FormState> formKey = GlobalKey<FormState>();
    final UserApiService userControllerServices = UserApiService();

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30.0),
          ),
          elevation: 10,
          child: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              List<dynamic> filteredEnvironments = environments;
              if (selectedRole != null &&
                  roles.firstWhere(
                          (role) => role['name'] == selectedRole)['name'] ==
                      "Admin") {
                filteredEnvironments = environments
                    .where((env) => env['name'] == "ADMIN")
                    .toList();
                selectedEnvironment = filteredEnvironments.isNotEmpty
                    ? filteredEnvironments.first['name']
                    : null;
              } else if (selectedRole != null) {
                filteredEnvironments = environments
                    .where((env) => env['name'] != "ADMIN")
                    .toList();
              }
              return Container(
                width: 400,
                height: 840,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(30.0),
                ),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 20.0),
                      child: Text(
                        'Register User',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24.0,
                          vertical: 10.0,
                        ),
                        child: Form(
                          key: formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              TextFormField(
                                controller: controllerName,
                                decoration: InputDecoration(
                                  labelText: 'Name',
                                  border: OutlineInputBorder(),
                                  contentPadding: EdgeInsets.symmetric(
                                    vertical: 15.0,
                                    horizontal: 20.0,
                                  ),
                                ),
                                style: TextStyle(fontSize: 18),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter the name';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 15),
                              TextFormField(
                                controller: controllerSurname,
                                decoration: InputDecoration(
                                  labelText: 'Last name',
                                  border: OutlineInputBorder(),
                                  contentPadding: EdgeInsets.symmetric(
                                    vertical: 15.0,
                                    horizontal: 20.0,
                                  ),
                                ),
                                style: TextStyle(fontSize: 18),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter the last name';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 15),
                              TextFormField(
                                controller: controllerEmail,
                                decoration: InputDecoration(
                                  labelText: 'Email',
                                  errorText: emailError,
                                  border: OutlineInputBorder(),
                                  contentPadding: EdgeInsets.symmetric(
                                    vertical: 15.0,
                                    horizontal: 20.0,
                                  ),
                                ),
                                style: TextStyle(fontSize: 18),
                                keyboardType: TextInputType.emailAddress,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter the email address';
                                  }
                                  if (!RegExp(r'^[^@]+@[^@]+\.[^@]+')
                                      .hasMatch(value)) {
                                    return 'Please enter a valid email address';
                                  }
                                  return null;
                                },
                                onChanged: (_) {
                                  setState(() {
                                    emailError =
                                        null; 
                                  });
                                },
                              ),
                              const SizedBox(height: 15),
                              TextFormField(
                                controller: controllerContact,
                                decoration: InputDecoration(
                                  labelText: 'Phone number',
                                  border: OutlineInputBorder(),
                                  contentPadding: EdgeInsets.symmetric(
                                    vertical: 15.0,
                                    horizontal: 20.0,
                                  ),
                                ),
                                style: TextStyle(fontSize: 18),
                                keyboardType: TextInputType
                                    .number, 
                                inputFormatters: <TextInputFormatter>[
                                  FilteringTextInputFormatter
                                      .digitsOnly, 
                                ],
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter the phone number';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 15),
                              TextFormField(
                                controller: controllerUsername,
                                decoration: InputDecoration(
                                  labelText: 'Username',
                                  errorText:
                                      usernameError, 
                                  border: OutlineInputBorder(),
                                  contentPadding: EdgeInsets.symmetric(
                                    vertical: 15.0,
                                    horizontal: 20.0,
                                  ),
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter the username';
                                  }
                                  return null;
                                },
                                onChanged: (_) {
                                  setState(() {
                                    usernameError =
                                        null; 
                                  });
                                },
                              ),
                              const SizedBox(height: 15),
                              TextFormField(
                                controller: controllerPassword,
                                decoration: InputDecoration(
                                  labelText: 'Password',
                                  border: OutlineInputBorder(),
                                  contentPadding: EdgeInsets.symmetric(
                                    vertical: 15.0,
                                    horizontal: 20.0,
                                  ),
                                ),
                                style: TextStyle(fontSize: 18),
                                obscureText: true,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter the password';
                                  }
                                  if (value.length < 8) {
                                    return 'Password must be at least 8 characters long';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 15),
                              Text(
                                'Role',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 10),
                              DropdownButton<String>(
                                value: selectedRole,
                                hint: Text(
                                  'Select a Role',
                                  style: TextStyle(fontSize: 18),
                                ),
                                isExpanded: true,
                                items: roles.map((role) {
                                  return DropdownMenuItem<String>(
                                    value: role['name'],
                                    child: Text(
                                      role['name'],
                                      style: TextStyle(fontSize: 18),
                                    ),
                                  );
                                }).toList(),
                                onChanged: (String? newRole) {
                                  setState(() {
                                    selectedRole = newRole;
                                    selectedEnvironment = null;
                                  });
                                },
                              ),
                              const SizedBox(height: 15),
                              Text(
                                'Environment',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 10),
                              DropdownButton<String>(
                                value: selectedEnvironment,
                                hint: Text(
                                  'Select an Environment',
                                  style: TextStyle(fontSize: 18),
                                ),
                                isExpanded: true,
                                items: filteredEnvironments.map((env) {
                                  return DropdownMenuItem<String>(
                                    value: env['name'],
                                    child: Text(
                                      env['name'],
                                      style: TextStyle(fontSize: 18),
                                    ),
                                  );
                                }).toList(),
                                onChanged: selectedRole == null
                                    ? null
                                    : (String? newEnvironment) {
                                        setState(() {
                                          selectedEnvironment = newEnvironment;
                                        });
                                      },
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: ElevatedButton(
                        onPressed: () async {
                          if (formKey.currentState!.validate()) {
                            Map<String, dynamic> userData = {
                              "first_name": controllerName.text,
                              "last_name": controllerSurname.text,
                              "email": controllerEmail.text,
                              "contact_number": controllerContact.text,
                              "username": controllerUsername.text,
                              "password": controllerPassword.text,
                              "role_id": roles.firstWhere(
                                  (role) => role['name'] == selectedRole)['id'],
                              "environment_id": environments.firstWhere((env) =>
                                  env['name'] == selectedEnvironment)['id'],
                            };

                            try {
                              final response = await userControllerServices
                                  .registerUser(context, userData);

                              if (response['status'] == 200 ||
                                  response['status'] == 201) {
                                fetchUsers();
                                Navigator.of(context).pop();
                              } else if (response['error'] ==
                                  'Username already exists') {
                                setState(() {
                                  usernameError =
                                      'Username already exists'; 
                                });
                               } else if (response['error'] ==
                                  'Email already exists') {
                                setState(() {
                                  emailError = 'Email already exists';
                                });
                              }  else {
                                // SnackBarUtil.showCustomSnackBar(
                                //   context: context,
                                //   message:
                                //       response['error'] ?? 'An error occurred',
                                // );
                              }
                            } catch (e) {
                              SnackBarUtil.showCustomSnackBar(
                                context: context,
                                message: 'An unexpected error occurred',
                              );
                            }
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              const Color.fromARGB(255, 34, 118, 186),
                              foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            vertical: 15.0,
                            horizontal: 40.0,
                          ),
                          textStyle: const TextStyle(fontSize: 20),
                        ),
                        child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Icon(Icons.save, size: 24),
                      SizedBox(width: 10),
                      Text('Save User'),
                    ],
                  ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }
}
