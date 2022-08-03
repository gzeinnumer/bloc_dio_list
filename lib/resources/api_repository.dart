import '../model/covid_model.dart';
import 'api_provider.dart';

class ApiRepository {
  final _provider = ApiProvider();

  Future<CovidModel> fetchCovidList() {
    return _provider.fetchCovidList();
  }
}

class NetworkError extends Error {}