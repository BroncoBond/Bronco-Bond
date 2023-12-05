import 'package:flutter/material.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:bronco_bond/src/screens/login.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class SearchPage extends StatefulWidget {
  final token;
  const SearchPage({@required this.token, Key? key}) : super(key: key);

  @override
  State<SearchPage> createState() => SearchPageState();
}

class SearchPageState extends State<SearchPage> {
  late String username;

  TextEditingController searchController = TextEditingController();
  List<Map<String, dynamic>> searchResults = [];

  void performSearch() async {
    // Backend functionality
    final query = searchController.text;
    final response = await http.get(Uri.parse('search'));

    if (response.statusCode == 200) {
      setState(() {
        searchResults =
            List<Map<String, dynamic>>.from(json.decode(response.body));
      });
    } else {
      print('Failed to fetch search results');
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    Map<String, dynamic> jwtDecodedToken = JwtDecoder.decode(widget.token);

    username = jwtDecodedToken['username'];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios),
            color: Colors.black,
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const LoginPage()),
              );
            },
          ),
          title: Text("BroncoBond",
              style: GoogleFonts.raleway(
                  textStyle: Theme.of(context).textTheme.displaySmall,
                  fontSize: 25,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF3B5F43))),
        ),
        body: SingleChildScrollView(
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
              Text(username),
              Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: buildSearchBar(" ", searchController)),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  buildIcon("Organization", "orgIcon.png"),
                  buildIcon("Professors", "profIcon.png"),
                ],
              ),
              SizedBox(height: 5),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  buildIcon("People", "peopleIcon.png"),
                  buildIcon("Messages", "messagesIcon.png"),
                ],
              ),
              SizedBox(height: 5),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  buildIcon("Events", "eventsIcon.png"),
                  buildIcon("Forums", "messagesIcon.png"),
                ],
              )
            ])));
  }

  Widget buildSearchBar(String label, TextEditingController fieldController) {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10.0),
        color: Colors.grey[200],
      ),
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 8.0),
            child: TextField(
              controller: fieldController,
              keyboardType: TextInputType.text,
              decoration: InputDecoration(
                hintText: 'Search...',
                border: InputBorder.none,
                icon: Icon(Icons.search),
              ),
              onSubmitted: (String value) {
                performSearch();
              },
            ),
          ),
          Expanded(
            child: ListView.builder(
                shrinkWrap: true,
                itemCount: searchResults.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(searchResults[index]['email']),
                  );
                }),
          ),
        ],
      ),
    );
  }

  Widget buildIcon(String title, String imagePath) {
    return Column(
      children: [
        Center(
            child: SizedBox(
          width: 175,
          height: 175,
          child: Card(
              clipBehavior: Clip.hardEdge,
              child: InkWell(
                splashColor: Colors.blue.withAlpha(30),
                onTap: () {
                  debugPrint('${title} tapped.');
                },

                child: imagePath.isNotEmpty
                    ? Image(
                        image: AssetImage('assets/images/$imagePath'),
                        fit: BoxFit.cover)
                    : Center(
                        child:
                            Text(title)), // Display text if imagePath is empty
              )),
        )),
        SizedBox(height: 5),
        Center(
            child: Text(
          title,
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ))
      ],
    );
  }
}
