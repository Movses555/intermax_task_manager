// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'server_side_api.dart';

// **************************************************************************
// ChopperGenerator
// **************************************************************************

// ignore_for_file: always_put_control_body_on_new_line, always_specify_types, prefer_const_declarations, unnecessary_brace_in_string_interps
class _$ServerSideApi extends ServerSideApi {
  _$ServerSideApi([ChopperClient? client]) {
    if (client == null) return;
    this.client = client;
  }

  @override
  final definitionType = ServerSideApi;

  @override
  Future<Response<User>> loginUser(dynamic data) {
    final $url = '/login_user.php';
    final $body = data;
    final $request = Request('POST', $url, client.baseUrl, body: $body);
    return client.send<User, User>($request);
  }

  @override
  Future<Response<Brigade>> loginBrigade(dynamic data) {
    final $url = '/login_brigade.php';
    final $body = data;
    final $request = Request('POST', $url, client.baseUrl, body: $body);
    return client.send<Brigade, Brigade>($request);
  }

  @override
  Future<Response<dynamic>> registerUser(dynamic data) {
    final $url = '/register_user.php';
    final $body = data;
    final $request = Request('POST', $url, client.baseUrl, body: $body);
    return client.send<dynamic, dynamic>($request);
  }

  @override
  Future<Response<dynamic>> registerBrigade(dynamic data) {
    final $url = '/register_brigade.php';
    final $body = data;
    final $request = Request('POST', $url, client.baseUrl, body: $body);
    return client.send<dynamic, dynamic>($request);
  }

  @override
  Future<Response<dynamic>> addTask(dynamic data) {
    final $url = '/add_task.php';
    final $body = data;
    final $request = Request('POST', $url, client.baseUrl, body: $body);
    return client.send<dynamic, dynamic>($request);
  }

  @override
  Future<Response<dynamic>> editTask(dynamic data) {
    final $url = '/edit_task.php';
    final $body = data;
    final $request = Request('POST', $url, client.baseUrl, body: $body);
    return client.send<dynamic, dynamic>($request);
  }

  @override
  Future<Response<dynamic>> editNotes1(dynamic data) {
    final $url = '/edit_notes1.php';
    final $body = data;
    final $request = Request('POST', $url, client.baseUrl, body: $body);
    return client.send<dynamic, dynamic>($request);
  }

  @override
  Future<Response<dynamic>> editNotes2(dynamic data) {
    final $url = '/edit_notes2.php';
    final $body = data;
    final $request = Request('POST', $url, client.baseUrl, body: $body);
    return client.send<dynamic, dynamic>($request);
  }

  @override
  Future<Response<dynamic>> deleteTask(dynamic data) {
    final $url = '/delete_task.php';
    final $body = data;
    final $request = Request('POST', $url, client.baseUrl, body: $body);
    return client.send<dynamic, dynamic>($request);
  }

  @override
  Future<Response<dynamic>> updateStatus(dynamic data) {
    final $url = '/update_status.php';
    final $body = data;
    final $request = Request('POST', $url, client.baseUrl, body: $body);
    return client.send<dynamic, dynamic>($request);
  }

  @override
  Future<Response<dynamic>> updateOnWayTime(dynamic data) {
    final $url = '/update_time_1.php';
    final $body = data;
    final $request = Request('POST', $url, client.baseUrl, body: $body);
    return client.send<dynamic, dynamic>($request);
  }

  @override
  Future<Response<dynamic>> updateWorkTime(dynamic data) {
    final $url = '/update_time_2.php';
    final $body = data;
    final $request = Request('POST', $url, client.baseUrl, body: $body);
    return client.send<dynamic, dynamic>($request);
  }

  @override
  Future<Response<dynamic>> changeBrigade(dynamic data) {
    final $url = '/change_brigade.php';
    final $body = data;
    final $request = Request('POST', $url, client.baseUrl, body: $body);
    return client.send<dynamic, dynamic>($request);
  }

  @override
  Future<Response<List<TaskServerModel>>> getTasks(dynamic data) {
    final $url = '/get_tasks.php';
    final $body = data;
    final $request = Request('POST', $url, client.baseUrl, body: $body);
    return client.send<List<TaskServerModel>, TaskServerModel>($request);
  }

  @override
  Future<Response<List<TaskServerModel>>> getBrigadeTask(dynamic data) {
    final $url = '/get_brigade_tasks.php';
    final $body = data;
    final $request = Request('POST', $url, client.baseUrl, body: $body);
    return client.send<List<TaskServerModel>, TaskServerModel>($request);
  }
}
