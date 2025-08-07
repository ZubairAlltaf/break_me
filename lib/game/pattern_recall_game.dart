import 'dart:math';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/game.dart';
import 'package:flame/input.dart';
import 'package:flame/particles.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../screens/main_menu_screen.dart';
import '../services/storage_service.dart';
import '../main.dart';

class PatternRecallGame extends FlameGame with MultiTouchTapDetector {
  List<int> correctBoxes = [];
  List<int> playerSelections = [];
  int level;
  int score;
  int questionsAnswered = 0;
  int questionsRequired = 2;
  bool isPlayerTurn = false;
  bool isShowingPattern = false;
  bool showNextButton = false;
  bool isGameOver = false;
  bool showCorrectScreen = false;
  List<ButtonComponent> buttons = [];
  late TextComponent statusText;
  late TextComponent levelText;
  late TextComponent scoreText;
  late TextComponent questionText;
  late RectangleComponent primaryActionButton;
  late RectangleComponent homeButton;
  late RectangleComponent primaryShadow;
  late RectangleComponent homeShadow;
  late RectangleComponent gameOverOverlay;
  late TextComponent gameOverText;
  late TextComponent gameOverScoreText;
  late TextComponent gameOverLevelText;
  late RectangleComponent correctOverlay;
  late TextComponent correctText;
  final StorageService _storageService = StorageService();

  PatternRecallGame({int initialLevel = 1, int initialScore = 0})
      : level = initialLevel,
        score = initialScore;

  @override
  Future<void> onLoad() async {
    add(
      RectangleComponent(
        size: size,
        paint: Paint()
          ..shader = const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.blueAccent, Colors.tealAccent],
          ).createShader(Rect.fromLTWH(0, 0, size.x, size.y)),
      ),
    );
    _setupUI();
    _setupGrid();
    _startNewLevel();
  }

  void _setupUI() {
    statusText = TextComponent(
      text: 'Watch!',
      position: Vector2(size.x / 2, 50),
      anchor: Anchor.center,
      textRenderer: TextPaint(
        style: GoogleFonts.robotoMono(
          fontSize: 32,
          color: Colors.white,
          fontWeight: FontWeight.bold,
          shadows: [const Shadow(blurRadius: 10, color: Colors.black45)],
        ),
      ),
    );
    add(statusText);

    levelText = TextComponent(
      text: 'Level: $level',
      position: Vector2(20, 20),
      textRenderer: TextPaint(
        style: GoogleFonts.robotoMono(fontSize: 20, color: Colors.white),
      ),
    );
    scoreText = TextComponent(
      text: 'Score: $score',
      position: Vector2(size.x - 20, 20),
      anchor: Anchor.topRight,
      textRenderer: TextPaint(
        style: GoogleFonts.robotoMono(fontSize: 20, color: Colors.white),
      ),
    );
    questionText = TextComponent(
      text: 'Question: ${questionsAnswered + 1}/$questionsRequired',
      position: Vector2(size.x / 2, 100),
      anchor: Anchor.center,
      textRenderer: TextPaint(
        style: GoogleFonts.robotoMono(fontSize: 20, color: Colors.white),
      ),
    );
    add(levelText);
    add(scoreText);
    add(questionText);

    primaryShadow = RectangleComponent(
      size: Vector2(124, 54),
      position: Vector2(size.x / 2 - 80 + 2, size.y - 50 + 2),
      anchor: Anchor.center,
      paint: Paint()..color = Colors.black.withOpacity(0),
    );
    add(primaryShadow);

    homeShadow = RectangleComponent(
      size: Vector2(124, 54),
      position: Vector2(size.x / 2 + 80 + 2, size.y - 50 + 2),
      anchor: Anchor.center,
      paint: Paint()..color = Colors.black.withOpacity(0),
    );
    add(homeShadow);

    primaryActionButton = RectangleComponent(
      size: Vector2(120, 50),
      position: Vector2(size.x / 2 - 80, size.y - 50),
      anchor: Anchor.center,
      paint: Paint()..color = Colors.purple.withOpacity(0),
      children: [
        TextComponent(
          text: '',
          position: Vector2(60, 25),
          anchor: Anchor.center,
          textRenderer: TextPaint(
            style: GoogleFonts.robotoMono(
              fontSize: 20,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
    add(primaryActionButton);

    homeButton = RectangleComponent(
      size: Vector2(120, 50),
      position: Vector2(size.x / 2 + 80, size.y - 50),
      anchor: Anchor.center,
      paint: Paint()..color = Colors.blue.withOpacity(0),
      children: [
        TextComponent(
          text: 'Home',
          position: Vector2(60, 25),
          anchor: Anchor.center,
          textRenderer: TextPaint(
            style: GoogleFonts.robotoMono(
              fontSize: 20,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
    add(homeButton);

    gameOverOverlay = RectangleComponent(
      size: size,
      position: Vector2(size.x / 2, size.y / 2),
      anchor: Anchor.center,
      paint: Paint()..color = Colors.black.withOpacity(0),
    );
    add(gameOverOverlay);

    gameOverText = TextComponent(
      text: 'Game Over!',
      position: Vector2(size.x / 2, size.y / 2 - 50),
      anchor: Anchor.center,
      textRenderer: TextPaint(
        style: GoogleFonts.robotoMono(
          fontSize: 48,
          color: Colors.redAccent.withOpacity(0),
          fontWeight: FontWeight.bold,
          shadows: [const Shadow(blurRadius: 15, color: Colors.black87)],
        ),
      ),
    );
    add(gameOverText);

    gameOverScoreText = TextComponent(
      text: 'Score: $score',
      position: Vector2(size.x / 2, size.y / 2 + 10),
      anchor: Anchor.center,
      textRenderer: TextPaint(
        style: GoogleFonts.robotoMono(
          fontSize: 24,
          color: Colors.white.withOpacity(0),
          fontWeight: FontWeight.bold,
        ),
      ),
    );
    add(gameOverScoreText);

    gameOverLevelText = TextComponent(
      text: 'Level: $level',
      position: Vector2(size.x / 2, size.y / 2 + 40),
      anchor: Anchor.center,
      textRenderer: TextPaint(
        style: GoogleFonts.robotoMono(
          fontSize: 24,
          color: Colors.white.withOpacity(0),
          fontWeight: FontWeight.bold,
        ),
      ),
    );
    add(gameOverLevelText);

    correctOverlay = RectangleComponent(
      size: size,
      position: Vector2(size.x / 2, size.y / 2),
      anchor: Anchor.center,
      paint: Paint()..color = Colors.black.withOpacity(0.5),
    );
    add(correctOverlay);

    correctText = TextComponent(
      text: 'Great Job!',
      position: Vector2(size.x / 2, size.y / 2),
      anchor: Anchor.center,
      textRenderer: TextPaint(
        style: GoogleFonts.robotoMono(
          fontSize: 48,
          color: Colors.greenAccent,
          fontWeight: FontWeight.bold,
          shadows: [const Shadow(blurRadius: 10, color: Colors.black45)],
        ),
      ),
    );
    add(correctText);
  }

  void _setupGrid() {
    buttons.forEach((button) => remove(button));
    buttons.clear();
    final gridSize = level >= 9 ? 4 : 3;
    final buttonSize = 80.0;
    final spacing = 20.0;
    final offsetX = (size.x - (gridSize * buttonSize + (gridSize - 1) * spacing)) / 2;
    final offsetY = 200.0;

    for (var i = 0; i < gridSize; i++) {
      for (var j = 0; j < gridSize; j++) {
        final index = i * gridSize + j;
        final button = ButtonComponent(
          position: Vector2(
            offsetX + j * (buttonSize + spacing),
            offsetY + i * (buttonSize + spacing),
          ),
          size: Vector2(buttonSize, buttonSize),
          index: index,
          onTap: _onButtonTap,
        );
        buttons.add(button);
        add(button);
      }
    }
  }

  void _startNewLevel() {
    correctBoxes = [];
    playerSelections = [];
    questionsAnswered = 0;
    questionsRequired = level >= 9 ? 5 : 2 + (level - 1);
    isPlayerTurn = false;
    isShowingPattern = true;
    showNextButton = false;
    isGameOver = false;
    showCorrectScreen = false;
    statusText.text = 'Watch!';
    levelText.text = 'Level: $level';
    scoreText.text = 'Score: $score';
    questionText.text = 'Question: ${questionsAnswered + 1}/$questionsRequired';
    primaryShadow.paint.color = Colors.black.withOpacity(0);
    homeShadow.paint.color = Colors.black.withOpacity(0);
    primaryActionButton.paint.color = Colors.purple.withOpacity(0);
    homeButton.paint.color = Colors.blue.withOpacity(0);
    (primaryActionButton.children.first as TextComponent).text = '';
    gameOverOverlay.paint.color = Colors.black.withOpacity(0);
    gameOverText.textRenderer = TextPaint(
      style: GoogleFonts.robotoMono(
        fontSize: 48,
        color: Colors.redAccent.withOpacity(0),
        fontWeight: FontWeight.bold,
        shadows: [const Shadow(blurRadius: 15, color: Colors.black87)],
      ),
    );
    gameOverScoreText.textRenderer = TextPaint(
      style: GoogleFonts.robotoMono(
        fontSize: 24,
        color: Colors.white.withOpacity(0),
        fontWeight: FontWeight.bold,
      ),
    );
    gameOverLevelText.textRenderer = TextPaint(
      style: GoogleFonts.robotoMono(
        fontSize: 24,
        color: Colors.white.withOpacity(0),
        fontWeight: FontWeight.bold,
      ),
    );
    correctOverlay.paint.color = Colors.black.withOpacity(0);
    correctText.textRenderer = TextPaint(
      style: GoogleFonts.robotoMono(
        fontSize: 48,
        color: Colors.greenAccent.withOpacity(0),
        fontWeight: FontWeight.bold,
        shadows: [const Shadow(blurRadius: 10, color: Colors.black45)],
      ),
    );
    _setupGrid();
    _generatePattern();
    _showPattern();
    _saveProgress();
  }

  void _generatePattern() {
    correctBoxes.clear();
    final gridSize = level >= 9 ? 4 : 3;
    final boxCount = 3 + (level - 1);
    final maxBoxes = gridSize * gridSize;
    final boxCountClamped = boxCount.clamp(3, maxBoxes);
    final indices = List.generate(maxBoxes, (index) => index)..shuffle();
    correctBoxes = indices.take(boxCountClamped).toList();
  }

  Future<void> _showPattern() async {
    for (int index in correctBoxes) {
      buttons[index].highlight();
      await Future.delayed(const Duration(milliseconds: 500));
      buttons[index].unhighlight();
      await Future.delayed(const Duration(milliseconds: 200));
    }
    isShowingPattern = false;
    isPlayerTurn = true;
    statusText.text = 'Repeat!';
  }

  void _onButtonTap(int index) {
    if (!isPlayerTurn || isShowingPattern || showNextButton || isGameOver) return;
    playerSelections.add(index);
    buttons[index].highlight();

    if (playerSelections.length <= correctBoxes.length &&
        playerSelections.last != correctBoxes[playerSelections.length - 1]) {
      score = (score - level * 5).clamp(0, 999999);
      scoreText.text = 'Score: $score';
      _saveProgress();
      _gameOver();
      return;
    }

    if (playerSelections.length == correctBoxes.length) {
      score += level * 10;
      questionsAnswered++;
      scoreText.text = 'Score: $score';
      questionText.text =
      'Question: ${questionsAnswered + 1 > questionsRequired ? questionsRequired : questionsAnswered + 1}/$questionsRequired';
      statusText.text = 'Correct!';
      showCorrectScreen = true;
      showNextButton = true;
      primaryShadow.paint.color = Colors.black.withOpacity(0.3);
      homeShadow.paint.color = Colors.black.withOpacity(0.3);
      primaryActionButton.paint.color = Colors.purple.withOpacity(1);
      homeButton.paint.color = Colors.blue.withOpacity(1);
      (primaryActionButton.children.first as TextComponent).text = questionsAnswered >= questionsRequired ? 'Next' : 'Next';
      correctOverlay.paint.color = Colors.black.withOpacity(0.5);
      correctText.textRenderer = TextPaint(
        style: GoogleFonts.robotoMono(
          fontSize: 48,
          color: Colors.greenAccent.withOpacity(1),
          fontWeight: FontWeight.bold,
          shadows: [const Shadow(blurRadius: 10, color: Colors.black45)],
        ),
      );
      add(
        ParticleSystemComponent(
          particle: Particle.generate(
            count: 50,
            generator: (i) => AcceleratedParticle(
              acceleration: Vector2(0, 100),
              speed: Vector2(
                Random().nextDouble() * 100 - 50,
                Random().nextDouble() * -100,
              ),
              position: Vector2(size.x / 2, size.y / 2),
              child: CircleParticle(
                radius: 5,
                paint: Paint()
                  ..color =
                  Colors.primaries[Random().nextInt(Colors.primaries.length)],
              ),
            ),
          ),
        ),
      );
      _saveProgress();
    }
  }

  void _onPrimaryActionButtonTap() {
    final actionText = (primaryActionButton.children.first as TextComponent).text;
    if (actionText == 'Next') {
      showNextButton = false;
      showCorrectScreen = false;
      primaryShadow.paint.color = Colors.black.withOpacity(0);
      homeShadow.paint.color = Colors.black.withOpacity(0);
      primaryActionButton.paint.color = Colors.purple.withOpacity(0);
      homeButton.paint.color = Colors.blue.withOpacity(0);
      correctOverlay.paint.color = Colors.black.withOpacity(0);
      correctText.textRenderer = TextPaint(
        style: GoogleFonts.robotoMono(
          fontSize: 48,
          color: Colors.greenAccent.withOpacity(0),
          fontWeight: FontWeight.bold,
          shadows: [const Shadow(blurRadius: 10, color: Colors.black45)],
        ),
      );
      if (questionsAnswered >= questionsRequired) {
        level++;
        _saveProgress();
        _startNewLevel();
      } else {
        playerSelections = [];
        buttons.forEach((button) => button.unhighlight());
        isPlayerTurn = false;
        isShowingPattern = true;
        statusText.text = 'Watch!';
        _generatePattern();
        _showPattern();
      }
      _saveProgress();
    } else if (actionText == 'Try Again') {
      _startNewLevel();
    }
  }

  void _onHomeButtonTap() {
    _saveProgress();
    navigatorKey.currentState?.pushReplacement(
      MaterialPageRoute(builder: (context) => const MainMenuScreen()),
    );
  }

  void _gameOver() {
    isGameOver = true;
    isPlayerTurn = false;
    statusText.text = '';
    questionText.text = '';
    // Ensure overlay and text are added or brought to front
    gameOverOverlay.paint.color = Colors.black.withOpacity(0.7);
    gameOverText.textRenderer = TextPaint(
      style: GoogleFonts.robotoMono(
        fontSize: 48,
        color: Colors.redAccent.withOpacity(1),
        fontWeight: FontWeight.bold,
        shadows: [const Shadow(blurRadius: 15, color: Colors.black87)],
      ),
    );
    gameOverScoreText
      ..text = 'Score: $score'
      ..textRenderer = TextPaint(
        style: GoogleFonts.robotoMono(
          fontSize: 24,
          color: Colors.white.withOpacity(1),
          fontWeight: FontWeight.bold,
        ),
      );
    gameOverLevelText
      ..text = 'Level: $level'
      ..textRenderer = TextPaint(
        style: GoogleFonts.robotoMono(
          fontSize: 24,
          color: Colors.white.withOpacity(1),
          fontWeight: FontWeight.bold,
        ),
      );
    primaryShadow.paint.color = Colors.black.withOpacity(0.3);
    homeShadow.paint.color = Colors.black.withOpacity(0.3);
    primaryActionButton.paint.color = Colors.purple.withOpacity(1);
    homeButton.paint.color = Colors.blue.withOpacity(1);
    (primaryActionButton.children.first as TextComponent).text = 'Try Again';
    // Re-add overlay and text to ensure they are in front
    remove(gameOverOverlay);
    remove(gameOverText);
    remove(gameOverScoreText);
    remove(gameOverLevelText);
    add(gameOverOverlay);
    add(gameOverText);
    add(gameOverScoreText);
    add(gameOverLevelText);
    // Re-add buttons to ensure they are in front
    remove(primaryActionButton);
    remove(homeButton);
    remove(primaryShadow);
    remove(homeShadow);
    add(primaryShadow);
    add(homeShadow);
    add(primaryActionButton);
    add(homeButton);
  }

  Future<void> _saveProgress() async {
    await _storageService.setSavedLevel(level);
    await _storageService.setSavedScore(score);
    await _storageService.setHighScore(score);
  }

  @override
  void onTapDown(int pointerId, TapDownInfo info) {
    final position = info.eventPosition.global;
    if (position.x >= primaryActionButton.position.x - primaryActionButton.size.x / 2 &&
        position.x <= primaryActionButton.position.x + primaryActionButton.size.x / 2 &&
        position.y >= primaryActionButton.position.y - primaryActionButton.size.y / 2 &&
        position.y <= primaryActionButton.position.y + primaryActionButton.size.y / 2) {
      _onPrimaryActionButtonTap();
      return;
    }
    if (position.x >= homeButton.position.x - homeButton.size.x / 2 &&
        position.x <= homeButton.position.x + homeButton.size.x / 2 &&
        position.y >= homeButton.position.y - homeButton.size.y / 2 &&
        position.y <= homeButton.position.y + homeButton.size.y / 2) {
      _onHomeButtonTap();
      return;
    }
    if (isPlayerTurn && !isShowingPattern && !showNextButton && !isGameOver) {
      for (var button in buttons) {
        if (position.x >= button.position.x &&
            position.x <= button.position.x + button.size.x &&
            position.y >= button.position.y &&
            position.y <= button.position.y + button.size.y) {
          _onButtonTap(button.index);
          break;
        }
      }
    }
  }
}

class ButtonComponent extends RectangleComponent {
  final int index;
  final void Function(int) onTap;
  bool isHighlighted = false;

  ButtonComponent({
    required Vector2 position,
    required Vector2 size,
    required this.index,
    required this.onTap,
  }) : super(
    position: position,
    size: size,
    paint: Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Colors.purple[700]!, Colors.blue[300]!],
      ).createShader(Rect.fromLTWH(0, 0, size.x, size.y)),
  );

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
          Rect.fromLTWH(0, 0, size.x, size.y), const Radius.circular(15)),
      Paint()
        ..color = Colors.white.withOpacity(0.3)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4,
    );
    if (isHighlighted) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
            Rect.fromLTWH(0, 0, size.x, size.y), const Radius.circular(15)),
        Paint()
          ..shader = LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.yellow[700]!, Colors.orange[300]!],
          ).createShader(Rect.fromLTWH(0, 0, size.x, size.y))
          ..style = PaintingStyle.stroke
          ..strokeWidth = 6,
      );
    }
  }

  void highlight() {
    if (!isHighlighted) {
      isHighlighted = true;
      add(ScaleEffect.to(Vector2.all(1.2), EffectController(duration: 0.2)));
    }
  }

  void unhighlight() {
    if (isHighlighted) {
      isHighlighted = false;
      add(ScaleEffect.to(Vector2.all(1.0), EffectController(duration: 0.2)));
    }
  }
}