import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:crm_wakeel/core/common/widgets/app_text.dart';
import '../../../../features/appointments/domain/entities/appointment.dart';
import '../../../../core/config/theme/color_scheme.dart';
import '../../../../core/config/theme/typography.dart';
import '../../../../core/services/di/di_container.dart';
import '../bloc/cubits/client_appointments_cubit.dart';
import '../../../../features/appointments/presentation/widgets/appointment_card.dart';
import '../../../../features/appointments/presentation/views/appointments_screen.dart';
import '../../../../features/appointments/presentation/views/appointment_details_screen.dart';
import '../../../../features/appointments/presentation/bloc/appointments_bloc.dart';

class ClientAppointmentsTab extends StatelessWidget {
  final String clientId;
  final List<Appointment>? initialAppointments;

  const ClientAppointmentsTab({
    super.key,
    required this.clientId,
    this.initialAppointments,
  });

  @override
  Widget build(BuildContext context) {
    // Only load if not initial
    return BlocProvider(
      create: (context) {
        final cubit = getIt<ClientAppointmentsCubit>();
        // If we have initial data, we might want to use it or just refresh
        cubit.loadAppointments(clientId);
        return cubit;
      },
      child: _ClientAppointmentsView(
        clientId: clientId,
        initialAppointments: initialAppointments,
      ),
    );
  }
}

class _ClientAppointmentsView extends StatefulWidget {
  final String clientId;
  final List<Appointment>? initialAppointments;

  const _ClientAppointmentsView({
    required this.clientId,
    this.initialAppointments,
  });

  @override
  State<_ClientAppointmentsView> createState() =>
      _ClientAppointmentsViewState();
}

class _ClientAppointmentsViewState extends State<_ClientAppointmentsView> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_isBottom) {
      context.read<ClientAppointmentsCubit>().loadMoreAppointments(
        widget.clientId,
      );
    }
  }

  bool get _isBottom {
    if (!_scrollController.hasClients) return false;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.offset;
    return currentScroll >= (maxScroll * 0.9);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ClientAppointmentsCubit, ClientAppointmentsState>(
      builder: (context, state) {
        List<Appointment> appointments = widget.initialAppointments ?? [];
        bool isLoading = false;

        if (state is ClientAppointmentsLoading) {
          isLoading = true;
        }

        if (state is ClientAppointmentsLoaded) {
          appointments = state.appointments;
          isLoading = false;
        }

        if (isLoading && appointments.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is ClientAppointmentsError && appointments.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.error_outline,
                  color: AppColorScheme.error,
                  size: 48,
                ),
                const SizedBox(height: 16),
                AppText(state.message),
                TextButton(
                  onPressed: () => context
                      .read<ClientAppointmentsCubit>()
                      .loadAppointments(widget.clientId, refresh: true),
                  child: const AppText('إعادة المحاولة'),
                ),
              ],
            ),
          );
        }

        if (appointments.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: AppColorScheme.surface,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.calendar_today_outlined,
                    size: 64,
                    color: AppColorScheme.silver,
                  ),
                ),
                const SizedBox(height: 24),
                AppText(
                  'لا توجد مواعيد حالياً',
                  style: AppTypography.titleMedium.copyWith(
                    color: AppColorScheme.textMuted,
                  ),
                ),
                const SizedBox(height: 8),
                AppText(
                  'لم يتم جدولة أي مواعيد لهذا العميل بعد.',
                  style: AppTypography.labelSmall.copyWith(
                    color: AppColorScheme.textMuted,
                  ),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () async {
            await context.read<ClientAppointmentsCubit>().loadAppointments(
              widget.clientId,
              refresh: true,
            );
          },
          child: ListView.separated(
            physics: const AlwaysScrollableScrollPhysics(),
            controller: _scrollController,
            padding: const EdgeInsets.all(16),
            itemCount:
                appointments.length +
                (state is ClientAppointmentsLoaded && !state.hasReachedMax
                    ? 1
                    : 0),
            separatorBuilder: (context, index) => const SizedBox(height: 16),
            itemBuilder: (context, index) {
              if (index >= appointments.length) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(8.0),
                    child: CircularProgressIndicator(),
                  ),
                );
              }
              final appointment = appointments[index];
              return AppointmentCard(
                appointment: appointment,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          AppointmentsScreen(initialDate: appointment.startAt),
                    ),
                  );
                },
                onDetailsTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => BlocProvider(
                        create: (_) => getIt<AppointmentsBloc>(),
                        child: AppointmentDetailsScreen(
                          appointmentId: appointment.id,
                        ),
                      ),
                    ),
                  ).then((_) {
                    // Refresh appointments list when returning
                    context.read<ClientAppointmentsCubit>().loadAppointments(
                      widget.clientId,
                    );
                  });
                },
              );
            },
          ),
        );
      },
    );
  }
}
