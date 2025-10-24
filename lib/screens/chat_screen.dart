import 'package:flutter/material.dart';
import '../models/message_model.dart';
import '../widgets/chat_bubble.dart';
import '../widgets/chat_input_field.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();

  final List<Message> _messages = [
    Message(
      sender: "John Doe",
      text:
          "Hey! I saw your profile and I'm also looking for a place to stay. I'm a student at the University of California, Berkeley. What about you?",
      time: "10:30 AM",
      isMe: false,
      avatarUrl:
          "https://i.pravatar.cc/150?img=3", // Example placeholder
    ),
    Message(
      sender: "Jane Doe",
      text:
          "Hi John! I'm a student at the University of California, Berkeley as well. I'm looking for a place to stay with a roommate. What's your budget?",
      time: "10:31 AM",
      isMe: true,
      avatarUrl:
          "https://i.pravatar.cc/150?img=5",
    ),
    Message(
      sender: "John Doe",
      text: "My budget is around \$1000 per month. What about you?",
      time: "10:32 AM",
      isMe: false,
      avatarUrl:
          "https://i.pravatar.cc/150?img=3",
    ),
  ];

  void _sendMessage() {
    if (_controller.text.trim().isEmpty) return;

    setState(() {
      _messages.add(
        Message(
          sender: "Jane Doe",
          text: _controller.text.trim(),
          time: "Now",
          isMe: true,
          avatarUrl: "https://i.pravatar.cc/150?img=5",
        ),
      );
      _controller.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const CircleAvatar(
              backgroundImage: NetworkImage("https://i.pravatar.cc/150?img=5"),
            ),
            const SizedBox(width: 10),
            const Text("Jane Doe"),
          ],
        ),
        actions: const [
          SizedBox(width: 8),
          Icon(Icons.more_vert),
          SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                return ChatBubble(message: _messages[index]);
              },
            ),
          ),
          ChatInputField(
            controller: _controller,
            onSend: _sendMessage,
          ),
        ],
      ),
    );
  }
}
