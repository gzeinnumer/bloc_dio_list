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
