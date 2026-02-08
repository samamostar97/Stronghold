import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:stronghold_core/stronghold_core.dart';
import '../constants/app_colors.dart';
import '../constants/app_spacing.dart';
import '../constants/app_text_styles.dart';
import '../providers/supplement_provider.dart';
import '../utils/error_handler.dart';
import '../utils/validators.dart';
import 'dialog_text_field.dart';

class SupplementEditDialog extends ConsumerStatefulWidget {
  const SupplementEditDialog({super.key, required this.supplement});
  final SupplementResponse supplement;

  @override
  ConsumerState<SupplementEditDialog> createState() => _State();
}

class _State extends ConsumerState<SupplementEditDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _name;
  late final TextEditingController _price;
  late final TextEditingController _description;
  SupplementCategoryResponse? _category;
  SupplierResponse? _supplier;
  String? _imagePath;
  bool _imageDeleted = false;
  String? _currentImageUrl;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _name = TextEditingController(text: widget.supplement.name);
    _price = TextEditingController(text: widget.supplement.price.toString());
    _description =
        TextEditingController(text: widget.supplement.description ?? '');
    _currentImageUrl = widget.supplement.imageUrl;
  }

  @override
  void dispose() {
    _name.dispose();
    _price.dispose();
    _description.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final result = await FilePicker.platform
        .pickFiles(type: FileType.image, allowMultiple: false);
    if (result != null && result.files.isNotEmpty) {
      setState(() {
        _imagePath = result.files.first.path;
        _imageDeleted = false;
      });
    }
  }

  void _removeImage() {
    setState(() {
      _imagePath = null;
      _imageDeleted = true;
    });
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_category == null || _supplier == null) return;
    setState(() => _saving = true);
    try {
      final request = UpdateSupplementRequest(
        name: _name.text.trim(),
        price: double.parse(_price.text.trim()),
        description: _description.text.trim().isEmpty
            ? null
            : _description.text.trim(),
        supplementCategoryId: _category!.id,
        supplierId: _supplier!.id,
      );
      await ref
          .read(supplementListProvider.notifier)
          .update(widget.supplement.id, request);
      if (_imageDeleted && _currentImageUrl != null) {
        await ref
            .read(supplementListProvider.notifier)
            .deleteImage(widget.supplement.id);
      } else if (_imagePath != null) {
        await ref
            .read(supplementListProvider.notifier)
            .uploadImage(widget.supplement.id, _imagePath!);
      }
      if (mounted) Navigator.of(context).pop(true);
    } catch (e) {
      if (mounted) {
        Navigator.of(context)
            .pop(ErrorHandler.getContextualMessage(e, 'edit-supplement'));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final categoriesAsync = ref.watch(categoriesDropdownProvider);
    final suppliersAsync = ref.watch(suppliersDropdownProvider);

    return Dialog(
      backgroundColor: AppColors.surfaceSolid,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusXl)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 500),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xxl),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(children: [
                    Expanded(
                        child: Text('Izmijeni suplement',
                            style: AppTextStyles.headingMd)),
                    IconButton(
                      icon: Icon(LucideIcons.x,
                          color: AppColors.textMuted, size: 20),
                      onPressed: () => Navigator.of(context).pop(false),
                    ),
                  ]),
                  const SizedBox(height: AppSpacing.xl),
                  _imageSection(),
                  const SizedBox(height: AppSpacing.lg),
                  DialogTextField(
                      controller: _name,
                      label: 'Naziv',
                      validator: (v) => Validators.stringLength(v, 2, 100)),
                  const SizedBox(height: AppSpacing.lg),
                  DialogTextField(
                      controller: _price,
                      label: 'Cijena (KM)',
                      keyboardType: const TextInputType.numberWithOptions(
                          decimal: true),
                      validator: Validators.price),
                  const SizedBox(height: AppSpacing.lg),
                  DialogTextField(
                      controller: _description,
                      label: 'Opis (opcionalno)',
                      maxLines: 3,
                      validator: Validators.description),
                  const SizedBox(height: AppSpacing.lg),
                  categoriesAsync.when(
                    loading: () => const LinearProgressIndicator(),
                    error: (e, _) => Text('Greska: $e',
                        style: AppTextStyles.bodySm
                            .copyWith(color: AppColors.error)),
                    data: (cats) {
                      if (_category == null && cats.isNotEmpty) {
                        _category = cats.firstWhere(
                          (c) =>
                              c.id ==
                              widget.supplement.supplementCategoryId,
                          orElse: () => cats.first,
                        );
                      }
                      return _dropdown<SupplementCategoryResponse>(
                        label: 'Kategorija',
                        value: _category,
                        items: cats,
                        itemLabel: (c) => c.name,
                        onChanged: (v) => setState(() => _category = v),
                      );
                    },
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  suppliersAsync.when(
                    loading: () => const LinearProgressIndicator(),
                    error: (e, _) => Text('Greska: $e',
                        style: AppTextStyles.bodySm
                            .copyWith(color: AppColors.error)),
                    data: (sups) {
                      if (_supplier == null && sups.isNotEmpty) {
                        _supplier = sups.firstWhere(
                          (s) => s.id == widget.supplement.supplierId,
                          orElse: () => sups.first,
                        );
                      }
                      return _dropdown<SupplierResponse>(
                        label: 'Dobavljac',
                        value: _supplier,
                        items: sups,
                        itemLabel: (s) => s.name,
                        onChanged: (v) => setState(() => _supplier = v),
                      );
                    },
                  ),
                  const SizedBox(height: AppSpacing.xxl),
                  _actions(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _imageSection() => Row(children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
            border: Border.all(color: AppColors.border),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
            child: _imagePath != null
                ? Image.file(File(_imagePath!), fit: BoxFit.cover)
                : (_currentImageUrl != null && !_imageDeleted)
                    ? Image.network(
                        ApiConfig.imageUrl(_currentImageUrl!),
                        fit: BoxFit.cover,
                        errorBuilder: (_, e, s) => Icon(LucideIcons.image,
                            size: 40, color: AppColors.textMuted),
                      )
                    : Icon(LucideIcons.image,
                        size: 40, color: AppColors.textMuted),
          ),
        ),
        const SizedBox(width: AppSpacing.lg),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextButton.icon(
              onPressed: _pickImage,
              icon: Icon(LucideIcons.upload, size: 18),
              label: Text(
                  _imagePath != null ? 'Promijeni sliku' : 'Odaberi sliku'),
              style:
                  TextButton.styleFrom(foregroundColor: AppColors.secondary),
            ),
            if (_currentImageUrl != null || _imagePath != null)
              TextButton.icon(
                onPressed: _removeImage,
                icon: Icon(LucideIcons.trash2, size: 18),
                label: const Text('Ukloni sliku'),
                style:
                    TextButton.styleFrom(foregroundColor: AppColors.error),
              ),
          ],
        ),
      ]);

  Widget _actions() => Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          TextButton(
            onPressed:
                _saving ? null : () => Navigator.of(context).pop(false),
            child: Text('Odustani',
                style:
                    AppTextStyles.bodyMd.copyWith(color: AppColors.textMuted)),
          ),
          const SizedBox(width: AppSpacing.md),
          ElevatedButton(
            onPressed: _saving ? null : _save,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.background,
              shape: RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(AppSpacing.radiusSm)),
              padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.xxl, vertical: AppSpacing.md),
            ),
            child: _saving
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: AppColors.background))
                : Text('Spremi',
                    style: AppTextStyles.bodyBold
                        .copyWith(color: AppColors.background)),
          ),
        ],
      );

  Widget _dropdown<T>({
    required String label,
    required T? value,
    required List<T> items,
    required String Function(T) itemLabel,
    required ValueChanged<T?> onChanged,
  }) {
    return DropdownButtonFormField<T>(
      initialValue: value,
      isExpanded: true,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: AppTextStyles.bodySm.copyWith(color: AppColors.textMuted),
        filled: true,
        fillColor: AppColors.surface,
        contentPadding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg, vertical: AppSpacing.md),
        enabledBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: AppColors.border),
          borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: AppColors.textSecondary),
          borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
        ),
      ),
      dropdownColor: AppColors.surface,
      style: AppTextStyles.bodyMd,
      items: items
          .map((item) => DropdownMenuItem<T>(
              value: item,
              child:
                  Text(itemLabel(item), overflow: TextOverflow.ellipsis)))
          .toList(),
      onChanged: onChanged,
      validator: (v) => v == null ? 'Obavezno polje' : null,
    );
  }
}
