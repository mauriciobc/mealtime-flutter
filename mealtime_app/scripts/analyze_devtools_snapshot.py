#!/usr/bin/env python3
"""
Script para analisar snapshots exportados do Flutter DevTools
Uso: python3 scripts/analyze_devtools_snapshot.py [baseline|optimized]
"""

import json
import sys
import os
from pathlib import Path
from collections import defaultdict
from typing import Dict, List, Any, Tuple
import statistics


class DevToolsAnalyzer:
    """Analisa snapshots do DevTools e extrai métricas de performance"""
    
    def __init__(self, snapshot_dir: str):
        self.snapshot_dir = Path(snapshot_dir)
        self.snapshots = []
        self.metrics = defaultdict(dict)
        
    def load_snapshots(self) -> List[Dict[str, Any]]:
        """Carrega todos os snapshots JSON do diretório"""
        if not self.snapshot_dir.exists():
            print(f"❌ Diretório não encontrado: {self.snapshot_dir}")
            return []
            
        snapshot_files = list(self.snapshot_dir.glob("*.json"))
        if not snapshot_files:
            print(f"⚠️  Nenhum snapshot encontrado em {self.snapshot_dir}")
            return []
            
        print(f"📊 Carregando {len(snapshot_files)} snapshots...")
        
        for snapshot_file in snapshot_files:
            try:
                with open(snapshot_file, 'r', encoding='utf-8') as f:
                    data = json.load(f)
                    data['_filename'] = snapshot_file.name
                    self.snapshots.append(data)
                    print(f"   ✓ {snapshot_file.name}")
            except json.JSONDecodeError as e:
                print(f"   ✗ {snapshot_file.name}: JSON inválido - {e}")
            except Exception as e:
                print(f"   ✗ {snapshot_file.name}: Erro - {e}")
                
        return self.snapshots
    
    def extract_frame_data(self, snapshot: Dict[str, Any]) -> List[Dict[str, Any]]:
        """Extrai dados de frames do snapshot"""
        # Formato do DevTools pode variar, tentar diferentes caminhos
        frames = []
        
        # Tentar diferentes estruturas possíveis
        possible_paths = [
            ['timelineEvents'],
            ['events'],
            ['traceEvents'],
            ['data', 'events'],
        ]
        
        for path in possible_paths:
            data = snapshot
            try:
                for key in path:
                    data = data[key]
                frames = data
                break
            except (KeyError, TypeError):
                continue
                
        if not frames:
            return []
            
        # Filtrar apenas eventos de frame
        frame_events = [
            event for event in frames 
            if isinstance(event, dict) and event.get('name') in ['Frame', 'Vsync']
        ]
        
        return frame_events
    
    def calculate_fps(self, frames: List[Dict[str, Any]], duration_ms: float) -> float:
        """Calcula FPS baseado no número de frames e duração"""
        if not frames or duration_ms <= 0:
            return 0.0
            
        num_frames = len(frames)
        fps = (num_frames / duration_ms) * 1000
        return fps
    
    def analyze_snapshot(self, snapshot: Dict[str, Any]) -> Dict[str, Any]:
        """Analisa um snapshot e retorna métricas"""
        filename = snapshot.get('_filename', 'unknown')
        
        # Extrair frames
        frames = self.extract_frame_data(snapshot)
        
        # Calcular métricas básicas
        metrics = {
            'filename': filename,
            'total_frames': len(frames),
            'duration_ms': 0.0,
            'fps': 0.0,
        }
        
        if frames:
            # Tentar calcular duração
            timestamps = []
            for frame in frames:
                if 'ts' in frame:
                    timestamps.append(frame['ts'])
                elif 'timestamp' in frame:
                    timestamps.append(frame['timestamp'])
                    
            if len(timestamps) >= 2:
                duration_us = timestamps[-1] - timestamps[0]
                metrics['duration_ms'] = duration_us / 1000
                metrics['fps'] = self.calculate_fps(frames, metrics['duration_ms'])
        
        return metrics
    
    def analyze_all(self) -> Dict[str, Any]:
        """Analisa todos os snapshots"""
        print("\n🔍 Analisando snapshots...")
        
        all_metrics = []
        for snapshot in self.snapshots:
            metrics = self.analyze_snapshot(snapshot)
            all_metrics.append(metrics)
            print(f"   ✓ {metrics['filename']}: {metrics['total_frames']} frames, {metrics['fps']:.2f} FPS")
        
        return {
            'scenarios': all_metrics,
            'summary': self._calculate_summary(all_metrics)
        }
    
    def _calculate_summary(self, metrics: List[Dict[str, Any]]) -> Dict[str, Any]:
        """Calcula resumo estatístico das métricas"""
        if not metrics:
            return {}
            
        fps_values = [m['fps'] for m in metrics if m['fps'] > 0]
        duration_values = [m['duration_ms'] for m in metrics if m['duration_ms'] > 0]
        frames_values = [m['total_frames'] for m in metrics]
        
        summary = {
            'total_scenarios': len(metrics),
            'fps': {
                'mean': statistics.mean(fps_values) if fps_values else 0,
                'median': statistics.median(fps_values) if fps_values else 0,
                'min': min(fps_values) if fps_values else 0,
                'max': max(fps_values) if fps_values else 0,
            },
            'duration_ms': {
                'mean': statistics.mean(duration_values) if duration_values else 0,
                'median': statistics.median(duration_values) if duration_values else 0,
                'min': min(duration_values) if duration_values else 0,
                'max': max(duration_values) if duration_values else 0,
            },
            'total_frames': {
                'mean': statistics.mean(frames_values) if frames_values else 0,
                'median': statistics.median(frames_values) if frames_values else 0,
                'min': min(frames_values) if frames_values else 0,
                'max': max(frames_values) if frames_values else 0,
            },
        }
        
        return summary
    
    def print_report(self, analysis: Dict[str, Any]):
        """Imprime relatório formatado"""
        print("\n" + "="*80)
        print("📊 RELATÓRIO DE ANÁLISE DE PERFORMANCE")
        print("="*80)
        
        summary = analysis.get('summary', {})
        
        print("\n📈 RESUMO GERAL:")
        print(f"   Total de Cenários: {summary.get('total_scenarios', 0)}")
        
        fps = summary.get('fps', {})
        print(f"\n🎯 FPS:")
        print(f"   Média: {fps.get('mean', 0):.2f}")
        print(f"   Mediana: {fps.get('median', 0):.2f}")
        print(f"   Min: {fps.get('min', 0):.2f}")
        print(f"   Max: {fps.get('max', 0):.2f}")
        
        print("\n⏱️  DURAÇÃO:")
        duration = summary.get('duration_ms', {})
        print(f"   Média: {duration.get('mean', 0):.2f} ms")
        print(f"   Mediana: {duration.get('median', 0):.2f} ms")
        print(f"   Min: {duration.get('min', 0):.2f} ms")
        print(f"   Max: {duration.get('max', 0):.2f} ms")
        
        print("\n📊 POR CENÁRIO:")
        for scenario in analysis.get('scenarios', []):
            print(f"\n   {scenario['filename']}:")
            print(f"   • Frames: {scenario['total_frames']}")
            print(f"   • FPS: {scenario['fps']:.2f}")
            print(f"   • Duração: {scenario['duration_ms']:.2f} ms")
        
        print("\n" + "="*80)
    
    def export_results(self, analysis: Dict[str, Any], output_file: str):
        """Exporta resultados para JSON"""
        output_path = Path(output_file)
        with open(output_path, 'w', encoding='utf-8') as f:
            json.dump(analysis, f, indent=2, ensure_ascii=False)
        print(f"\n💾 Resultados exportados para: {output_path}")


def main():
    if len(sys.argv) < 2:
        print("❌ Uso: python3 scripts/analyze_devtools_snapshot.py [baseline|optimized]")
        sys.exit(1)
    
    mode = sys.argv[1]
    
    if mode not in ['baseline', 'optimized']:
        print("❌ Modo deve ser 'baseline' ou 'optimized'")
        sys.exit(1)
    
    # Configurar diretórios
    script_dir = Path(__file__).parent.parent
    snapshot_dir = script_dir / 'benchmarks' / mode
    output_dir = script_dir / 'benchmarks' / 'analysis'
    output_dir.mkdir(parents=True, exist_ok=True)
    
    # Criar analyzer e executar
    analyzer = DevToolsAnalyzer(str(snapshot_dir))
    analyzer.load_snapshots()
    
    if not analyzer.snapshots:
        print("\n⚠️  Nenhum snapshot para analisar. Execute o benchmark primeiro.")
        sys.exit(0)
    
    analysis = analyzer.analyze_all()
    analyzer.print_report(analysis)
    
    # Exportar resultados
    output_file = output_dir / f"{mode}_analysis.json"
    analyzer.export_results(analysis, str(output_file))
    
    print("\n✅ Análise concluída!")


if __name__ == '__main__':
    main()

