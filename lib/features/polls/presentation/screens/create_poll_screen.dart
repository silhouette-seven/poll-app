import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:poll_app/features/common/wave_state.dart';
import 'package:poll_app/features/polls/models/poll.dart';
import 'package:poll_app/features/polls/providers/poll_providers.dart';
import 'package:uuid/uuid.dart';

class CreatePollScreen extends ConsumerStatefulWidget {
  const CreatePollScreen({super.key});

  @override
  ConsumerState<CreatePollScreen> createState() => _CreatePollScreenState();
}

class _CreatePollScreenState extends ConsumerState<CreatePollScreen> {
  final _formKey = GlobalKey<FormState>();
  final _questionController = TextEditingController();
  final List<TextEditingController> _optionControllers = [
    TextEditingController(),
    TextEditingController(),
  ];
  bool _isLoading = false;

  void _addOption() {
    setState(() => _optionControllers.add(TextEditingController()));
  }

  void _removeOption(int index) {
    if (_optionControllers.length <= 2) return;
    setState(() => _optionControllers.removeAt(index));
  }

  Future<void> _createPoll() async {
    if (!_formKey.currentState!.validate()) {
      ref.read(waveStateProvider).triggerError();
      return;
    }
    setState(() => _isLoading = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception(
          "Not signed in. Enable Anonymous auth in Firebase Console.",
        );
      }

      final options =
          _optionControllers
              .map(
                (c) => PollOption(id: const Uuid().v4(), text: c.text.trim()),
              )
              .toList();

      final poll = Poll(
        id: '',
        question: _questionController.text.trim(),
        options: options,
        createdAt: DateTime.now(),
        createdBy: user.uid,
      );

      await ref.read(pollRepositoryProvider).createPoll(poll);
      ref.read(waveStateProvider).triggerSuccess();

      if (mounted) {
        context.go('/');
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Poll created!')));
      }
    } catch (e) {
      ref.read(waveStateProvider).triggerError();
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  InputDecoration _inputDecoration(String label, {IconData? icon}) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.white60, fontSize: 14),
      floatingLabelStyle: const TextStyle(color: Colors.white70),
      prefixIcon:
          icon != null ? Icon(icon, color: Colors.white38, size: 20) : null,
      filled: true,
      fillColor: Colors.white.withOpacity(0.08),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Colors.white38, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: Colors.red.shade300),
      ),
      errorStyle: TextStyle(color: Colors.red.shade200),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text(
          'Create Poll',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header icon
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.08),
                    border: Border.all(color: Colors.white.withOpacity(0.12)),
                  ),
                  child: const Icon(
                    Icons.poll_outlined,
                    color: Colors.white,
                    size: 32,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Ask your community',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white60,
                    fontSize: 14,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 28),

                // Question field
                TextFormField(
                  controller: _questionController,
                  style: const TextStyle(color: Colors.white, fontSize: 16),
                  decoration: _inputDecoration(
                    'Your question',
                    icon: Icons.help_outline,
                  ),
                  validator:
                      (v) => v == null || v.isEmpty ? 'Enter a question' : null,
                  maxLines: 2,
                  cursorColor: Colors.white70,
                ),

                const SizedBox(height: 28),

                // Options label
                Row(
                  children: [
                    Icon(Icons.list_alt, color: Colors.white38, size: 18),
                    const SizedBox(width: 8),
                    const Text(
                      'OPTIONS',
                      style: TextStyle(
                        color: Colors.white38,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1.5,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Option fields
                ..._optionControllers.asMap().entries.map((entry) {
                  final index = entry.key;
                  final controller = entry.value;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12.0),
                    child: Row(
                      children: [
                        // Number badge
                        Container(
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withOpacity(0.08),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.15),
                            ),
                          ),
                          child: Center(
                            child: Text(
                              '${index + 1}',
                              style: const TextStyle(
                                color: Colors.white54,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: TextFormField(
                            controller: controller,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                            ),
                            decoration: _inputDecoration('Option ${index + 1}'),
                            validator:
                                (v) =>
                                    v == null || v.isEmpty ? 'Required' : null,
                            cursorColor: Colors.white70,
                          ),
                        ),
                        if (_optionControllers.length > 2) ...[
                          const SizedBox(width: 4),
                          IconButton(
                            icon: Icon(
                              Icons.close,
                              color: Colors.red.shade300,
                              size: 20,
                            ),
                            onPressed: () => _removeOption(index),
                            splashRadius: 20,
                          ),
                        ],
                      ],
                    ),
                  );
                }),

                // Add option button
                Center(
                  child: TextButton.icon(
                    onPressed: _addOption,
                    icon: const Icon(
                      Icons.add_circle_outline,
                      color: Colors.white54,
                      size: 18,
                    ),
                    label: const Text(
                      'Add Option',
                      style: TextStyle(color: Colors.white54),
                    ),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 32),

                // Publish button
                SizedBox(
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _createPoll,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white.withOpacity(0.15),
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: Colors.white.withOpacity(0.05),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                        side: BorderSide(color: Colors.white.withOpacity(0.2)),
                      ),
                    ),
                    child:
                        _isLoading
                            ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                            : const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.send_rounded, size: 20),
                                SizedBox(width: 10),
                                Text(
                                  'Publish Poll',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ],
                            ),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
