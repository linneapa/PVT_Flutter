import 'package:http/http.dart' as http;
import 'package:mockito/mockito.dart';
import 'package:test/test.dart';
import 'package:ezsgame/api/Services.dart';
class MockClient extends Mock implements http.Client {}

main() {
  group('fetchPost', () {
    test('returns a Post if the http call completes successfully', () async {
      final client = MockClient();

      // Use Mockito to return a successful response when it calls the
      // provided http.Client.
      when(client.get(any))
          .thenAnswer((_) async => http.Response('{"title": "Test"}', 200));

      expect(await fetchParkingPost(client, null, null, true, false, false, false), const TypeMatcher<ParkingPost>());
    });

    test('throws an exception if the http call completes with an error', () {
      final client = MockClient();

      // Use Mockito to return an unsuccessful response when it calls the
      // provided http.Client.
      when(client.get(any))
          .thenAnswer((_) async => http.Response('Not Found', 404));

      expect(fetchParkingPost(client, null, null, true, false, false, false), throwsException);
    });

//    test('returns null if no vehicle i chosen', () {
//      final client = MockClient();
//
//      // Use Mockito to return an unsuccessful response when it calls the
//      // provided http.Client.
//      when(client.get(any))
//          .thenAnswer((_) async => http.Response('Not Found', 404));
//
//      expect(fetchParkingPost(client, null, null, false, false, false, false), null);
//    });
  });
}