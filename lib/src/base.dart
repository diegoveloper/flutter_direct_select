part of direct_select_plugin;

abstract class _DirectSelectBase extends StatefulWidget {
  /// See: [DirectSelect.child]
  final Widget? child;

  /// See: [DirectSelect.items]
  final List<Widget>? items;

  /// See: [DirectSelect.onSelectedItemChanged]
  final ValueChanged<int?>? onSelectedItemChanged;

  /// See: [DirectSelect.itemExtent]
  final double? itemExtent;

  /// See: [DirectSelect.itemMagnification]
  final double? itemMagnification;

  /// See: [DirectSelect.selectedIndex]
  final int? selectedIndex;

  /// See: [DirectSelect.mode]
  final DirectSelectMode? mode;

  /// See: [DirectSelect.backgroundColor]
  final Color? backgroundColor;

  /// See: [DirectSelect.selectionColor]
  final Color? selectionColor;

  const _DirectSelectBase({
    this.child,
    this.items,
    this.onSelectedItemChanged,
    this.itemExtent,
    this.itemMagnification,
    this.selectedIndex,
    this.mode,
    this.backgroundColor,
    this.selectionColor,
    Key? key,
  }) : super(key: key);

  @override
  _DirectSelectBaseState createState();
}

abstract class _DirectSelectBaseState<T extends _DirectSelectBase>
    extends State<T> {
  _FixedExtentScrollController? _controller;
  GlobalKey _key = GlobalKey();
  int? _currentIndex;

  Future<void> _createOverlay();

  Future<void> _removeOverlay();

  @override
  void initState() {
    _currentIndex = widget.selectedIndex;
    _controller = _FixedExtentScrollController(widget.selectedIndex!);
    super.initState();
  }

  @override
  void dispose() {
    _controller!.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(_DirectSelectBase oldWidget) {
    if (widget.selectedIndex != oldWidget.selectedIndex) {
      _currentIndex = widget.selectedIndex;
      _controller!.dispose();
      _controller = _FixedExtentScrollController(widget.selectedIndex!);
    }
    super.didUpdateWidget(oldWidget as T);
  }

  void _notifySelectedItem() {
    widget.onSelectedItemChanged!(_currentIndex);
  }

  Widget _overlayWidget([Key? key]) {
    final RenderBox box = _key.currentContext!.findRenderObject() as RenderBox;
    final position = box.localToGlobal(Offset.zero);
    final mediaQuery = MediaQuery.of(context);
    final half = mediaQuery.size.height / 2;
    final result = position.dy - mediaQuery.padding.top - half;
    return _MySelectionOverlay(
      key: key,
      top: result + widget.itemExtent! * widget.itemMagnification!,
      backgroundColor: widget.backgroundColor,
      child: _MySelectionList(
        itemExtent: widget.itemExtent,
        itemMagnification: widget.itemMagnification,
        childCount: widget.items != null ? widget.items!.length : 0,
        selectionColor: widget.selectionColor,
        onItemChanged: (index) {
          _currentIndex = index;
        },
        onItemSelected: () {
          if (widget.mode == DirectSelectMode.tap) {
            _removeOverlay();
          }
        },
        builder: (context, index) {
          if (widget.items != null) {
            return widget.items![index];
          }
          return const SizedBox.shrink();
        },
        controller: _controller,
      ),
    );
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
          : (details) => _controller!.hasScrollPositions
              ? _controller!.jumpTo(_controller!.offset - details.primaryDelta!)
              : null,
      child: Container(
        key: _key,
        child: widget.child,
      ),
    );
  }
}
