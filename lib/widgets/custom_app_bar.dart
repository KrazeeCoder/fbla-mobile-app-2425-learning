import 'package:fbla_mobile_2425_learning_app/pages/navigation_help.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  const CustomAppBar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: false,
      backgroundColor: Theme.of(context).canvasColor,
      elevation: 0,
      title: Row(
        children: [
          Transform.translate(
            offset: const Offset(0, -1), // Subtle lift
            child: SvgPicture.asset('assets/branding/logo_and_name.svg',
                height: 55),
          ),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () => {},
            color: const Color(0xFF8D9A8D),
          ),
          IconButton(
            icon: const Icon(Icons.help),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => const NavigationHelpPage()),
            ),
            color: const Color(0xFF8D9A8D),
          ),
        ],
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
