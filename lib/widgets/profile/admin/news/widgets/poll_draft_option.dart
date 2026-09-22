import 'package:flutter/widgets.dart';

/// Черновик одного варианта ответа в форме опроса.
class PollDraftOption {
  PollDraftOption();

  final TextEditingController textController = TextEditingController();

  void dispose() {
    textController.dispose();
  }
}