import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../../components/SnackBarUtil.dart';
import '../../../../../services/api_model_services/UserApiService.dart';

class UserDetailHelper {
  static void viewUserDetails({
    required BuildContext context,
    required Map<String, dynamic> user,
    required List<dynamic> roles,
    required List<dynamic> environments,
    required Function fetchUsers,
    required Function confirmDeleteUser,
    required int currentUserId,
  }) {
    TextEditingController firstNameController =
        TextEditingController(text: user['first_name'] ?? 'No First Name');
    TextEditingController lastNameController =
        TextEditingController(text: user['last_name'] ?? 'No Last Name');
    TextEditingController emailController =
        TextEditingController(text: user['email'] ?? 'No Email');
    TextEditingController usernameController =
        TextEditingController(text: user['username'] ?? 'No Username');
    TextEditingController contactNumberController = TextEditingController(
        text: user['contact_number'] ?? 'No Contact Number');

    String? selectedRole = user['role']?['id']?.toString();
    String? selectedEnvironment = user['environment']?['id']?.toString();
    final UserApiService userControllerServices = UserApiService();

    final bool isDeleted = user['is_deleted'] ?? false;
    final bool isCurrentUser = user['id'] == currentUserId;
    String? emailError;

    bool isValidEmail(String email) {
      final emailRegex =
          RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,4}$');
      return emailRegex.hasMatch(email);
    }

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            final bool isAdminRole = selectedRole != null &&
                roles.firstWhere((role) =>
                        role['id'].toString() == selectedRole)['name'] ==
                    "Admin";
            final bool isAdminEnvironment = selectedEnvironment != null &&
                environments.firstWhere((env) =>
                        env['id'].toString() == selectedEnvironment)['name'] ==
                    "ADMIN";

            List<dynamic> filteredEnvironments = environments;
            if (!isAdminRole) {
              filteredEnvironments =
                  environments.where((env) => env['name'] != "ADMIN").toList();
            }
            if (!isAdminRole &&
                isAdminEnvironment &&
                filteredEnvironments.isNotEmpty) {
              selectedEnvironment = filteredEnvironments.first['id'].toString();
            }

            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.0),
              ),
              elevation: 10,
              child: Container(
                width: 400,
                height: 700,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20.0),
                ),
                child: Column(
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            TextField(
                              controller: usernameController,
                              decoration: InputDecoration(
                                labelText: 'Username',
                                labelStyle: const TextStyle(fontSize: 18),
                                border: OutlineInputBorder(),
                                contentPadding: EdgeInsets.symmetric(
                                    vertical: 15.0, horizontal: 20.0),
                                errorText: usernameController.text.isEmpty
                                    ? 'This field is required'
                                    : null,
                              ),
                              enabled: !isDeleted && !isCurrentUser,
                            ),
                            const SizedBox(height: 15),
                            TextField(
                              controller: contactNumberController,
                              decoration: InputDecoration(
                                labelText: 'Phone Number',
                                labelStyle: const TextStyle(fontSize: 18),
                                border: const OutlineInputBorder(),
                                contentPadding: const EdgeInsets.symmetric(
                                    vertical: 15.0, horizontal: 20.0),
                                errorText: contactNumberController.text.isEmpty
                                    ? 'This field is required'
                                    : null,
                              ),
                              keyboardType: TextInputType.number,
                              inputFormatters: <TextInputFormatter>[
                                FilteringTextInputFormatter.digitsOnly,
                              ],
                              enabled: !isDeleted && !isCurrentUser,
                            ),
                            const SizedBox(height: 15),
                            TextField(
                              controller: firstNameController,
                              decoration: InputDecoration(
                                labelText: 'First Name',
                                labelStyle: const TextStyle(fontSize: 18),
                                border: const OutlineInputBorder(),
                                contentPadding: const EdgeInsets.symmetric(
                                    vertical: 15.0, horizontal: 20.0),
                                errorText: firstNameController.text.isEmpty
                                    ? 'This field is required'
                                    : null,
                              ),
                              enabled: !isDeleted && !isCurrentUser,
                            ),
                            const SizedBox(height: 15),
                            TextField(
                              controller: lastNameController,
                              decoration: InputDecoration(
                                labelText: 'Last Name',
                                border: const OutlineInputBorder(),
                                contentPadding: const EdgeInsets.symmetric(
                                    vertical: 15.0, horizontal: 20.0),
                                errorText: lastNameController.text.isEmpty
                                    ? 'This field is required'
                                    : null,
                              ),
                              enabled: !isDeleted && !isCurrentUser,
                            ),
                            const SizedBox(height: 15),
                            TextField(
                              controller: emailController,
                              decoration: InputDecoration(
                                labelText: 'Email',
                                labelStyle: const TextStyle(fontSize: 18),
                                border: const OutlineInputBorder(),
                                contentPadding: const EdgeInsets.symmetric(
                                    vertical: 15.0, horizontal: 20.0),
                                errorText: emailError,
                              ),
                              enabled: !isDeleted && !isCurrentUser,
                            ),
                            const SizedBox(height: 15),
                            Text('Role',
                                style: TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 10),
                            DropdownButton<String>(
                              value: selectedRole,
                              hint: const Text('Select Role',
                                  style: TextStyle(fontSize: 16)),
                              isExpanded: true,
                              items: roles.map((role) {
                                return DropdownMenuItem<String>(
                                  value: role['id'].toString(),
                                  child: Text(role['name'],
                                      style: const TextStyle(fontSize: 16)),
                                );
                              }).toList(),
                              onChanged: (!isDeleted && !isCurrentUser)
                                  ? (String? newRole) {
                                      setState(() {
                                        selectedRole = newRole;
                                        if (newRole != null &&
                                            roles.firstWhere((role) =>
                                                    role['id'].toString() ==
                                                    newRole)['name'] ==
                                                "Admin") {
                                          selectedEnvironment = environments
                                              .firstWhere((env) =>
                                                  env['name'] == "ADMIN")['id']
                                              .toString();
                                        }
                                      });
                                    }
                                  : null,
                            ),
                            const SizedBox(height: 15),
                            Text('Environment',
                                style: TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 10),
                            DropdownButton<String>(
                              value: selectedEnvironment,
                              hint: const Text('Select Environment',
                                  style: TextStyle(fontSize: 16)),
                              isExpanded: true,
                              items: filteredEnvironments.map((env) {
                                return DropdownMenuItem<String>(
                                  value: env['id'].toString(),
                                  child: Text(env['name'],
                                      style: const TextStyle(fontSize: 16)),
                                );
                              }).toList(),
                              onChanged:
                                  (!isAdminRole && !isDeleted && !isCurrentUser)
                                      ? (String? newEnv) {
                                          setState(() {
                                            selectedEnvironment = newEnv;
                                          });
                                        }
                                      : null,
                            ),
                          ],
                        ),
                      ),
                    ),
                    if (!isDeleted && !isCurrentUser)
                      Container(
                        padding: const EdgeInsets.all(16.0),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(20.0),
                            bottomRight: Radius.circular(20.0),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.2),
                              spreadRadius: 1,
                              blurRadius: 2,
                              offset: Offset(0, -2),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            ElevatedButton(
                              onPressed: () => confirmDeleteUser(context, user),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                                minimumSize: Size(150, 50),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.delete,
                                      color: Colors.white, size: 24),
                                  const SizedBox(width: 10),
                                  const Text(
                                    'Delete',
                                    style: TextStyle(
                                        color: Colors.white, fontSize: 18),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 20),
                            ElevatedButton(
                              onPressed: () async {
                                final email = emailController.text.trim();
                                final firstName =
                                    firstNameController.text.trim();
                                final lastName = lastNameController.text.trim();
                                final username = usernameController.text.trim();
                                final contactNumber =
                                    contactNumberController.text.trim();

                                setState(() {
                                  emailError = email.isEmpty
                                      ? 'This field is required'
                                      : (!isValidEmail(email)
                                          ? 'Please enter a valid email address'
                                          : null);

                                  firstNameController.text =
                                      firstName.isEmpty ? '' : firstName;
                                  lastNameController.text =
                                      lastName.isEmpty ? '' : lastName;
                                  usernameController.text =
                                      username.isEmpty ? '' : username;
                                  contactNumberController.text =
                                      contactNumber.isEmpty
                                          ? ''
                                          : contactNumber;
                                });

                                if (emailError != null ||
                                    firstName.isEmpty ||
                                    lastName.isEmpty ||
                                    username.isEmpty ||
                                    contactNumber.isEmpty) {
                                  return;
                                }

                                final userId = user['id'];
                                final updatedData = {
                                  "first_name": firstName,
                                  "last_name": lastName,
                                  "email": email,
                                  "username": username,
                                  "contact_number": contactNumber,
                                  "role_id": int.parse(selectedRole!),
                                  "environment_id":
                                      int.parse(selectedEnvironment!),
                                };

                                try {
                                  final response =
                                      await userControllerServices.updateUser(
                                    context,
                                    userId,
                                    updatedData,
                                  );

                                  if (response['status'] == 200) {
                                    SnackBarUtil.showCustomSnackBar(
                                      context: context,
                                      message: 'User updated successfully',
                                      duration:
                                          const Duration(milliseconds: 500),
                                    );
                                    fetchUsers();
                                    Navigator.of(context).pop();
                                  }
                                } catch (e) {
                                  // Error handling
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color.fromARGB(255, 34, 118, 186),
                                minimumSize: Size(150, 50),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.save,
                                      color: Colors.white, size: 24),
                                  const SizedBox(width: 10),
                                  const Text(
                                    'Save',
                                    style: TextStyle(
                                        color: Colors.white, fontSize: 18),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
