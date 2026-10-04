import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../models/poll_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/poll_provider.dart';
import '../../theme/app_theme.dart';

class PollScreen extends StatefulWidget {
  const PollScreen({super.key});

  @override
  State<PollScreen> createState() => _PollScreenState();
}

class _PollScreenState extends State<PollScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _showCreatePollDialog() {
    final questionCtrl = TextEditingController();
    final opt1Ctrl = TextEditingController();
    final opt2Ctrl = TextEditingController();
    final opt3Ctrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Create Society Poll', style: GoogleFonts.outfit(fontWeight: FontWeight.w700)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: questionCtrl,
                maxLines: 2,
                decoration: const InputDecoration(labelText: 'Poll Question', hintText: 'e.g. Should we install solar panels?'),
              ),
              const SizedBox(height: 12),
              TextField(controller: opt1Ctrl, decoration: const InputDecoration(labelText: 'Option 1')),
              const SizedBox(height: 8),
              TextField(controller: opt2Ctrl, decoration: const InputDecoration(labelText: 'Option 2')),
              const SizedBox(height: 8),
              TextField(controller: opt3Ctrl, decoration: const InputDecoration(labelText: 'Option 3 (Optional)')),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              if (questionCtrl.text.trim().isEmpty || opt1Ctrl.text.trim().isEmpty || opt2Ctrl.text.trim().isEmpty) return;

              final auth = Provider.of<AuthProvider>(context, listen: false);
              final pollProvider = Provider.of<PollProvider>(context, listen: false);
              final societyId = auth.userModel?.societyId ?? 'raj_rajeshwari_sec20';

              final options = [opt1Ctrl.text.trim(), opt2Ctrl.text.trim()];
              if (opt3Ctrl.text.trim().isNotEmpty) options.add(opt3Ctrl.text.trim());

              await pollProvider.createPoll(
                question: questionCtrl.text.trim(),
                optionTexts: options,
                societyId: societyId,
                postedBy: auth.userModel?.name.isNotEmpty == true ? auth.userModel!.name : 'Managing Committee',
                endDate: DateTime.now().add(const Duration(days: 4)),
              );

              if (ctx.mounted) Navigator.pop(ctx);
            },
            child: const Text('Publish Poll'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final user = auth.userModel;
    final societyId = user?.societyId ?? 'raj_rajeshwari_sec20';
    final uid = auth.currentUid.isNotEmpty ? auth.currentUid : (auth.firebaseUser?.uid ?? 'guest');

    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: AppBar(
        title: const Text('Society Polls & Voting'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_chart_rounded, color: AppTheme.primaryCrimson),
            tooltip: 'Create Poll',
            onPressed: _showCreatePollDialog,
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppTheme.primaryCrimson,
          unselectedLabelColor: AppTheme.textMuted,
          indicatorColor: AppTheme.primaryCrimson,
          indicatorWeight: 3,
          labelStyle: GoogleFonts.outfit(fontWeight: FontWeight.w700, fontSize: 14),
          tabs: const [
            Tab(text: 'Active Polls'),
            Tab(text: 'Closed Polls'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _PollsList(societyId: societyId, uid: uid, activeOnly: true),
          _PollsList(societyId: societyId, uid: uid, activeOnly: false),
        ],
      ),
    );
  }
}

class _PollsList extends StatelessWidget {
  final String societyId;
  final String uid;
  final bool activeOnly;

  const _PollsList({
    required this.societyId,
    required this.uid,
    required this.activeOnly,
  });

  @override
  Widget build(BuildContext context) {
    final pollProvider = Provider.of<PollProvider>(context);

    return StreamBuilder<List<PollModel>>(
      stream: pollProvider.streamPolls(societyId, activeOnly: activeOnly),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final polls = snapshot.data ?? [];
        if (polls.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.how_to_vote_outlined, size: 54, color: AppTheme.textSubtle.withValues(alpha: 0.5)),
                  const SizedBox(height: 16),
                  Text(
                    activeOnly ? 'No active polls right now' : 'No closed polls yet',
                    style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Democratic decision-making polls will be posted here by committee.',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.outfit(fontSize: 13, color: AppTheme.textMuted),
                  ),
                ],
              ),
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: polls.length,
          itemBuilder: (context, index) {
            final poll = polls[index];
            return _PollCard(poll: poll, uid: uid);
          },
        );
      },
    );
  }
}

class _PollCard extends StatefulWidget {
  final PollModel poll;
  final String uid;

  const _PollCard({required this.poll, required this.uid});

  @override
  State<_PollCard> createState() => _PollCardState();
}

class _PollCardState extends State<_PollCard> {
  String? _selectedOptionId;

  @override
  Widget build(BuildContext context) {
    final pollProvider = Provider.of<PollProvider>(context);
    final hasVoted = widget.poll.hasVoted(widget.uid);
    final userVotedOptionId = widget.poll.userSelectedOptionId(widget.uid);

    return Container(
      margin: const EdgeInsets.only(bottom: 18),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.cardBorder),
        boxShadow: AppTheme.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Poll Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: widget.poll.isActive ? AppTheme.goldLight : Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  widget.poll.isActive
                      ? 'Active • Ends ${DateFormat('dd MMM').format(widget.poll.endDate)}'
                      : 'Closed',
                  style: GoogleFonts.outfit(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: widget.poll.isActive ? AppTheme.goldDark : Colors.grey.shade700,
                  ),
                ),
              ),
              const Spacer(),
              Text(
                '${widget.poll.totalVotes} votes cast',
                style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.textSubtle),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Question
          Text(
            widget.poll.question,
            style: GoogleFonts.outfit(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppTheme.textDark,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 16),

          // Options List
          ...widget.poll.options.map((option) {
            final percentage = widget.poll.getPercentage(option);
            final isUserChoice = hasVoted && userVotedOptionId == option.id;
            final isSelectedForVote = _selectedOptionId == option.id;

            if (hasVoted || !widget.poll.isActive) {
              // Results Display Mode
              return Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isUserChoice ? AppTheme.primaryLight : AppTheme.backgroundLight,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isUserChoice ? AppTheme.primaryCrimson : AppTheme.cardBorder,
                    width: isUserChoice ? 1.5 : 1.0,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Row(
                            children: [
                              if (isUserChoice) ...[
                                const Icon(Icons.check_circle_rounded, color: AppTheme.primaryCrimson, size: 16),
                                const SizedBox(width: 6),
                              ],
                              Expanded(
                                child: Text(
                                  option.text,
                                  style: GoogleFonts.outfit(
                                    fontSize: 13,
                                    fontWeight: isUserChoice ? FontWeight.w700 : FontWeight.w500,
                                    color: isUserChoice ? AppTheme.primaryCrimson : AppTheme.textDark,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          '${percentage.toStringAsFixed(1)}% (${option.voteCount})',
                          style: GoogleFonts.outfit(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: isUserChoice ? AppTheme.primaryCrimson : AppTheme.textMuted,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: LinearProgressIndicator(
                        value: widget.poll.totalVotes > 0 ? option.voteCount / widget.poll.totalVotes : 0.0,
                        backgroundColor: Colors.white,
                        color: isUserChoice ? AppTheme.primaryCrimson : AppTheme.goldAccent,
                        minHeight: 8,
                      ),
                    ),
                  ],
                ),
              );
            } else {
              // Voting Selection Mode
              return InkWell(
                onTap: () => setState(() => _selectedOptionId = option.id),
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  decoration: BoxDecoration(
                    color: isSelectedForVote ? AppTheme.primaryLight : Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelectedForVote ? AppTheme.primaryCrimson : AppTheme.cardBorder,
                      width: isSelectedForVote ? 1.6 : 1.0,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        isSelectedForVote ? Icons.radio_button_checked_rounded : Icons.radio_button_off_rounded,
                        color: isSelectedForVote ? AppTheme.primaryCrimson : AppTheme.textSubtle,
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          option.text,
                          style: GoogleFonts.outfit(
                            fontSize: 13,
                            fontWeight: isSelectedForVote ? FontWeight.w700 : FontWeight.w500,
                            color: isSelectedForVote ? AppTheme.primaryCrimson : AppTheme.textDark,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }
          }),

          const SizedBox(height: 12),

          // Submit Vote Button (If active and not yet voted)
          if (!hasVoted && widget.poll.isActive)
            SizedBox(
              width: double.infinity,
              height: 46,
              child: ElevatedButton(
                onPressed: _selectedOptionId == null || pollProvider.isVoting
                    ? null
                    : () async {
                        final success = await pollProvider.submitVote(
                          pollId: widget.poll.id,
                          optionId: _selectedOptionId!,
                          uid: widget.uid,
                        );
                        if (context.mounted && !success) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(pollProvider.errorMessage ?? 'Voting error'),
                              backgroundColor: AppTheme.alertUrgent,
                            ),
                          );
                        }
                      },
                child: pollProvider.isVoting
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                      )
                    : const Text('Cast Vote'),
              ),
            ),

          const SizedBox(height: 8),
          Text(
            'Posted by ${widget.poll.postedBy}',
            style: GoogleFonts.outfit(fontSize: 11, color: AppTheme.textSubtle),
          ),
        ],
      ),
    );
  }
}
