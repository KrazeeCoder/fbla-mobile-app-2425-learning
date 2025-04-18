import 'package:fbla_mobile_2425_learning_app/pages/navigation_help.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:showcaseview/showcaseview.dart';
import '../coach_marks/showcase_keys.dart';

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
          Showcase(
            key: ShowcaseKeys.helpIconKey,
            title: 'Help',
            description:
                'Use the help button to get help with navigating WorldWise',
            child: TextButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const NavigationHelpPage()),
              ),
              child: const Row(
                children: [
                  Text('Need Help?',
                      style: TextStyle(
                          color: const Color(0xFF8D9A8D),
                          fontSize: 14,
                          fontWeight: FontWeight.bold)),
                  const SizedBox(width: 4),
                  Icon(Icons.help, color: const Color(0xFF8D9A8D), size: 22),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
