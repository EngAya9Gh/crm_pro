import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/client_contact.dart';
import '../../domain/usecases/client_contacts_usecases.dart';
import 'client_contacts_state.dart';

class ClientContactsCubit extends Cubit<ClientContactsState> {
  final GetClientContactsUseCase getContactsUseCase;
  final AddClientContactUseCase addContactUseCase;
  final UpdateClientContactUseCase updateContactUseCase;
  final DeleteClientContactUseCase deleteContactUseCase;
  final MergeClientContactUseCase mergeContactUseCase;

  List<ClientContact> _contacts = [];

  ClientContactsCubit({
    required this.getContactsUseCase,
    required this.addContactUseCase,
    required this.updateContactUseCase,
    required this.deleteContactUseCase,
    required this.mergeContactUseCase,
  }) : super(ClientContactsInitial());

  Future<void> getContacts(String clientId) async {
    emit(ClientContactsLoading());
    try {
      _contacts = await getContactsUseCase(clientId);
      emit(ClientContactsLoaded(List.from(_contacts)));
    } catch (e) {
      emit(ClientContactsError(e.toString()));
    }
  }

  Future<void> addContact(String clientId, Map<String, dynamic> data) async {
    emit(ClientContactsOperationInProgress());
    try {
      final newContact = await addContactUseCase(clientId, data);
      // Remove old primary if new is primary
      if (newContact.isPrimary) {
        _contacts = _contacts.map((c) => c.copyWith(isPrimary: false)).toList();
      }
      _contacts.add(newContact);
      emit(ClientContactsOperationSuccess('تم إضافة جهة الاتصال بنجاح'));
      emit(ClientContactsLoaded(List.from(_contacts)));
    } catch (e) {
      emit(ClientContactsError(e.toString()));
      emit(ClientContactsLoaded(List.from(_contacts)));
    }
  }

  Future<void> updateContact(String clientId, int contactId, Map<String, dynamic> data) async {
    emit(ClientContactsOperationInProgress());
    try {
      final updatedContact = await updateContactUseCase(clientId, contactId, data);
      if (updatedContact.isPrimary) {
        _contacts = _contacts.map((c) => c.copyWith(isPrimary: false)).toList();
      }
      final index = _contacts.indexWhere((c) => c.id == contactId);
      if (index != -1) {
        _contacts[index] = updatedContact;
      }
      emit(ClientContactsOperationSuccess('تم تعديل جهة الاتصال بنجاح'));
      emit(ClientContactsLoaded(List.from(_contacts)));
    } catch (e) {
      emit(ClientContactsError(e.toString()));
      emit(ClientContactsLoaded(List.from(_contacts)));
    }
  }

  Future<void> deleteContact(String clientId, int contactId) async {
    emit(ClientContactsOperationInProgress());
    try {
      await deleteContactUseCase(clientId, contactId);
      _contacts.removeWhere((c) => c.id == contactId);
      emit(ClientContactsOperationSuccess('تم حذف جهة الاتصال بنجاح'));
      emit(ClientContactsLoaded(List.from(_contacts)));
    } catch (e) {
      emit(ClientContactsError(e.toString()));
      emit(ClientContactsLoaded(List.from(_contacts)));
    }
  }

  Future<void> mergeContact(String sourceClientId, String targetClientId, int contactId) async {
    emit(ClientContactsOperationInProgress());
    try {
      await mergeContactUseCase(sourceClientId, targetClientId, contactId);
      _contacts.removeWhere((c) => c.id == contactId);
      emit(ClientContactsOperationSuccess('تم دمج جهة الاتصال بنجاح'));
      emit(ClientContactsLoaded(List.from(_contacts)));
    } catch (e) {
      emit(ClientContactsError(e.toString()));
      emit(ClientContactsLoaded(List.from(_contacts)));
    }
  }
}
