import 'package:bookwise/functions/community/screens/addpost.dart';
import 'package:flutter/material.dart';
import 'package:bookwise/functions/community/screens/searchscreen.dart';
import 'package:bookwise/common/constants/colors_and_fonts.dart';

class MainPage extends StatefulWidget {
  const MainPage({Key? key}) : super(key: key);

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 46, 42, 42),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              children: [
                SizedBox(
                  height: height / 2,
                  child: Stack(
                    children: [
                      Container(
                        height: height / 2.5,
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
                              Text(
                                "Community",
                                style:
                                    Theme.of(context).textTheme.displayLarge!,
                              ),
                              const Spacer(),
                              InkWell(
                                onTap: () {
                                  showSearch(
                                    context: context,
                                    delegate: SearchScreen(),
                                  );
                                },
                                child: Container(
                                  padding: const EdgeInsets.all(12),
                                  height: 50,
                                  width: double.maxFinite,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      width: 1,
                                      color: AppColors.black,
                                    ),
                                  ),
                                  child: const Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text("Search for Readers"),
                                      Icon(Icons.search),
                                    ],
                                  ),
                                ),
                              ),
                              const Spacer(
                                flex: 7,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: FloatingActionButton(
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const AddPostScreen()));
                },
                backgroundColor: Colors.white,
                child: const Icon(Icons.add, color: Colors.black),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
