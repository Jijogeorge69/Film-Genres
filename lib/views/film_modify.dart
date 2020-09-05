import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get_it/get_it.dart';
import 'package:Films_List/models/film_for_listing.dart';
import 'package:Films_List/models/film_insert.dart';
import 'package:Films_List/services/film_service.dart';

class FilmModify extends StatefulWidget {
  final String filmID;
  FilmModify({this.filmID});

  @override
  _FilmModifyState createState() => _FilmModifyState();
}

class _FilmModifyState extends State<FilmModify> {
  bool get isEditing => widget.filmID != null;
  bool _validate = false;
  FilmService get filmService => GetIt.I<FilmService>();

  String errorMessage;
  FilmForListing film;

  TextEditingController _titleController = TextEditingController();
  TextEditingController _ratingController = TextEditingController();

  bool _isLoading = false;

  showAlertDialog(BuildContext context) {
    Widget okButton = FlatButton(
      child: Text("OK"),
      onPressed: () {
        Navigator.of(context).pop();
      },
    );

    AlertDialog alert = AlertDialog(
      title: Text("Alert!!!"),
      content: Text("Please enter film title"),
      actions: [
        okButton,
      ],
    );

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  @override
  void initState() {
    super.initState();
    if (isEditing) {
      setState(() {
        _isLoading = true;
      });
      filmService.getoneFilm(widget.filmID).then((response) {
        setState(() {
          _isLoading = false;
        });

        if (response.error) {
          errorMessage = response.errorMessage ?? 'An error occurred';
        }
        film = response.data;
        _titleController.text = film.filmTitle;
        _ratingController.text = film.filmRating;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(isEditing ? 'Edit Film' : 'Create Film')),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: _isLoading
            ? Center(child: CircularProgressIndicator())
            : Column(
                children: <Widget>[
                  TextField(
                    controller: _titleController,
                    decoration: InputDecoration(
                      hintText: 'Film title',
                      labelText: 'Enter the film title',
                      errorText: _validate ? 'Value Can\'t Be Empty' : null,
                    ),
                  ),
                  Container(height: 8),
                  TextField(
                    inputFormatters: [
                      LengthLimitingTextInputFormatter(1),
                      WhitelistingTextInputFormatter(RegExp("[1-4]")),
                    ],
                    keyboardType: TextInputType.number,
                    controller: _ratingController,
                    decoration: InputDecoration(hintText: 'Film rating'),
                  ),
                  Container(height: 16),
                  SizedBox(
                    width: double.infinity,
                    height: 35,
                    child: RaisedButton(
                      child:
                          Text('Submit', style: TextStyle(color: Colors.white)),
                      color: Theme.of(context).primaryColor,
                      onPressed: () async {
                        setState(() {
                          _titleController.text.isEmpty
                              ? _validate = true
                              : _validate = false;
                        });
                        if (isEditing) {
                          setState(() {
                            _isLoading = true;
                          });
                          final note = FilmInsert(
                              name: _titleController.text,
                              rating: _ratingController.text);

                          final result =
                              await filmService.updateFilm(widget.filmID, note);

                          setState(() {
                            _isLoading = false;
                          });

                          final title = 'Done';
                          final text = result.error
                              ? (result.errorMessage ?? 'An error occurred')
                              : 'Your film was updated';

                          showDialog(
                              context: context,
                              builder: (_) => AlertDialog(
                                    title: Text(title),
                                    content: Text(text),
                                    actions: <Widget>[
                                      FlatButton(
                                        child: Text('Ok'),
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                        },
                                      )
                                    ],
                                  )).then((data) {
                            if (result.data) {
                              Navigator.of(context).pop();
                            }
                          });
                        } else {
                          setState(() {
                            _isLoading = true;
                          });
                          final note = FilmInsert(
                              name: _titleController.text,
                              rating: _ratingController.text);
                          final result = await filmService.createFilm(note);

                          setState(() {
                            _isLoading = false;
                          });

                          final title = 'Done';
                          final text = result.error
                              ? (result.errorMessage ?? 'An error occurred')
                              : 'Your film was created';

                          showDialog(
                              context: context,
                              builder: (_) => AlertDialog(
                                    title: Text(title),
                                    content: Text(text),
                                    actions: <Widget>[
                                      FlatButton(
                                        child: Text('Ok'),
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                        },
                                      )
                                    ],
                                  )).then((data) {
                            if (result.data) {
                              Navigator.of(context).pop();
                            }
                          });
                        }
                      },
                    ),
                  )
                ],
              ),
      ),
    );
  }
}
