import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ChatScreen extends StatefulWidget {
  final String matchId;

  const ChatScreen({super.key, required this.matchId});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final supabase = Supabase.instance.client;
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  List messages = [];

  @override
  void initState() {
    super.initState();
    fetchMessages();
    listenToMessages();
  }

  Future<void> fetchMessages() async {
    final data = await supabase
        .from('chat_messages')
        .select()
        .eq('match_id', widget.matchId)
        .order('created_at');

    setState(() {
      messages = data;
    });

    scrollToBottom();
  }

  void listenToMessages() {
    supabase
        .channel('chat_${widget.matchId}')
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: 'chat_messages',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'match_id',
            value: widget.matchId,
          ),
          callback: (payload) {
            setState(() {
              messages.add(payload.newRecord);
            });
            scrollToBottom();
          },
        )
        .subscribe();
  }

  void scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.jumpTo(
          _scrollController.position.maxScrollExtent,
        );
      }
    });
  }

  Future<void> sendMessage() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    // 🚫 block phone numbers
    if (RegExp(r'\d{10}').hasMatch(text)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Sharing phone not allowed")),
      );
      return;
    }

    final user = supabase.auth.currentUser;

    await supabase.from('chat_messages').insert({
      'match_id': widget.matchId,
      'sender_id': user!.id,
      'sender_name': user.email ?? "User",
      'message': text,
    });

    _controller.clear();
  }

  String formatTime(String time) {
    final dt = DateTime.parse(time).toLocal();
    final hour = dt.hour.toString().padLeft(2, '0');
    final min = dt.minute.toString().padLeft(2, '0');
    return "$hour:$min";
  }

  @override
  Widget build(BuildContext context) {
    final userId = supabase.auth.currentUser!.id;

    return Scaffold(
      appBar: AppBar(title: const Text("Chat")),
      body: Column(
        children: [
          // ⚠️ WARNING
          Container(
            width: double.infinity,
            color: Colors.yellow.shade100,
            padding: const EdgeInsets.all(10),
            child: const Text(
              "⚠️ Do not share phone/email. Payments outside QAPTO are not protected.",
              style: TextStyle(fontSize: 12),
            ),
          ),

          // 💬 CHAT LIST
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final msg = messages[index];
                final isMe = msg['sender_id'] == userId;

                return Align(
                  alignment:
                      isMe ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin:
                        const EdgeInsets.symmetric(vertical: 6, horizontal: 10),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isMe ? Colors.blue : Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: isMe
                          ? CrossAxisAlignment.end
                          : CrossAxisAlignment.start,
                      children: [
                        // 👤 NAME
                        Text(
                          msg['sender_name'] ?? 'User',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color:
                                isMe ? Colors.white70 : Colors.black54,
                          ),
                        ),

                        const SizedBox(height: 4),

                        // 💬 MESSAGE
                        Text(
                          msg['message'],
                          style: TextStyle(
                            color:
                                isMe ? Colors.white : Colors.black,
                            fontSize: 15,
                          ),
                        ),

                        const SizedBox(height: 4),

                        // 🕒 TIME
                        Text(
                          formatTime(msg['created_at']),
                          style: TextStyle(
                            fontSize: 10,
                            color:
                                isMe ? Colors.white70 : Colors.black45,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          // ✏️ INPUT
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: "Type message...",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      contentPadding:
                          const EdgeInsets.symmetric(horizontal: 10),
                    ),
                  ),
                ),
                const SizedBox(width: 5),
                IconButton(
                  icon: const Icon(Icons.send, color: Colors.blue),
                  onPressed: sendMessage,
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}