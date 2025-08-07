import 'dart:async';
import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Required for Haptic Feedback
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'game_over_screen.dart'; // Make sure you have this file

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> with TickerProviderStateMixin {
  // --- Game State Variables ---
  List<int> correctPattern = [];
  List<int> playerInput = [];
  int level = 1;
  int score = 0;
  bool isPlayerTurn = false;
  bool isShowingPattern = false;
  int? highlightedIndex;
  String statusText = '';
  final int gridCount = 9;

  // --- Animation Controllers ---
  late AnimationController _auroraController;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    // Animation for the background aurora effect
    _auroraController = AnimationController(vsync: this, duration: const Duration(seconds: 10))
      ..repeat(reverse: true);

    // Pulse Animation for highlighted tiles
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // Start the game after the first frame
    WidgetsBinding.instance.addPostFrameCallback((_) => _startNewLevel());
  }

  @override
  void dispose() {
    _auroraController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  // --- Game Logic (Core logic is the same, with added feedback) ---

  void _startNewLevel() {
    setState(() {
      playerInput = [];
      isPlayerTurn = false;
      isShowingPattern = true;
      statusText = '👀 Watch Closely';
    });

    if (level == 1 && correctPattern.isEmpty) {
      for (int i = 0; i < 3; i++) {
        correctPattern.add(Random().nextInt(gridCount));
      }
    } else {
      correctPattern.add(Random().nextInt(gridCount));
    }
    _showPattern();
  }

  Future<void> _showPattern() async {
    final speed = max(150, 450 - (level ~/ 5) * 40);
    await Future.delayed(const Duration(milliseconds: 700));

    for (int index in correctPattern) {
      if (!mounted) return;
      setState(() => highlightedIndex = index);
      _pulseController.forward(from: 0);
      HapticFeedback.lightImpact();
      await Future.delayed(Duration(milliseconds: speed));
      if (!mounted) return;
      setState(() => highlightedIndex = null);
      await Future.delayed(Duration(milliseconds: speed ~/ 2));
    }

    if (!mounted) return;
    setState(() {
      isShowingPattern = false;
      isPlayerTurn = true;
      statusText = '🎮 Your Turn!';
    });
  }

  void _onPlayerTap(int buttonIndex) {
    if (!isPlayerTurn || isShowingPattern) return;

    HapticFeedback.mediumImpact();
    setState(() {
      playerInput.add(buttonIndex);
      highlightedIndex = buttonIndex;
    });
    _pulseController.forward(from: 0);

    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) setState(() => highlightedIndex = null);
    });

    for (int i = 0; i < playerInput.length; i++) {
      if (playerInput[i] != correctPattern[i]) {
        HapticFeedback.heavyImpact();
        _gameOver();
        return;
      }
    }

    if (playerInput.length == correctPattern.length) {
      setState(() {
        score += level * 10;
        level++;
        statusText = '🎉 Correct!';
      });
      Future.delayed(const Duration(milliseconds: 1000), _startNewLevel);
    }
  }

  void _gameOver() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => GameOverScreen(score: score),
      ),
    );
  }

  // --- UI Build Method ---

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(color: Color(0xFF0D0221)),
        child: Stack(
          children: [
            _buildAnimatedBackground(),
            SafeArea(
              child: Column(
                children: [
                  _buildHeader(),
                  _buildStatusText(),
                  const Spacer(),
                  _buildGameGrid(),
                  const Spacer(flex: 2),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- UI Helper Widgets (Redesigned for Neon Theme) ---

  Widget _buildAnimatedBackground() {
    return AnimatedBuilder(
      animation: _auroraController,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: const [Color(0xFF26408B), Color(0xFF0D0221), Color(0xFF5C2751)],
              begin: Alignment(-1.0 - _auroraController.value * 2, -1.0),
              end: Alignment(1.0 + _auroraController.value * 2, 1.0),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _infoTile("Level", "$level"),
          _infoTile("Score", "$score"),
        ],
      ),
    );
  }

  Widget _infoTile(String title, String value) {
    return Column(
      children: [
        Text(title.toUpperCase(), style: GoogleFonts.russoOne(color: Colors.white54, fontSize: 16, letterSpacing: 1.5)),
        const SizedBox(height: 4),
        Text(value, style: GoogleFonts.russoOne(color: Colors.white, fontSize: 32))
            .animate(key: ValueKey(value)) // Animate when value changes
            .scale(duration: 300.ms, curve: Curves.easeOutBack),
      ],
    );
  }

  Widget _buildStatusText() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20.0),
      child: Text(statusText, style: GoogleFonts.russoOne(fontSize: 24, color: Colors.white))
          .animate(key: ValueKey(statusText)) // Animate when text changes
          .fadeIn(duration: 400.ms)
          .slideY(begin: 0.2, end: 0),
    );
  }

  Widget _buildGameGrid() {
    return SizedBox(
      width: 340,
      height: 340,
      child: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          mainAxisSpacing: 18,
          crossAxisSpacing: 18,
        ),
        physics: const NeverScrollableScrollPhysics(),
        itemCount: gridCount,
        itemBuilder: (context, index) {
          final isHighlighted = highlightedIndex == index;
          return ScaleTransition(
            scale: isHighlighted ? _pulseAnimation : const AlwaysStoppedAnimation(1.0),
            child: GestureDetector(
              onTap: () => _onPlayerTap(index),
              child: Container(
                decoration: BoxDecoration(
                  color: isHighlighted ? const Color(0xFFF900BF) : const Color(0xFF2A1B3D),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: isHighlighted ? const Color(0xFFF900BF).withOpacity(0.8) : const Color(0xFF00C1ED).withOpacity(0.5),
                      blurRadius: isHighlighted ? 25 : 10,
                      spreadRadius: isHighlighted ? 4 : 1,
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
