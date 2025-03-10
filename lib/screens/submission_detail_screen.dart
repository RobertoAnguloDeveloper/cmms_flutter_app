// lib/screens/form_management/submission_detail_screen.dart
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../components/drawer_menu/DrawerMenu.dart';
import '../../models/Permission_set.dart';
import '../services/form_submission_service.dart';

class SubmissionDetailScreen extends StatefulWidget {
  final FormSubmission submission;
  final PermissionSet permissionSet;
  final Map<String, dynamic> sessionData;

  const SubmissionDetailScreen({
    Key? key,
    required this.submission,
    required this.permissionSet,
    required this.sessionData,
  }) : super(key: key);

  @override
  _SubmissionDetailScreenState createState() => _SubmissionDetailScreenState();
}

class _SubmissionDetailScreenState extends State<SubmissionDetailScreen> {
  final FormSubmissionService _submissionService = FormSubmissionService();
  bool isLoading = false;

  // Helper to get icon for file type
  IconData _getIconForFileType(String filePath) {
    final extension = filePath.split('.').last.toLowerCase();

    switch (extension) {
      case 'pdf':
        return Icons.picture_as_pdf;
      case 'jpg':
      case 'jpeg':
      case 'png':
      case 'gif':
        return Icons.image;
      case 'doc':
      case 'docx':
        return Icons.description;
      case 'xls':
      case 'xlsx':
        return Icons.table_chart;
      case 'txt':
        return Icons.text_snippet;
      default:
        return Icons.attachment;
    }
  }

  // Helper to get color for file type
  Color _getColorForFileType(String filePath) {
    final extension = filePath.split('.').last.toLowerCase();

    switch (extension) {
      case 'pdf':
        return Colors.red;
      case 'jpg':
      case 'jpeg':
      case 'png':
      case 'gif':
        return Colors.blue;
      case 'doc':
      case 'docx':
        return Colors.blue.shade800;
      case 'xls':
      case 'xlsx':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  // Clean position string
  String _cleanPositionString(String? position) {
    if (position == null || position.isEmpty) {
      return '';
    }

    if (position.endsWith('~')) {
      return position.substring(0, position.length - 1);
    }

    return position;
  }

  // Process and group answers
  List<SubmissionAnswer> _processAnswers(List<SubmissionAnswer> answers) {
    final Map<String, SubmissionAnswer> groupedAnswers = {};
    final Map<String, int> questionCountMap = {};

    for (var answer in answers) {
      if (answer.questionType.toLowerCase() == 'signature') continue;

      final questionKey = answer.question;
      final isCheckbox = answer.questionType.toLowerCase() == 'checkbox';

      questionCountMap[questionKey] = (questionCountMap[questionKey] ?? 0) + 1;
      final uniqueKey = isCheckbox
          ? questionKey // Group checkboxes
          : "${questionKey}_${questionCountMap[questionKey]}";

      if (isCheckbox && groupedAnswers.containsKey(questionKey)) {
        // Combine checkbox answers
        final existingAnswer = groupedAnswers[questionKey]!;
        groupedAnswers[questionKey] = SubmissionAnswer(
          id: existingAnswer.id,
          question: existingAnswer.question,
          questionType: existingAnswer.questionType,
          answer: existingAnswer.answer + ', ' + answer.answer,
        );
      } else {
        groupedAnswers[uniqueKey] = answer;
      }
    }

    return groupedAnswers.values.toList();
  }

  // Load signature image
  Future<Uint8List> _loadSignatureImage(int attachmentId) async {
    try {
      return await _submissionService.getAttachmentBytes(attachmentId);
    } catch (e) {
      print('Error loading signature image: $e');
      throw e;
    }
  }

  // Navigate back to submissions list
  void _navigateBack() {
    Navigator.pop(context);
  }

  // Delete submission
  Future<void> _deleteSubmission() async {
    try {
      // Confirm deletion
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: const Text('Delete Submission'),
          content: const Text(
            'Are you sure you want to delete this submission? This action cannot be undone.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Delete'),
            ),
          ],
        ),
      );

      if (confirmed == true) {
        // Show loading indicator
        setState(() => isLoading = true);
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (loadingContext) => const AlertDialog(
            content: Row(
              children: [
                CircularProgressIndicator(),
                SizedBox(width: 20),
                Text("Deleting submission..."),
              ],
            ),
          ),
        );

        // Delete submission
        final success = await _submissionService.deleteSubmission(
            context,
            widget.submission.submissionId
        );

        // Close loading dialog
        if (mounted) Navigator.pop(context);

        if (success) {
          // Return to list with reload flag
          Navigator.pop(context, true);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Submission deleted successfully'),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    } catch (e) {
      // Handle errors
      setState(() => isLoading = false);
      if (mounted) {
        Navigator.of(context).pop(); // Close loading dialog if open
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error deleting submission: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final processedAnswers = _processAnswers(widget.submission.answers);

    // Split attachments into signatures and regular files
    final signatures = widget.submission.attachments.where((a) => a.isSignature).toList();
    final regularAttachments = widget.submission.attachments.where((a) => !a.isSignature).toList();
    final hasAttachments = widget.submission.attachments.isNotEmpty;

    return WillPopScope(
      onWillPop: () async {
        _navigateBack();
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black),
            onPressed: _navigateBack,
          ),
          title: Text(
            widget.submission.formTitle,
            style: const TextStyle(color: Colors.black87),
            overflow: TextOverflow.ellipsis,
          ),
          actions: [
            // Delete button for super users
            if (widget.sessionData['role']?['is_super_user'] == true)
              IconButton(
                icon: const Icon(
                  Icons.delete_outline,
                  size: 28,
                  color: Colors.red,
                ),
                tooltip: 'Delete Submission',
                onPressed: _deleteSubmission,
              ),
          ],
        ),
        drawer: DrawerMenu(
          onItemTapped: (index) => Navigator.pop(context),
          parentContext: context,
          permissionSet: widget.permissionSet,
          sessionData: widget.sessionData,
        ),
        body: isLoading
            ? const Center(child: CircularProgressIndicator())
            : Container(
          color: const Color(0xFFE3F2FD),
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Submission header
              Card(
                color: Colors.white,
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                margin: const EdgeInsets.symmetric(vertical: 12),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Form title
                          Expanded(
                            child: Text(
                              'Form Title: ${widget.submission.formTitle.isNotEmpty ? widget.submission.formTitle : "No title"}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 22,
                                color: Colors.black87,
                              ),
                            ),
                          ),
                          // Action buttons
                          Row(
                            children: [
                              // Export to PDF button
                              IconButton(
                                icon: const Icon(
                                  Icons.ios_share,
                                  size: 28,
                                  color: Colors.blue,
                                ),
                                tooltip: 'Export to PDF',
                                onPressed: () {
                                  // PDF export functionality placeholder
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('PDF export to be implemented'),
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Submitted by: ${widget.submission.submittedBy}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: Colors.black54,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Date: ${DateFormat('dd/MM/yyyy HH:mm').format(widget.submission.submittedAt)}',
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Form answers
              const SizedBox(height: 16),
              ...processedAnswers.map((answer) {
                return Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFB3E5FC),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        answer.question,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 12),
                      if (answer.questionType.toLowerCase() == 'checkbox' &&
                          answer.answer.contains(','))
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: answer.answer.split(',').map((option) {
                            final trimmedOption = option.trim();
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 6),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Icon(Icons.check_circle, size: 18, color: Colors.blue),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      trimmedOption,
                                      style: const TextStyle(fontSize: 16),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        )
                      else
                        Text(
                          answer.answer,
                          style: const TextStyle(fontSize: 16),
                        ),
                    ],
                  ),
                );
              }).toList(),

              // Signatures section
              if (signatures.isNotEmpty) ...[
                const SizedBox(height: 24),
                const Text(
                  'Signatures:',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
                const SizedBox(height: 8),
                ...signatures.map((signature) {
                  return Card(
                    color: Colors.white,
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Signature author
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                          child: Text(
                            'Signature by: ${signature.signatureAuthor ?? "Signer"}',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),

                        // Position if available
                        if (signature.signaturePosition != null)
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Text(
                              _cleanPositionString(signature.signaturePosition),
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[700],
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ),

                        // Signature image
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          width: double.infinity,
                          child: signature.id != null
                              ? FutureBuilder<Uint8List>(
                            future: _loadSignatureImage(signature.id!),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState == ConnectionState.waiting) {
                                return Container(
                                  height: 100,
                                  alignment: Alignment.center,
                                  child: const CircularProgressIndicator(),
                                );
                              } else if (snapshot.hasError) {
                                return Container(
                                  height: 100,
                                  alignment: Alignment.center,
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.error_outline, color: Colors.red, size: 32),
                                      const SizedBox(height: 8),
                                      const Text(
                                        'Could not load signature',
                                        style: TextStyle(color: Colors.red),
                                      ),
                                    ],
                                  ),
                                );
                              } else if (snapshot.hasData) {
                                return ConstrainedBox(
                                  constraints: const BoxConstraints(maxHeight: 150),
                                  child: Image.memory(
                                    snapshot.data!,
                                    fit: BoxFit.contain,
                                  ),
                                );
                              } else {
                                return Container(
                                  height: 100,
                                  alignment: Alignment.center,
                                  child: const Text('No signature data available'),
                                );
                              }
                            },
                          )
                              : Container(
                            height: 100,
                            alignment: Alignment.center,
                            child: const Text('Signature ID missing'),
                          ),
                        ),

                        // View full size button
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Align(
                            alignment: Alignment.centerRight,
                            child: TextButton.icon(
                              icon: const Icon(Icons.fullscreen),
                              label: const Text('View Full Size'),
                              onPressed: () async {
                                if (signature.id != null) {
                                  try {
                                    await _submissionService.openAttachment(context, signature.id!);
                                  } catch (e) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text('Error opening signature: $e')),
                                    );
                                  }
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Signature ID is missing')),
                                  );
                                }
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ],

              // Regular attachments section
              if (regularAttachments.isNotEmpty) ...[
                const SizedBox(height: 24),
                const Text(
                  'Attachments:',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Files attached: ${regularAttachments.length}',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                    fontStyle: FontStyle.italic,
                  ),
                ),
                ...regularAttachments.map((attachment) {
                  final fileName = attachment.filePath.split('\\').last;
                  return Card(
                    color: Colors.white,
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      leading: Icon(
                        _getIconForFileType(attachment.filePath),
                        color: _getColorForFileType(attachment.filePath),
                        size: 36,
                      ),
                      title: Text(
                        fileName,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      subtitle: Text(
                        'Attachment',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                      onTap: () async {
                        if (attachment.id != null) {
                          try {
                            await _submissionService.openAttachment(context, attachment.id!);
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Error opening attachment: $e')),
                            );
                          }
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Attachment ID is missing')),
                          );
                        }
                      },
                    ),
                  );
                }).toList(),
              ],

              // Message if no attachments
              if (!hasAttachments) ...[
                const SizedBox(height: 24),
                Container(
                  margin: const EdgeInsets.only(top: 8),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'No files or signatures attached to this submission.',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}