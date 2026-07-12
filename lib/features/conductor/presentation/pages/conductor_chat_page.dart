import 'package:flutter/material.dart';

class ConductorChatPage extends StatefulWidget {
  const ConductorChatPage({super.key});
  @override
  State<ConductorChatPage> createState() => _ConductorChatPageState();
}

class _ConductorChatPageState extends State<ConductorChatPage> {
  final _msgCtrl = TextEditingController();
  bool _typing = false;

  final _messages = [
    {'sender': 'coop', 'text': 'Buenos días Carlos, ¿cómo va la ruta?', 'time': '10:30'},
    {'sender': 'driver', 'text': 'Todo bien, saliendo de Plaza de Armas', 'time': '10:31'},
    {'sender': 'coop', 'text': 'Recibido. Hay un reporte de tráfico en la Av. Central. Toma la ruta alterna si es necesario.', 'time': '10:32'},
    {'sender': 'driver', 'text': 'Entendido, voy por la alterna. Gracias.', 'time': '10:34'},
  ];

  @override
  void dispose() { _msgCtrl.dispose(); super.dispose(); }

  void _send() {
    if (_msgCtrl.text.trim().isEmpty) return;
    setState(() {
      _messages.add({'sender': 'driver', 'text': _msgCtrl.text.trim(), 'time': '${DateTime.now().hour}:${DateTime.now().minute.toString().padLeft(2, '0')}'});
      _typing = false;
    });
    _msgCtrl.clear();
    Future.delayed(const Duration(seconds: 2), () => setState(() => _typing = true));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Row(children: [
          CircleAvatar(radius: 18, backgroundColor: Color(0xFF001B44), child: Icon(Icons.business, size: 18, color: Colors.white)),
          SizedBox(width: 8),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('TransLima Express', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFF001B44), fontFamily: 'Inter')),
            Text('En línea', style: TextStyle(fontSize: 12, color: Colors.green, fontFamily: 'Inter')),
          ]),
        ]),
        backgroundColor: const Color(0xFFF8F9FA), elevation: 0,
      ),
      body: Column(children: [
        Expanded(child: ListView.builder(padding: const EdgeInsets.all(16), itemCount: _messages.length, itemBuilder: (_, i) {
          final m = _messages[i];
          final isDriver = m['sender'] == 'driver';
          return Align(alignment: isDriver ? Alignment.centerRight : Alignment.centerLeft, child: Container(
            margin: const EdgeInsets.only(bottom: 8), padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            constraints: const BoxConstraints(maxWidth: 280),
            decoration: BoxDecoration(color: isDriver ? const Color(0xFF001B44) : Colors.white, borderRadius: BorderRadius.circular(14), boxShadow: isDriver ? null : const [BoxShadow(color: Color(0x14002F6C), blurRadius: 4)]),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(m['text']!, style: TextStyle(fontSize: 15, color: isDriver ? Colors.white : const Color(0xFF001B44), fontFamily: 'Inter')),
              const SizedBox(height: 4),
              Text(m['time']!, style: TextStyle(fontSize: 11, color: isDriver ? Colors.white60 : const Color(0xFF434750), fontFamily: 'Inter')),
            ]),
          ));
        })),
        if (_typing) const Padding(padding: EdgeInsets.only(left: 20, bottom: 4), child: Align(alignment: Alignment.centerLeft, child: Text('TransLima Express está escribiendo...', style: TextStyle(fontSize: 12, color: Color(0xFF434750), fontStyle: FontStyle.italic, fontFamily: 'Inter')))),
        Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: Colors.white, boxShadow: const [BoxShadow(color: Color(0x14002F6C), blurRadius: 8, offset: Offset(0, -2))]), child: Row(children: [
          const SizedBox(width: 4),
          IconButton(onPressed: () {}, icon: const Icon(Icons.attach_file, color: Color(0xFF434750)), padding: EdgeInsets.zero, constraints: const BoxConstraints()),
          const SizedBox(width: 4),
          Expanded(child: TextField(controller: _msgCtrl, onSubmitted: (_) => _send(), decoration: const InputDecoration(hintText: 'Escribe un mensaje...', hintStyle: TextStyle(fontSize: 14, color: Color(0xFF434750), fontFamily: 'Inter'), border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(24)), borderSide: BorderSide.none), filled: true, fillColor: Color(0xFFF8F9FA), contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 10)))),
          const SizedBox(width: 8),
          Container(decoration: BoxDecoration(color: const Color(0xFF001B44), borderRadius: BorderRadius.circular(24)), child: IconButton(onPressed: _send, icon: const Icon(Icons.send, size: 20, color: Colors.white), padding: const EdgeInsets.all(10), constraints: const BoxConstraints())),
        ])),
      ]),
    );
  }
}
