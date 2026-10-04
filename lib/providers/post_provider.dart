import 'package:flutter/material.dart';
import '../models/post_model.dart';
import '../services/post_service.dart';

class PostProvider extends ChangeNotifier {
  final PostService _postService = PostService();

  String _selectedCategory = 'All';
  String _searchQuery = '';
  bool _isCreatingPost = false;
  String? _errorMessage;

  String get selectedCategory => _selectedCategory;
  String get searchQuery => _searchQuery;
  bool get isCreatingPost => _isCreatingPost;
  String? get errorMessage => _errorMessage;

  final List<String> categories = const [
    'All',
    'General',
    'Maintenance',
    'Security',
    'Social',
    'Buy/Sell',
  ];

  void setCategory(String category) {
    _selectedCategory = category;
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  // Stream posts strictly filtered by societyId and category
  Stream<List<PostModel>> streamPosts(String societyId) {
    return _postService.getPostsStream(
      societyId,
      category: _selectedCategory,
    ).map((posts) {
      if (_searchQuery.trim().isEmpty) return posts;
      final q = _searchQuery.toLowerCase().trim();
      return posts.where((p) {
        return p.title.toLowerCase().contains(q) ||
            p.description.toLowerCase().contains(q) ||
            p.authorName.toLowerCase().contains(q) ||
            p.category.toLowerCase().contains(q);
      }).toList();
    });
  }

  // Create Post
  Future<bool> createPost({
    required String title,
    required String description,
    required String authorUid,
    required String authorName,
    required String authorFlat,
    required String societyId,
    required String category,
    String? imageUrl,
  }) async {
    _isCreatingPost = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _postService.createPost(
        title: title,
        description: description,
        authorUid: authorUid,
        authorName: authorName,
        authorFlat: authorFlat,
        societyId: societyId,
        category: category,
        imageUrl: imageUrl,
      );
      _isCreatingPost = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isCreatingPost = false;
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  // Toggle Like
  Future<void> toggleLike(String postId, String uid, bool isCurrentlyLiked) async {
    try {
      await _postService.toggleLike(postId, uid, isCurrentlyLiked);
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  // Add Comment
  Future<bool> addComment({
    required String postId,
    required String authorUid,
    required String authorName,
    required String authorFlat,
    required String text,
  }) async {
    try {
      await _postService.addComment(
        postId: postId,
        authorUid: authorUid,
        authorName: authorName,
        authorFlat: authorFlat,
        text: text,
      );
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  // Stream Comments for Post
  Stream<List<CommentModel>> streamComments(String postId) {
    return _postService.getCommentsStream(postId);
  }
}
