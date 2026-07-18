import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:park_ui/park_ui.dart';

// ---------------------------------------------------------------------------
// Test helpers
// ---------------------------------------------------------------------------

/// A failing [ImageProvider] that always throws during load.
///
/// This triggers the [Image.errorBuilder] synchronously so tests can verify
/// error / placeholder UI without any real I/O or image codec.
class _FailingImageProvider extends ImageProvider<_FailingImageProvider> {
  const _FailingImageProvider();

  @override
  Future<_FailingImageProvider> obtainKey(ImageConfiguration configuration) {
    return Future<_FailingImageProvider>.value(this);
  }

  @override
  void resolveStreamForKey(
    ImageConfiguration configuration,
    ImageStream stream,
    _FailingImageProvider key,
    ImageErrorListener handleError,
  ) {
    // Immediately report an error so the Image widget's errorBuilder fires.
    handleError(
      StateError('test image intentionally fails to load'),
      StackTrace.current,
    );
  }
}

/// A widget that pushes [child] onto the [Navigator] when first mounted.
/// Must be placed below [MaterialApp] so its context includes a [Navigator].
class _PushOnMount extends StatefulWidget {
  final Widget child;
  const _PushOnMount({required this.child});

  @override
  State<_PushOnMount> createState() => _PushOnMountState();
}

class _PushOnMountState extends State<_PushOnMount> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        Navigator.of(context).push(
          MaterialPageRoute<void>(builder: (_) => widget.child),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) => const Scaffold(body: SizedBox.shrink());
}

Widget _buildApp(Widget viewer) {
  return MaterialApp(
    theme: ThemeData(extensions: [ParkThemeData.light()]),
    builder: (ctx, child) => ParkLocalizationsWidget(
      localizations: const ParkLocalizationsZh(),
      child: child!,
    ),
    home: _PushOnMount(child: viewer),
  );
}

/// Convenience: a viewer with a single failing test image and default settings.
Widget _singleViewer({
  bool showToolbar = true,
  bool doubleTapZoom = true,
  bool swipeToDismiss = true,
  bool showIndex = true,
  VoidCallback? onTap,
  VoidCallback? onLongPress,
  Widget Function(BuildContext, Object, StackTrace?)? errorBuilder,
}) {
  return ParkImageViewer(
    images: const [_FailingImageProvider()],
    showToolbar: showToolbar,
    doubleTapZoom: doubleTapZoom,
    swipeToDismiss: swipeToDismiss,
    showIndex: showIndex,
    onTap: onTap,
    onLongPress: onLongPress,
    errorBuilder: errorBuilder,
  );
}

/// Three failing images for multi-page tests.
const List<ImageProvider> _threeImages = [
  _FailingImageProvider(),
  _FailingImageProvider(),
  _FailingImageProvider(),
];

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  group('ParkImageViewer', () {
    // 1. Basic rendering -------------------------------------------------------
    testWidgets('creates without error', (tester) async {
      await tester.pumpWidget(_buildApp(_singleViewer()));
      await tester.pumpAndSettle();

      expect(find.byType(ParkImageViewer), findsOneWidget);
    });

    // 2. InteractiveViewer present (zoom capability) ---------------------------
    testWidgets('renders image inside InteractiveViewer', (tester) async {
      await tester.pumpWidget(_buildApp(_singleViewer()));
      await tester.pumpAndSettle();

      expect(find.byType(InteractiveViewer), findsOneWidget);
    });

    // 3. Page indicator visible with multiple images ---------------------------
    testWidgets('shows page indicator "1 / 3" with multiple images',
        (tester) async {
      await tester.pumpWidget(_buildApp(
        ParkImageViewer(images: _threeImages),
      ));
      await tester.pumpAndSettle();

      expect(find.text('1 / 3'), findsOneWidget);
    });

    // 4. Page indicator hidden for single image --------------------------------
    testWidgets('hides page indicator for single image', (tester) async {
      await tester.pumpWidget(_buildApp(_singleViewer()));
      await tester.pumpAndSettle();

      expect(find.textContaining(RegExp(r'\d+\s*/\s*\d+')), findsNothing);
    });

    // 5. initialIndex sets the starting page -----------------------------------
    testWidgets('respects initialIndex for page indicator', (tester) async {
      await tester.pumpWidget(_buildApp(
        ParkImageViewer(images: _threeImages, initialIndex: 1),
      ));
      await tester.pumpAndSettle();

      expect(find.text('2 / 3'), findsOneWidget);
    });

    // 6. Close button triggers Navigator.pop -----------------------------------
    testWidgets('close button pops the route', (tester) async {
      await tester.pumpWidget(_buildApp(_singleViewer()));
      await tester.pumpAndSettle();

      expect(find.byType(ParkImageViewer), findsOneWidget);

      // Tap the close icon in the top-left corner.
      await tester.tap(find.byIcon(Icons.close));
      await tester.pumpAndSettle();

      expect(find.byType(ParkImageViewer), findsNothing);
    });

    // 7. Static show() method pushes ParkImageViewer onto Navigator ----------
    testWidgets('static show() pushes viewer onto Navigator', (tester) async {
      // Pump a minimal app; use a Builder to get a context below MaterialApp.
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(extensions: [ParkThemeData.light()]),
          builder: (ctx, child) => ParkLocalizationsWidget(
            localizations: const ParkLocalizationsZh(),
            child: child!,
          ),
          home: Builder(
            builder: (context) => Scaffold(
              body: Center(
                child: ElevatedButton(
                  onPressed: () {
                    ParkImageViewer.show(
                      context,
                      images: const [_FailingImageProvider()],
                    );
                  },
                  child: const Text('Open'),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Before tapping the button, ParkImageViewer should not be present.
      expect(find.byType(ParkImageViewer), findsNothing);

      // Tap the button to trigger ParkImageViewer.show().
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      // After the route is pushed, ParkImageViewer should be visible.
      expect(find.byType(ParkImageViewer), findsOneWidget);
    });

    // 8. Toolbar visible when showToolbar is true ------------------------------
    testWidgets('shows toolbar buttons when showToolbar is true',
        (tester) async {
      await tester.pumpWidget(_buildApp(_singleViewer(showToolbar: true)));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.zoom_in), findsOneWidget);
      expect(find.byIcon(Icons.zoom_out), findsOneWidget);
      expect(find.byIcon(Icons.rotate_right), findsOneWidget);
    });

    // 9. Toolbar hidden when showToolbar is false ------------------------------
    testWidgets('hides toolbar buttons when showToolbar is false',
        (tester) async {
      await tester.pumpWidget(_buildApp(_singleViewer(showToolbar: false)));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.zoom_in), findsNothing);
      expect(find.byIcon(Icons.zoom_out), findsNothing);
      expect(find.byIcon(Icons.rotate_right), findsNothing);
    });

    // 10. Toolbar zoom-in button is tappable -----------------------------------
    testWidgets('toolbar zoom-in button responds to tap', (tester) async {
      await tester.pumpWidget(_buildApp(_singleViewer(showToolbar: true)));
      await tester.pumpAndSettle();

      // Should not throw; triggers _zoomIn on the TransformationController.
      await tester.tap(find.byIcon(Icons.zoom_in));
      await tester.pump();

      expect(find.byIcon(Icons.zoom_in), findsOneWidget);
    });

    // 11. Toolbar rotate button is tappable ------------------------------------
    testWidgets('toolbar rotate button responds to tap', (tester) async {
      await tester.pumpWidget(_buildApp(_singleViewer(showToolbar: true)));
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.rotate_right));
      await tester.pump();

      expect(find.byIcon(Icons.rotate_right), findsOneWidget);
    });

    // 12. Double-tap zoom disabled ---------------------------------------------
    testWidgets('still renders when doubleTapZoom is false', (tester) async {
      await tester.pumpWidget(
          _buildApp(_singleViewer(doubleTapZoom: false)));
      await tester.pumpAndSettle();

      expect(find.byType(ParkImageViewer), findsOneWidget);
      expect(find.byType(InteractiveViewer), findsOneWidget);
    });

    // 13. Long press callback --------------------------------------------------
    testWidgets('onLongPress is forwarded to GestureDetector', (tester) async {
      bool longPressed = false;
      await tester.pumpWidget(_buildApp(
          _singleViewer(onLongPress: () => longPressed = true)));
      await tester.pumpAndSettle();

      // Long-press on the InteractiveViewer which sits inside the PageView-item
      // GestureDetector that owns the onLongPress callback.
      await tester.longPress(find.byType(InteractiveViewer));
      await tester.pump();

      expect(longPressed, isTrue);
    });

    // 14. Custom errorBuilder --------------------------------------------------
    testWidgets('custom errorBuilder renders on image load failure',
        (tester) async {
      await tester.pumpWidget(_buildApp(
        _singleViewer(
          errorBuilder: (context, error, stack) =>
              const Text('CUSTOM_ERROR'),
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.text('CUSTOM_ERROR'), findsOneWidget);
    });

    // 15. Default error builder shows broken_image icon ------------------------
    testWidgets('default error builder shows broken_image icon',
        (tester) async {
      await tester.pumpWidget(_buildApp(_singleViewer()));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.broken_image_outlined), findsOneWidget);
    });

    // 16. swipeToDismiss:true wraps Scaffold in GestureDetector ----------------
    testWidgets('swipeToDismiss:true adds outer GestureDetector',
        (tester) async {
      await tester.pumpWidget(
          _buildApp(_singleViewer(swipeToDismiss: true)));
      await tester.pumpAndSettle();

      // The outer GestureDetector (for vertical-drag-dismiss) is an ancestor
      // of the Scaffold.
      final ancestors = find
          .ancestor(
            of: find.byType(Scaffold),
            matching: find.byType(GestureDetector),
          )
          .evaluate();

      expect(ancestors, isNotEmpty,
          reason: 'swipeToDismiss:true should wrap Scaffold in GestureDetector');
    });

    // 17. swipeToDismiss:false does NOT add outer GestureDetector --------------
    testWidgets('swipeToDismiss:false has no outer GestureDetector',
        (tester) async {
      await tester.pumpWidget(
          _buildApp(_singleViewer(swipeToDismiss: false)));
      await tester.pumpAndSettle();

      // When swipeToDismiss is false the Scaffold is the outermost widget
      // returned by ParkImageViewer — no GestureDetector ancestor should exist
      // between Scaffold and the ParkImageViewer itself.
      final gestureAncestors = find
          .ancestor(
            of: find.byType(Scaffold),
            matching: find.byType(GestureDetector),
          )
          .evaluate();

      expect(gestureAncestors, isEmpty,
          reason: 'swipeToDismiss:false should not wrap Scaffold');
    });

    // 18. showIndex:false hides indicator even with multiple images ------------
    testWidgets('showIndex:false hides page indicator', (tester) async {
      await tester.pumpWidget(_buildApp(
        ParkImageViewer(images: _threeImages, showIndex: false),
      ));
      await tester.pumpAndSettle();

      expect(find.textContaining(RegExp(r'\d+\s*/\s*\d+')), findsNothing);
    });

    // 19. Toolbar flip buttons are present -------------------------------------
    testWidgets('toolbar contains flip horizontal and vertical buttons',
        (tester) async {
      await tester.pumpWidget(_buildApp(_singleViewer(showToolbar: true)));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.flip), findsOneWidget);
      expect(find.byIcon(Icons.flip_to_front), findsOneWidget);
    });

    // 20. PageView is used for horizontal swiping ------------------------------
    testWidgets('uses PageView for horizontal image swiping', (tester) async {
      await tester.pumpWidget(_buildApp(
        ParkImageViewer(images: _threeImages),
      ));
      await tester.pumpAndSettle();

      expect(find.byType(PageView), findsOneWidget);
    });
  });
}
