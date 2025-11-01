import 'package:flutter/material.dart';
import 'package:mealtime_app/features/cats/domain/entities/cat.dart';
import 'package:mealtime_app/shared/widgets/loading_widget.dart';

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
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildNameField(),
            const SizedBox(height: 16),
            _buildBreedField(),
            const SizedBox(height: 16),
            _buildGenderField(),
            const SizedBox(height: 16),
            _buildColorField(),
            const SizedBox(height: 16),
            _buildBirthDateField(),
            const SizedBox(height: 16),
            _buildWeightFields(),
            const SizedBox(height: 16),
            _buildDescriptionField(),
            const SizedBox(height: 24),
            _buildSubmitButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildNameField() {
    return TextFormField(
      controller: _nameController,
      decoration: const InputDecoration(
        labelText: 'Nome *',
        hintText: 'Digite o nome do gato',
        border: OutlineInputBorder(),
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Nome é obrigatório';
        }
        return null;
      },
    );
  }

  Widget _buildBreedField() {
    return TextFormField(
      controller: _breedController,
      decoration: const InputDecoration(
        labelText: 'Raça',
        hintText: 'Ex: Persa, Siamês, SRD',
        border: OutlineInputBorder(),
      ),
    );
  }

  Widget _buildGenderField() {
    return DropdownButtonFormField<String>(
      key: _genderFieldKey,
      initialValue: _selectedGender,
      decoration: const InputDecoration(
        labelText: 'Sexo',
        border: OutlineInputBorder(),
      ),
      items: const [
        DropdownMenuItem(value: 'M', child: Text('Macho')),
        DropdownMenuItem(value: 'F', child: Text('Fêmea')),
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
      decoration: const InputDecoration(
        labelText: 'Cor',
        hintText: 'Ex: Branco, Preto, Tigrado',
        border: OutlineInputBorder(),
      ),
    );
  }

  Widget _buildBirthDateField() {
    return InkWell(
      onTap: _selectBirthDate,
      child: InputDecorator(
        decoration: const InputDecoration(
          labelText: 'Data de Nascimento *',
          border: OutlineInputBorder(),
        ),
        child: Text(
          _selectedBirthDate != null
              ? '${_selectedBirthDate!.day}/${_selectedBirthDate!.month}/${_selectedBirthDate!.year}'
              : 'Selecione a data',
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
            decoration: const InputDecoration(
              labelText: 'Peso Atual (kg)',
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.number,
            validator: (value) {
              if (value != null && value.isNotEmpty) {
                final weight = double.tryParse(value);
                if (weight == null || weight <= 0) {
                  return 'Peso inválido';
                }
              }
              return null;
            },
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: TextFormField(
            controller: _targetWeightController,
            decoration: const InputDecoration(
              labelText: 'Peso Ideal (kg)',
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.number,
            validator: (value) {
              if (value != null && value.isNotEmpty) {
                final weight = double.tryParse(value);
                if (weight == null || weight <= 0) {
                  return 'Peso inválido';
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
      decoration: const InputDecoration(
        labelText: 'Descrição',
        hintText: 'Informações adicionais sobre o gato',
        border: OutlineInputBorder(),
      ),
      maxLines: 3,
    );
  }

  Widget _buildSubmitButton() {
    return ElevatedButton(
      onPressed: widget.isLoading ? null : _submitForm,
      child: widget.isLoading
          ? const Material3LoadingIndicator(size: 20.0)
          : Text(widget.initialCat != null ? 'Atualizar Gato' : 'Criar Gato'),
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
