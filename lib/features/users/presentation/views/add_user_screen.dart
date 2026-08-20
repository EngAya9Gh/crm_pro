import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:crm_wakeel/core/common/widgets/app_text.dart';
import 'package:crm_wakeel/core/common/widgets/app_text_field.dart';
import 'package:crm_wakeel/core/common/widgets/app_elevated_button.dart';
import 'package:crm_wakeel/core/config/theme/color_scheme.dart';
import '../../domain/entities/user.dart';
import '../bloc/users_bloc.dart';
import '../bloc/users_event.dart';
import '../bloc/users_state.dart';
import '../../../settings/presentation/bloc/lookups_bloc.dart';
import '../../../settings/presentation/bloc/lookups_event.dart';
import '../../../settings/presentation/bloc/lookups_state.dart';
import '../../../settings/domain/entities/lookup_entities.dart';

class AddUserScreen extends StatefulWidget {
  final User? user;
  const AddUserScreen({super.key, this.user});

  @override
  State<AddUserScreen> createState() => _AddUserScreenState();
}

class _AddUserScreenState extends State<AddUserScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _passwordController;
  late TextEditingController _passwordConfirmController;

  TeamEntity? _selectedTeam;
  RoleEntity? _selectedRole;
  bool _isActive = true;

  bool get _isEditing => widget.user != null;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.user?.name ?? '');
    _emailController = TextEditingController(text: widget.user?.email ?? '');
    _phoneController = TextEditingController(text: widget.user?.phone ?? '');
    _passwordController = TextEditingController();
    _passwordConfirmController = TextEditingController();
    _isActive = widget.user?.isActive ?? true;

    // Load lookups if needed
    context.read<LookupsBloc>().add(LoadAllLookups());
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _passwordConfirmController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColorScheme.surface,
      appBar: AppBar(
        title: AppText(
          _isEditing ? 'تعديل المستخدم' : 'إضافة مستخدم جديد',
          style: const TextStyle(color: AppColorScheme.white),
        ),
        backgroundColor: AppColorScheme.primary,
        iconTheme: const IconThemeData(color: AppColorScheme.white),
      ),
      body: MultiBlocListener(
        listeners: [
          BlocListener<UsersBloc, UsersState>(
            listener: (context, state) {
              if (state.operationStatus == UsersOperationStatus.success) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: AppText(
                      state.operationMessage ?? 'تمت العملية بنجاح',
                      style: const TextStyle(color: Colors.white),
                    ),
                    backgroundColor: AppColorScheme.success,
                  ),
                );
                Navigator.pop(context);
              } else if (state.operationStatus ==
                  UsersOperationStatus.failure) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: AppText(
                      state.operationMessage ?? 'حدث خطأ غير معروف',
                      style: const TextStyle(color: Colors.white),
                    ),
                    backgroundColor: AppColorScheme.error,
                  ),
                );
              }
            },
          ),
          BlocListener<LookupsBloc, LookupsState>(
            listener: (context, state) {
              if (state is LookupsLoaded && _isEditing) {
                // Pre-select team
                if (_selectedTeam == null && widget.user!.team != null) {
                  try {
                    _selectedTeam = state.lookups.teams.firstWhere(
                      (t) => t.id == widget.user!.team!.id,
                    );
                    setState(() {});
                  } catch (_) {}
                }
                // Pre-select role
                if (_selectedRole == null && widget.user!.role != null) {
                  try {
                    _selectedRole = state.lookups.roles.firstWhere(
                      (r) => r.id == widget.user!.role!.id,
                    );
                    setState(() {});
                  } catch (_) {}
                }
              }
            },
          ),
        ],
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionTitle('المعلومات الشخصية'),
                const SizedBox(height: 16),
                AppTextField(
                  controller: _nameController,
                  hintText: 'الاسم الكامل',
                  prefixIcon: const Icon(Icons.person_outline),
                  validator: (val) =>
                      val!.isEmpty ? 'الرجاء إدخال الاسم' : null,
                ),
                const SizedBox(height: 16),
                AppTextField(
                  controller: _emailController,
                  hintText: 'البريد الإلكتروني',
                  prefixIcon: const Icon(Icons.email_outlined),
                  keyboardType: TextInputType.emailAddress,
                  validator: (val) =>
                      val!.isEmpty ? 'الرجاء إدخال البريد الإلكتروني' : null,
                ),
                const SizedBox(height: 16),
                AppTextField(
                  controller: _phoneController,
                  hintText: 'رقم الهاتف',
                  prefixIcon: const Icon(Icons.phone_outlined),
                  keyboardType: TextInputType.phone,
                ),

                const SizedBox(height: 24),
                _buildSectionTitle('الأمان'),
                const SizedBox(height: 16),
                if (_isEditing)
                  const Padding(
                    padding: EdgeInsets.only(bottom: 12.0),
                    child: AppText(
                      'اترك كلمة المرور فارغة إذا كنت لا تريد تغييرها',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColorScheme.textMuted,
                      ),
                    ),
                  ),
                AppTextField(
                  controller: _passwordController,
                  hintText: 'كلمة المرور',
                  prefixIcon: const Icon(Icons.lock_outline),
                  isPassword: true,
                  validator: (val) {
                    if (!_isEditing && (val == null || val.isEmpty)) {
                      return 'الرجاء إدخال كلمة المرور';
                    }
                    if (val != null && val.isNotEmpty && val.length < 6) {
                      return 'كلمة المرور يجب أن تكون 6 أحرف على الأقل';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                AppTextField(
                  controller: _passwordConfirmController,
                  hintText: 'تأكيد كلمة المرور',
                  prefixIcon: const Icon(Icons.lock_outline),
                  isPassword: true,
                  validator: (val) {
                    if (_passwordController.text.isNotEmpty &&
                        val != _passwordController.text) {
                      return 'كلمات المرور غير متطابقة';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 24),
                _buildSectionTitle('الصلاحيات والفرق'),
                const SizedBox(height: 16),
                BlocBuilder<LookupsBloc, LookupsState>(
                  builder: (context, state) {
                    List<TeamEntity> teams = [];
                    List<RoleEntity> roles = [];
                    if (state is LookupsLoaded) {
                      teams = state.lookups.teams;
                      roles = state.lookups.roles;
                    }

                    return Column(
                      children: [
                        _buildDropdown<TeamEntity>(
                          label: 'الفريق',
                          value: _selectedTeam,
                          items: teams,
                          itemLabel: (t) => t.name,
                          onChanged: (val) =>
                              setState(() => _selectedTeam = val),
                        ),
                        const SizedBox(height: 16),
                        _buildDropdown<RoleEntity>(
                          label: 'الدور الوظيفي',
                          value: _selectedRole,
                          items: roles,
                          itemLabel: (r) => r.name,
                          onChanged: (val) =>
                              setState(() => _selectedRole = val),
                        ),
                      ],
                    );
                  },
                ),

                const SizedBox(height: 24),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const AppText('حساب نشط'),
                  value: _isActive,
                  onChanged: (val) => setState(() => _isActive = val),
                  activeColor: AppColorScheme.primary,
                ),

                const SizedBox(height: 32),
                BlocBuilder<UsersBloc, UsersState>(
                  builder: (context, state) {
                    if (state.operationStatus == UsersOperationStatus.loading) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    return SizedBox(
                      width: double.infinity,
                      child: AppElevatedButton(
                        onPressed: _submit,
                        text: _isEditing ? 'حفظ التعديلات' : 'إضافة المستخدم',
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      if (_selectedRole == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('الرجاء اختيار الدور الوظيفي')),
        );
        return;
      }

      final data = {
        'name': _nameController.text,
        'email': _emailController.text,
        'phone': _phoneController.text,
        'role_id': _selectedRole!.id,
        'is_active': _isActive ? 1 : 0,
      };

      if (_selectedTeam != null) {
        data['team_id'] = _selectedTeam!.id;
      }

      if (_passwordController.text.isNotEmpty) {
        data['password'] = _passwordController.text;
        data['password_confirmation'] = _passwordConfirmController.text;
      }

      if (_isEditing) {
        context.read<UsersBloc>().add(UpdateUserEvent(widget.user!.id, data));
      } else {
        context.read<UsersBloc>().add(CreateUserEvent(data));
      }
    }
  }

  Widget _buildSectionTitle(String title) {
    return AppText(
      title,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: AppColorScheme.primary,
      ),
    );
  }

  Widget _buildDropdown<T>({
    required String label,
    required T? value,
    required List<T> items,
    required String Function(T) itemLabel,
    required Function(T?) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppText(
          label,
          style: const TextStyle(fontSize: 12, color: AppColorScheme.textMuted),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: AppColorScheme.background,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColorScheme.silver),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<T>(
              value: value,
              isExpanded: true,
              hint: AppText(
                'اختر $label',
                style: const TextStyle(color: Colors.grey),
              ),
              items: items.map((item) {
                return DropdownMenuItem<T>(
                  value: item,
                  child: AppText(itemLabel(item)),
                );
              }).toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }
}
