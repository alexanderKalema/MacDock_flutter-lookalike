import 'package:flutter/material.dart';
import 'dart:ui' show lerpDouble;

/// A single item in the [Dock].
/// Displays an icon within a container with a shadow when dragged.
class DockItem extends StatelessWidget {
  /// Creates a [DockItem].
  ///
  /// The [icon] parameter must not be null and specifies the icon to display.
  /// The [isDragging] parameter specifies whether the item is currently being dragged.
  final IconData icon;
  final bool isDragging;

  const DockItem({
    super.key,
    required this.icon,
    this.isDragging = false,
  });

  @override
  Widget build(BuildContext context) {
    Matrix4 transform = Matrix4.identity();
    if (isDragging) {
      transform.scale(1.1);
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      height: 48,
      margin: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: Colors.primaries[icon.hashCode % Colors.primaries.length],
        boxShadow: isDragging
            ? [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 10,
                  spreadRadius: 3,
                ),
              ]
            : null,
      ),
      transform: transform,
      child: SizedBox(child: Center(child: Icon(icon, color: Colors.white))),
    );
  }
}

/// A dock containing reorderable [items] that can be dragged and animated.
class Dock<T> extends StatefulWidget {
  /// Creates a new instance of [Dock].
  ///
  /// The [items] parameter must not be null and should provide the
  /// initial list of items to be displayed in the dock.
  ///
  /// The [builder] function must be provided to create widgets
  /// for each item in the dock based on the item data and its drag state.
  ///
  /// The [onReorder] function is called when an item is reordered.
  const Dock({
    super.key,
    required this.items,
    required this.builder,
    required this.onReorder,
  });

  final List<T> items;
  final Widget Function(T, bool) builder;
  final void Function(T, int) onReorder;

  @override
  State<Dock<T>> createState() => _DockState<T>();
}

class _DockState<T> extends State<Dock<T>> with TickerProviderStateMixin {
  late List<T> _items;
  final List<AnimationController> _controllers = [];


  @override
  void initState() {
    super.initState();
    _items = List.from(widget.items);
  }

  @override
  void dispose() {
    for (final controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  AnimationController _createAnimationController() {
    final controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _controllers.add(controller);
    return controller;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: Colors.black12,
      ),
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: SizedBox(
        height: MediaQuery.of(context).size.height * 0.1,
        width: double.infinity,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final itemWidth = constraints.maxWidth / _items.length;

            return ReorderableListView.builder(
              scrollDirection: Axis.horizontal,
              shrinkWrap: false,
              itemCount: _items.length,
              itemBuilder: (context, index) {
                return SizedBox(
                  key: ValueKey(_items[index]),
                  width: itemWidth,
                  child: Draggable<int>(
                    data: index,
                    feedback: ScaleTransition(
                      scale: Tween<double>(begin: 1.0, end: 1.5).animate(
                        _createAnimationController()..forward(),
                      ),
                      child: SizedBox(
                        width: itemWidth * 0.8,
                        child: widget.builder(_items[index], true),
                      ),
                    ),
                    childWhenDragging: Opacity(
                      opacity: 0.5,
                      child: widget.builder(_items[index], false),
                    ),
                    child: DragTarget<int>(
                      builder: (context, candidateData, rejectedData) {
                        return widget.builder(_items[index], false);
                      },
                      onAcceptWithDetails: (details) {
                        _onReorder(details.data, index);
                      },
                    ),
                  ),
                );
              },
              onReorder: _onReorder,
              proxyDecorator: (child, index, animation) {
                return AnimatedBuilder(
                  animation: animation,
                  builder: (BuildContext context, Widget? child) {
                    final double animValue =
                        Curves.easeInOut.transform(animation.value);
                    final double elevation = lerpDouble(0, 8, animValue)!;
                    return Material(
                      elevation: elevation,
                      color: Colors.transparent,
                      child: child,
                    );
                  },
                  child: child,
                );
              },
            );
          },
        ),
      ),
    );
  }

  /// Reorders the items when an icon is dragged.
  ///
  /// [oldIndex] is the starting position and [newIndex] is the target.
  void _onReorder(int oldIndex, int newIndex) {
    setState(() {
      if (oldIndex < newIndex) {
        newIndex -= 1;
      }
      final T item = _items.removeAt(oldIndex);
      _items.insert(newIndex, item);
      widget.onReorder(item, newIndex + 1);
    });
  }
}
