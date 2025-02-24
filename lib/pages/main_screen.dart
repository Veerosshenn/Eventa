import 'bought_ticket_screen.dart';
import 'consts.dart';
import 'home_screen.dart';
import 'profile_screen.dart';
import 'waitlist_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  List<IconData> bottomIcons = [
    Icons.home_filled,
    CupertinoIcons.compass_fill,
    CupertinoIcons.ticket_fill,
    Icons.person_rounded
  ];

  int currentIndex = 0;
  late final List<Widget> page;
  @override
  void initState() {
    page = [
      const HomeScreen(),
      WaitlistScreen(),
      BoughtTicketScreen(),
      ProfileScreen(),
    ];
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appBackgroundColor,
      bottomNavigationBar: SizedBox(
          height: 100,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(
                bottomIcons.length,
                (index) => GestureDetector(
                      onTap: () {
                        setState(() {
                          currentIndex = index;
                        });
                      },
                      child: Stack(
                        children: [
                          AnimatedContainer(
                            duration: Duration(microseconds: 300),
                            height: currentIndex == index ? 25 : 0,
                            width: currentIndex == index ? 25 : 0,
                            decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                      color: Colors.white.withOpacity(0.1),
                                      spreadRadius:
                                          currentIndex == index ? 10 : 0,
                                      blurRadius:
                                          currentIndex == index ? 15 : 0)
                                ]),
                          ),
                          Icon(
                            bottomIcons[index],
                            color: currentIndex == index
                                ? Colors.white
                                : Colors.white.withOpacity(0.3),
                          )
                        ],
                      ),
                    )),
          )),
      body: page[currentIndex],
    );
  }

  navBarPage(iconName) {
    return Center(
      child: Icon(
        iconName,
        size: 100,
        color: Colors.white,
      ),
    );
  }
}
