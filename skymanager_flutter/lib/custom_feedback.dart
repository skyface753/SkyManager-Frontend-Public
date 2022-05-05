import 'package:feedback/feedback.dart';
import 'package:flutter/material.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:skymanager/fixed_values.dart' as fixed_values;

/// A data type holding user feedback consisting of a feedback type, free from
/// feedback text, and a sentiment rating.
class CustomFeedback {
  CustomFeedback({
    this.feedbackType,
    this.feedbackText,
    this.email,
  });

  FeedbackType? feedbackType;
  String? feedbackText;
  String? email;

  @override
  String toString() {
    return {
      if (email != null) 'email: ': email,
      'feedback_type: ': feedbackType.toString(),
      'feedback_text: ': feedbackText,
    }.toString();
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      if (email != null) 'email': email.toString(),
      'feedback_type': feedbackType.toString(),
      'feedback_text': feedbackText,
    };
  }
}

/// What type of feedback the user wants to provide.
enum FeedbackType {
  bugReport,
  featureRequest,
}

/// A form that prompts the user for the type of feedback they want to give,
/// free form text feedback, and a sentiment rating.
/// The submit button is disabled until the user provides the feedback type. All
/// other fields are optional.
class CustomFeedbackForm extends StatefulWidget {
  const CustomFeedbackForm({
    Key? key,
    required this.onSubmit,
    required this.scrollController,
  }) : super(key: key);

  final OnSubmit onSubmit;
  final ScrollController? scrollController;

  @override
  _CustomFeedbackFormState createState() => _CustomFeedbackFormState();
}

class _CustomFeedbackFormState extends State<CustomFeedbackForm> {
  final CustomFeedback _customFeedback = CustomFeedback();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: Stack(
            children: [
              if (widget.scrollController != null)
                const FeedbackSheetDragHandle(),
              ListView(
                controller: widget.scrollController,
                // Pad the top by 20 to match the corner radius if drag enabled.
                padding: EdgeInsets.fromLTRB(
                    16, widget.scrollController != null ? 20 : 16, 16, 0),
                children: [
                  const Text('What kind of feedback do you want to give?'),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      const Padding(
                        padding: EdgeInsets.only(right: 8),
                        child: Text('*'),
                      ),
                      Flexible(
                        child: DropdownButton<FeedbackType>(
                          value: _customFeedback.feedbackType,
                          items: FeedbackType.values
                              .map(
                                (type) => DropdownMenuItem<FeedbackType>(
                                  child: Text(type
                                      .toString()
                                      .split('.')
                                      .last
                                      .replaceAll('_', ' ')),
                                  value: type,
                                ),
                              )
                              .toList(),
                          onChanged: (feedbackType) => setState(() =>
                              _customFeedback.feedbackType = feedbackType),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Text('What is your feedback?'),
                  TextField(
                    onChanged: (newFeedback) =>
                        _customFeedback.feedbackText = newFeedback,
                  ),
                  const SizedBox(height: 16),
                  const Text('Provide an email to stay in contact (optional)'),
                  TextField(
                    onChanged: (newEmail) => _customFeedback.email = newEmail,
                  )
                ],
              ),
            ],
          ),
        ),
        TextButton(
          // disable this button until the user has specified a feedback type
          onPressed: _customFeedback.feedbackType != null
              ? () => _showPrivacyAlert(context)
              : null,
          child: const Text('submit'),
        ),
        const SizedBox(height: 8),
      ],
    );
  }

  _showPrivacyAlert(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Submit Feedback'),
          content: Linkify(
              text: "By submitting feedback, you agree to our "
                      "Terms of Service and Privacy Policy, which can be found at " +
                  fixed_values.privacyUrl,
              onOpen: (link) async {
                if (await canLaunch(link.url)) {
                  await launch(link.url);
                }
              }),
          actions: [
            ElevatedButton(
              child: const Text('Cancel'),
              onPressed: () => Navigator.pop(context),
            ),
            ElevatedButton(
              child: const Text('Submit'),
              onPressed: () {
                widget.onSubmit(
                  _customFeedback.feedbackText ?? '',
                  extras: _customFeedback.toMap(),
                );
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }
}
