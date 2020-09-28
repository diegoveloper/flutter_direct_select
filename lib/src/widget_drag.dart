part of direct_select_plugin;

class _DirectSelectDrag extends _DirectSelectBase {
  const _DirectSelectDrag({
    Widget child,
    List<Widget> items,
    ValueChanged<int> onSelectedItemChanged,
    double itemExtent,
    double itemMagnification,
    int selectedIndex,
    DirectSelectMode mode,
    Color backgroundColor,
    Key key,
  }) : super(
          selectedIndex: selectedIndex,
          mode: mode,
          itemMagnification: itemMagnification,
          items: items,
          onSelectedItemChanged: onSelectedItemChanged,
          itemExtent: itemExtent,
          backgroundColor: backgroundColor,
          child: child,
          key: key,
        );

  @override
  _DirectSelectDragState createState() => _DirectSelectDragState();
}

class _DirectSelectDragState extends _DirectSelectBaseState<_DirectSelectDrag> {
  OverlayEntry _overlayEntry;
  GlobalKey<_MySelectionOverlayState> _keyOverlay;

  @override
  Future<void> _createOverlay() async {
    if (mounted) {
      OverlayState overlayState = Overlay.of(context);
      if (overlayState != null) {
        _overlayEntry = OverlayEntry(builder: (_) => _overlayWidget(_keyOverlay));
        overlayState.insert(_overlayEntry);
      }
    }
  }

  @override
  Future<void> _removeOverlay() async {
    if (mounted) {
      final currentState = _keyOverlay.currentState;
      if (currentState != null) {
        currentState.reverse(_overlayEntry);
      }
      _notifySelectedItem();
    }
  }

  @override
  void initState() {
    _keyOverlay = GlobalKey();
    super.initState();
  }
}
