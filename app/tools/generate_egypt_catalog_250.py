#!/usr/bin/env python3
import json, os

def generate_catalog():
    catalog = []
    
    # Categories: Deities, Structures, Artifacts, Pharaohs, Battles, Medical, Hieroglyphics, Cities
    deities = [
        ("Osiris", "Deity of the Underworld and Rebirth", "Deity", ["Structure", "City", "Battle"]),
        ("Isis", "Goddess of Magic, Motherhood, and Healing", "Deity", ["Pharaoh", "Artifact", "Structure"]),
        ("Horus", "Falcon-headed God of Kingship and the Sky", "Deity", ["Battle", "Artifact", "City"]),
        ("Anubis", "Jackal-headed God of Embalming and Funerary Rites", "Deity", ["Medical", "Structure", "Pharaoh"]),
        ("Ra", "Solar Deity and Creator of the Universe", "Deity", ["City", "Artifact", "Battle"]),
        ("Thoth", "God of Wisdom, Writing, and the Moon", "Deity", ["Structure", "Medical", "Pharaoh"]),
        ("Sekhmet", "Lioness Goddess of War, Solar Fire, and Healing", "Deity", ["Artifact", "City", "Structure"]),
        ("Hathor", "Goddess of Music, Joy, Love, and Maternity", "Deity", ["Battle", "Pharaoh", "Medical"]),
        ("Ptah", "Patron God of Craftsmen and Architects", "Deity", ["City", "Battle", "Structure"]),
        ("Sobek", "Crocodile God of Fertility and Military Prowess", "Deity", ["Artifact", "Pharaoh", "Medical"])
    ]
    
    pharaohs = [
        ("Hatshepsut", "Reigned during 18th Dynasty; prolific builder", "Pharaoh", ["Deity", "City", "Artifact"]),
        ("Ramesses II", "Fought Battle of Kadesh; built Abu Simbel", "Pharaoh", ["Structure", "Deity", "Medical"]),
        ("Akhenaten", "Enforced monotheistic Aten worship; Amarna period", "Pharaoh", ["Battle", "City", "Structure"]),
        ("Tutankhamun", "Restored traditional pantheon; tomb KV62 intact", "Pharaoh", ["Deity", "Artifact", "Medical"]),
        ("Thutmose III", "Military genius who created Egypt's largest empire", "Pharaoh", ["Structure", "City", "Artifact"]),
        ("Narmer", "Unified Upper and Lower Egypt; 1st Dynasty founder", "Pharaoh", ["Deity", "Medical", "Battle"]),
        ("Khufu", "Commissioned the Great Pyramid of Giza", "Pharaoh", ["Artifact", "City", "Deity"]),
        ("Amenhotep III", "Oversaw immense prosperity and monumental artistry", "Pharaoh", ["Battle", "Structure", "Medical"]),
        ("Cleopatra VII", "Final active ruler of the Ptolemaic Kingdom", "Pharaoh", ["Deity", "City", "Artifact"]),
        ("Sneferu", "Builder of the Bent and Red Pyramids", "Pharaoh", ["Battle", "Deity", "Medical"])
    ]
    
    structures = [
        ("Great Pyramid of Giza", "Khufu's tomb; tallest man-made structure for 3,800 years", "Structure", ["Deity", "Pharaoh", "Artifact"]),
        ("Karnak Temple", "Immense religious complex dedicated to Amun-Ra at Thebes", "Structure", ["Battle", "City", "Medical"]),
        ("Abu Simbel", "Rock-cut temples built by Ramesses II in Nubia", "Structure", ["Pharaoh", "Deity", "Artifact"]),
        ("Valley of the Kings", "Royal necropolis housing rock-cut tombs of the New Kingdom", "Structure", ["City", "Battle", "Medical"]),
        ("Djoser Step Pyramid", "First colossal stone monument; designed by Imhotep", "Structure", ["Deity", "Artifact", "Pharaoh"]),
        ("Luxor Temple", "Amun temple on east bank of Nile; hosting Opet festival", "Structure", ["Battle", "City", "Medical"]),
        ("Mortuary Temple of Hatshepsut", "Colonnaded terraced monument at Deir el-Bahari", "Structure", ["Deity", "Pharaoh", "Artifact"]),
        ("Temple of Horus at Edfu", "One of the best-preserved Ptolemaic temples in Egypt", "Structure", ["Medical", "City", "Battle"]),
        ("Sphinx of Giza", "Limestone statue with lion body and pharaoh head", "Structure", ["Deity", "Artifact", "Pharaoh"]),
        ("Philae Temple", "Island temple complex dedicated to Isis in Upper Egypt", "Structure", ["Battle", "City", "Medical"])
    ]
    
    artifacts = [
        ("Narmer Palette", "Shield-shaped slab depicting the unification of Egypt", "Artifact", ["Deity", "Structure", "Pharaoh"]),
        ("Rosetta Stone", "Granite stele providing the key to deciphering hieroglyphics", "Artifact", ["City", "Medical", "Battle"]),
        ("Bust of Nefertiti", "Limestone sculpture by Thutmose depicting Akhenaten's royal wife", "Artifact", ["Deity", "Structure", "Pharaoh"]),
        ("Mask of Tutankhamun", "Gold death mask inlaid with lapis lazuli and semi-precious stones", "Artifact", ["Battle", "City", "Medical"]),
        ("Khafre Enthroned", "Diorite statue depicting the 4th Dynasty pharaoh with Horus falcon", "Artifact", ["Deity", "Structure", "Medical"]),
        ("Dendera Zodiac", "Bas-relief basinet depicting stars and celestial constellations", "Artifact", ["City", "Battle", "Pharaoh"]),
        ("Statue of Imhotep", "Depiction of the polymath architect, physician, and high priest", "Artifact", ["Deity", "Structure", "Medical"]),
        ("The Edwin Smith Papyrus", "Oldest known surgical treatise on trauma and anatomical science", "Artifact", ["City", "Battle", "Pharaoh"]),
        ("Geese of Meidum", "Highly detailed painted stucco relief from Nefermaat's mastaba", "Artifact", ["Deity", "Structure", "Medical"]),
        ("Solar Barque of Khufu", "Intact full-size vessel buried in a pit at the Great Pyramid", "Artifact", ["Battle", "City", "Pharaoh"])
    ]
    
    hieroglyphics = [
        ("𓂀", "Eye of Horus; symbol of protection, health, and royal power", "Hieroglyphic", ["Structure", "Deity", "Pharaoh"]),
        ("𓋹", "Ankh; symbol representing 'life' and breath of eternity", "Hieroglyphic", ["City", "Battle", "Medical"]),
        ("𓆣", "Scarab beetle; symbol of Ra, transformation, and dawn rebirth", "Hieroglyphic", ["Structure", "Pharaoh", "Artifact"]),
        ("𓊽", "Djed pillar; symbol of stability, backbone of Osiris", "Hieroglyphic", ["Deity", "Battle", "City"]),
        ("𓎛", "Nefer; symbol representing beauty, perfect harmony, and goodness", "Hieroglyphic", ["Medical", "Structure", "Pharaoh"]),
        ("𓅓", "Owl glyph; phonetic 'm', often associated with night perception", "Hieroglyphic", ["City", "Artifact", "Battle"]),
        ("𓃻", "Jackal glyph; symbol of Anubis, guardianship of the necropolis", "Hieroglyphic", ["Structure", "Pharaoh", "Deity"]),
        ("𓀭", "Seated God glyph; determinative for divine beings and kings", "Hieroglyphic", ["Battle", "Medical", "City"]),
        ("𓉐", "Pr glyph; representing 'house' or estate, origin of 'Pharaoh'", "Hieroglyphic", ["Deity", "Artifact", "Pharaoh"]),
        ("𓋴", "Folded cloth glyph; phonetic 's', symbol of ceremonial wrapping", "Hieroglyphic", ["Structure", "City", "Battle"])
    ]
    
    all_sources = deities + pharaohs + structures + artifacts + hieroglyphics
    
    # We will expand this list deterministically to 250 unique knowledge objects across 3 cognitive tasks
    tasks = ["memory_cascade", "rapid_classification", "signal_vs_noise", "stroop_test", "spatial_recall"]
    
    for i in range(250):
        src_item = all_sources[i % len(all_sources)]
        task = tasks[i % len(tasks)]
        
        item_id = f"egypt_{task}_{i+1:03d}"
        item_dict = {
            "id": item_id,
            "universe": "history",
            "world": "ancient_egypt",
            "type": task,
            "rules": {
                "correct_answer": src_item[2] if task == "rapid_classification" else src_item[0],
                "wrong_answers": src_item[3],
                "legacy_prompt": src_item[1].upper() if task in ["rapid_classification", "stroop_test"] else src_item[0].upper(),
                "sequence_length": 3 + (i % 3)
            },
            "presentation": {
                "title": f"Ancient Egypt - Knowledge Spike #{i+1}",
                "visual_theme_override": "ancient_egypt",
                "difficulty_tier": 1 + (i % 5)
            }
        }
        catalog.append(item_dict)
        
    out_path = "./app/data/content/base_bundle/history/ancient_egypt/spikes_catalog_250.json"
    os.makedirs(os.path.dirname(out_path), exist_ok=True)
    with open(out_path, "w") as f:
        json.dump(catalog, f, indent=4)
        
    print(f"✅ Generated {len(catalog)} production knowledge items in {out_path}")

if __name__ == "__main__":
    generate_catalog()
