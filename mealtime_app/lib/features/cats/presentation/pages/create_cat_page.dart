import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:material_design/material_design.dart';
import 'package:mealtime_app/features/cats/domain/entities/cat.dart';
import 'package:mealtime_app/features/cats/presentation/bloc/cats_bloc.dart';
import 'package:mealtime_app/features/cats/presentation/bloc/cats_event.dart';
import 'package:mealtime_app/features/cats/presentation/bloc/cats_state.dart';
import 'package:mealtime_app/features/cats/presentation/widgets/cat_form.dart';
import 'package:mealtime_app/shared/widgets/loading_widget.dart';
import 'package:mealtime_app/core/localization/app_localizations_extension.dart';
import 'package:material_3_expressive/material_3_expressive.dart';

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
      appBar: M3EAppBar.top(
        titleText: context.l10n.cats_addCat,
        automaticallyImplyLeading: true,
        actions: [
          if (_isLoading)
            const Padding(
              padding: M3EdgeInsets.all(M3SpacingToken.space16),
              child: Material3LoadingIndicator(size: 20.0),
            ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: BlocListener<CatsBloc, CatsState>(
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
                }
              },
              child: CatForm(onSubmit: _createCat, isLoading: _isLoading),
            ),
          ),
          BlocBuilder<CatsBloc, CatsState>(
            buildWhen: (prev, curr) =>
                curr is CatsError || prev is CatsError,
            builder: (context, state) {
              if (state is CatsError) {
                return Padding(
                  padding: const M3EdgeInsets.all(M3SpacingToken.space16),
                  child: SelectableText.rich(
                    TextSpan(
                      text: state.failure.message,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                        fontSize: 14,
                      ),
                    ),
                  ),
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
    );
  }

  void _createCat(Cat cat) {
    context.read<CatsBloc>().add(CreateCat(cat));
  }
}
