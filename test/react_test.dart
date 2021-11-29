import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_love/flutter_love.dart';
import 'package:flutter/widgets.dart';

String eventText = '';
final states = <String>[];

void main() {

  tearDown(() {
    states.clear();
  });

  group('ReactState', () {
    testWidgets('initial state', (tester) async {

      final system = createSystem();

      await tester.pumpWidget(ReactState<String, String>(
        system: system,
        builder: (context, state, dispatch) {
          states.add(state);
          return builder(context, text: state);
        },
      ));

      expect(states, ['a']);
      expect(find.text('a'), findsOneWidget);
    });

    testWidgets('state updates', (tester) async {

      final system = createSystem();

      await tester.pumpWidget(ReactState<String, String>(
        system: system,
        builder: (context, state, dispatch) {
          states.add(state);
          return builder(context, text: state, onTap: () => dispatch(eventText));
        },
      ));

      expect(states, ['a']);
      expect(find.text('a'), findsOneWidget); 

      await tester.dispatchText('b');
      await tester.pump();

      expect(states, [
        'a',
        'a|b',
      ]);
      expect(find.text('a|b'), findsOneWidget);
    });

    testWidgets('system dispose', (tester) async {

      int disposeInvoked = 0;

      final system = createSystem()
        .onDispose(run: () => disposeInvoked += 1);

      await tester.pumpWidget(ReactState<String, String>(
        system: system,
        builder: (context, state, dispatch) {
          states.add(state);
          return builder(context, text: state, onTap: () => dispatch(eventText));
        },
      ));

      expect(states, ['a']);
      expect(disposeInvoked, 0);
      
      await tester.pumpWidget(Container());

      expect(states, ['a']);
      expect(disposeInvoked, 1);
    });

    testWidgets('system replacement', (tester) async {

      int runInvokedA = 0;
      int disposeInvokedA = 0;
      int runInvokedB = 0;
      int disposeInvokedB = 0;

      final systemA = System<String, String>.create(
        initialState: 'a',
      ).add(reduce: (state, event) => '$state|$event')
      .onRun(effect: (_, __) { runInvokedA += 1; })
      .onDispose(run: () { disposeInvokedA += 1; });

      final systemB = System<String, String>.create(
        initialState: 'b'
      ).add(reduce: (state, event) => '$state-$event')
      .onRun(effect: (_, __) { runInvokedB += 1; })
      .onDispose(run: () { disposeInvokedB += 1; });

      final key = GlobalKey();

      await tester.pumpWidget(ReactState<String, String>(
        key: key,
        system: systemA,
        builder: (context, state, dispatch) {
          states.add(state);
          return builder(context, text: state, onTap: () => dispatch(eventText));
        },
      ));

      expect(runInvokedA, 1);
      expect(disposeInvokedA, 0);
      expect(runInvokedB, 0);
      expect(disposeInvokedB, 0);
      expect(states, [
        'a',
      ]);
      expect(find.text('a'), findsOneWidget);

      await tester.pumpWidget(ReactState<String, String>(
        key: key,
        system: systemB, // replace system
        builder: (context, state, dispatch) {
          states.add(state);
          return builder(context, text: state, onTap: () => dispatch(eventText));
        },
      ));

      expect(runInvokedA, 1);
      expect(disposeInvokedA, 1);
      expect(runInvokedB, 1);
      expect(disposeInvokedB, 0);
      expect(states, [
        'a',
        'b',
      ]);
      expect(find.text('b'), findsOneWidget);

      await tester.dispatchText('c');
      await tester.pump();

      expect(runInvokedA, 1);
      expect(disposeInvokedA, 1);
      expect(runInvokedB, 1);
      expect(disposeInvokedB, 0);
      expect(states, [
        'a',
        'b',
        'b-c',
      ]);
      expect(find.text('b-c'), findsOneWidget);

    });


    testWidgets('default state equals', (tester) async {

      final system = System<String, String>
        .create(initialState: 'a')
        .add(reduce: (state, event) => event);

      await tester.pumpWidget(ReactState<String, String>(
        system: system,
        builder: (context, state, dispatch) {
          states.add(state);
          return builder(context, text: state, onTap: () => dispatch(eventText));
        },
      ));

      expect(states, [
        'a'
      ]);
      expect(find.text('a'), findsOneWidget);

      await tester.dispatchText('a');
      await tester.pump();

      expect(states, [
        'a',
      ]);
      expect(find.text('a'), findsOneWidget);

      await tester.dispatchText('b');
      await tester.pump();

      expect(states, [
        'a',
        'b',
      ]);
      expect(find.text('b'), findsOneWidget);

    });
    testWidgets('custom state equals', (tester) async {});

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

    // testWidgets('track states', (tester) async {

    //   final system = createSystem();

    //   await tester.pumpWidget(ReactState<String, String>(
    //     system: system,
    //     builder: (context, state, dispatch) {
    //       states.add(state);
    //       return builder(context, state, () => dispatch(eventText));
    //     },
    //   ));

    //   expect(states, [
    //     'a'
    //   ]);
    //   expect(find.text('a'), findsOneWidget);

    //   await tester.dispatchText('b');
    //   await tester.pump();
    //   expect(states, [
    //     'a',
    //     'a|b',
    //   ]);
    //   expect(find.text('a|b'), findsOneWidget);

    // });

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

System<String, String> createSystem() 
  => System<String, String>.create(
    initialState: 'a',
  ).add(reduce: reduce);

String reduce(String state, String event)
  => '$state|$event';

Widget builder(
  BuildContext context, {
  required String text, 
  VoidCallback? onTap
}) => GestureDetector(
  onTap: onTap,
  child: Text(text, textDirection: TextDirection.ltr),
);

extension on WidgetTester {

  Future<void> dispatchText(String text) async {
    eventText = text;
    await tap(find.byType(Text));
  }
}