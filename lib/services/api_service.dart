import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:plastik60_app/config/constants.dart';
import 'package:plastik60_app/services/storage_service.dart';

enum RequestMethod { get, post, put, delete }

class ApiService {
  final StorageService? storageService;
  final http.Client _client = http.Client();

  ApiService({this.storageService});

  Future<String?> _getToken() async {
    if (storageService == null) return null;
    return await storageService!.getString(AppConstants.tokenKey);
  }

  Future<Map<String, String>> _getHeaders({bool requiresAuth = true}) async {
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    if (requiresAuth) {
      final token = await _getToken();
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }
    }

    return headers;
  }

  Future<dynamic> request({
    required String endpoint,
    required RequestMethod method,
    Map<String, dynamic>? data,
    Map<String, String>? queryParams,
    bool requiresAuth = true,
    bool handleError = true,
  }) async {
    try {
      var uri = Uri.parse(endpoint);

      if (queryParams != null) {
        uri = uri.replace(queryParameters: queryParams);
      }

      final headers = await _getHeaders(requiresAuth: requiresAuth);
      http.Response response;

      switch (method) {
        case RequestMethod.get:
          response = await _client.get(uri, headers: headers);
          break;
        case RequestMethod.post:
          response = await _client.post(
            uri,
            headers: headers,
            body: data != null ? json.encode(data) : null,
          );
          break;
        case RequestMethod.put:
          response = await _client.put(
            uri,
            headers: headers,
            body: data != null ? json.encode(data) : null,
          );
          break;
        case RequestMethod.delete:
          response = await _client.delete(
            uri,
            headers: headers,
            body: data != null ? json.encode(data) : null,
          );
          break;
      }

      if (response.statusCode >= 200 && response.statusCode < 300) {
        if (response.body.isEmpty) return null;
        return json.decode(response.body);
      } else {
        if (handleError) {
          _handleError(response);
        }
        return null;
      }
    } on SocketException {
      if (handleError) {
        throw Exception('No Internet connection');
      }
      return null;
    } catch (e) {
      if (handleError) {
        throw Exception('An error occurred: $e');
      }
      return null;
    }
  }

  void _handleError(http.Response response) {
    try {
      final errorData = json.decode(response.body);
      final errorMessage = errorData['message'] ?? 'An error occurred';
      throw Exception(errorMessage);
    } catch (e) {
      throw Exception('An error occurred: ${response.statusCode}');
    }
  }

  // Helper methods for common HTTP methods
  Future<dynamic> get(
    String endpoint, {
    Map<String, String>? queryParams,
    bool requiresAuth = true,
    bool handleError = true,
  }) async {
    return request(
      endpoint: endpoint,
      method: RequestMethod.get,
      queryParams: queryParams,
      requiresAuth: requiresAuth,
      handleError: handleError,
    );
  }

  Future<dynamic> post(
    String endpoint, {
    Map<String, dynamic>? data,
    bool requiresAuth = true,
    bool handleError = true,
  }) async {
    return request(
      endpoint: endpoint,
      method: RequestMethod.post,
      data: data,
      requiresAuth: requiresAuth,
      handleError: handleError,
    );
  }

  Future<dynamic> put(
    String endpoint, {
    Map<String, dynamic>? data,
    bool requiresAuth = true,
    bool handleError = true,
  }) async {
    return request(
      endpoint: endpoint,
      method: RequestMethod.put,
      data: data,
      requiresAuth: requiresAuth,
      handleError: handleError,
    );
  }

  Future<dynamic> delete(
    String endpoint, {
    Map<String, dynamic>? data,
    bool requiresAuth = true,
    bool handleError = true,
  }) async {
    return request(
      endpoint: endpoint,
      method: RequestMethod.delete,
      data: data,
      requiresAuth: requiresAuth,
      handleError: handleError,
    );
  }

  // File upload method
  Future<dynamic> uploadFile(
    String endpoint,
    File file, {
    String fileField = 'file',
    Map<String, String>? fields,
    bool requiresAuth = true,
    bool handleError = true,
  }) async {
    try {
      final uri = Uri.parse(endpoint);
      final headers = await _getHeaders(requiresAuth: requiresAuth);

      // Remove Content-Type header as it will be set by the multipart request
      headers.remove('Content-Type');

      final request = http.MultipartRequest('POST', uri);
      request.headers.addAll(headers);

      // Add file
      final fileStream = http.ByteStream(file.openRead());
      final fileLength = await file.length();
      final multipartFile = http.MultipartFile(
        fileField,
        fileStream,
        fileLength,
        filename: file.path.split('/').last,
      );
      request.files.add(multipartFile);

      // Add other fields if provided
      if (fields != null) {
        request.fields.addAll(fields);
      }

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        if (response.body.isEmpty) return null;
        return json.decode(response.body);
      } else {
        if (handleError) {
          _handleError(response);
        }
        return null;
      }
    } catch (e) {
      if (handleError) {
        throw Exception('An error occurred during file upload: $e');
      }
      return null;
    }
  }
}
