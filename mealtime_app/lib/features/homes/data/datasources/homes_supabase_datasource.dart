import 'package:mealtime_app/core/errors/exceptions.dart';
import 'package:mealtime_app/core/supabase/supabase_config.dart';
import 'package:mealtime_app/features/homes/data/models/household_model.dart';
import 'package:flutter/foundation.dart';

import 'package:mealtime_app/features/homes/data/datasources/homes_remote_datasource.dart';

/// Data source que usa Supabase diretamente para households
/// A API /households do backend requer autenticação via Supabase session (cookies),
/// que não funciona com Dio/Retrofit em mobile. Usamos o Supabase client diretamente.
class HomesSupabaseDataSourceImpl implements HomesRemoteDataSource {
  final supabase = SupabaseConfig.client;

  @override
  Future<List<HouseholdModel>> getHomes() async {
    try {
      // Buscar households onde o usuário é owner
      final user = supabase.auth.currentUser;
      if (user == null) {
        throw ServerException('Usuário não autenticado');
      }

      debugPrint('[HomesSupabaseDataSource] Buscando households para user: ${user.id}');

      // Buscar households diretamente onde o usuário é owner
      final response = await supabase
          .from('households')
          .select()
          .eq('owner_id', user.id);

      debugPrint('[HomesSupabaseDataSource] Resposta: $response');

      // Converter para models
      final households = <HouseholdModel>[];
      final responseList = response as List;
      for (final item in responseList) {
        final itemMap = item as Map<String, dynamic>;
        households.add(HouseholdModel.fromJson(itemMap));
      }

      debugPrint('[HomesSupabaseDataSource] Encontrados ${households.length} households');
      return households;
    } catch (e) {
      debugPrint('[HomesSupabaseDataSource] Erro: $e');
      throw ServerException('Erro ao buscar residências: ${e.toString()}');
    }
  }

  @override
  Future<HouseholdModel> createHome({
    required String name,
    String? description,
  }) async {
    try {
      final user = supabase.auth.currentUser;
      if (user == null) {
        throw ServerException('Usuário não autenticado');
      }

      // Criar household
      final response = await supabase
          .from('households')
          .insert({
            'name': name,
            'owner_id': user.id,
          })
          .select()
          .single();

      final household = HouseholdModel.fromJson(response);

      // Adicionar o criador como membro
      await supabase.from('household_members').insert({
        'household_id': household.id,
        'user_id': user.id,
        'role': 'owner',
      });

      return household;
    } catch (e) {
      throw ServerException('Erro ao criar residência: ${e.toString()}');
    }
  }

  @override
  Future<HouseholdModel> updateHome({
    required String id,
    required String name,
    String? description,
  }) async {
    try {
      final response = await supabase
          .from('households')
          .update({'name': name})
          .eq('id', id)
          .select()
          .single();

      return HouseholdModel.fromJson(response);
    } catch (e) {
      throw ServerException('Erro ao atualizar residência: ${e.toString()}');
    }
  }

  @override
  Future<void> deleteHome(String id) async {
    try {
      await supabase.from('households').delete().eq('id', id);
    } catch (e) {
      throw ServerException('Erro ao excluir residência: ${e.toString()}');
    }
  }

  @override
  Future<void> setActiveHome(String id) async {
    try {
      // Armazenar localmente o household ativo
      // TODO: Implementar lógica se necessário
      debugPrint('[HomesSupabaseDataSource] setActiveHome: $id');
    } catch (e) {
      throw ServerException('Erro ao definir residência ativa: ${e.toString()}');
    }
  }
}

