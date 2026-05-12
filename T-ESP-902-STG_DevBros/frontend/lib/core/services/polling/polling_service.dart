import 'dart:async';

import 'package:http/http.dart' as http;
import 'package:inspiria/core/response/generic_responce.dart';

class PollingHandle {
  PollingHandle(this.response, this._cancel);

  final Future<GenericResponce> response;
  final void Function([String? reason]) _cancel;

  void cancel([String? reason]) => _cancel(reason);
}

class PollingService {

  PollingHandle startPolling(
    String url,
    Map<String, dynamic> params, {
    Duration interval = const Duration(seconds: 5),
    Duration timeout = const Duration(seconds: 30),
    int? maxAttempts,
    bool stopOnFirstFailure = false,
  }) {
    final completer = Completer<GenericResponce>();
    Timer? periodicTimer;
    Timer? timeoutTimer;
    int attempts = 0; /// pas sur que je laisse ça
    bool isRequestInFlight = false;

    void complete(GenericResponce response) {
      if (completer.isCompleted) return;
      completer.complete(response);
      periodicTimer?.cancel();
      timeoutTimer?.cancel();
    }

    Future<void> runPoll() async {
      if (completer.isCompleted || isRequestInFlight) return;
      if (maxAttempts != null && attempts >= maxAttempts) {
        complete(
          GenericResponce(
            statusCode: 429,
            errorMessage: 'Polling stopped after $attempts attempts',
          ),
        );
        return;
      }

      isRequestInFlight = true;
      attempts += 1;

      try {
        final response = await http.get(
          Uri.parse(url).replace(
            queryParameters: params.map(
              (key, value) => MapEntry(key, '$value'),
            ),
          ),
        );

        if (response.statusCode == 200) {
          complete(GenericResponce(statusCode: response.statusCode));
        } else if (stopOnFirstFailure) {
          complete(
            GenericResponce(
              statusCode: response.statusCode,
              errorMessage:
                  response.body.isNotEmpty
                      ? response.body
                      : 'Error ${response.statusCode}',
            ),
          );
        } else if (maxAttempts != null && attempts >= maxAttempts) {
          complete(
            GenericResponce(
              statusCode: response.statusCode,
              errorMessage:
                  response.body.isNotEmpty
                      ? response.body
                      : 'Polling stopped after $attempts attempts',
            ),
          );
        }
      } catch (e) {
        if (maxAttempts != null && attempts >= maxAttempts) {
          complete(
            GenericResponce(statusCode: 500, errorMessage: e.toString()),
          );
        }
      } finally {
        isRequestInFlight = false;
      }
    }

    periodicTimer = Timer.periodic(interval, (_) {
      unawaited(runPoll());
    });

    timeoutTimer = Timer(timeout, () {
      complete(
        GenericResponce(
          statusCode: 408,
          errorMessage: 'Polling timed out after ${timeout.inSeconds}s',
        ),
      );
    });

    // On appellera le premier call uniquement
    unawaited(runPoll());

    return PollingHandle(
      completer.future,
      ([String? reason]) => complete(
        GenericResponce(
          statusCode: 499,
          errorMessage: reason ?? 'Polling cancelled',
        ),
      ),
    );
  }
}
