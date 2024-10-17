import 'package:flutter/material.dart';
import 'dock.dart';

/// The home page widget that contains the [Dock] and displays the main content.
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String _mainContentText = 'Main Content Area';

  /// Updates the main content text based on the icon placed and its position.
  void _updateMainContent(IconData icon, int position) {
    setState(() {
      _mainContentText = '${_getIconName(icon)} icon placed at position $position';
    });
  }

  /// Converts an [IconData] to its corresponding name.
  String _getIconName(IconData icon) {
    if (icon == Icons.person) return 'Person';
    if (icon == Icons.message) return 'Message';
    if (icon == Icons.call) return 'Phone';
    if (icon == Icons.camera) return 'Camera';
    if (icon == Icons.photo) return 'Photo';
    return 'Unknown';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Icon Dock'),
        centerTitle: true,
        elevation: 4,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blueGrey[200]!, Colors.blueGrey[500]!],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: Text(_mainContentText),
        ),
      ),
      bottomNavigationBar: Dock<IconData>(
        items: const [
          Icons.person,
          Icons.message,
          Icons.call,
          Icons.camera,
          Icons.photo,
        ],
        builder: (IconData icon, bool isDragging) {
          return DockItem(
            icon: icon,
            isDragging: isDragging,
          );
        },
        onReorder: _updateMainContent,
      ),
    );
  }
}