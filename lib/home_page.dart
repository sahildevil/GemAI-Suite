import 'package:animate_do/animate_do.dart';
import 'package:assistant/feature_box.dart';
import 'package:assistant/gemini_service.dart';
import 'package:flutter/material.dart';
import 'package:assistant/pallete.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:speech_to_text/speech_recognition_result.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final speechToText = SpeechToText();
  final fluttertts = FlutterTts();
  String lastwords = '';
  final GeminiService geminiService = GeminiService();
  String? generatedcontent;
  String? generatedimageurl;
  bool isSpeechInitialized = false;
  bool isListening = false;
  final TextEditingController textController = TextEditingController();

  @override
  void initState() {
    super.initState();
    initSpeechToText();
    initTexttoSpeech();
  }

  Future<void> initTexttoSpeech() async {
    await fluttertts.setLanguage('en-US');
    await fluttertts.setSpeechRate(0.5);
    await fluttertts.setVolume(1.0);
    await fluttertts.setPitch(1.0);
    setState(() {});
  }

  Future<void> initSpeechToText() async {
    isSpeechInitialized = await speechToText.initialize(
      onError: (error) => debugPrint('SpeechToText Error: $error'),
      onStatus: (status) {
        debugPrint('SpeechToText Status: $status');
        if (status == 'notListening' && isListening) {
          // Automatically generate a response when listening stops
          processResponse();
        }
      },
    );
    setState(() {});
  }

  Future<void> startListening() async {
    if (isSpeechInitialized) {
      isListening = true;
      await speechToText.listen(onResult: onSpeechResult);
      setState(() {});
    }
  }

  Future<void> stopListening() async {
    if (speechToText.isListening) {
      isListening = false;
      await speechToText.stop();
      setState(() {});
    }
  }

  void onSpeechResult(SpeechRecognitionResult result) {
    setState(() {
      lastwords = result.recognizedWords;
    });
  }

  Future<void> processResponse({String? input}) async {
    final query = input ?? lastwords;
    if (query.isNotEmpty) {
      final response = await geminiService.getGeminiResponse(query);
      if (response.contains('http')) {
        generatedimageurl = response;
        generatedcontent = null;
      } else {
        generatedcontent = response;
        generatedimageurl = null;
      }
      setState(() {});
    }
  }

  Future<void> systemSpeak(String content) async {
    await fluttertts.speak(content);
  }

  @override
  void dispose() {
    speechToText.stop();
    fluttertts.stop();
    textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: BounceInDown(
          child: const Text(
            'GemAI Suite',
            style: TextStyle(
              fontFamily: 'Cera Pro',
              color: Pallete.mainFontColor,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        centerTitle: true,
        leading: const Icon(Icons.menu_rounded),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            ZoomIn(
              child: Stack(
                children: [
                  Center(
                    child: Container(
                      height: 120,
                      width: 120,
                      margin: const EdgeInsets.only(
                        top: 10.0,
                      ),
                      decoration: const BoxDecoration(
                          color: Pallete.assistantCircleColor,
                          shape: BoxShape.circle),
                    ),
                  ),
                  Container(
                    height: 123,
                    decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        image: DecorationImage(
                            image: AssetImage('assets/images/appicon.jpeg'))),
                  )
                ],
              ),
            ),
            FadeInRight(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
                margin: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 20,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15).copyWith(),
                  border: Border.all(
                    color: const Color.fromARGB(255, 110, 180, 245),
                  ),
                ),
                child: Column(
                  children: [
                    Text(
                      generatedcontent == null
                          ? 'Hi There, How can I assist you today?'
                          : generatedcontent!,
                      style: TextStyle(
                        fontFamily: 'Cera Pro',
                        color: Pallete.mainFontColor,
                        fontSize: generatedcontent == null ? 25 : 18,
                      ),
                    ),
                    if (generatedcontent != null)
                      IconButton(
                        icon: const Icon(Icons.volume_up),
                        onPressed: () {
                          systemSpeak(generatedcontent!);
                        },
                      ),
                  ],
                ),
              ),
            ),
            if (generatedimageurl != null)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Image.network(generatedimageurl!),
              ),
            SlideInLeft(
              child: Visibility(
                visible: generatedcontent == null && generatedimageurl == null,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  alignment: Alignment.centerLeft,
                  child: const Text(
                    'Suggested Actions',
                    style: TextStyle(
                      fontFamily: 'Cera Pro',
                      color: Pallete.mainFontColor,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
            Visibility(
              visible: generatedcontent == null && generatedimageurl == null,
              child: Column(
                children: [
                  SlideInLeft(
                    child: const FeatureBox(
                      colour: Pallete.firstSuggestionBoxColor,
                      headertext: 'Chat With Gemini',
                      desctext: 'Answers all your queries in a breeze!',
                    ),
                  ),
                  SlideInRight(
                    child: const FeatureBox(
                      colour: Pallete.secondSuggestionBoxColor,
                      headertext: 'Image Generator',
                      desctext: 'OpenAI Paid API Required!',
                    ),
                  ),
                  SlideInLeft(
                    child: const FeatureBox(
                      colour: Pallete.thirdSuggestionBoxColor,
                      headertext: 'Gemini Voice Assistant',
                      desctext: 'Press the Mic button to start!',
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(left: 20.0),
              child: TextField(
                controller: textController,
                decoration: InputDecoration(
                  hintText: 'Enter your prompt...',
                  hintStyle: TextStyle(
                    fontFamily: 'Cera Pro',
                    color: Colors.grey.shade600,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(
                      color: Pallete.mainFontColor,
                    ),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                ),
                style: const TextStyle(
                  fontFamily: 'Cera Pro',
                  color: Pallete.mainFontColor,
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          FloatingActionButton(
            backgroundColor: Pallete.secondSuggestionBoxColor,
            onPressed: () async {
              final input = textController.text.trim();
              if (input.isNotEmpty) {
                await processResponse(input: input);
                textController.clear();
              }
            },
            child: const Icon(Icons.send_rounded),
          ),
          const SizedBox(width: 10),
          FloatingActionButton(
            backgroundColor: Pallete.firstSuggestionBoxColor,
            onPressed: () async {
              if (!isSpeechInitialized) {
                await initSpeechToText();
              } else if (speechToText.isNotListening) {
                await startListening();
              } else if (speechToText.isListening) {
                await stopListening();
                await processResponse();
              }
            },
            child: Icon(
              speechToText.isListening
                  ? Icons.stop_circle_rounded
                  : Icons.mic_none_rounded,
            ),
          ),
        ],
      ),
    );
  }
}
