# bloc_dio_list

covid_bloc.dart
```dart
import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../model/covid_model.dart';
import '../resources/api_repository.dart';

part 'covid_event.dart';

part 'covid_state.dart';

class CovidBloc extends Bloc<CovidEvent, CovidState> {
  final ApiRepository _apiRepository = ApiRepository();

  CovidBloc(CovidState initialState) : super(initialState);

  @override
  CovidState get initialState => CovidInitial();

  @override
  Stream<CovidState> mapEventToState(
    CovidEvent event,
  ) async* {
    if (event is GetCovidList) {
      try {
        yield CovidLoading();
        final mList = await _apiRepository.fetchCovidList();
        yield CovidLoaded(mList);
        if (mList.error != null) {
          yield CovidError(mList.error!);
        }
      } on NetworkError {
        yield CovidError("Failed to fetch data. is your device online?");
      }
    }
  }
}
```

- covid_event.dart
```dart
part of 'covid_bloc.dart';

abstract class CovidEvent extends Equatable {
  const CovidEvent();
}

class GetCovidList extends CovidEvent {
  @override
  List<Object>? get props => null;
}
```
- covid_state.dart
```dart
part of 'covid_bloc.dart';

abstract class CovidState extends Equatable {
  const CovidState();
}

class CovidInitial extends CovidState {
  const CovidInitial();
  @override
  List<Object> get props => [];
}

class CovidLoading extends CovidState {
  const CovidLoading();
  @override
  List<Object>? get props => null;
}

class CovidLoaded extends CovidState {
  final CovidModel covidModel;
  const CovidLoaded(this.covidModel);
  @override
  List<Object> get props => [covidModel];
}

class CovidError extends CovidState {
  final String message;
  const CovidError(this.message);
  @override
  List<Object> get props => [message];
}
```

- covid_model.dart
```dart
class CovidModel {
  Global? global;
  List<Countries>? countries;
  String? date;
  String? error;

  CovidModel({this.global, this.countries, this.date});

  CovidModel.withError(String errorMessage) {
    error = errorMessage;
  }

  CovidModel.fromJson(Map<String, dynamic> json) {
    global = json['Global'] != null ? Global.fromJson(json['Global']) : null;
    if (json['Countries'] != null) {
      countries = <Countries>[];
      json['Countries'].forEach((v) {
        countries?.add(Countries.fromJson(v));
      });
    }
    date = json['Date'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (global != null) {
      data['Global'] = global?.toJson();
    }
    if (this.countries != null) {
      data['Countries'] = countries?.map((v) => v.toJson()).toList();
    }
    data['Date'] = this.date;
    return data;
  }
}

class Global {
  int? newConfirmed;
  int? totalConfirmed;
  int? newDeaths;
  int? totalDeaths;
  int? newRecovered;
  int? totalRecovered;

  Global(
      {this.newConfirmed,
        this.totalConfirmed,
        this.newDeaths,
        this.totalDeaths,
        this.newRecovered,
        this.totalRecovered});

  Global.fromJson(Map<String, dynamic> json) {
    newConfirmed = json['NewConfirmed'];
    totalConfirmed = json['TotalConfirmed'];
    newDeaths = json['NewDeaths'];
    totalDeaths = json['TotalDeaths'];
    newRecovered = json['NewRecovered'];
    totalRecovered = json['TotalRecovered'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['NewConfirmed'] = newConfirmed;
    data['TotalConfirmed'] = totalConfirmed;
    data['NewDeaths'] = newDeaths;
    data['TotalDeaths'] = totalDeaths;
    data['NewRecovered'] = newRecovered;
    data['TotalRecovered'] = totalRecovered;
    return data;
  }
}

class Countries {
  String? country;
  String? countryCode;
  String? slug;
  int? newConfirmed;
  int? totalConfirmed;
  int? newDeaths;
  int? totalDeaths;
  int? newRecovered;
  int? totalRecovered;
  String? date;

  Countries(
      {this.country,
        this.countryCode,
        this.slug,
        this.newConfirmed,
        this.totalConfirmed,
        this.newDeaths,
        this.totalDeaths,
        this.newRecovered,
        this.totalRecovered,
        this.date});

  Countries.fromJson(Map<String, dynamic> json) {
    country = json['Country'];
    countryCode = json['CountryCode'];
    slug = json['Slug'];
    newConfirmed = json['NewConfirmed'];
    totalConfirmed = json['TotalConfirmed'];
    newDeaths = json['NewDeaths'];
    totalDeaths = json['TotalDeaths'];
    newRecovered = json['NewRecovered'];
    totalRecovered = json['TotalRecovered'];
    date = json['Date'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['Country'] = this.country;
    data['CountryCode'] = this.countryCode;
    data['Slug'] = this.slug;
    data['NewConfirmed'] = this.newConfirmed;
    data['TotalConfirmed'] = this.totalConfirmed;
    data['NewDeaths'] = this.newDeaths;
    data['TotalDeaths'] = this.totalDeaths;
    data['NewRecovered'] = this.newRecovered;
    data['TotalRecovered'] = this.totalRecovered;
    data['Date'] = this.date;
    return data;
  }
}
```

- covid_page.dart
```dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc_covid/covid_bloc.dart';
import '../model/covid_model.dart';

class CovidPage extends StatefulWidget {
  CovidPage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  _CovidPageState createState() => _CovidPageState();
}

class _CovidPageState extends State<CovidPage> {
  final CovidBloc _bloc = CovidBloc(const CovidInitial());

  @override
  void initState() {
    _bloc.add(GetCovidList());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('COVID-19 List')),
      body: _buildListCovid(),
    );
  }

  Widget _buildListCovid() {
    return Container(
      margin: EdgeInsets.all(8.0),
      child: BlocProvider(
        create: (_) => _bloc,
        child: BlocListener<CovidBloc, CovidState>(
          listener: (context, state) {
            if (state is CovidError) {
              Scaffold.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                ),
              );
            }
          },
          child: BlocBuilder<CovidBloc, CovidState>(
            builder: (context, state) {
              Widget w;
              if (state is CovidInitial) {
                w = _buildLoading();
              } else if (state is CovidLoading) {
                w = _buildLoading();
              } else if (state is CovidLoaded) {
                w = _buildCard(context, state.covidModel);
              } else if (state is CovidError) {
                w = Container();
              } else{
                w = Container();
              }
              return w;
            },
          ),
        ),
      ),
    );
  }

  Widget _buildCard(BuildContext context, CovidModel model) {
    return ListView.builder(
      itemCount: model.countries?.length,
      itemBuilder: (context, index) {
        return Container(
          margin: EdgeInsets.all(8.0),
          child: Card(
            child: Container(
              margin: EdgeInsets.all(8.0),
              child: Column(
                children: <Widget>[
                  Text("Country: ${model.countries?[index].country}"),
                  Text("Total Confirmed: ${model.countries?[index].totalConfirmed}"),
                  Text("Total Deaths: ${model.countries?[index].totalDeaths}"),
                  Text("Total Recovered: ${model.countries?[index].totalRecovered}"),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildLoading() => Center(child: CircularProgressIndicator());
}
```
- api_provider.dart
```dart
import 'package:dio/dio.dart' show Dio, Response;

import '../model/covid_model.dart';

class ApiProvider {
  final Dio _dio = Dio();
  final String _url = 'https://api.covid19api.com/summary';

  Future<CovidModel> fetchCovidList() async {
    try {
      Response response = await _dio.get(_url);
      return CovidModel.fromJson(response.data);
    } catch (error, stacktrace) {
      print("Exception occured: $error stackTrace: $stacktrace");
      return CovidModel.withError("Data not found / Connection issue");
    }
  }
}
```

- api_repository.dart
```dart
import '../model/covid_model.dart';
import 'api_provider.dart';

class ApiRepository {
  final _provider = ApiProvider();

  Future<CovidModel> fetchCovidList() {
    return _provider.fetchCovidList();
  }
}

class NetworkError extends Error {}
```

- main.dart
```dart
import 'package:bloc_dio_list/page/covid_page.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: CovidPage(title: 'Flutter Demo Home Page'),
    );
  }
}
```

---

```
Copyright 2022 M. Fadli Zein
```