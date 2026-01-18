import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pocketgm/constants/colors.dart';
import 'package:pocketgm/models/opening.dart';
import 'package:pocketgm/providers/openings_provider.dart';
import 'package:pocketgm/widgets/app_scaffold.dart';
import 'package:uuid/uuid.dart';

class OpeningsScreen extends ConsumerStatefulWidget {
  const OpeningsScreen({super.key});

  @override
  ConsumerState<OpeningsScreen> createState() => _OpeningsScreenState();
}

class _OpeningsScreenState extends ConsumerState<OpeningsScreen> {
  @override
  Widget build(BuildContext context) {
    final openingsState = ref.watch(openingsProvider);

    return AppScaffold(
      title: 'Openingszetten',
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Selected Opening Info
          if (openingsState.selectedOpening != null) ...[
            _buildSelectedOpeningCard(openingsState),
            const SizedBox(height: 24),
          ],

          // Standard Openings
          _buildSectionHeader('Standaard Openingen'),
          _buildSection(
            children: DefaultOpenings.all
                .map((opening) => _buildOpeningTile(opening, openingsState))
                .toList(),
          ),
          const SizedBox(height: 24),

          // Custom Openings
          _buildSectionHeader('Aangepaste Openingen'),
          if (openingsState.customOpenings.isEmpty)
            _buildEmptyCustomSection()
          else
            _buildSection(
              children: openingsState.customOpenings
                  .map((opening) => _buildOpeningTile(
                        opening,
                        openingsState,
                        isCustom: true,
                      ))
                  .toList(),
            ),
          const SizedBox(height: 16),

          // Add Custom Opening Button
          _buildAddButton(),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildSelectedOpeningCard(OpeningsProvider openingsState) {
    final opening = openingsState.selectedOpening!;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            buttonColor.withOpacity(0.4),
            buttonColor.withOpacity(0.2),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: buttonColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.check_circle, color: buttonColor, size: 20),
              const SizedBox(width: 8),
              const Text(
                'Geselecteerde Opening',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            opening.name,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            opening.displayMoves,
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 14,
              fontFamily: 'monospace',
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Text(
                  '${opening.moves.length} zetten',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.6),
                    fontSize: 12,
                  ),
                ),
              ),
              TextButton.icon(
                onPressed: () =>
                    ref.read(openingsProvider.notifier).clearSelection(),
                icon: const Icon(Icons.close, size: 16),
                label: const Text('Deselecteren'),
                style: TextButton.styleFrom(
                  foregroundColor: Colors.white70,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                ),
              ),
            ],
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

  Widget _buildSection({required List<Widget> children}) {
    return Container(
      decoration: BoxDecoration(
        color: buttonColor.withOpacity(0.5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        children: children,
      ),
    );
  }

  Widget _buildOpeningTile(
    Opening opening,
    OpeningsProvider openingsState, {
    bool isCustom = false,
  }) {
    final isSelected = openingsState.selectedOpening?.id == opening.id;

    return Column(
      children: [
        ListTile(
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          leading: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: isSelected
                  ? buttonColor
                  : Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              isSelected ? Icons.check : Icons.menu_book_rounded,
              color: isSelected ? Colors.white : Colors.white54,
              size: 20,
            ),
          ),
          title: Text(
            opening.name,
            style: TextStyle(
              color: isSelected ? buttonColor : Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
          subtitle: Text(
            opening.description,
            style: TextStyle(
              color: Colors.white.withOpacity(0.6),
              fontSize: 12,
            ),
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '${opening.moves.length}',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.5),
                  fontSize: 12,
                ),
              ),
              const SizedBox(width: 8),
              if (isCustom)
                IconButton(
                  icon: const Icon(Icons.delete_outline,
                      color: Colors.white38, size: 20),
                  onPressed: () => _confirmDelete(opening),
                ),
              Icon(
                Icons.chevron_right,
                color: Colors.white.withOpacity(0.3),
              ),
            ],
          ),
          onTap: () {
            if (isSelected) {
              ref.read(openingsProvider.notifier).clearSelection();
            } else {
              ref.read(openingsProvider.notifier).selectOpening(opening);
            }
          },
        ),
        const Divider(height: 1, color: Colors.white10),
      ],
    );
  }

  Widget _buildEmptyCustomSection() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: buttonColor.withOpacity(0.3),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        children: [
          Icon(
            Icons.library_add_outlined,
            color: Colors.white.withOpacity(0.4),
            size: 48,
          ),
          const SizedBox(height: 12),
          Text(
            'Geen aangepaste openingen',
            style: TextStyle(
              color: Colors.white.withOpacity(0.6),
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Voeg je eigen openingen toe',
            style: TextStyle(
              color: Colors.white.withOpacity(0.4),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddButton() {
    return Material(
      color: buttonColor,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: () => _showAddOpeningDialog(),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.add, color: Colors.white),
              SizedBox(width: 8),
              Text(
                'Nieuwe Opening Toevoegen',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showAddOpeningDialog() {
    final nameController = TextEditingController();
    final descController = TextEditingController();
    final movesController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Nieuwe Opening',
          style: TextStyle(color: Colors.white),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Naam',
                  labelStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.white.withOpacity(0.3)),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: buttonColor),
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: descController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Beschrijving',
                  labelStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.white.withOpacity(0.3)),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: buttonColor),
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: movesController,
                style: const TextStyle(color: Colors.white),
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: 'Zetten (UCI formaat)',
                  hintText: 'e2e4, e7e5, g1f3',
                  hintStyle: TextStyle(color: Colors.white.withOpacity(0.3)),
                  labelStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.white.withOpacity(0.3)),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: buttonColor),
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Voer zetten in UCI formaat in, gescheiden door komma\'s.\nBijvoorbeeld: e2e4, e7e5, g1f3',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.5),
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Annuleren',
              style: TextStyle(color: Colors.white.withOpacity(0.7)),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: buttonColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: () {
              final name = nameController.text.trim();
              final desc = descController.text.trim();
              final movesText = movesController.text.trim();

              if (name.isEmpty || movesText.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Vul naam en zetten in'),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }

              final moves = movesText
                  .split(',')
                  .map((m) => m.trim().toLowerCase())
                  .where((m) => m.length == 4)
                  .toList();

              if (moves.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Ongeldige zetten. Gebruik UCI formaat (bijv. e2e4)'),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }

              final opening = Opening(
                id: const Uuid().v4(),
                name: name,
                description: desc.isEmpty ? moves.join(', ') : desc,
                moves: moves,
              );

              ref.read(openingsProvider.notifier).addCustomOpening(opening);
              Navigator.pop(context);
            },
            child: const Text(
              'Toevoegen',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(Opening opening) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Opening Verwijderen',
          style: TextStyle(color: Colors.white),
        ),
        content: Text(
          'Weet je zeker dat je "${opening.name}" wilt verwijderen?',
          style: TextStyle(color: Colors.white.withOpacity(0.8)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Annuleren',
              style: TextStyle(color: Colors.white.withOpacity(0.7)),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: () {
              ref.read(openingsProvider.notifier).removeCustomOpening(opening.id);
              Navigator.pop(context);
            },
            child: const Text(
              'Verwijderen',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
