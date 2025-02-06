import 'package:flutter/material.dart';


class RecentLessonsHomepage extends StatelessWidget {
  const RecentLessonsHomepage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
        children: [
          Padding(
            padding: EdgeInsets.only(bottom: 6.0),
            child: Align(
              alignment: Alignment.centerLeft,
                child: Text(
                "Recent Lessons",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 25)
            )),
          ),
          RecentLessonTile(),
          RecentLessonTile(),
          RecentLessonTile(),
          RecentLessonTile(),
          RecentLessonTile(),
          RecentLessonTile(),
          RecentLessonTile()
        ]
    );
  }
}



class RecentLessonTile extends StatelessWidget {
  const RecentLessonTile({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 6.0),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          foregroundColor: Colors.black,
          backgroundColor: Color(0xFFE6FFEA),
          padding: EdgeInsets.symmetric(vertical: 12, horizontal: 20),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 5,
          shadowColor: Colors.black.withOpacity(0.2),
        ),
        onPressed: () => {},
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 3.0, horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    "assets/streak_homepage_design.png",
                    width: MediaQuery.sizeOf(context).width * 0.125,
                  ),
                  const Padding(
                    padding: EdgeInsets.only(left: 20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Lesson Name",
                          style: TextStyle(
                            fontSize: 20,
                            color: Color(0xFF000000),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          "2nd Grade Math",
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              Icon(Icons.play_arrow_sharp)
            ],
          ),
        ),
      ),
    );
  }
}
