import 'package:dio/dio.dart'hide Headers;
import 'package:firebase/model/todo.dart';
import 'package:retrofit/error_logger.dart';
import 'package:retrofit/http.dart';


part 'rest_client.g.dart';


@RestApi(baseUrl: 'https://springbootapiwithdocker.onrender.com')
abstract class RestClient {

  factory RestClient(Dio dio, {String? baseUrl}) = _RestClient;

  @GET("/users")
  Future<List<EmployeModel>> getUserList();

  @POST("/users")
  Future<String> AddUser(@Body() Map<String, dynamic> body);
}