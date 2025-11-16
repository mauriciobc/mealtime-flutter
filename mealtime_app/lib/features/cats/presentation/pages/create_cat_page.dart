import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:mealtime_app/features/cats/domain/entities/cat.dart';
import 'package:mealtime_app/features/cats/presentation/bloc/cats_bloc.dart';
import 'package:mealtime_app/features/cats/presentation/bloc/cats_event.dart';
import 'package:mealtime_app/features/cats/presentation/bloc/cats_state.dart';
import 'package:mealtime_app/features/cats/presentation/widgets/cat_form.dart';
import 'package:mealtime_app/shared/widgets/loading_widget.dart';
import 'package:mealtime_app/core/localization/app_localizations_extension.dart';

class CreateCatPage extends StatefulWidget {
  const CreateCatPage({super.key});

  @override
  State<CreateCatPage> createState() => _CreateCatPageState();
}

class _CreateCatPageState extends State<CreateCatPage> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.cats_addCat),
        actions: [
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Material3LoadingIndicator(size: 20.0),
            ),
        ],
      ),
      body: BlocListener<CatsBloc, CatsState>(
        listener: (context, state) {
          if (state is CatOperationInProgress) {
            setState(() {
              _isLoading = true;
            });
          } else if (state is CatOperationSuccess) {
            setState(() {
              _isLoading = false;
            });
            context.pop();
          } else if (state is CatsError) {
            setState(() {
              _isLoading = false;
            });
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.failure.message),
                backgroundColor: Theme.of(context).colorScheme.error,
              ),
            );
          }
        },
        child: CatForm(onSubmit: _createCat, isLoading: _isLoading),
      ),
    );
  }

  void _createCat(Cat cat) {
    context.read<CatsBloc>().add(CreateCat(cat));
  }
}
