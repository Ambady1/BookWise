import 'package:bookwise/common/constants/colors_and_fonts.dart';
import 'package:bookwise/functions/homepage/screens/detail_screen.dart';
import 'package:bookwise/functions/wishlist/repositories/firebasecall_wishlist.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class Wishlist extends StatefulWidget {
  const Wishlist({Key? key}) : super(key: key);

  @override
  State<Wishlist> createState() => _WishlistState();
}

class _WishlistState extends State<Wishlist> {
  @override
  Widget build(BuildContext context) {
    // Ensure the height variable is defined
    final double height = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 46, 42, 42),
      body: Column(
        children: [
          Container(
            width: double.infinity, // Ensure the container takes full width
            height: height / 5,
            decoration: BoxDecoration(
              color: AppColors.lightBlue, // Replace with your color constant
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
                    "Wishlist",
                    style: Theme.of(context)
                        .textTheme
                        .displayLarge, // Replace with your text style
                  ),
                  const Spacer(flex: 5),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10.0),
          Expanded(
              child: StreamBuilder<List<Map<String, dynamic>>>(
            stream: streamWishlist(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              }

              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Center(child: Text('No items in wishlist'));
              }

              List<Map<String, dynamic>> wishlist = snapshot.data!;

              return GridView.builder(
                shrinkWrap: true,
                padding: const EdgeInsets.all(8.0),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3, // Number of columns in the grid
                  childAspectRatio: 0.6, // Aspect ratio for each grid item
                  mainAxisSpacing: 2.0, // Space between grid items vertically
                  crossAxisSpacing:
                      8.0, // Space between grid items horizontally
                ),
                itemCount: wishlist.length,
                itemBuilder: (context, index) {
                  Map<String, dynamic> book = wishlist[index];
                  return GridTile(
                    child: SizedBox(
                      height: 300.h, // Adjust height as needed
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Card(
                            elevation: 2,
                            margin: EdgeInsets.zero,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Container(
                              height: 150.h, // Adjust height as needed
                              width: double.infinity,
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                DetailsScreen(id: book['id'])));
                                  },
                                  child: Image.network(
                                    book[
                                        'imageUrl'], // Ensure you define errorLink
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 10.0),
                          Expanded(
                            child: Text(
                              book['title'] ?? 'No title',
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context)
                                  .textTheme
                                  .headlineMedium
                                  ?.copyWith(
                                    fontWeight: FontWeight.w500,
                                    color: Colors.white,
                                  ),
                            ),
                          ),
                          const SizedBox(height: 10.0),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          )),
        ],
      ),
    );
  }
}
