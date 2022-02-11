import 'package:chopper/chopper.dart';

part 'send_notification.chopper.dart';

@ChopperApi()
abstract class Notify extends ChopperService{

  static const String _key = "AAAA--A2rHM:APA91bErvxIUm6FDHa6M4-UNSUxS6Iv2An-y7u0K4JN7tkdRPzMBFSv2OFZY0NoUYcgMUXkoJN64uyjJq74cOuc83scqXi8DRwtt22tztNB2-U46n58tu2DKc6sxmv-0gIp13E74T_3p";

  @Post(path: '/fcm/send', headers: {
    'Authorization' : 'key=$_key',
    'Content-Type' : 'application/json'
  })
  Future<Response> notify(@Body() var data);

  static Notify create(){
    final client = ChopperClient(
      baseUrl: 'https://fcm.googleapis.com',
      services: [_$Notify()],
      converter: const JsonConverter(),
    );

    return _$Notify(client);
  }
}