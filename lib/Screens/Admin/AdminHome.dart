import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:online_book_store/Screens/Admin/Charts.dart';
import 'package:online_book_store/Screens/Admin/ManageStore.dart';
import 'package:online_book_store/Screens/Admin/Reports.dart';
import 'Feedbacks.dart';

class Adminhome extends StatefulWidget {
  const Adminhome({super.key});

  @override
  State<Adminhome> createState() => _AdminhomeState();
}

class _AdminhomeState extends State<Adminhome> {
  bool _isLoading = false;
  int currentindex = 0;

  final List<Widget> _screens = [
    ManageStore(),
    Reports(),
    Feedbacks(),
    Charts(),
  ];

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        bool shouldExit = await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Confirm Exit'),
            content: const Text('Do you really want to exit?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('Exit'),
              ),
            ],
          ),
        );
        return shouldExit;
      },
      child: _isLoading
          ? const Center(
        child: CircularProgressIndicator(color: Color(0xff12082A)),
      )
          : Scaffold(
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: currentindex,
          onTap: (int index) {
            setState(() {
              currentindex = index;
            });
          },
          selectedItemColor: const Color(0xff8042E1),
          unselectedItemColor: Colors.grey,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.store),
              label: "Manage Store",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.book_rounded),
              label: "Reports",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.feedback_sharp),
              label: "Feedback&Rating",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.waterfall_chart),
              label: "Chart",
            ),
          ],
        ),
        body: _screens[currentindex],
      ),
    );
  }
}
