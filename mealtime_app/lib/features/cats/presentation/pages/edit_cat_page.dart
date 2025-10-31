import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:mealtime_app/features/cats/domain/entities/cat.dart';
import 'package:mealtime_app/features/cats/presentation/bloc/cats_bloc.dart';
import 'package:mealtime_app/features/cats/presentation/bloc/cats_event.dart';
import 'package:mealtime_app/features/cats/presentation/bloc/cats_state.dart';
import 'package:mealtime_app/features/cats/presentation/widgets/cat_form.dart';
import 'package:mealtime_app/shared/widgets/loading_widget.dart';
import 'package:mealtime_app/shared/widgets/error_widget.dart';

class EditCatPage extends StatefulWidget {
  final String catId;

  const EditCatPage({super.key, required this.catId});

  @override
  State<EditCatPage> createState() => _EditCatPageState();
}

class _EditCatPageState extends State<EditCatPage> {
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    context.read<CatsBloc>().add(LoadCatById(widget.catId));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Editar Gato'),
        actions: [
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Material3LoadingIndicator(size: 20.0),
            ),
        ],
      ),
      body: BlocConsumer<CatsBloc, CatsState>(
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
        builder: (context, state) {
          if (state is CatsLoading) {
            return const LoadingWidget();
          } else if (state is CatsError) {
            return CustomErrorWidget(
              message: state.failure.message,
              onRetry: () {
                context.read<CatsBloc>().add(LoadCatById(widget.catId));
              },
            );
          } else if (state is CatLoaded) {
            return CatForm(
              initialCat: state.cat,
              onSubmit: _updateCat,
              isLoading: _isLoading,
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  void _updateCat(Cat cat) {
    context.read<CatsBloc>().add(UpdateCat(cat));
  }
}
