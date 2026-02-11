import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:poll_app/features/polls/providers/poll_providers.dart';
import 'package:poll_app/features/polls/presentation/widgets/poll_card.dart';

class MyPollsScreen extends ConsumerWidget {
  const MyPollsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final myPollsAsync = ref.watch(createdPollsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Polls'),
        backgroundColor: Colors.transparent,
      ),
      body: myPollsAsync.when(
        data: (polls) {
          if (polls.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.inventory_2_outlined,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    "You haven't created any polls yet.",
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ],
              ),
            );
          }
          return ListView.builder(
            itemCount: polls.length,
            itemBuilder: (context, index) {
              final poll = polls[index];
              return Stack(
                children: [
                  PollCard(
                    poll: poll,
                    onVote:
                        (
                          _,
                        ) {}, // Viewer mode, can't vote on own poll manager view ideally? Or can?
                  ),
                  Positioned(
                    top: 24,
                    right: 24,
                    child: IconButton(
                      icon: const Icon(Icons.delete_outline, color: Colors.red),
                      onPressed: () async {
                        final confirm = await showDialog<bool>(
                          context: context,
                          builder:
                              (c) => AlertDialog(
                                title: const Text('Delete Poll?'),
                                content: const Text('This cannot be undone.'),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(c, false),
                                    child: const Text('Cancel'),
                                  ),
                                  TextButton(
                                    onPressed: () => Navigator.pop(c, true),
                                    child: const Text(
                                      'Delete',
                                      style: TextStyle(color: Colors.red),
                                    ),
                                  ),
                                ],
                              ),
                        );

                        if (confirm == true) {
                          if (confirm == true) {
                            await ref
                                .read(pollRepositoryProvider)
                                .deletePoll(poll.id);
                            // ignore: unused_result
                            ref.refresh(createdPollsProvider);
                          }
                        }
                      },
                    ),
                  ),
                ],
              );
            },
          );
        },
        error: (err, stack) => Center(child: Text('Error: $err')),
        loading: () => const Center(child: CircularProgressIndicator()),
      ),
    );
  }
}
