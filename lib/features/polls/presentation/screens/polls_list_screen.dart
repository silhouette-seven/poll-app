import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:poll_app/features/common/wave_state.dart';
import 'package:poll_app/features/polls/presentation/widgets/poll_card.dart';
import 'package:poll_app/features/polls/providers/poll_providers.dart';
import 'package:poll_app/features/polls/data/local_poll_storage.dart';

class PollsListScreen extends ConsumerWidget {
  const PollsListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pollsAsync = ref.watch(pollsStreamProvider);
    final localStorage = ref.watch(localPollStorageProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text(
          'Community Polls',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: false,
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      extendBodyBehindAppBar: true,
      body: pollsAsync.when(
        data: (polls) {
          if (polls.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.poll, size: 64, color: Colors.white38),
                  SizedBox(height: 16),
                  Text(
                    'No polls yet. Create one!',
                    style: TextStyle(color: Colors.white60, fontSize: 16),
                  ),
                ],
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.only(
              top: kToolbarHeight + 48,
              bottom: 80,
            ),
            itemCount: polls.length,
            itemBuilder: (context, index) {
              final poll = polls[index];
              // Get the option the current user voted for
              final votedOptionId = localStorage.getVotedOptionId(poll.id);

              return PollCard(
                poll: poll,
                userVotedOptionId: votedOptionId,
                onVote: (optionId) async {
                  try {
                    await ref
                        .read(pollRepositoryProvider)
                        .vote(poll.id, optionId);
                    ref.read(waveStateProvider).triggerSuccess();
                  } catch (e) {
                    ref.read(waveStateProvider).triggerError();
                    if (context.mounted) {
                      ScaffoldMessenger.of(
                        context,
                      ).showSnackBar(SnackBar(content: Text('$e')));
                    }
                  }
                },
              );
            },
          );
        },
        error:
            (error, stack) => Center(
              child: Text(
                'Error: $error',
                style: const TextStyle(color: Colors.white70),
              ),
            ),
        loading:
            () => const Center(
              child: CircularProgressIndicator(color: Colors.white),
            ),
      ),
    );
  }
}
