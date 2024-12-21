import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import '../../../models/base_model.dart';
import '../../../services/api_services/answer_submitted_service.dart';
import '../../../services/api_services/api_client.dart';
import '../../../configs/api_config.dart';
import '../../../services/api_services/auth_service.dart';
import '../../../services/api_services/role_permission_service.dart';
import '../../../services/api_services/role_service.dart';
import '../../../services/api_services/permission_service.dart';
import '../../../services/api_services/user_service.dart';
import '../../../services/api_services/environment_service.dart';
import '../../../services/api_services/form_service.dart';
import '../../../services/api_services/question_service.dart';
import '../../../services/api_services/question_type_service.dart';
import '../../../services/api_services/form_question_service.dart';
import '../../../services/api_services/answer_service.dart';
import '../../../services/api_services/form_answer_service.dart';
import '../../../services/api_services/form_submission_service.dart';
import '../../../services/api_services/attachment_service.dart';
import '../../../services/api_services/export_service.dart';
import '../../components/json_viewer.dart';

class ParamConfig {
  final String type;
  final bool required;
  final dynamic defaultValue;
  final String? description;
  final String? hint;
  final bool isPassword;
  final List<String>? options;

  const ParamConfig({
    required this.type,
    this.required = true,
    this.defaultValue,
    this.description,
    this.hint,
    this.isPassword = false,
    this.options,
  });
}

class FileHelper {
  static Future<String> saveFile(Uint8List bytes, String filename, BuildContext context) async {
    try {
      final appDir = await getApplicationDocumentsDirectory();
      final String filePath = '${appDir.path}/$filename';

      // Write bytes to file
      final File file = File(filePath);
      await file.writeAsBytes(bytes);

      // Show success snackbar
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('File downloaded successfully!'),
                const SizedBox(height: 4),
                Text(
                  'Saved to: $filePath',
                  style: const TextStyle(fontSize: 12),
                ),
              ],
            ),
            duration: const Duration(seconds: 5),
          ),
        );
      }

      return filePath;
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving file: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
      throw Exception('Failed to save file: $e');
    }
  }
}

// Helper function to parse parameter values based on their type
dynamic parseParamValue(String value, String type) {
  if (value.isEmpty) return null;

  switch (type.toLowerCase()) {
    case 'number':
    case 'int':
      return int.tryParse(value);
    case 'double':
    case 'float':
      return double.tryParse(value);
    case 'boolean':
    case 'bool':
      return value.toLowerCase() == 'true';
    case 'datetime':
      return DateTime.tryParse(value);
    default:
      return value;
  }
}

class ServiceOperation {
  final String name;
  final Future<dynamic> Function(Map<String, dynamic>) operation;
  final Map<String, ParamConfig> params;
  final String? description;

  const ServiceOperation({
    required this.name,
    required this.operation,
    this.params = const {},
    this.description,
  });
}

class ServiceCategory {
  final String name;
  final List<ServiceOperation> operations;
  final String? description;

  const ServiceCategory({
    required this.name,
    required this.operations,
    this.description,
  });
}

class ApiTestScreen extends StatefulWidget {
  const ApiTestScreen({super.key});

  @override
  State<ApiTestScreen> createState() => _ApiTestScreenState();
}

class _ApiTestScreenState extends State<ApiTestScreen> {
  late final ApiClient _apiClient;
  late final List<ServiceCategory> _serviceCategories;
  bool _isAuthenticated = false;

// Services
  late final AuthService _authService;
  late final UserService _userService;
  late final RoleService _roleService;
  late final RolePermissionService _rolePermissionService;
  late final PermissionService _permissionService;
  late final EnvironmentService _environmentService;
  late final FormService _formService;
  late final QuestionService _questionService;
  late final QuestionTypeService _questionTypeService;
  late final FormQuestionService _formQuestionService;
  late final AnswerService _answerService;
  late final AnswerSubmittedService _answerSubmittedService;
  late final FormAnswerService _formAnswerService;
  late final FormSubmissionService _formSubmissionService;
  late final AttachmentService _attachmentService;
  late final ExportService _exportService;

  Map<String, dynamic>? _result;
  String? _error;
  bool _isLoading = false;
  String _selectedCategory = '';
  final Map<String, TextEditingController> _paramControllers = {};

  @override
  void initState() {
    super.initState();
    _initializeServices();
    _initializeServiceCategories();
    _checkAuthStatus();
  }

  @override
  void dispose() {
    for (var controller in _paramControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _checkAuthStatus() async {
    final token = await _apiClient.getToken();
    setState(() {
      _isAuthenticated = token != null;
    });
  }

  void _initializeServices() {
    _apiClient = ApiClient(baseUrl: ApiConfig.baseUrl);
    _authService = AuthService(_apiClient);
    _userService = UserService(_apiClient);
    _roleService = RoleService(_apiClient);
    _permissionService = PermissionService(_apiClient);
    _rolePermissionService = RolePermissionService(_apiClient);
    _environmentService = EnvironmentService(_apiClient);
    _formService = FormService(_apiClient);
    _questionService = QuestionService(_apiClient);
    _questionTypeService = QuestionTypeService(_apiClient);
    _formQuestionService = FormQuestionService(_apiClient);
    _answerService = AnswerService(_apiClient);
    _formAnswerService = FormAnswerService(_apiClient);
    _formSubmissionService = FormSubmissionService(_apiClient);
    _attachmentService = AttachmentService(_apiClient);
    _exportService = ExportService(_apiClient);
  }

  void _initializeServiceCategories() {
    _serviceCategories = [
      ServiceCategory(
        name: 'Authentication',
        description: 'User authentication and current user operations',
        operations: [
          ServiceOperation(
            name: 'Login',
            description: 'Authenticate user and get access token',
            params: {
              'username': ParamConfig(
                type: 'string',
                required: true,
                hint: 'Enter username',
              ),
              'password': ParamConfig(
                type: 'string',
                required: true,
                isPassword: true,
                hint: 'Enter password',
              ),
            },
            operation: (params) => _authService.login(
              params['username'],
              params['password'],
            ),
          ),
          ServiceOperation(
            name: 'Get Current User',
            description: 'Get currently authenticated user details',
            operation: (params) => _authService.getCurrentUser(),
          ),
        ],
      ),
      ServiceCategory(
        name: 'Users',
        description: 'User management operations',
        operations: [
          ServiceOperation(
            name: 'Get All Users',
            description: 'Retrieve all system users',
            params: {
              'includeDeleted': ParamConfig(
                type: 'boolean',
                required: false,
                defaultValue: false,
                description: 'Include soft-deleted users',
              ),
            },
            operation: (params) => _userService.getAllUsers(
              includeDeleted: params['includeDeleted'] ?? false,
            ),
          ),
          ServiceOperation(
            name: 'Get Users by Role',
            description: 'Get users with specific role',
            params: {
              'roleId': ParamConfig(
                type: 'int',
                required: true,
                hint: 'Enter role ID',
              ),
            },
            operation: (params) =>
                _userService.getUsersByRole(params['roleId']),
          ),
          ServiceOperation(
            name: 'Get Users by Environment',
            description: 'Get users in specific environment',
            params: {
              'environmentId': ParamConfig(
                type: 'int',
                required: true,
                hint: 'Enter environment ID',
              ),
            },
            operation: (params) =>
                _userService.getUsersByEnvironment(params['environmentId']),
          ),
          ServiceOperation(
            name: 'Register User',
            description: 'Create new user account',
            params: {
              'firstName': ParamConfig(type: 'string', required: true),
              'lastName': ParamConfig(type: 'string', required: true),
              'email': ParamConfig(type: 'string', required: true),
              'contactNumber': ParamConfig(type: 'string', required: true),
              'username': ParamConfig(type: 'string', required: true),
              'password':
                  ParamConfig(type: 'string', required: true, isPassword: true),
              'roleId': ParamConfig(type: 'int', required: true),
              'environmentId': ParamConfig(type: 'int', required: true),
            },
            operation: (params) => _userService.registerUser(
              firstName: params['firstName'],
              lastName: params['lastName'],
              email: params['email'],
              contactNumber: params['contactNumber'],
              username: params['username'],
              password: params['password'],
              roleId: params['roleId'],
              environmentId: params['environmentId'],
            ),
          ),
          ServiceOperation(
            name: 'Update User',
            description: 'Update existing user details',
            params: {
              'userId': ParamConfig(type: 'int', required: true),
              'firstName': ParamConfig(type: 'string', required: false),
              'lastName': ParamConfig(type: 'string', required: false),
              'email': ParamConfig(type: 'string', required: false),
              'contactNumber': ParamConfig(type: 'string', required: false),
              'username': ParamConfig(type: 'string', required: false),
              'password': ParamConfig(
                  type: 'string', required: false, isPassword: true),
              'roleId': ParamConfig(type: 'int', required: false),
              'environmentId': ParamConfig(type: 'int', required: false),
            },
            operation: (params) => _userService.updateUser(
              params['userId'],
              firstName: params['firstName'],
              lastName: params['lastName'],
              email: params['email'],
              contactNumber: params['contactNumber'],
              username: params['username'],
              password: params['password'],
              roleId: params['roleId'],
              environmentId: params['environmentId'],
            ),
          ),
          ServiceOperation(
            name: 'Delete User',
            description: 'Soft delete user account',
            params: {
              'userId': ParamConfig(
                type: 'int',
                required: true,
                hint: 'Enter user ID',
              ),
            },
            operation: (params) => _userService.deleteUser(params['userId']),
          ),
        ],
      ),
      ServiceCategory(
        name: 'Roles',
        description: 'Role management operations',
        operations: [
          ServiceOperation(
            name: 'Get All Roles',
            description: 'Retrieve all system roles',
            operation: (params) => _roleService.getAllRoles(),
          ),
          ServiceOperation(
            name: 'Get Role',
            description: 'Get specific role details',
            params: {
              'roleId': ParamConfig(
                type: 'int',
                required: true,
                hint: 'Enter role ID',
              ),
            },
            operation: (params) => _roleService.getRole(params['roleId']),
          ),
          ServiceOperation(
            name: 'Create Role',
            description: 'Create new role',
            params: {
              'name': ParamConfig(type: 'string', required: true),
              'description': ParamConfig(type: 'string', required: false),
              'isSuperUser': ParamConfig(
                type: 'boolean',
                required: false,
                defaultValue: false,
              ),
            },
            operation: (params) => _roleService.createRole(
              name: params['name'],
              description: params['description'],
              isSuperUser: params['isSuperUser'] ?? false,
            ),
          ),
          ServiceOperation(
            name: 'Update Role',
            description: 'Update existing role',
            params: {
              'roleId': ParamConfig(type: 'int', required: true),
              'name': ParamConfig(type: 'string', required: false),
              'description': ParamConfig(type: 'string', required: false),
              'isSuperUser': ParamConfig(type: 'boolean', required: false),
            },
            operation: (params) => _roleService.updateRole(
              params['roleId'],
              name: params['name'],
              description: params['description'],
              isSuperUser: params['isSuperUser'],
            ),
          ),
          ServiceOperation(
            name: 'Delete Role',
            description: 'Delete role',
            params: {
              'roleId': ParamConfig(
                type: 'int',
                required: true,
                hint: 'Enter role ID',
              ),
            },
            operation: (params) => _roleService.deleteRole(params['roleId']),
          ),
        ],
      ),
      ServiceCategory(
        name: 'Permissions',
        description: 'Permission management operations',
        operations: [
          ServiceOperation(
            name: 'Get All Permissions',
            description: 'Retrieve all system permissions',
            operation: (params) => _permissionService.getAllPermissions(),
          ),
          ServiceOperation(
            name: 'Get Permission',
            description: 'Get specific permission details',
            params: {
              'permissionId': ParamConfig(
                type: 'int',
                required: true,
                hint: 'Enter permission ID',
              ),
            },
            operation: (params) =>
                _permissionService.getPermission(params['permissionId']),
          ),
          ServiceOperation(
            name: 'Create Permission',
            description: 'Create new permission',
            params: {
              'name': ParamConfig(type: 'string', required: true),
              'description': ParamConfig(type: 'string', required: false),
            },
            operation: (params) => _permissionService.createPermission(
              name: params['name'],
              description: params['description'],
            ),
          ),
          ServiceOperation(
            name: 'Check User Permission',
            description: 'Check if user has specific permission',
            params: {
              'userId': ParamConfig(type: 'int', required: true),
              'permissionName': ParamConfig(type: 'string', required: true),
            },
            operation: (params) => _permissionService.checkUserPermission(
              params['userId'],
              params['permissionName'],
            ),
          ),
        ],
      ),
      ServiceCategory(
        name: 'Role Permissions',
        description: 'Role-Permission relationship operations',
        operations: [
          ServiceOperation(
            name: 'Get All Role Permissions',
            description: 'Retrieve all role-permission mappings',
            operation: (params) =>
                _rolePermissionService.getAllRolePermissions(),
          ),
          ServiceOperation(
            name: 'Get Roles with Permissions',
            description: 'Get all roles with their permissions',
            operation: (params) =>
                _rolePermissionService.getRolesWithPermissions(),
          ),
          ServiceOperation(
            name: 'Get Permissions by Role',
            description: 'Get permissions for specific role',
            params: {
              'roleId': ParamConfig(
                type: 'int',
                required: true,
                hint: 'Enter role ID',
              ),
            },
            operation: (params) =>
                _rolePermissionService.getPermissionsByRole(params['roleId']),
          ),
          ServiceOperation(
            name: 'Assign Permission to Role',
            description: 'Add permission to role',
            params: {
              'roleId': ParamConfig(type: 'int', required: true),
              'permissionId': ParamConfig(type: 'int', required: true),
            },
            operation: (params) =>
                _rolePermissionService.assignPermissionToRole(
              params['roleId'],
              params['permissionId'],
            ),
          ),
        ],
      ),
      ServiceCategory(
        name: 'Environments',
        description: 'Environment management operations',
        operations: [
          ServiceOperation(
            name: 'Get All Environments',
            description: 'Retrieve all environments',
            params: {
              'includeDeleted': ParamConfig(
                type: 'boolean',
                required: false,
                defaultValue: false,
              ),
            },
            operation: (params) => _environmentService.getAllEnvironments(
              includeDeleted: params['includeDeleted'] ?? false,
            ),
          ),
          ServiceOperation(
            name: 'Get Environment',
            description: 'Get specific environment details',
            params: {
              'environmentId': ParamConfig(
                type: 'int',
                required: true,
                hint: 'Enter environment ID',
              ),
            },
            operation: (params) =>
                _environmentService.getEnvironment(params['environmentId']),
          ),
          ServiceOperation(
            name: 'Get Environment by Name',
            description: 'Get environment by its name',
            params: {
              'name': ParamConfig(
                type: 'string',
                required: true,
                hint: 'Enter environment name',
              ),
            },
            operation: (params) =>
                _environmentService.getEnvironmentByName(params['name']),
          ),
          ServiceOperation(
            name: 'Create Environment',
            description: 'Create new environment',
            params: {
              'name': ParamConfig(type: 'string', required: true),
              'description': ParamConfig(type: 'string', required: false),
            },
            operation: (params) => _environmentService.createEnvironment(
              name: params['name'],
              description: params['description'],
            ),
          ),
          ServiceOperation(
            name: 'Update Environment',
            description: 'Update existing environment',
            params: {
              'environmentId': ParamConfig(type: 'int', required: true),
              'name': ParamConfig(type: 'string', required: false),
              'description': ParamConfig(type: 'string', required: false),
            },
            operation: (params) => _environmentService.updateEnvironment(
              params['environmentId'],
              name: params['name'],
              description: params['description'],
            ),
          ),
          ServiceOperation(
            name: 'Delete Environment',
            description: 'Delete environment',
            params: {
              'environmentId': ParamConfig(
                type: 'int',
                required: true,
                hint: 'Enter environment ID',
              ),
            },
            operation: (params) =>
                _environmentService.deleteEnvironment(params['environmentId']),
          ),
        ],
      ),
      ServiceCategory(
        name: 'Forms',
        description: 'Form management operations',
        operations: [
          ServiceOperation(
            name: 'Get All Forms',
            description: 'Retrieve all forms',
            operation: (params) => _formService.getAllForms(),
          ),
          ServiceOperation(
            name: 'Get Form',
            description: 'Get specific form details',
            params: {
              'formId': ParamConfig(
                type: 'int',
                required: true,
                hint: 'Enter form ID',
              ),
            },
            operation: (params) => _formService.getForm(params['formId']),
          ),
          ServiceOperation(
            name: 'Get Forms by Environment',
            description: 'Get forms in specific environment',
            params: {
              'environmentId': ParamConfig(
                type: 'int',
                required: true,
                hint: 'Enter environment ID',
              ),
            },
            operation: (params) =>
                _formService.getFormsByEnvironment(params['environmentId']),
          ),
          ServiceOperation(
            name: 'Get Public Forms',
            description: 'Get all public forms',
            operation: (params) => _formService.getPublicForms(),
          ),
          ServiceOperation(
            name: 'Create Form',
            description: 'Create new form',
            params: {
              'title': ParamConfig(type: 'string', required: true),
              'description': ParamConfig(type: 'string', required: false),
              'isPublic': ParamConfig(
                type: 'boolean',
                required: false,
                defaultValue: false,
              ),
            },
            operation: (params) => _formService.createForm(
              title: params['title'],
              description: params['description'],
              isPublic: params['isPublic'] ?? false,
            ),
          ),
          ServiceOperation(
            name: 'Update Form',
            description: 'Update existing form',
            params: {
              'formId': ParamConfig(type: 'int', required: true),
              'title': ParamConfig(type: 'string', required: false),
              'description': ParamConfig(type: 'string', required: false),
              'isPublic': ParamConfig(type: 'boolean', required: false),
            },
            operation: (params) => _formService.updateForm(
              params['formId'],
              title: params['title'],
              description: params['description'],
              isPublic: params['isPublic'],
            ),
          ),
          ServiceOperation(
            name: 'Delete Form',
            description: 'Delete form',
            params: {
              'formId': ParamConfig(
                type: 'int',
                required: true,
                hint: 'Enter form ID',
              ),
            },
            operation: (params) => _formService.deleteForm(params['formId']),
          ),
          ServiceOperation(
            name: 'Get Form Statistics',
            description: 'Get form usage statistics',
            params: {
              'formId': ParamConfig(
                type: 'int',
                required: true,
                hint: 'Enter form ID',
              ),
            },
            operation: (params) =>
                _formService.getFormStatistics(params['formId']),
          ),
        ],
      ),
      ServiceCategory(
        name: 'Questions',
        description: 'Question management operations',
        operations: [
          ServiceOperation(
            name: 'Get All Questions',
            description: 'Retrieve all questions',
            operation: (params) => _questionService.getAllQuestions(),
          ),
          ServiceOperation(
            name: 'Get Questions by Type',
            description: 'Get questions of specific type',
            params: {
              'typeId': ParamConfig(
                type: 'int',
                required: true,
                hint: 'Enter question type ID',
              ),
            },
            operation: (params) =>
                _questionService.getQuestionsByType(params['typeId']),
          ),
          ServiceOperation(
            name: 'Get Question',
            description: 'Get specific question details',
            params: {
              'questionId': ParamConfig(
                type: 'int',
                required: true,
                hint: 'Enter question ID',
              ),
            },
            operation: (params) =>
                _questionService.getQuestion(params['questionId']),
          ),
          ServiceOperation(
            name: 'Create Question',
            description: 'Create new question',
            params: {
              'text': ParamConfig(type: 'string', required: true),
              'questionTypeId': ParamConfig(type: 'int', required: true),
              'isSignature': ParamConfig(
                type: 'boolean',
                required: false,
                defaultValue: false,
              ),
              'remarks': ParamConfig(type: 'string', required: false),
            },
            operation: (params) => _questionService.createQuestion(
              text: params['text'],
              questionTypeId: params['questionTypeId'],
              isSignature: params['isSignature'] ?? false,
              remarks: params['remarks'],
            ),
          ),
          ServiceOperation(
            name: 'Update Question',
            description: 'Update existing question',
            params: {
              'questionId': ParamConfig(type: 'int', required: true),
              'text': ParamConfig(type: 'string', required: false),
              'questionTypeId': ParamConfig(type: 'int', required: false),
              'isSignature': ParamConfig(type: 'boolean', required: false),
              'remarks': ParamConfig(type: 'string', required: false),
            },
            operation: (params) => _questionService.updateQuestion(
              params['questionId'],
              text: params['text'],
              questionTypeId: params['questionTypeId'],
              isSignature: params['isSignature'],
              remarks: params['remarks'],
            ),
          ),
          ServiceOperation(
            name: 'Delete Question',
            description: 'Delete question',
            params: {
              'questionId': ParamConfig(
                type: 'int',
                required: true,
                hint: 'Enter question ID',
              ),
            },
            operation: (params) =>
                _questionService.deleteQuestion(params['questionId']),
          ),
        ],
      ),
      ServiceCategory(
        name: 'Question Types',
        description: 'Question type management operations',
        operations: [
          ServiceOperation(
            name: 'Get All Question Types',
            description: 'Retrieve all question types',
            operation: (params) => _questionTypeService.getAllQuestionTypes(),
          ),
          ServiceOperation(
            name: 'Get Question Type',
            description: 'Get specific question type details',
            params: {
              'typeId': ParamConfig(
                type: 'int',
                required: true,
                hint: 'Enter question type ID',
              ),
            },
            operation: (params) =>
                _questionTypeService.getQuestionType(params['typeId']),
          ),
          ServiceOperation(
            name: 'Create Question Type',
            description: 'Create new question type',
            params: {
              'type': ParamConfig(
                type: 'string',
                required: true,
                hint: 'Enter question type',
              ),
            },
            operation: (params) => _questionTypeService.createQuestionType(
              type: params['type'],
            ),
          ),
          ServiceOperation(
            name: 'Update Question Type',
            description: 'Update existing question type',
            params: {
              'typeId': ParamConfig(type: 'int', required: true),
              'type': ParamConfig(type: 'string', required: true),
            },
            operation: (params) => _questionTypeService.updateQuestionType(
              params['typeId'],
              type: params['type'],
            ),
          ),
          ServiceOperation(
            name: 'Delete Question Type',
            description: 'Delete question type',
            params: {
              'typeId': ParamConfig(
                type: 'int',
                required: true,
                hint: 'Enter question type ID',
              ),
            },
            operation: (params) =>
                _questionTypeService.deleteQuestionType(params['typeId']),
          ),
        ],
      ),
      ServiceCategory(
        name: 'Form Questions',
        description: 'Form question relationship operations',
        operations: [
          ServiceOperation(
            name: 'Get All Form Questions',
            description: 'Retrieve all form questions',
            params: {
              'includeRelations': ParamConfig(
                type: 'boolean',
                required: false,
                defaultValue: true,
              ),
              'page': ParamConfig(type: 'int', required: false),
              'perPage': ParamConfig(type: 'int', required: false),
              'formId': ParamConfig(type: 'int', required: false),
            },
            operation: (params) => _formQuestionService.getAllFormQuestions(
              includeRelations: params['includeRelations'] ?? true,
              page: params['page'],
              perPage: params['perPage'],
              formId: params['formId'],
            ),
          ),
          ServiceOperation(
            name: 'Create Form Question',
            description: 'Add question to form',
            params: {
              'formId': ParamConfig(type: 'int', required: true),
              'questionId': ParamConfig(type: 'int', required: true),
              'orderNumber': ParamConfig(type: 'int', required: false),
            },
            operation: (params) => _formQuestionService.createFormQuestion(
              formId: params['formId'],
              questionId: params['questionId'],
              orderNumber: params['orderNumber'],
            ),
          ),
          ServiceOperation(
            name: 'Get Form Question',
            description: 'Get specific form question details',
            params: {
              'formQuestionId': ParamConfig(
                type: 'int',
                required: true,
                hint: 'Enter form question ID',
              ),
            },
            operation: (params) =>
                _formQuestionService.getFormQuestion(params['formQuestionId']),
          ),
          ServiceOperation(
            name: 'Get Questions by Form',
            description: 'Get all questions in a form',
            params: {
              'formId': ParamConfig(
                type: 'int',
                required: true,
                hint: 'Enter form ID',
              ),
            },
            operation: (params) =>
                _formQuestionService.getQuestionsByForm(params['formId']),
          ),
        ],
      ),
      ServiceCategory(
        name: 'Answers',
        description: 'Answer management operations',
        operations: [
          ServiceOperation(
            name: 'Get All Answers',
            description: 'Retrieve all answers',
            operation: (params) => _answerService.getAllAnswers(),
          ),
          ServiceOperation(
            name: 'Create Answer',
            description: 'Create new answer',
            params: {
              'value': ParamConfig(type: 'string', required: true),
              'remarks': ParamConfig(type: 'string', required: false),
            },
            operation: (params) => _answerService.createAnswer(
              value: params['value'],
              remarks: params['remarks'],
            ),
          ),
          ServiceOperation(
            name: 'Get Answer',
            description: 'Get specific answer details',
            params: {
              'answerId': ParamConfig(
                type: 'int',
                required: true,
                hint: 'Enter answer ID',
              ),
            },
            operation: (params) => _answerService.getAnswer(params['answerId']),
          ),
          ServiceOperation(
            name: 'Update Answer',
            description: 'Update existing answer',
            params: {
              'answerId': ParamConfig(type: 'int', required: true),
              'value': ParamConfig(type: 'string', required: false),
              'remarks': ParamConfig(type: 'string', required: false),
            },
            operation: (params) => _answerService.updateAnswer(
              params['answerId'],
              value: params['value'],
              remarks: params['remarks'],
            ),
          ),
        ],
      ),
      ServiceCategory(
        name: 'Form Submissions',
        description: 'Form submission operations',
        operations: [
          ServiceOperation(
            name: 'Get All Submissions',
            description: 'Retrieve all form submissions',
            params: {
              'formId': ParamConfig(type: 'int', required: false),
              'startDate': ParamConfig(type: 'datetime', required: false),
              'endDate': ParamConfig(type: 'datetime', required: false),
            },
            operation: (params) => _formSubmissionService.getAllSubmissions(
              formId: params['formId'],
              startDate: params['startDate'],
              endDate: params['endDate'],
            ),
          ),
          ServiceOperation(
            name: 'Get Submission',
            description: 'Get specific submission details',
            params: {
              'submissionId': ParamConfig(
                type: 'int',
                required: true,
                hint: 'Enter submission ID',
              ),
            },
            operation: (params) =>
                _formSubmissionService.getSubmission(params['submissionId']),
          ),
          ServiceOperation(
            name: 'Delete Submission',
            description: 'Delete form submission',
            params: {
              'submissionId': ParamConfig(
                type: 'int',
                required: true,
                hint: 'Enter submission ID',
              ),
            },
            operation: (params) =>
                _formSubmissionService.deleteSubmission(params['submissionId']),
          ),
        ],
      ),
      ServiceCategory(
        name: 'Export',
        description: 'Export operations',
        operations: [
          ServiceOperation(
            name: 'Export Form',
            description: 'Export form to PDF or DOCX format',
            params: {
              'formId': ParamConfig(
                type: 'int',
                required: true,
                description: 'ID of the form to export',
              ),
              'format': ParamConfig(
                type: 'string',
                required: false,
                defaultValue: 'PDF',
                options: ['PDF', 'DOCX'],
                description: 'Export format',
              ),
              'pageSize': ParamConfig(
                type: 'string',
                required: false,
                defaultValue: 'A4',
                options: ['A4', 'Letter', 'Legal'],
                description: 'Page size for the exported document',
              ),
            },
            operation: (params) async {
              try {
                final formId = params['formId'] as int;
                final format = ExportFormat.values.firstWhere(
                      (f) => f.value == (params['format'] ?? 'PDF'),
                  orElse: () => ExportFormat.pdf,
                );
                final pageSize = PageSize.values.firstWhere(
                      (p) => p.value == (params['pageSize'] ?? 'A4'),
                  orElse: () => PageSize.a4,
                );

                final bytes = await _exportService.exportForm(
                  formId,
                  format: format,
                  pageSize: pageSize,
                );

                final filename = 'form_${formId}_export.${format.value.toLowerCase()}';

                // Note: You need to pass the BuildContext to saveFile
                final filePath = await FileHelper.saveFile(
                  bytes,
                  filename,
                  context, // Make sure 'context' is available here
                );

                return {
                  'status': 'success',
                  'message': 'File saved successfully',
                  'filename': filename,
                  'filePath': filePath,
                  'size': bytes.length,
                };
              } catch (e) {
                throw Exception('Export failed: $e');
              }
            },
          ),
          ServiceOperation(
            name: 'Get Export Formats',
            description: 'Get available export formats and default settings',
            operation: (params) async {
              final response = await _exportService.getExportFormats();
              return {
                'formats': response.formats,
                'default': response.defaultFormat,
              };
            },
          ),
          ServiceOperation(
            name: 'Get Export Parameters',
            description: 'Get export configuration parameters',
            operation: (params) async {
              final response = await _exportService.getExportParameters();
              return response.parameters;
            },
          ),
          ServiceOperation(
            name: 'Preview Export Parameters',
            description: 'Preview export parameters for a specific form',
            params: {
              'formId': ParamConfig(
                type: 'int',
                required: true,
                description: 'ID of the form to preview parameters for',
              ),
            },
            operation: (params) async {
              return await _exportService.previewExportParameters(params['formId']);
            },
          ),
        ],
      ),
      // Add these categories to the _serviceCategories list in _initializeServiceCategories()

      ServiceCategory(
        name: 'Form Answers',
        description: 'Form answer management operations',
        operations: [
          ServiceOperation(
            name: 'Get All Form Answers',
            description: 'Retrieve all form answers',
            operation: (params) => _formAnswerService.getAllFormAnswers(),
          ),
          ServiceOperation(
            name: 'Create Form Answer',
            description: 'Create new form answer',
            params: {
              'formQuestionId': ParamConfig(type: 'int', required: true),
              'answerId': ParamConfig(type: 'int', required: true),
              'remarks': ParamConfig(type: 'string', required: false),
            },
            operation: (params) => _formAnswerService.createFormAnswer(
              formQuestionId: params['formQuestionId'],
              answerId: params['answerId'],
              remarks: params['remarks'],
            ),
          ),
          ServiceOperation(
            name: 'Get Form Answer',
            description: 'Get specific form answer details',
            params: {
              'formAnswerId': ParamConfig(
                type: 'int',
                required: true,
                hint: 'Enter form answer ID',
              ),
            },
            operation: (params) =>
                _formAnswerService.getFormAnswer(params['formAnswerId']),
          ),
          ServiceOperation(
            name: 'Get Answers by Question',
            description: 'Get form answers for specific question',
            params: {
              'formQuestionId': ParamConfig(
                type: 'int',
                required: true,
                hint: 'Enter form question ID',
              ),
            },
            operation: (params) => _formAnswerService
                .getAnswersByQuestion(params['formQuestionId']),
          ),
          ServiceOperation(
            name: 'Update Form Answer',
            description: 'Update existing form answer',
            params: {
              'formAnswerId': ParamConfig(type: 'int', required: true),
              'answerId': ParamConfig(type: 'int', required: false),
              'formQuestionId': ParamConfig(type: 'int', required: false),
            },
            operation: (params) => _formAnswerService.updateFormAnswer(
              params['formAnswerId'],
              answerId: params['answerId'],
              formQuestionId: params['formQuestionId'],
            ),
          ),
          ServiceOperation(
            name: 'Delete Form Answer',
            description: 'Delete form answer',
            params: {
              'formAnswerId': ParamConfig(
                type: 'int',
                required: true,
                hint: 'Enter form answer ID',
              ),
            },
            operation: (params) =>
                _formAnswerService.deleteFormAnswer(params['formAnswerId']),
          ),
        ],
      ),

      ServiceCategory(
        name: 'Answer Submissions',
        description: 'Answer submission operations',
        operations: [
          ServiceOperation(
            name: 'Create Answer Submitted',
            description: 'Create new answer submission',
            params: {
              'formSubmissionId': ParamConfig(type: 'int', required: true),
              'questionText': ParamConfig(type: 'string', required: true),
              'answerText': ParamConfig(type: 'string', required: true),
              'questionType': ParamConfig(type: 'string', required: true),
              'isSignature': ParamConfig(
                type: 'boolean',
                required: false,
                defaultValue: false,
              ),
            },
            operation: (params) =>
                _answerSubmittedService.createAnswerSubmitted(
              formSubmissionId: params['formSubmissionId'],
              questionText: params['questionText'],
              answerText: params['answerText'],
              questionType: params['questionType'],
              isSignature: params['isSignature'] ?? false,
            ),
          ),
          ServiceOperation(
            name: 'Get All Answers Submitted',
            description: 'Retrieve all submitted answers',
            params: {
              'formSubmissionId': ParamConfig(type: 'int', required: false),
              'startDate': ParamConfig(type: 'datetime', required: false),
              'endDate': ParamConfig(type: 'datetime', required: false),
            },
            operation: (params) =>
                _answerSubmittedService.getAllAnswersSubmitted(
              formSubmissionId: params['formSubmissionId'],
              startDate: params['startDate'],
              endDate: params['endDate'],
            ),
          ),
          ServiceOperation(
            name: 'Get Answer Submitted',
            description: 'Get specific submitted answer',
            params: {
              'answerSubmittedId': ParamConfig(
                type: 'int',
                required: true,
                hint: 'Enter submitted answer ID',
              ),
            },
            operation: (params) => _answerSubmittedService
                .getAnswerSubmitted(params['answerSubmittedId']),
          ),
          ServiceOperation(
            name: 'Get Answers by Submission',
            description: 'Get all answers for a submission',
            params: {
              'submissionId': ParamConfig(
                type: 'int',
                required: true,
                hint: 'Enter submission ID',
              ),
            },
            operation: (params) => _answerSubmittedService
                .getAnswersBySubmission(params['submissionId']),
          ),
          ServiceOperation(
            name: 'Update Answer Submitted',
            description: 'Update submitted answer',
            params: {
              'answerSubmittedId': ParamConfig(type: 'int', required: true),
              'answerText': ParamConfig(type: 'string', required: true),
            },
            operation: (params) =>
                _answerSubmittedService.updateAnswerSubmitted(
              params['answerSubmittedId'],
              answerText: params['answerText'],
            ),
          ),
          ServiceOperation(
            name: 'Delete Answer Submitted',
            description: 'Delete submitted answer',
            params: {
              'answerSubmittedId': ParamConfig(
                type: 'int',
                required: true,
                hint: 'Enter submitted answer ID',
              ),
            },
            operation: (params) => _answerSubmittedService
                .deleteAnswerSubmitted(params['answerSubmittedId']),
          ),
        ],
      ),

      ServiceCategory(
        name: 'Attachments',
        description: 'Attachment management operations',
        operations: [
          ServiceOperation(
            name: 'Create Attachment',
            description: 'Upload new attachment',
            params: {
              'formSubmissionId': ParamConfig(type: 'int', required: true),
              'isSignature': ParamConfig(
                type: 'boolean',
                required: false,
                defaultValue: false,
              ),
            },
            operation: (params) => _attachmentService.createAttachment(
              formSubmissionId: params['formSubmissionId'],
              file: params['file'],
              isSignature: params['isSignature'] ?? false,
            ),
          ),
          ServiceOperation(
            name: 'Get All Attachments',
            description: 'Retrieve all attachments',
            params: {
              'formSubmissionId': ParamConfig(type: 'int', required: false),
              'isSignature': ParamConfig(type: 'boolean', required: false),
              'fileType': ParamConfig(type: 'string', required: false),
            },
            operation: (params) => _attachmentService.getAllAttachments(
              formSubmissionId: params['formSubmissionId'],
              isSignature: params['isSignature'],
              fileType: params['fileType'],
            ),
          ),
          ServiceOperation(
            name: 'Get Submission Attachments',
            description: 'Get attachments for specific submission',
            params: {
              'submissionId': ParamConfig(
                type: 'int',
                required: true,
                hint: 'Enter submission ID',
              ),
            },
            operation: (params) => _attachmentService
                .getSubmissionAttachments(params['submissionId']),
          ),
          ServiceOperation(
            name: 'Delete Attachment',
            description: 'Delete attachment',
            params: {
              'attachmentId': ParamConfig(
                type: 'int',
                required: true,
                hint: 'Enter attachment ID',
              ),
            },
            operation: (params) =>
                _attachmentService.deleteAttachment(params['attachmentId']),
          ),
        ],
      ),
    ];

    _selectedCategory = _serviceCategories.first.name;
  }

  Widget _buildServiceSelector() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Status: ${_isAuthenticated ? 'Authenticated' : 'Not Authenticated'}',
              style: TextStyle(
                color: _isAuthenticated ? Colors.green : Colors.red,
              ),
            ),
            const SizedBox(height: 8),
            DropdownButton<String>(
              value: _selectedCategory,
              isExpanded: true,
              items: _serviceCategories.map((category) {
                return DropdownMenuItem(
                  value: category.name,
                  child: Text(category.name.toUpperCase()),
                );
              }).toList(),
              onChanged: (category) {
                if (category != null) {
                  setState(() {
                    _selectedCategory = category;
                    _result = null;
                    _error = null;
                  });
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOperationList() {
    final category =
        _serviceCategories.firstWhere((cat) => cat.name == _selectedCategory);

    return Expanded(
      child: ListView.builder(
        itemCount: category.operations.length,
        itemBuilder: (context, index) {
          final operation = category.operations[index];
          return Card(
            child: ExpansionTile(
              title: Text(operation.name),
              subtitle: operation.description != null
                  ? Text(operation.description!)
                  : null,
              children: [
                _buildOperationControls(operation),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildOperationControls(ServiceOperation operation) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (operation.params.isNotEmpty) ...[
            const Text(
              'Parameters:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            _buildParameterInputs(operation),
            const SizedBox(height: 16),
          ],
          ElevatedButton(
            onPressed: _isAuthenticated || operation.name == 'Login'
                ? () => _executeOperation(operation)
                : null,
            child: Text(
              _isAuthenticated || operation.name == 'Login'
                  ? 'Execute'
                  : 'Login Required',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildParameterInputs(ServiceOperation operation) {
    return Column(
      children: operation.params.entries.map((entry) {
        final paramKey = '${operation.name}_${entry.key}';
        final controller = _paramControllers.putIfAbsent(
          paramKey,
          () => TextEditingController(
            text: entry.value.defaultValue?.toString(),
          ),
        );

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4.0),
          child: TextField(
            controller: controller,
            decoration: InputDecoration(
              labelText: entry.key,
              helperText: entry.value.description,
              hintText: entry.value.hint,
              border: const OutlineInputBorder(),
            ),
            obscureText: entry.value.isPassword,
            keyboardType: entry.value.type == 'number'
                ? TextInputType.number
                : TextInputType.text,
          ),
        );
      }).toList(),
    );
  }

  Future<void> _executeOperation(ServiceOperation operation) async {
    try {
      setState(() {
        _isLoading = true;
        _result = null;
        _error = null;
      });

      // Collect parameters
      final params = <String, dynamic>{};
      for (final entry in operation.params.entries) {
        final paramKey = '${operation.name}_${entry.key}';
        final controller = _paramControllers[paramKey];
        final value = controller?.text.trim();

        if (entry.value.required && (value == null || value.isEmpty)) {
          // Use default value if available
          if (entry.value.defaultValue != null) {
            params[entry.key] = entry.value.defaultValue;
            continue;
          }
          throw ArgumentError('${entry.key} is required');
        }

        if (value?.isNotEmpty == true) {
          switch (entry.value.type.toLowerCase()) {
            case 'int':
              try {
                params[entry.key] = int.parse(value!);
              } catch (e) {
                throw ArgumentError('Invalid integer for ${entry.key}');
              }
              break;
            case 'double':
            case 'float':
              try {
                params[entry.key] = double.parse(value!);
              } catch (e) {
                throw ArgumentError('Invalid number for ${entry.key}');
              }
              break;
            case 'boolean':
            case 'bool':
              params[entry.key] = value!.toLowerCase() == 'true';
              break;
            default:
              params[entry.key] = value;
          }
        } else if (entry.value.defaultValue != null) {
          params[entry.key] = entry.value.defaultValue;
        }
      }

      // Execute operation
      final result = await operation.operation(params);

      setState(() {
        if (result != null) {
          if (result is List) {
            // Handle list results
            final items = result.map((item) {
              if (item is BaseModel) {
                return item.toJson();
              }
              return item;
            }).toList();
            _result = {'items': items};
          } else if (result is BaseModel) {
            _result = result.toJson();
          } else if (result is Map) {
            _result = Map<String, dynamic>.from(result);
          } else {
            _result = {'data': result};
          }
        }
        _isLoading = false;
      });
    } catch (e) {
      print('Execute operation error: $e'); // Add logging for debugging
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
// Left panel
          SizedBox(
            width: 300,
            child: Column(
              children: [
                DrawerHeader(
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'Service Test Panel',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        ApiConfig.baseUrl,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                _buildServiceSelector(),
                _buildOperationList(),
              ],
            ),
          ),
// Right panel with results
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Response',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      if (_result != null)
                        IconButton(
                          icon: const Icon(Icons.copy),
                          onPressed: () {
                            Clipboard.setData(ClipboardData(
                              text: const JsonEncoder.withIndent('  ')
                                  .convert(_result),
                            ));
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Response copied to clipboard'),
                              ),
                            );
                          },
                        ),
                    ],
                  ),
                  const Divider(),
                  if (_isLoading)
                    const Center(child: CircularProgressIndicator())
                  else if (_error != null)
                    Card(
                      color: Colors.red.shade100,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Error:',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.red,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _error!,
                              style: const TextStyle(color: Colors.red),
                            ),
                          ],
                        ),
                      ),
                    )
                  else if (_result != null)
                    Expanded(
                      child: JsonViewer(_result!),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
