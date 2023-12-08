import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<String> logs = ["Logs"];

  // BytesBuilder bytesBuilder = BytesBuilder();
  final recorder = AudioRecorder();
  String? path;

  void _log(String text) {
    setState(() {
      logs.add(text);
    });
  }

  @override
  void initState() {
    super.initState();
    recorder.onStateChanged().listen((event) {
      _log(event.toString());
    });
  }

  Widget _buildLogs() {
    return SingleChildScrollView(
      child: Column(
        children: logs
            .map((e) => Padding(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 4),
                  child: Text(e),
                ))
            .toList(),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextButton(
          onPressed: () async {
            try {
              if (!await recorder.hasPermission()) {
                throw Exception("Please grant mic permission");
              }
              path =
                  "${(await getTemporaryDirectory()).path}/${DateTime.now().millisecondsSinceEpoch}.m4a";
              await recorder.start(const RecordConfig(), path: path!);
              // (await recorder.startStream(RecordConfig())).listen((event) {
              //   bytesBuilder.add(event);
              // });
              _log("* Record Clicked");
            } catch (err) {
              _log("Error $err");
            }
          },
          child: const Text("Record"),
        ),
        TextButton(
          onPressed: () async {
            try {
              await recorder.stop();
              _log("* Stop Recording Clicked");
            } catch (err) {
              _log("Error $err");
            }
          },
          child: const Text("Stop Recording"),
        ),
        TextButton(
          onPressed: () async {
            final player = AudioPlayer();
            try {
              // await player.setSourceBytes(bytesBuilder.toBytes());
              await player.setSourceDeviceFile(path!);
              await player.resume();
              _log("Playing");
            } catch (err) {
              _log("Error $err");
            }
          },
          child: const Text("Play"),
        ),
        TextButton(
          onPressed: () async {
            final player = AudioPlayer();
            try {
              // await player.setSourceBytes(bytesBuilder.toBytes());
              await player.setSourceDeviceFile(path!);
              final duration = await player.getDuration();
              _log("Duration is $duration");
            } catch (err) {
              _log("Error $err");
            } finally {
              player.dispose();
            }
          },
          child: const Text("Get Duration"),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text("Recorded file duratio is zero"),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Expanded(child: _buildLogs()),
          Expanded(child: _buildActionButtons()),
        ],
      ),
    );
  }
}
