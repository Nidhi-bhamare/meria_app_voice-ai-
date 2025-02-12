import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'dart:convert';
import 'package:http/http.dart' as http;

class VoiceAiScreen extends StatefulWidget {
  @override
  _VoiceAiScreenState createState() => _VoiceAiScreenState();
}

class _VoiceAiScreenState extends State<VoiceAiScreen>
    with TickerProviderStateMixin {
  stt.SpeechToText _speech = stt.SpeechToText();
  FlutterTts _flutterTts = FlutterTts();

  bool _isListening = false;
  String _text = '';
  String _language = 'en_US';

  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _initializeSpeech();

    // Animation setup
    _controller = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );

    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(_controller);
  }

  void _initializeSpeech() async {
    bool available = await _speech.initialize();
    if (!available) {
      print('Speech recognition not available.');
    }
  }

  void _toggleListening() async {
    if (_isListening) {
      _speech.stop();
    } else {
      await _speech.listen(
        onResult: (result) {
          setState(() {
            _text = result.recognizedWords;
          });
        },
        localeId: _language,
      );
    }

    setState(() {
      _isListening = !_isListening;
    });
  }

  void _readTextAloud() async {
    await _flutterTts.setLanguage(_language);
    await _flutterTts.speak(_text);
  }

  Future<String> _askQuestion(String question) async {
    const String apiKey = 'YOUR_OPENAI_API_KEY';
    final url = Uri.parse('https://api.openai.com/v1/completions');
    final headers = {
      'Authorization': 'Bearer $apiKey',
      'Content-Type': 'application/json',
    };
    final body = jsonEncode({
      'model': 'text-davinci-003',
      'prompt': question,
      'max_tokens': 150,
      'temperature': 0.7,
    });

    final response = await http.post(url, headers: headers, body: body);
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['choices'][0]['text'].toString().trim();
    } else {
      return 'Error: Unable to fetch response';
    }
  }

  void _handleQuestion() async {
    if (_text.isNotEmpty) {
      String answer = await _askQuestion(_text);
      setState(() {
        _text = answer;
      });
      _readTextAloud();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Voice AI')),
      body: FadeTransition(
        opacity: _animation,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text('Recognized Speech:',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              SizedBox(height: 20),
              Text(_text.isEmpty ? 'Speak now' : _text,
                  style: TextStyle(fontSize: 24)),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _toggleListening,
                child:
                    Text(_isListening ? 'Stop Listening' : 'Start Listening'),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _readTextAloud,
                child: Text('Read Aloud'),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _handleQuestion,
                child: Text('Ask Question'),
              ),
              SizedBox(height: 20),
              DropdownButton<String>(
                value: _language,
                items: <String>[
                  'en_US',
                  'hi_IN',
                  'fr_FR',
                  'de_DE',
                  'ta_IN',
                  'gu_IN',
                  'mr_IN'
                ].map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value.split('_')[0]),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  if (newValue != null) {
                    setState(() {
                      _language = newValue;
                    });
                    _initializeSpeech();
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
