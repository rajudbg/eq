import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _kResultId = 'action_plan.celebration_result_id';
const _kVisible = 'action_plan.celebration_visible_count';

/// Persists last celebrated visible habit count per assessment result.
class ActionPlanCelebrationPrefs {
  Future<({String? resultId, int visible})> readLast() async {
    final prefs = await SharedPreferences.getInstance();
    return (
      resultId: prefs.getString(_kResultId),
      visible: prefs.getInt(_kVisible) ?? 0,
    );
  }

  Future<void> write(String resultId, int visibleCount) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kResultId, resultId);
    await prefs.setInt(_kVisible, visibleCount);
  }
}

final actionPlanCelebrationPrefsProvider =
    Provider<ActionPlanCelebrationPrefs>((ref) {
  return ActionPlanCelebrationPrefs();
});
