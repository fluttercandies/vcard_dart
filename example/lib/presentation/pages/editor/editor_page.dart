import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:vcard_dart/vcard_dart.dart';

import '../../../core/core.dart';
import '../../providers/providers.dart';
import '../../router/app_router.dart';
import '../../widgets/widgets.dart';

/// Editor page for creating/editing contacts.
class EditorPage extends ConsumerStatefulWidget {
  const EditorPage({super.key, this.contactId});

  final String? contactId;

  @override
  ConsumerState<EditorPage> createState() => _EditorPageState();
}

class _EditorPageState extends ConsumerState<EditorPage> {
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initEditor();
    });
  }

  Future<void> _initEditor() async {
    if (_initialized) return;
    _initialized = true;

    final notifier = ref.read(editorProvider.notifier);

    if (widget.contactId != null) {
      // Load existing contact
      final contact = await ref.read(getContactByIdUseCaseProvider)(
        widget.contactId!,
      );
      if (contact != null && mounted) {
        notifier.initFromContact(contact);
      }
    } else {
      // New contact
      notifier.initNew();
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(editorProvider);
    final isNew = widget.contactId == null;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            _buildHeader(context, isNew, state),
            // Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppSpacing.pagePadding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Version selector
                    _buildVersionSelector(state),
                    const SizedBox(height: AppSpacing.xl),
                    // Basic info section
                    _buildBasicInfoSection(state),
                    const SizedBox(height: AppSpacing.xl),
                    // Contact info section
                    _buildContactInfoSection(state),
                    const SizedBox(height: AppSpacing.xl),
                    // Address section
                    _buildAddressSection(state),
                    const SizedBox(height: AppSpacing.xl),
                    // Organization section
                    _buildOrganizationSection(state),
                    const SizedBox(height: AppSpacing.xl),
                    // Notes section
                    _buildNotesSection(state),
                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: _buildSaveFab(context, state),
    );
  }

  Widget _buildHeader(BuildContext context, bool isNew, EditorState state) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: const BoxDecoration(
        color: AppColors.primary,
        border: Border(
          bottom: BorderSide(
            color: AppColors.border,
            width: AppSpacing.borderWidth,
          ),
        ),
      ),
      child: Row(
        children: [
          NeoIconButton(
            icon: Icons.arrow_back,
            onPressed: () => _handleBack(context, state),
            color: AppColors.surface,
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isNew ? AppStrings.editorNewCard : AppStrings.editorEditCard,
                  style: AppTextStyles.headlineLarge,
                ),
                if (state.isDirty)
                  Text(
                    'Unsaved changes',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
              ],
            ),
          ),
          if (!isNew) ...[
            NeoIconButton(
              icon: Icons.file_download_outlined,
              onPressed: () => context.goExport(widget.contactId!),
              color: AppColors.accent,
              tooltip: 'Export',
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildVersionSelector(EditorState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('VCARD VERSION', style: AppTextStyles.labelMedium),
        const SizedBox(height: AppSpacing.sm),
        NeoChoiceChips<VCardVersion>(
          options: const [VCardVersion.v21, VCardVersion.v30, VCardVersion.v40],
          selected: state.version,
          onSelected: (version) {
            ref.read(editorProvider.notifier).setVersion(version);
          },
          labelBuilder: (version) {
            switch (version) {
              case VCardVersion.v21:
                return 'v2.1';
              case VCardVersion.v30:
                return 'v3.0';
              case VCardVersion.v40:
                return 'v4.0';
            }
          },
        ),
      ],
    );
  }

  Widget _buildBasicInfoSection(EditorState state) {
    return NeoCard(
      margin: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const NeoSectionHeader(
            title: AppStrings.editorBasicInfo,
            icon: Icons.person_outline,
          ),
          const SizedBox(height: AppSpacing.lg),
          // Name fields
          Row(
            children: [
              Expanded(
                child: NeoTextField(
                  label: AppStrings.labelPrefix,
                  hint: 'Mr., Dr.',
                  initialValue: state.prefix,
                  onChanged: (v) =>
                      ref.read(editorProvider.notifier).setPrefix(v),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                flex: 2,
                child: NeoTextField(
                  label: AppStrings.labelFirstName,
                  hint: 'John',
                  initialValue: state.givenName,
                  onChanged: (v) =>
                      ref.read(editorProvider.notifier).setGivenName(v),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Expanded(
                child: NeoTextField(
                  label: AppStrings.labelMiddleName,
                  hint: 'Michael',
                  initialValue: state.middleName,
                  onChanged: (v) =>
                      ref.read(editorProvider.notifier).setMiddleName(v),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: NeoTextField(
                  label: AppStrings.labelLastName,
                  hint: 'Doe',
                  initialValue: state.familyName,
                  onChanged: (v) =>
                      ref.read(editorProvider.notifier).setFamilyName(v),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Expanded(
                child: NeoTextField(
                  label: AppStrings.labelSuffix,
                  hint: 'Jr., III',
                  initialValue: state.suffix,
                  onChanged: (v) =>
                      ref.read(editorProvider.notifier).setSuffix(v),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                flex: 2,
                child: NeoTextField(
                  label: AppStrings.labelNickname,
                  hint: 'Johnny',
                  initialValue: state.nickname,
                  onChanged: (v) =>
                      ref.read(editorProvider.notifier).setNickname(v),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildContactInfoSection(EditorState state) {
    return NeoCard(
      margin: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          NeoSectionHeader(
            title: AppStrings.editorContactInfo,
            icon: Icons.contact_phone_outlined,
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                NeoIconButton(
                  icon: Icons.add,
                  size: 32,
                  iconSize: 16,
                  onPressed: () => ref.read(editorProvider.notifier).addEmail(),
                  tooltip: 'Add email',
                ),
                const SizedBox(width: AppSpacing.xs),
                NeoIconButton(
                  icon: Icons.phone_outlined,
                  size: 32,
                  iconSize: 16,
                  onPressed: () => ref.read(editorProvider.notifier).addPhone(),
                  tooltip: 'Add phone',
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          // Emails
          ...state.emails.asMap().entries.map((entry) {
            final index = entry.key;
            final email = entry.value;
            return _buildEmailField(index, email);
          }),
          const SizedBox(height: AppSpacing.md),
          // Phones
          ...state.phones.asMap().entries.map((entry) {
            final index = entry.key;
            final phone = entry.value;
            return _buildPhoneField(index, phone);
          }),
        ],
      ),
    );
  }

  Widget _buildEmailField(int index, EmailEntry email) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: NeoTextField(
              label: index == 0 ? AppStrings.labelEmail : null,
              hint: 'email@example.com',
              initialValue: email.value,
              keyboardType: TextInputType.emailAddress,
              onChanged: (v) {
                ref
                    .read(editorProvider.notifier)
                    .updateEmail(index, email.copyWith(value: v));
              },
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          _TypeDropdown(
            value: email.types.isNotEmpty ? email.types.first : 'home',
            onChanged: (type) {
              ref
                  .read(editorProvider.notifier)
                  .updateEmail(index, email.copyWith(types: [type ?? 'home']));
            },
          ),
          if (index > 0) ...[
            const SizedBox(width: AppSpacing.xs),
            NeoIconButton.danger(
              icon: Icons.close,
              size: 32,
              iconSize: 16,
              onPressed: () =>
                  ref.read(editorProvider.notifier).removeEmail(index),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPhoneField(int index, PhoneEntry phone) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: NeoTextField(
              label: index == 0 ? AppStrings.labelPhone : null,
              hint: '+1 234 567 8900',
              initialValue: phone.value,
              keyboardType: TextInputType.phone,
              onChanged: (v) {
                ref
                    .read(editorProvider.notifier)
                    .updatePhone(index, phone.copyWith(value: v));
              },
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          _PhoneTypeDropdown(
            value: phone.types.isNotEmpty ? phone.types.first : 'cell',
            onChanged: (type) {
              ref
                  .read(editorProvider.notifier)
                  .updatePhone(index, phone.copyWith(types: [type ?? 'cell']));
            },
          ),
          if (index > 0) ...[
            const SizedBox(width: AppSpacing.xs),
            NeoIconButton.danger(
              icon: Icons.close,
              size: 32,
              iconSize: 16,
              onPressed: () =>
                  ref.read(editorProvider.notifier).removePhone(index),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildAddressSection(EditorState state) {
    return NeoCard(
      margin: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          NeoSectionHeader(
            title: AppStrings.editorAddressInfo,
            icon: Icons.location_on_outlined,
            trailing: NeoIconButton(
              icon: Icons.add,
              size: 32,
              iconSize: 16,
              onPressed: () => ref.read(editorProvider.notifier).addAddress(),
              tooltip: 'Add address',
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          ...state.addresses.asMap().entries.map((entry) {
            final index = entry.key;
            final address = entry.value;
            return _buildAddressFields(index, address);
          }),
        ],
      ),
    );
  }

  Widget _buildAddressFields(int index, AddressEntry address) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (index > 0) ...[
          const Divider(height: AppSpacing.xl),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Address ${index + 1}', style: AppTextStyles.labelMedium),
              NeoIconButton.danger(
                icon: Icons.close,
                size: 28,
                iconSize: 14,
                onPressed: () =>
                    ref.read(editorProvider.notifier).removeAddress(index),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
        ],
        NeoTextField(
          label: AppStrings.labelStreet,
          hint: '123 Main Street',
          initialValue: address.street,
          onChanged: (v) {
            ref
                .read(editorProvider.notifier)
                .updateAddress(index, address.copyWith(street: v));
          },
        ),
        const SizedBox(height: AppSpacing.md),
        Row(
          children: [
            Expanded(
              flex: 2,
              child: NeoTextField(
                label: AppStrings.labelCity,
                hint: 'New York',
                initialValue: address.city,
                onChanged: (v) {
                  ref
                      .read(editorProvider.notifier)
                      .updateAddress(index, address.copyWith(city: v));
                },
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: NeoTextField(
                label: AppStrings.labelState,
                hint: 'NY',
                initialValue: address.state,
                onChanged: (v) {
                  ref
                      .read(editorProvider.notifier)
                      .updateAddress(index, address.copyWith(state: v));
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        Row(
          children: [
            Expanded(
              child: NeoTextField(
                label: AppStrings.labelPostalCode,
                hint: '10001',
                initialValue: address.postalCode,
                onChanged: (v) {
                  ref
                      .read(editorProvider.notifier)
                      .updateAddress(index, address.copyWith(postalCode: v));
                },
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              flex: 2,
              child: NeoTextField(
                label: AppStrings.labelCountry,
                hint: 'USA',
                initialValue: address.country,
                onChanged: (v) {
                  ref
                      .read(editorProvider.notifier)
                      .updateAddress(index, address.copyWith(country: v));
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        _TypeDropdown(
          value: address.types.isNotEmpty ? address.types.first : 'home',
          onChanged: (type) {
            ref
                .read(editorProvider.notifier)
                .updateAddress(
                  index,
                  address.copyWith(types: [type ?? 'home']),
                );
          },
        ),
        const SizedBox(height: AppSpacing.md),
      ],
    );
  }

  Widget _buildOrganizationSection(EditorState state) {
    return NeoCard(
      margin: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const NeoSectionHeader(
            title: AppStrings.editorOrganization,
            icon: Icons.business_outlined,
          ),
          const SizedBox(height: AppSpacing.lg),
          NeoTextField(
            label: AppStrings.labelOrganization,
            hint: 'Acme Inc.',
            initialValue: state.organization,
            onChanged: (v) =>
                ref.read(editorProvider.notifier).setOrganization(v),
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Expanded(
                child: NeoTextField(
                  label: AppStrings.labelTitle,
                  hint: 'Software Engineer',
                  initialValue: state.title,
                  onChanged: (v) =>
                      ref.read(editorProvider.notifier).setTitle(v),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: NeoTextField(
                  label: AppStrings.labelDepartment,
                  hint: 'Engineering',
                  initialValue: state.department,
                  onChanged: (v) =>
                      ref.read(editorProvider.notifier).setDepartment(v),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          NeoTextField(
            label: AppStrings.labelRole,
            hint: 'Team Lead',
            initialValue: state.role,
            onChanged: (v) => ref.read(editorProvider.notifier).setRole(v),
          ),
        ],
      ),
    );
  }

  Widget _buildNotesSection(EditorState state) {
    return NeoCard(
      margin: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const NeoSectionHeader(
            title: AppStrings.editorNotes,
            icon: Icons.note_outlined,
          ),
          const SizedBox(height: AppSpacing.lg),
          NeoTextField(
            label: AppStrings.labelNote,
            hint: 'Additional notes...',
            initialValue: state.note,
            maxLines: 4,
            onChanged: (v) => ref.read(editorProvider.notifier).setNote(v),
          ),
        ],
      ),
    );
  }

  Widget _buildSaveFab(BuildContext context, EditorState state) {
    return Container(
      decoration: const BoxDecoration(
        boxShadow: [BoxShadow(color: AppColors.border, offset: Offset(4, 4))],
      ),
      child: FloatingActionButton.extended(
        onPressed: state.isSaving ? null : () => _saveContact(context, state),
        backgroundColor: state.isDirty
            ? AppColors.success
            : AppColors.textSecondary,
        foregroundColor: AppColors.light,
        elevation: 0,
        shape: RoundedRectangleBorder(
          side: const BorderSide(
            color: AppColors.border,
            width: AppSpacing.borderWidth,
          ),
          borderRadius: BorderRadius.circular(0),
        ),
        icon: state.isSaving
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppColors.light,
                ),
              )
            : const Icon(Icons.save),
        label: Text(
          state.isSaving ? 'SAVING...' : AppStrings.actionSave,
          style: AppTextStyles.labelLarge.copyWith(color: AppColors.light),
        ),
      ),
    );
  }

  Future<void> _saveContact(BuildContext context, EditorState state) async {
    final notifier = ref.read(editorProvider.notifier);
    notifier.setSaving(true);

    // Capture scaffold messenger and router before async gap
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final router = GoRouter.of(context);

    try {
      final vcard = state.buildVCard();
      final contactsNotifier = ref.read(contactsProvider.notifier);

      if (widget.contactId != null) {
        // Update existing
        final existing = await ref.read(getContactByIdUseCaseProvider)(
          widget.contactId!,
        );
        if (existing != null) {
          await contactsNotifier.updateContact(existing.copyWith(vCard: vcard));
        }
      } else {
        // Create new
        await contactsNotifier.createContact(vcard);
      }

      notifier.clearDirty();
      notifier.setSaving(false);

      if (mounted) {
        scaffoldMessenger.showSnackBar(
          const SnackBar(
            content: Text(AppStrings.msgSaved),
            backgroundColor: AppColors.success,
          ),
        );
        router.go(AppRoutes.home);
      }
    } catch (e) {
      notifier.setSaving(false);
      notifier.setError(e.toString());

      if (mounted) {
        scaffoldMessenger.showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  void _handleBack(BuildContext context, EditorState state) {
    if (state.isDirty) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: AppColors.surface,
          shape: RoundedRectangleBorder(
            side: const BorderSide(
              color: AppColors.border,
              width: AppSpacing.borderWidth,
            ),
            borderRadius: BorderRadius.circular(0),
          ),
          title: const Text(
            AppStrings.msgUnsavedChanges,
            style: AppTextStyles.headlineLarge,
          ),
          content: const Text(
            AppStrings.msgDiscardChanges,
            style: AppTextStyles.bodyMedium,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('CANCEL'),
            ),
            NeoButton.danger(
              onPressed: () {
                Navigator.of(context).pop();
                context.goHome();
              },
              child: const Text('DISCARD'),
            ),
          ],
        ),
      );
    } else {
      context.goHome();
    }
  }
}

/// Type dropdown for email/address.
class _TypeDropdown extends StatelessWidget {
  const _TypeDropdown({required this.value, required this.onChanged});

  final String value;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border.all(color: AppColors.border, width: 2),
        boxShadow: const [
          BoxShadow(color: AppColors.border, offset: Offset(2, 2)),
        ],
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          items: const [
            DropdownMenuItem(value: 'home', child: Text('HOME')),
            DropdownMenuItem(value: 'work', child: Text('WORK')),
            DropdownMenuItem(value: 'other', child: Text('OTHER')),
          ],
          onChanged: onChanged,
          style: AppTextStyles.labelSmall,
          dropdownColor: AppColors.surface,
        ),
      ),
    );
  }
}

/// Phone type dropdown.
class _PhoneTypeDropdown extends StatelessWidget {
  const _PhoneTypeDropdown({required this.value, required this.onChanged});

  final String value;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border.all(color: AppColors.border, width: 2),
        boxShadow: const [
          BoxShadow(color: AppColors.border, offset: Offset(2, 2)),
        ],
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          items: const [
            DropdownMenuItem(value: 'cell', child: Text('MOBILE')),
            DropdownMenuItem(value: 'home', child: Text('HOME')),
            DropdownMenuItem(value: 'work', child: Text('WORK')),
            DropdownMenuItem(value: 'fax', child: Text('FAX')),
          ],
          onChanged: onChanged,
          style: AppTextStyles.labelSmall,
          dropdownColor: AppColors.surface,
        ),
      ),
    );
  }
}
