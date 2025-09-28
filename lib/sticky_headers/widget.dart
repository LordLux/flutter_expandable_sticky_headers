// Copyright 2018 Simon Lightfoot. All rights reserved.
// Use of this source code is governed by a the MIT license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';

import './render.dart';

/// Builder called during layout to allow the header's content to be animated or styled based
/// on the amount of stickiness the header has.
///
/// [context] for your build operation.
///
/// [stuckAmount] will have the value of:
/// ```
///   0.0 <= value <= 1.0: about to be stuck
///          0.0 == value: at top
///  -1.0 >= value >= 0.0: past stuck
/// ```
///
typedef StickyHeaderWidgetBuilder = Widget Function(BuildContext context, double stuckAmount, bool isHovering);

/// Builder for the expander shape
typedef ExpanderShapeBuilder = ShapeBorder Function(bool open);

/// Stick Header Widget
///
/// Will layout the [header] above the [content] unless the [overlapHeaders] boolean is set to true.
/// The [header] will remain stuck to the top of its parent [Scrollable] content.
///
/// Place this widget inside a [ListView], [GridView], [CustomScrollView], [SingleChildScrollView] or similar.
///
class StickyHeader extends MultiChildRenderObjectWidget {
  /// Constructs a new [StickyHeader] widget.
  StickyHeader({
    super.key,
    required this.header,
    required this.content,
    this.overlapHeaders = false,
    this.controller,
    this.callback,
  }) : super(children: [content, header]);

  /// Header to be shown at the top of the parent [Scrollable] content.
  final Widget header;

  /// Content to be shown below the header.
  final Widget content;

  /// If true, the header will overlap the Content.
  final bool overlapHeaders;

  /// Optional [ScrollController] that will be used by the widget instead of the default inherited one.
  final ScrollController? controller;

  /// Optional callback with stickiness value. If you think you need this, then you might want to
  /// consider using [StickyHeaderBuilder] instead.
  final RenderStickyHeaderCallback? callback;

  @override
  RenderStickyHeader createRenderObject(BuildContext context) {
    final scrollPosition = controller?.position ?? Scrollable.of(context)!.position;
    return RenderStickyHeader(
      scrollPosition: scrollPosition,
      callback: callback,
      overlapHeaders: overlapHeaders,
    );
  }

  @override
  void updateRenderObject(BuildContext context, RenderStickyHeader renderObject) {
    final scrollPosition = controller?.position ?? Scrollable.of(context).position;
    renderObject
      ..scrollPosition = scrollPosition
      ..callback = callback
      ..overlapHeaders = overlapHeaders;
  }
}

/// Sticky Header Builder Widget.
///
/// The same as [StickyHeader] but instead of supplying a Header view, you supply a [builder] that
/// constructs the header with the appropriate stickyness.
///
/// Place this widget inside a [ListView], [GridView], [CustomScrollView], [SingleChildScrollView] or similar.
///
class StickyHeaderBuilder extends StatefulWidget {
  /// Constructs a new [StickyHeaderBuilder] widget.
  const StickyHeaderBuilder({
    super.key,
    required this.builder,
    required this.content,
    this.overlapHeaders = false,
    this.controller,
  });

  /// Called when the sticky amount changes for the header.
  /// This builder must not return null.
  final StickyHeaderWidgetBuilder builder;

  /// Content to be shown below the header.
  final Widget content;

  /// If true, the header will overlap the Content.
  final bool overlapHeaders;

  /// Optional [ScrollController] that will be used by the widget instead of the default inherited one.
  final ScrollController? controller;

  @override
  State<StickyHeaderBuilder> createState() => _StickyHeaderBuilderState();
}

class _StickyHeaderBuilderState extends State<StickyHeaderBuilder> {
  double? _stuckAmount;

  @override
  Widget build(BuildContext context) {
    return StickyHeader(
      overlapHeaders: widget.overlapHeaders,
      header: LayoutBuilder(builder: (context, _) => widget.builder(context, _stuckAmount ?? 0.0, false)),
      content: widget.content,
      controller: widget.controller,
      callback: (double stuckAmount) {
        if (_stuckAmount != stuckAmount) {
          _stuckAmount = stuckAmount;
          WidgetsBinding.instance.endOfFrame.then((_) {
            if (mounted) setState(() {});
          });
        }
      },
    );
  }
}

/// The expander direction
enum ExpanderDirection {
  /// Whether the [Expander] expands down
  down,

  /// Whether the [Expander] expands up
  up,
}

/// Sticky Header Builder Widget.
///
/// The same as [StickyHeader] but instead of supplying a Header view, you supply a [builder] that
/// constructs the header with the appropriate stickyness.
///
/// Place this widget inside a [ListView], [GridView], [CustomScrollView], [SingleChildScrollView] or similar.
///
class ExpandingStickyHeaderBuilder extends StatefulWidget {
  /// Constructs a new [StickyHeaderBuilder] widget.
  const ExpandingStickyHeaderBuilder({
    super.key,
    this.builder,
    required this.content,
    this.overlapHeaders = false,
    this.controller,
    this.leading,
    this.header,
    this.icon,
    this.trailing,
    this.animationDuration,
    this.animationCurve,
    this.direction = ExpanderDirection.down,
    this.initiallyExpanded = true,
    this.onStateChanged,
    this.enabled = true,
    this.headerBackgroundColor,
    this.headerShape,
    this.contentBackgroundColor,
    this.contentPadding,
    this.contentShape,
  }) : assert((builder == null) != (header == null), 'You must provide either a builder or a header: {builder: ${builder != null ? "<builder>" : "null"}, header: ${header != null ? "<header>" : "null"}}');

  /// Called when the sticky amount changes for the header.
  final StickyHeaderWidgetBuilder? builder;

  /// Content to be shown below the header.
  final Widget content;

  /// If true, the header will overlap the Content.
  final bool overlapHeaders;

  /// Optional [ScrollController] that will be used by the widget instead of the default inherited one.
  final ScrollController? controller;

  /// The leading widget.
  ///
  /// See also:
  ///
  ///  * [Icon], used to display graphic content
  ///  * [RadioButton], used to select an exclusive option from a set of options
  ///  * [Checkbox], used to select or deselect items within a list
  final Widget? leading;

  /// The expander header
  ///
  /// Usually a [Text] widget.
  final Widget? header;

  /// The expander icon.
  ///
  /// If not provided, defaults to a chevron icon down or up, depending on the
  /// [direction].
  final Widget? icon;

  /// The trailing widget.
  ///
  /// It's positioned at the right of [header] and before [icon].
  ///
  /// See also:
  ///
  ///  * [ToggleSwitch], used to toggle a setting between two states
  final Widget? trailing;

  /// The expand-collapse animation duration.
  ///
  /// If null, defaults to [FluentThemeData.fastAnimationDuration]
  final Duration? animationDuration;

  /// The expand-collapse animation curve.
  ///
  /// If null, defaults to [FluentThemeData.animationCurve]
  final Curve? animationCurve;

  /// The expand direction.
  ///
  /// Defaults to [ExpanderDirection.down]
  final ExpanderDirection direction;

  /// Whether the [Expander] is initially expanded.
  ///
  /// Defaults to `false`.
  final bool initiallyExpanded;

  /// A callback called when the current state is changed.
  ///
  /// `true` when open and `false` when closed.
  final ValueChanged<bool>? onStateChanged;

  /// Whether the [Expander] is enabled.
  ///
  /// Defaults to `true`.
  final bool enabled;

  /// The background color of the header.
  final Color? headerBackgroundColor;

  /// The shape of the header.
  ///
  /// Use the `open` property to determine whether the expander is open or not.
  final ExpanderShapeBuilder? headerShape;

  /// The content color of the content.
  final Color? contentBackgroundColor;

  /// The padding of the content.
  final EdgeInsetsGeometry? contentPadding;

  /// The shape of the content
  ///
  /// Use the `open` property to determine whether the expander is open or not.
  final ExpanderShapeBuilder? contentShape;

  @override
  State<ExpandingStickyHeaderBuilder> createState() => _ExpandingStickyHeaderBuilderState();
}

class _ExpandingStickyHeaderBuilderState extends State<ExpandingStickyHeaderBuilder> with SingleTickerProviderStateMixin {
  double? _stuckAmount;

  bool _isHovering = false;

  late bool _isExpanded;
  bool get isExpanded => _isExpanded;
  set isExpanded(bool value) {
    if (_isExpanded != value) _handlePressed();
  }

  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this);
    _isExpanded = PageStorage.of(context).readState(context) as bool? ?? widget.initiallyExpanded;
    if (_isExpanded == true) {
      _controller.value = 1;
    }
  }

  void _handlePressed() {
    if (_isExpanded) {
      _controller.animateTo(
        0.0,
        duration: widget.animationDuration ?? const Duration(milliseconds: 300),
        curve: widget.animationCurve ?? Curves.easeInOut,
      );
      _isExpanded = false;
    } else {
      _controller.animateTo(
        1.0,
        duration: widget.animationDuration ?? const Duration(milliseconds: 300),
        curve: widget.animationCurve ?? Curves.easeInOut,
      );
      _isExpanded = true;
    }
    PageStorage.of(context).writeState(context, _isExpanded);
    widget.onStateChanged?.call(_isExpanded);
    if (mounted) setState(() {});
  }

  bool get _isDown => widget.direction == ExpanderDirection.down;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // HEADER
    Widget header(Widget child) => Container(
          constraints: const BoxConstraints(
            minHeight: 42.0,
          ),
          decoration: ShapeDecoration(
            color: widget.headerBackgroundColor ?? Colors.grey.shade800,
            shape: widget.headerShape?.call(_isExpanded) ??
                RoundedRectangleBorder(
                  side: BorderSide(color: Colors.grey.shade600),
                  borderRadius: BorderRadius.vertical(
                    top: const Radius.circular(6.0),
                    bottom: Radius.circular(_isExpanded ? 0.0 : 6.0),
                  ),
                ),
          ),
          padding: const EdgeInsetsDirectional.only(start: 16.0),
          alignment: AlignmentDirectional.centerStart,
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            if (widget.leading != null)
              Padding(
                padding: const EdgeInsetsDirectional.only(end: 10.0),
                child: widget.leading!,
              ),
            Expanded(child: child),
            if (widget.trailing != null)
              Padding(
                padding: const EdgeInsetsDirectional.only(start: 20.0),
                child: widget.trailing!,
              ),
            Padding(
              padding: EdgeInsetsDirectional.only(
                start: widget.trailing != null ? 8.0 : 20.0,
                end: 8.0,
                top: 8.0,
                bottom: 8.0,
              ),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10.0,
                  vertical: 10.0,
                ),
                decoration: BoxDecoration(
                  color: widget.enabled ? Colors.red : Colors.grey.shade700,
                  borderRadius: BorderRadius.circular(6.0),
                ),
                child: widget.icon ??
                    RotationTransition(
                      turns: Tween<double>(
                        begin: 0,
                        end: 0.5,
                      ).animate(CurvedAnimation(
                        parent: _controller,
                        curve: Interval(
                          0.5,
                          1.0,
                          curve: widget.animationCurve ?? Curves.easeInOut,
                        ),
                      )),
                      child: AnimatedSlide(
                        duration: widget.animationDuration ?? const Duration(milliseconds: 300),
                        curve: Curves.easeInCirc,
                        offset: _isHovering ? const Offset(0, 0.1) : Offset.zero,
                        child: Icon(
                          _isDown ? Icons.expand_more : Icons.expand_less,
                          size: 8.0,
                        ),
                      ),
                    ),
              ),
            ),
          ]),
        );
    final Widget content = SizeTransition(
      sizeFactor: CurvedAnimation(
        curve: Interval(
          0.0,
          0.5,
          curve: widget.animationCurve ?? Curves.easeInOut,
        ),
        parent: _controller,
      ),
      child: Container(
        width: double.infinity,
        padding: widget.contentPadding,
        decoration: ShapeDecoration(
          shape: widget.contentShape?.call(_isExpanded) ??
              RoundedRectangleBorder(
                side: BorderSide(color: Colors.grey.shade600),
                borderRadius: const BorderRadius.vertical(bottom: Radius.circular(6.0)),
              ),
          color: widget.contentBackgroundColor ?? Colors.grey.shade800,
        ),
        child: ExcludeFocus(
          excluding: !_isExpanded,
          child: widget.content,
        ),
      ),
    );

    return StickyHeader(
      overlapHeaders: widget.overlapHeaders,
      header: LayoutBuilder(builder: (context, _) {
        return InkWell(
          onTap: widget.enabled ? _handlePressed : null,
          child: MouseRegion(
            onEnter: (_) => setState(() => _isHovering = true),
            onExit: (_) => setState(() => _isHovering = false),
            child: widget.builder?.call(context, _stuckAmount ?? 0.0, _isHovering) ?? header(widget.header!),
          ),
        );
      }),
      content: content,
      controller: widget.controller,
      callback: (double stuckAmount) {
        if (_stuckAmount != stuckAmount) {
          _stuckAmount = stuckAmount;
          WidgetsBinding.instance.endOfFrame.then((_) {
            if (mounted) setState(() {});
          });
        }
      },
    );
  }
}
