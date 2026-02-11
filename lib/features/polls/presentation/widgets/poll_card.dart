import 'package:flutter/material.dart';
import 'package:poll_app/features/polls/models/poll.dart';
import 'package:poll_app/features/polls/presentation/widgets/poll_chart.dart';

class PollCard extends StatelessWidget {
  final Poll poll;
  final Function(String) onVote;
  final String? userVotedOptionId;

  const PollCard({
    super.key,
    required this.poll,
    required this.onVote,
    this.userVotedOptionId,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Colors.white.withOpacity(0.08),
        border: Border.all(color: Colors.white.withOpacity(0.12)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.bar_chart_rounded,
                    color: Colors.white,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    poll.question,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: Colors.white,
                      height: 1.3,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            PollChart(
              poll: poll,
              onVote: onVote,
              userVotedOptionId: userVotedOptionId,
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                const Icon(
                  Icons.how_to_vote_outlined,
                  size: 14,
                  color: Colors.white38,
                ),
                const SizedBox(width: 5),
                Text(
                  '${poll.totalVotes} Votes',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Colors.white38,
                  ),
                ),
                const SizedBox(width: 10),
                const Text('·', style: TextStyle(color: Colors.white24)),
                const SizedBox(width: 10),
                Text(
                  _formatDate(poll.createdAt),
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Colors.white38,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) => "${date.day}/${date.month}/${date.year}";
}
