import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flame/game.dart'; // Required for GameWidget
import '../game/pattern_recall_game.dart'; // ✅ FIXED: Points to the Flame game

class MainMenuScreen extends StatefulWidget {
  const MainMenuScreen({super.key});

  @override
  State<MainMenuScreen> createState() => _MainMenuScreenState();
}

class _MainMenuScreenState extends State<MainMenuScreen> {
  int highScore = 0;
  int savedLevel = 1;
  int savedScore = 0;
  bool hasSavedGame = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      highScore = prefs.getInt('highScore') ?? 0;
      savedLevel = prefs.getInt('savedLevel') ?? 1;
      savedScore = prefs.getInt('savedScore') ?? 0;
      // A saved game exists if the level is greater than 1 or score is greater than 0
      hasSavedGame = savedLevel > 1 || savedScore > 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        // Original gradient background
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.blueAccent, Colors.tealAccent],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Original Title
              Text(
                'Pattern Recall',
                style: GoogleFonts.robotoMono(
                  fontSize: 48,
                  color: Colors.white,
                  shadows: [
                    const Shadow(
                      blurRadius: 10,
                      color: Colors.black45,
                      offset: Offset(2, 2),
                    ),
                  ],
                ),
              )
                  .animate()
                  .fadeIn(duration: 1.seconds)
                  .scaleXY(begin: 0.8, end: 1.0),
              const SizedBox(height: 20),
              // Original High Score Text
              Text(
                'High Score: $highScore',
                style: GoogleFonts.robotoMono(
                  fontSize: 24,
                  color: Colors.white,
                ),
              ).animate().fadeIn(duration: 1.2.seconds, delay: 0.2.seconds),
              const SizedBox(height: 10),
              // Original Saved Game Text
              Text(
                hasSavedGame
                    ? 'Last Game: Level $savedLevel, Score $savedScore'
                    : 'No saved game',
                style: GoogleFonts.robotoMono(
                  fontSize: 18,
                  color: Colors.white70,
                ),
              ).animate().fadeIn(duration: 1.4.seconds, delay: 0.4.seconds),
              const SizedBox(height: 40),
              // Original "Start Game" Button
              ElevatedButton(
                onPressed: () {
                  // ✅ FIXED: Navigates to PatternRecallGame with a fresh start
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => GameWidget(
                        game: PatternRecallGame(
                          initialLevel: 1,
                          initialScore: 0,
                        ),
                      ),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.blueAccent,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 40, vertical: 20),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  elevation: 8,
                  shadowColor: Colors.black45,
                ),
                child: Text(
                  'Start Game',
                  style: GoogleFonts.robotoMono(
                    fontSize: 20,
                    color: Colors.blueAccent,
                  ),
                ),
              )
                  .animate()
                  .fadeIn(duration: 1.6.seconds, delay: 0.6.seconds)
                  .scaleXY(begin: 0.9, end: 1.0),
              const SizedBox(height: 20),
              // Original "Continue" Button
              ElevatedButton(
                onPressed: hasSavedGame
                    ? () {
                  // ✅ FIXED: Navigates to PatternRecallGame with saved progress
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => GameWidget(
                        game: PatternRecallGame(
                          initialLevel: savedLevel,
                          initialScore: savedScore,
                        ),
                      ),
                    ),
                  );
                }
                    : null, // Button is disabled if there's no saved game
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                  hasSavedGame ? Colors.white : Colors.grey[400],
                  foregroundColor: Colors.blueAccent,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 40, vertical: 20),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  elevation: hasSavedGame ? 8 : 0,
                  shadowColor: Colors.black45,
                ),
                child: Text(
                  'Continue',
                  style: GoogleFonts.robotoMono(
                    fontSize: 20,
                    color: hasSavedGame ? Colors.blueAccent : Colors.grey[600],
                  ),
                ),
              )
                  .animate()
                  .fadeIn(duration: 1.8.seconds, delay: 0.8.seconds)
                  .scaleXY(begin: 0.9, end: 1.0),
            ],
          ),
        ),
      ),
    );
  }
}
