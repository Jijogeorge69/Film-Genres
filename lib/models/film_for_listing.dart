class FilmForListing {
  String filmID;
  String filmTitle;
  String filmRating;

  FilmForListing({this.filmID, this.filmTitle, this.filmRating});

  factory FilmForListing.fromJson(Map<String, dynamic> json) {
    return FilmForListing(
      filmID: json['_id'],
      filmTitle: json['name'],
      filmRating: json['rating'],
    );
  }
}
