#!/usr/bin/env python3
from __future__ import annotations
import json,re
from pathlib import Path
ROOT=Path(__file__).resolve().parents[3];APP=ROOT/'app';SRC=APP/'src';errors=[]
manifest=json.loads((SRC/'gameplay/families/manifest.json').read_text());entries=manifest['families'];visible=[e['id'] for e in entries if e.get('content_role')=='production']
expected=['scene_investigation','flash_words','spot_the_difference','object_recall','pattern_recall']
if visible!=expected:errors.append(f'visible family order mismatch: {visible}')
interaction_dir=SRC/'gameplay/interactions';interaction_text='\n'.join(p.read_text() for p in interaction_dir.rglob('*.gd'))
for family_id in expected:
 if family_id in interaction_text:errors.append(f'interaction system contains family id: {family_id}')
registry=(interaction_dir/'InteractionAdapterRegistry.gd').read_text();base=(interaction_dir/'InteractionAdapter.gd').read_text()
for method in ('register_adapter','create_adapter','has_adapter','get_adapter_ids'):
 if not re.search(rf'^func {method}\(',registry,re.M):errors.append(f'Interaction registry missing {method}')
if 'signal interaction_submitted' not in base:errors.append('InteractionAdapter payload signal missing')
adapters=json.loads((interaction_dir/'manifest.json').read_text())['adapters'];adapter_ids={a['id'] for a in adapters};required={'single_choice','multiple_choice','spatial_tap','region_selection','ordering','sequence_input'}
if adapter_ids!=required:errors.append(f'adapter modes mismatch: {adapter_ids}')
if 'drag_drop' not in json.loads((interaction_dir/'manifest.json').read_text()).get('future_modes',[]):errors.append('drag_drop is not future-ready')
contracts=(SRC/'gameplay/contracts/InteractionProfile.gd');
if not contracts.exists():errors.append('InteractionProfile contract missing')
presentation=(SRC/'gameplay/contracts/PresentationProfile.gd').read_text();module=(SRC/'gameplay/runtime/ChallengeFamilyModule.gd').read_text();session=(SRC/'gameplay/runtime/ChallengeSessionService.gd').read_text()
for needle,label in [('interaction_profile_id','PresentationProfile declaration'),('get_interaction_profile','family module API'),('interaction_profile','session routing payload')]:
 if needle not in (presentation+'\n'+module+'\n'+session):errors.append(f'missing {label}')
memory=(SRC/'ui/screens/MemoryQuestionScreen.gd').read_text()
if 'InteractionAdapterRegistry.create_adapter' not in memory or '_on_interaction_submitted' not in memory:errors.append('Recall route is not a generic interaction host')
for family_id,folder,count,adapter in [('spot_the_difference','spot_the_difference',4,'spatial_tap'),('object_recall','object_recall',4,'multiple_choice'),('pattern_recall','pattern_recall',3,'sequence_input')]:
 d=SRC/'gameplay/families'/folder
 required_files=['Family.gd','Generator.gd','Validator.gd','DifficultyPolicy.gd','ExposurePolicy.gd','ScoringPolicy.gd','View.gd']
 for suffix in required_files:
  if not any(p.name.endswith(suffix) for p in d.glob('*.gd')):errors.append(f'{family_id} missing {suffix}')
 text='\n'.join(p.read_text() for p in d.rglob('*.gd'))
 if not re.search(rf'"adapter_id"\s*:\s*"{adapter}"', text):errors.append(f'{family_id} does not own {adapter} profile')
 family_file=next(d.glob('*Family.gd')).read_text();template_count=len(set(re.findall(r'"id"\s*:\s*"([a-z0-9_]+_v1)"', family_file)))
 if template_count<count:errors.append(f'{family_id} declares fewer than {count} templates')
 if not list((d/'tutorial').glob('*.tscn')):errors.append(f'{family_id} tutorial missing')
for shared in [SRC/'gameplay/runtime',SRC/'gameplay/interactions',SRC/'ui/screens/MemoryQuestionScreen.gd']:
 paths=[shared] if shared.is_file() else list(shared.rglob('*.gd'))
 text='\n'.join(p.read_text() for p in paths)
 for family_id in ('spot_the_difference','object_recall','pattern_recall'):
  if family_id in text:errors.append(f'shared code contains Phase 5 family id: {family_id} in {shared.relative_to(APP)}')
project=(APP/'project.godot').read_text();boot=(SRC/'core/app/AppBoot.gd').read_text()
if 'InteractionAdapterRegistry="*res://' not in project:errors.append('interaction registry autoload missing')
if 'InteractionAdapterRegistry.initialize()' not in boot:errors.append('interaction registry boot initialization missing')
if errors:
 for e in errors:print('PHASE5 ARCHITECTURE FAIL:',e)
 raise SystemExit(1)
print('PHASE5_ARCHITECTURE_PASS')
print(f'production_families={len(visible)} adapters={len(adapter_ids)} new_templates=11')
