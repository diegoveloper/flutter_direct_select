part of direct_select_plugin;

class _FixedExtentScrollController extends FixedExtentScrollController {
  _FixedExtentScrollController(int initialItem) : super(initialItem: initialItem);

  /// Allow us to access the protected getter [ScrollController.positions].
  bool get hasScrollPositions => positions.isNotEmpty;
}
