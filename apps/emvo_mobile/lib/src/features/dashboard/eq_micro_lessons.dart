/// Daily EQ micro-lessons — 30 entries covering all four dimensions.
///
/// Each lesson teaches one EQ concept through a relatable real-world scenario
/// in ~60 seconds of reading. Tagged to dimensions so the dashboard can
/// prioritize lessons matching the user's weakest area.
library;

class MicroLesson {
  const MicroLesson({
    required this.id,
    required this.title,
    required this.body,
    required this.dimension,
    required this.takeaway,
    this.emoji = '🧠',
  });

  final String id;
  final String title;
  final String body;
  final String dimension; // matches EQDimension name
  final String takeaway;
  final String emoji;
}

const List<MicroLesson> microLessons = [
  // ── Self-Awareness ──
  MicroLesson(
    id: 'ml_sa_01',
    title: 'Why your boss\'s eye roll stings',
    body:
        'When someone you respect shows disapproval, it hits harder than a stranger\'s '
        'criticism. That\'s because your brain stores "emotional anchors" — people whose '
        'reactions carry outsized weight because of your history with them. Recognizing '
        'who your anchors are is the first step to not being blindsided.',
    dimension: 'selfAwareness',
    takeaway: 'Name your top 3 emotional anchors — people whose reactions affect you most.',
    emoji: '🎯',
  ),
  MicroLesson(
    id: 'ml_sa_02',
    title: 'The 6-second body scan',
    body:
        'Emotions hit the body before the mind. Your jaw tightens before you "decide" '
        'you\'re angry. Your stomach drops before you label it as dread. A 6-second body '
        'scan — head, shoulders, gut, hands — can name the emotion 10 seconds before '
        'your conscious mind catches up.',
    dimension: 'selfAwareness',
    takeaway: 'Before your next meeting, scan head → shoulders → stomach → hands.',
    emoji: '🫁',
  ),
  MicroLesson(
    id: 'ml_sa_03',
    title: 'Comfort zones have GPS coordinates',
    body:
        'Notice how your emotional state shifts between rooms. Your bedroom might feel '
        'safe, the team Slack channel might feel anxious, and the gym might feel '
        'empowering. These aren\'t just spaces — they\'re emotional environments that '
        'trigger specific patterns. Mapping them gives you power over them.',
    dimension: 'selfAwareness',
    takeaway: 'List 3 places and the automatic emotion each one triggers.',
    emoji: '📍',
  ),
  MicroLesson(
    id: 'ml_sa_04',
    title: 'The story you tell yourself about yourself',
    body:
        'You carry a running narrative: "I\'m bad at confrontation" or "I\'m the '
        'responsible one." These internal scripts shape behavior more than the actual '
        'situation does. Most scripts are written in childhood and never updated. '
        'Just questioning "Is that still true?" can rewire years of autopilot.',
    dimension: 'selfAwareness',
    takeaway: 'Finish this sentence honestly: "I\'m the kind of person who…"',
    emoji: '📖',
  ),
  MicroLesson(
    id: 'ml_sa_05',
    title: 'Emotional hangovers are real',
    body:
        'A stressful afternoon meeting can color your entire evening. You snap at your '
        'partner, not because of them, but because cortisol from 4pm is still in your '
        'bloodstream at 7pm. Naming "I\'m carrying leftover stress" instantly reduces '
        'its power by up to 43% (UCLA neuroimaging research).',
    dimension: 'selfAwareness',
    takeaway: 'Tonight, ask yourself: "Is this feeling mine, or am I carrying someone else\'s energy?"',
    emoji: '🍷',
  ),
  MicroLesson(
    id: 'ml_sa_06',
    title: 'The difference between hungry and hurt',
    body:
        'Low blood sugar mimics frustration. Dehydration mimics anxiety. Poor sleep '
        'mimics sadness. Before labeling an emotion, rule out the physical basics. The '
        'acronym HALT — Hungry, Angry, Lonely, Tired — was created specifically for this. '
        'Check the body before you blame the world.',
    dimension: 'selfAwareness',
    takeaway: 'Next time you feel off, run HALT: Am I Hungry? Angry? Lonely? Tired?',
    emoji: '🍽️',
  ),
  MicroLesson(
    id: 'ml_sa_07',
    title: 'Your "default emotion"',
    body:
        'Everyone has one. For some it\'s mild anxiety. For others it\'s restless '
        'dissatisfaction. It\'s the emotion you return to when nothing else is happening. '
        'Knowing your default matters because it\'s the lens you interpret ambiguous '
        'situations through — and ambiguous situations are most of life.',
    dimension: 'selfAwareness',
    takeaway: 'What do you feel when nothing specific is happening? Name that baseline.',
    emoji: '🏠',
  ),

  // ── Self-Regulation ──
  MicroLesson(
    id: 'ml_sr_01',
    title: 'The 90-second rule',
    body:
        'Neuroscientist Jill Bolte Taylor discovered that the chemical lifespan of an '
        'emotion in your body is roughly 90 seconds. After that, if you\'re still feeling '
        'it, you\'re re-triggering it with your thoughts. The first 90 seconds are '
        'chemistry. Everything after is a choice.',
    dimension: 'selfRegulation',
    takeaway: 'Next time anger flares, set a mental 90-second timer. Just observe.',
    emoji: '⏱️',
  ),
  MicroLesson(
    id: 'ml_sr_02',
    title: 'Name it to tame it',
    body:
        'UCLA brain imaging shows that putting a precise word on a feeling — "frustrated" '
        'instead of "bad" — reduces amygdala activation by up to 43%. The act of labeling '
        'engages your prefrontal cortex, which is the brain\'s brake pedal. Vague words '
        'like "stressed" give your brain nothing to grip onto.',
    dimension: 'selfRegulation',
    takeaway: 'Replace "I feel bad" with a specific word. Try the emotion wheel.',
    emoji: '🏷️',
  ),
  MicroLesson(
    id: 'ml_sr_03',
    title: 'Why "calm down" never works',
    body:
        'Telling someone (or yourself) to "calm down" is like pressing the gas and brake '
        'simultaneously. Instead, try "labeling up": "I notice I\'m getting heated." This '
        'engages the observer part of your brain without fighting the emotion. You can\'t '
        'control an emotion you\'re pretending not to have.',
    dimension: 'selfRegulation',
    takeaway: 'Replace "calm down" with "I notice I\'m feeling…" in your inner dialogue.',
    emoji: '🎙️',
  ),
  MicroLesson(
    id: 'ml_sr_04',
    title: 'The unsent message technique',
    body:
        'Write the angry email. Type the confrontational text. Then don\'t send it. This '
        'isn\'t suppression — it\'s externalization. Moving the emotion from your head to '
        'a screen reduces its intensity without the consequences of sending. Studies show '
        'even writing for 60 seconds reduces emotional load by half.',
    dimension: 'selfRegulation',
    takeaway: 'Keep a "draft" note on your phone for feelings you need to externalize safely.',
    emoji: '📝',
  ),
  MicroLesson(
    id: 'ml_sr_05',
    title: 'Physiological sighs',
    body:
        'Stanford neuroscientist Andrew Huberman identified the fastest real-time '
        'stress reset: a double inhale through the nose followed by a long exhale. This '
        '"physiological sigh" re-inflates collapsed lung sacs and triggers the '
        'parasympathetic nervous system in one breath cycle. It works in seconds.',
    dimension: 'selfRegulation',
    takeaway: 'Try now: two quick inhales through nose, then one slow exhale through mouth.',
    emoji: '🌬️',
  ),
  MicroLesson(
    id: 'ml_sr_06',
    title: 'Decision fatigue and emotional hijacking',
    body:
        'By 3pm, you\'ve made ~35,000 decisions. Each one depletes willpower. That\'s why '
        'arguments happen at dinner, not breakfast. Your prefrontal cortex (the EQ part) '
        'literally runs out of glucose. Strategic rest isn\'t laziness — it\'s emotional '
        'armor for the evening.',
    dimension: 'selfRegulation',
    takeaway: 'Block 15 minutes before your most emotionally demanding part of the day.',
    emoji: '🔋',
  ),
  MicroLesson(
    id: 'ml_sr_07',
    title: 'Delay ≠ suppress',
    body:
        'Emotionally intelligent people don\'t suppress feelings — they delay their '
        'response. "I need to think about this" is not avoidance; it\'s choosing when to '
        'engage. The distinction: suppression says "I\'m fine." Delay says "I\'ll come '
        'back to this when I can be thoughtful about it."',
    dimension: 'selfRegulation',
    takeaway: 'Practice one intentional delay this week: "Let me sit with this."',
    emoji: '⏸️',
  ),

  // ── Empathy ──
  MicroLesson(
    id: 'ml_em_01',
    title: 'The invisible yes',
    body:
        'When someone tells you about a problem, they\'re rarely asking you to fix it. '
        'They\'re asking: "Is what I\'m feeling valid?" The invisible question behind '
        'most venting is "Am I okay?" Before offering solutions, answer the question '
        'they\'re actually asking.',
    dimension: 'empathy',
    takeaway: 'Next time someone vents, try "That sounds really hard" before any advice.',
    emoji: '👂',
  ),
  MicroLesson(
    id: 'ml_em_02',
    title: 'Micro-expressions last 1/25th of a second',
    body:
        'A flash of contempt (one lip corner rises). A micro-frown (inner eyebrows pull '
        'together). These flicker across someone\'s face in 40 milliseconds before their '
        '"social mask" takes over. You can\'t always catch them — but training yourself '
        'to notice face changes builds empathy automatically.',
    dimension: 'empathy',
    takeaway: 'In your next conversation, focus on the other person\'s eyes for 3 seconds before responding.',
    emoji: '👁️',
  ),
  MicroLesson(
    id: 'ml_em_03',
    title: 'Empathy is not agreement',
    body:
        'You can fully understand someone\'s perspective without agreeing with their '
        'conclusion. "I can see why you\'d feel that way" doesn\'t mean "You\'re right." '
        'This is the most misunderstood aspect of empathy — and the reason debates '
        'escalate. Understanding and endorsement are completely separate skills.',
    dimension: 'empathy',
    takeaway: 'Try "I can see why you\'d feel that way" in a disagreement this week.',
    emoji: '🤝',
  ),
  MicroLesson(
    id: 'ml_em_04',
    title: 'The empathy gap between then and now',
    body:
        'It\'s nearly impossible to empathize with your future self\'s emotions. Hungry '
        'you can\'t predict full you\'s preferences. Happy you can\'t imagine depressed '
        'you\'s logic. This "hot-cold empathy gap" explains why we make commitments we '
        'can\'t keep and say "I don\'t know what I was thinking" later.',
    dimension: 'empathy',
    takeaway: 'Before making a big decision, ask: "Would I still choose this in a different mood?"',
    emoji: '🌡️',
  ),
  MicroLesson(
    id: 'ml_em_05',
    title: 'Listening to learn vs listening to respond',
    body:
        'Most people listen to respond: while the other person talks, their brain is '
        'already drafting a reply. Empathic listening means staying in reception mode. '
        'A simple trick: don\'t start formulating your response until 2 seconds of '
        'silence after they finish. That gap is where understanding lives.',
    dimension: 'empathy',
    takeaway: 'In your next conversation, wait 2 seconds of silence before responding.',
    emoji: '🎧',
  ),
  MicroLesson(
    id: 'ml_em_06',
    title: 'Compassion fatigue is protection, not failure',
    body:
        'If you\'re someone who absorbs others\' emotions, you know the burnout that '
        'follows. This isn\'t a defect — it\'s your empathy system protecting itself from '
        'overload. Setting boundaries after emotional conversations isn\'t selfish. '
        'It\'s maintenance for the part of you that cares the most.',
    dimension: 'empathy',
    takeaway: 'After an emotionally heavy conversation, give yourself 10 minutes of quiet.',
    emoji: '🛡️',
  ),
  MicroLesson(
    id: 'ml_em_07',
    title: 'The curse of projection',
    body:
        'Assuming others feel what you would feel in their situation is the most common '
        'empathy error. Your coworker\'s silence might mean peace, not anger. Your '
        'friend\'s laugh might be nervous, not dismissive. Asking "How are you actually '
        'feeling?" takes 4 seconds and prevents 4 hours of wrong assumptions.',
    dimension: 'empathy',
    takeaway: 'Replace "I would feel X" with "How do you feel?" — just once today.',
    emoji: '🪞',
  ),

  // ── Social Skills ──
  MicroLesson(
    id: 'ml_ss_01',
    title: 'The repair conversation',
    body:
        'Every relationship expert agrees: it\'s not about avoiding conflict — it\'s '
        'about repairing after. A simple repair sounds like: "I think I came off '
        'harsh earlier. That wasn\'t my intention." This one sentence has saved more '
        'relationships than any communication technique ever invented.',
    dimension: 'socialSkills',
    takeaway: 'Think of one recent interaction that felt off. Send a 1-line repair text.',
    emoji: '🔧',
  ),
  MicroLesson(
    id: 'ml_ss_02',
    title: 'Social energy is a bank account',
    body:
        'Every interaction is either a deposit (asking, praising, showing interest) or '
        'a withdrawal (criticizing, asking favors, complaining). Gottman\'s research found '
        'that healthy relationships maintain a 5:1 deposit-to-withdrawal ratio. That '
        'means 5 positive interactions for every 1 hard one.',
    dimension: 'socialSkills',
    takeaway: 'Before your next request, make a deposit: genuine praise or curiosity.',
    emoji: '🏦',
  ),
  MicroLesson(
    id: 'ml_ss_03',
    title: 'The power of "Tell me more"',
    body:
        'Three words that transform any conversation. "Tell me more" signals genuine '
        'interest without judgment. It keeps the other person in the driver\'s seat '
        'and gives you time to understand before reacting. It works in interviews, '
        'arguments, and first dates equally well.',
    dimension: 'socialSkills',
    takeaway: 'Use "Tell me more" at least once today instead of your usual response.',
    emoji: '💬',
  ),
  MicroLesson(
    id: 'ml_ss_04',
    title: 'Reading rooms, not just faces',
    body:
        'Individual emotions are one thing. Group energy is another. Walk into a meeting '
        'and scan: who\'s leaning in? Who\'s checked out? Where is the tension sitting? '
        'People with high social skills read rooms the way chess players read boards — '
        'seeing the whole dynamic, not just one piece.',
    dimension: 'socialSkills',
    takeaway: 'At your next group gathering, spend 30 seconds just observing the room before participating.',
    emoji: '🏠',
  ),
  MicroLesson(
    id: 'ml_ss_05',
    title: 'Influence ≠ manipulation',
    body:
        'Influence means helping someone see something they hadn\'t considered. '
        'Manipulation means hiding your real intent. The difference is transparency. '
        '"I think this approach would benefit both of us — here\'s why" is influence. '
        '"Just trust me" without a reason is manipulation.',
    dimension: 'socialSkills',
    takeaway: 'When persuading, always state your reason. Transparency builds lasting trust.',
    emoji: '🔑',
  ),
  MicroLesson(
    id: 'ml_ss_06',
    title: 'The gift of going second',
    body:
        'In emotionally charged conversations, the person who speaks second has the '
        'advantage. They can respond to what was actually said rather than what they '
        'imagined was coming. Letting the other person finish — fully — gives you data '
        'most people never collect.',
    dimension: 'socialSkills',
    takeaway: 'In your next difficult conversation, let the other person finish first.',
    emoji: '🎁',
  ),
  MicroLesson(
    id: 'ml_ss_07',
    title: 'Boundaries are social skills',
    body:
        'Saying no is not a failure of kindness — it\'s the highest form of social '
        'intelligence. People who can\'t set boundaries burn out and become resentful, '
        'which poisons relationships far more than a clear "I can\'t this time." '
        'A respectful no builds more trust than a reluctant yes.',
    dimension: 'socialSkills',
    takeaway: 'Practice: "I\'d love to but I can\'t this time" — no explanation needed.',
    emoji: '🚧',
  ),

  // ── Bonus lessons (mixed) ──
  MicroLesson(
    id: 'ml_mix_01',
    title: 'Your EQ drops 14% when tired',
    body:
        'A University of Arizona study found that just one night of poor sleep reduces '
        'emotional recognition accuracy by 14%. Your ability to read people isn\'t '
        'fixed — it fluctuates with rest, stress, and nutrition. High EQ isn\'t a '
        'permanent trait; it\'s maintained through daily maintenance.',
    dimension: 'selfRegulation',
    takeaway: 'Protect your sleep before an emotionally important day.',
    emoji: '😴',
  ),
  MicroLesson(
    id: 'ml_mix_02',
    title: 'EQ across cultures',
    body:
        'Direct eye contact means respect in Western cultures and confrontation in many '
        'East Asian ones. Silence after a question means thoughtfulness in Japan and '
        'awkwardness in the US. EQ isn\'t universal — it\'s contextual. The highest form '
        'of EQ is knowing that your rules might not apply.',
    dimension: 'empathy',
    takeaway: 'Consider: whose emotional rules are you applying to others?',
    emoji: '🌍',
  ),
];

/// Returns today's lesson based on the day of the year.
MicroLesson lessonForDate(DateTime date) {
  final dayOfYear = date.difference(DateTime(date.year, 1, 1)).inDays;
  final index = (date.year * 400 + dayOfYear).abs() % microLessons.length;
  return microLessons[index];
}
