import 'package:flutter/material.dart';
import 'package:Films_List/models/film_for_listing.dart';
import 'package:Films_List/services/film_service.dart';
import 'package:Films_List/views/film_delete.dart';
import 'package:get_it/get_it.dart';
import 'film_modify.dart';
import 'package:Films_List/models/api_response.dart';

class FilmList extends StatefulWidget {
  @override
  _FilmListState createState() => _FilmListState();
}

class _FilmListState extends State<FilmList> {
  FilmService get service => GetIt.I<FilmService>();
  List<FilmForListing> films = [];

  APIResponse<List<FilmForListing>> _apiResponse;
  bool _isLoading = false;

  @override
  void initState() {
    _fetchNotes();
    super.initState();
  }

  _fetchNotes() async {
    setState(() {
      _isLoading = true;
    });

    _apiResponse = await service.getFilmsList();

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text('List of Films')),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.of(context)
                .push(MaterialPageRoute(builder: (_) => FilmModify()))
                .then((_) {
              _fetchNotes();
            });
          },
          child: Icon(Icons.add),
        ),
        body: Builder(
          builder: (_) {
            if (_isLoading) {
              return Center(child: CircularProgressIndicator());
            }

            if (_apiResponse.error) {
              return Center(child: Text(_apiResponse.errorMessage));
            }

            return ListView.separated(
              separatorBuilder: (_, __) =>
                  Divider(height: 1, color: Colors.green),
              itemBuilder: (_, index) {
                return Dismissible(
                  key: ValueKey(_apiResponse.data[index].filmID),
                  direction: DismissDirection.startToEnd,
                  onDismissed: (direction) {},
                  confirmDismiss: (direction) async {
                    final result = await showDialog(
                        context: context, builder: (_) => FilmDelete());
                    if (result) {
                      final deleteResult = await service
                          .deleteFilm(_apiResponse.data[index].filmID);

                      var message;
                      if (deleteResult != null && deleteResult.data == true) {
                        message = 'The film was deleted successfully';
                      } else {
                        message =
                            deleteResult?.errorMessage ?? 'An error occured';
                      }

                      showDialog(
                          context: context,
                          builder: (_) => AlertDialog(
                                title: Text('Done'),
                                content: Text(message),
                                actions: <Widget>[
                                  FlatButton(
                                      child: Text('Ok'),
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      })
                                ],
                              ));

                      return deleteResult?.data ?? false;
                    }
                    print(result);
                    return result;
                  },
                  background: Container(
                    color: Colors.red,
                    padding: EdgeInsets.only(left: 16),
                    child: Align(
                      child: Icon(Icons.delete, color: Colors.white),
                      alignment: Alignment.centerLeft,
                    ),
                  ),
                  child: ListTile(
                    title: Text(
                      _apiResponse.data[index].filmTitle,
                      style: TextStyle(color: Theme.of(context).primaryColor),
                    ),
                    subtitle: Text(_apiResponse.data[index].filmRating),
                    onTap: () {
                      Navigator.of(context)
                          .push(MaterialPageRoute(
                              builder: (_) => FilmModify(
                                  filmID: _apiResponse.data[index].filmID)))
                          .then((data) {
                        _fetchNotes();
                      });
                    },
                  ),
                );
              },
              itemCount: _apiResponse.data.length,
            );
          },
        ));
  }
}
