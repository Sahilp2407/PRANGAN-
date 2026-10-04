import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../models/post_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/post_provider.dart';
import '../../theme/app_theme.dart';

class PostDetailScreen extends StatefulWidget {
  final PostModel post;

  const PostDetailScreen({super.key, required this.post});

  @override
  State<PostDetailScreen> createState() => _PostDetailScreenState();
}

class _PostDetailScreenState extends State<PostDetailScreen> {
  final TextEditingController _commentController = TextEditingController();
  bool _isPostingComment = false;

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _submitComment() async {
    final text = _commentController.text.trim();
    if (text.isEmpty) return;

    final auth = Provider.of<AuthProvider>(context, listen: false);
    final postProvider = Provider.of<PostProvider>(context, listen: false);
    final user = auth.userModel;

    setState(() => _isPostingComment = true);

    final success = await postProvider.addComment(
      postId: widget.post.id,
      authorUid: auth.currentUid.isNotEmpty ? auth.currentUid : (auth.firebaseUser?.uid ?? 'guest'),
      authorName: user?.name.isNotEmpty == true ? user!.name : 'Resident',
      authorFlat: user?.flatDisplay.isNotEmpty == true ? user!.flatDisplay : 'A-702',
      text: text,
    );

    if (mounted) {
      setState(() => _isPostingComment = false);
      if (success) {
        _commentController.clear();
        FocusScope.of(context).unfocus();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to post comment'), backgroundColor: AppTheme.alertUrgent),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final postProvider = Provider.of<PostProvider>(context);
    final uid = auth.currentUid.isNotEmpty ? auth.currentUid : (auth.firebaseUser?.uid ?? 'guest');

    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: AppBar(
        title: const Text('Discussion'),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Post Container
                  Container(
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
                        // Author header
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 20,
                              backgroundColor: AppTheme.primaryLight,
                              child: Text(
                                widget.post.authorName.isNotEmpty ? widget.post.authorName[0].toUpperCase() : 'R',
                                style: GoogleFonts.outfit(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: AppTheme.primaryCrimson,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    widget.post.authorName,
                                    style: GoogleFonts.outfit(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w700,
                                      color: AppTheme.textDark,
                                    ),
                                  ),
                                  Text(
                                    '${widget.post.authorFlat} • ${DateFormat('dd MMM yyyy, hh:mm a').format(widget.post.timestamp)}',
                                    style: GoogleFonts.outfit(
                                      fontSize: 11,
                                      color: AppTheme.textSubtle,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppTheme.goldLight,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                widget.post.category,
                                style: GoogleFonts.outfit(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: AppTheme.goldDark,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // Title
                        Text(
                          widget.post.title,
                          style: GoogleFonts.outfit(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.textDark,
                            height: 1.3,
                          ),
                        ),
                        const SizedBox(height: 10),

                        // Description
                        Text(
                          widget.post.description,
                          style: GoogleFonts.outfit(
                            fontSize: 14,
                            color: AppTheme.textMuted,
                            height: 1.5,
                          ),
                        ),

                        if (widget.post.imageUrl != null) ...[
                          const SizedBox(height: 16),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(14),
                            child: Image.network(
                              widget.post.imageUrl!,
                              width: double.infinity,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ],

                        const SizedBox(height: 18),
                        const Divider(height: 1),
                        const SizedBox(height: 12),

                        // Like toggle action
                        Row(
                          children: [
                            InkWell(
                              onTap: () {
                                final isLiked = widget.post.isLikedBy(uid);
                                postProvider.toggleLike(widget.post.id, uid, isLiked);
                              },
                              borderRadius: BorderRadius.circular(8),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                                child: Row(
                                  children: [
                                    Icon(
                                      widget.post.isLikedBy(uid) ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                                      size: 20,
                                      color: widget.post.isLikedBy(uid) ? AppTheme.alertUrgent : AppTheme.textSubtle,
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      '${widget.post.likes.length} Likes',
                                      style: GoogleFonts.outfit(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                        color: widget.post.isLikedBy(uid) ? AppTheme.alertUrgent : AppTheme.textMuted,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Comments Section Header
                  Text(
                    'Comments & Replies',
                    style: GoogleFonts.outfit(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textDark,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Comments Stream
                  StreamBuilder<List<CommentModel>>(
                    stream: postProvider.streamComments(widget.post.id),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(
                          child: Padding(
                            padding: EdgeInsets.all(20),
                            child: CircularProgressIndicator(),
                          ),
                        );
                      }

                      final comments = snapshot.data ?? [];
                      if (comments.isEmpty) {
                        return Container(
                          padding: const EdgeInsets.all(20),
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: AppTheme.cardBorder),
                          ),
                          child: Text(
                            'No comments yet. Write the first response!',
                            style: GoogleFonts.outfit(fontSize: 13, color: AppTheme.textMuted),
                          ),
                        );
                      }

                      return ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: comments.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 10),
                        itemBuilder: (context, index) {
                          final comment = comments[index];
                          return Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: AppTheme.cardBorder),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    CircleAvatar(
                                      radius: 12,
                                      backgroundColor: AppTheme.primaryLight,
                                      child: Text(
                                        comment.authorName.isNotEmpty ? comment.authorName[0] : 'R',
                                        style: GoogleFonts.outfit(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w700,
                                          color: AppTheme.primaryCrimson,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      comment.authorName,
                                      style: GoogleFonts.outfit(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w700,
                                        color: AppTheme.textDark,
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      '(${comment.authorFlat})',
                                      style: GoogleFonts.outfit(fontSize: 11, color: AppTheme.textSubtle),
                                    ),
                                    const Spacer(),
                                    Text(
                                      DateFormat('hh:mm a').format(comment.timestamp),
                                      style: GoogleFonts.outfit(fontSize: 11, color: AppTheme.textSubtle),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  comment.text,
                                  style: GoogleFonts.outfit(
                                    fontSize: 13,
                                    color: AppTheme.textDark,
                                    height: 1.4,
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      );
                    },
                  ),
                ],
              ),
            ),
          ),

          // Sticky Bottom Bar for Adding Comments
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              border: const Border(top: BorderSide(color: AppTheme.cardBorder)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 10,
                  offset: const Offset(0, -3),
                ),
              ],
            ),
            child: SafeArea(
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _commentController,
                      decoration: InputDecoration(
                        hintText: 'Add a helpful comment or reply...',
                        filled: true,
                        fillColor: AppTheme.backgroundLight,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      onSubmitted: (_) => _submitComment(),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Container(
                    decoration: const BoxDecoration(
                      color: AppTheme.primaryCrimson,
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: _isPostingComment
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                            )
                          : const Icon(Icons.send_rounded, color: Colors.white, size: 20),
                      onPressed: _isPostingComment ? null : _submitComment,
                    ),
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
