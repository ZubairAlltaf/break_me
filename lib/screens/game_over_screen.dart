import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:confetti/confetti.dart';
import 'main_menu_screen.dart';
import '../services/storage_service.dart';

class GameOverScreen extends StatefulWidget {
  final int score;

  const GameOverScreen({super.key, required this.score});

  @override
  State<GameOverScreen> createState() => _GameOverScreenState();
}

class _GameOverScreenState extends State<GameOverScreen> {
  int highScore = 0;
  bool isNewHighScore = false;
  late ConfettiController _confettiController;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(seconds: 5));
    _updateHighScore();
  }

  Future<void> _updateHighScore() async {
    final storageService = StorageService();
    highScore = await storageService.getHighScore();
    if (widget.score > highScore) {
      await storageService.setHighScore(widget.score);
      setState(() {
        highScore = widget.score;
        isNewHighScore = true;
      });
      _confettiController.play();
    }
    // Clear saved game data on game over
    await storageService.setSavedLevel(1);
    await storageService.setSavedScore(0);
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.blueAccent, Colors.tealAccent],
          ),
        ),
        child: Stack(
          children: [
            Align(
              alignment: Alignment.topCenter,
              child: ConfettiWidget(
                confettiController: _confettiController,
                blastDirectionality: BlastDirectionality.explosive,
                shouldLoop: false,
                colors: const [
                  Colors.red,
                  Colors.blue,
                  Colors.green,
                  Colors.yellow,
                  Colors.purple,
                ],
                numberOfParticles: 50,
                maxBlastForce: 20,
                minBlastForce: 5,
                emissionFrequency: 0.05,
              ),
            ),
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Game Over',
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
                  Text(
                    'Score: ${widget.score}',
                    style: GoogleFonts.robotoMono(
                      fontSize: 24,
                      color: Colors.white,
                    ),
                  ).animate().fadeIn(duration: 1.2.seconds, delay: 0.2.seconds),
                  const SizedBox(height: 10),
                  Text(
                    'High Score: $highScore',
                    style: GoogleFonts.robotoMono(
                      fontSize: 24,
                      color: Colors.white,
                    ),
                  ).animate().fadeIn(duration: 1.4.seconds, delay: 0.4.seconds),
                  if (isNewHighScore)
                    Text(
                      'New High Score!',
                      style: GoogleFonts.robotoMono(
                        fontSize: 28,
                        color: Colors.yellowAccent,
                        fontWeight: FontWeight.bold,
                      ),
                    )
                        .animate()
                        .fadeIn(duration: 1.6.seconds, delay: 0.6.seconds)
                        .shake(),
                  const SizedBox(height: 40),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const MainMenuScreen(),
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
                      'Main Menu',
                      style: GoogleFonts.robotoMono(
                        fontSize: 20,
                        color: Colors.blueAccent,
                      ),
                    ),
                  )
                      .animate()
                      .fadeIn(duration: 1.8.seconds, delay: 0.8.seconds)
                      .scaleXY(begin: 0.9, end: 1.0),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}