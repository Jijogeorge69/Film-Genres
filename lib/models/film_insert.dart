import 'package:flutter/foundation.dart';

class FilmInsert {
  String name;
  String rating;

  FilmInsert({
    @required this.name,
    @required this.rating,
  });

  Map<String, dynamic> toJson() {
    return {"name": name, "rating": rating};
  }
}
