import 'dart:async';
import 'package:anime_flow/app/localization/app_localizations.dart';
import 'package:anime_flow/core/utils/system_util.dart';
import 'package:material_ui/material_ui.dart';

/// 弹幕输入框
class DanmakuTextField extends StatefulWidget {
  final Color? iconColor;
  final Color? textColor;
  final Color? backgroundColor;
  final bool inputVisible;
  final double? height;
  final bool showCloseButton;

  /// 输入框聚焦或样式弹窗打开时为 true，交互结束时为 false。
  final ValueChanged<bool>? onFocusChange;

  /// 发送文字及样式：类型 1 为滚动、4 为底部、5 为顶部。
  final void Function(String text, int type, Color color)? onSend;

  /// 点击右侧弹幕开关按钮时回调。
  final VoidCallback? onClose;

  const DanmakuTextField({
    super.key,
    this.iconColor,
    this.textColor,
    this.height,
    this.showCloseButton = true,
    this.inputVisible = true,
    this.backgroundColor,
    this.onFocusChange,
    this.onSend,
    this.onClose,
  });

  @override
  State<DanmakuTextField> createState() => _DanmakuTextFieldState();
}

class _DanmakuTextFieldState extends State<DanmakuTextField>
    with SingleTickerProviderStateMixin {
  late final FocusNode focusNode;
  late final TextEditingController textController;
  late final AnimationController inputAnimationController;
  late final Animation<double> inputAnimation;

  static const int sendCooldownSeconds = 5;
  static const Duration closeAnimationDuration = Duration(milliseconds: 220);
  static const double defaultHeight = 36;
  static const double collapsedWidth = 44;

  int sendCooldownRemaining = 0;
  Timer? sendCooldownTimer;
  final MenuController _styleMenuController = MenuController();
  int _selectedType = 1;
  Color _selectedColor = Colors.white;
  bool _styleMenuOpen = false;
  bool _interactionActive = false;

  static const _colors = [
    Colors.white,
    Color(0xFFFF5252),
    Color(0xFFFFD740),
    Color(0xFF69F0AE),
    Color(0xFF18FFFF),
    Color(0xFF448AFF),
    Color(0xFFB388FF),
    Color(0xFFFF80AB),
  ];

  bool get sendLocked => widget.onSend != null && sendCooldownRemaining > 0;

  @override
  void initState() {
    super.initState();
    focusNode = FocusNode();
    focusNode.addListener(handleFocusChange);
    textController = TextEditingController();
    inputAnimationController = AnimationController(
      vsync: this,
      duration: closeAnimationDuration,
      value: widget.inputVisible ? 1 : 0,
    );
    inputAnimation = CurvedAnimation(
      parent: inputAnimationController,
      curve: Curves.easeOutCubic,
      reverseCurve: Curves.easeInCubic,
    );
  }

  @override
  void didUpdateWidget(covariant DanmakuTextField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.inputVisible == oldWidget.inputVisible) return;
    if (widget.inputVisible) {
      inputAnimationController.forward();
    } else {
      _styleMenuController.close();
      inputAnimationController.reverse();
    }
  }

  void handleFocusChange() {
    final active = focusNode.hasFocus || _styleMenuOpen;
    if (_interactionActive == active) return;
    _interactionActive = active;
    widget.onFocusChange?.call(active);
  }

  void handleSend() {
    if (sendLocked) return;
    final text = textController.text.trim();
    if (text.isEmpty) return;
    _styleMenuController.close();
    widget.onSend?.call(text, _selectedType, _selectedColor);
    textController.clear();
    FocusScope.of(context).unfocus();
    if (widget.onSend != null) {
      startSendCooldown();
    }
  }

  void handleClose() {
    _styleMenuController.close();
    FocusScope.of(context).unfocus();
    widget.onClose?.call();
  }

  Widget _buildStyleMenu(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colorScheme = Theme.of(context).colorScheme;
    return MenuAnchor(
      controller: _styleMenuController,
      consumeOutsideTap: true,
      onOpen: () {
        _styleMenuOpen = true;
        handleFocusChange();
      },
      onClose: () {
        if (!mounted) return;
        _styleMenuOpen = false;
        handleFocusChange();
      },
      menuChildren: [
        Padding(
          padding: const EdgeInsets.all(12),
          child: SizedBox(
            width: 280,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l10n.danmakuDisplayType,
                    style: Theme.of(context).textTheme.labelLarge),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  children: [
                    for (final (type, label) in [
                      (1, l10n.scrollingDanmaku),
                      (5, l10n.topDanmaku),
                      (4, l10n.bottomDanmaku),
                    ])
                      ChoiceChip(
                        label: Text(label),
                        selected: _selectedType == type,
                        showCheckmark: false,
                        onSelected: (_) => setState(() => _selectedType = type),
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(l10n.danmakuColor,
                    style: Theme.of(context).textTheme.labelLarge),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final color in _colors)
                      Semantics(
                        button: true,
                        selected: color == _selectedColor,
                        label:
                            '#${color.toARGB32().toRadixString(16).substring(2).toUpperCase()}',
                        child: InkWell(
                          onTap: () => setState(() => _selectedColor = color),
                          borderRadius: BorderRadius.circular(8),
                          child: SizedBox(
                            width: 64,
                            height: 40,
                            child: Center(
                              child: Container(
                                width: 32,
                                height: 32,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: color,
                                  border: Border.all(
                                    color: color == _selectedColor
                                        ? colorScheme.primary
                                        : colorScheme.outline,
                                    width: color == _selectedColor ? 2 : 1,
                                  ),
                                ),
                                child: color == _selectedColor
                                    ? Icon(Icons.check,
                                        size: 18,
                                        color: color.computeLuminance() > 0.5
                                            ? Colors.black
                                            : Colors.white)
                                    : null,
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
      builder: (context, controller, child) => IconButton(
        tooltip: l10n.danmakuStyle,
        constraints: const BoxConstraints.tightFor(width: 36, height: 36),
        padding: EdgeInsets.zero,
        onPressed: () {
          if (controller.isOpen) {
            controller.close();
          } else {
            controller.open();
          }
        },
        icon: Stack(
          clipBehavior: Clip.none,
          children: [
            Icon(Icons.text_format, size: 22, color: widget.iconColor),
            Positioned(
              right: -2,
              bottom: 0,
              child: Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _selectedColor,
                  border: Border.all(color: colorScheme.outline),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void startSendCooldown() {
    sendCooldownTimer?.cancel();
    setState(() {
      sendCooldownRemaining = sendCooldownSeconds;
    });
    sendCooldownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      setState(() {
        sendCooldownRemaining--;
        if (sendCooldownRemaining <= 0) {
          sendCooldownRemaining = 0;
          timer.cancel();
        }
      });
    });
  }

  @override
  void dispose() {
    sendCooldownTimer?.cancel();
    focusNode.removeListener(handleFocusChange);
    focusNode.dispose();
    textController.dispose();
    inputAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkTheme = SystemUtil.isDarkTheme(context);
    return LayoutBuilder(
      builder: (context, constraints) {
        final l10n = AppLocalizations.of(context);
        final maxWidth =
            constraints.hasBoundedWidth ? constraints.maxWidth - 16 : 150.0;
        final closeButtonWidth = widget.showCloseButton ? collapsedWidth : 0.0;
        final inputWidth =
            (maxWidth - closeButtonWidth).clamp(0.0, double.infinity);
        return Align(
          alignment: Alignment.centerRight,
          child: Container(
            height: widget.height ?? defaultHeight,
            decoration: BoxDecoration(
              color: widget.backgroundColor,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: isDarkTheme
                    ? Colors.white.withValues(alpha: 0.3)
                    : Colors.black.withValues(alpha: 0.3),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizeTransition(
                  axis: Axis.horizontal,
                  sizeFactor: inputAnimation,
                  alignment: Alignment.centerRight,
                  child: FadeTransition(
                    opacity: inputAnimation,
                    child: SizedBox(
                      width: inputWidth,
                      child: Row(
                        children: [
                          SizedBox(
                            width: 36,
                            height: 36,
                            child: _buildStyleMenu(context),
                          ),
                          Expanded(
                            child: TextField(
                              focusNode: focusNode,
                              controller: textController,
                              textInputAction: TextInputAction.send,
                              textAlignVertical: TextAlignVertical.center,
                              onSubmitted: (widget.onSend == null || sendLocked)
                                  ? null
                                  : (_) => handleSend(),
                              style: const TextStyle(
                                fontSize: 14,
                                height: 1.0,
                              ),
                              decoration: InputDecoration(
                                hintText: sendLocked
                                    ? l10n.waitToSendDanmaku(
                                        sendCooldownRemaining)
                                    : l10n.sendDanmakuHint,
                                hintStyle: TextStyle(
                                  color: widget.textColor,
                                  fontSize: 14,
                                  height: 1.0,
                                ),
                                border: InputBorder.none,
                                contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 5, vertical: 5),
                                isDense: true,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                if (widget.showCloseButton)
                  IconButton(
                    tooltip: widget.inputVisible
                        ? l10n.turnOffDanmaku
                        : l10n.turnOnDanmaku,
                    constraints: const BoxConstraints.tightFor(
                      width: collapsedWidth,
                      height: 36,
                    ),
                    padding: EdgeInsets.zero,
                    icon: Icon(
                      widget.inputVisible
                          ? Icons.subtitles_outlined
                          : Icons.subtitles_off_outlined,
                      size: 20,
                      color: widget.iconColor,
                    ),
                    onPressed: widget.onClose == null ? null : handleClose,
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}
