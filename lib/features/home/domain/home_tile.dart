final class HomeTile {
  const HomeTile({
    required this.title,
    required this.body,
    required this.kind,
  });

  final String title;
  final String body;
  final HomeTileKind kind;
}

enum HomeTileKind { queue, streak, group, alarm }
