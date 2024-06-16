import 'package:bookwise/functions/homepage/books/anime_books.dart';
import 'package:bookwise/functions/homepage/books/zone_books.dart';
import 'package:flutter/material.dart';
//import 'package:bookwise/functions/homepage/repositories/firebasecall.dart';
import 'package:bookwise/common/constants/colors_and_fonts.dart';
//import 'package:bookwise/functions/homepage/notifiers/app_notifier.dart';
import 'package:bookwise/functions/homepage/books/headline.dart';
import 'package:bookwise/functions/homepage/books/adventure_books.dart';
import 'package:bookwise/functions/homepage/books/novel.dart';
import 'package:bookwise/functions/homepage/books/horror.dart';
import 'package:bookwise/functions/homepage/screens/search_screen.dart';

class Homepage extends StatefulWidget {
  const Homepage({Key? key}) : super(key: key);

  @override
  State<Homepage> createState() => _HomepageState();
}

final TextEditingController searchController = TextEditingController();

class _HomepageState extends State<Homepage> {
  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 46, 42, 42),
      body: SingleChildScrollView(
        //physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            SizedBox(
              height: height / 2,
              child: Stack(
                children: [
                  Container(
                    height: height / 2.5,
                    //height: constraints.maxHeight * 0.8,
                    //width: width,
                    //margin: const EdgeInsets.only(left: 16),
                    decoration: BoxDecoration(
                      color: AppColors.lightBlue,
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(45),
                        bottomRight: Radius.circular(45),
                      ),
                    ),
                    child: SafeArea(
                      minimum: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Spacer(),
                          Text("Book Wise",
                              style: Theme.of(context).textTheme.displayLarge),
                          const Spacer(),
                          InkWell(
                            onTap: () {
                              showSearch(
                                  context: context,
                                  delegate: CustomSearchDelegate());
                            },
                            child: Container(
                              padding: EdgeInsets.all(12),
                              height: 50,
                              width: double.maxFinite,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                    width: 1, color: AppColors.black),
                              ),
                              child: const Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text("Search for Books"),
                                  Icon(Icons.search),
                                ],
                              ),
                            ),
                          ),
                          const Spacer(
                            flex: 2,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Books In Your Zone',
                                  style: Theme.of(context)
                                      .textTheme
                                      .displayMedium),
                              /*InkWell(
                                onTap: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              BookList(name: "Fiction")));
                                },
                                child: Text(
                                  "See All",
                                  style: Theme.of(context).textTheme.headline4,
                                ),
                              )*/
                            ],
                          ),
                          const Spacer(
                            flex: 5,
                          ),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    child: Container(
                      height: height / 5.3,
                      //height: constraints.maxHeight * 0.38,
                      margin: const EdgeInsets.only(left: 16),
                      child: const ZoneBooks(),
                    ),
                  ),
                ],
              ),
            ),
            Headline(
              category: "Anime",
              showAll: "Anime",
            ),
            SizedBox(
              //color: Colors.grey.shade100,
              height: height / 3.4,
              child: const AnimeBooks(),
            ),
            Headline(
              category: "Action & Adventure",
              showAll: "Action & Adventure",
            ),
            SizedBox(
              //color: Colors.yellow,
              height: height / 3.4,
              child: const AdventureBooks(),
            ),
            Headline(
              category: "Novel",
              showAll: "Novel",
            ),
            SizedBox(
              //color: Colors.yellow,
              height: height / 3.4,
              child: const NovelBooks(),
            ),
            Headline(
              category: "Horror",
              showAll: "Horror",
            ),
            SizedBox(
              //child: Colors.yellow,
              height: height / 3.4,
              child: const HorrorBooks(),
            ),
          ],
        ),
      ),
    );
  }
}
