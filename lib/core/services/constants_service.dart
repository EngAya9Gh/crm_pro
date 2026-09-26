import 'package:dio/dio.dart';
import 'network/api_client.dart';
import '../utils/end_points.dart';

class ConstantsService {
  final ApiClient _apiClient;

  Map<String, List<String>> ticketStatuses = {};
  Map<String, List<String>> ticketPriorities = {};
  Map<String, List<String>> ticketSources = {};
  Map<String, List<String>> evaluationChannels = {};
  Map<String, List<String>> contactPositions = {};

  ConstantsService({required ApiClient apiClient}) : _apiClient = apiClient;

  Future<void> fetchConstants() async {
    try {
      final response = await _apiClient.dio.get(EndPoints.constants);
      if (response.data != null && response.data is Map) {
        final data = response.data as Map<String, dynamic>;
        
        ticketStatuses = _parseMapList(data['ticket_statuses']);
        ticketPriorities = _parseMapList(data['ticket_priorities']);
        ticketSources = _parseMapList(data['ticket_sources']);
        evaluationChannels = _parseMapList(data['evaluation_channels']);
        contactPositions = _parseMapList(data['contact_positions']);
      }
    } catch (e) {
      print('Failed to fetch constants: $e');
    }
  }

  Map<String, List<String>> _parseMapList(dynamic data) {
    if (data is Map) {
      return data.map((key, value) {
        if (value is List) {
          return MapEntry(key.toString(), value.map((e) => e.toString()).toList());
        }
        return MapEntry(key.toString(), []);
      });
    }
    return {};
  }
}
