import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../domain/entities/invoice_payment.dart';
import '../../../domain/usecases/get_invoice_payments_usecase.dart';
import '../../../domain/usecases/add_invoice_payment_usecase.dart';
import '../../../domain/usecases/update_invoice_payment_usecase.dart';
import '../../../domain/usecases/delete_invoice_payment_usecase.dart';

// States
abstract class InvoicePaymentsState extends Equatable {
  const InvoicePaymentsState();

  @override
  List<Object?> get props => [];
}

class InvoicePaymentsInitial extends InvoicePaymentsState {}

class InvoicePaymentsLoading extends InvoicePaymentsState {}

class InvoicePaymentsLoaded extends InvoicePaymentsState {
  final List<InvoicePayment> payments;

  const InvoicePaymentsLoaded(this.payments);

  @override
  List<Object?> get props => [payments];
}

class InvoicePaymentsOperationSuccess extends InvoicePaymentsState {
  final String message;

  const InvoicePaymentsOperationSuccess(this.message);

  @override
  List<Object?> get props => [message];
}

class InvoicePaymentsError extends InvoicePaymentsState {
  final String message;

  const InvoicePaymentsError(this.message);

  @override
  List<Object?> get props => [message];
}

// Cubit
class InvoicePaymentsCubit extends Cubit<InvoicePaymentsState> {
  final GetInvoicePaymentsUseCase getPayments;
  final AddInvoicePaymentUseCase addPayment;
  final UpdateInvoicePaymentUseCase updatePayment;
  final DeleteInvoicePaymentUseCase deletePayment;

  InvoicePaymentsCubit({
    required this.getPayments,
    required this.addPayment,
    required this.updatePayment,
    required this.deletePayment,
  }) : super(InvoicePaymentsInitial());

  Future<void> loadPayments(int invoiceId) async {
    if (isClosed) return;
    emit(InvoicePaymentsLoading());
    final result = await getPayments(invoiceId);
    if (isClosed) return;
    result.fold(
      (failure) => emit(InvoicePaymentsError(failure.message)),
      (payments) => emit(InvoicePaymentsLoaded(payments)),
    );
  }

  Future<void> createPayment(int invoiceId, Map<String, dynamic> data) async {
    if (isClosed) return;
    emit(InvoicePaymentsLoading());
    final result = await addPayment(invoiceId, data);
    if (isClosed) return;
    result.fold((failure) => emit(InvoicePaymentsError(failure.message)), (
      payment,
    ) {
      if (isClosed) return;
      emit(const InvoicePaymentsOperationSuccess('تم إضافة الدفعة بنجاح'));
      loadPayments(invoiceId);
    });
  }

  Future<void> editPayment(
    int invoiceId,
    int paymentId,
    Map<String, dynamic> data,
  ) async {
    if (isClosed) return;
    emit(InvoicePaymentsLoading());
    final result = await updatePayment(invoiceId, paymentId, data);
    if (isClosed) return;
    result.fold((failure) => emit(InvoicePaymentsError(failure.message)), (
      payment,
    ) {
      if (isClosed) return;
      emit(const InvoicePaymentsOperationSuccess('تم تعديل الدفعة بنجاح'));
      loadPayments(invoiceId);
    });
  }

  Future<void> removePayment(int invoiceId, int paymentId) async {
    if (isClosed) return;
    emit(InvoicePaymentsLoading());
    final result = await deletePayment(invoiceId, paymentId);
    if (isClosed) return;
    result.fold((failure) => emit(InvoicePaymentsError(failure.message)), (_) {
      if (isClosed) return;
      emit(const InvoicePaymentsOperationSuccess('تم حذف الدفعة بنجاح'));
      loadPayments(invoiceId);
    });
  }
}
