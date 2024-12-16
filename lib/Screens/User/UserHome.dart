import 'package:flutter/material.dart';
import 'package:online_book_store/Screens/User/Cart.dart';
import 'package:online_book_store/Screens/User/History.dart';
import 'package:online_book_store/Screens/User/Store.dart';
import 'package:online_book_store/Screens/User/Profile.dart';

class Userhome extends StatefulWidget {
  const Userhome({super.key});

  @override
  State<Userhome> createState() => _UserhomeState();
}

class _UserhomeState extends State<Userhome> {
  bool _isLoading = false;

  int currentindex = 0;

  final List<Widget> _screens = [
    Store(),
    Cart(),
    History(),
    Profile(),
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
              label: "Store",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.add_shopping_cart),
              label: "Shopping Cart",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.history),
              label: "History",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person),
              label: "Profile",
            ),
          ],
        ),
        body: _screens[currentindex],
      ),
    );;
  }
}
