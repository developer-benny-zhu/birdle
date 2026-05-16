library;

import 'dart:collection';
import 'dart:math';

import 'package:english_words/english_words.dart' as nouns;

enum HitType { none, hit, partial, miss }

typedef Letter = ({String char, HitType type});

final List<String> legalWords = nouns.all
    .where((word) => word.length == 5)
    .map((word) => word.toLowerCase())
    .toList();

final List<String> allLegalGuesses = legalWords;

class Game {
  static const int defaultMaxGuesses = 5;
  Game({this.maxGuesses = defaultMaxGuesses, this.seed})
    : _wordToGuess = _generateInitialWord(seed),
      _guesses = List<Word>.generate(maxGuesses, (_) => Word.empty());

  final int maxGuesses;
  final int? seed;
  Word _wordToGuess;
  List<Word> _guesses;

  Word get hiddenWord => _wordToGuess;
  UnmodifiableListView<Word> get guesses => UnmodifiableListView(_guesses);

  Word get previousGuess {
    final index = _guesses.lastIndexWhere((word) => word.isNotEmpty);
    return index == -1 ? Word.empty() : _guesses[index];
  }

  int get activeIndex => _guesses.indexWhere((word) => word.isEmpty);
  int get guessesRemaining {
    if (activeIndex == -1) return 0;
    return maxGuesses - activeIndex;
  }

  bool get didWin {
    if (_guesses.first.isEmpty) return false;

    for (final letter in previousGuess) {
      if (letter.type != HitType.hit) return false;
    }

    return true;
  }

  bool get didLose => guessesRemaining == 0 && !didWin;
  void resetGame() {
    _wordToGuess = _generateInitialWord(seed);
    _guesses = List<Word>.generate(maxGuesses, (_) => Word.empty());
  }

  Word guess(String guess) {
    final result = matchGuessOnly(guess);
    addGuessToList(result);
    return result;
  }

  bool isLegalGuess(String guess) => Word.fromString(guess).isLegalGuess;
  Word matchGuessOnly(String guess) =>
      Word.fromString(guess).evaluateGuess(_wordToGuess);

  void addGuessToList(Word guess) {
    final guessIndex = activeIndex;
    if (guessIndex == -1) {
      throw StateError('No guesses remaining.');
    }

    _guesses[guessIndex] = guess;
  }

  static Word _generateInitialWord(int? seed) =>
      seed == null ? Word.random() : Word.fromSeed(seed);
}

class Word with IterableMixin<Letter> {
  Word(this._letters);

  factory Word.empty() =>
      Word(List<Letter>.filled(5, (char: '', type: HitType.none)));

  factory Word.fromString(String guess) {
    if (guess.length != 5) {
      throw ArgumentError.value(
        guess,
        'guess',
        'Must be exactly 5 characters long.',
      );
    }

    final letters = guess
        .toLowerCase()
        .split('')
        .map((char) => (char: char, type: HitType.none))
        .toList();
    return Word(letters);
  }

  factory Word.random() {
    final random = Random();
    final nextWord = legalWords[random.nextInt(legalWords.length)];
    return Word.fromString(nextWord);
  }

  factory Word.fromSeed(int seed) =>
      Word.fromString(legalWords[seed % legalWords.length]);

  final List<Letter> _letters;

  @override
  Iterator<Letter> get iterator => _letters.iterator;
  @override
  bool get isEmpty => every((letter) => letter.char.isEmpty);

  @override
  int get length => _letters.length;
  Letter operator [](int i) => _letters[i];

  @override
  String toString() => _letters.map((letter) => letter.char).join().trim();

  String toStringVerbose() => _letters
      .map((letter) => '${letter.char} - ${letter.type.name}')
      .join('\n');
}

extension WordUtils on Word {
  bool get isLegalGuess => allLegalGuesses.contains(toString());

  Word evaluateGuess(Word hiddenWord) {
    assert(isLegalGuess);

    final result = List<Letter>.filled(length, (char: '', type: HitType.none));
    final unmatchedHiddenLetterCounts = <String, int>{};
    for (var i = 0; i < length; i++) {
      final guessChar = this[i].char;
      final hiddenChar = hiddenWord[i].char;

      if (guessChar == hiddenChar) {
        result[i] = (char: guessChar, type: HitType.hit);
      } else {
        final unmatchedCount = unmatchedHiddenLetterCounts[hiddenChar] ?? 0;
        unmatchedHiddenLetterCounts[hiddenChar] = unmatchedCount + 1;
      }
    }
    for (var i = 0; i < length; i++) {
      if (result[i].type == HitType.hit) continue;

      final guessChar = this[i].char;
      final unmatchedCount = unmatchedHiddenLetterCounts[guessChar] ?? 0;
      final isPartial = unmatchedCount > 0;
      if (isPartial) {
        unmatchedHiddenLetterCounts[guessChar] = unmatchedCount - 1;
      }

      result[i] = (
        char: guessChar,
        type: isPartial ? HitType.partial : HitType.miss,
      );
    }

    return Word(result);
  }
}
