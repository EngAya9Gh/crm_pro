import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/client_contact.dart';
import '../../../../core/services/network/api_client.dart';
import '../../../../core/utils/end_points.dart';
import '../../data/models/client_contact_model.dart';

abstract class GlobalContactsState {}

class GlobalContactsInitial extends GlobalContactsState {}

class GlobalContactsLoading extends GlobalContactsState {}

class GlobalContactsLoaded extends GlobalContactsState {
  final List<ClientContact> contacts;
  final bool hasReachedMax;

  GlobalContactsLoaded(this.contacts, {this.hasReachedMax = false});
}

class GlobalContactsError extends GlobalContactsState {
  final String message;
  GlobalContactsError(this.message);
}

class GlobalContactsCubit extends Cubit<GlobalContactsState> {
  final ApiClient _apiClient;

  GlobalContactsCubit(this._apiClient) : super(GlobalContactsInitial());

  int _currentPage = 1;
  bool _hasReachedMax = false;
  List<ClientContact> _contacts = [];
  Map<String, dynamic> _currentFilters = {};

  Future<void> fetchContacts({Map<String, dynamic>? filters, bool isRefresh = false}) async {
    if (isRefresh) {
      _currentPage = 1;
      _hasReachedMax = false;
      _contacts.clear();
      _currentFilters = filters ?? _currentFilters;
      emit(GlobalContactsLoading());
    } else if (_hasReachedMax) {
      return;
    }

    try {
      final queryParams = {
        'page': _currentPage,
        'per_page': 15,
        ..._currentFilters,
      };

      final response = await _apiClient.dio.get(
        EndPoints.globalContacts,
        queryParameters: queryParams,
      );

      List<ClientContact> fetchedContacts = [];
      
      // Handle both paginated response or direct list
      dynamic data = response.data;
      
      // Unpack success wrapper if it exists
      if (data is Map && data.containsKey('success') && data['data'] != null) {
        data = data['data'];
      }

      if (data is Map) {
        if (data.containsKey('data')) {
          final listData = data['data'];
          if (listData is List) {
            fetchedContacts = listData.map((e) => ClientContactModel.fromJson(e as Map<String, dynamic>)).toList();
          } else if (listData is Map && listData.containsKey('data') && listData['data'] is List) {
            fetchedContacts = (listData['data'] as List).map((e) => ClientContactModel.fromJson(e as Map<String, dynamic>)).toList();
          }
        }
        
        dynamic meta;
        if (data.containsKey('meta')) {
          meta = data['meta'];
        } else if (data.containsKey('last_page')) {
          meta = data;
        }

        if (meta != null && meta['last_page'] != null) {
          _hasReachedMax = _currentPage >= (int.tryParse(meta['last_page'].toString()) ?? 1);
        } else {
          _hasReachedMax = fetchedContacts.isEmpty || fetchedContacts.length < 15;
        }
      } else if (data is List) {
        fetchedContacts = data.map((e) => ClientContactModel.fromJson(e as Map<String, dynamic>)).toList();
        _hasReachedMax = true; // Assuming list means no pagination
      }

      _contacts.addAll(fetchedContacts);
      _currentPage++;

      emit(GlobalContactsLoaded(List.from(_contacts), hasReachedMax: _hasReachedMax));
    } catch (e) {
      emit(GlobalContactsError(e.toString()));
    }
  }
}
