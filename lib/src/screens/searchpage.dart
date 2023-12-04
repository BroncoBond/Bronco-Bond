import 'package:flutter/material.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:google_fonts/google_fonts.dart';

class SearchPage extends StatefulWidget {
  final token;
  const SearchPage({@required this.token, Key? key}) : super(key: key);

  @override
  State<SearchPage> createState() => SearchPageState();
}

class SearchPageState extends State<SearchPage> {
  late String email;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    Map<String, dynamic> jwtDecodedToken = JwtDecoder.decode(widget.token);

    email = jwtDecodedToken['email'];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
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
              Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: buildSearchBar(" ")),
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

  Widget buildSearchBar(String label) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10.0),
        color: Colors.grey[200],
      ),
      child: const Padding(
        padding: EdgeInsets.symmetric(horizontal: 8.0),
        child: TextField(
          decoration: InputDecoration(
            hintText: 'Search...',
            border: InputBorder.none,
            icon: Icon(Icons.search),
          ),
        ),
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
