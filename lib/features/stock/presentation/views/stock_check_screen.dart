import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:crm_wakeel/core/common/widgets/app_scaffold.dart';
import 'package:crm_wakeel/core/common/widgets/app_text_field.dart';
import 'package:crm_wakeel/core/common/widgets/app_elevated_button.dart';
import 'package:crm_wakeel/core/common/widgets/app_text.dart';
import 'package:crm_wakeel/core/common/widgets/app_loader.dart';
import 'package:crm_wakeel/core/config/theme/color_scheme.dart';
import 'package:crm_wakeel/core/config/theme/typography.dart';
import 'package:crm_wakeel/core/services/di/di_container.dart';
import '../cubit/stock_cubit.dart';
import 'scanner_screen.dart';

class StockCheckScreen extends StatefulWidget {
  const StockCheckScreen({super.key});

  @override
  State<StockCheckScreen> createState() => _StockCheckScreenState();
}

class _StockCheckScreenState extends State<StockCheckScreen> {
  final TextEditingController _skuController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _skuController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<StockCubit>(),
      child: Builder(
        builder: (context) {
          return BlocListener<StockCubit, StockState>(
            listener: (context, state) {
              if (state is StockSyncSuccess) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("تمت مزامنة المنتجات بنجاح"),
                    backgroundColor: AppColorScheme.success,
                  ),
                );
              } else if (state is StockSyncError) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.message),
                    backgroundColor: AppColorScheme.error,
                  ),
                );
              }
            },
            child: AppScaffold(
              title: "فحص المخزون",
              centerTitle: true,
              actions: [
                BlocBuilder<StockCubit, StockState>(
                  builder: (context, state) {
                    if (state is StockSyncLoading) {
                      return const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16.0),
                        child: Center(
                          child: SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        ),
                      );
                    }
                    return IconButton(
                      icon: const Icon(Icons.sync_rounded),
                      onPressed: () {
                        context.read<StockCubit>().syncProducts();
                      },
                    );
                  },
                ),
              ],
              body: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    _buildSearchSection(),
                    const SizedBox(height: 24),
                    Expanded(child: _buildResultSection()),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSearchSection() {
    return Builder(
      builder: (context) {
        return Form(
          key: _formKey,
          child: Column(
            children: [
              AppTextField(
                controller: _skuController,
                label: "كود المنتج (SKU)",
                hintText: "أدخل كود المنتج أو امسح الباركود",
                prefixIcon: IconButton(
                  icon: const Icon(Icons.qr_code_scanner_rounded),
                  onPressed: () async {
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ScannerScreen(),
                      ),
                    );
                    if (result != null && result is String) {
                      _skuController.text = result;
                      if (context.mounted) {
                        context.read<StockCubit>().scanProduct(result);
                      }
                    }
                  },
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'يرجى إدخال كود المنتج';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: AppElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      context.read<StockCubit>().scanProduct(
                        _skuController.text,
                      );
                    }
                  },
                  text: "فحص",
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildResultSection() {
    return BlocBuilder<StockCubit, StockState>(
      builder: (context, state) {
        if (state is StockScanLoading) {
          return const Center(child: AppLoader());
        } else if (state is StockScanError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.error_outline_rounded,
                  size: 64,
                  color: AppColorScheme.error,
                ),
                const SizedBox(height: 16),
                AppText(
                  state.message,
                  style: AppTypography.bodyLarge.copyWith(
                    color: AppColorScheme.error,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        } else if (state is StockScanSuccess) {
          final item = state.stockItem;
          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: AppColorScheme.card,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColorScheme.grey300),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      const Icon(
                        Icons.inventory_2_rounded,
                        size: 48,
                        color: AppColorScheme.primary,
                      ),
                      const SizedBox(height: 16),
                      AppText(
                        item.name,
                        style: AppTypography.titleLarge.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      AppText(
                        item.sku,
                        style: AppTypography.labelMedium.copyWith(
                          color: AppColorScheme.textMuted,
                        ),
                      ),
                      const SizedBox(height: 24),
                      const Divider(),
                      const SizedBox(height: 24),
                      Row(
                        children: [
                          Expanded(
                            child: _buildInfoItem(
                              "المخزون الفعلي (ERP)",
                              item.stockErp.toString(),
                              Icons.cloud_sync_rounded,
                              AppColorScheme.primary,
                            ),
                          ),
                          Container(
                            width: 1,
                            height: 60,
                            color: AppColorScheme.grey300,
                            margin: const EdgeInsets.symmetric(horizontal: 16),
                          ),
                          Expanded(
                            child: _buildInfoItem(
                              "المخزون المحلي",
                              item.stockLocal.toString(),
                              Icons.storage_rounded,
                              AppColorScheme.secondary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColorScheme.surface,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            AppText("السعر", style: AppTypography.titleMedium),
                            AppText(
                              "${item.price} ر.س",
                              style: AppTypography.titleLarge.copyWith(
                                color: AppColorScheme.success,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.qr_code_scanner_rounded,
                size: 80,
                color: AppColorScheme.textMuted.withOpacity(0.3),
              ),
              const SizedBox(height: 16),
              AppText(
                "جاهز للفحص",
                style: AppTypography.titleMedium.copyWith(
                  color: AppColorScheme.textMuted,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildInfoItem(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Column(
      children: [
        Icon(icon, color: color, size: 28),
        const SizedBox(height: 8),
        AppText(
          value,
          style: AppTypography.displayMedium.copyWith(
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        AppText(
          label,
          style: AppTypography.labelSmall.copyWith(
            color: AppColorScheme.textMuted,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
