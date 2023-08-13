import 'dart:math';

import 'package:dio/dio.dart';
import 'package:fresh_dio/fresh_dio.dart';
import 'package:jsonplaceholder_client/jsonplaceholder_client.dart';
import 'package:jsonplaceholder_client/src/models/tokens.dart';

class PhotosRequestFailureException implements Exception {}

class JsonplaceholderClient {
  JsonplaceholderClient({Dio? httpClient}) {
    _httpClient = (httpClient ?? Dio())
      ..options.baseUrl = 'https://jsonplaceholder.typicode.com'
      ..interceptors.add(
        LogInterceptor(request: false, responseHeader: false),
      );

    var refreshCount = 0;

    _fresh = Fresh<Tokens>(
      httpClient: _httpClient,
      shouldRefresh: (response) {
        final isFirst = refreshCount == 0;
        refreshCount += 1;
        return isFirst;
      },
      tokenStorage: InMemoryTokenStorage<Tokens>(),
      tokenHeader: (token) => {'Authorization': 'Bearer ${token.access}'},
      refreshToken: (token, _) async {
        if (token == null) throw RevokeTokenException();

        try {
          await Dio().post(
            'https://jsonplaceholder.typicode.com/posts',
          );
        } catch (_) {
          throw RevokeTokenException();
        }

        return Tokens(access: 'access', refresh: 'refresh');
      },
    );

    _httpClient.interceptors.add(_fresh);
  }

  late final Dio _httpClient;
  late final Fresh<Tokens> _fresh;

  Stream<AuthenticationStatus> get authenticationStatus =>
      _fresh.authenticationStatus;

  Future<void> authenticate({
    required String username,
    required String password,
  }) async {
    await Future<void>.delayed(const Duration(seconds: 1));
    await _fresh.setToken(Tokens(refresh: '', access: ''));
  }

  Future<void> unauthenticate() async {
    await Future<void>.delayed(const Duration(seconds: 1));
    await _fresh.setToken(null);
  }

  Future<List<Photo>> photos() async {
    final response = await _httpClient.get<dynamic>('/photos');

    if (response.statusCode != 200) {
      throw PhotosRequestFailureException();
    }

    return (response.data as List)
        .map((dynamic item) => Photo.fromJson(item as Map<String, dynamic>))
        .toList();
  }
}
