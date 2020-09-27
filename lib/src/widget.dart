part of direct_select_plugin;

class DirectSelect extends StatefulWidget {
  /// Widget child you'll tap to display the Selection List.
  final Widget child;

  /// List of Widgets you'll display after you tap the child.
  final List<Widget> items;

  /// Listener when you select any item from the Selection List.
  final ValueChanged<int> onSelectedItemChanged;

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

  const DirectSelect({
    Key key,
    this.selectedIndex,
    this.mode = DirectSelectMode.drag,
    this.itemMagnification = 1.15,
    @required this.child,
    @required this.items,
    @required this.onSelectedItemChanged,
    @required this.itemExtent,
    this.backgroundColor = Colors.white,
  })  : assert(child != null),
        assert(onSelectedItemChanged != null),
        assert(itemExtent != null),
        super(key: key);

  @override
  _DirectSelectState createState() => _DirectSelectState();
}

class _DirectSelectState extends State<DirectSelect> {
  _FixedExtentScrollController _controller;
  GlobalKey _key = GlobalKey();
  int _currentIndex;
  bool _dialogShowing;

  void _createOverlay() async {
    if (mounted) {
      final RenderBox box = _key.currentContext.findRenderObject();
      final position = box.localToGlobal(Offset.zero);
      final mediaQuery = MediaQuery.of(context);
      final half = mediaQuery.size.height / 2;
      final result = position.dy - mediaQuery.padding.top - half;
      final itemExtent = widget.itemExtent;
      _dialogShowing = true;
      await showGeneralDialog(
        context: context,
        useRootNavigator: true,
        barrierDismissible: false,
        barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
        barrierColor: null, // this ensures that the barrier would be transparent.
        transitionDuration: const Duration(milliseconds: 230),
        transitionBuilder: (buildContext, animation, secondaryAnimation, child) => FadeTransition(
          opacity: CurvedAnimation(
            parent: animation,
            curve: Curves.easeOut,
          ),
          child: child,
        ),
        pageBuilder: (context, animation, secondaryAnimation) => WillPopScope(
          onWillPop: () async {
            _dialogShowing = false;
            _notifySelectedItem();
            return true;
          },
          child: _MySelectionOverlay(
            top: result + itemExtent * widget.itemMagnification,
            backgroundColor: widget.backgroundColor,
            child: _MySelectionList(
              itemExtent: widget.itemExtent,
              itemMagnification: widget.itemMagnification,
              childCount: widget.items != null ? widget.items.length : 0,
              onItemChanged: (index) {
                if (index != null) {
                  _currentIndex = index;
                }
              },
              onItemSelected: () {
                if (widget.mode == DirectSelectMode.tap) {
                  _removeOverlay();
                }
              },
              builder: (context, index) {
                if (widget.items != null) {
                  return widget.items[index];
                }
                return const SizedBox.shrink();
              },
              controller: _controller,
            ),
          ),
        ),
      );
    }
  }

  void _notifySelectedItem() {
    widget.onSelectedItemChanged(_currentIndex);
  }

  Future<void> _removeOverlay() async {
    if (mounted) {
      final navigator = Navigator.of(context);
      if (_dialogShowing && navigator != null) {
        if (!await navigator.maybePop()) {
          _notifySelectedItem();
        }
      } else {
        _notifySelectedItem();
      }
      _dialogShowing = false;
    }
  }

  @override
  void didUpdateWidget(DirectSelect oldWidget) {
    if (widget.selectedIndex != oldWidget.selectedIndex) {
      _currentIndex = widget.selectedIndex;
      _controller.dispose();
      _controller = _FixedExtentScrollController(widget.selectedIndex);
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  void initState() {
    _currentIndex = widget.selectedIndex ?? 0;
    _controller = _FixedExtentScrollController(widget.selectedIndex);
    _dialogShowing = false;
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final preferTapMode = widget.mode == DirectSelectMode.tap;
    return GestureDetector(
      onTap: preferTapMode ? _createOverlay : null,
      onVerticalDragStart: preferTapMode ? null : (_) => _createOverlay(),
      onVerticalDragEnd: preferTapMode ? null : (_) => _removeOverlay(),
      onVerticalDragUpdate: preferTapMode
          ? null
          : (details) => _controller.hasScrollPositions
              ? _controller.jumpTo(_controller.offset - details.primaryDelta)
              : null,
      child: Container(
        key: _key,
        child: widget.child,
      ),
    );
  }
}
