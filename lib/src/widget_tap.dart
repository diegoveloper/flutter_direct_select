part of direct_select_plugin;

class _DirectSelectTap extends _DirectSelectBase {
  const _DirectSelectTap({
    Widget? child,
    List<Widget>? items,
    ValueChanged<int?>? onSelectedItemChanged,
    double? itemExtent,
    double? itemMagnification,
    int? selectedIndex,
    DirectSelectMode? mode,
    Color? backgroundColor,
    Color? selectionColor,
    Key? key,
  }) : super(
          selectedIndex: selectedIndex,
          mode: mode,
          itemMagnification: itemMagnification,
          items: items,
          onSelectedItemChanged: onSelectedItemChanged,
          itemExtent: itemExtent,
          backgroundColor: backgroundColor,
          selectionColor: selectionColor,
          child: child,
          key: key,
        );

  @override
  _DirectSelectTapState createState() => _DirectSelectTapState();
}

class _DirectSelectTapState extends _DirectSelectBaseState<_DirectSelectTap> {
  late bool _dialogShowing;

  @override
  Future<void> _createOverlay() async {
    if (mounted) {
      _dialogShowing = true;
      await showGeneralDialog(
        context: context,
        useRootNavigator: true,
        barrierDismissible: false,
        barrierLabel:
            MaterialLocalizations.of(context).modalBarrierDismissLabel,
        barrierColor: Colors
            .transparent, // this ensures that the barrier would be transparent.
        transitionDuration: const Duration(milliseconds: 230),
        transitionBuilder:
            (buildContext, animation, secondaryAnimation, child) =>
                FadeTransition(
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
          child: _overlayWidget(),
        ),
      );
    }
  }

  @override
  Future<void> _removeOverlay() async {
    if (mounted) {
      final navigator = Navigator.of(context);
      if (_dialogShowing) {
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
  void initState() {
    _dialogShowing = false;
    super.initState();
  }
}
