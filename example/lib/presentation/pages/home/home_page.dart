import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/core.dart';
import '../../../domain/entities/contact_entity.dart';
import '../../providers/providers.dart';
import '../../router/app_router.dart';
import '../../widgets/widgets.dart';

/// Home page displaying contacts list.
class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Load contacts on init
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(contactsProvider.notifier).loadContacts();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final contactsState = ref.watch(contactsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // Header
            SliverToBoxAdapter(child: _buildHeader(context)),
            // Search bar
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.pagePadding,
                ),
                child: _buildSearchBar(),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.lg)),
            // Quick actions
            SliverToBoxAdapter(child: _buildQuickActions(context)),
            const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.lg)),
            // Contacts section header
            const SliverToBoxAdapter(
              child: NeoSectionHeader(
                title: 'MY CONTACTS',
                icon: Icons.contacts_outlined,
              ),
            ),
            // Contacts list
            if (contactsState.isLoading)
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.all(AppSpacing.xxl),
                  child: Center(
                    child: CircularProgressIndicator(color: AppColors.primary),
                  ),
                ),
              )
            else if (contactsState.error != null)
              SliverToBoxAdapter(
                child: NeoEmptyState(
                  title: 'ERROR',
                  subtitle: contactsState.error,
                  icon: Icons.error_outline,
                  action: () =>
                      ref.read(contactsProvider.notifier).loadContacts(),
                  actionLabel: 'RETRY',
                ),
              )
            else if (contactsState.contacts.isEmpty)
              SliverToBoxAdapter(
                child: NeoEmptyState(
                  title: AppStrings.homeNoCards,
                  subtitle: AppStrings.homeCreateFirst,
                  icon: Icons.person_add_outlined,
                  action: () => context.goNewContact(),
                  actionLabel: 'CREATE VCARD',
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.all(AppSpacing.pagePadding),
                sliver: SliverList.builder(
                  itemCount: contactsState.contacts.length,
                  itemBuilder: (context, index) {
                    final contact = contactsState.contacts[index];
                    return _ContactListItem(
                      contact: contact,
                      onTap: () => context.goEditContact(contact.id),
                      onFavorite: () => ref
                          .read(contactsProvider.notifier)
                          .toggleFavorite(contact.id),
                      onExport: () => context.goExport(contact.id),
                      onDelete: () => _confirmDelete(context, contact),
                    );
                  },
                ),
              ),
            const SliverToBoxAdapter(child: SizedBox(height: 100)),
          ],
        ),
      ),
      floatingActionButton: _buildFab(context),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.pagePadding),
      decoration: const BoxDecoration(
        color: AppColors.primary,
        border: Border(
          bottom: BorderSide(
            color: AppColors.border,
            width: AppSpacing.borderWidth,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppSpacing.sm),
                decoration: BoxDecoration(
                  color: AppColors.dark,
                  border: Border.all(color: AppColors.border, width: 2),
                ),
                child: const Icon(
                  Icons.contact_page,
                  color: AppColors.primary,
                  size: 24,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppStrings.homeTitle,
                      style: AppTextStyles.displaySmall,
                    ),
                    Text(
                      AppStrings.homeSubtitle,
                      style: AppTextStyles.bodySmall,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      margin: const EdgeInsets.only(top: AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border.all(
          color: AppColors.border,
          width: AppSpacing.borderWidth,
        ),
        boxShadow: const [
          BoxShadow(color: AppColors.border, offset: Offset(4, 4)),
        ],
      ),
      child: TextField(
        controller: _searchController,
        onChanged: (query) {
          if (query.isEmpty) {
            ref.read(contactsProvider.notifier).loadContacts();
          } else {
            ref.read(contactsProvider.notifier).searchContacts(query);
          }
        },
        style: AppTextStyles.bodyMedium,
        decoration: const InputDecoration(
          hintText: 'Search contacts...',
          prefixIcon: Icon(Icons.search, color: AppColors.textSecondary),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.md,
          ),
        ),
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.pagePadding),
      child: Row(
        children: [
          Expanded(
            child: _QuickActionButton(
              icon: Icons.add,
              label: 'NEW',
              color: AppColors.primary,
              onTap: () => context.goNewContact(),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: _QuickActionButton(
              icon: Icons.file_upload_outlined,
              label: 'IMPORT',
              color: AppColors.accent,
              onTap: _showImportDialog,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFab(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        boxShadow: [BoxShadow(color: AppColors.border, offset: Offset(4, 4))],
      ),
      child: FloatingActionButton.extended(
        onPressed: () => context.goNewContact(),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.dark,
        elevation: 0,
        shape: RoundedRectangleBorder(
          side: const BorderSide(
            color: AppColors.border,
            width: AppSpacing.borderWidth,
          ),
          borderRadius: BorderRadius.circular(0),
        ),
        icon: const Icon(Icons.add),
        label: const Text('NEW VCARD', style: AppTextStyles.labelLarge),
      ),
    );
  }

  void _showImportDialog() {
    showDialog(
      context: context,
      builder: (dialogContext) => _ImportDialog(
        onImport: (vcardData) async {
          // Capture navigator and scaffold messenger before async gap
          final navigator = Navigator.of(dialogContext);
          final scaffoldMessenger = ScaffoldMessenger.of(dialogContext);
          try {
            final imported = await ref
                .read(contactsProvider.notifier)
                .importVCards(vcardData);
            if (mounted) {
              navigator.pop();
              scaffoldMessenger.showSnackBar(
                SnackBar(
                  content: Text('Imported ${imported.length} contact(s)'),
                  backgroundColor: AppColors.success,
                ),
              );
            }
          } catch (e) {
            if (mounted) {
              scaffoldMessenger.showSnackBar(
                SnackBar(
                  content: Text('Import failed: $e'),
                  backgroundColor: AppColors.error,
                ),
              );
            }
          }
        },
      ),
    );
  }

  void _confirmDelete(BuildContext context, ContactEntity contact) {
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
        title: const Text('DELETE CONTACT', style: AppTextStyles.headlineLarge),
        content: Text(
          'Are you sure you want to delete "${contact.displayName}"?',
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
              ref.read(contactsProvider.notifier).deleteContact(contact.id);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(AppStrings.msgDeleted),
                  backgroundColor: AppColors.dark,
                ),
              );
            },
            child: const Text('DELETE'),
          ),
        ],
      ),
    );
  }
}

/// Quick action button widget.
class _QuickActionButton extends StatelessWidget {
  const _QuickActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return NeoCard(
      color: color,
      padding: const EdgeInsets.all(AppSpacing.lg),
      onTap: onTap,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: AppColors.dark, size: 20),
          const SizedBox(width: AppSpacing.sm),
          Text(label, style: AppTextStyles.labelLarge),
        ],
      ),
    );
  }
}

/// Contact list item widget.
class _ContactListItem extends StatelessWidget {
  const _ContactListItem({
    required this.contact,
    required this.onTap,
    required this.onFavorite,
    required this.onExport,
    required this.onDelete,
  });

  final ContactEntity contact;
  final VoidCallback onTap;
  final VoidCallback onFavorite;
  final VoidCallback onExport;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return NeoCard(
      onTap: onTap,
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Row(
        children: [
          NeoAvatar(
            text: contact.initials,
            backgroundColor: contact.isFavorite
                ? AppColors.secondary
                : AppColors.primary,
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        contact.displayName,
                        style: AppTextStyles.titleLarge,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (contact.isFavorite)
                      const Icon(
                        Icons.star,
                        color: AppColors.secondary,
                        size: 18,
                      ),
                  ],
                ),
                if (contact.organizationName != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    contact.organizationName!,
                    style: AppTextStyles.bodySmall,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                if (contact.primaryEmail != null ||
                    contact.primaryPhone != null) ...[
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      if (contact.primaryEmail != null) ...[
                        const Icon(
                          Icons.email_outlined,
                          size: 12,
                          color: AppColors.textSecondary,
                        ),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            contact.primaryEmail!,
                            style: AppTextStyles.bodySmall,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: AppColors.textSecondary),
            color: AppColors.surface,
            shape: RoundedRectangleBorder(
              side: const BorderSide(color: AppColors.border, width: 2),
              borderRadius: BorderRadius.circular(0),
            ),
            onSelected: (value) {
              switch (value) {
                case 'favorite':
                  onFavorite();
                case 'export':
                  onExport();
                case 'delete':
                  onDelete();
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'favorite',
                child: Row(
                  children: [
                    Icon(
                      contact.isFavorite ? Icons.star_border : Icons.star,
                      size: 20,
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Text(contact.isFavorite ? 'Unfavorite' : 'Favorite'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'export',
                child: Row(
                  children: [
                    Icon(Icons.file_download_outlined, size: 20),
                    SizedBox(width: AppSpacing.sm),
                    Text('Export'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(
                      Icons.delete_outline,
                      size: 20,
                      color: AppColors.error,
                    ),
                    SizedBox(width: AppSpacing.sm),
                    Text('Delete', style: TextStyle(color: AppColors.error)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Import dialog widget.
class _ImportDialog extends StatefulWidget {
  const _ImportDialog({required this.onImport});

  final Future<void> Function(String vcardData) onImport;

  @override
  State<_ImportDialog> createState() => _ImportDialogState();
}

class _ImportDialogState extends State<_ImportDialog> {
  final _controller = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(
        side: const BorderSide(
          color: AppColors.border,
          width: AppSpacing.borderWidth,
        ),
        borderRadius: BorderRadius.circular(0),
      ),
      title: const Text('IMPORT VCARD', style: AppTextStyles.headlineLarge),
      content: SizedBox(
        width: double.maxFinite,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Paste vCard data below:',
              style: AppTextStyles.bodyMedium,
            ),
            const SizedBox(height: AppSpacing.md),
            Container(
              height: 200,
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.border, width: 2),
              ),
              child: TextField(
                controller: _controller,
                maxLines: null,
                expands: true,
                style: AppTextStyles.monospace,
                decoration: const InputDecoration(
                  hintText: 'BEGIN:VCARD\nVERSION:4.0\n...',
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.all(AppSpacing.md),
                ),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('CANCEL'),
        ),
        NeoButton.primary(
          onPressed: _isLoading
              ? null
              : () async {
                  if (_controller.text.isEmpty) return;
                  setState(() => _isLoading = true);
                  await widget.onImport(_controller.text);
                  if (mounted) {
                    setState(() => _isLoading = false);
                  }
                },
          isLoading: _isLoading,
          child: const Text('IMPORT'),
        ),
      ],
    );
  }
}
