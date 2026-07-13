#!/usr/bin/env python3
from pathlib import Path
import json,re
ROOT=Path(__file__).resolve().parents[3];APP=ROOT/'app';errors=[]
configs={
'spot_the_difference':('SpotDifferenceFamily.gd',4,'spot_difference_preview.svg'),
'object_recall':('ObjectRecallFamily.gd',4,'object_recall_preview.svg'),
'pattern_recall':('PatternRecallFamily.gd',3,'pattern_recall_preview.svg')}
for family,(filename,count,preview) in configs.items():
 d=APP/'src/gameplay/families'/family;f=d/filename
 if not f.exists():errors.append(f'missing {f.relative_to(ROOT)}');continue
 text=f.read_text();ids=re.findall(r'"id"\s*:\s*"([a-z0-9_]+_v1)"',text)
 if len(set(ids))<count:errors.append(f'{family} template count {len(set(ids))} < {count}')
 for suffix in ('Generator','Validator','DifficultyPolicy','ExposurePolicy','ScoringPolicy','View'):
  if not list(d.glob(f'*{suffix}.gd')):errors.append(f'{family} missing {suffix}')
 if not list((d/'tutorial').glob('*.gd')) or not list((d/'tutorial').glob('*.tscn')):errors.append(f'{family} tutorial incomplete')
 asset=APP/'assets/gameplay'/preview
 if not asset.exists():errors.append(f'{family} preview missing')
 if not re.search(r'"content_role"\s*:\s*"production"', text) or not re.search(r'"player_visible"\s*:\s*true', text):errors.append(f'{family} not production-visible')
manifest=json.loads((APP/'src/gameplay/families/manifest.json').read_text())
for family in configs:
 matches=[e for e in manifest['families'] if e.get('id')==family and e.get('enabled')]
 if len(matches)!=1:errors.append(f'{family} manifest entry invalid')
interaction=json.loads((APP/'src/gameplay/interactions/manifest.json').read_text())
if len(interaction.get('adapters',[]))<6:errors.append('interaction adapter content incomplete')
if errors:
 for e in errors:print('PHASE5 CONTENT FAIL:',e)
 raise SystemExit(1)
print('PHASE5_CONTENT_PASS families=3 templates=11 adapters=6')
