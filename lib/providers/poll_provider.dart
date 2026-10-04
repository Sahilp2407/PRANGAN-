import 'package:flutter/material.dart';
import '../models/poll_model.dart';
import '../services/poll_service.dart';

class PollProvider extends ChangeNotifier {
  final PollService _pollService = PollService();

  bool _isVoting = false;
  String? _errorMessage;

  bool get isVoting => _isVoting;
  String? get errorMessage => _errorMessage;

  // Stream Polls filtered by societyId
  Stream<List<PollModel>> streamPolls(String societyId, {bool activeOnly = true}) {
    return _pollService.getPollsStream(societyId).map((polls) {
      if (activeOnly) {
        return polls.where((p) => p.isActive).toList();
      } else {
        return polls.where((p) => !p.isActive).toList();
      }
    });
  }

  // Submit Vote
  Future<bool> submitVote({
    required String pollId,
    required String optionId,
    required String uid,
  }) async {
    _isVoting = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _pollService.submitVote(
        pollId: pollId,
        optionId: optionId,
        uid: uid,
      );
      _isVoting = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isVoting = false;
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
      return false;
    }
  }

  // Create Poll
  Future<bool> createPoll({
    required String question,
    required List<String> optionTexts,
    required String societyId,
    required String postedBy,
    required DateTime endDate,
  }) async {
    try {
      await _pollService.createPoll(
        question: question,
        optionTexts: optionTexts,
        societyId: societyId,
        postedBy: postedBy,
        endDate: endDate,
      );
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }
}
