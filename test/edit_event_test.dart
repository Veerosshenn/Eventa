import 'dart:io';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:assignment1/pages/edit_event.dart'; // Your EditEventScreen
import './edit_event_test.mocks.dart'; // Generated mocks using build_runner

/// Custom HttpOverrides to mock all network calls (especially for CachedNetworkImage)
class TestHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return _MockHttpClient();
  }
}

/// Mock HttpClient that returns a dummy response
class _MockHttpClient implements HttpClient {
  @override
  Future<HttpClientRequest> getUrl(Uri url) async => _MockHttpClientRequest();

  // Other HttpClient methods can throw UnimplementedError if not needed
  @override
  noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _MockHttpClientRequest implements HttpClientRequest {
  @override
  Future<HttpClientResponse> close() async => _MockHttpClientResponse();

  @override
  noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _MockHttpClientResponse extends Stream<List<int>> implements HttpClientResponse {
  @override
  int get statusCode => HttpStatus.ok;

  @override
  StreamSubscription<List<int>> listen(void Function(List<int>)? onData,
      {Function? onError, void Function()? onDone, bool? cancelOnError}) {
    return const Stream<List<int>>.empty().listen(onData,
        onError: onError, onDone: onDone, cancelOnError: cancelOnError);
  }

  @override
  noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}


@GenerateMocks([
  FirebaseFirestore,
  CollectionReference,
  Query,
  QuerySnapshot,
  QueryDocumentSnapshot,
])

void main() {
  HttpOverrides.global = TestHttpOverrides(); // Set the custom HttpOverrides
  late MockFirebaseFirestore mockFirestore;
  late MockCollectionReference<Map<String, dynamic>> mockCollection;
  late MockQuery<Map<String, dynamic>> mockQuery;
  late MockQuerySnapshot<Map<String, dynamic>> mockSnapshot;
  late MockQueryDocumentSnapshot<Map<String, dynamic>> mockDocument;
  late StreamController<QuerySnapshot<Map<String, dynamic>>> controller;

  setUp(() {
    mockFirestore = MockFirebaseFirestore();
    mockCollection = MockCollectionReference<Map<String, dynamic>>();
    mockQuery = MockQuery<Map<String, dynamic>>();
    mockSnapshot = MockQuerySnapshot<Map<String, dynamic>>();
    mockDocument = MockQueryDocumentSnapshot<Map<String, dynamic>>();
    controller = StreamController<QuerySnapshot<Map<String, dynamic>>>();

    // Firestore setup
    when(mockFirestore.collection('events')).thenReturn(mockCollection);
    when(mockCollection.where('createdBy', isEqualTo: anyNamed('isEqualTo')))
        .thenReturn(mockQuery);
    when(mockQuery.snapshots()).thenAnswer((_) => controller.stream);
    when(mockSnapshot.docs).thenReturn([mockDocument]);

    // Mock event data
    when(mockDocument.data()).thenReturn({
      'eventName': 'Test Event',
      'date': '2025-04-21',
      'startTime': '10:00 AM',
      'posterUrl': 'poster.png',
    });

    when(mockDocument['eventName']).thenReturn('Test Event');
    when(mockDocument['date']).thenReturn('2025-04-21');
    when(mockDocument['startTime']).thenReturn('10:00 AM');
    when(mockDocument['posterUrl']).thenReturn('poster.png');
  });

  tearDown(() {
    controller.close();
  });

  testWidgets('EditEventScreen shows event grid for user', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: EditEventScreen(
          userId: 'mockUserId',
          firestore: mockFirestore,
        ),
      ),
    );

    // Emit the mocked snapshot to simulate Firestore response
    controller.add(mockSnapshot);

    await tester.pump(); // trigger widget build
    await tester.pumpAndSettle(); // wait for animations, stream to complete

    expect(find.text('Test Event'), findsOneWidget);
    expect(find.text('2025-04-21 • 10:00 AM'), findsOneWidget);
  });
}
