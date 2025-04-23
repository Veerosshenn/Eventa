import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';

import 'package:assignment1/pages/register_organizer.dart';

import './register_organizer_test.mocks.dart'; // Generated using build_runner

@GenerateMocks([FirebaseAuth, FirebaseFirestore, UserCredential, User, DocumentReference, CollectionReference])
void main() {
  late MockFirebaseAuth mockAuth;
  late MockFirebaseFirestore mockFirestore;
  late MockUserCredential mockUserCredential;
  late MockUser mockUser;
  late MockCollectionReference<Map<String, dynamic>> mockUsersCollection;
  late MockDocumentReference<Map<String, dynamic>> mockUserDoc;

  setUp(() {
    mockAuth = MockFirebaseAuth();
    mockFirestore = MockFirebaseFirestore();
    mockUserCredential = MockUserCredential();
    mockUser = MockUser();
    mockUsersCollection = MockCollectionReference<Map<String, dynamic>>();
    mockUserDoc = MockDocumentReference<Map<String, dynamic>>();

    when(mockAuth.createUserWithEmailAndPassword(
      email: anyNamed('email'),
      password: anyNamed('password'),
    )).thenAnswer((_) async => mockUserCredential);

    when(mockUserCredential.user).thenReturn(mockUser);
    when(mockUser.uid).thenReturn("testUID");

    when(mockFirestore.collection('users')).thenReturn(mockUsersCollection);
    when(mockUsersCollection.doc(any)).thenReturn(mockUserDoc);
    when(mockUserDoc.set(any)).thenAnswer((_) async => {});
    when(mockAuth.sendPasswordResetEmail(email: anyNamed('email')))
        .thenAnswer((_) async => {});
  });

  testWidgets('Organizer form fills and submits successfully', (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(
      home: RegisterOrganizerScreen(auth: mockAuth, firestore: mockFirestore),
    ));

    // Fill form
    await tester.enterText(find.byType(TextField).at(0), 'John Doe');
    await tester.enterText(find.byType(TextField).at(1), 'john@example.com');
    await tester.enterText(find.byType(TextField).at(2), '1234567890');
    await tester.enterText(find.byType(TextField).at(3), 'Event Co');

    await tester.tap(find.byType(ElevatedButton).first);
    await tester.pump(); // showDialog appears

    // Confirm dialog is shown and tap confirm
    expect(find.text('Confirm Registration'), findsOneWidget);
    await tester.tap(find.widgetWithText(ElevatedButton, 'Confirm'));
    await tester.pumpAndSettle(); // Wait for async actions

    verify(mockAuth.createUserWithEmailAndPassword(
      email: 'john@example.com',
      password: 'temp123',
    )).called(1);

    verify(mockUserDoc.set(any)).called(1);
    verify(mockAuth.sendPasswordResetEmail(email: 'john@example.com')).called(1);
  });
}
