enum OraclePersona {
  spark(
    name: 'Spark',
    description: 'Playful and energetic',
    style: 'Short, punchy answers with optimistic energy. Uses present tense.',
    lengthTarget: 6,
  ),
  luna(
    name: 'Luna',
    description: 'Mystical and enigmatic',
    style: 'Cryptic, poetic answers with celestial imagery. Uses metaphors.',
    lengthTarget: 8,
  ),
  oraclePro(
    name: 'Oracle Pro',
    description: 'Wise and thoughtful',
    style: 'Balanced, nuanced answers that acknowledge complexity.',
    lengthTarget: 10,
  );

  final String name;
  final String description;
  final String style;
  final int lengthTarget;

  const OraclePersona({
    required this.name,
    required this.description,
    required this.style,
    required this.lengthTarget,
  });

  int get maxWords => lengthTarget + 2;
}
