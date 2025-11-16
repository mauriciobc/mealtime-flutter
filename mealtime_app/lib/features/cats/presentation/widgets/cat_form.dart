import 'package:flutter/material.dart';
import 'package:material_design/material_design.dart';
import 'package:mealtime_app/features/cats/domain/entities/cat.dart';
import 'package:mealtime_app/shared/widgets/loading_widget.dart';
import 'package:mealtime_app/core/localization/app_localizations_extension.dart';

class CatForm extends StatefulWidget {
  final Cat? initialCat;
  final Function(Cat) onSubmit;
  final bool isLoading;

  const CatForm({
    super.key,
    this.initialCat,
    required this.onSubmit,
    this.isLoading = false,
  });

  @override
  State<CatForm> createState() => _CatFormState();
}

class _CatFormState extends State<CatForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _breedController = TextEditingController();
  final _colorController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _currentWeightController = TextEditingController();
  final _targetWeightController = TextEditingController();

  String? _selectedGender;
  DateTime? _selectedBirthDate;
  String? _selectedHomeId;
  
  Key _genderFieldKey = const ValueKey(null);

  @override
  void initState() {
    super.initState();
    if (widget.initialCat != null) {
      _populateForm(widget.initialCat!);
    } else {
      _selectedBirthDate = DateTime.now().subtract(const Duration(days: 365));
    }
  }

  void _populateForm(Cat cat) {
    _nameController.text = cat.name;
    _breedController.text = cat.breed ?? '';
    _colorController.text = cat.color ?? '';
    _descriptionController.text = cat.description ?? '';
    _currentWeightController.text = cat.currentWeight?.toString() ?? '';
    _targetWeightController.text = cat.targetWeight?.toString() ?? '';
    _selectedGender = cat.gender;
    _selectedBirthDate = cat.birthDate;
    _selectedHomeId = cat.homeId;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _breedController.dispose();
    _colorController.dispose();
    _descriptionController.dispose();
    _currentWeightController.dispose();
    _targetWeightController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        padding: const M3EdgeInsets.all(M3SpacingToken.space16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildNameField(),
            SizedBox(height: M3SpacingToken.space16.value),
            _buildBreedField(),
            SizedBox(height: M3SpacingToken.space16.value),
            _buildGenderField(),
            SizedBox(height: M3SpacingToken.space16.value),
            _buildColorField(),
            SizedBox(height: M3SpacingToken.space16.value),
            _buildBirthDateField(),
            SizedBox(height: M3SpacingToken.space16.value),
            _buildWeightFields(),
            SizedBox(height: M3SpacingToken.space16.value),
            _buildDescriptionField(),
            SizedBox(height: M3SpacingToken.space24.value),
            _buildSubmitButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildNameField() {
    return TextFormField(
      controller: _nameController,
      decoration: InputDecoration(
        labelText: context.l10n.cats_name,
        hintText: context.l10n.cats_nameHint,
        border: const OutlineInputBorder(),
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return context.l10n.cats_nameRequired;
        }
        return null;
      },
    );
  }

  Widget _buildBreedField() {
    return TextFormField(
      controller: _breedController,
      decoration: InputDecoration(
        labelText: context.l10n.cats_breed,
        hintText: context.l10n.cats_breedHint,
        border: const OutlineInputBorder(),
      ),
    );
  }

  Widget _buildGenderField() {
    return DropdownButtonFormField<String>(
      key: _genderFieldKey,
      initialValue: _selectedGender,
      decoration: InputDecoration(
        labelText: context.l10n.cats_gender,
        border: const OutlineInputBorder(),
      ),
      items: [
        DropdownMenuItem(value: 'M', child: Text(context.l10n.cats_genderMale)),
        DropdownMenuItem(value: 'F', child: Text(context.l10n.cats_genderFemale)),
      ],
      onChanged: (value) {
        setState(() {
          _selectedGender = value;
          _genderFieldKey = ValueKey(value);
        });
      },
    );
  }

  Widget _buildColorField() {
    return TextFormField(
      controller: _colorController,
      decoration: InputDecoration(
        labelText: context.l10n.cats_color,
        hintText: 'Ex: Branco, Preto, Tigrado',
        border: const OutlineInputBorder(),
      ),
    );
  }

  Widget _buildBirthDateField() {
    return InkWell(
      onTap: _selectBirthDate,
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: context.l10n.cats_birthDateRequired,
          border: const OutlineInputBorder(),
        ),
        child: Text(
          _selectedBirthDate != null
              ? '${_selectedBirthDate!.day}/${_selectedBirthDate!.month}/${_selectedBirthDate!.year}'
              : context.l10n.cats_selectDate,
        ),
      ),
    );
  }

  Widget _buildWeightFields() {
    return Row(
      children: [
        Expanded(
          child: TextFormField(
            controller: _currentWeightController,
            decoration: InputDecoration(
              labelText: context.l10n.cats_currentWeight,
              border: const OutlineInputBorder(),
            ),
            keyboardType: TextInputType.number,
            validator: (value) {
              if (value != null && value.isNotEmpty) {
                final weight = double.tryParse(value);
                if (weight == null || weight <= 0) {
                  return context.l10n.cats_invalidWeight;
                }
              }
              return null;
            },
          ),
        ),
        SizedBox(width: M3SpacingToken.space16.value),
        Expanded(
          child: TextFormField(
            controller: _targetWeightController,
            decoration: InputDecoration(
              labelText: context.l10n.cats_targetWeight,
              border: const OutlineInputBorder(),
            ),
            keyboardType: TextInputType.number,
            validator: (value) {
              if (value != null && value.isNotEmpty) {
                final weight = double.tryParse(value);
                if (weight == null || weight <= 0) {
                  return context.l10n.cats_invalidWeight;
                }
              }
              return null;
            },
          ),
        ),
      ],
    );
  }

  Widget _buildDescriptionField() {
    return TextFormField(
      controller: _descriptionController,
      decoration: InputDecoration(
        labelText: context.l10n.common_description,
        hintText: context.l10n.cats_descriptionHint,
        border: const OutlineInputBorder(),
      ),
      maxLines: 3,
    );
  }

  Widget _buildSubmitButton() {
    return ElevatedButton(
      onPressed: widget.isLoading ? null : _submitForm,
      child: widget.isLoading
          ? const Material3LoadingIndicator(size: 20.0)
          : Text(widget.initialCat != null ? context.l10n.cats_saveCat : context.l10n.cats_createCat),
    );
  }

  Future<void> _selectBirthDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedBirthDate ?? DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 365 * 20)),
      lastDate: DateTime.now(),
    );

    if (date != null) {
      setState(() {
        _selectedBirthDate = date;
      });
    }
  }

  void _submitForm() {
    if (_formKey.currentState!.validate() && _selectedBirthDate != null) {
      final cat = Cat(
        id: widget.initialCat?.id ?? '',
        name: _nameController.text.trim(),
        breed: _breedController.text.trim().isEmpty
            ? null
            : _breedController.text.trim(),
        birthDate: _selectedBirthDate!,
        gender: _selectedGender,
        color: _colorController.text.trim().isEmpty
            ? null
            : _colorController.text.trim(),
        description: _descriptionController.text.trim().isEmpty
            ? null
            : _descriptionController.text.trim(),
        currentWeight: _currentWeightController.text.isNotEmpty
            ? double.tryParse(_currentWeightController.text)
            : null,
        targetWeight: _targetWeightController.text.isNotEmpty
            ? double.tryParse(_targetWeightController.text)
            : null,
        homeId:
            _selectedHomeId ?? '', // TODO: Implementar seleção de residência
        createdAt: widget.initialCat?.createdAt ?? DateTime.now(),
        updatedAt: DateTime.now(),
        isActive: widget.initialCat?.isActive ?? true,
      );

      widget.onSubmit(cat);
    }
  }
}
