class Message {
  final String id;
  final String conversationId;
  final String senderId;
  final String senderName;
  final String senderInitials;
  final String receiverId;
  final String text;
  final DateTime sentAt;
  final bool isRead;

  const Message({
    required this.id,
    required this.conversationId,
    required this.senderId,
    required this.senderName,
    required this.senderInitials,
    required this.receiverId,
    required this.text,
    required this.sentAt,
    this.isRead = false,
  });
}

class Conversation {
  final String id;
  final String otherUserId;
  final String otherUserName;
  final String otherUserInitials;
  final String lastMessage;
  final DateTime lastMessageAt;
  final int unreadCount;
  final String? relatedListingId;
  final String? relatedListingTitle;

  const Conversation({
    required this.id,
    required this.otherUserId,
    required this.otherUserName,
    required this.otherUserInitials,
    required this.lastMessage,
    required this.lastMessageAt,
    this.unreadCount = 0,
    this.relatedListingId,
    this.relatedListingTitle,
  });
}

class SampleMessages {
  static final List<Conversation> conversations = [
    Conversation(
      id: 'c1',
      otherUserId: 'u1',
      otherUserName: 'Ahmed Khan',
      otherUserInitials: 'AK',
      lastMessage: 'Yes, parking is available for 2 cars...',
      lastMessageAt: DateTime(2026, 4, 21, 10, 38),
      unreadCount: 1,
      relatedListingId: '1',
      relatedListingTitle: '3-Bed House – Model Town',
    ),
    Conversation(
      id: 'c2',
      otherUserId: 'u3',
      otherUserName: 'Fatima Bibi',
      otherUserInitials: 'FB',
      lastMessage: 'The lehenga is available on your dates',
      lastMessageAt: DateTime(2026, 4, 21, 9, 0),
      unreadCount: 1,
      relatedListingId: '3',
      relatedListingTitle: 'Bridal Lehenga Full Set',
    ),
    Conversation(
      id: 'c3',
      otherUserId: 'u5',
      otherUserName: 'Usman Malik',
      otherUserInitials: 'UM',
      lastMessage: 'The bike has been returned, thanks!',
      lastMessageAt: DateTime(2026, 4, 20, 15, 0),
      unreadCount: 0,
    ),
    Conversation(
      id: 'c4',
      otherUserId: 'u4',
      otherUserName: 'Zara Abbasi',
      otherUserInitials: 'ZA',
      lastMessage: 'Can I visit the room tomorrow?',
      lastMessageAt: DateTime(2026, 4, 19, 11, 0),
      unreadCount: 0,
    ),
  ];

  static final List<Message> thread = [
    Message(
      id: 'm1',
      conversationId: 'c1',
      senderId: 'u3',
      senderName: 'Fatima Bibi',
      senderInitials: 'FB',
      receiverId: 'u1',
      text: 'Hello! Is the house still available from May 8th?',
      sentAt: DateTime(2026, 4, 21, 10, 32),
      isRead: true,
    ),
    Message(
      id: 'm2',
      conversationId: 'c1',
      senderId: 'u1',
      senderName: 'Ahmed Khan',
      senderInitials: 'AK',
      receiverId: 'u3',
      text: "Yes! It's available from May 8-14. Would you like to visit?",
      sentAt: DateTime(2026, 4, 21, 10, 35),
      isRead: true,
    ),
    Message(
      id: 'm3',
      conversationId: 'c1',
      senderId: 'u3',
      senderName: 'Fatima Bibi',
      senderInitials: 'FB',
      receiverId: 'u1',
      text: 'Yes please. Also is parking included?',
      sentAt: DateTime(2026, 4, 21, 10, 37),
      isRead: true,
    ),
    Message(
      id: 'm4',
      conversationId: 'c1',
      senderId: 'u1',
      senderName: 'Ahmed Khan',
      senderInitials: 'AK',
      receiverId: 'u3',
      text: 'Yes, parking is available for 2 cars at no extra cost.',
      sentAt: DateTime(2026, 4, 21, 10, 38),
      isRead: false,
    ),
  ];
}
