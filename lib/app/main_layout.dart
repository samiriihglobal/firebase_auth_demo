import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class MainLayout extends StatefulWidget {
  final Widget child;
  final String userName;
  final String profileUrl;

  const MainLayout({
    super.key,
    required this.child,
    required this.userName,
    required this.profileUrl,
  });

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  DateTime timeBackPressed = DateTime.now();


  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        final difference = DateTime.now().difference(timeBackPressed);
        bool isExitWarning = difference >= const Duration(seconds: 2);
        timeBackPressed = DateTime.now();

        if (isExitWarning) {
          // Fluttertoast.showToast(
          //   msg: "Press back again to Exit!",
          //   fontSize: 18,
          // );
          return false;
        } else {
          // Fluttertoast.cancel();
          return true;
        }
      },
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        drawer: Drawer(
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              DrawerHeader(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CircleAvatar(
                      radius: 36,
                      backgroundImage: NetworkImage(widget.profileUrl),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      widget.userName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      "samir@example.com", // you can fetch from user model
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              ListTile(
                leading: const Icon(Icons.settings),
                title: const Text("Settings"),
                onTap: () {
                  Navigator.pop(context);
                  // context.go('/settings'); // navigate to settings
                },
              ),
              ListTile(
                leading: const Icon(Icons.logout),
                title: const Text("Logout"),
                onTap: () {
                  Navigator.pop(context);
                  // call your logout method
                },
              ),
            ],
          ),
        ),
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// Header
              Container(
                color: Theme.of(context).cardColor,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 20, 16, 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: Text(
                          "Welcome back,\n${widget.userName} 👋",
                          style: Theme.of(context)
                              .textTheme
                              .headlineSmall
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                      ),
                      Builder(
                        builder: (context) => InkWell(
                          onTap: () {
                            print("opening drawer");
                            Scaffold.of(context).openDrawer();
                          },
                          child: CircleAvatar(
                            radius: 28,
                            backgroundImage: NetworkImage(widget.profileUrl),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              Expanded(child: widget.child),
            ],
          ),
        ),
        bottomNavigationBar: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.transparent,
          elevation: 0,
          selectedFontSize: 12,
          unselectedFontSize: 12,
          selectedItemColor: Theme.of(context).colorScheme.primary,
          unselectedItemColor: Colors.grey,
          currentIndex: 0,
          onTap: (index) {
            switch (index) {
              case 0:
                // context.go('/home');
                break;
              case 1:
                // context.go('/rubik');
                break;
              case 2:
                // context.go('/timer');
                break;
              case 3:
                // context.go('/lessonlist');
                break;
              case 4:
                // context.go('/algorithm');
                break;
            }
          },
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
            BottomNavigationBarItem(icon: Icon(CupertinoIcons.cube), label: 'Play Cube'),
            BottomNavigationBarItem(icon: Icon(Icons.timer), label: 'Timer'),
            BottomNavigationBarItem(icon: Icon(Icons.menu_book), label: 'Lessons'),
            BottomNavigationBarItem(icon: Icon(Icons.functions), label: 'Algorithms'),
          ],
        ),
      ),
    );
  }
}
