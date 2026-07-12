import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final chatDemoProvider = StateProvider<List<Map<String, String>>>((ref) => [
  {'sender': 'Conductor', 'text': 'Buenos días, reportando novedades en la ruta.', 'time': '10:30'},
  {'sender': 'Cooperativa', 'text': 'Recibido. ¿Algún desvío?', 'time': '10:31'},
  {'sender': 'Conductor', 'text': 'Sí, hay obras en Jr. de la Unión. Voy por ruta alterna.', 'time': '10:32'},
  {'sender': 'Cooperativa', 'text': 'Entendido. Actualizamos la ruta en el sistema.', 'time': '10:33'},
]);

class ChatPage extends ConsumerStatefulWidget {
  final String roomId;
  const ChatPage({super.key, required this.roomId});
  @override
  ConsumerState<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends ConsumerState<ChatPage> {
  final _msgCtrl = TextEditingController();

  @override
  void dispose() { _msgCtrl.dispose(); super.dispose(); }

  void _send() {
    if (_msgCtrl.text.trim().isEmpty) return;
    const user = 'Tú';
    ref.read(chatDemoProvider.notifier).state = [
      ...ref.read(chatDemoProvider),
      {'sender': user, 'text': _msgCtrl.text.trim(), 'time': '${DateTime.now().hour}:${DateTime.now().minute.toString().padLeft(2, '0')}'},
    ];
    _msgCtrl.clear();
  }

  @override
  Widget build(BuildContext context) {
    final messages = ref.watch(chatDemoProvider);

    return Scaffold(
      appBar: AppBar(title: Text('Soporte - ${widget.roomId}')),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: messages.length,
              reverse: false,
              itemBuilder: (_, i) {
                final m = messages[i];
                final isMe = m['sender'] == 'Tú';
                return Align(
                  alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: isMe ? const Color(0xFF001B44) : Colors.grey[200],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(m['sender']!, style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: isMe ? Colors.white70 : Colors.grey[600])),
                        const SizedBox(height: 4),
                        Text(m['text']!, style: TextStyle(color: isMe ? Colors.white : Colors.black87)),
                        const SizedBox(height: 2),
                        Text(m['time']!, style: TextStyle(fontSize: 10, color: isMe ? Colors.white54 : Colors.grey)),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8),
            child: Row(children: [
              Expanded(child: TextField(controller: _msgCtrl, decoration: const InputDecoration(hintText: 'Escribe un mensaje...', border: OutlineInputBorder()), onSubmitted: (_) => _send())),
              const SizedBox(width: 8),
              IconButton(onPressed: _send, icon: const Icon(Icons.send), color: const Color(0xFF001B44)),
            ]),
          ),
        ],
      ),
    );
  }
}
