import 'package:bookwise/common/constants/colors_and_fonts.dart';
import 'package:flutter/material.dart';
import 'package:bookwise/functions/homepage/notifiers/app_notifier.dart';
import 'package:bookwise/functions/homepage/model/detailmodel.dart';
import 'package:provider/provider.dart';
import 'package:readmore/readmore.dart';
import 'package:url_launcher/url_launcher.dart';

class DetailsScreen extends StatefulWidget {
  DetailsScreen({Key? key, required this.id, this.boxColor}) : super(key: key);

  var id;
  final Color? boxColor;

  @override
  State<DetailsScreen> createState() => _DetailsScreenState();
}

class _DetailsScreenState extends State<DetailsScreen> {
  @override
  Widget build(BuildContext context) {
    String errorLink =
        "https://img.freepik.com/free-vector/funny-error-404-background-design_1167-219.jpg?w=740&t=st=1658904599~exp=1658905199~hmac=131d690585e96267bbc45ca0978a85a2f256c7354ce0f18461cd030c5968011c";
    double height = MediaQuery.of(context).size.height / 815;
    double width = MediaQuery.of(context).size.width / 375;

    return Scaffold(
      backgroundColor: Color.fromARGB(255, 46, 42, 42),
      body: Consumer<AppNotifier>(
        builder: ((context, value, child) {
          return widget.id != null
              ? FutureBuilder(
                  future: value.showBookData(id: widget.id),
                  builder: (context, AsyncSnapshot<DetailModel> snapshot) {
                    if (snapshot.hasError) {
                      return const Center(
                        child: Text("Opps! Try again later!"),
                      );
                    }
                    if (snapshot.hasData) {
                      return SingleChildScrollView(
                        child: Column(
                          children: [
                            SizedBox(
                              height: height * 350,
                              child: Stack(
                                children: [
                                  Container(
                                    width: double.maxFinite,
                                    height: height * 200,
                                    decoration: BoxDecoration(
                                      color: widget.boxColor ??
                                          const Color(0xffF9CFE3),
                                      borderRadius: const BorderRadius.only(
                                        bottomLeft: Radius.circular(35),
                                        bottomRight: Radius.circular(35),
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    left: 0,
                                    right: 0,
                                    bottom: 0,
                                    child: Container(
                                      height: height * 250,
                                      alignment: Alignment.center,
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(12),
                                        child: Image(
                                          image: NetworkImage(
                                              "${snapshot.data?.volumeInfo?.imageLinks?.thumbnail ?? errorLink}"),
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    top: 70,
                                    left: 16,
                                    child: OutlinedButton.icon(
                                      onPressed: () {
                                        Navigator.pop(context);
                                      },
                                      style: OutlinedButton.styleFrom(
                                          side: const BorderSide(width: 1)),
                                      icon: Icon(
                                        Icons.arrow_back_ios_new,
                                        color: AppColors.black,
                                      ),
                                      label: const Text(
                                        "",
                                      ),
                                    ),
                                  )
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Text(
                                    "${snapshot.data?.volumeInfo?.title ?? "Censored"}",
                                    textAlign: TextAlign.center,
                                    style: Theme.of(context)
                                        .textTheme
                                        .displayLarge
                                        ?.copyWith(
                                          fontSize: 24,
                                          color: Colors.white,
                                        ),
                                  ),
                                  const SizedBox(height: 10),
                                  Text(
                                    "${(snapshot.data?.volumeInfo!.authors?.isNotEmpty ?? false) ? snapshot.data?.volumeInfo!.authors![0] : "Censored"}"
                                        .toUpperCase(),
                                    textAlign: TextAlign.center,
                                    style: Theme.of(context)
                                        .textTheme
                                        .headlineMedium
                                        ?.copyWith(color: Colors.white),
                                  ),
                                  const SizedBox(
                                    height: 10,
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 35),
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          "${snapshot.data?.volumeInfo?.printType}",
                                          style: Theme.of(context)
                                              .textTheme
                                              .headlineMedium
                                              ?.copyWith(color: Colors.white),
                                        ),
                                        const Spacer(
                                          flex: 2,
                                        ),
                                        Container(
                                          height: height * 35,
                                          width: width * 90,
                                          alignment: Alignment.center,
                                          decoration: BoxDecoration(
                                              color: Colors.white,
                                              borderRadius:
                                                  BorderRadius.circular(12)),
                                          child: const Text(
                                            "AVAILABLE",
                                            style:
                                                TextStyle(color: Colors.black),
                                          ),
                                        ),
                                        const Spacer(),
                                        Text(
                                          "${snapshot.data?.volumeInfo?.pageCount} Pages",
                                          style: Theme.of(context)
                                              .textTheme
                                              .headlineMedium
                                              ?.copyWith(color: Colors.white),
                                        )
                                      ],
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 20,
                                  ),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      OutlinedButton(
                                        onPressed: () async {
                                          Uri url = Uri.parse(
                                              "${snapshot.data?.volumeInfo?.previewLink}");

                                          if (await canLaunchUrl(url)) {
                                            await launchUrl(url,
                                                mode: LaunchMode
                                                    .externalApplication);
                                          } else {
                                            throw 'could not launch $url';
                                          }
                                        },
                                        style: OutlinedButton.styleFrom(
                                            side: const BorderSide(
                                                width: 1, color: Colors.white)),
                                        child: Text(
                                          "BOOK THIS",
                                          style: Theme.of(context)
                                              .textTheme
                                              .headlineMedium
                                              ?.copyWith(color: Colors.white),
                                        ),
                                      ),
                                      OutlinedButton.icon(
                                        onPressed: () {},
                                        style: OutlinedButton.styleFrom(
                                            side: const BorderSide(
                                                width: 1, color: Colors.white)),
                                        icon: const Icon(
                                          Icons.favorite_outline,
                                          color: Colors.white,
                                        ),
                                        label: Text(
                                          "WISHLIST",
                                          style: Theme.of(context)
                                              .textTheme
                                              .headlineMedium
                                              ?.copyWith(color: Colors.white),
                                        ),
                                      )
                                    ],
                                  ),
                                  const SizedBox(
                                    height: 20,
                                  ),
                                  Text(
                                    "Details",
                                    style: Theme.of(context)
                                        .textTheme
                                        .displayMedium
                                        ?.copyWith(color: Colors.white),
                                  ),
                                  const SizedBox(
                                    height: 10,
                                  ),
                                  SizedBox(
                                    child: Row(
                                      children: [
                                        Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              "Author",
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .headlineMedium
                                                  ?.copyWith(
                                                      color: Colors.white),
                                            ),
                                            Text("Publisher",
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .headlineMedium
                                                    ?.copyWith(
                                                        color: Colors.white)),
                                            Text("Published Date",
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .headlineMedium
                                                    ?.copyWith(
                                                        color: Colors.white)),
                                            Text("Category",
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .headlineMedium
                                                    ?.copyWith(
                                                        color: Colors.white))
                                          ],
                                        ),
                                        const SizedBox(width: 20),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                "${(snapshot.data?.volumeInfo?.authors?.isNotEmpty ?? false) ? snapshot.data?.volumeInfo?.authors![0] : 'Unknown'}",
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .headlineSmall
                                                    ?.copyWith(
                                                        fontSize: 16,
                                                        color: Colors.white),
                                              ),
                                              Text(
                                                "${snapshot.data?.volumeInfo?.publisher ?? 'Unknown'}",
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .headlineSmall
                                                    ?.copyWith(
                                                        fontSize: 16,
                                                        color: Colors.white),
                                              ),
                                              Text(
                                                "${snapshot.data?.volumeInfo?.publishedDate ?? 'Unknown'}",
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .headlineSmall
                                                    ?.copyWith(
                                                        fontSize: 16,
                                                        color: Colors.white),
                                              ),
                                              Text(
                                                "${(snapshot.data?.volumeInfo?.categories?.isNotEmpty ?? false) ? snapshot.data?.volumeInfo?.categories![0] : 'Unknown'}",
                                                overflow: TextOverflow.ellipsis,
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .headlineSmall
                                                    ?.copyWith(
                                                        fontSize: 16,
                                                        color: Colors.white),
                                              )
                                            ],
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 20,
                                  ),
                                  Text(
                                    "Description",
                                    style: Theme.of(context)
                                        .textTheme
                                        .displayMedium
                                        ?.copyWith(color: Colors.white),
                                  ),
                                  const SizedBox(
                                    height: 10,
                                  ),
                                  ReadMoreText(
                                    "${snapshot.data?.volumeInfo?.description?.replaceAll(RegExp(r'<p>|</p>|<b>|</b>|<br>|<i>|</i>'), '')}",
                                    trimLines: 6,
                                    colorClickableText: Colors.blue,
                                    trimMode: TrimMode.Line,
                                    trimCollapsedText: 'Read More',
                                    trimExpandedText: ' Collapse',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.white,
                                    ),
                                    moreStyle: TextStyle(
                                      color: Colors.blue,
                                      decoration: TextDecoration.underline,
                                    ),
                                    lessStyle: TextStyle(
                                      color: Colors.blue,
                                      decoration: TextDecoration.underline,
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  ElevatedButton(
                                    onPressed: () async {
                                      Uri url = Uri.parse(
                                          "${snapshot.data?.volumeInfo?.infoLink}");

                                      if (await canLaunchUrl(url)) {
                                        await launchUrl(url,
                                            mode:
                                                LaunchMode.externalApplication);
                                      } else {
                                        throw 'could not launch $url';
                                      }
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColors.black,
                                    ),
                                    child: Text(
                                      "Buy Online",
                                      style: Theme.of(context)
                                          .textTheme
                                          .displayMedium
                                          ?.copyWith(
                                              fontSize: 18,
                                              color: Colors.white),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    }
                    return Center(
                        child: CircularProgressIndicator(
                      color: AppColors.black,
                    ));
                  },
                )
              : const Center(
                  child: Text("Opps No Data Found!"),
                );
        }),
      ),
    );
  }
}
