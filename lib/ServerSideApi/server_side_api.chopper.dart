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
  Future<Response<dynamic>> addBrigade(dynamic data) {
    final $url = '/add_brigade.php';
    final $body = data;
    final $request = Request('POST', $url, client.baseUrl, body: $body);
    return client.send<dynamic, dynamic>($request);
  }

  @override
  Future<Response<dynamic>> addTaskToList(dynamic data) {
    final $url = '/add_task_to_list.php';
    final $body = data;
    final $request = Request('POST', $url, client.baseUrl, body: $body);
    return client.send<dynamic, dynamic>($request);
  }

  @override
  Future<Response<dynamic>> deleteBrigadeFromList(dynamic data) {
    final $url = '/delete_brigade_from_list.php';
    final $body = data;
    final $request = Request('POST', $url, client.baseUrl, body: $body);
    return client.send<dynamic, dynamic>($request);
  }

  @override
  Future<Response<dynamic>> deleteTaskFromList(dynamic data) {
    final $url = '/delete_task_from_list.php';
    final $body = data;
    final $request = Request('POST', $url, client.baseUrl, body: $body);
    return client.send<dynamic, dynamic>($request);
  }

  @override
  Future<Response<dynamic>> backupData(dynamic data) {
    final $url = '/back_up_data.php';
    final $body = data;
    final $request = Request('POST', $url, client.baseUrl, body: $body);
    return client.send<dynamic, dynamic>($request);
  }

  @override
  Future<Response<dynamic>> restoreBackup(dynamic data) {
    final $url = '/restore_backup.php';
    final $body = data;
    final $request = Request('POST', $url, client.baseUrl, body: $body);
    return client.send<dynamic, dynamic>($request);
  }

  @override
  Future<Response<dynamic>> changeUserPassword(dynamic data) {
    final $url = '/change_user_password.php';
    final $body = data;
    final $request = Request('POST', $url, client.baseUrl, body: $body);
    return client.send<dynamic, dynamic>($request);
  }

  @override
  Future<Response<dynamic>> changeBrigadePassword(dynamic data) {
    final $url = '/change_brigade_password.php';
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

  @override
  Future<Response<PrivilegesModel>> getPrivileges(dynamic data) {
    final $url = '/get_privileges.php';
    final $body = data;
    final $request = Request('POST', $url, client.baseUrl, body: $body);
    return client.send<PrivilegesModel, PrivilegesModel>($request);
  }

  @override
  Future<Response<dynamic>> submitPrivileges(dynamic data) {
    final $url = '/submit_privileges.php';
    final $body = data;
    final $request = Request('POST', $url, client.baseUrl, body: $body);
    return client.send<dynamic, dynamic>($request);
  }

  @override
  Future<Response<List<BackupFile>>> getBackupFiles() {
    final $url = '/get_backup_files.php';
    final $request = Request('GET', $url, client.baseUrl);
    return client.send<List<BackupFile>, BackupFile>($request);
  }

  @override
  Future<Response<List<TaskModel>>> getTasksFromServer() {
    final $url = '/get_tasks_from_server.php';
    final $request = Request('GET', $url, client.baseUrl);
    return client.send<List<TaskModel>, TaskModel>($request);
  }

  @override
  Future<Response<List<BrigadeModel>>> getBrigadesFromServer() {
    final $url = '/get_brigades_from_server.php';
    final $request = Request('GET', $url, client.baseUrl);
    return client.send<List<BrigadeModel>, BrigadeModel>($request);
  }

  @override
  Future<Response<List<User>>> getAdmins() {
    final $url = '/get_admins.php';
    final $request = Request('GET', $url, client.baseUrl);
    return client.send<List<User>, User>($request);
  }

  @override
  Future<Response<List<User>>> getBrigades() {
    final $url = '/get_brigades.php';
    final $request = Request('GET', $url, client.baseUrl);
    return client.send<List<User>, User>($request);
  }
}
