import 'package:flutter/material.dart';
import 'package:pocketgm/constants/colors.dart';
import 'package:pocketgm/widgets/app_scaffold.dart';

class DocumentationScreen extends StatelessWidget {
  const DocumentationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: "Documentation",
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSectionHeader("Input Controls"),
          _buildCard(
            context,
            title: "How to Input Moves",
            icon: Icons.gamepad,
            content:
                "Moves are entered in 4 steps:\n"
                "1. Select 'From' Column (a-h)\n"
                "2. Select 'From' Row (1-8)\n"
                "3. Select 'To' Column (a-h)\n"
                "4. Select 'To' Row (1-8)\n\n"
                "Use the Increment button to cycle through options, and Confirm to select.",
          ),
          _buildCard(
            context,
            title: "Button Actions",
            icon: Icons.touch_app,
            content:
                "• Increment (Vol Up): Cycle selection (1-8)\n"
                "• Confirm (Vol Down): Select current value\n"
                "• Long Press Increment: Undo last move\n"
                "• Long Press Confirm: Replay last move vibration\n\n"
                "Note: Long press actions are currently only available in Interface mode.",
          ),
          _buildCard(
            context,
            title: "Input Mistakes",
            icon: Icons.undo,
            content:
                "WRONG NUMBER ENTERED\n"
                "Just tap LEFT more times - the counter loops around. When you reach the correct number, tap RIGHT to confirm.\n\n"
                "CONFIRMED WRONG VALUE\n"
                "Wait until the move is complete (all 4 values entered). If the move is illegal, it will be rejected automatically. If legal but wrong, use UNDO button to go back.\n\n"
                "TOO MANY LEFT TAPS\n"
                "The counter loops: 1→2→3→4→5→6→7→8→1→2... Just keep going until you reach your number again.",
          ),
          SizedBox(height: 24),
          _buildSectionHeader("Vibration Guide"),
          _buildCard(
            context,
            title: "Move Coordinates",
            icon: Icons.vibration,
            content:
                "Moves are communicated via vibration pulses representing coordinates (Column, then Row).\n\n"
                "• Columns (a-h): 1-8 pulses\n"
                "• Rows (1-8): 1-8 pulses\n\n"
                "Sequence: From Column -> Pause -> From Row -> Long Pause -> To Column -> Pause -> To Row\n\n"
                "Example 'e2 to e4':\n"
                "5 pulses (e) -> pause -> 2 pulses (2) -> long pause -> 5 pulses (e) -> pause -> 4 pulses (4).\n\n"
                "The speed of these pulses can be adjusted in settings.",
          ),
          _buildCard(
            context,
            title: "Feedback Alerts",
            icon: Icons.warning_amber_rounded,
            content:
                "In Feedback Mode, the engine alerts you to critical moments:\n\n"
                "• Blunder (Long Vibration): A serious mistake that significantly worsens your position. STOP and reconsider!\n"
                "• Mistake (2 Pulses): A minor inaccuracy or suboptimal move.\n"
                "• Opportunity (3 Pulses): Your opponent has blundered! Look for a winning tactic.",
          ),
          _buildCard(
            context,
            title: "System Alerts",
            icon: Icons.notifications_active,
            content:
                "• Input Tap (Short Tick): Confirms a button press or volume key input.\n"
                "• Success (Happy Pattern): Game started successfully or move confirmed.\n"
                "• Error (SOS Pattern): Invalid move attempted (e.g. moving a knight like a rook) or system error.",
          ),

          const SizedBox(height: 24),
          _buildSectionHeader("Game Modes"),
          _buildCard(
            context,
            title: "Quick Mode",
            icon: Icons.speed,
            content:
                "Designed for fast-paced games. You only need to input your opponent's moves. The engine automatically calculates and plays the best move for you on the internal board, providing vibration feedback so you can execute it immediately.",
          ),
          _buildCard(
            context,
            title: "Full Mode",
            icon: Icons.sports_esports,
            content:
                "Complete control over the game. You manually input both your opponent's moves and your own. The engine suggests the best moves via vibration, but you have the freedom to deviate and play any move you wish.",
          ),
          _buildCard(
            context,
            title: "Feedback Mode",
            icon: Icons.analytics,
            content:
                "A silent partner for improvement. Play your game normally by inputting all moves. The engine remains silent unless you make a blunder or miss a significant opportunity, at which point it will alert you via vibration.",
          ),
          const SizedBox(height: 24),
          _buildSectionHeader("Input Methods"),
          _buildCard(
            context,
            title: "PocketGM Device",
            icon: Icons.bluetooth,
            content:
                "Connect to the custom PocketGM hardware via Bluetooth for a seamless, screen-free experience.",
          ),
          _buildCard(
            context,
            title: "Standalone",
            icon: Icons.volume_up,
            content:
                "Use your phone's volume buttons to input moves without looking at the screen. Perfect for discreet play.",
          ),
          _buildCard(
            context,
            title: "Interface",
            icon: Icons.touch_app,
            content:
                "Standard on-screen controls. Use the visual board and buttons to input moves directly.",
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0, left: 4.0),
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(
          color: Colors.white60,
          fontSize: 12,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildCard(
    BuildContext context, {
    required String title,
    required IconData icon,
    required String content,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: buttonColor.withOpacity(0.5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white10),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(
          dividerColor: Colors.transparent,
          iconTheme: const IconThemeData(color: Colors.white54),
        ),
        child: ExpansionTile(
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: Colors.white),
          ),
          title: Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 16,
              color: Colors.white,
            ),
          ),
          childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          children: [
            Text(
              content,
              style: const TextStyle(
                color: Colors.white70,
                height: 1.5,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
