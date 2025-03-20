import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  const CustomAppBar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: false,
      backgroundColor: Theme.of(context).canvasColor,
      title: Row(
        children: [
          SvgPicture.asset(
            'assets/branding/logo.svg',
            height: 60,
          ),
          const SizedBox(width: 8),
          SvgPicture.asset(
            'assets/branding/name.svg',
            height: 115
          ),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: ()=>{},
            color: Color(0xFF8D9A8D)
          ),
          IconButton(
            icon: Icon(Icons.help),
            onPressed: () =>{},
            color: Color(0xFF8D9A8D)
          ),
        ],
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
