import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

enum DirectSelectMode {
  /// The [DirectSelect] is engaged by dragging on it.
  drag,

  /// The [DirectSelect] is engaged by tapping on it.
  tap,
}

class DirectSelect extends StatefulWidget {
  /// Widget child you'll tap to display the Selection List.
  final Widget child;

  /// List of Widgets you'll display after you tap the child.
  final List<Widget> items;

  /// Listener when you select any item from the Selection List.
  final ValueChanged<int> onSelectedItemChanged;

  /// Height of each Item of the Selection List.
  final double itemExtent;

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
  FixedExtentScrollController _controller;
  OverlayEntry _overlayEntry;
  GlobalKey _key = GlobalKey();
  GlobalKey<_MySelectionOverlayState> _keyOverlay = GlobalKey();
  int _currentIndex;

  _createOverlay() async {
    RenderBox box = _key.currentContext.findRenderObject();
    final position = box.localToGlobal(Offset.zero);
    final half = MediaQuery.of(context).size.height / 2;
    final result = -half + position.dy;
    final itemSize = widget.itemExtent;
    OverlayState overlayState = Overlay.of(context);
    _overlayEntry = OverlayEntry(
      builder: (context) => _MySelectionOverlay(
        key: _keyOverlay,
        top: result + itemSize,
        backgroundColor: widget.backgroundColor,
        child: _MySelectionList(
          itemExtent: widget.itemExtent,
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
    );

    overlayState.insert(_overlayEntry);
  }

  _removeOverlay() {
    _keyOverlay.currentState.reverse(_overlayEntry);
    widget.onSelectedItemChanged(_currentIndex);
  }

  @override
  void didUpdateWidget(DirectSelect oldWidget) {
    if (widget.selectedIndex != oldWidget.selectedIndex) {
      _currentIndex = widget.selectedIndex;
      _controller.dispose();
      _controller = FixedExtentScrollController(
        initialItem: widget.selectedIndex,
      );
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  void initState() {
    _currentIndex = widget.selectedIndex ?? 0;
    _controller = FixedExtentScrollController(
      initialItem: widget.selectedIndex,
    );
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
          : (details) => _controller.positions.isNotEmpty
              ? _controller.jumpTo(_controller.offset - details.primaryDelta)
              : null,
      child: Container(
        key: _key,
        child: widget.child,
      ),
    );
  }
}

class _MySelectionOverlay extends StatefulWidget {
  final double top;
  final Widget child;
  final double bottom;
  final Color backgroundColor;
  final Color textColor;

  const _MySelectionOverlay({
    Key key,
    this.top,
    this.bottom,
    this.child,
    this.backgroundColor,
    this.textColor,
  }) : super(key: key);

  @override
  _MySelectionOverlayState createState() {
    return _MySelectionOverlayState();
  }
}

class _MySelectionOverlayState extends State<_MySelectionOverlay>
    with SingleTickerProviderStateMixin {
  AnimationController _controller;

  @override
  void initState() {
    _controller = AnimationController(
      vsync: this,
      lowerBound: 0.0,
      upperBound: 1.0,
      duration: const Duration(milliseconds: 230),
    );
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _controller.forward();
    return FadeTransition(
      opacity: Tween(begin: 0.0, end: 1.0).animate(_controller),
      child: Stack(
        children: <Widget>[
          Positioned.fill(
            child: Container(
              color: widget.backgroundColor,
            ),
          ),
          Positioned(
            top: widget.top,
            left: 0.0,
            right: 0.0,
            bottom: widget.bottom,
            child: ScaleTransition(
              scale: Tween(begin: 1.0, end: 1.12).animate(_controller),
              child: widget.child,
            ),
          ),
        ],
      ),
    );
  }

  void reverse(OverlayEntry overlayEntry) {
    _controller.reverse().whenComplete(() => overlayEntry.remove());
  }
}

class _MySelectionList extends StatelessWidget {
  final FixedExtentScrollController controller;
  final IndexedWidgetBuilder builder;
  final int childCount;
  final ValueChanged<int> onItemChanged;
  final VoidCallback onItemSelected;
  final double itemExtent;

  const _MySelectionList({
    Key key,
    @required this.controller,
    @required this.builder,
    @required this.childCount,
    @required this.onItemChanged,
    @required this.onItemSelected,
    @required this.itemExtent,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.transparency,
      child: Container(
        height: MediaQuery.of(context).size.height,
        child: NotificationListener<ScrollNotification>(
          onNotification: (scrollNotification) {
            if (scrollNotification is ScrollEndNotification) {
              onItemSelected();
            }
            return false;
          },
          child: CupertinoPicker.builder(
            scrollController: controller,
            offAxisFraction: 0.0,
            itemExtent: itemExtent,
            childCount: childCount,
            useMagnifier: true,
            magnification: 1.15,
            diameterRatio: 3.0,
            onSelectedItemChanged: onItemChanged,
            itemBuilder: builder,
          ),
        ),
      ),
    );
  }
}
