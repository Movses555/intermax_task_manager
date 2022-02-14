// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'send_notification.dart';

// **************************************************************************
// ChopperGenerator
// **************************************************************************

// ignore_for_file: always_put_control_body_on_new_line, always_specify_types, prefer_const_declarations, unnecessary_brace_in_string_interps
class _$Notify extends Notify {
  _$Notify([ChopperClient? client]) {
    if (client == null) return;
    this.client = client;
  }

  @override
  final definitionType = Notify;

  @override
  Future<Response<dynamic>> notify(dynamic data) {
    final $url = '/fcm/send';
    final $headers = {
      'Authorization':
          'key=AAAA--A2rHM:APA91bErvxIUm6FDHa6M4-UNSUxS6Iv2An-y7u0K4JN7tkdRPzMBFSv2OFZY0NoUYcgMUXkoJN64uyjJq74cOuc83scqXi8DRwtt22tztNB2-U46n58tu2DKc6sxmv-0gIp13E74T_3p',
      'Content-Type': 'application/json',
    };

    final $body = data;
    final $request =
        Request('POST', $url, client.baseUrl, body: $body, headers: $headers);
    return client.send<dynamic, dynamic>($request);
  }
}
