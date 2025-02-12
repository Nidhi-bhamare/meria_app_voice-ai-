// import 'dart:async';

// import 'package:flutter/material.dart';
// import 'package:flutter_tts/flutter_tts.dart';
// import 'package:speech_to_text/speech_to_text.dart' as stt;
// import 'package:translator/translator.dart';

// void main() {
//   runApp(SpeechToTextApp());
// }

// class SpeechToTextApp extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       debugShowCheckedModeBanner: false,
//       title: 'Voice Ai',
//       theme: ThemeData(primarySwatch: Colors.deepPurple),
//       home: SplashScreen(),
//     );
//   }
// }

// class SplashScreen extends StatefulWidget {
//   @override
//   _SplashScreenState createState() => _SplashScreenState();
// }

// class _SplashScreenState extends State<SplashScreen>
//     with SingleTickerProviderStateMixin {
//   late AnimationController _controller;
//   late Animation<double> _scaleAnimation;

//   @override
//   void initState() {
//     super.initState();

//     _controller = AnimationController(
//       vsync: this,
//       duration: Duration(seconds: 5),
//     );

//     _scaleAnimation = Tween<double>(begin: 0.8, end: 1.2).animate(
//       CurvedAnimation(
//         parent: _controller,
//         curve: Curves.easeInOut,
//       ),
//     );

//     _controller.forward();

//     Future.delayed(Duration(seconds: 5), () {
//       Navigator.of(context).pushReplacement(
//         PageRouteBuilder(
//           pageBuilder: (context, animation, secondaryAnimation) =>
//               SpeechToTextScreen(),
//           transitionsBuilder: (context, animation, secondaryAnimation, child) {
//             const begin = Offset(0.0, 1.0);
//             const end = Offset.zero;
//             const curve = Curves.easeInOut;

//             var tween =
//                 Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
//             var offsetAnimation = animation.drive(tween);

//             return SlideTransition(
//               position: offsetAnimation,
//               child: child,
//             );
//           },
//         ),
//       );
//     });
//   }

//   @override
//   void dispose() {
//     _controller.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       body: Center(
//         child: ScaleTransition(
//           scale: _scaleAnimation,
//           child: Image.asset(
//             'assets/logo.png',
//             width: 180,
//             height: 180,
//           ),
//         ),
//       ),
//     );
//   }
// }

// class SpeechToTextScreen extends StatefulWidget {
//   @override
//   _SpeechToTextScreenState createState() => _SpeechToTextScreenState();
// }

// class _SpeechToTextScreenState extends State<SpeechToTextScreen> {
//   late stt.SpeechToText _speech;
//   bool _isListening = false;
//   String _spokenText = "";
//   String _translatedText = "";
//   String _targetLanguage = "en";
//   final FlutterTts _flutterTts = FlutterTts();
//   final translator = GoogleTranslator();

//   @override
//   void initState() {
//     super.initState();
//     _speech = stt.SpeechToText();
//   }

//   Future<void> _startListening() async {
//     bool available = await _speech.initialize();
//     if (available) {
//       setState(() => _isListening = true);
//       _speech.listen(onResult: (val) {
//         setState(() {
//           _spokenText = val.recognizedWords;
//         });
//       });
//     } else {
//       setState(() => _isListening = false);
//     }
//   }

//   void _stopListening() {
//     _speech.stop();
//     setState(() => _isListening = false);
//   }

//   Future<void> _translateText() async {
//     if (_spokenText.isEmpty) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text("Please speak something first!")),
//       );
//       return;
//     }
//     final translation =
//         await translator.translate(_spokenText, to: _targetLanguage);
//     setState(() {
//       _translatedText = translation.text;
//     });
//   }

//   Future<void> _speakText() async {
//     if (_translatedText.isNotEmpty) {
//       await _flutterTts.speak(_translatedText);
//     } else {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text("No text to speak!")),
//       );
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Container(
//         decoration: BoxDecoration(
//           gradient: LinearGradient(
//             colors: [
//               const Color(0xFFA1FFCE),
//               const Color(0xFFFAFFD1),
//             ],
//             begin: Alignment.topLeft,
//             end: Alignment.bottomRight,
//           ),
//         ),
//         child: Padding(
//           padding: const EdgeInsets.all(16.0),
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             crossAxisAlignment: CrossAxisAlignment.stretch,
//             children: [
//               Text(
//                 "Voice AI",
//                 style: TextStyle(
//                   fontSize: 28,
//                   fontWeight: FontWeight.bold,
//                   color: const Color.fromARGB(255, 2, 2, 2),
//                   letterSpacing: 2.0,
//                 ),
//                 textAlign: TextAlign.center,
//               ),
//               SizedBox(height: 30),
//               Container(
//                 padding: EdgeInsets.all(16),
//                 decoration: BoxDecoration(
//                   color: Colors.white.withOpacity(0.8),
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//                 child: Column(
//                   children: [
//                     Text(
//                       "Spoken Text:",
//                       style: TextStyle(
//                         fontSize: 20,
//                         fontWeight: FontWeight.bold,
//                         color: const Color.fromARGB(255, 0, 0, 0),
//                       ),
//                     ),
//                     SizedBox(height: 10),
//                     Text(
//                       _spokenText.isEmpty ? "Start speaking..." : _spokenText,
//                       style: TextStyle(fontSize: 16, color: Colors.black87),
//                       textAlign: TextAlign.center,
//                     ),
//                   ],
//                 ),
//               ),
//               SizedBox(height: 20),
//               Container(
//                 padding: EdgeInsets.all(16),
//                 decoration: BoxDecoration(
//                   color: Colors.white.withOpacity(0.8),
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//                 child: Column(
//                   children: [
//                     Text(
//                       "Translated Text:",
//                       style: TextStyle(
//                         fontSize: 20,
//                         fontWeight: FontWeight.bold,
//                         color: const Color.fromARGB(255, 255, 255, 255),
//                       ),
//                     ),
//                     SizedBox(height: 10),
//                     Text(
//                       _translatedText.isEmpty
//                           ? "Translation will appear here..."
//                           : _translatedText,
//                       style: TextStyle(fontSize: 16, color: Colors.black87),
//                       textAlign: TextAlign.center,
//                     ),
//                   ],
//                 ),
//               ),
//               SizedBox(height: 20),
//               DropdownButtonFormField<String>(
//                 value: _targetLanguage,
//                 onChanged: (String? newValue) {
//                   setState(() => _targetLanguage = newValue!);
//                 },
//                 decoration: InputDecoration(
//                   filled: true,
//                   fillColor: Colors.white,
//                   border: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(12),
//                     borderSide: BorderSide.none,
//                   ),
//                 ),
//                 items: [
//                   DropdownMenuItem(value: "en", child: Text("English")),
//                   DropdownMenuItem(value: "hi", child: Text("Hindi")),
//                   DropdownMenuItem(value: "gu", child: Text("Gujarati")),
//                   DropdownMenuItem(value: "es", child: Text("Spanish")),
//                   DropdownMenuItem(value: "fr", child: Text("French")),
//                   DropdownMenuItem(value: "de", child: Text("German")),
//                 ],
//               ),
//               SizedBox(height: 30),
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                 children: [
//                   ElevatedButton(
//                     onPressed: _isListening ? _stopListening : _startListening,
//                     child: Text(_isListening ? "Stop" : "Listen"),
//                   ),
//                   ElevatedButton(
//                     onPressed: _translateText,
//                     child: Text("Translate"),
//                   ),
//                   ElevatedButton(
//                     onPressed: _speakText,
//                     child: Text("Speak"),
//                   ),
//                 ],
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:http/http.dart' as http;
import 'package:speech_to_text/speech_to_text.dart' as stt;

void main() {
  runApp(SpeechToTextApp());
}

class SpeechToTextApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Voice Ai',
      theme: ThemeData(primarySwatch: Colors.deepPurple),
      home: SplashScreen(),
    );
  }
}

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: 5),
    );
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.2).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );
    _controller.forward();
    Future.delayed(Duration(seconds: 5), () {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => SpeechToTextScreen()),
      );
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: ScaleTransition(
          scale: _scaleAnimation,
          child: Image.asset('assets/logo.png', width: 180, height: 180),
        ),
      ),
    );
  }
}

class SpeechToTextScreen extends StatefulWidget {
  @override
  _SpeechToTextScreenState createState() => _SpeechToTextScreenState();
}

class _SpeechToTextScreenState extends State<SpeechToTextScreen> {
  late stt.SpeechToText _speech;
  bool _isListening = false;
  String _spokenText = "";
  String _responseText = "";
  final FlutterTts _flutterTts = FlutterTts();

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();

    // Initialize TTS settings
    _flutterTts.setLanguage("en-US");
    _flutterTts.setSpeechRate(0.5);
    _flutterTts.setVolume(1.0);
    _flutterTts.setPitch(1.0);
  }

  Future<void> _startListening() async {
    bool available = await _speech.initialize();
    if (available) {
      setState(() => _isListening = true);
      _speech.listen(onResult: (val) {
        setState(() {
          _spokenText = val.recognizedWords;
        });
        _getAnswerFromAPI(_spokenText); // Send recognized speech to API
      });
    } else {
      setState(() => _isListening = false);
    }
  }

  void _stopListening() {
    _speech.stop();
    setState(() => _isListening = false);
  }

  Future<void> _speakText() async {
    if (_responseText.isNotEmpty) {
      var result = await _flutterTts.speak(_responseText);
      print("TTS Status: $result"); // Debugging
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("No response to speak!")),
      );
    }
  }

  Future<void> _getAnswerFromAPI(String question) async {
    final url = Uri.parse('http://10.10.20.90:11434/api/generate');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'model': 'llama3:latest', // Ensure correct model
          'prompt': question, // Send spoken text as the prompt
          'stream': false,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final answer = data['response']?.trim() ?? ""; // Handle null response

        setState(() {
          _responseText = answer;
        });

        _speakText(); // Speak the response
      } else {
        print("Error: ${response.body}");
        setState(() {
          _responseText = "Sorry, I couldn't get the answer.";
        });
      }
    } catch (error) {
      print("Exception: $error");
      setState(() {
        _responseText = "An error occurred. Please try again.";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFA1FFCE), Color(0xFFFAFFD1)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                "Voice AI",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                  letterSpacing: 2.0,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 30),
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.8),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    Text(
                      "Spoken Text:",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      _spokenText.isEmpty ? "Start speaking..." : _spokenText,
                      style: TextStyle(fontSize: 16, color: Colors.black87),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 20),
                    Text(
                      "Response:",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      _responseText.isEmpty
                          ? "Response will appear here..."
                          : _responseText,
                      style: TextStyle(fontSize: 16, color: Colors.black87),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              SizedBox(height: 30),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: _isListening ? _stopListening : _startListening,
                    child: Text(_isListening ? "Stop" : "Listen"),
                  ),
                  ElevatedButton(
                    onPressed: _speakText,
                    child: Text("Speak"),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
