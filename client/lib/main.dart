import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Chat client',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.deepPurple,
            background: Colors.black12,
            brightness: Brightness.dark),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Websocket Chat'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final _wsUrl = Uri.parse('ws://127.0.0.1:8080');
  late final _wsChannel = WebSocketChannel.connect(_wsUrl);

  late TextEditingController _inputController;
  String _input = '';

  final _messeges = Queue<String>();

  void _handleSend() {
    _wsChannel.sink.add(_input);
  }

  @override
  void initState() {
    _inputController = TextEditingController();
    _inputController.addListener(() {
      setState(() {
        _input = _inputController.text;
      });
    });

    _wsChannel.stream.listen((final message) {
      setState(() {
        _messeges.addFirst(message);
      });
    });

    super.initState();
  }

  @override
  void dispose() {
    _inputController.dispose();
    _wsChannel.sink.close();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.background,
        title: Text(widget.title),
      ),
      body: Column(
        children: [
          Expanded(
            child: Align(
              alignment: Alignment.topCenter,
              child: ListView.separated(
                  shrinkWrap: true,
                  reverse: true,
                  itemBuilder: (context, index) =>
                      Text(_messeges.toList()[index]),
                  separatorBuilder: (_, __) => const SizedBox(
                        height: 12,
                      ),
                  itemCount: _messeges.length),
            ),
          ),
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 8.0, vertical: 16.0),
            child: Form(
              child: TextFormField(
                controller: _inputController,
                decoration: InputDecoration(
                    suffixIcon: _input.isEmpty
                        ? null
                        : InkWell(
                            child: const Icon(Icons.send),
                            // ignore: avoid_print
                            onTap: _handleSend,
                          )),
              ),
            ),
          )
        ],
      ),
    );
  }
}
