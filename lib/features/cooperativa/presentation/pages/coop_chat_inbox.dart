import 'package:flutter/material.dart';

class CoopChatInbox extends StatefulWidget {
  const CoopChatInbox({super.key});
  @override
  State<CoopChatInbox> createState() => _CoopChatInboxState();
}

class _CoopChatInboxState extends State<CoopChatInbox> {
  int? _selectedIndex;

  static const _conversations = <Map<String, String>>[
    {'driver': 'Carlos Mendoza', 'bus': 'ABC-123', 'lastMsg': 'Entendido, voy por la alterna', 'time': '10:34', 'unread': '2'},
    {'driver': 'Luisa Rodriguez', 'bus': 'ABC-124', 'lastMsg': 'Reportando llegada a Miraflores', 'time': '10:20', 'unread': '0'},
    {'driver': 'Ana Villanueva', 'bus': 'DEF-456', 'lastMsg': 'Hay alguna novedad en la ruta?', 'time': '09:55', 'unread': '0'},
  ];

  @override
  Widget build(BuildContext context) {
    final wide = MediaQuery.of(context).size.width >= 700;

    if (wide) {
      return _DesktopView(
        conversations: _conversations,
        selectedIndex: _selectedIndex,
        onSelect: (i) => setState(() => _selectedIndex = i),
        onBack: () => setState(() => _selectedIndex = null),
      );
    }
    if (_selectedIndex != null) {
      return _ChatThread(
        driver: _conversations[_selectedIndex!]['driver']!,
        bus: _conversations[_selectedIndex!]['bus']!,
        onBack: () => setState(() => _selectedIndex = null),
      );
    }
    return _ConversationList(
      conversations: _conversations,
      selectedIndex: _selectedIndex,
      onSelect: (i) => setState(() => _selectedIndex = i),
    );
  }
}

class _DesktopView extends StatelessWidget {
  final List<Map<String, String>> conversations;
  final int? selectedIndex;
  final ValueChanged<int> onSelect;
  final VoidCallback onBack;

  const _DesktopView({required this.conversations, required this.selectedIndex, required this.onSelect, required this.onBack});

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      SizedBox(
        width: 340,
        child: _ConversationList(
          conversations: conversations,
          selectedIndex: selectedIndex,
          onSelect: onSelect,
        ),
      ),
      const VerticalDivider(width: 1),
      Expanded(
        child: selectedIndex != null
            ? _ChatThread(
                driver: conversations[selectedIndex!]['driver']!,
                bus: conversations[selectedIndex!]['bus']!,
                onBack: onBack,
              )
            : const Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                Icon(Icons.chat_outlined, size: 64, color: Color(0xFF434750)),
                SizedBox(height: 12),
                Text('Selecciona una conversacion', style: TextStyle(fontSize: 16, color: Color(0xFF434750), fontFamily: 'Inter')),
              ])),
      ),
    ]);
  }
}

class _ConversationList extends StatelessWidget {
  final List<Map<String, String>> conversations;
  final int? selectedIndex;
  final ValueChanged<int> onSelect;

  const _ConversationList({required this.conversations, required this.selectedIndex, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFF8F9FA),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Padding(padding: EdgeInsets.fromLTRB(20, 20, 20, 0), child: Text('Chat Inbox', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: Color(0xFF001B44), fontFamily: 'Inter'))),
        const SizedBox(height: 16),
        Expanded(child: ListView(padding: const EdgeInsets.symmetric(horizontal: 8), children: conversations.asMap().entries.map((e) {
          final c = e.value;
          final i = e.key;
          final unread = int.tryParse(c['unread']!) ?? 0;
          return Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Material(
              color: selectedIndex == i ? const Color(0xFFFED000).withAlpha(30) : Colors.transparent,
              borderRadius: BorderRadius.circular(10),
              child: InkWell(
                onTap: () => onSelect(i),
                borderRadius: BorderRadius.circular(10),
                child: Padding(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12), child: Row(children: [
                  CircleAvatar(radius: 24, backgroundColor: const Color(0xFF001B44), child: Text(c['driver']![0], style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontFamily: 'Inter'))),
                  const SizedBox(width: 12),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(c['driver']!, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Color(0xFF001B44), fontFamily: 'Inter')),
                    const SizedBox(height: 2),
                    Text(c['lastMsg']!, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 13, color: Color(0xFF434750), fontFamily: 'Inter')),
                  ])),
                  Column(children: [
                    Text(c['time']!, style: const TextStyle(fontSize: 11, color: Color(0xFF434750), fontFamily: 'Inter')),
                    if (unread > 0) const SizedBox(height: 4),
                    if (unread > 0) Container(width: 20, height: 20, decoration: const BoxDecoration(color: Color(0xFFBA1A1A), shape: BoxShape.circle), child: Center(child: Text('$unread', style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700, fontFamily: 'Inter')))),
                  ]),
                ])),
              ),
            ),
          );
        }).toList())),
      ]),
    );
  }
}

class _ChatThread extends StatefulWidget {
  final String driver, bus;
  final VoidCallback onBack;
  const _ChatThread({required this.driver, required this.bus, required this.onBack});
  @override
  State<_ChatThread> createState() => _ChatThreadState();
}

class _ChatThreadState extends State<_ChatThread> {
  final _msgCtrl = TextEditingController();
  final _msgs = [
    {'sender': 'driver', 'text': 'Buenos dias, reportando inicio de ruta', 'time': '10:30'},
    {'sender': 'coop', 'text': 'Recibido Carlos. Todo en orden?', 'time': '10:31'},
    {'sender': 'driver', 'text': 'Si, todo normal. Hay reporte de trafico en Av. Central?', 'time': '10:32'},
    {'sender': 'coop', 'text': 'Si, toma la ruta alterna. Te actualizamos si se libera.', 'time': '10:33'},
    {'sender': 'driver', 'text': 'Entendido, voy por la alterna. Gracias.', 'time': '10:34'},
  ];

  @override void dispose() { _msgCtrl.dispose(); super.dispose(); }

  void _send() {
    if (_msgCtrl.text.trim().isEmpty) return;
    setState(() => _msgs.add({'sender': 'coop', 'text': _msgCtrl.text.trim(), 'time': '${DateTime.now().hour}:${DateTime.now().minute.toString().padLeft(2, '0')}'}));
    _msgCtrl.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: Color(0xFF001B44)), onPressed: widget.onBack),
        title: Row(children: [
          const CircleAvatar(radius: 16, backgroundColor: Color(0xFF001B44), child: Icon(Icons.person, size: 16, color: Colors.white)),
          const SizedBox(width: 8),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(widget.driver, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Color(0xFF001B44), fontFamily: 'Inter')),
            Text('Bus ${widget.bus} · En linea', style: const TextStyle(fontSize: 12, color: Colors.green, fontFamily: 'Inter')),
          ]),
        ]),
        backgroundColor: const Color(0xFFF8F9FA), elevation: 0,
      ),
      body: Column(children: [
        Expanded(child: ListView.builder(padding: const EdgeInsets.all(16), itemCount: _msgs.length, itemBuilder: (_, i) {
          final m = _msgs[i]; final isCoop = m['sender'] == 'coop';
          return Align(alignment: isCoop ? Alignment.centerRight : Alignment.centerLeft, child: Container(
            margin: const EdgeInsets.only(bottom: 8), padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            constraints: const BoxConstraints(maxWidth: 300),
            decoration: BoxDecoration(color: isCoop ? const Color(0xFF001B44) : const Color(0xFFF8F9FA), borderRadius: BorderRadius.circular(14), boxShadow: isCoop ? null : const [BoxShadow(color: Color(0x14002F6C), blurRadius: 4)]),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(m['text']!, style: TextStyle(fontSize: 15, color: isCoop ? Colors.white : const Color(0xFF001B44), fontFamily: 'Inter')),
              const SizedBox(height: 4),
              Text(m['time']!, style: TextStyle(fontSize: 11, color: isCoop ? Colors.white60 : const Color(0xFF434750), fontFamily: 'Inter')),
            ]),
          ));
        })),
        Container(padding: const EdgeInsets.all(12), decoration: const BoxDecoration(color: Colors.white, boxShadow: [BoxShadow(color: Color(0x14002F6C), blurRadius: 8, offset: Offset(0, -2))]), child: SafeArea(child: Row(children: [
          const SizedBox(width: 4),
          IconButton(onPressed: () {}, icon: const Icon(Icons.attach_file, color: Color(0xFF434750)), padding: EdgeInsets.zero, constraints: const BoxConstraints()),
          const SizedBox(width: 4),
          Expanded(child: TextField(controller: _msgCtrl, onSubmitted: (_) => _send(), decoration: const InputDecoration(hintText: 'Escribe un mensaje...', hintStyle: TextStyle(fontSize: 14, color: Color(0xFF434750), fontFamily: 'Inter'), border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(24)), borderSide: BorderSide.none), filled: true, fillColor: Color(0xFFF8F9FA), contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 10)))),
          const SizedBox(width: 8),
          Container(decoration: BoxDecoration(color: const Color(0xFF001B44), borderRadius: BorderRadius.circular(24)), child: IconButton(onPressed: _send, icon: const Icon(Icons.send, size: 18, color: Colors.white), constraints: const BoxConstraints(minWidth: 44, minHeight: 44))),
        ]))),
      ]),
    );
  }
}
