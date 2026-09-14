import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:crm_wakeel/core/common/widgets/app_text.dart';
import 'package:crm_wakeel/core/common/widgets/app_scaffold.dart';
import 'package:crm_wakeel/core/common/widgets/app_text_field.dart';
import 'package:crm_wakeel/core/common/widgets/app_dropdown.dart';
import 'package:crm_wakeel/core/config/theme/color_scheme.dart';
import '../bloc/appointments_bloc.dart';
import '../bloc/appointments_event.dart';
import '../bloc/appointments_state.dart';
import '../../../../features/settings/presentation/bloc/lookups_bloc.dart';
import '../../../../features/settings/presentation/bloc/lookups_state.dart';

class AddEditAppointmentScreen extends StatefulWidget {
  final int? appointmentId;

  const AddEditAppointmentScreen({super.key, this.appointmentId});

  @override
  State<AddEditAppointmentScreen> createState() =>
      _AddEditAppointmentScreenState();
}

class _AddEditAppointmentScreenState extends State<AddEditAppointmentScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _locationController = TextEditingController();
  int? _selectedClientId;
  int? _selectedUserId;

  DateTime _startDate = DateTime.now();
  TimeOfDay _startTime = const TimeOfDay(hour: 9, minute: 0);
  int _durationMinutes = 60;
  String _selectedStatus = 'scheduled';
  String _selectedType = 'meeting';

  bool get isEdit => widget.appointmentId != null;

  @override
  void initState() {
    super.initState();
    context.read<AppointmentsBloc>().add(const GetAppointmentClientsEvent());
    if (isEdit) {
      context.read<AppointmentsBloc>().add(
        GetAppointmentDetailsEvent(widget.appointmentId!),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: isEdit ? 'تعديل موعد' : 'موعد جديد',
      body: BlocConsumer<AppointmentsBloc, AppointmentsState>(
        listener: (context, state) {
          if (state.operationStatus == AppointmentOperationStatus.success) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: AppText(state.operationMessage)));
            Navigator.pop(context);
          } else if (state.operationStatus ==
              AppointmentOperationStatus.failure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: AppText(state.operationMessage),
                backgroundColor: AppColorScheme.error,
              ),
            );
          }

          if (state.detailStatus == AppointmentsStatus.success &&
              isEdit &&
              _titleController.text.isEmpty) {
            final appt = state.appointmentDetail!;
            _titleController.text = appt.title;
            _descriptionController.text = appt.description ?? '';
            _locationController.text = appt.location ?? '';
            _startDate = appt.startAt;
            _startTime = TimeOfDay.fromDateTime(appt.startAt);
            _durationMinutes = appt.endAt.difference(appt.startAt).inMinutes;
            _selectedStatus = appt.status;
            _selectedType = appt.type;
            _selectedClientId = appt.clientId;
            _selectedUserId = appt.userId;
          }
        },
        builder: (context, state) {
          if (state.operationStatus == AppointmentOperationStatus.loading ||
              (isEdit && state.detailStatus == AppointmentsStatus.loading)) {
            return const Center(child: CircularProgressIndicator());
          }

          return Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(24),
              children: [
                AppTextField(
                  controller: _titleController,
                  label: 'عنوان الموعد',
                  hintText: 'مثال: اجتماع عرض السعر',
                  validator: (v) => v!.isEmpty ? 'مطلوب' : null,
                ),
                const SizedBox(height: 16),
                _buildDateTimePicker(),
                const SizedBox(height: 16),
                DropdownButtonFormField<int>(
                  value: _durationMinutes,
                  decoration: const InputDecoration(
                    labelText: 'المدة (بالدقائق)',
                    border: OutlineInputBorder(),
                  ),
                  items: [15, 30, 45, 60, 90, 120]
                      .map(
                        (m) => DropdownMenuItem(
                          value: m,
                          child: AppText('$m دقيقة'),
                        ),
                      )
                      .toList(),
                  onChanged: (v) => setState(() => _durationMinutes = v!),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: _selectedType,
                  decoration: const InputDecoration(
                    labelText: 'نوع الموعد',
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem(
                      value: 'meeting',
                      child: AppText('اجتماع'),
                    ),
                    DropdownMenuItem(value: 'call', child: AppText('هاتف')),
                    DropdownMenuItem(value: 'visit', child: AppText('زيارة')),
                  ],
                  onChanged: (v) => setState(() => _selectedType = v!),
                ),
                const SizedBox(height: 16),
                AppTextField(
                  controller: _locationController,
                  label: 'الموقع/الرابط',
                  hintText: 'مثال: مكتب الرياض أو Zoom',
                ),
                const SizedBox(height: 16),
                if (state.isClientsLoading)
                  const Center(child: LinearProgressIndicator())
                else
                  AppDropdown<int>(
                    label: 'العميل',
                    hint: 'اختر العميل',
                    value: _selectedClientId,
                    legacyItems: () {
                      final items = state.clientList.map((client) {
                        return DropdownMenuItem<int>(
                          value: client.id,
                          child: AppText(client.name),
                        );
                      }).toList();

                      if (isEdit &&
                          state.appointmentDetail != null &&
                          state.appointmentDetail!.clientId != null) {
                        final appt = state.appointmentDetail!;
                        final exists = state.clientList.any(
                          (c) => c.id == appt.clientId,
                        );
                        if (!exists) {
                          items.insert(
                            0,
                            DropdownMenuItem<int>(
                              value: appt.clientId,
                              child: AppText(
                                appt.clientName ?? 'العميل الحالي',
                              ),
                            ),
                          );
                        }
                      }
                      return items;
                    }(),
                    itemLabel: (id) {
                      if (isEdit &&
                          state.appointmentDetail != null &&
                          state.appointmentDetail!.clientId == id) {
                        return state.appointmentDetail!.clientName ?? '';
                      }
                      final client = state.clientList
                          .where((c) => c.id == id)
                          .firstOrNull;
                      return client?.name ?? '';
                    },
                    onChanged: (value) {
                      setState(() {
                        _selectedClientId = value;
                      });
                    },
                    validator: (value) => value == null ? 'مطلوب' : null,
                  ),
                const SizedBox(height: 16),
                BlocBuilder<LookupsBloc, LookupsState>(
                  builder: (context, lookupsState) {
                    if (lookupsState is! LookupsLoaded) {
                      return const SizedBox.shrink();
                    }
                    return AppDropdown<int>(
                      label: 'الموظف المسؤول (اختياري)',
                      hint: 'سيتم تعيينك كمسؤول افتراضياً',
                      value: _selectedUserId,
                      legacyItems: lookupsState.employees.map((emp) {
                        return DropdownMenuItem<int>(
                          value: emp.id,
                          child: AppText(emp.name),
                        );
                      }).toList(),
                      itemLabel: (id) =>
                          lookupsState.employees
                              .where((e) => e.id == id)
                              .firstOrNull
                              ?.name ??
                          '',
                      onChanged: (value) {
                        setState(() {
                          _selectedUserId = value;
                        });
                      },
                    );
                  },
                ),
                const SizedBox(height: 16),
                AppTextField(
                  controller: _descriptionController,
                  label: 'ملاحظات إضافية',
                  maxLines: 3,
                ),
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColorScheme.primary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: AppText(
                    isEdit ? 'حفظ التعديلات' : 'تأكيد الموعد',
                    style: const TextStyle(
                      color: AppColorScheme.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildDateTimePicker() {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: InkWell(
            onTap: _selectDate,
            child: InputDecorator(
              decoration: const InputDecoration(
                labelText: 'التاريخ',
                border: OutlineInputBorder(),
              ),
              child: AppText(DateFormat('yyyy/MM/dd').format(_startDate)),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: InkWell(
            onTap: _selectTime,
            child: InputDecorator(
              decoration: const InputDecoration(
                labelText: 'البدء',
                border: OutlineInputBorder(),
              ),
              child: AppText(_startTime.format(context)),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _startDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) setState(() => _startDate = picked);
  }

  Future<void> _selectTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _startTime,
    );
    if (picked != null) setState(() => _startTime = picked);
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedClientId == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: AppText('الرجاء اختيار العميل')));
      return;
    }

    final startAt = DateTime(
      _startDate.year,
      _startDate.month,
      _startDate.day,
      _startTime.hour,
      _startTime.minute,
    );
    final endAt = startAt.add(Duration(minutes: _durationMinutes));

    final data = {
      'title': _titleController.text,
      'description': _descriptionController.text,
      'location': _locationController.text,
      'client_id': _selectedClientId,
      if (_selectedUserId != null) 'user_id': _selectedUserId,
      'start_at': startAt.toIso8601String(),
      'end_at': endAt.toIso8601String(),
      'status': _selectedStatus,
      'type': _selectedType,
    };

    if (isEdit) {
      context.read<AppointmentsBloc>().add(
        UpdateAppointmentEvent(widget.appointmentId!, data),
      );
    } else {
      context.read<AppointmentsBloc>().add(CreateAppointmentEvent(data));
    }
  }
}
