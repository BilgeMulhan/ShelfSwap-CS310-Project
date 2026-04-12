import 'package:flutter/material.dart';
import '../utils/app_paddings.dart';
import '../utils/app_text_styles.dart';

class RequestChatScreen extends StatelessWidget {
  const RequestChatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final bubbleMaxWidth = screenWidth * 0.7;
    final messages = [
      {'text': 'Hey! I saw you are interested in swapping for my Calculus book.', 'isMe': false},
      {'text': 'Yes! I can swap it with a pair of headphones.', 'isMe': true},
      {'text': 'Sounds great! When and where would be a good time for us to meet?', 'isMe': false},
      {'text': 'How about tomorrow around noon by the campus library?', 'isMe': true},
      {'text': 'Perfect! See you there tomorrow at noon.', 'isMe': false},
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Requests')),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: AppPaddings.screen,
              child: Row(
                children: [
                  const CircleAvatar(radius: 24),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Ahmet Y.', style: AppTextStyles.sectionTitle.copyWith(fontSize: 16)),
                      const Text('Calculus Book'),
                      const Text('Campus Dorm'),
                    ],
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: messages.length,
                itemBuilder: (context, index) {
                  final message = messages[index];
                  final isMe = message['isMe'] as bool;
                  return Align(
                    alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.all(12),
                      constraints: BoxConstraints(maxWidth: bubbleMaxWidth),
                      decoration: BoxDecoration(
                        color: isMe ? Colors.blue.shade100 : Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(message['text'] as String),
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'Type a message...',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(30)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  CircleAvatar(
                    radius: 24,
                    child: IconButton(
                      onPressed: () {},
                      icon: const Icon(Icons.send),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}