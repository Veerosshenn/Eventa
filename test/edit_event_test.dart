import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:assignment1/pages/edit_event.dart'; // Your EditEventScreen
import './edit_event_test.mocks.dart'; // Generated using build_runner

// Generate mocks for all Firestore-related classes
@GenerateMocks([FirebaseFirestore, CollectionReference, Query, QuerySnapshot, QueryDocumentSnapshot])

void main() {
  late MockFirebaseFirestore mockFirestore;
  late MockCollectionReference<Map<String, dynamic>> mockCollection;
  late MockQuery<Map<String, dynamic>> mockQuery;
  late MockQuerySnapshot<Map<String, dynamic>> mockSnapshot;
  late MockQueryDocumentSnapshot<Map<String, dynamic>> mockDocument;

  setUp(() async {
    // Initialize all mocks
    mockFirestore = MockFirebaseFirestore();
    mockCollection = MockCollectionReference<Map<String, dynamic>>();
    mockQuery = MockQuery();
    mockSnapshot = MockQuerySnapshot();
    mockDocument = MockQueryDocumentSnapshot<Map<String, dynamic>>();

    // Mock the Firestore collection call
    when(mockFirestore.collection('events')).thenReturn(mockCollection);

    // Mock the where clause to return a query
    when(mockCollection.where('createdBy', isEqualTo: anyNamed('isEqualTo')))
        .thenReturn(mockQuery);

    // Mock the snapshots stream to return our mock snapshot
    when(mockQuery.snapshots()).thenAnswer((_) => Stream.value(mockSnapshot));

    // Mock the documents in the snapshot
    when(mockSnapshot.docs).thenReturn([mockDocument]);

    // Mock the data of the document for the event
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

  testWidgets('EditEventScreen shows event grid for user', (WidgetTester tester) async {
    // Mock CachedNetworkImage to avoid network call
    final imageOverride = CachedNetworkImage(
      imageUrl: 'poster.png',
      imageBuilder: (context, imageProvider) => Container(), // Use a blank container
      placeholder: (context, url) => const SizedBox(),
      errorWidget: (context, url, error) => const Icon(Icons.error),
    );

    // Wrap the EditEventScreen widget in a MaterialApp
    await tester.pumpWidget(
      MaterialApp(
        home: EditEventScreen(userId: 'mockUserId', firestore: mockFirestore),
      ),
    );

    await tester.pump(Duration(seconds: 2)); // Allow time for the stream to emit

    // Allow the widget tree to settle
    await tester.pumpAndSettle();

    // Verify that the event name, date, and start time are displayed
    expect(find.text('Test Event'), findsOneWidget);
    expect(find.text('2025-04-21 • 10:00 AM'), findsOneWidget);

    // Verify that the event poster is loaded (mocked as a blank container)
    expect(find.byType(CachedNetworkImage), findsOneWidget); // Adjust this check if necessary
  });
}
