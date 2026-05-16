import 'package:flutter/material.dart';
import 'game.dart';
import 'tile.dart';
import 'guess_input.dart';

class GamePage extends StatefulWidget {
  const GamePage({super.key});

  @override
  State<GamePage> createState() => _GamePageState();
}

class _GamePageState extends State<GamePage> {
  final Game _game = Game();

  void _showGameEndDialog(String title, String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                setState(() {
                  _game.resetGame();
                });
                Navigator.of(context).pop();
              },
              child: const Text('Play Again'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        spacing: 5.0,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          for (final guess in _game.guesses)
            Row(
              spacing: 5.0,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                for (final letter in guess) Tile(letter.char, letter.type),
              ],
            ),
          if (!_game.didWin && !_game.didLose)
            GuessInput(
              onSubmitGuess: (guess) {
                if (guess.length != 5 || !_game.isLegalGuess(guess)) {
                  ScaffoldMessenger.of(context).clearSnackBars();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Not a valid 5-letter word!'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                  return;
                }

                setState(() {
                  _game.guess(guess);
                });

                if (_game.didWin) {
                  _showGameEndDialog(
                    'You Win!',
                    'You guessed the word: ${_game.hiddenWord.toString().toUpperCase()}',
                  );
                } else if (_game.didLose) {
                  _showGameEndDialog(
                    'Game Over',
                    'The correct word was: ${_game.hiddenWord.toString().toUpperCase()}',
                  );
                }
              },
            )
          else
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton.icon(
                onPressed: () {
                  setState(() {
                    _game.resetGame();
                  });
                },
                icon: const Icon(Icons.refresh),
                label: const Text('Reset Game'),
              ),
            ),
        ],
      ),
    );
  }
}
