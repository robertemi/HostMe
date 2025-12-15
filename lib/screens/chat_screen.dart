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
  late final String userId;

  @override
  void initState() {
    super.initState();
    userId = Supabase.instance.client.auth.currentUser!.id;

    _fetchInitialMessages();
    _listenToMessages();
  }

  // -----------------------------
  // 1. INITIAL LOAD (NO SORTING)
  // -----------------------------
  Future<void> _fetchInitialMessages() async {
    final data = await Supabase.instance.client
        .from('messages')
        .select()
        .or(
          'and(sender_id.eq.$userId,receiver_id.eq.${widget.receiverId}),'
          'and(sender_id.eq.${widget.receiverId},receiver_id.eq.$userId)',
        )
        .order('created_at', ascending: true);

    setState(() {
      _messages.clear();
      for (var msg in data) {
        final time = DateTime.tryParse(msg['created_at']) ?? DateTime.now();
        _messages.add(
          Message(
            sender: msg['sender_id'],
            text: msg['text'],
            time: time,
            isMe: msg['sender_id'] == userId,
          ),
        );
      }
    });
  }

  // -----------------------------
  // 2. REALTIME LISTENER
  // -----------------------------
  void _listenToMessages() {
    Supabase.instance.client
        .channel('messages-channel')
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: 'messages',
          callback: (payload) {
            final msg = payload.newRecord;

            // Only messages for this conversation
            final sender = msg['sender_id'];
            final receiver = msg['receiver_id'];

            if (!(
              (sender == userId && receiver == widget.receiverId) ||
              (sender == widget.receiverId && receiver == userId)
            )) {
              return;
            }

            final createdAt = msg['created_at'];
            if (_messages.any((m) => m.time.toIso8601String() == createdAt)) return;

            final time = DateTime.tryParse(createdAt) ?? DateTime.now();

            setState(() {
              _messages.add(
                Message(
                  sender: sender,
                  text: msg['text'],
                  time: time,
                  isMe: sender == userId,
                ),
              );
            });
          },
        )
        .subscribe();
  }

  // -----------------------------
  // 3. SEND MESSAGE
  // -----------------------------
  void _sendMessage() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    await Supabase.instance.client.from('messages').insert({
      'sender_id': userId,
      'receiver_id': widget.receiverId,
      'text': text,
    });

    _controller.clear();
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
            Text(widget.receiverName),
          ],
        ),
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
