import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/message_model.dart';
import '../widgets/chat_screen_widgets/chat_bubble.dart';
import '../widgets/chat_screen_widgets/chat_input_field.dart';

class ChatScreen extends StatefulWidget {
  final String receiverId;
  final String receiverName;
  final String receiverAvatar;

  const ChatScreen({
    super.key,
    required this.receiverId,
    required this.receiverName,
    required this.receiverAvatar,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final List<Message> _messages = [];

  @override
  void initState() {
    super.initState();
    _fetchInitialMessages();
    _listenToMessages();
  }

  Future<void> _fetchInitialMessages() async {
    final userId = Supabase.instance.client.auth.currentUser?.id;

    final response = await Supabase.instance.client
        .from('messages')
        .select()
        .or('sender_id.eq.$userId,receiver_id.eq.$userId')
        .order('created_at');

    final data = response as List<dynamic>;
    setState(() {
      _messages.addAll(
        data.where((msg) =>
            (msg['sender_id'] == userId && msg['receiver_id'] == widget.receiverId) ||
            (msg['sender_id'] == widget.receiverId && msg['receiver_id'] == userId)).map(
          (msg) => Message(
            sender: msg['sender_id'],
            text: msg['text'],
            time: msg['created_at'],
            isMe: msg['sender_id'] == userId,
            avatarUrl: msg['avatar'] ?? 'https://i.pravatar.cc/150?img=3',
          ),
        ),
      );
    });
  }

  void _listenToMessages() {
    final userId = Supabase.instance.client.auth.currentUser?.id;

    Supabase.instance.client
        .from('messages')
        .stream(primaryKey: ['id'])
        .order('created_at')
        .listen((List<Map<String, dynamic>> data) {
      final filtered = data.where((msg) =>
          (msg['sender_id'] == userId && msg['receiver_id'] == widget.receiverId) ||
          (msg['sender_id'] == widget.receiverId && msg['receiver_id'] == userId));

      setState(() {
        _messages
          ..clear()
          ..addAll(filtered.map((msg) => Message(
                sender: msg['sender_id'],
                text: msg['text'],
                time: msg['created_at'],
                isMe: msg['sender_id'] == userId,
                avatarUrl: msg['avatar'] ?? 'https://i.pravatar.cc/150?img=3',
              )));
      });
    });
  }

  void _sendMessage() async {
    if (_controller.text.trim().isEmpty) return;

    final text = _controller.text.trim();
    final userId = Supabase.instance.client.auth.currentUser?.id;

    await Supabase.instance.client.from('messages').insert({
      'sender_id': userId,
      'receiver_id': widget.receiverId,
      'text': text,
      'avatar': 'https://i.pravatar.cc/150?img=5', // current user avatar
    });

    _controller.clear();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: Row(
          children: [
            CircleAvatar(backgroundImage: NetworkImage(widget.receiverAvatar)),
            const SizedBox(width: 10),
            Text(
              widget.receiverName,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ],
        ),
        actions: const [
          SizedBox(width: 8),
          Icon(Icons.more_vert),
          SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        bottom: false,
        child: Column(
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
            SafeArea(
              top: false,
              child: ChatInputField(
                controller: _controller,
                onSend: _sendMessage,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
