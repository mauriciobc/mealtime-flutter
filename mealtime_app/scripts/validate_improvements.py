#!/usr/bin/env python3
"""
Script para validar melhorias de performance comparando baseline vs optimized
Uso: python3 scripts/validate_improvements.py
"""

import json
import sys
from pathlib import Path


def load_json(filepath):
    """Carrega arquivo JSON"""
    try:
        with open(filepath, 'r', encoding='utf-8') as f:
            return json.load(f)
    except FileNotFoundError:
        print(f"⚠️  Arquivo não encontrado: {filepath}")
        return None
    except json.JSONDecodeError as e:
        print(f"❌ Erro ao decodificar JSON: {e}")
        return None


def calculate_improvement(before, after):
    """Calcula porcentagem de melhoria"""
    if before is None or after is None:
        return None
    if before == 0:
        # Se baseline é 0, calcular aumento em vez de %
        return after * 100 if after > 0 else None
    return ((before - after) / before) * 100


def format_duration(ms):
    """Formata duração em formato legível"""
    if ms is None:
        return "N/A"
    if ms < 1000:
        return f"{ms:.1f} ms"
    elif ms < 60000:
        return f"{ms/1000:.1f} s"
    else:
        return f"{ms/60000:.1f} min"


def main():
    print("="*80)
    print("📊 VALIDAÇÃO DE MELHORIAS DE PERFORMANCE")
    print("="*80)
    print()
    
    # Carregar análises
    script_dir = Path(__file__).parent.parent
    baseline_file = script_dir / 'benchmarks' / 'analysis' / 'baseline_analysis.json'
    optimized_file = script_dir / 'benchmarks' / 'analysis' / 'optimized_analysis.json'
    
    baseline = load_json(baseline_file)
    optimized = load_json(optimized_file)
    
    if baseline is None and optimized is None:
        print("⚠️  Nenhum snapshot encontrado. Mostrando comparação com dados conhecidos...")
        print()
        # Usar dados conhecidos do baseline para comparação
        compare_with_known_baseline(None)
        return
    
    if baseline is None:
        print("⚠️  Baseline não encontrado. Execute primeiro:")
        print("   python3 scripts/analyze_devtools_snapshot.py baseline")
        print()
        return
    
    if optimized is None:
        print("⚠️  Optimized não encontrado. Mostrando comparação com dados conhecidos...")
        print()
        # Usar dados conhecidos do baseline para comparação
        compare_with_known_baseline(baseline)
        return
    
    # Comparar diretamente
    print("✅ Comparando Baseline vs Otimizado...")
    print()
    
    compare_results(baseline, optimized)


def compare_with_known_baseline(baseline):
    """Compara com baseline conhecido das análises anteriores"""
    print()
    print("📊 Comparação com Baseline Conhecido")
    print("-"*80)
    
    # Dados conhecidos do baseline anterior
    known_baseline = {
        'fps': 0.08,
        'frame_time_avg': 11775.72,
        'build_avg': 380.68,
        'raster_avg': 7712.48,
        'frames_janky': 5.65,
    }
    
    # Dados otimizados (estimados)
    estimated = {
        'fps': 45.0,
        'frame_time_avg': 400.0,
        'build_avg': 120.0,
        'raster_avg': 200.0,
        'frames_janky': 0.8,
    }
    
    metrics = [
        ('FPS Médio', 'fps', 'fps'),
        ('Frame Time Médio', 'frame_time_avg', 'ms'),
        ('Build Time Médio', 'build_avg', 'ms'),
        ('Raster Time Médio', 'raster_avg', 'ms'),
        ('Frames Janky', 'frames_janky', '%'),
    ]
    
    print(f"{'Métrica':<30} {'Baseline':<15} {'Otimizado':<15} {'Melhoria':<15} {'Status':<10}")
    print("-"*80)
    
    for name, key, unit in metrics:
        before = known_baseline.get(key)
        after = estimated.get(key)
        
        if before is None or after is None:
            continue
        
        # Para FPS, calcular multiplicador (não %)
        if key == 'fps':
            if before == 0:
                improvement_str = "MUITO ALTO (>50,000%)"
            else:
                improvement = ((after - before) / before) * 100
                improvement_str = f"{improvement:.0f}%"
            status = "✅" if after >= 30 else "🟡" if after >= 20 else "❌"
        else:
            improvement = calculate_improvement(before, after)
            improvement_str = f"{improvement:.1f}%"
            status = "✅" if improvement and improvement > 50 else "🟡" if improvement and improvement > 20 else "❌"
        
        print(f"{name:<30} {before:<15.2f} {after:<15.2f} {improvement_str:<15} {status:<10}")
    
    print()
    print("⚠️  NOTA: Dados otimizados são estimados.")
    print("Execute o profiling real para obter resultados concretos!")
    print()


def compare_results(baseline, optimized):
    """Compara resultados de dois snapshots"""
    baseline_summary = baseline.get('summary', {})
    optimized_summary = optimized.get('summary', {})
    
    if not baseline_summary or not optimized_summary:
        print("❌ Dados incompletos nos snapshots")
        return
    
    metrics = [
        ('FPS', 'fps', 'mean'),
        ('Duração Média', 'duration_ms', 'mean'),
        ('Total de Frames', 'total_frames', 'mean'),
    ]
    
    print(f"{'Métrica':<30} {'Baseline':<20} {'Otimizado':<20} {'Melhoria':<15}")
    print("-"*85)
    
    for name, category, subkey in metrics:
        category_data = baseline_summary.get(category, {})
        optimized_data = optimized_summary.get(category, {})
        
        before = category_data.get(subkey, 0) if category_data else 0
        after = optimized_data.get(subkey, 0) if optimized_data else 0
        
        improvement = calculate_improvement(before, after)
        
        if improvement is None:
            improvement_str = "N/A"
        elif improvement == float('inf'):
            improvement_str = "∞"
        else:
            improvement_str = f"{improvement:.1f}%"
        
        print(f"{name:<30} {before:<20.2f} {after:<20.2f} {improvement_str:<15}")
    
    print()


if __name__ == '__main__':
    main()

