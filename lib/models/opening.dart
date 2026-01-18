/// A pre-programmed chess opening with a sequence of moves
class Opening {
  final String id;
  final String name;
  final String description;
  final List<String> moves; // List of UCI moves like ['e2e4', 'd7d5', 'e4d5']

  const Opening({
    required this.id,
    required this.name,
    required this.description,
    required this.moves,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'description': description,
        'moves': moves,
      };

  factory Opening.fromJson(Map<String, dynamic> json) => Opening(
        id: json['id'] as String,
        name: json['name'] as String,
        description: json['description'] as String,
        moves: List<String>.from(json['moves']),
      );

  /// Get a human-readable display of moves (e.g., "1. e4 d5 2. exd5")
  String get displayMoves {
    final buffer = StringBuffer();
    for (int i = 0; i < moves.length; i++) {
      if (i % 2 == 0) {
        buffer.write('${(i ~/ 2) + 1}. ');
      }
      buffer.write(_uciToSan(moves[i]));
      if (i < moves.length - 1) {
        buffer.write(' ');
      }
    }
    return buffer.toString();
  }

  /// Simple UCI to SAN-like conversion for display
  String _uciToSan(String uci) {
    if (uci.length < 4) return uci;
    final from = uci.substring(0, 2);
    final to = uci.substring(2, 4);
    return '$from-$to';
  }
}

/// Pre-defined common openings
class DefaultOpenings {
  static const List<Opening> all = [
    Opening(
      id: 'italian',
      name: 'Italian Game',
      description: '1. e4 e5 2. Nf3 Nc6 3. Bc4',
      moves: ['e2e4', 'e7e5', 'g1f3', 'b8c6', 'f1c4'],
    ),
    Opening(
      id: 'sicilian',
      name: 'Sicilian Defense',
      description: '1. e4 c5',
      moves: ['e2e4', 'c7c5'],
    ),
    Opening(
      id: 'french',
      name: 'French Defense',
      description: '1. e4 e6 2. d4 d5',
      moves: ['e2e4', 'e7e6', 'd2d4', 'd7d5'],
    ),
    Opening(
      id: 'carokann',
      name: 'Caro-Kann Defense',
      description: '1. e4 c6 2. d4 d5',
      moves: ['e2e4', 'c7c6', 'd2d4', 'd7d5'],
    ),
    Opening(
      id: 'queensgambit',
      name: 'Queen\'s Gambit',
      description: '1. d4 d5 2. c4',
      moves: ['d2d4', 'd7d5', 'c2c4'],
    ),
    Opening(
      id: 'london',
      name: 'London System',
      description: '1. d4 d5 2. Nf3 Nf6 3. Bf4',
      moves: ['d2d4', 'd7d5', 'g1f3', 'g8f6', 'c1f4'],
    ),
    Opening(
      id: 'ruylopez',
      name: 'Ruy López',
      description: '1. e4 e5 2. Nf3 Nc6 3. Bb5',
      moves: ['e2e4', 'e7e5', 'g1f3', 'b8c6', 'f1b5'],
    ),
    Opening(
      id: 'scotch',
      name: 'Scotch Game',
      description: '1. e4 e5 2. Nf3 Nc6 3. d4',
      moves: ['e2e4', 'e7e5', 'g1f3', 'b8c6', 'd2d4'],
    ),
    Opening(
      id: 'kingsgambit',
      name: 'King\'s Gambit',
      description: '1. e4 e5 2. f4',
      moves: ['e2e4', 'e7e5', 'f2f4'],
    ),
    Opening(
      id: 'kings_indian',
      name: 'King\'s Indian Defense',
      description: '1. d4 Nf6 2. c4 g6',
      moves: ['d2d4', 'g8f6', 'c2c4', 'g7g6'],
    ),
  ];
}
