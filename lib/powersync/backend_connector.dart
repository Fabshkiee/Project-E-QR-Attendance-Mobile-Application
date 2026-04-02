import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:powersync/powersync.dart';
import 'package:project_e_qr_app/services/auth_api.dart';

class MyBackendConnector extends PowerSyncBackendConnector {
  final PowerSyncDatabase db;
  final AuthApi _authApi;

  MyBackendConnector(this.db, {AuthApi? authApi}) : _authApi = authApi ?? AuthApi();

  @override
  Future<PowerSyncCredentials?> fetchCredentials() async {
    final endpoint = dotenv.env['INSTANCE_URL'];
    final token = await _authApi.getPowerSyncJwt();

    if (endpoint == null || endpoint.isEmpty) {
      throw StateError('Missing INSTANCE_URL in .env');
    }

    return PowerSyncCredentials(endpoint: endpoint, token: token);
  }

  // Implement uploadData to send local changes to your backend service
  // You can omit this method if you only want to sync data from the server to the client
  // See example implementation here: https://docs.powersync.com/client-sdks/reference/flutter#3-integrate-with-your-backend
  @override
  Future<void> uploadData(PowerSyncDatabase database) async {
    // This function is called whenever there is data to upload, whether the
    // device is online or offline.
    // If this call throws an error, it is retried periodically.

    final transaction = await database.getNextCrudTransaction();
    if (transaction == null) {
      return;
    }

    // The data that needs to be changed in the remote db
    for (var op in transaction.crud) {
      switch (op.op) {
        case UpdateType.put:
        // TODO: Instruct your backend API to CREATE a record
        case UpdateType.patch:
        // TODO: Instruct your backend API to PATCH a record
        case UpdateType.delete:
        //TODO: Instruct your backend API to DELETE a record
      }
    }

    // Completes the transaction and moves onto the next one
    await transaction.complete();
  }
}
