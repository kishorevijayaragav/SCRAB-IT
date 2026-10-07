import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/formatters.dart';
import '../../core/utils/validators.dart';
import '../../models/inventory_item.dart';
import '../../widgets/custom_button.dart';

class AddEditInventorySheet extends StatefulWidget {
  final InventoryItem? item;
  final Future<bool> Function({
    required String material,
    required double quantity,
    required double pricePerKg,
  }) onSave;

  const AddEditInventorySheet({
    super.key,
    this.item,
    required this.onSave,
  });

  @override
  State<AddEditInventorySheet> createState() => _AddEditInventorySheetState();
}

class _AddEditInventorySheetState extends State<AddEditInventorySheet> {
  static const Map<String, double> defaultPrices = {
    'Aluminium': 180,
    'Copper': 720,
    'Iron': 40,
    'Brass': 480,
    'Plastic': 30,
    'Paper': 15,
    'E-Waste': 120,
  };

  final _formKey = GlobalKey<FormState>();
  late String _selectedMaterial;
  late final TextEditingController _qtyController;
  late final TextEditingController _priceController;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _selectedMaterial = widget.item?.material ?? 'Aluminium';
    final initialQty = widget.item?.quantity ?? 1.0;
    final initialPrice = widget.item?.pricePerKg ?? defaultPrices[_selectedMaterial] ?? 180.0;

    _qtyController = TextEditingController(
      text: initialQty.toStringAsFixed(initialQty.truncateToDouble() == initialQty ? 0 : 1),
    );
    _priceController = TextEditingController(text: initialPrice.round().toString());
  }

  @override
  void dispose() {
    _qtyController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  void _onMaterialChanged(String? material) {
    if (material == null) return;
    setState(() {
      _selectedMaterial = material;
      final defaultPrice = defaultPrices[material] ?? 100.0;
      _priceController.text = defaultPrice.round().toString();
    });
  }

  double get _calculatedTotal {
    final q = double.tryParse(_qtyController.text) ?? 0;
    final p = double.tryParse(_priceController.text) ?? 0;
    return q * p;
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final q = double.parse(_qtyController.text.trim());
    final p = double.parse(_priceController.text.trim());

    setState(() => _isSaving = true);
    final ok = await widget.onSave(
      material: _selectedMaterial,
      quantity: q,
      pricePerKg: p,
    );
    if (!mounted) return;
    setState(() => _isSaving = false);
    if (ok) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.item != null;

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 12,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Bottom sheet drag handle
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: AppColors.line,
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
              ),

              // Title
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    isEdit ? 'Edit Inventory Item' : 'Add Inventory Item',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: AppColors.ink,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded, size: 20),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Material Dropdown
              DropdownButtonFormField<String>(
                value: _selectedMaterial,
                decoration: const InputDecoration(
                  labelText: 'Material',
                  prefixIcon: Icon(Icons.category_outlined, size: 20),
                ),
                items: defaultPrices.keys.map((name) {
                  final price = defaultPrices[name]!.round();
                  return DropdownMenuItem<String>(
                    value: name,
                    child: Text('$name — ₹$price / kg'),
                  );
                }).toList(),
                onChanged: _onMaterialChanged,
              ),
              const SizedBox(height: 14),

              // Quantity & Price Row
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _qtyController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: const InputDecoration(
                        labelText: 'Quantity (kg)',
                        hintText: '1.0',
                        prefixIcon: Icon(Icons.scale_rounded, size: 20),
                      ),
                      validator: (v) => Validators.positiveNumber(v, 'Quantity'),
                      onChanged: (_) => setState(() {}),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _priceController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: const InputDecoration(
                        labelText: 'Price / kg (₹)',
                        hintText: '180',
                        prefixIcon: Icon(Icons.currency_rupee_rounded, size: 20),
                      ),
                      validator: (v) => Validators.positiveNumber(v, 'Price'),
                      onChanged: (_) => setState(() {}),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Total Calculation Preview Pill
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: AppColors.greenSoft,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.greenLine),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Calculated Total Value',
                      style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
                        color: AppColors.greenDark,
                      ),
                    ),
                    Text(
                      Formatters.money(_calculatedTotal),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: AppColors.greenDark,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Submit Button
              CustomButton(
                text: isEdit ? 'Update Item' : 'Save Item',
                icon: isEdit ? Icons.check_rounded : Icons.add_rounded,
                isLoading: _isSaving,
                onPressed: _submit,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
