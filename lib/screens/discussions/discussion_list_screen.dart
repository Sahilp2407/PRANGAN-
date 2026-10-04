import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import '../../models/post_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/post_provider.dart';
import '../../theme/app_theme.dart';
import 'post_detail_screen.dart';
import 'new_post_screen.dart';

class DiscussionListScreen extends StatefulWidget {
  const DiscussionListScreen({super.key});

  @override
  State<DiscussionListScreen> createState() => _DiscussionListScreenState();
}

class _DiscussionListScreenState extends State<DiscussionListScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final postProvider = Provider.of<PostProvider>(context);
    final user = auth.userModel;
    final societyId = user?.societyId ?? 'raj_rajeshwari_sec20';
    final uid = auth.currentUid.isNotEmpty ? auth.currentUid : (auth.firebaseUser?.uid ?? 'guest');

    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: AppBar(
        title: const Text('Discussion Board'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_comment_rounded, color: AppTheme.primaryCrimson),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const NewPostScreen()),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Field
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search topics, complaints, neighbors...',
                prefixIcon: const Icon(Icons.search_rounded, size: 20, color: AppTheme.textSubtle),
                filled: true,
                fillColor: AppTheme.backgroundLight,
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, size: 18),
                        onPressed: () {
                          _searchController.clear();
                          postProvider.setSearchQuery('');
                        },
                      )
                    : null,
              ),
              onChanged: (val) => postProvider.setSearchQuery(val),
            ),
          ),

          // Horizontally scrollable Category Filter Chips
          Container(
            color: Colors.white,
            height: 52,
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: postProvider.categories.length,
              separatorBuilder: (_, _) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final category = postProvider.categories[index];
                final isSelected = postProvider.selectedCategory == category;
                return FilterChip(
                  label: Text(category),
                  selected: isSelected,
                  selectedColor: AppTheme.primaryCrimson,
                  backgroundColor: AppTheme.backgroundLight,
                  labelStyle: GoogleFonts.outfit(
                    fontSize: 12,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    color: isSelected ? Colors.white : AppTheme.textDark,
                  ),
                  side: BorderSide(
                    color: isSelected ? AppTheme.primaryCrimson : AppTheme.cardBorder,
                  ),
                  onSelected: (_) => postProvider.setCategory(category),
                );
              },
            ),
          ),
          const Divider(height: 1),

          // Posts List Stream
          Expanded(
            child: StreamBuilder<List<PostModel>>(
              stream: postProvider.streamPosts(societyId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final posts = snapshot.data ?? [];
                if (posts.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.forum_outlined, size: 54, color: AppTheme.textSubtle.withValues(alpha: 0.5)),
                          const SizedBox(height: 16),
                          Text(
                            'No discussions found',
                            style: GoogleFonts.outfit(fontSize: 17, fontWeight: FontWeight.w600, color: AppTheme.textDark),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Be the first resident to start a topic or question in this category!',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.outfit(fontSize: 13, color: AppTheme.textMuted),
                          ),
                          const SizedBox(height: 20),
                          ElevatedButton.icon(
                            icon: const Icon(Icons.edit_note_rounded),
                            label: const Text('Start Discussion'),
                            onPressed: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(builder: (_) => const NewPostScreen()),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: posts.length,
                  itemBuilder: (context, index) {
                    final post = posts[index];
                    final isLiked = post.isLikedBy(uid);

                    return Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: AppTheme.cardBorder),
                        boxShadow: AppTheme.cardShadow,
                      ),
                      child: InkWell(
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => PostDetailScreen(post: post),
                            ),
                          );
                        },
                        borderRadius: BorderRadius.circular(18),
                        child: Padding(
                          padding: const EdgeInsets.all(18),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Author row
                              Row(
                                children: [
                                  CircleAvatar(
                                    radius: 18,
                                    backgroundColor: AppTheme.primaryLight,
                                    child: Text(
                                      post.authorName.isNotEmpty ? post.authorName[0].toUpperCase() : 'R',
                                      style: GoogleFonts.outfit(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w700,
                                        color: AppTheme.primaryCrimson,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          post.authorName,
                                          style: GoogleFonts.outfit(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w700,
                                            color: AppTheme.textDark,
                                          ),
                                        ),
                                        Text(
                                          '${post.authorFlat} • ${DateFormat('dd MMM, hh:mm a').format(post.timestamp)}',
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
                                      post.category,
                                      style: GoogleFonts.outfit(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w700,
                                        color: AppTheme.goldDark,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 14),

                              // Title
                              Text(
                                post.title,
                                style: GoogleFonts.outfit(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: AppTheme.textDark,
                                  height: 1.3,
                                ),
                              ),
                              const SizedBox(height: 6),

                              // Body Description
                              Text(
                                post.description,
                                maxLines: 3,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.outfit(
                                  fontSize: 13,
                                  color: AppTheme.textMuted,
                                  height: 1.4,
                                ),
                              ),

                              if (post.imageUrl != null) ...[
                                const SizedBox(height: 12),
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: Image.network(
                                    post.imageUrl!,
                                    height: 160,
                                    width: double.infinity,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, _, _) => const SizedBox.shrink(),
                                  ),
                                ),
                              ],

                              const SizedBox(height: 16),
                              const Divider(height: 1),
                              const SizedBox(height: 10),

                              // Action Footer: Like, Comment, Share
                              Row(
                                children: [
                                  InkWell(
                                    onTap: () {
                                      postProvider.toggleLike(post.id, uid, isLiked);
                                    },
                                    borderRadius: BorderRadius.circular(8),
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                                      child: Row(
                                        children: [
                                          Icon(
                                            isLiked ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                                            size: 18,
                                            color: isLiked ? AppTheme.alertUrgent : AppTheme.textSubtle,
                                          ),
                                          const SizedBox(width: 6),
                                          Text(
                                            '${post.likes.length}',
                                            style: GoogleFonts.outfit(
                                              fontSize: 13,
                                              fontWeight: isLiked ? FontWeight.w700 : FontWeight.w500,
                                              color: isLiked ? AppTheme.alertUrgent : AppTheme.textMuted,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Row(
                                    children: [
                                      const Icon(Icons.chat_bubble_outline_rounded, size: 17, color: AppTheme.textSubtle),
                                      const SizedBox(width: 6),
                                      Text(
                                        '${post.commentCount} comments',
                                        style: GoogleFonts.outfit(
                                          fontSize: 13,
                                          color: AppTheme.textMuted,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const Spacer(),
                                  IconButton(
                                    icon: const Icon(Icons.share_outlined, size: 18, color: AppTheme.textSubtle),
                                    onPressed: () {
                                      SharePlus.instance.share(
                                        ShareParams(
                                          text: 'Discussion from Prangan (${post.category}):\n"${post.title}"\n${post.description}',
                                          subject: post.title,
                                        ),
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppTheme.primaryCrimson,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.edit_note_rounded),
        label: Text('Start Topic', style: GoogleFonts.outfit(fontWeight: FontWeight.w600)),
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const NewPostScreen()),
          );
        },
      ),
    );
  }
}
