import 'package:permission_handler/permission_handler.dart';

class PermissionService {
  Future<PermissionStatus> askForPermission() async {
    var status = await Permission.contacts.status;
    if (status.isUndetermined || status.isDenied) {
      return Permission.contacts.request();
    }
    return status;
  }
}
