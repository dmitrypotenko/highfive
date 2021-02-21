import 'package:chopper/chopper.dart';
import 'package:json_annotation/json_annotation.dart';

part "firebase_functions_client.chopper.dart";
part 'firebase_functions_client.g.dart';

@ChopperApi(baseUrl: "https://us-central1-highfive-311f2.cloudfunctions.net")
abstract class FirebaseFunctionClient extends ChopperService {
  @Post(path: "/sendPushNotification")
  Future<Response> sendPush(@Body() SendHighFiveRequest request);

  // helper methods that help you instantiate your service
  static FirebaseFunctionClient create([ChopperClient client]) => _$FirebaseFunctionClient(client);
}

@JsonSerializable()
class SendHighFiveRequest {
  List<String> to;
  String from;
  String comment;
  String highfiveId;

  SendHighFiveRequest(this.to, this.from, this.comment, this.highfiveId);

  Map<String, dynamic> toJson() => _$SendHighFiveRequestToJson(this);
}
