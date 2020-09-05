import 'package:Films_List/models/film_for_listing.dart';
import 'package:Films_List/models/api_response.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:Films_List/models/film_insert.dart';
import 'package:Films_List/services/header_service.dart';
import 'package:Films_List/constants/constants.dart';

class FilmService {
  static const API = 'http://192.168.0.20:8080';
  static const headers = {
    'Content-Type': 'application/json',
  };

  Future<APIResponse<List<FilmForListing>>> getFilmsList() async {
    return http.get(API + '/api/v1/films').then((data) {
      if (data.statusCode == 200) {
        final jsonData = json.decode(data.body);
        print('final data $jsonData');
        final notes = <FilmForListing>[];
        for (var item in jsonData) {
          print('inside loop');
          final note = FilmForListing(
              filmID: item['_id'],
              filmTitle: item['name'],
              filmRating: item['rating'].toString());
          notes.add(note);
        }
        return APIResponse<List<FilmForListing>>(data: notes);
      }

      return APIResponse<List<FilmForListing>>(
          error: true, errorMessage: 'An error occured');
    }).catchError((_) => APIResponse<List<FilmForListing>>(
        error: true, errorMessage: 'Inside Get Catch'));
  }

  Future<APIResponse<FilmForListing>> getoneFilm(String filmID) async {
    return http
        .get(API + '/api/v1/films/' + filmID,
            headers: ServiceHelper.getHeader(GlobalPasser.sessionToken))
        .then((data) {
      if (data.statusCode == 200) {
        print('Inside 200');
        final jsonData = json.decode(data.body);
        print(jsonData);
        final oneFilm = FilmForListing(
            filmID: jsonData['_id'],
            filmTitle: jsonData['name'],
            filmRating: jsonData['rating'].toString());
        return APIResponse<FilmForListing>(data: oneFilm);
      }
      return APIResponse<FilmForListing>(
          error: true, errorMessage: 'Login Alert!!! Please Login.');
    }).catchError((_) => APIResponse<FilmForListing>(
            error: true, errorMessage: 'Inside Edit Catch'));
  }

  Future<APIResponse<bool>> createFilm(FilmInsert item) {
    return http
        .post(API + '/api/v1/films',
            headers: ServiceHelper.getHeader(GlobalPasser.sessionToken),
            body: json.encode(item.toJson()))
        .then((data) {
      if (data.statusCode == 404) {
        return APIResponse<bool>(
            error: true, errorMessage: 'Please enter film title and rating!!');
      }
      if (data.statusCode == 200) {
        return APIResponse<bool>(data: true);
      }
      return APIResponse<bool>(
          error: true, errorMessage: 'Login Alert!!! Please Login.');
    }).catchError((_) => APIResponse<bool>(
            error: true, errorMessage: 'Inside Create Catch'));
  }

  Future<APIResponse<bool>> updateFilm(String filmID, FilmInsert item) {
    return http
        .put(API + '/api/v1/films/' + filmID,
            headers: ServiceHelper.getHeader(GlobalPasser.sessionToken),
            body: json.encode(item.toJson()))
        .then((data) {
      if (data.statusCode == 404) {
        return APIResponse<bool>(
            error: true, errorMessage: 'Please enter film title and rating!!');
      }
      if (data.statusCode == 200) {
        return APIResponse<bool>(data: true);
      }
      return APIResponse<bool>(
          error: true, errorMessage: 'Login Alert!!! Please Login.');
    }).catchError((_) => APIResponse<bool>(
            error: true, errorMessage: 'Inside Update Catch'));
  }

  Future<APIResponse<bool>> deleteFilm(String filmID) {
    return http
        .delete(
      API + '/api/v1/films/' + filmID,
      headers: ServiceHelper.getHeader(GlobalPasser.sessionToken),
    )
        .then((data) {
      if (data.statusCode == 200) {
        return APIResponse<bool>(data: true);
      }
      return APIResponse<bool>(
          error: true, errorMessage: 'Login Alert!!! Please Login.');
    }).catchError((_) => APIResponse<bool>(
            error: true, errorMessage: 'Inside Delete Catch'));
  }
}
