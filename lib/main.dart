import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: MusicPlayerScreen(),
    );
  }
}

class MusicPlayerScreen extends StatefulWidget {
  @override
  _MusicPlayerScreenState createState() => _MusicPlayerScreenState();
}

class _MusicPlayerScreenState extends State<MusicPlayerScreen>
    with WidgetsBindingObserver {
  final TextEditingController _urlController = TextEditingController();
  final AudioPlayer _audioPlayer = AudioPlayer()
    ..setReleaseMode(ReleaseMode.stop);
  String? _filePath;
  bool isPlaying = false;
  bool isPlayingFromUrl = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _audioPlayer.dispose();
    super.dispose();
  }

  void _pickAudioFile() async {
    FilePickerResult? result =
        await FilePicker.platform.pickFiles(type: FileType.audio);
    if (result != null) {
      await _audioPlayer.stop(); 
      setState(() {
        _filePath = result.files.single.path;
        _urlController.clear();
        isPlayingFromUrl = false;
        isPlaying = false;
      });
    }
  }

  void _playFromUrl() async {
    if (_urlController.text.isEmpty) return;
    await _audioPlayer.stop(); 
    await _audioPlayer.play(UrlSource(_urlController.text));
    setState(() {
      isPlaying = true;
      isPlayingFromUrl = true;
      _filePath = null;
    });
  }

  void _togglePlayPause() async {
    if (_filePath != null) {
      if (isPlaying) {
        await _audioPlayer.pause();
      } else {
        await _audioPlayer.play(DeviceFileSource(_filePath!));
      }
    } else if (isPlayingFromUrl) {
      if (isPlaying) {
        await _audioPlayer.pause();
      } else {
        await _audioPlayer.play(UrlSource(_urlController.text));
      }
    }
    setState(() {
      isPlaying = !isPlaying;
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      _audioPlayer.pause();
      setState(() => isPlaying = false);
    } else if (state == AppLifecycleState.resumed &&
        (isPlayingFromUrl || _filePath != null)) {
      _audioPlayer.resume();
      setState(() => isPlaying = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Music Player")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _urlController,
              decoration: InputDecoration(labelText: "Enter Music URL"),
              onChanged: (text) {
                setState(() {
                  _filePath = null;
                  isPlayingFromUrl = false;
                });
              },
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: _playFromUrl,
              child: Text("Play from URL"),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _pickAudioFile,
              child: Text("Choose Audio File"),
            ),
            SizedBox(height: 10),
            Text(_filePath ?? "No file selected"),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _togglePlayPause,
              child: Text(isPlaying ? "Pause" : "Play"),
            ),
          ],
        ),
      ),
    );
  }
}
