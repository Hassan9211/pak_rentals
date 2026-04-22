import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/theme.dart';
import '../services/user_state.dart';
import '../widgets/common_widgets.dart';

// ── Message model ──
class _Msg {
  final String text;
  final bool isMe;
  final DateTime time;

  _Msg({required this.text, required this.isMe, required this.time});
}

// ── Conversation model ──
class _Conv {
  final String id;
  final String initials;
  final List<Color> colors;
  final String name;
  final String role;
  bool isOnline;
  List<_Msg> messages;
  int unread;

  _Conv({
    required this.id,
    required this.initials,
    required this.colors,
    required this.name,
    required this.role,
    this.isOnline = false,
    required this.messages,
    this.unread = 0,
  });

  String get lastMsg => messages.isEmpty ? '' : messages.last.text;
  DateTime get lastTime => messages.isEmpty ? DateTime.now() : messages.last.time;
}

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  _Conv? _activeConv;
  final TextEditingController _msgCtrl = TextEditingController();
  final ScrollController _scrollCtrl = ScrollController();
  final FocusNode _focusNode = FocusNode();
  bool _isTyping = false; // simulated "other person typing"

  late List<_Conv> _conversations;

  @override
  void initState() {
    super.initState();
    _conversations = [
      _Conv(
        id: 'c1',
        initials: 'AK',
        colors: [AppColors.cyan, AppColors.purple],
        name: 'Ahmed Khan',
        role: 'Host · 3-Bed House',
        isOnline: true,
        unread: 1,
        messages: [
          _Msg(text: 'Hello! Is the house still available from May 8th?', isMe: false, time: _t(10, 32)),
          _Msg(text: "Yes! It's available from May 8-14. Would you like to visit?", isMe: true, time: _t(10, 35)),
          _Msg(text: 'Yes please. Also is parking included?', isMe: false, time: _t(10, 37)),
          _Msg(text: 'Yes, parking is available for 2 cars at no extra cost.', isMe: true, time: _t(10, 38)),
        ],
      ),
      _Conv(
        id: 'c2',
        initials: 'FB',
        colors: [AppColors.pink, AppColors.purple],
        name: 'Fatima Bibi',
        role: 'Shadi Wear',
        isOnline: false,
        unread: 1,
        messages: [
          _Msg(text: 'Is the bridal lehenga available for June 15?', isMe: true, time: _t(9, 0)),
          _Msg(text: 'The lehenga is available on your dates', isMe: false, time: _t(9, 5)),
        ],
      ),
      _Conv(
        id: 'c3',
        initials: 'UM',
        colors: [const Color(0xFF378ADD), AppColors.cyan],
        name: 'Usman Malik',
        role: 'Vehicles',
        isOnline: false,
        unread: 0,
        messages: [
          _Msg(text: 'I am returning the bike now', isMe: true, time: _t(15, 0)),
          _Msg(text: 'The bike has been returned, thanks!', isMe: false, time: _t(15, 10)),
        ],
      ),
      _Conv(
        id: 'c4',
        initials: 'ZA',
        colors: [AppColors.warning, AppColors.pink],
        name: 'Zara Abbasi',
        role: 'Property',
        isOnline: true,
        unread: 0,
        messages: [
          _Msg(text: 'Can I visit the room tomorrow?', isMe: false, time: _t(11, 0)),
        ],
      ),
    ];
  }

  @override
  void dispose() {
    _msgCtrl.dispose();
    _scrollCtrl.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  DateTime _t(int h, int m) {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day, h, m);
  }

  void _sendMessage() {
    final text = _msgCtrl.text.trim();
    if (text.isEmpty || _activeConv == null) return;

    setState(() {
      _activeConv!.messages.add(_Msg(
        text: text,
        isMe: true,
        time: DateTime.now(),
      ));
      // Update unread in conversation list
      _activeConv!.unread = 0;
      _msgCtrl.clear();
    });

    _scrollToBottom();

    // Simulate reply after 1.5s
    setState(() => _isTyping = true);
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (!mounted) return;
      setState(() {
        _isTyping = false;
        _activeConv!.messages.add(_Msg(
          text: _autoReply(text),
          isMe: false,
          time: DateTime.now(),
        ));
      });
      _scrollToBottom();
    });
  }

  String _autoReply(String msg) {
    final lower = msg.toLowerCase();
    if (lower.contains('price') || lower.contains('cost') || lower.contains('kitna')) {
      return 'The price is as listed. Feel free to negotiate if booking for longer duration!';
    }
    if (lower.contains('available') || lower.contains('book')) {
      return 'Yes, it is available! You can go ahead and book it.';
    }
    if (lower.contains('visit') || lower.contains('see') || lower.contains('dekh')) {
      return 'Sure! You can visit anytime between 10 AM – 6 PM. Just let me know.';
    }
    if (lower.contains('thank') || lower.contains('shukriya')) {
      return 'You are welcome! 😊';
    }
    if (lower.contains('hello') || lower.contains('hi') || lower.contains('salam')) {
      return 'Hello! How can I help you?';
    }
    return 'Got it! I will get back to you shortly. 👍';
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollCtrl.hasClients) {
        _scrollCtrl.animateTo(
          _scrollCtrl.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  int get _totalUnread =>
      _conversations.fold(0, (sum, c) => sum + c.unread);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: _activeConv == null ? _buildInbox() : _buildChat(),
      ),
    );
  }

  // ── INBOX ──
  Widget _buildInbox() {
    return Column(
      children: [
        // Header
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: const BoxDecoration(
            color: AppColors.bgElevated,
            border: Border(bottom: BorderSide(color: AppColors.borderLight, width: 0.5)),
          ),
          child: Row(
            children: [
              Text('Inbox',
                  style: GoogleFonts.syne(
                      fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
              const SizedBox(width: 8),
              if (_totalUnread > 0)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.cyan.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text('$_totalUnread unread',
                      style: GoogleFonts.dmSans(
                          fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.cyan)),
                ),
            ],
          ),
        ),
        Expanded(
          child: _conversations.isEmpty
              ? _buildEmptyInbox()
              : ListView.builder(
                  itemCount: _conversations.length,
                  itemBuilder: (context, i) => _buildConvTile(_conversations[i]),
                ),
        ),
      ],
    );
  }

  Widget _buildConvTile(_Conv c) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _activeConv = c;
          c.unread = 0;
        });
        // Scroll to bottom after opening
        Future.delayed(const Duration(milliseconds: 100), _scrollToBottom);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: c.unread > 0 ? AppColors.bgElevated : AppColors.bg,
          border: const Border(bottom: BorderSide(color: AppColors.borderLight, width: 0.5)),
        ),
        child: Row(
          children: [
            Stack(
              children: [
                UserAvatar(initials: c.initials, size: 46, colors: c.colors),
                if (c.isOnline)
                  Positioned(
                    right: 0, bottom: 0,
                    child: Container(
                      width: 12, height: 12,
                      decoration: BoxDecoration(
                        color: AppColors.success,
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.bg, width: 2),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(c.name,
                          style: GoogleFonts.dmSans(
                            fontSize: 13,
                            fontWeight: c.unread > 0 ? FontWeight.w700 : FontWeight.w500,
                            color: AppColors.textPrimary,
                          )),
                      Text(_formatTime(c.lastTime),
                          style: GoogleFonts.dmSans(
                              fontSize: 10,
                              color: c.unread > 0 ? AppColors.cyan : AppColors.textMuted)),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(c.role,
                      style: GoogleFonts.dmSans(fontSize: 10, color: AppColors.cyan)),
                  const SizedBox(height: 2),
                  Text(
                    c.lastMsg,
                    style: GoogleFonts.dmSans(
                      fontSize: 12,
                      color: c.unread > 0 ? AppColors.textSecondary : AppColors.textMuted,
                      fontWeight: c.unread > 0 ? FontWeight.w500 : FontWeight.normal,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            if (c.unread > 0) ...[
              const SizedBox(width: 8),
              Container(
                width: 20, height: 20,
                decoration: const BoxDecoration(color: AppColors.cyan, shape: BoxShape.circle),
                child: Center(
                  child: Text('${c.unread}',
                      style: GoogleFonts.dmSans(
                          fontSize: 10, fontWeight: FontWeight.w700, color: Colors.black)),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyInbox() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('💬', style: TextStyle(fontSize: 48)),
          const SizedBox(height: 12),
          Text('No messages yet',
              style: GoogleFonts.syne(
                  fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
          const SizedBox(height: 6),
          Text('Message a host from any listing',
              style: GoogleFonts.dmSans(fontSize: 13, color: AppColors.textMuted)),
        ],
      ),
    );
  }

  // ── CHAT ──
  Widget _buildChat() {
    final conv = _activeConv!;
    return Column(
      children: [
        // Chat header
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: const BoxDecoration(
            color: AppColors.bgElevated,
            border: Border(bottom: BorderSide(color: AppColors.borderLight, width: 0.5)),
          ),
          child: Row(
            children: [
              GestureDetector(
                onTap: () => setState(() => _activeConv = null),
                child: const AppBackButton(),
              ),
              const SizedBox(width: 10),
              Stack(
                children: [
                  UserAvatar(initials: conv.initials, size: 36, colors: conv.colors),
                  if (conv.isOnline)
                    Positioned(
                      right: 0, bottom: 0,
                      child: Container(
                        width: 10, height: 10,
                        decoration: BoxDecoration(
                          color: AppColors.success,
                          shape: BoxShape.circle,
                          border: Border.all(color: AppColors.bgElevated, width: 1.5),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(conv.name,
                        style: GoogleFonts.dmSans(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary)),
                    Text(
                      conv.isOnline ? 'Online now' : conv.role,
                      style: GoogleFonts.dmSans(
                          fontSize: 10,
                          color: conv.isOnline ? AppColors.success : AppColors.textMuted),
                    ),
                  ],
                ),
              ),
              // Info button
              Container(
                width: 32, height: 32,
                decoration: BoxDecoration(
                  color: AppColors.bgInput,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.borderLight, width: 0.5),
                ),
                child: const Icon(Icons.info_outline, size: 16, color: AppColors.textSecondary),
              ),
            ],
          ),
        ),

        // Messages list
        Expanded(
          child: ListView.builder(
            controller: _scrollCtrl,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            itemCount: conv.messages.length + (_isTyping ? 1 : 0),
            itemBuilder: (context, i) {
              // Typing indicator
              if (_isTyping && i == conv.messages.length) {
                return _buildTypingIndicator(conv);
              }
              return _buildBubble(conv.messages[i]);
            },
          ),
        ),

        // Input bar
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: const BoxDecoration(
            color: AppColors.bgElevated,
            border: Border(top: BorderSide(color: AppColors.borderLight, width: 0.5)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Container(
                  constraints: const BoxConstraints(maxHeight: 120),
                  decoration: BoxDecoration(
                    color: AppColors.bgInput,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.borderLight, width: 0.5),
                  ),
                  child: TextField(
                    controller: _msgCtrl,
                    focusNode: _focusNode,
                    maxLines: null,
                    keyboardType: TextInputType.multiline,
                    textInputAction: TextInputAction.newline,
                    style: GoogleFonts.dmSans(fontSize: 14, color: AppColors.textPrimary),
                    decoration: InputDecoration(
                      hintText: 'Type a message...',
                      hintStyle: GoogleFonts.dmSans(fontSize: 14, color: AppColors.textMuted),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      isDense: true,
                    ),
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: _sendMessage,
                child: Container(
                  width: 40, height: 40,
                  decoration: const BoxDecoration(
                    color: AppColors.cyan,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.send_rounded, size: 18, color: Colors.black),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBubble(_Msg m) {
    final isMe = m.isMe;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isMe) ...[
            UserAvatar(
              initials: _activeConv!.initials,
              size: 26,
              colors: _activeConv!.colors,
            ),
            const SizedBox(width: 6),
          ],
          Column(
            crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
            children: [
              Container(
                constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width * 0.65,
                ),
                padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 9),
                decoration: BoxDecoration(
                  color: isMe ? AppColors.cyan : AppColors.bgCard,
                  borderRadius: BorderRadius.only(
                    topLeft: const Radius.circular(14),
                    topRight: const Radius.circular(14),
                    bottomLeft: isMe ? const Radius.circular(14) : const Radius.circular(2),
                    bottomRight: isMe ? const Radius.circular(2) : const Radius.circular(14),
                  ),
                  border: isMe ? null : Border.all(color: AppColors.borderLight, width: 0.5),
                ),
                child: Text(
                  m.text,
                  style: GoogleFonts.dmSans(
                    fontSize: 13,
                    color: isMe ? Colors.black : AppColors.textPrimary,
                    height: 1.4,
                  ),
                ),
              ),
              const SizedBox(height: 3),
              Text(
                _formatTime(m.time),
                style: GoogleFonts.dmSans(fontSize: 9, color: AppColors.textMuted),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTypingIndicator(_Conv conv) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          UserAvatar(initials: conv.initials, size: 26, colors: conv.colors),
          const SizedBox(width: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.bgCard,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(14),
                topRight: Radius.circular(14),
                bottomRight: Radius.circular(14),
                bottomLeft: Radius.circular(2),
              ),
              border: Border.all(color: AppColors.borderLight, width: 0.5),
            ),
            child: Row(
              children: [
                _dot(0),
                const SizedBox(width: 3),
                _dot(150),
                const SizedBox(width: 3),
                _dot(300),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _dot(int delayMs) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.3, end: 1.0),
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeInOut,
      builder: (_, v, __) => Opacity(
        opacity: v,
        child: Container(
          width: 6, height: 6,
          decoration: const BoxDecoration(
            color: AppColors.textMuted,
            shape: BoxShape.circle,
          ),
        ),
      ),
    );
  }

  String _formatTime(DateTime t) {
    final h = t.hour > 12 ? t.hour - 12 : t.hour == 0 ? 12 : t.hour;
    final m = t.minute.toString().padLeft(2, '0');
    final ampm = t.hour >= 12 ? 'PM' : 'AM';
    return '$h:$m $ampm';
  }
}
