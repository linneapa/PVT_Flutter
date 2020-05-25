import 'package:ezsgame/api/ParkingSpace.dart';
import 'package:ezsgame/api/Services.dart';
import 'package:mockito/mockito.dart';
import 'package:http/http.dart' as http;
import 'package:test/test.dart';

class MockClient extends Mock implements http.Client {}

main(){
  group('fetchParkering', () {
    test('returns a Parkering if the http call completes successfully', () async {
      final client = MockClient();
      // Use Mockito to return a successful response when it calls the
      // provided http.Client.
      when(client.get('https://openparking.stockholm.se/LTF-Tolken/v1/ptillaten/all?maxFeatures=100&outputFormat=json&apiKey=c9e27b4b-e374-41b5-b741-00b90cbe2d97'))
          .thenAnswer((_) async => http.Response('{"title": "Test"}', 200));

      expect(await Services.fetchParkering(client, true, false, false, false), const TypeMatcher<Parkering>());
    });

    test('throws an exception if the http call completes with an error', () {
      final client = MockClient();

      // Use Mockito to return an unsuccessful response when it calls the
      // provided http.Client.
      when(client.get('https://openparking.stockholm.se/LTF-Tolken/v1/ptillaten/all?maxFeatures=100&outputFormat=json&apiKey=c9e27b4b-e374-41b5-b741-00b90cbe2d97'))
          .thenAnswer((_) async => http.Response('Not Found', 404));

      //when(Services.fetchParkering(true, false, false, false)).thenAnswer((_) async => http.Response('Not Found', 404));
      //when(client.get(Services.fetchParkering(true, false, false, false))).thenAnswer((realInvocation) => null);

      expect(Services.fetchParkering(client, true, false, false, false), throwsException);
    });
  });
}