import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../features/chat/presentation/providers/chat_provider.dart';

class ChatPage extends ConsumerStatefulWidget {
  final String roomId;
  const ChatPage({super.key, required this.roomId});
  @override
  ConsumerState<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends ConsumerState<ChatPage> {
  final _ctrl = TextEditingController();
  @override void dispose() { _ctrl.dispose(); super.dispose(); }

  void _send() {
    final t = _ctrl.text.trim();
    if (t.isEmpty) return;
    ref.read(sendMessageAction(widget.roomId))(t);
    _ctrl.clear();
  }

  @override
  Widget build(BuildContext context) {
    final msgs = ref.watch(messagesProvider(widget.roomId));
    return Scaffold(
      appBar: AppBar(title: Text('Chat - ${widget.roomId}'), backgroundColor: const Color(0xFFF8F9FA), elevation: 0),
      body: msgs.when(loading: () => const Center(child: CircularProgressIndicator(color: Color(0xFF001B44))), error: (_, __) => const Center(child: Text('Error')), data: (messages) => Column(children: [
        Expanded(child: ListView.builder(padding: const EdgeInsets.all(16), itemCount: messages.length, itemBuilder: (_, i) {
          final m = messages[i]; final me = m.senderId == 'current_user';
          return Align(alignment: me ? Alignment.centerRight : Alignment.centerLeft, child: Container(margin: const EdgeInsets.only(bottom: 8), padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10), constraints: const BoxConstraints(maxWidth: 280), decoration: BoxDecoration(color: me ? const Color(0xFF001B44) : Colors.grey[200], borderRadius: BorderRadius.circular(14)), child: Text(m.content, style: TextStyle(fontSize: 15, color: me ? Colors.white : Colors.black87, fontFamily: 'Inter'))));
        })),
        Padding(padding: const EdgeInsets.all(12), child: Row(children: [Expanded(child: TextField(controller: _ctrl, onSubmitted: (_) => _send(), decoration: const InputDecoration(hintText: 'Escribe...', border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(24)), borderSide: BorderSide.none), filled: true, fillColor: Color(0xFFF8F9FA), contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 10)))), const SizedBox(width: 8), Container(decoration: BoxDecoration(color: const Color(0xFF001B44), borderRadius: BorderRadius.circular(24)), child: IconButton(onPressed: _send, icon: const Icon(Icons.send, size: 18, color: Colors.white), constraints: const BoxConstraints(minWidth: 44, minHeight: 44)))])),
      ])),
    );
  }
}
