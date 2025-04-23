import 'dart:math';

import 'package:easy_localization/easy_localization.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'event_detail_screen.dart';
import 'consts.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late PageController controller;
  double pageOffset = 1;
  int currentIndex = 1;
  String userName = "User";
  bool isUserNameFetched = false;
  late Stream<List<Map<String, dynamic>>> eventStream;

  @override
  void initState() {
    super.initState();
    controller = PageController(viewportFraction: 0.8)
      ..addListener(() {
        setState(() {
          pageOffset = controller.page ?? 0;
        });
      });

    // Initialize the event stream
    eventStream = fetchEvents();
    fetchUserName();
  }

  Future<void> fetchUserName() async {
    if (!isUserNameFetched) {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();
        setState(() {
          userName = userDoc['name'] ?? "User";
          isUserNameFetched = true;
        });
      }
    }
  }

  Stream<List<Map<String, dynamic>>> fetchEvents() {
    return FirebaseFirestore.instance
        .collection('events')
        .snapshots()
        .map((snapshot) {
      if (snapshot.docs.isEmpty) {
        print("No events found in Firestore.");
      }
      return snapshot.docs.map((doc) => doc.data()).toList();
    });
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appBackgroundColor,
      appBar: headerParts(),
      body: Column(
        children: [
          const SizedBox(height: 35),
          searchField(),
          const SizedBox(height: 40),
          Expanded(
            child: Column(
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    "What's available now".tr(),
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                const SizedBox(height: 50),
                Expanded(
                    child: StreamBuilder<List<Map<String, dynamic>>>(
                  stream: eventStream,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return Center(child: Text("No events available".tr()));
                    }

                    List<Map<String, dynamic>> events = snapshot.data!;

                    return Stack(
                      alignment: Alignment.center,
                      children: [
                        PageView.builder(
                          controller: controller,
                          onPageChanged: (index) {
                            setState(() {
                              currentIndex = index % events.length;
                            });
                          },
                          itemCount: events.length,
                          itemBuilder: (context, index) {
                            double scale =
                                0.6 + (1 - (pageOffset - index).abs()) * 0.4;
                            double angle = (controller.position.haveDimensions
                                    ? index.toDouble() - (controller.page ?? 0)
                                    : index.toDouble() - 1) *
                                5;
                            angle = angle.clamp(-5, 5);

                            final event = events[index];

                            return GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (_) =>
                                          EventDetailScreen(eventData: event)),
                                );
                              },
                              child: Padding(
                                padding: EdgeInsets.only(
                                    top: 70 - (scale / 1.6 * 100)),
                                child: Stack(
                                  alignment: Alignment.topCenter,
                                  children: [
                                    Transform.rotate(
                                      angle: angle * pi / 90,
                                      child: Hero(
                                        tag: event['posterUrl'],
                                        child: ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(25),
                                          child: Image.network(
                                            event['posterUrl'],
                                            height: 325,
                                            width: 225,
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                        Positioned(
                          top: 350,
                          child: Row(
                            children: List.generate(
                              events.length,
                              (index) => AnimatedContainer(
                                duration: const Duration(milliseconds: 300),
                                margin: const EdgeInsets.only(right: 15),
                                width: currentIndex == index ? 30 : 10,
                                height: 10,
                                decoration: BoxDecoration(
                                  color: currentIndex == index
                                      ? buttonColor
                                      : Colors.white24,
                                  borderRadius: BorderRadius.circular(15),
                                ),
                              ),
                            ),
                          ),
                        )
                      ],
                    );
                  },
                ))
              ],
            ),
          )
        ],
      ),
    );
  }

  Padding searchField() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: TextField(
        decoration: InputDecoration(
          contentPadding: const EdgeInsets.symmetric(vertical: 19),
          filled: true,
          fillColor: Colors.white.withOpacity(0.05),
          hintText: "Search".tr(),
          hintStyle: const TextStyle(color: Colors.white54),
          prefixIcon: const Icon(Icons.search, size: 35),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(27),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  AppBar headerParts() {
    return AppBar(
      backgroundColor: appBackgroundColor,
      title: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 5),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 5),
                  isUserNameFetched
                      ? Text(
                          "hello_user".tr(namedArgs: {'userName': userName}),
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            letterSpacing: 1,
                            color: Colors.white54,
                          ),
                        )
                      : const CircularProgressIndicator(),
                  const SizedBox(height: 5),
                  Text(
                    "Relax, book your tickets, and enjoy the events!".tr(),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      height: 1.2,
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
