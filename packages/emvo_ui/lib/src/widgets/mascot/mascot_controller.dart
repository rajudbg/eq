import 'package:flutter_riverpod/flutter_riverpod.dart';

// Mascot emotional states
enum MascotState {
  idle,
  listening,
  thinking,
  happy,
  concerned,
  celebrating,
  encouraging,
  surprised,
}

// State notifier for mascot
class MascotNotifier extends StateNotifier<MascotState> {
  MascotNotifier() : super(MascotState.idle);

  void setState(MascotState newState) => state = newState;

  void idle() => state = MascotState.idle;
  void listen() => state = MascotState.listening;
  void think() => state = MascotState.thinking;
  void celebrate() => state = MascotState.celebrating;
  void happy() => state = MascotState.happy;
  void concern() => state = MascotState.concerned;
  void encourage() => state = MascotState.encouraging;
  void surprise() => state = MascotState.surprised;

  // React to assessment answers
  void reactToAnswer(int score) {
    if (score >= 4) {
      celebrate();
    } else if (score <= 2) {
      concern();
    } else {
      encourage();
    }
  }
}

final mascotProvider = StateNotifierProvider<MascotNotifier, MascotState>((ref) {
  return MascotNotifier();
});
