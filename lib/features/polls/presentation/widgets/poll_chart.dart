import 'package:flutter/material.dart';
import 'package:poll_app/features/polls/models/poll.dart';

class PollChart extends StatelessWidget {
  final Poll poll;
  final String? userVotedOptionId;
  final Function(String optionId)? onVote;

  const PollChart({
    super.key,
    required this.poll,
    this.userVotedOptionId,
    this.onVote,
  });

  @override
  Widget build(BuildContext context) {
    if (poll.totalVotes == 0) return _buildEmptyState(context);

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children:
          poll.options.map((option) {
            final percentage =
                poll.totalVotes == 0 ? 0.0 : option.voteCount / poll.totalVotes;
            final percentText = '${(percentage * 100).toStringAsFixed(0)}%';
            final bool isWinner =
                poll.totalVotes > 0 &&
                option.voteCount ==
                    poll.options
                        .map((e) => e.voteCount)
                        .reduce((a, b) => a > b ? a : b);
            final bool isUserVoted = userVotedOptionId == option.id;

            // Green tint for user's selection, white for others
            final Color barColor =
                isUserVoted
                    ? const Color(0xFF4CAF50).withOpacity(0.35)
                    : Colors.white.withOpacity(isWinner ? 0.2 : 0.06);
            final Color borderColor =
                isUserVoted
                    ? const Color(0xFF4CAF50).withOpacity(0.6)
                    : isWinner
                    ? Colors.white.withOpacity(0.3)
                    : Colors.white.withOpacity(0.08);
            final Color textColor =
                isUserVoted ? const Color(0xFF81C784) : Colors.white;

            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 5.0),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: onVote != null ? () => onVote!(option.id) : null,
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    height: 54,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.10),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: borderColor,
                        width: isUserVoted ? 1.5 : 1.0,
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Stack(
                        children: [
                          // Progress bar
                          FractionallySizedBox(
                            alignment: Alignment.centerLeft,
                            widthFactor: percentage.clamp(0.0, 1.0),
                            child: Container(
                              decoration: BoxDecoration(color: barColor),
                            ),
                          ),
                          // Text overlay
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16.0,
                              ),
                              child: Row(
                                children: [
                                  // Checkmark for voted option
                                  if (isUserVoted) ...[
                                    const Icon(
                                      Icons.check_circle,
                                      size: 18,
                                      color: Color(0xFF4CAF50),
                                    ),
                                    const SizedBox(width: 8),
                                  ],
                                  Expanded(
                                    child: Text(
                                      option.text,
                                      style: TextStyle(
                                        fontWeight:
                                            isUserVoted || isWinner
                                                ? FontWeight.w600
                                                : FontWeight.w400,
                                        fontSize: 15,
                                        color: textColor,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 3,
                                    ),
                                    decoration: BoxDecoration(
                                      color:
                                          isUserVoted
                                              ? const Color(
                                                0xFF4CAF50,
                                              ).withOpacity(0.2)
                                              : Colors.black.withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      '$percentText · ${option.voteCount}',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                        color: textColor,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children:
          poll.options.map((option) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 5.0),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: onVote != null ? () => onVote!(option.id) : null,
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    height: 54,
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.10),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.white.withOpacity(0.1)),
                    ),
                    alignment: Alignment.centerLeft,
                    child: Row(
                      children: [
                        const Icon(
                          Icons.radio_button_unchecked,
                          size: 20,
                          color: Colors.white54,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            option.text,
                            style: const TextStyle(
                              fontWeight: FontWeight.w500,
                              fontSize: 15,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
    );
  }
}
