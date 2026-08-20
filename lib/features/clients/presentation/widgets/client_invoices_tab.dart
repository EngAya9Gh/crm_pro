import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/common/widgets/app_text.dart';
import '../../../../core/config/theme/color_scheme.dart';
import '../../../../core/config/theme/typography.dart';
import '../../../../core/services/di/di_container.dart';
import '../../../../features/invoices/domain/entities/invoice.dart';
import '../bloc/cubits/client_invoices_cubit.dart';
import '../../../../features/invoices/presentation/widgets/invoice_card.dart';
import '../../../../features/invoices/presentation/views/invoice_details_screen.dart';
import '../../../../features/invoices/presentation/bloc/invoices_bloc.dart';

class ClientInvoicesTab extends StatelessWidget {
  final String clientId;
  final List<Invoice>? initialInvoices;

  const ClientInvoicesTab({
    super.key,
    required this.clientId,
    this.initialInvoices,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<ClientInvoicesCubit>()..loadInvoices(clientId),
      child: _ClientInvoicesView(
        clientId: clientId,
        initialInvoices: initialInvoices,
      ),
    );
  }
}

class _ClientInvoicesView extends StatefulWidget {
  final String clientId;
  final List<Invoice>? initialInvoices;

  const _ClientInvoicesView({required this.clientId, this.initialInvoices});

  @override
  State<_ClientInvoicesView> createState() => _ClientInvoicesViewState();
}

class _ClientInvoicesViewState extends State<_ClientInvoicesView> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_isBottom) {
      context.read<ClientInvoicesCubit>().loadMoreInvoices(widget.clientId);
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
    return BlocBuilder<ClientInvoicesCubit, ClientInvoicesState>(
      builder: (context, state) {
        List<Invoice> invoices = widget.initialInvoices ?? [];
        bool isLoading = false;

        if (state is ClientInvoicesLoading) {
          isLoading = true;
        }

        if (state is ClientInvoicesLoaded) {
          invoices = state.invoices;
          isLoading = false;
        }

        if (isLoading && invoices.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is ClientInvoicesError && invoices.isEmpty) {
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
                      .read<ClientInvoicesCubit>()
                      .loadInvoices(widget.clientId, refresh: true),
                  child: const AppText('إعادة المحاولة'),
                ),
              ],
            ),
          );
        }

        if (invoices.isEmpty) {
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
                    Icons.receipt_long_outlined,
                    size: 64,
                    color: AppColorScheme.silver,
                  ),
                ),
                const SizedBox(height: 24),
                AppText(
                  'لا توجد فواتير حالياً',
                  style: AppTypography.titleMedium.copyWith(
                    color: AppColorScheme.textMuted,
                  ),
                ),
                const SizedBox(height: 8),
                AppText(
                  'لم يتم إصدار أي فواتير لهذا العميل بعد.',
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
            await context.read<ClientInvoicesCubit>().loadInvoices(
              widget.clientId,
              refresh: true,
            );
          },
          child: ListView.separated(
            physics: const AlwaysScrollableScrollPhysics(),
            controller: _scrollController,
            padding: const EdgeInsets.all(16),
            itemCount:
                invoices.length +
                (state is ClientInvoicesLoaded && !state.hasReachedMax ? 1 : 0),
            separatorBuilder: (context, index) => const SizedBox(height: 16),
            itemBuilder: (context, index) {
              if (index >= invoices.length) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(8.0),
                    child: CircularProgressIndicator(),
                  ),
                );
              }
              final invoice = invoices[index];
              return InvoiceCard(
                invoice: invoice,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => BlocProvider(
                        create: (context) => getIt<InvoicesBloc>(),
                        child: InvoiceDetailsScreen(invoiceId: invoice.id),
                      ),
                    ),
                  );
                },
              );
            },
          ),
        );
      },
    );
  }
}
