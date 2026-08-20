import 'package:crm_wakeel/core/common/widgets/app_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../../core/services/di/di_container.dart';
import '../../domain/entities/client_procedure.dart';
import '../bloc/cubits/client_procedures_cubit.dart';

class ClientProceduresTab extends StatelessWidget {
  final String clientId;

  const ClientProceduresTab({super.key, required this.clientId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          getIt<ClientProceduresCubit>()..loadProcedures(clientId),
      child: _ClientProceduresView(clientId: clientId),
    );
  }
}

class _ClientProceduresView extends StatelessWidget {
  final String clientId;

  const _ClientProceduresView({required this.clientId});

  void _showProcedureDialog(
    BuildContext context, {
    ClientProcedure? procedure,
  }) {
    showDialog(
      context: context,
      builder: (dialogContext) => _ProcedureDialog(
        clientId: clientId,
        procedure: procedure,
        cubit: context.read<ClientProceduresCubit>(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        BlocBuilder<ClientProceduresCubit, ClientProceduresState>(
          builder: (context, state) {
            if (state is ClientProceduresLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is ClientProceduresError) {
              return Center(child: Text('Error: ${state.message}'));
            } else if (state is ClientProceduresLoaded) {
              return SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 50,
                  vertical: 16,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.orange.withValues(alpha: 0.1),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.check_circle_outline,
                            color: Colors.orange,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const AppText(
                          'إجراءات العمل',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    if (state.procedures.isEmpty)
                      const Center(child: AppText('لا توجد إجراءات حالياً'))
                    else
                      ...state.procedures.map(
                        (procedure) => Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: _ProcedureCard(
                            procedure: procedure,
                            onEdit: () => _showProcedureDialog(
                              context,
                              procedure: procedure,
                            ),
                            onDelete: () {
                              context
                                  .read<ClientProceduresCubit>()
                                  .deleteExistingProcedure(
                                    clientId,
                                    procedure.id,
                                  );
                            },
                          ),
                        ),
                      ),

                    const SizedBox(height: 24),
                    const AppText(
                      'ملاحظات المتابعة',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.grey.withValues(
                          alpha: 0.1,
                        ), // Match image light grey bg
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const AppText(
                        'العميل مهتم جداً بتقنيات الذكاء الاصطناعي، يحتاج لعرض فني مفصل قبل نهاية الأسبوع.',
                        style: TextStyle(color: Colors.grey, height: 1.5),
                      ),
                    ),
                    const SizedBox(height: 80), // Space for FAB
                  ],
                ),
              );
            }
            return const SizedBox.shrink();
          },
        ),
        Positioned(
          bottom: 16,
          right: 16,
          child: FloatingActionButton(
            backgroundColor: Colors.orange,
            onPressed: () => _showProcedureDialog(context),
            child: const Icon(Icons.add, color: Colors.white),
          ),
        ),
      ],
    );
  }
}

class _ProcedureCard extends StatelessWidget {
  final ClientProcedure procedure;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _ProcedureCard({
    required this.procedure,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final isCompleted = procedure.status == 'completed';
    // Style from image:
    // Completed: Green border, white bg (or very light green tint), green Check icon.
    // Pending: Grey/Light border, white bg, Orange Clock icon.

    final borderColor = isCompleted
        ? Colors.green.withValues(alpha: 0.5)
        : Colors.grey.shade300;
    final iconData = isCompleted
        ? Icons.check_circle
        : Icons.access_time_filled; // Or outlined clock

    return InkWell(
      onTap: onEdit, // Allow tap to edit
      onLongPress: onDelete, // Simple way to delete or show menu
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: borderColor),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Status Icon (Right side in RTL)
            Container(
              padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isCompleted ? Colors.green : Colors.white,
                border: isCompleted
                    ? null
                    : Border.all(color: Colors.orange, width: 2),
              ),
              child: Icon(
                iconData,
                color: isCompleted ? Colors.white : Colors.orange,
                size: 20, // Smaller visual size inside the circle like image
              ),
            ),
            const SizedBox(width: 16),

            // Content (Left side in RTL)
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppText(
                    procedure.title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (procedure.description.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    AppText(
                      procedure.description,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      // User name
                      if (procedure.completedBy != null) ...[
                        Icon(
                          Icons.person,
                          size: 14,
                          color: Colors.grey.shade400,
                        ),
                        const SizedBox(width: 4),
                        AppText(
                          procedure.completedBy?.name ?? '',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey.shade400,
                          ),
                        ),
                        const SizedBox(width: 12),
                      ],
                      // Date
                      if (procedure.dueDate != null) ...[
                        Icon(
                          Icons.calendar_month,
                          size: 14,
                          color: Colors.grey.shade400,
                        ),
                        const SizedBox(width: 4),
                        AppText(
                          DateFormat('yyyy-MM-dd').format(procedure.dueDate!),
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey.shade400,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProcedureDialog extends StatefulWidget {
  final String clientId;
  final ClientProcedure? procedure;
  final ClientProceduresCubit cubit;

  const _ProcedureDialog({
    required this.clientId,
    this.procedure,
    required this.cubit,
  });

  @override
  State<_ProcedureDialog> createState() => _ProcedureDialogState();
}

class _ProcedureDialogState extends State<_ProcedureDialog> {
  late TextEditingController _titleController;
  late TextEditingController _descController;
  DateTime? _dueDate;
  String _status = 'pending';

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(
      text: widget.procedure?.title ?? '',
    );
    _descController = TextEditingController(
      text: widget.procedure?.description ?? '',
    );
    _dueDate = widget.procedure?.dueDate;
    _status = widget.procedure?.status ?? 'pending';
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        widget.procedure == null ? 'New Procedure' : 'Edit Procedure',
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: 'Title'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _descController,
              decoration: const InputDecoration(labelText: 'Description'),
              maxLines: 3,
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: _status,
              decoration: const InputDecoration(labelText: 'Status'),
              items: const [
                DropdownMenuItem(value: 'pending', child: Text('Pending')),
                DropdownMenuItem(value: 'completed', child: Text('Completed')),
              ],
              onChanged: (val) {
                if (val != null) setState(() => _status = val);
              },
            ),
            const SizedBox(height: 12),
            InkWell(
              onTap: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: _dueDate ?? DateTime.now(),
                  firstDate: DateTime(2000),
                  lastDate: DateTime(2100),
                );
                if (date != null) setState(() => _dueDate = date);
              },
              child: InputDecorator(
                decoration: const InputDecoration(labelText: 'Due Date'),
                child: Text(
                  _dueDate != null
                      ? DateFormat('yyyy-MM-dd').format(_dueDate!)
                      : 'Select Date',
                ),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            if (_titleController.text.isEmpty) return;

            final newProcedure = ClientProcedure(
              id: widget.procedure?.id ?? 0, // 0 for new
              title: _titleController.text,
              description: _descController.text,
              status: _status,
              dueDate: _dueDate,
              createdAt: widget.procedure?.createdAt ?? DateTime.now(),
              // other fields ignored or managed by backend
            );

            if (widget.procedure == null) {
              widget.cubit.addNewProcedure(widget.clientId, newProcedure);
            } else {
              widget.cubit.updateExistingProcedure(
                widget.clientId,
                newProcedure,
              );
            }
            Navigator.pop(context);
          },
          child: const Text('Save'),
        ),
      ],
    );
  }
}
