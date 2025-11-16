import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:material_design/material_design.dart';
import 'package:mealtime_app/features/homes/domain/entities/home.dart';
import 'package:mealtime_app/features/homes/presentation/bloc/homes_bloc.dart';
import 'package:mealtime_app/features/homes/presentation/widgets/home_form.dart';

class EditHomePage extends StatefulWidget {
  final Home home;

  const EditHomePage({super.key, required this.home});

  @override
  State<EditHomePage> createState() => _EditHomePageState();
}

class _EditHomePageState extends State<EditHomePage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _descriptionController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.home.name);
    _descriptionController = TextEditingController(
      text: widget.home.description ?? '',
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Editar Residência'),
        actions: [
          TextButton(onPressed: _saveHome, child: const Text('Salvar')),
        ],
      ),
      body: BlocListener<HomesBloc, HomesState>(
        listener: (context, state) {
          if (state is HomesError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Theme.of(context).colorScheme.error,
              ),
            );
          } else if (state is HomesLoaded) {
            // Home editada com sucesso
            context.pop();
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Residência atualizada com sucesso!'),
              ),
            );
          }
        },
        child: SingleChildScrollView(
          padding: const M3EdgeInsets.all(M3SpacingToken.space16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Editar Residência',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                SizedBox(height: M3SpacingToken.space24.value),
                HomeForm(
                  nameController: _nameController,
                  descriptionController: _descriptionController,
                ),
                SizedBox(height: M3SpacingToken.space32.value),
                ElevatedButton(
                  onPressed: _saveHome,
                  child: const Text('Salvar Alterações'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _saveHome() {
    if (_formKey.currentState!.validate()) {
      context.read<HomesBloc>().add(
        UpdateHomeEvent(
          id: widget.home.id,
          name: _nameController.text.trim(),
          description: _descriptionController.text.trim().isEmpty
              ? null
              : _descriptionController.text.trim(),
        ),
      );
    }
  }
}
