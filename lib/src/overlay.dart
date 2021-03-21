part of direct_select_plugin;

class _MySelectionOverlay extends StatefulWidget {
  final double? top;
  final Widget? child;
  final double? bottom;
  final Color? backgroundColor;

  const _MySelectionOverlay({
    Key? key,
    this.top,
    this.bottom,
    this.child,
    this.backgroundColor,
  }) : super(key: key);

  @override
  _MySelectionOverlayState createState() {
    return _MySelectionOverlayState();
  }
}

class _MySelectionOverlayState extends State<_MySelectionOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

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

  void reverse(OverlayEntry? overlayEntry) {
    _controller.reverse().whenComplete(() => overlayEntry!.remove());
  }
}

class _MySelectionList extends StatelessWidget {
  final FixedExtentScrollController? controller;
  final IndexedWidgetBuilder builder;
  final int childCount;
  final ValueChanged<int> onItemChanged;
  final VoidCallback onItemSelected;
  final double? itemExtent;
  final double? itemMagnification;
  final Color? selectionColor;

  const _MySelectionList({
    Key? key,
    required this.controller,
    required this.builder,
    required this.childCount,
    required this.onItemChanged,
    required this.onItemSelected,
    required this.itemExtent,
    required this.itemMagnification,
    required this.selectionColor,
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
            itemExtent: itemExtent!,
            childCount: childCount,
            useMagnifier: true,
            magnification: itemMagnification!,
            diameterRatio: 3.0,
            onSelectedItemChanged: onItemChanged,
            selectionOverlay: CupertinoPickerDefaultSelectionOverlay(background: selectionColor!),
            itemBuilder: builder,
          ),
        ),
      ),
    );
  }
}
