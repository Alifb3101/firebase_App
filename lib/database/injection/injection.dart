import 'package:dio/dio.dart';

import '../restclient/rest_client.dart';


final dio = Dio(BaseOptions(
));

final restClient = RestClient(Dio());