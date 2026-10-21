import 'package:anime_flow/app/localization/app_localizations.dart';
import 'package:anime_flow/app/localization/app_localizations_delegates.dart';
import 'package:anime_flow/shared/widgets/danmaku_text_field.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

void main() {
  testWidgets('sending defaults to white scrolling danmaku', (tester) async {
    final sent = <(String, int, Color)>[];
    await tester.pumpWidget(_app(
      onSend: (text, type, color) => sent.add((text, type, color)),
    ));

    await tester.enterText(find.byType(TextField), ' hello ');
    await tester.testTextInput.receiveAction(TextInputAction.send);
    await tester.pump();

    expect(sent, [('hello', 1, Colors.white)]);
    expect(tester.widget<TextField>(find.byType(TextField)).controller!.text,
        isEmpty);
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('style selection keeps draft and sends selected type and color',
      (tester) async {
    final sent = <(String, int, Color)>[];
    await tester.pumpWidget(_app(
      onSend: (text, type, color) => sent.add((text, type, color)),
    ));
    await tester.enterText(find.byType(TextField), 'styled comment');
    await tester.tap(find.byTooltip('弹幕样式'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(ChoiceChip, '顶部弹幕'));
    await tester.pump();
    await tester.tap(find.byWidgetPredicate((widget) =>
        widget is Semantics && widget.properties.label == '#FF80AB'));
    await tester.pump();

    expect(tester.widget<TextField>(find.byType(TextField)).controller!.text,
        'styled comment');
    expect(
        tester
            .widget<ChoiceChip>(find.widgetWithText(ChoiceChip, '顶部弹幕'))
            .selected,
        isTrue);
    await tester.tapAt(const Offset(10, 10));
    await tester.pumpAndSettle();
    await tester.tap(find.byType(TextField));
    await tester.testTextInput.receiveAction(TextInputAction.send);
    await tester.pump();

    expect(sent, [('styled comment', 5, const Color(0xFFFF80AB))]);
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('bottom danmaku uses type 4 and popup keeps interaction active',
      (tester) async {
    final active = <bool>[];
    final sent = <(String, int, Color)>[];
    await tester.pumpWidget(_app(
      onSend: (text, type, color) => sent.add((text, type, color)),
      onFocusChange: active.add,
    ));
    await tester.tap(find.byTooltip('弹幕样式'));
    await tester.pumpAndSettle();
    expect(active.last, isTrue);
    await tester.tap(find.widgetWithText(ChoiceChip, '底部弹幕'));
    await tester.pump();
    await tester.tapAt(const Offset(10, 10));
    await tester.pumpAndSettle();
    expect(active.last, isFalse);

    await tester.enterText(find.byType(TextField), 'bottom');
    await tester.testTextInput.receiveAction(TextInputAction.send);
    await tester.pump();
    expect(sent, [('bottom', 4, Colors.white)]);
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('collapsing input dismisses style popup on a narrow screen',
      (tester) async {
    tester.view.physicalSize = const Size(320, 568);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(_app());
    await tester.tap(find.byTooltip('弹幕样式'));
    await tester.pumpAndSettle();
    expect(find.byType(ChoiceChip), findsNWidgets(3));
    expect(tester.takeException(), isNull);

    await tester.pumpWidget(_app(inputVisible: false));
    await tester.pumpAndSettle();
    expect(find.byType(ChoiceChip), findsNothing);
    expect(find.byTooltip('弹幕样式').hitTestable(), findsNothing);
    expect(tester.takeException(), isNull);
  });
}

Widget _app({
  void Function(String, int, Color)? onSend,
  ValueChanged<bool>? onFocusChange,
  bool inputVisible = true,
}) =>
    MaterialApp(
      locale: const Locale.fromSubtags(languageCode: 'zh', scriptCode: 'Hans'),
      localizationsDelegates: appLocalizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(
        body: Center(
          child: SizedBox(
            width: 320,
            child: DanmakuTextField(
              onSend: onSend,
              onFocusChange: onFocusChange,
              inputVisible: inputVisible,
            ),
          ),
        ),
      ),
    );
