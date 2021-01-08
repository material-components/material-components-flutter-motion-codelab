class Email {
  const Email({
    required this.sender,
    required this.time,
    required this.subject,
    required this.message,
    required this.avatar,
    required this.recipients,
    required this.containsPictures,
  });

  final String sender;
  final String time;
  final String subject;
  final String message;
  final String avatar;
  final String recipients;
  final bool containsPictures;
}
