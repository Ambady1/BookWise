import 'package:http/http.dart' as http;
import 'dart:math' as math;

final random = math.Random().nextInt(21);

class BookApi {
  //Books in your zone
  Future getZone({required String title}) async {
    final response = await http.get(Uri.parse(
        "https://www.googleapis.com/books/v1/volumes?q=$title&maxResults=1"));
    var body = response.body;
    return body;
  }

  Future getBooks() async {
    final response = await http.get(
      Uri.parse(
          "https://www.googleapis.com/books/v1/volumes?q=Fiction&maxResults=39"),
      // headers: headers,
    );

    var body = response.body;
    //print(body);
    return body;
  }

  Future searchBooks({required String searchBook}) async {
    final response = await http.get(
      Uri.parse(
          "https://www.googleapis.com/books/v1/volumes?q=$searchBook&orderBy=relevance&maxResults=10"),
      // headers: headers,
    );

    var body = response.body;
    //print(body);
    return body;
  }

  Future showBooksDetails({required String id}) async {
    final response = await http.get(
      Uri.parse("https://www.googleapis.com/books/v1/volumes/$id"),
    );

    var body = response.body;
    //print(body);
    return body;
  }

//Amine Books
  Future getBooks2() async {
    final response = await http.get(
      Uri.parse(
          "https://www.googleapis.com/books/v1/volumes?q=subject:anime&orderBy=relevance&maxResults=39&startIndex=$random"),
    );

    var body = response.body;
    //print(body);
    return body;
  }

//Adventure Books
  Future getBooks3() async {
    final response = await http.get(
      Uri.parse(
          "https://www.googleapis.com/books/v1/volumes?q=subject:adventure&orderBy=relevance&maxResults=39&startIndex=$random"),
    );

    var body = response.body;
    //print(body);
    return body;
  }

  //Novel
  Future getBooks4() async {
    final response = await http.get(
      Uri.parse(
          "https://www.googleapis.com/books/v1/volumes?q=subject:novel&orderBy=relevance&maxResults=39&startIndex=$random"),
    );

    var body = response.body;
    //print(body);
    return body;
  }

  //Horror Books
  Future getBooks5() async {
    final response = await http.get(
      Uri.parse(
          "https://www.googleapis.com/books/v1/volumes?q=subject:horror&orderBy=relevance&maxResults=39&startIndex=$random"),
    );

    var body = response.body;
    //print(body);
    return body;
  }
}
