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
          _buildSectionHeader("Input controls"),
          _buildCard(
            context,
            title: "Entering moves",
            icon: Icons.gamepad,
            content:
                "Enter each move in four steps:\n"
                "1. Starting column (a–h)\n"
                "2. Starting row (1–8)\n"
                "3. Destination column (a–h)\n"
                "4. Destination row (1–8)\n\n"
                "Tap Increment to cycle through values, then Confirm to select.",
          ),
          _buildCard(
            context,
            title: "Button controls",
            icon: Icons.touch_app,
            content:
                "• Increment or volume up: cycle through values.\n"
                "• Confirm or volume down: select the current value.\n"
                "• Hold Increment: undo the last move.\n"
                "• Hold Confirm: repeat the last move's vibration.\n\n"
                "Press and hold actions are available when using the on-screen buttons.",
          ),
          _buildCard(
            context,
            title: "Correcting input",
            icon: Icons.undo,
            content:
                "Wrong value selected\n"
                "Keep tapping Increment until you reach the right value, then tap Confirm. The counter returns to 1 after 8.\n\n"
                "Wrong value confirmed\n"
                "Finish entering all four values. Illegal moves are rejected automatically. To correct a legal move, tap Undo or hold Increment when using the on-screen buttons.",
          ),
          SizedBox(height: 24),
          _buildSectionHeader("Vibrations"),
          _buildCard(
            context,
            title: "Move coordinates",
            icon: Icons.vibration,
            content:
                "Each square is sent as a column, then a row:\n\n"
                "• Columns a–h: 1–8 pulses.\n"
                "• Rows 1–8: 1–8 pulses.\n\n"
                "A short pause separates the column and row. A longer pause separates the starting and destination squares.\n\n"
                "For e2 to e4: 5 pulses, pause, 2 pulses, long pause, 5 pulses, pause, 4 pulses.\n\n"
                "Change the vibration speed in Settings.",
          ),
          _buildCard(
            context,
            title: "Move feedback",
            icon: Icons.warning_amber_rounded,
            content:
                "Feedback mode uses three alerts:\n\n"
                "• One long vibration: a blunder that weakens your position.\n"
                "• Two pulses: a mistake or inaccuracy.\n"
                "• Three pulses: an opportunity after your opponent's blunder.",
          ),
          _buildCard(
            context,
            title: "Other alerts",
            icon: Icons.notifications_active,
            content:
                "• A short tick confirms a button press.\n"
                "• The success pattern confirms a move or the start of a game.\n"
                "• The error pattern signals an invalid move or a system error.",
          ),

          const SizedBox(height: 24),
          _buildSectionHeader("Game modes"),
          _buildCard(
            context,
            title: "Quick mode",
            icon: Icons.speed,
            content:
                "Enter your opponent's moves. The engine chooses your reply, plays it on the app's board, and sends it through vibration.",
          ),
          _buildCard(
            context,
            title: "Full mode",
            icon: Icons.sports_esports,
            content:
                "Enter both players' moves. The engine suggests a reply through vibration; you choose which move to play.",
          ),
          _buildCard(
            context,
            title: "Feedback mode",
            icon: Icons.analytics,
            content:
                "Enter both players' moves. The engine sends vibration alerts for mistakes, blunders, and opportunities.",
          ),
          const SizedBox(height: 24),
          _buildSectionHeader("Input methods"),
          _buildCard(
            context,
            title: "PocketGM device",
            icon: Icons.bluetooth,
            content:
                "Connect your PocketGM device through Bluetooth to enter moves and receive vibrations.",
          ),
          _buildCard(
            context,
            title: "Phone volume buttons",
            icon: Icons.volume_up,
            content: "Enter moves with your phone's volume buttons.",
          ),
          _buildCard(
            context,
            title: "On-screen buttons",
            icon: Icons.touch_app,
            content: "Enter moves with the on-screen buttons.",
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0, left: 4.0),
      child: Text(
        title,
        style: const TextStyle(
          color: Colors.white60,
          fontSize: 14,
          fontWeight: FontWeight.w600,
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
