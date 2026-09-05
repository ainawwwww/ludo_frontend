import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ludo_vibe/features/home/models/home_data_model.dart';
import 'package:ludo_vibe/features/home/providers/home_provider.dart';
import 'package:ludo_vibe/features/home/screens/home_screen.dart';

Future<void> _capture(
  WidgetTester tester,
  GlobalKey boundaryKey,
  String name,
) async {
  await tester.pump(const Duration(milliseconds: 300));
  final boundary = tester.renderObject<RenderRepaintBoundary>(
    find.byKey(boundaryKey),
  );
  final image = await boundary.toImage(pixelRatio: 1);
  final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
  final output = Directory('build/home_alignment')..createSync(recursive: true);
  File('${output.path}/$name.png').writeAsBytesSync(
    bytes!.buffer.asUint8List(),
  );
}

Widget _testApp(GlobalKey boundaryKey) {
  return ProviderScope(
    overrides: [
      homeDataProvider.overrideWith(
        (ref) async => HomeDataModel(
          username: 'Ali',
          level: 33,
          coins: 33000,
          diamonds: 33,
          currentLeague: LeagueSummary(name: 'No. 90'),
          globalRank: 1000,
        ),
      ),
    ],
    child: RepaintBoundary(
      key: boundaryKey,
      child: const MaterialApp(
        debugShowCheckedModeBanner: false,
        home: HomeScreen(),
      ),
    ),
  );
}

void main() {
  testWidgets('captures all home game sections at 393x852', (tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(393, 852);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);
    final boundaryKey = GlobalKey();
    await tester.pumpWidget(_testApp(boundaryKey));
    await tester.pump(const Duration(milliseconds: 500));

    expect(tester.getTopLeft(find.byType(PageView)).dy, closeTo(289, 0.01));

    const names = ['ludo', 'domino', 'jackaroo', 'other'];
    for (var index = 0; index < names.length; index++) {
      await _capture(tester, boundaryKey, '393x852_${names[index]}');
      if (index < names.length - 1) {
        await tester.drag(find.byType(PageView), const Offset(-393, 0));
        await tester.pumpAndSettle();
      }
    }

    final container = ProviderScope.containerOf(
      tester.element(find.byType(HomeScreen)),
    );
    expect(container.read(homeProvider).cardPageIndex, 3);
  });

  for (final size in [const Size(360, 780), const Size(430, 932)]) {
    testWidgets('renders responsively at ${size.width}x${size.height}', (
      tester,
    ) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = size;
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.view.resetPhysicalSize);
      final boundaryKey = GlobalKey();
      await tester.pumpWidget(_testApp(boundaryKey));
      await tester.pump(const Duration(milliseconds: 500));

      expect(tester.takeException(), isNull);
      await _capture(
        tester,
        boundaryKey,
        '${size.width.toInt()}x${size.height.toInt()}_ludo',
      );
    });
  }
}
