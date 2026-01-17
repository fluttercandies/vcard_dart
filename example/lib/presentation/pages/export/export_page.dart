import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/core.dart';
import '../../../domain/entities/export_format.dart';
import '../../providers/providers.dart';
import '../../router/app_router.dart';
import '../../widgets/widgets.dart';

/// Export page for exporting contacts.
class ExportPage extends ConsumerStatefulWidget {
  const ExportPage({super.key, required this.contactId});

  final String contactId;

  @override
  ConsumerState<ExportPage> createState() => _ExportPageState();
}

class _ExportPageState extends ConsumerState<ExportPage> {
  ExportFormat _selectedFormat = ExportFormat.vcard;
  String? _exportedContent;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _generateExport();
    });
  }

  Future<void> _generateExport() async {
    setState(() => _isLoading = true);

    try {
      final contact = await ref.read(getContactByIdUseCaseProvider)(
        widget.contactId,
      );
      if (contact == null) {
        setState(() {
          _isLoading = false;
          _exportedContent = 'Contact not found';
        });
        return;
      }

      final exportUseCase = ref.read(exportContactUseCaseProvider);
      final content = await exportUseCase(contact, _selectedFormat);

      setState(() {
        _isLoading = false;
        _exportedContent = content;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _exportedContent = 'Error: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final contactAsync = ref.watch(contactByIdProvider(widget.contactId));

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            _buildHeader(context, contactAsync),
            // Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppSpacing.pagePadding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Format selector
                    _buildFormatSelector(),
                    const SizedBox(height: AppSpacing.xl),
                    // Preview
                    _buildPreview(),
                    const SizedBox(height: AppSpacing.xl),
                    // Actions
                    _buildActions(context),
                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, AsyncValue contactAsync) {
    final contactName = contactAsync.when(
      data: (contact) => contact?.displayName ?? 'Unknown',
      loading: () => 'Loading...',
      error: (_, _) => 'Error',
    );

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: const BoxDecoration(
        color: AppColors.accent,
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
            onPressed: () => context.goBack(),
            color: AppColors.surface,
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  AppStrings.exportTitle,
                  style: AppTextStyles.headlineLarge,
                ),
                Text(
                  contactName,
                  style: AppTextStyles.bodySmall,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFormatSelector() {
    return NeoCard(
      margin: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const NeoSectionHeader(
            title: AppStrings.exportFormat,
            icon: Icons.format_list_bulleted,
          ),
          const SizedBox(height: AppSpacing.lg),
          NeoChoiceChips<ExportFormat>(
            options: ExportFormat.values,
            selected: _selectedFormat,
            onSelected: (format) {
              setState(() => _selectedFormat = format);
              _generateExport();
            },
            labelBuilder: (format) => format.displayName,
          ),
        ],
      ),
    );
  }

  Widget _buildPreview() {
    return NeoCard(
      margin: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          NeoSectionHeader(
            title: AppStrings.exportPreview,
            icon: Icons.preview_outlined,
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                NeoChip(
                  label: _selectedFormat.fileExtension.toUpperCase(),
                  color: AppColors.primary,
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Container(
            width: double.infinity,
            constraints: const BoxConstraints(maxHeight: 400),
            decoration: BoxDecoration(
              color: AppColors.dark,
              border: Border.all(color: AppColors.border, width: 2),
            ),
            child: _isLoading
                ? const Center(
                    child: Padding(
                      padding: EdgeInsets.all(AppSpacing.xxl),
                      child: CircularProgressIndicator(
                        color: AppColors.primary,
                      ),
                    ),
                  )
                : SingleChildScrollView(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    child: SelectableText(
                      _exportedContent ?? '',
                      style: AppTextStyles.monospace.copyWith(
                        color: AppColors.light,
                        fontSize: 11,
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildActions(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: NeoButton.primary(
                onPressed: _copyToClipboard,
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.copy, size: 18),
                    SizedBox(width: AppSpacing.sm),
                    Text(AppStrings.exportCopy),
                  ],
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: NeoButton.secondary(
                onPressed: _share,
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.share, size: 18),
                    SizedBox(width: AppSpacing.sm),
                    Text(AppStrings.exportShare),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        NeoButton.accent(
          onPressed: _saveFile,
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.save_alt, size: 18),
              SizedBox(width: AppSpacing.sm),
              Text(AppStrings.exportSave),
            ],
          ),
        ),
      ],
    );
  }

  void _copyToClipboard() {
    if (_exportedContent == null) return;

    Clipboard.setData(ClipboardData(text: _exportedContent!));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(AppStrings.msgCopied),
        backgroundColor: AppColors.success,
      ),
    );
  }

  void _share() {
    if (_exportedContent == null) return;

    // Note: For full share functionality, you would use share_plus package
    // For now, we just copy to clipboard
    _copyToClipboard();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Content copied (share requires share_plus package)'),
        backgroundColor: AppColors.info,
      ),
    );
  }

  void _saveFile() {
    if (_exportedContent == null) return;

    // Note: For full file save functionality, you would use file_picker or path_provider
    // For now, we just copy to clipboard
    _copyToClipboard();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Content copied (save requires file picker)'),
        backgroundColor: AppColors.info,
      ),
    );
  }
}
