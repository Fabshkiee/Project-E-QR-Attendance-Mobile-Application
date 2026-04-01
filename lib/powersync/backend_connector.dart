import 'package:powersync/powersync.dart';

class MyBackendConnector extends PowerSyncBackendConnector {
  PowerSyncDatabase db;

  MyBackendConnector(this.db);
  @override
  Future<PowerSyncCredentials?> fetchCredentials() async {
    // Implement fetchCredentials to obtain a JWT from your authentication service. 
    // See https://docs.powersync.com/configuration/auth/overview
    // See example implementation here: https://pub.dev/documentation/powersync/latest/powersync/DevConnector/fetchCredentials.html

    return PowerSyncCredentials(
      endpoint: 'https://xxxxxx.powersync.journeyapps.com',
      // Use a development token (see Authentication Setup https://docs.powersync.com/configuration/auth/development-tokens) to get up and running quickly
      token: 'An authentication token'
    );
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