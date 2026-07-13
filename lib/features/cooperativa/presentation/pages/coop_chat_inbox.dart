import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../chat/presentation/providers/chat_provider.dart';
import '../../../chat/domain/entities/chat_conversation.dart';

class CoopChatInbox extends ConsumerStatefulWidget {
  const CoopChatInbox({super.key});
  @override
  ConsumerState<CoopChatInbox> createState() => _CoopChatInboxState();
}

class _CoopChatInboxState extends ConsumerState<CoopChatInbox> {
  int? _sel;

  @override
  Widget build(BuildContext context) {
    final async = ref.watch(conversationsProvider);
    final wide = MediaQuery.of(context).size.width >= 700;
    return async.when(loading: () => const Center(child: CircularProgressIndicator(color: Color(0xFF001B44))), error: (_, __) => const Center(child: Text('Error')), data: (convs) {
      if (wide) return _Desktop(convs: convs, sel: _sel, onSel: (i) => setState(() => _sel = i), onBack: () => setState(() => _sel = null));
      if (_sel != null && _sel! < convs.length) return _ChatView(cid: convs[_sel!].id, name: convs[_sel!].driverName, onBack: () => setState(() => _sel = null));
      return _ConvList(convs: convs, sel: _sel, onTap: (i) => setState(() => _sel = i));
    });
  }
}

class _Desktop extends StatelessWidget {
  final List<ChatConversation> convs; final int? sel; final ValueChanged<int> onSel; final VoidCallback onBack;
  const _Desktop({required this.convs, required this.sel, required this.onSel, required this.onBack});
  @override
  Widget build(BuildContext ctx) => Row(children: [
    SizedBox(width: 340, child: _ConvList(convs: convs, sel: sel, onTap: onSel)),
    const VerticalDivider(width: 1),
    Expanded(child: sel != null && sel! < convs.length ? _ChatView(cid: convs[sel!].id, name: convs[sel!].driverName, onBack: onBack) : const Center(child: Text('Selecciona una conversacion'))),
  ]);
}

class _ConvList extends StatelessWidget {
  final List<ChatConversation> convs; final int? sel; final ValueChanged<int> onTap;
  const _ConvList({required this.convs, required this.sel, required this.onTap});
  @override
  Widget build(BuildContext ctx) => Container(color: const Color(0xFFF8F9FA), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    const Padding(padding: EdgeInsets.fromLTRB(20, 20, 20, 0), child: Text('Chat Inbox', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: Color(0xFF001B44), fontFamily: 'Inter'))),
    const SizedBox(height: 16),
    Expanded(child: ListView(padding: const EdgeInsets.symmetric(horizontal: 8), children: List.generate(convs.length, (i) {
      final c = convs[i];
      return Padding(padding: const EdgeInsets.only(bottom: 4), child: Material(color: sel == i ? const Color(0xFFFED000).withAlpha(30) : Colors.transparent, borderRadius: BorderRadius.circular(10), child: InkWell(onTap: () => onTap(i), borderRadius: BorderRadius.circular(10), child: Padding(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12), child: Row(children: [
        CircleAvatar(radius: 24, backgroundColor: const Color(0xFF001B44), child: Text(c.driverName[0], style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600))),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(c.driverName, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Color(0xFF001B44), fontFamily: 'Inter')), const SizedBox(height: 2), Text(c.lastMessage, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 13, color: Color(0xFF434750), fontFamily: 'Inter'))])),
        Column(children: [Text('${c.lastMessageAt.hour}:${c.lastMessageAt.minute.toString().padLeft(2, '0')}', style: const TextStyle(fontSize: 11, color: Color(0xFF434750))), if (c.unreadCount > 0) const SizedBox(height: 4), if (c.unreadCount > 0) Container(width: 20, height: 20, decoration: const BoxDecoration(color: Color(0xFFBA1A1A), shape: BoxShape.circle), child: Center(child: Text('${c.unreadCount}', style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700))))]),
      ])))));
    }))),
  ]));
}

class _ChatView extends ConsumerStatefulWidget {
  final String cid, name; final VoidCallback onBack;
  const _ChatView({required this.cid, required this.name, required this.onBack});
  @override
  ConsumerState<_ChatView> createState() => _ChatViewState();
}

class _ChatViewState extends ConsumerState<_ChatView> {
  final _ctrl = TextEditingController();
  @override void dispose() { _ctrl.dispose(); super.dispose(); }
  void _send() { final t = _ctrl.text.trim(); if (t.isEmpty) return; ref.read(sendMessageAction(widget.cid))(t); _ctrl.clear(); }

  @override
  Widget build(BuildContext ctx) {
    final msgs = ref.watch(messagesProvider(widget.cid));
    return Scaffold(
      appBar: AppBar(leading: IconButton(icon: const Icon(Icons.arrow_back, color: Color(0xFF001B44)), onPressed: widget.onBack), title: Row(children: [const CircleAvatar(radius: 16, backgroundColor: Color(0xFF001B44), child: Icon(Icons.person, size: 16, color: Colors.white)), const SizedBox(width: 8), Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(widget.name, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Color(0xFF001B44), fontFamily: 'Inter')), const Text('En linea', style: TextStyle(fontSize: 12, color: Colors.green, fontFamily: 'Inter'))])]), backgroundColor: const Color(0xFFF8F9FA), elevation: 0),
      body: msgs.when(loading: () => const Center(child: CircularProgressIndicator(color: Color(0xFF001B44))), error: (_, __) => const Center(child: Text('Error')), data: (messages) => Column(children: [
        Expanded(child: ListView.builder(padding: const EdgeInsets.all(16), itemCount: messages.length, itemBuilder: (_, i) {
          final m = messages[i]; final me = m.senderId == 'current_user' || m.senderId == 'coop';
          return Align(alignment: me ? Alignment.centerRight : Alignment.centerLeft, child: Container(margin: const EdgeInsets.only(bottom: 8), padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10), constraints: const BoxConstraints(maxWidth: 300), decoration: BoxDecoration(color: me ? const Color(0xFF001B44) : const Color(0xFFF8F9FA), borderRadius: BorderRadius.circular(14)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(m.content, style: TextStyle(fontSize: 15, color: me ? Colors.white : const Color(0xFF001B44), fontFamily: 'Inter')), const SizedBox(height: 4), Text('${m.createdAt.hour}:${m.createdAt.minute.toString().padLeft(2, '0')}', style: TextStyle(fontSize: 11, color: me ? Colors.white60 : const Color(0xFF434750)))])));
        })),
        Padding(padding: const EdgeInsets.all(12), child: Row(children: [Expanded(child: TextField(controller: _ctrl, onSubmitted: (_) => _send(), decoration: const InputDecoration(hintText: 'Escribe...', border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(24)), borderSide: BorderSide.none), filled: true, fillColor: Color(0xFFF8F9FA), contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 10)))), const SizedBox(width: 8), Container(decoration: BoxDecoration(color: const Color(0xFF001B44), borderRadius: BorderRadius.circular(24)), child: IconButton(onPressed: _send, icon: const Icon(Icons.send, size: 18, color: Colors.white), constraints: const BoxConstraints(minWidth: 44, minHeight: 44)))])),
      ])),
    );
  }
}
