import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_love/flutter_love.dart';
import 'package:flutter/widgets.dart';

final states = <String>[];
String eventText = '';

// Widget buildRoot({
//   required Widget child
// }) => MediaQuery(
//   data: const MediaQueryData(),
//   child: Directionality(
//     textDirection: TextDirection.ltr,
//     child: child,
//   ),
// );

// Widget builder(
//   BuildContext context, 
//   String text, 
//   Dispatch<String> dispatch
// ) => Column(
//   children: [
//     EditableText(
//       onSubmitted: dispatch,
//       backgroundCursorColor: color, 
//       controller: controller, 
//       cursorColor: color, 
//       focusNode: focusNode,
//       style: textStyle,
//     ),
//     Expanded(child: Text(text),)
//   ],
// );

System<String, String> createSystem() 
  => System<String, String>.create(
    initialState: 'a',
  ).add(reduce: reduce);

String reduce(String state, String event)
  => '$state|$event';


extension on WidgetTester {

  Future<void> dispatchText(String text) async {
    eventText = text;
    await tap(find.byType(Text));
  }
}

Widget builder(
  BuildContext context, 
  String text, 
  VoidCallback onTap
) => GestureDetector(
  onTap: onTap,
  child: Text(text, textDirection: TextDirection.ltr),
);

void main() {

  tearDown(() {
    states.clear();
  });

  group('ReactState', () {

    // testWidgets('handle system replacement', (tester) async {
    //   final key = GlobalKey();
    //   late final Dispatch<String> dispatchA;
    //   late final Dispatch<String> dispatchB;
    //   int disposeInvokedA = 0;
    //   int disposeInvokedB = 0;

    //   final systemA = System<String, String>
    //     .create(initialState: 'a1')
    //     .add(reduce: reduce)
    //     .onRun(effect: (_, dispatch) { dispatchA = dispatch; })
    //     .onDispose(run: () => disposeInvokedA += 1);

    //   final systemB = System<String, String>
    //     .create(initialState: 'b1')
    //     .add(reduce: reduce)
    //     .onRun(effect: (_, dispatch) { dispatchB = dispatch; })
    //     .onDispose(run: () => disposeInvokedB += 1);
      
    //   await tester.pumpWidget(buildRoot(
    //     child: ReactState<String, String>(
    //       key: key,
    //       system: systemA,
    //       builder: (context, state, dispatch) {
    //         states.add(state);
    //         return builder(context, state, () => dispatch(eventText));
    //       },
    //     ),
    //   ));
    //   expect(states, [
    //     'a1',
    //   ]);
    //   expect(find.text('a1'), findsOneWidget);
    //   expect(disposeInvokedA, 0);
    //   expect(disposeInvokedB, 0);

    //   await tester.pumpWidget(buildRoot(
    //     child: ReactState<String, String>(
    //       key: key,
    //       system: systemB,
    //       builder: (context, state, dispatch) {
    //         states.add(state);
    //         return builder(context, state, () => dispatch(eventText));
    //       },
    //     ),
    //   ));
    //   expect(states, [
    //     'a1',
    //     'b1',
    //   ]);
    //   expect(find.text('b1'), findsOneWidget);
    //   expect(disposeInvokedA, 1);
    //   expect(disposeInvokedB, 0);

    //   dispatchA('a2');
    //   dispatchB('b2');
    //   await tester.pump();
    //   expect(states, [
    //     'a1',
    //     'b1',
    //     'b1|b2',
    //   ]);
    //   expect(find.text('b1|b2'), findsOneWidget);
    //   expect(disposeInvokedA, 1);
    //   expect(disposeInvokedB, 0);

    //   await tester.pumpWidget(buildRoot(
    //     child: Container()
    //   ));
    //   expect(states, [
    //     'a1',
    //     'b1',
    //     'b1|b2',
    //   ]);
    //   expect(find.text('b1|b2'), findsNothing);
    //   expect(disposeInvokedA, 1);
    //   expect(disposeInvokedB, 1);
    // });

    testWidgets('track states', (tester) async {

      final system = createSystem();

      await tester.pumpWidget(ReactState<String, String>(
        system: system,
        builder: (context, state, dispatch) {
          states.add(state);
          return builder(context, state, () => dispatch(eventText));
        },
      ));

      expect(states, [
        'a'
      ]);
      expect(find.text('a'), findsOneWidget);

      await tester.dispatchText('b');
      await tester.pump();
      expect(states, [
        'a',
        'a|b',
      ]);
      expect(find.text('a|b'), findsOneWidget);

    });

    // testWidgets('handle default equal', (tester) async {

    //   final system = System<String, String>
    //     .create(initialState: 'a')
    //     .add(reduce: (_, event) => event);

    //   await tester.pumpWidget(buildRoot(
    //     child: ReactState<String, String>(
    //       system: system,
    //       builder: (context, state, dispatch) {
    //         states.add(state);
    //         return builder(context, state, dispatch);
    //       },
    //     )
    //   ));
    //   expect(states, [
    //     'a',
    //   ]);
    //   expect(find.text('a'), findsOneWidget);

    //   await tester.dispatchText('a');
    //   await tester.pump();
    //   expect(states, [
    //     'a'
    //   ]);
    //   expect(find.text('a'), findsOneWidget);

    //   await tester.dispatchText('b');
    //   await tester.pump();
    //   expect(states, [
    //     'a',
    //     'b',
    //   ]);
    //   expect(find.text('b'), findsOneWidget);
    // });

    // testWidgets('handle custom equal', (tester) async {
    //   final system = System<String, String>
    //     .create(initialState: 'a')
    //     .add(reduce: (_, event) => event);

    //   await tester.pumpWidget(buildRoot(
    //     child: ReactState<String, String>(
    //       system: system,
    //       equals: (it1, it2) => it1.length == it2.length,
    //       builder: (context, state, dispatch) {
    //         states.add(state);
    //         return builder(context, state, dispatch);
    //       },
    //     )
    //   ));
    //   expect(states, [
    //     'a'
    //   ]);
    //   expect(find.text('a'), findsOneWidget);

    //   await tester.dispatchText('b');
    //   await tester.pump();
    //   expect(states, [
    //     'a'
    //   ]);
    //   expect(find.text('a'), findsOneWidget);
    
    //   await tester.dispatchText('aa');
    //   await tester.pump();
    //   expect(states, [
    //     'a',
    //     'aa',
    //   ]);
    //   expect(find.text('aa'), findsNWidgets(2));
    // });
  });
}


