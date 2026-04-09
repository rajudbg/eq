/// Curated emotion vocabulary mapped to broad mood categories.
///
/// Based on the "emotional granularity" research (Barrett, 2017) —
/// people who can label emotions precisely show measurably higher EQ.
library;

import 'package:flutter/material.dart';

/// A specific emotion word within one of the broad mood buckets.
class EmotionWord {
  const EmotionWord({
    required this.label,
    required this.emoji,
    required this.definition,
    this.eqDimension,
  });

  final String label;
  final String emoji;

  /// One-line description shown after selection so the user learns the word.
  final String definition;

  /// Optional link to an EQ dimension — used to surface vocabulary stats.
  final String? eqDimension;
}

/// The five broad buckets (matches existing mood chips).
enum MoodCategory {
  low('Low', Icons.sentiment_very_dissatisfied, '😞'),
  down('Down', Icons.sentiment_dissatisfied, '😔'),
  okay('Okay', Icons.sentiment_neutral, '😐'),
  good('Good', Icons.sentiment_satisfied, '😊'),
  great('Great', Icons.sentiment_very_satisfied, '🤩');

  const MoodCategory(this.label, this.icon, this.emoji);
  final String label;
  final IconData icon;
  final String emoji;
}

/// Master vocabulary. Each bucket has 6–8 options ordered from most common
/// to more nuanced. The list is intentionally small enough to avoid
/// decision fatigue while still expanding the user's emotional range.
const Map<MoodCategory, List<EmotionWord>> emotionVocabulary = {
  MoodCategory.low: [
    EmotionWord(
      label: 'Exhausted',
      emoji: '🫠',
      definition: 'Completely drained — emotionally, physically, or both.',
    ),
    EmotionWord(
      label: 'Anxious',
      emoji: '😰',
      definition: 'A tight, uneasy worry about what might happen.',
      eqDimension: 'selfAwareness',
    ),
    EmotionWord(
      label: 'Overwhelmed',
      emoji: '🌊',
      definition: 'Too many demands hitting at once — hard to think clearly.',
      eqDimension: 'selfRegulation',
    ),
    EmotionWord(
      label: 'Lonely',
      emoji: '🫥',
      definition: 'Disconnected, even if people are around.',
      eqDimension: 'socialSkills',
    ),
    EmotionWord(
      label: 'Frustrated',
      emoji: '😤',
      definition: 'Effort isn\'t matching results — something feels blocked.',
      eqDimension: 'selfRegulation',
    ),
    EmotionWord(
      label: 'Hopeless',
      emoji: '🕳️',
      definition: 'Nothing ahead feels like it will get better.',
    ),
    EmotionWord(
      label: 'Numb',
      emoji: '😶',
      definition: 'Can\'t feel much of anything — checked out.',
      eqDimension: 'selfAwareness',
    ),
  ],
  MoodCategory.down: [
    EmotionWord(
      label: 'Disappointed',
      emoji: '😞',
      definition: 'Something fell short of what you expected or hoped for.',
    ),
    EmotionWord(
      label: 'Irritated',
      emoji: '😒',
      definition: 'Small annoyances building up under the surface.',
      eqDimension: 'selfRegulation',
    ),
    EmotionWord(
      label: 'Insecure',
      emoji: '🥺',
      definition: 'Doubting yourself or your standing with others.',
      eqDimension: 'selfAwareness',
    ),
    EmotionWord(
      label: 'Guilty',
      emoji: '😣',
      definition: 'Feeling responsible for something that went wrong.',
      eqDimension: 'empathy',
    ),
    EmotionWord(
      label: 'Drained',
      emoji: '🪫',
      definition: 'Running on empty — social or emotional energy is gone.',
    ),
    EmotionWord(
      label: 'Restless',
      emoji: '😓',
      definition: 'Can\'t settle — something is off but hard to name.',
      eqDimension: 'selfAwareness',
    ),
    EmotionWord(
      label: 'Envious',
      emoji: '😕',
      definition: 'Wanting what someone else has — and feeling bad about it.',
      eqDimension: 'selfAwareness',
    ),
  ],
  MoodCategory.okay: [
    EmotionWord(
      label: 'Neutral',
      emoji: '😐',
      definition: 'Not good, not bad — just existing.',
    ),
    EmotionWord(
      label: 'Cautious',
      emoji: '🤔',
      definition: 'Holding back — watching before acting.',
      eqDimension: 'selfRegulation',
    ),
    EmotionWord(
      label: 'Patient',
      emoji: '⏳',
      definition: 'Waiting calmly — trusting the process.',
      eqDimension: 'selfRegulation',
    ),
    EmotionWord(
      label: 'Pensive',
      emoji: '🧐',
      definition: 'Deep in thought — trying to make sense of something.',
      eqDimension: 'selfAwareness',
    ),
    EmotionWord(
      label: 'Accepting',
      emoji: '🙂',
      definition: 'At peace with how things are, even if not ideal.',
      eqDimension: 'selfRegulation',
    ),
    EmotionWord(
      label: 'Bored',
      emoji: '🥱',
      definition: 'Nothing feels stimulating — energy is flat.',
    ),
    EmotionWord(
      label: 'Distracted',
      emoji: '🫨',
      definition: 'Mind keeps wandering — hard to stay present.',
      eqDimension: 'selfAwareness',
    ),
  ],
  MoodCategory.good: [
    EmotionWord(
      label: 'Confident',
      emoji: '💪',
      definition: 'Trusting your ability to handle what comes.',
      eqDimension: 'selfAwareness',
    ),
    EmotionWord(
      label: 'Connected',
      emoji: '🤝',
      definition: 'Feeling close to someone — genuinely seen.',
      eqDimension: 'socialSkills',
    ),
    EmotionWord(
      label: 'Grateful',
      emoji: '🙏',
      definition: 'Noticing something good and actually feeling it.',
      eqDimension: 'empathy',
    ),
    EmotionWord(
      label: 'Motivated',
      emoji: '🔥',
      definition: 'Energy pointed in a clear direction — ready to act.',
    ),
    EmotionWord(
      label: 'Calm',
      emoji: '🍃',
      definition: 'Inner stillness — nothing is pulling at you.',
      eqDimension: 'selfRegulation',
    ),
    EmotionWord(
      label: 'Curious',
      emoji: '✨',
      definition: 'Interested and open — wanting to learn more.',
      eqDimension: 'empathy',
    ),
    EmotionWord(
      label: 'Relieved',
      emoji: '😮‍💨',
      definition: 'A weight just dropped — breathing easier now.',
    ),
  ],
  MoodCategory.great: [
    EmotionWord(
      label: 'Joyful',
      emoji: '😄',
      definition: 'Pure, in-the-moment happiness — light and easy.',
    ),
    EmotionWord(
      label: 'Inspired',
      emoji: '🌟',
      definition: 'Fired up by an idea, person, or possibility.',
    ),
    EmotionWord(
      label: 'Proud',
      emoji: '🏆',
      definition: 'Recognizing your own effort and growth.',
      eqDimension: 'selfAwareness',
    ),
    EmotionWord(
      label: 'Loved',
      emoji: '❤️',
      definition: 'Feeling valued and cared for — it landed.',
      eqDimension: 'socialSkills',
    ),
    EmotionWord(
      label: 'Playful',
      emoji: '🎉',
      definition: 'Light energy — spontaneous and free.',
    ),
    EmotionWord(
      label: 'Empowered',
      emoji: '⚡',
      definition: 'Owning your choices — no apologies needed.',
      eqDimension: 'selfRegulation',
    ),
    EmotionWord(
      label: 'Peaceful',
      emoji: '🕊️',
      definition: 'Deep contentment — everything feels aligned.',
    ),
  ],
};
