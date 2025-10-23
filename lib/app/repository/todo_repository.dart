import 'package:dio/dio.dart';
import 'package:mytodo/app/core/api_client.dart';
import 'package:mytodo/app/core/errors.dart';
import 'package:mytodo/app/model/todo_model.dart';

class TodoRepository {
  final _apiClient = ApiClient();

  Future<List<TodoModel>> fetchTodo() async {
    try {
      final response = await _apiClient.dio.get('todos');

      // Check if response has the expected structure
      if (response.data == null) {
        throw ApiException("Invalid response: no data received");
      }

      if (response.data is! Map<String, dynamic>) {
        throw ApiException("Invalid response format");
      }

      final data = response.data as Map<String, dynamic>;
      if (!data.containsKey('data')) {
        throw ApiException("Invalid response: missing data field");
      }

      final list = data['data'];
      if (list is! List) {
        throw ApiException("Invalid response: data is not a list");
      }

      return List<Map<String, dynamic>>.from(list)
          .map((e) => TodoModel.fromJson(e))
          .toList();
    } on DioException catch (e) {
      if (e.error is ApiException) throw e.error!;
      throw ApiException("Failed to fetch todos");
    } catch (e) {
      throw ApiException("Failed to fetch todos: ${e.toString()}");
    }
  }

  Future<TodoModel> create(Map<String, dynamic> payload) async {
    try {
      final response = await _apiClient.dio.post('todos', data: payload);

      // Check if response has the expected structure
      if (response.data == null) {
        throw ApiException("Invalid response: no data received");
      }

      if (response.data is! Map<String, dynamic>) {
        throw ApiException("Invalid response format");
      }

      final responseData = response.data as Map<String, dynamic>;
      if (!responseData.containsKey('data')) {
        throw ApiException("Invalid response: missing data field");
      }

      return TodoModel.fromJson(responseData['data']);
    } on DioException catch (e) {
      if (e.error is ApiException) throw e.error!;
      throw ApiException("Failed to create todo");
    } catch (e) {
      throw ApiException("Failed to create todo: ${e.toString()}");
    }
  }

  Future<TodoModel> update(int id, Map<String, dynamic> payload) async {
    try {
      final response =
          await _apiClient.dio.put('todos/${id.toString()}', data: payload);

      // Check if response has the expected structure
      if (response.data == null) {
        throw ApiException("Invalid response: no data received");
      }

      if (response.data is! Map<String, dynamic>) {
        throw ApiException("Invalid response format");
      }

      final responseData = response.data as Map<String, dynamic>;
      if (!responseData.containsKey('data')) {
        throw ApiException("Invalid response: missing data field");
      }

      return TodoModel.fromJson(responseData['data']);
    } on DioException catch (e) {
      if (e.error is ApiException) throw e.error!;
      throw ApiException("Failed to update todo");
    } catch (e) {
      throw ApiException("Failed to update todo: ${e.toString()}");
    }
  }

  Future<bool> delete(int id) async {
    try {
      final response = await _apiClient.dio.delete('todos/${id.toString()}');

      // Check if response has the expected structure
      if (response.data == null) {
        throw ApiException("Invalid response: no data received");
      }

      if (response.data is! Map<String, dynamic>) {
        throw ApiException("Invalid response format");
      }

      final responseData = response.data as Map<String, dynamic>;
      if (!responseData.containsKey('data')) {
        throw ApiException("Invalid response: missing data field");
      }
      if (responseData['success'] == true) {
        return true;
      } else {
        return false;
      }
    } on DioException catch (e) {
      if (e.error is ApiException) throw e.error!;
      throw ApiException("Failed to delete todo");
    } catch (e) {
      throw ApiException("Failed to delete todo: ${e.toString()}");
    }
  }
}
