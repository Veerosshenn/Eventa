import 'package:assignment1/pages/create_event.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import './create_event_test.mocks.dart'; // Generated using build_runner

@GenerateMocks([
  FirebaseFirestore,
  FirebaseStorage,
  Reference,
  UploadTask,
  TaskSnapshot,
  DocumentReference,
  CollectionReference,
])

void main() {
  late MockFirebaseFirestore mockFirestore;
  late MockFirebaseStorage mockStorage;
  late MockCollectionReference<Map<String, dynamic>> mockCollection;
  late MockDocumentReference<Map<String, dynamic>> mockDoc;
  late MockReference mockRef;
  late MockUploadTask mockUploadTask;
  late MockTaskSnapshot mockSnapshot;

  setUp(() {
    mockFirestore = MockFirebaseFirestore();
    mockStorage = MockFirebaseStorage();
    mockCollection = MockCollectionReference<Map<String, dynamic>>();
    mockDoc = MockDocumentReference<Map<String, dynamic>>();
    mockRef = MockReference();
    mockUploadTask = MockUploadTask();
    mockSnapshot = MockTaskSnapshot();

    // Firestore mocks
    when(mockFirestore.collection('events')).thenReturn(mockCollection);
    when(mockCollection.doc(any)).thenReturn(mockDoc);
    when(mockDoc.set(any)).thenAnswer((_) async {});

    // Firebase Storage mocks
    when(mockStorage.ref(any)).thenAnswer((_) {
      return mockRef;
    });
    when(mockRef.child(any)).thenAnswer(((_) {
      return mockRef;
    }));
    when(mockRef.putData(any)).thenAnswer(((_) {
      return mockUploadTask;
    }));

    // Mocking the upload task completion
    when(mockUploadTask.then(any)).thenAnswer((invocation) async {
      final onValue = invocation.positionalArguments[0] as dynamic Function(TaskSnapshot);
      return onValue(mockSnapshot);
    });

    when(mockUploadTask.whenComplete(any)).thenAnswer((invocation) async {
      await Function.apply(invocation.positionalArguments[0], []);
      return mockSnapshot;
    });

    // Mock download URL
    when(mockSnapshot.ref).thenReturn(mockRef);
    when(mockRef.getDownloadURL()).thenAnswer((_) async => 'https://fakeurl.com/poster.png');
  });

  testWidgets('CreateEventScreen creates event when form is valid', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: CreateEventScreen(userId: 'testUser', firestore: mockFirestore, storage: mockStorage),
      ),
    );

    await tester.enterText(find.byKey(Key('event_name_field')), 'Test Event');
    await tester.enterText(find.byKey(Key('event_date_field')), '2025-04-21');
    await tester.enterText(find.byKey(Key('event_start_time_field')), '10:00 AM');
    await tester.enterText(find.byKey(Key('event_end_time_field')), '12:00 PM');
    await tester.enterText(find.byKey(Key('event_location_field')), 'Auditorium');
    await tester.enterText(find.byKey(Key('event_description_field')), 'A cool event');

    final buttonFinder = find.byKey(Key('create_event_button'));
    await tester.ensureVisible(buttonFinder);
    await tester.tap(buttonFinder);
    await tester.pumpAndSettle();

    verify(mockFirestore.collection('events')).called(1);
    verify(mockDoc.set(argThat(containsPair('eventName', 'Test Event')))).called(1);
  });
}
