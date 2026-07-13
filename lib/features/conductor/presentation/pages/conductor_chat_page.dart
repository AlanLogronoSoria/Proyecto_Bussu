import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../chat/presentation/providers/chat_provider.dart';

class ConductorChatPage extends ConsumerStatefulWidget {
  const ConductorChatPage({super.key});
  @override
  ConsumerState<ConductorChatPage> createState() => _ConductorChatPageState();
}

class _ConductorChatPageState extends ConsumerState<ConductorChatPage> {
  final _ctrl = TextEditingController();
  @override void dispose() { _ctrl.dispose(); super.dispose(); }

  void _send() {
    final t = _ctrl.text.trim();
    if (t.isEmpty) return;
    ref.read(sendMessageAction('default'))(t);
    _ctrl.clear();
  }

  @override
  Widget build(BuildContext context) {
    final msgs = ref.watch(messagesProvider('default'));
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF8F9FA),
        elevation: 0,
        title: Row(children: [
          const CircleAvatar(radius: 18, backgroundColor: Color(0xFF001B44), child: Icon(Icons.business, size: 18, color: Colors.white)),
          const SizedBox(width: 8),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('TransLima Express', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFF001B44), fontFamily: 'Inter')),
            const Text('En linea', style: TextStyle(fontSize: 12, color: Colors.green, fontFamily: 'Inter')),
          ]),
        ]),
      ),
      body: msgs.when(
        loading: () => const Center(child: CircularProgressIndicator(color: Color(0xFF001B44))),
        error: (_, __) => const Center(child: Text('Error')),
        data: (messages) => Column(children: [
          Expanded(child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: messages.length,
            itemBuilder: (_, i) {
              final m = messages[i];
              final me = m.senderId == 'current_user';
              return _Bubble(me: me, text: m.content, time: '${m.createdAt.hour}:${m.createdAt.minute.toString().padLeft(2, '0')}');
            },
          )),
          _InputBar(ctrl: _ctrl, onSend: _send),
        ]),
      ),
    );
  }
}

class _Bubble extends StatelessWidget {
  final bool me; final String text, time;
  const _Bubble({required this.me, required this.text, required this.time});
  @override
  Widget build(BuildContext context) {
    return Align(alignment: me ? Alignment.centerRight : Alignment.centerLeft, child: Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      constraints: const BoxConstraints(maxWidth: 280),
      decoration: BoxDecoration(color: me ? const Color(0xFF001B44) : Colors.white, borderRadius: BorderRadius.circular(14), boxShadow: me ? null : const [BoxShadow(color: Color(0x14002F6C), blurRadius: 4)]),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(text, style: TextStyle(fontSize: 15, color: me ? Colors.white : const Color(0xFF001B44), fontFamily: 'Inter')),
        const SizedBox(height: 4),
        Text(time, style: TextStyle(fontSize: 11, color: me ? Colors.white60 : const Color(0xFF434750), fontFamily: 'Inter')),
      ]),
    ));
  }
}

class _InputBar extends StatelessWidget {
  final TextEditingController ctrl; final VoidCallback onSend;
  const _InputBar({required this.ctrl, required this.onSend});
  @override
  Widget build(BuildContext context) {
    return Container(padding: const EdgeInsets.all(12), decoration: const BoxDecoration(color: Colors.white, boxShadow: [BoxShadow(color: Color(0x14002F6C), blurRadius: 8, offset: Offset(0, -2))]), child: Row(children: [
      const SizedBox(width: 4),
      Expanded(child: TextField(controller: ctrl, onSubmitted: (_) => onSend(), decoration: const InputDecoration(hintText: 'Escribe un mensaje...', border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(24)), borderSide: BorderSide.none), filled: true, fillColor: Color(0xFFF8F9FA), contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 10)))),
      const SizedBox(width: 8),
      Container(decoration: BoxDecoration(color: const Color(0xFF001B44), borderRadius: BorderRadius.circular(24)), child: IconButton(onPressed: onSend, icon: const Icon(Icons.send, size: 20, color: Colors.white), padding: const EdgeInsets.all(10), constraints: const BoxConstraints())),
    ]));
  }
}
