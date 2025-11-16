import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:material_design/material_design.dart';
import 'package:mealtime_app/features/homes/presentation/bloc/homes_bloc.dart';
import 'package:mealtime_app/features/homes/presentation/widgets/home_form.dart';
import 'package:mealtime_app/core/localization/app_localizations_extension.dart';

class CreateHomePage extends StatefulWidget {
  const CreateHomePage({super.key});

  @override
  State<CreateHomePage> createState() => _CreateHomePageState();
}

class _CreateHomePageState extends State<CreateHomePage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();

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
        title: Text(context.l10n.homes_create),
        actions: [
          TextButton(onPressed: _saveHome, child: Text(context.l10n.common_save)),
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
            // Home criada com sucesso
            context.pop();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(context.l10n.homes_homeCreated)),
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
                  context.l10n.homes_info,
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
                  child: Text(context.l10n.homes_createHome),
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
        CreateHomeEvent(
          name: _nameController.text.trim(),
          description: _descriptionController.text.trim().isEmpty
              ? null
              : _descriptionController.text.trim(),
        ),
      );
    }
  }
}
