import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  Future<int> getHighScore() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('highScore') ?? 0;
  }

  Future<void> setHighScore(int score) async {
    final prefs = await SharedPreferences.getInstance();
    final currentHighScore = await getHighScore();
    if (score > currentHighScore) {
      await prefs.setInt('highScore', score);
    }
  }

  Future<int> getSavedLevel() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('savedLevel') ?? 1;
  }

  Future<void> setSavedLevel(int level) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('savedLevel', level.clamp(1, 9999));
  }

  Future<int> getSavedScore() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('savedScore') ?? 0;
  }

  Future<void> setSavedScore(int score) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('savedScore', score.clamp(0, 999999));
  }
}