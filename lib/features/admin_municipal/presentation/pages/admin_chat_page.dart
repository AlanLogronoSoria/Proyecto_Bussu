import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../chat/presentation/providers/chat_provider.dart';

class AdminChatPage extends ConsumerStatefulWidget {
  const AdminChatPage({super.key});
  @override
  ConsumerState<AdminChatPage> createState() => _AdminChatPageState();
}

class _AdminChatPageState extends ConsumerState<AdminChatPage> {
  final _msgCtrl = TextEditingController();
  late final ScrollController _scrollCtrl;

  @override
  void initState() { super.initState(); _scrollCtrl = ScrollController(); }
  @override
  void dispose() { _msgCtrl.dispose(); _scrollCtrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final messagesAsync = ref.watch(messagesProvider('admin-chat'));
    final messages = messagesAsync.valueOrNull ?? [];
    final unread = ref.watch(unreadCountProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: Row(children: [
          Stack(children: [
            const CircleAvatar(radius: 16, backgroundColor: Color(0xFF001B44), child: Icon(Icons.business, size: 16, color: Colors.white)),
            const Positioned(right: 0, bottom: 0, child: CircleAvatar(radius: 5, backgroundColor: Colors.white, child: CircleAvatar(radius: 4, backgroundColor: Colors.green))),
          ]),
          const SizedBox(width: 10),
          const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Chat Municipal', style: TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.w600, color: Color(0xFF001B44))),
            Text('Cooperativas conectadas', style: TextStyle(fontSize: 10, color: Colors.green, fontFamily: 'Inter')),
          ]),
        ]),
        backgroundColor: const Color(0xFFF8F9FA), elevation: 0,
        actions: [IconButton(onPressed: () {}, icon: Badge(isLabelVisible: unread > 0, label: Text('$unread', style: const TextStyle(fontSize: 10, color: Colors.white)), child: const Icon(Icons.notifications_outlined, color: Color(0xFF001B44))))],
      ),
      body: Column(children: [
        Expanded(child: ListView.builder(controller: _scrollCtrl, padding: const EdgeInsets.all(16), itemCount: messages.length, itemBuilder: (_, i) {
          final m = messages[i];
          final isMe = m.senderId == 'current_user' || m.senderId == 'municipal';
          return Align(alignment: isMe ? Alignment.centerRight : Alignment.centerLeft, child: Container(
            constraints: const BoxConstraints(maxWidth: 300), margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: isMe ? const Color(0xFF001B44) : Colors.white, borderRadius: BorderRadius.circular(14)),
            child: Column(crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start, children: [
              Text(m.content, style: TextStyle(fontSize: 14, color: isMe ? Colors.white : const Color(0xFF001B44), fontFamily: 'Inter')),
              const SizedBox(height: 4),
              Row(mainAxisSize: MainAxisSize.min, children: [
                Text(_fmt(m.createdAt), style: TextStyle(fontSize: 10, color: isMe ? Colors.white70 : const Color(0xFF434750))),
                if (isMe) ...[const SizedBox(width: 4), Icon(m.isRead ? Icons.done_all : Icons.done, size: 14, color: m.isRead ? Colors.lightBlue : Colors.white60)],
              ]),
            ]),
          ));
        })),
        Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: Colors.white, boxShadow: [BoxShadow(color: Colors.black.withAlpha(10), blurRadius: 4, offset: const Offset(0, -1))]), child: Row(children: [
          Expanded(child: TextField(controller: _msgCtrl, decoration: const InputDecoration(hintText: 'Escribe un mensaje...', hintStyle: TextStyle(fontFamily: 'Inter'), filled: true, fillColor: Color(0xFFF8F9FA), border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(24)), borderSide: BorderSide.none), contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 10)))),
          const SizedBox(width: 6),
          CircleAvatar(backgroundColor: const Color(0xFF001B44), child: IconButton(icon: const Icon(Icons.send, size: 18, color: Colors.white), onPressed: () { if (_msgCtrl.text.trim().isNotEmpty) { ref.read(sendMessageAction('admin-chat'))(_msgCtrl.text.trim()); _msgCtrl.clear(); } })),
        ])),
      ]),
    );
  }

  String _fmt(DateTime dt) => '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
}
