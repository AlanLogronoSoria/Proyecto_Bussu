import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../chat/presentation/providers/chat_provider.dart';
import '../providers/fleet_provider.dart';

class CoopChatPage extends ConsumerStatefulWidget {
  const CoopChatPage({super.key});
  @override
  ConsumerState<CoopChatPage> createState() => _CoopChatPageState();
}

class _CoopChatPageState extends ConsumerState<CoopChatPage> {
  String? _activeChatId;
  String? _activeDriverName;
  final _msgCtrl = TextEditingController();
  late final ScrollController _scrollCtrl;

  @override
  void initState() { super.initState(); _scrollCtrl = ScrollController(); }
  @override
  void dispose() { _msgCtrl.dispose(); _scrollCtrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    if (_activeChatId != null) return _buildChatView();
    return _buildDriverList();
  }

  Widget _buildDriverList() {
    final coopId = ref.watch(currentCoopIdProvider);
    final driversAsync = ref.watch(driversProvider(coopId));
    final unread = ref.watch(unreadCountProvider);

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Padding(padding: const EdgeInsets.fromLTRB(16, 20, 16, 0), child: Row(children: [
        const Icon(Icons.chat_outlined, color: Color(0xFF001B44), size: 22), const SizedBox(width: 8),
        const Text('Chat con Conductores', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: Color(0xFF001B44), fontFamily: 'Inter')),
        const Spacer(),
        IconButton(onPressed: () {}, icon: Badge(isLabelVisible: unread > 0, label: Text('$unread', style: const TextStyle(fontSize: 10, color: Colors.white)), child: const Icon(Icons.notifications_outlined, color: Color(0xFF001B44)))),
      ])),
      const SizedBox(height: 4),
      const Padding(padding: EdgeInsets.symmetric(horizontal: 16), child: Row(children: [Icon(Icons.circle, size: 8, color: Colors.green), SizedBox(width: 4), Text('En tiempo real · Persistente', style: TextStyle(fontSize: 12, color: Color(0xFF434750), fontFamily: 'Inter'))])),
      const SizedBox(height: 12),
      Expanded(child: driversAsync.when(
        loading: () => const Center(child: CircularProgressIndicator(color: Color(0xFF001B44))),
        error: (_, __) => const Center(child: Text('Error al cargar')),
        data: (drivers) => ListView(padding: const EdgeInsets.symmetric(horizontal: 16), children: [
          ...drivers.map((d) {
            final hasUnread = d.id.hashCode % 3 == 0;
            return Container(
              margin: const EdgeInsets.only(bottom: 6),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), boxShadow: const [BoxShadow(color: Color(0x14002F6C), blurRadius: 4)]),
              child: ListTile(
                leading: Stack(children: [
                  CircleAvatar(radius: 24, backgroundColor: const Color(0xFF001B44), child: Text(d.fullName.isNotEmpty ? d.fullName[0].toUpperCase() : '?', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontFamily: 'Inter'))),
                  Positioned(right: 0, bottom: 0, child: Container(width: 12, height: 12, decoration: BoxDecoration(color: d.isActive ? Colors.green : Colors.grey, shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 2)))),
                ]),
                title: Text(d.fullName, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Color(0xFF001B44), fontFamily: 'Inter')),
                subtitle: Row(children: [
                  Text('Bus: ${d.assignedBusPlate ?? "—"}', style: const TextStyle(fontSize: 12, color: Color(0xFF434750), fontFamily: 'Inter')),
                  const Spacer(),
                  Text('Último: hace 5 min', style: const TextStyle(fontSize: 11, color: Color(0xFFBDBDBD), fontFamily: 'Inter')),
                ]),
                trailing: hasUnread ? Container(width: 22, height: 22, decoration: const BoxDecoration(color: Color(0xFFBA1A1A), shape: BoxShape.circle), child: const Center(child: Text('1', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700)))) : null,
                onTap: () => setState(() { _activeChatId = d.id; _activeDriverName = d.fullName; }),
              ),
            );
          }),
        ]),
      )),
    ]);
  }

  Widget _buildChatView() {
    final messagesAsync = ref.watch(messagesProvider(_activeChatId!));
    final messages = messagesAsync.valueOrNull ?? [];
    final roomId = _activeChatId!;
    ref.listen(messagesProvider(roomId), (_, __) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollCtrl.hasClients) _scrollCtrl.animateTo(_scrollCtrl.position.maxScrollExtent, duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
      });
    });

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: Color(0xFF001B44)), onPressed: () => setState(() { _activeChatId = null; _activeDriverName = null; })),
        title: Row(children: [
          Stack(children: [
            CircleAvatar(radius: 16, backgroundColor: const Color(0xFF001B44), child: Text(_activeDriverName?.isNotEmpty == true ? _activeDriverName![0].toUpperCase() : '?', style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600, fontFamily: 'Inter'))),
            const Positioned(right: 0, bottom: 0, child: CircleAvatar(radius: 5, backgroundColor: Colors.white, child: CircleAvatar(radius: 4, backgroundColor: Colors.green))),
          ]),
          const SizedBox(width: 8),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(_activeDriverName ?? '', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Color(0xFF001B44), fontFamily: 'Inter')),
            const Text('En línea · ahora', style: TextStyle(fontSize: 11, color: Colors.green, fontFamily: 'Inter')),
          ]),
        ]),
        backgroundColor: const Color(0xFFF8F9FA), elevation: 0,
      ),
      body: Column(children: [
        Expanded(child: ListView.builder(controller: _scrollCtrl, padding: const EdgeInsets.all(16), itemCount: messages.length, itemBuilder: (_, i) {
          final m = messages[i];
          final isMe = m.senderId == 'coop' || m.senderId == 'current_user';
          return Align(alignment: isMe ? Alignment.centerRight : Alignment.centerLeft, child: Container(constraints: const BoxConstraints(maxWidth: 300), margin: const EdgeInsets.only(bottom: 6), padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: isMe ? const Color(0xFF001B44) : Colors.white, borderRadius: BorderRadius.circular(14)), child: Column(crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start, children: [
            Text(m.content, style: TextStyle(fontSize: 14, color: isMe ? Colors.white : const Color(0xFF001B44), fontFamily: 'Inter')),
            const SizedBox(height: 4),
            Row(mainAxisSize: MainAxisSize.min, children: [
              Text(_fmt(m.createdAt), style: TextStyle(fontSize: 10, color: isMe ? Colors.white70 : const Color(0xFF434750))),
              if (isMe) ...[const SizedBox(width: 4), Icon(m.isRead ? Icons.done_all : Icons.done, size: 14, color: m.isRead ? Colors.lightBlue : Colors.white60)],
            ]),
          ])));
        })),
        Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: Colors.white, boxShadow: [BoxShadow(color: Colors.black.withAlpha(10), blurRadius: 4, offset: const Offset(0, -1))]), child: Row(children: [
          Expanded(child: TextField(controller: _msgCtrl, decoration: const InputDecoration(hintText: 'Escribe un mensaje...', hintStyle: TextStyle(fontFamily: 'Inter', color: Color(0xFFBDBDBD)), filled: true, fillColor: Color(0xFFF8F9FA), border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(24)), borderSide: BorderSide.none), contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 10)))),
          const SizedBox(width: 6),
          CircleAvatar(backgroundColor: const Color(0xFF001B44), child: IconButton(icon: const Icon(Icons.send, size: 18, color: Colors.white), onPressed: () { if (_msgCtrl.text.trim().isNotEmpty) { ref.read(sendMessageAction(roomId))(_msgCtrl.text.trim()); _msgCtrl.clear(); } })),
        ])),
      ]),
    );
  }

  String _fmt(DateTime dt) => '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
}
