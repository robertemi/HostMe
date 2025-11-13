class MatchModel {
  final String id;
  final String name;
  final String message;
  final String timeAgo;
  final String avatarUrl;
  final bool isOnline;
  final int unreadCount;

  MatchModel({
    required this.id,
    required this.name,
    required this.message,
    required this.timeAgo,
    required this.avatarUrl,
    this.isOnline = false,
    this.unreadCount = 0,
  });
}
