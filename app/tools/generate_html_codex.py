#!/usr/bin/env python3
import json, os, glob, sys

def generate_codex():
    print("========================================")
    print("[CONTENT TOOL] Authoritative Hierarchical HTML Codex Generator")
    print("========================================\n")
    
    base_dir = "./data/content/base_bundle" if os.path.exists("./data/content/base_bundle") else "./app/data/content/base_bundle"
    json_files = glob.glob(f"{base_dir}/**/*.json", recursive=True)
    if not json_files:
        json_files = glob.glob("./app/data/**/*.json", recursive=True)
        
    print(f"Crawling {len(json_files)} JSON content files across repository...")
    
    tree = {} # tree[universe][world][type/scenario] = [items]
    total_items = 0
    
    for filepath in sorted(json_files):
        try:
            with open(filepath, 'r', encoding='utf-8') as f:
                content = json.load(f)
                items = content if isinstance(content, list) else [content]
                for item in items:
                    if isinstance(item, dict) and "id" in item and "type" in item:
                        u = item.get("universe", "general")
                        w = item.get("world", "default")
                        t = item.get("type", "rapid_classification")
                        
                        pres = item.get("presentation", {})
                        s_group = pres.get("title", t)
                        if "Knowledge Spike" in s_group or "Q" in s_group or s_group == t:
                            s_group = t.capitalize().replace("_", " ") + " Protocol"
                            
                        if u not in tree: tree[u] = {}
                        if w not in tree[u]: tree[u][w] = {}
                        if s_group not in tree[u][w]: tree[u][w][s_group] = []
                        
                        tree[u][w][s_group].append(item)
                        total_items += 1
        except Exception as e:
            pass
            
    print(f"Aggregated {total_items} items across {len(tree)} Universes.")
    
    universe_meta = {
        "history": {"title": "History", "color": "#E6B800", "desc": "Civilizations, dynastic timelines, cultural evolution, and human decision making."},
        "science_lab": {"title": "Science Lab", "color": "#00D4FF", "desc": "Empirical deduction, scientific methodology, and probabilistic estimation."},
        "tech_ops": {"title": "Tech Ops", "color": "#00FF66", "desc": "Cybernetic protocols, algorithmic efficiency, hardware, and matrix parse."},
        "life_sciences": {"title": "Life Sciences", "color": "#2ECC71", "desc": "Cellular mechanics, medical equilibria, nature, and biological scaling."},
        "society_mind": {"title": "Society & Mind", "color": "#AF7AC5", "desc": "Behavioral dynamics, economics, psychology, law, and societal evolution."},
        "creative_arts": {"title": "Creative Arts", "color": "#FF2288", "desc": "Divergent thinking, architectural geometry, compositional harmony, and design."},
        "frontier": {"title": "Frontier", "color": "#9B59B6", "desc": "Deep space navigation, survival mechanics, high-stakes trade-offs, and exploration."}
    }
    
    html_path = "./UNIVERSE_CONTENT_CODEX.html" if os.path.exists("./project.godot") else "./app/UNIVERSE_CONTENT_CODEX.html"
    
    html_parts = []
    html_parts.append("""<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>2 Second Witness — Master Content Codex</title>
<style>
  :root { --bg: #0B1320; --panel: #0F192A; --card: #152238; --border: #223348; --text: #E2E8F0; --muted: #94A3B8; --cyan: #00D4FF; --gold: #E6B800; }
  * { box-sizing: border-box; margin: 0; padding: 0; font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, Helvetica, Arial, sans-serif; }
  body { background-color: var(--bg); color: var(--text); padding: 30px; line-height: 1.6; }
  header { max-width: 1200px; margin: 0 auto 30px; border-bottom: 2px solid var(--cyan); padding-bottom: 20px; }
  h1 { font-size: 28px; color: var(--cyan); letter-spacing: 1px; margin-bottom: 8px; display: flex; align-items: center; gap: 10px; }
  .subtitle { color: var(--muted); font-size: 15px; }
  .stats-grid { display: grid; grid-template-columns: repeat(4, 1fr); gap: 15px; max-width: 1200px; margin: 0 auto 30px; }
  .stat-card { background: var(--panel); border: 1px solid var(--border); border-radius: 8px; padding: 16px; text-align: center; }
  .stat-val { font-size: 26px; font-weight: bold; color: var(--gold); }
  .stat-lbl { font-size: 13px; color: var(--muted); text-transform: uppercase; letter-spacing: 0.5px; }
  
  .container { max-width: 1200px; margin: 0 auto; }
  
  details { background: var(--panel); border: 1px solid var(--border); border-radius: 8px; margin-bottom: 16px; overflow: hidden; }
  summary { padding: 18px 24px; font-size: 18px; font-weight: 600; cursor: pointer; list-style: none; display: flex; justify-content: space-between; align-items: center; background: rgba(255,255,255,0.02); transition: background 0.2s; }
  summary::-webkit-details-marker { display: none; }
  summary:hover { background: rgba(255,255,255,0.05); }
  details[open] > summary { border-bottom: 1px solid var(--border); }
  
  .uni-title { display: flex; align-items: center; gap: 12px; }
  .uni-badge { font-size: 12px; padding: 4px 10px; border-radius: 20px; font-weight: bold; text-transform: uppercase; }
  
  .world-details { margin: 16px 20px; background: var(--card); border: 1px solid var(--border); }
  .world-summary { font-size: 16px; color: var(--gold); padding: 14px 20px; }
  
  .scenario-details { margin: 12px 16px; background: rgba(0,0,0,0.25); border: 1px dashed var(--border); }
  .scenario-summary { font-size: 15px; color: #8595FF; padding: 12px 16px; }
  
  .table-wrap { padding: 16px; overflow-x: auto; }
  table { width: 100%; border-collapse: collapse; font-size: 14px; }
  th, td { padding: 10px 14px; text-align: left; border-bottom: 1px solid rgba(255,255,255,0.05); }
  th { color: var(--muted); font-weight: 600; text-transform: uppercase; font-size: 12px; }
  tr:hover { background: rgba(255,255,255,0.03); }
  .q-prompt { color: #FFF; font-weight: 500; }
  .q-ans { color: #2ECC71; font-weight: bold; }
  .q-wrong { color: #E74C3C; font-size: 13px; }
  
  .search-box { width: 100%; max-width: 1200px; margin: 0 auto 25px; display: block; }
  input[type="text"] { width: 100%; padding: 14px 20px; font-size: 16px; background: var(--panel); border: 1px solid var(--border); border-radius: 8px; color: var(--text); outline: none; transition: border-color 0.2s; }
  input[type="text"]:focus { border-color: var(--cyan); }
</style>
<script>
  function filterCodex() {
    let q = document.getElementById('searchInput').value.toLowerCase();
    let rows = document.querySelectorAll('tbody tr');
    rows.forEach(r => {
      let txt = r.innerText.toLowerCase();
      r.style.display = txt.includes(q) ? '' : 'none';
    });
  }
</script>
</head>
<body>

<header>
  <h1><span>●</span> 2 SECOND WITNESS — MASTER CONTENT CODEX</h1>
  <p class="subtitle">Authoritative 4-Tier Interactive Directory: Universes ▶ Worlds ▶ Scenarios ▶ Rapid-Fire Questions</p>
</header>
""")

    html_parts.append(f"""
<div class="stats-grid">
  <div class="stat-card"><div class="stat-val">7</div><div class="stat-lbl">Universes</div></div>
  <div class="stat-card"><div class="stat-val">{len(tree)}</div><div class="stat-lbl">Active Domains</div></div>
  <div class="stat-card"><div class="stat-val">62</div><div class="stat-lbl">World Categories</div></div>
  <div class="stat-card"><div class="stat-val">{total_items}</div><div class="stat-lbl">Rapid-Fire Trials</div></div>
</div>

<div class="search-box">
  <input type="text" id="searchInput" onkeyup="filterCodex()" placeholder="🔍 Search any question, answer, world, or prompt across all {total_items} items...">
</div>

<div class="container">
""")

    for u_id in sorted(tree.keys()):
        meta = universe_meta.get(u_id.lower(), {"title": u_id.upper(), "color": "#00D4FF", "desc": "Domain observation content."})
        u_color = meta["color"]
        u_worlds = tree[u_id]
        u_item_count = sum(len(items) for w in u_worlds.values() for items in w.values())
        
        html_parts.append(f"""
<details open style="border-left: 5px solid {u_color};">
  <summary>
    <div class="uni-title">
      <span style="color:{u_color}; font-size:22px;">●</span>
      <span>UNIVERSE: {meta['title'].upper()}</span>
      <span class="uni-badge" style="background:{u_color}22; color:{u_color}; border: 1px solid {u_color}66;">{len(u_worlds)} Worlds</span>
    </div>
    <span style="color:var(--muted); font-size:14px;">{u_item_count} Total Trials</span>
  </summary>
  <p style="padding: 10px 24px; color:var(--muted); font-size:14px; border-bottom:1px solid var(--border);">{meta['desc']}</p>
""")

        for w_id in sorted(u_worlds.keys()):
            w_scenarios = u_worlds[w_id]
            w_item_count = sum(len(items) for items in w_scenarios.values())
            w_name = w_id.capitalize().replace("_", " ")
            
            html_parts.append(f"""
  <details class="world-details">
    <summary class="world-summary">
      <span>📁 WORLD CATEGORY: {w_name}</span>
      <span style="color:var(--muted); font-size:13px;">{len(w_scenarios)} Scenario Protocols | {w_item_count} Items</span>
    </summary>
""")
            
            for s_name in sorted(w_scenarios.keys()):
                s_items = w_scenarios[s_name]
                html_parts.append(f"""
    <details class="scenario-details">
      <summary class="scenario-summary">
        <span>🕹️ SCENARIO SUBCATEGORY: {s_name}</span>
        <span style="color:var(--cyan); font-size:13px;">{len(s_items)} Rapid-Fire Questions</span>
      </summary>
      <div class="table-wrap">
        <table>
          <thead>
            <tr>
              <th style="width:10%;">ID / Tier</th>
              <th style="width:15%;">Protocol Type</th>
              <th style="width:40%;">Stimulus Prompt / Question</th>
              <th style="width:15%;">Correct Verification</th>
              <th style="width:20%;">Distractor Noise (Wrong)</th>
            </tr>
          </thead>
          <tbody>
""")
                for item in s_items:
                    rules = item.get("rules", {})
                    pres = item.get("presentation", {})
                    prompt = rules.get("legacy_prompt", rules.get("prompt", ""))
                    ans = rules.get("correct_answer", "")
                    w_ans = rules.get("wrong_answers", [])
                    w_str = ", ".join([str(x) for x in w_ans]) if isinstance(w_ans, list) else str(w_ans)
                    tier = pres.get("difficulty_tier", item.get("difficulty", 1))
                    
                    html_parts.append(f"""
            <tr>
              <td><span style="font-family:monospace; color:var(--muted);">{item.get('id','')}</span><br><span style="color:var(--gold); font-size:12px;">Tier {tier}</span></td>
              <td><span style="background:#223348; padding:3px 8px; border-radius:4px; font-size:12px; color:#8595FF;">{item.get('type','')}</span></td>
              <td class="q-prompt">{prompt}</td>
              <td class="q-ans">✓ {ans}</td>
              <td class="q-wrong">✗ {w_str}</td>
            </tr>
""")
                html_parts.append("""
          </tbody>
        </table>
      </div>
    </details>
""")
            html_parts.append('  </details>')
        html_parts.append('</details>')
        
    html_parts.append("""
</div>
</body>
</html>
""")
    
    with open(html_path, 'w', encoding='utf-8') as f:
        f.write("".join(html_parts))
    print(f"✓ Generated Master Interactive HTML Codex at: {html_path} ({os.path.getsize(html_path) / 1024:.1f} KB)")

if __name__ == "__main__":
    generate_codex()
