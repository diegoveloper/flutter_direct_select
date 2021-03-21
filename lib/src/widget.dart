part of direct_select_plugin;

class DirectSelect extends StatelessWidget {
  /// Widget child you'll tap to display the Selection List.
  final Widget child;

  /// List of Widgets you'll display after you tap the child.
  final List<Widget> items;

  /// Listener when you select any item from the Selection List.
  final ValueChanged<int?> onSelectedItemChanged;

  /// Height of each Item of the Selection List.
  final double itemExtent;

  /// Amount of magnification when showing the selected item in the overlay.
  final double itemMagnification;

  /// Selected index of your selection list.
  final int selectedIndex;

  /// The preferred method to engage this widget.
  final DirectSelectMode mode;

  /// Color of the background, [Colors.white] by default.
  final Color backgroundColor;

  /// Color of the selection background, [Colors.black12] by default.
  final Color selectionColor;

  const DirectSelect({
    required this.items,
    required this.onSelectedItemChanged,
    required this.itemExtent,
    required this.child,
    this.selectedIndex = 0,
    this.mode = DirectSelectMode.drag,
    this.itemMagnification = 1.15,
    this.backgroundColor = Colors.white,
    this.selectionColor = Colors.black12,
    Key? key,
  })  : assert(items.length > 0),
        assert(itemMagnification >= 1.0),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    switch (mode) {
      case DirectSelectMode.drag:
        return _DirectSelectDrag(
          selectedIndex: selectedIndex,
          mode: mode,
          itemMagnification: itemMagnification,
          items: items,
          onSelectedItemChanged: onSelectedItemChanged,
          itemExtent: itemExtent,
          backgroundColor: backgroundColor,
          selectionColor: selectionColor,
          child: child,
        );
      case DirectSelectMode.tap:
        return _DirectSelectTap(
          selectedIndex: selectedIndex,
          mode: mode,
          itemMagnification: itemMagnification,
          items: items,
          onSelectedItemChanged: onSelectedItemChanged,
          itemExtent: itemExtent,
          backgroundColor: backgroundColor,
          selectionColor: selectionColor,
          child: child,
        );
    }
    throw ArgumentError('Unknown DirectSelectMode provided: $mode');
  }
}
