import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/theme.dart';
import '../services/api_client.dart';
import '../services/user_state.dart';
import '../widgets/common_widgets.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  List<Map<String, dynamic>> _conversations = [];
  Map<String, dynamic>? _activeConv;
  List<Map<String, dynamic>> _messages = [];

  bool _loadingConvs = true;
  bool _loadingMsgs = false;

  final TextEditingController _msgCtrl = TextEditingController();
  final ScrollController _scrollCtrl = ScrollController();
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _loadConversations();
  }

  @override
  void dispose() {
    _msgCtrl.dispose();
    _scrollCtrl.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _loadConversations() async {
    setState(() => _loadingConvs = true);
    try {
      final res = await MessagesApi.getConversations();
      final list = res['data'] as List? ?? [];
      if (mounted) {
        setState(() {
          _conversations = list.cast<Map<String, dynamic>>();
          _loadingConvs = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _loadingConvs = false);
    }
  }

  Future<void> _openConversation(Map<String, dynamic> conv) async {
    setState(() { _activeConv = conv; _loadingMsgs = true; _messages = []; });

    try {
      final listingId = (conv['listing']?['id'] ?? conv['listing_id'])?.toString() ?? '';
      final contactId = (conv['contact']?['id'])?.toString() ?? '';
      if (listingId.isNotEmpty && contactId.isNotEmpty) {
        final res = await MessagesApi.getThread(listingId, contactId);
        final list = res['data'] as List? ?? [];
        if (mounted) {
          setState(() {
            _messages = list.cast<Map<String, dynamic>>();
            _loadingMsgs = false;
          });
          _scrollToBottom();
        }
      } else {
        if (mounted) setState(() => _loadingMsgs = false);
      }
    } catch (_) {
      if (mounted) setState(() => _loadingMsgs = false);
    }
  }

  Future<void> _sendMessage() async {
    final text = _msgCtrl.text.trim();
    if (text.isEmpty || _activeConv == null) return;

    final myId = UserState().email; // used as sender identifier
    final listingId = (_activeConv!['listing']?['id'] ?? _activeConv!['listing_id'])?.toString() ?? '';
    final receiverId = (_activeConv!['contact']?['id'])?.toString() ?? '';

    // Optimistic UI — add message immediately
    final optimistic = {
      'message': text,
      'sender_id': myId,
      'sent_at': DateTime.now().toIso8601String(),
      '_isMe': true,
    };
    setState(() {
      _messages.add(optimistic);
      _msgCtrl.clear();
    });
    _scrollToBottom();

    try {
      await MessagesApi.send(
        receiverId: receiverId,
        listingId: listingId,
        message: text,
      );
      // Reload to get server message with real ID
      if (_activeConv != null) _openConversation(_activeConv!);
    } catch (_) {
      // Remove optimistic message on failure
      if (mounted) {
        setState(() => _messages.remove(optimistic));
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Failed to send message', style: GoogleFonts.dmSans(fontSize: 13, color: Colors.white)),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(16),
        ));
      }
    }
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

  int get _totalUnread => _conversations.fold(0, (sum, c) => sum + ((c['unread_count'] as int?) ?? 0));

  String _contactName(Map<String, dynamic> conv) =>
      conv['contact']?['name'] as String? ?? 'User';

  String _contactInitials(Map<String, dynamic> conv) {
    final name = _contactName(conv);
    final parts = name.trim().split(' ');
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return (parts[0][0] + parts[parts.length - 1][0]).toUpperCase();
  }

  String _listingTitle(Map<String, dynamic> conv) =>
      conv['listing']?['title'] as String? ?? '';

  bool _isMe(Map<String, dynamic> msg) {
    final myId = UserState().email;
    final senderId = msg['sender']?['email'] ?? msg['sender_id'] ?? '';
    return senderId == myId || msg['_isMe'] == true;
  }

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
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: const BoxDecoration(
            color: AppColors.bgElevated,
            border: Border(bottom: BorderSide(color: AppColors.borderLight, width: 0.5)),
          ),
          child: Row(
            children: [
              Text('Inbox', style: GoogleFonts.syne(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
              const SizedBox(width: 8),
              if (_totalUnread > 0)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.cyan.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text('$_totalUnread unread',
                      style: GoogleFonts.dmSans(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.cyan)),
                ),
            ],
          ),
        ),
        Expanded(
          child: _loadingConvs
              ? const Center(child: CircularProgressIndicator(color: AppColors.cyan, strokeWidth: 2))
              : _conversations.isEmpty
                  ? _buildEmptyInbox()
                  : RefreshIndicator(
                      color: AppColors.cyan,
                      backgroundColor: AppColors.bgCard,
                      onRefresh: _loadConversations,
                      child: ListView.builder(
                        itemCount: _conversations.length,
                        itemBuilder: (context, i) => _buildConvTile(_conversations[i]),
                      ),
                    ),
        ),
      ],
    );
  }

  Widget _buildConvTile(Map<String, dynamic> c) {
    final unread = (c['unread_count'] as int?) ?? 0;
    final lastMsg = c['last_message'] as String? ?? '';
    final listingTitle = _listingTitle(c);

    return GestureDetector(
      onTap: () => _openConversation(c),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: unread > 0 ? AppColors.bgElevated : AppColors.bg,
          border: const Border(bottom: BorderSide(color: AppColors.borderLight, width: 0.5)),
        ),
        child: Row(
          children: [
            UserAvatar(initials: _contactInitials(c), size: 46),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(_contactName(c),
                          style: GoogleFonts.dmSans(
                              fontSize: 13,
                              fontWeight: unread > 0 ? FontWeight.w700 : FontWeight.w500,
                              color: AppColors.textPrimary)),
                      Text(_formatTime(c['last_message_at'] as String?),
                          style: GoogleFonts.dmSans(
                              fontSize: 10,
                              color: unread > 0 ? AppColors.cyan : AppColors.textMuted)),
                    ],
                  ),
                  if (listingTitle.isNotEmpty)
                    Text('Re: $listingTitle', style: GoogleFonts.dmSans(fontSize: 10, color: AppColors.cyan)),
                  const SizedBox(height: 2),
                  Text(lastMsg,
                      style: GoogleFonts.dmSans(
                          fontSize: 12,
                          color: unread > 0 ? AppColors.textSecondary : AppColors.textMuted,
                          fontWeight: unread > 0 ? FontWeight.w500 : FontWeight.normal),
                      maxLines: 1, overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
            if (unread > 0) ...[
              const SizedBox(width: 8),
              Container(
                width: 20, height: 20,
                decoration: const BoxDecoration(color: AppColors.cyan, shape: BoxShape.circle),
                child: Center(child: Text('$unread',
                    style: GoogleFonts.dmSans(fontSize: 10, fontWeight: FontWeight.w700, color: Colors.black))),
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
          Text('No messages yet', style: GoogleFonts.syne(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
          const SizedBox(height: 6),
          Text('Message a host from any listing', style: GoogleFonts.dmSans(fontSize: 13, color: AppColors.textMuted)),
        ],
      ),
    );
  }

  // ── CHAT ──
  Widget _buildChat() {
    final conv = _activeConv!;
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: const BoxDecoration(
            color: AppColors.bgElevated,
            border: Border(bottom: BorderSide(color: AppColors.borderLight, width: 0.5)),
          ),
          child: Row(
            children: [
              GestureDetector(
                onTap: () { setState(() { _activeConv = null; _messages = []; }); _loadConversations(); },
                child: const AppBackButton(),
              ),
              const SizedBox(width: 10),
              UserAvatar(initials: _contactInitials(conv), size: 36),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(_contactName(conv),
                        style: GoogleFonts.dmSans(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                    if (_listingTitle(conv).isNotEmpty)
                      Text(_listingTitle(conv), style: GoogleFonts.dmSans(fontSize: 10, color: AppColors.cyan)),
                  ],
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: _loadingMsgs
              ? const Center(child: CircularProgressIndicator(color: AppColors.cyan, strokeWidth: 2))
              : _messages.isEmpty
                  ? Center(child: Text('No messages yet', style: GoogleFonts.dmSans(fontSize: 13, color: AppColors.textMuted)))
                  : ListView.builder(
                      controller: _scrollCtrl,
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      itemCount: _messages.length,
                      itemBuilder: (context, i) => _buildBubble(_messages[i]),
                    ),
        ),
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
                  decoration: const BoxDecoration(color: AppColors.cyan, shape: BoxShape.circle),
                  child: const Icon(Icons.send_rounded, size: 18, color: Colors.black),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBubble(Map<String, dynamic> m) {
    final isMe = _isMe(m);
    final text = m['message'] as String? ?? '';
    final time = m['sent_at'] as String?;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isMe) ...[
            UserAvatar(initials: _contactInitials(_activeConv!), size: 26),
            const SizedBox(width: 6),
          ],
          Column(
            crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
            children: [
              Container(
                constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.65),
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
                child: Text(text,
                    style: GoogleFonts.dmSans(
                        fontSize: 13,
                        color: isMe ? Colors.black : AppColors.textPrimary,
                        height: 1.4)),
              ),
              const SizedBox(height: 3),
              Text(_formatTime(time), style: GoogleFonts.dmSans(fontSize: 9, color: AppColors.textMuted)),
            ],
          ),
        ],
      ),
    );
  }

  String _formatTime(String? iso) {
    if (iso == null) return '';
    try {
      final dt = DateTime.parse(iso).toLocal();
      final h = dt.hour > 12 ? dt.hour - 12 : dt.hour == 0 ? 12 : dt.hour;
      final m = dt.minute.toString().padLeft(2, '0');
      final ampm = dt.hour >= 12 ? 'PM' : 'AM';
      return '$h:$m $ampm';
    } catch (_) {
      return '';
    }
  }
}
