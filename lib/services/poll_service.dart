import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/poll_model.dart';

class PollService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Create Poll
  Future<String> createPoll({
    required String question,
    required List<String> optionTexts,
    required String societyId,
    required String postedBy,
    required DateTime endDate,
  }) async {
    try {
      final docRef = _firestore.collection('polls').doc();
      final options = optionTexts.asMap().entries.map((entry) {
        return PollOption(
          id: 'opt_${entry.key}',
          text: entry.value,
          voteCount: 0,
        );
      }).toList();

      final poll = PollModel(
        id: docRef.id,
        question: question,
        options: options,
        totalVotes: 0,
        societyId: societyId,
        votedUsers: {},
        postedBy: postedBy,
        endDate: endDate,
        status: 'active',
      );

      await docRef.set(poll.toMap());
      return docRef.id;
    } catch (e) {
      debugPrint('Error creating poll: $e');
      rethrow;
    }
  }

  // Stream Polls for a society
  Stream<List<PollModel>> getPollsStream(String societyId) {
    return _firestore
        .collection('polls')
        .where('societyId', isEqualTo: societyId)
        .snapshots()
        .map((snapshot) {
      final polls = snapshot.docs.map((doc) {
        return PollModel.fromMap(doc.data(), doc.id);
      }).toList();
      polls.sort((a, b) => b.endDate.compareTo(a.endDate));
      return polls;
    });
  }

  // Transaction-based vote submission to strictly prevent double voting
  Future<void> submitVote({
    required String pollId,
    required String optionId,
    required String uid,
  }) async {
    final pollRef = _firestore.collection('polls').doc(pollId);

    return _firestore.runTransaction((transaction) async {
      final snapshot = await transaction.get(pollRef);
      if (!snapshot.exists) {
        throw Exception('Poll does not exist.');
      }

      final data = snapshot.data()!;
      final poll = PollModel.fromMap(data, snapshot.id);

      if (!poll.isActive) {
        throw Exception('This poll has expired or is closed.');
      }

      if (poll.hasVoted(uid)) {
        throw Exception('You have already cast your vote in this poll.');
      }

      // Update options vote count
      final updatedOptions = poll.options.map((opt) {
        if (opt.id == optionId) {
          return opt.copyWith(voteCount: opt.voteCount + 1);
        }
        return opt;
      }).toList();

      final updatedVotedUsers = Map<String, String>.from(poll.votedUsers);
      updatedVotedUsers[uid] = optionId;

      transaction.update(pollRef, {
        'options': updatedOptions.map((e) => e.toMap()).toList(),
        'totalVotes': poll.totalVotes + 1,
        'votedUsers': updatedVotedUsers,
      });
    });
  }
}
