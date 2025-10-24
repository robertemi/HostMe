class Message {
  final String sender;
  final String text;
  final String time;
  final bool isMe;
  final String avatarUrl;

  Message({
    required this.sender,
    required this.text,
    required this.time,
    required this.isMe,
    required this.avatarUrl,
  });
}
