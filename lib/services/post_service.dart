import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/post_model.dart';

class PostService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Create Post
  Future<String> createPost({
    required String title,
    required String description,
    required String authorUid,
    required String authorName,
    required String authorFlat,
    required String societyId,
    required String category,
    String? imageUrl,
  }) async {
    try {
      final docRef = _firestore.collection('posts').doc();
      final post = PostModel(
        id: docRef.id,
        title: title,
        description: description,
        authorUid: authorUid,
        authorName: authorName,
        authorFlat: authorFlat,
        societyId: societyId,
        category: category,
        imageUrl: imageUrl,
        likes: [],
        commentCount: 0,
        timestamp: DateTime.now(),
      );

      await docRef.set(post.toMap());
      return docRef.id;
    } catch (e) {
      debugPrint('Error creating post: $e');
      rethrow;
    }
  }

  // Stream Posts filtered strictly by societyId and optional category
  Stream<List<PostModel>> getPostsStream(String societyId, {String? category}) {
    Query query = _firestore
        .collection('posts')
        .where('societyId', isEqualTo: societyId);

    if (category != null && category.isNotEmpty && category != 'All') {
      query = query.where('category', isEqualTo: category);
    }

    return query
        .snapshots()
        .map((snapshot) {
      final posts = snapshot.docs.map((doc) {
        return PostModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }).toList();
      // Sort in-memory to prevent complex composite index requirements initially
      posts.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      return posts;
    });
  }

  // Toggle Like on Post
  Future<void> toggleLike(String postId, String uid, bool isCurrentlyLiked) async {
    try {
      final postRef = _firestore.collection('posts').doc(postId);
      if (isCurrentlyLiked) {
        await postRef.update({
          'likes': FieldValue.arrayRemove([uid]),
        });
      } else {
        await postRef.update({
          'likes': FieldValue.arrayUnion([uid]),
        });
      }
    } catch (e) {
      debugPrint('Error toggling like: $e');
      rethrow;
    }
  }

  // Add Comment and update commentCount
  Future<void> addComment({
    required String postId,
    required String authorUid,
    required String authorName,
    required String authorFlat,
    required String text,
  }) async {
    try {
      final batch = _firestore.batch();
      final postRef = _firestore.collection('posts').doc(postId);
      final commentRef = postRef.collection('comments').doc();

      final comment = CommentModel(
        id: commentRef.id,
        authorUid: authorUid,
        authorName: authorName,
        authorFlat: authorFlat,
        text: text,
        timestamp: DateTime.now(),
      );

      batch.set(commentRef, comment.toMap());
      batch.update(postRef, {
        'commentCount': FieldValue.increment(1),
      });

      await batch.commit();
    } catch (e) {
      debugPrint('Error adding comment: $e');
      rethrow;
    }
  }

  // Stream Comments for a post
  Stream<List<CommentModel>> getCommentsStream(String postId) {
    return _firestore
        .collection('posts')
        .doc(postId)
        .collection('comments')
        .snapshots()
        .map((snapshot) {
      final comments = snapshot.docs.map((doc) {
        return CommentModel.fromMap(doc.data(), doc.id);
      }).toList();
      comments.sort((a, b) => a.timestamp.compareTo(b.timestamp));
      return comments;
    });
  }
}
