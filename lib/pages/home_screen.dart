import 'dart:math';

import 'package:bit301_assignment1/models/event_model.dart';
import 'package:bit301_assignment1/pages/consts.dart';
import 'package:bit301_assignment1/pages/event_detail_screen.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late PageController controller;
  double pageoffSet = 1;
  int currentIndex = 1;
  @override
  void initState() {
    super.initState();
    controller = PageController(
      initialPage: 1,
      viewportFraction: 0.6,
    )..addListener(() {
        setState(() {
          pageoffSet = controller.page!;
        });
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
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    "What's avaliable now",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                const SizedBox(height: 50),
                Expanded(
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      PageView.builder(
                        controller: controller,
                        onPageChanged: (index) {
                          setState(() {
                            currentIndex = index % events.length;
                          });
                        },
                        itemBuilder: (context, index) {
                          double scale = max(
                            0.6,
                            (1 - (pageoffSet - index).abs() + 0.6),
                          );
                          double angle = (controller.position.haveDimensions
                                  ? index.toDouble() - (controller.page ?? 0)
                                  : index.toDouble() - 1) *
                              5;
                          angle = angle.clamp(-5, 5);
                          final event = events[index % events.length];
                          return GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (_) => EventDetailScreen(
                                          event: event,
                                        )),
                              );
                            },
                            child: Padding(
                              padding: EdgeInsets.only(
                                  top: 100 - (scale / 1.6 * 100)),
                              child: Stack(
                                alignment: Alignment.topCenter,
                                children: [
                                  Transform.rotate(
                                    angle: angle * pi / 90,
                                    child: Hero(
                                      tag: event.poster,
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(25),
                                        child: Image.asset(
                                          event.poster,
                                          height: 300,
                                          width: 205,
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
                        top: 330,
                        child: Row(
                          children: List.generate(
                              events.length,
                              (index) => AnimatedContainer(
                                    duration: const Duration(microseconds: 300),
                                    margin: const EdgeInsets.only(right: 15),
                                    width: currentIndex == index ? 30 : 10,
                                    height: 10,
                                    decoration: BoxDecoration(
                                      color: currentIndex == index
                                          ? buttonColor
                                          : Colors.white24,
                                      borderRadius: BorderRadius.circular(15),
                                    ),
                                  )),
                        ),
                      )
                    ],
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }

  Padding searchField() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20),
      child: TextField(
        decoration: InputDecoration(
          contentPadding: EdgeInsets.symmetric(vertical: 19),
          filled: true,
          fillColor: Colors.white.withOpacity(0.05),
          hintText: "Search",
          hintStyle: TextStyle(
            color: Colors.white54,
          ),
          prefixIcon: Icon(
            Icons.search,
            size: 35,
          ),
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(27),
              borderSide: BorderSide.none),
        ),
      ),
    );
  }

  AppBar headerParts() {
    return AppBar(
      backgroundColor: appBackgroundColor,
      title: Padding(
        padding: EdgeInsets.symmetric(horizontal: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 10),
                Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: "Welcome Rosshen,",
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 1,
                          color: Colors.white54,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  "Relax, book your tickets, and enjoy the events!",
                  style: TextStyle(
                    height: 0.6,
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1,
                  ),
                )
              ],
            ),
            Container(
              width: 40,
              height: 45,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  image: const DecorationImage(
                    fit: BoxFit.cover,
                    image: AssetImage("profile_pic.jpg"),
                  )),
            )
          ],
        ),
      ),
    );
  }
}
