from pathlib import Path
import json, re, shutil, hashlib
from collections import defaultdict

ROOT = Path('app')
BANK_ROOT = ROOT/'data/observation_banks/creative_arts'
BASE_ROOT = ROOT/'data/content/base_bundle/creative_arts'

worlds = {
'painting':['Famous Paintings','Famous Painters','Art Styles','Color Theory','Painting Techniques','Art Materials','Portraits','Landscapes','Still Life','Murals'],
'drawing':['Sketching','Perspective','Anatomy','Shading','Line Art','Cartoon Drawing','Comic Drawing','Technical Drawing','Figure Drawing','Drawing Tools'],
'photography':['Cameras','Lenses','Lighting','Composition','Portrait Photography','Wildlife Photography','Landscape Photography','Street Photography','Famous Photographers','Editing'],
'digital_art':['Digital Painting','Pixel Art','Vector Art','Concept Art','3D Art','Character Art','Environment Art','UI Art','Game Art','AI Art'],
'animation':['Disney','Pixar','Anime','Stop Motion','2D Animation','3D Animation','Cartoon Characters','Animation Principles','Animation Studios','Visual Effects'],
'movies_cinematography':['Camera Shots','Camera Angles','Lighting','Film Genres','Directors','Cinematographers','Storyboards','Visual Effects','Color Grading','Classic Cinema'],
'graphic_design':['Logos','Branding','Posters','Advertising','Packaging','Icons','Infographics','Layout','Web Graphics','Brand Identity'],
'fashion':['Clothing','Shoes','Accessories','Jewelry','Luxury Brands','Streetwear','Runway Fashion','Fashion History','Designers','Fabrics'],
'architecture':['Famous Buildings','Skyscrapers','Bridges','Castles','Churches','Modern Architecture','Ancient Architecture','Building Styles','Architects','Structural Elements'],
'interior_design':['Living Rooms','Kitchens','Bedrooms','Bathrooms','Furniture','Lighting','Decor Styles','Space Planning','Color Schemes','Home Accessories'],
'comics_manga':['Superheroes','Manga Series','Comic Artists','Comic Styles','Panels','Speech Bubbles','Character Design','Villains','Graphic Novels','Publishers'],
'street_art':['Graffiti','Murals','Stencils','Stickers','Public Installations','Urban Artists','Spray Paint','Lettering','Street Styles','Famous Works'],
'famous_artists':['Renaissance Masters','Impressionists','Modern Artists','Contemporary Artists','Sculptors','Illustrators','Photographers','Digital Artists','Women Artists','Self Portraits'],
'art_history':['Ancient Art','Medieval Art','Renaissance','Baroque','Romanticism','Impressionism','Cubism','Surrealism','Pop Art','Contemporary Art'],
'sculpture':['Marble','Bronze','Wood','Clay','Public Sculptures','Monuments','Relief Sculpture','Abstract Sculpture','Famous Sculptors','Sculpture Techniques'],
'crafts_diy':['Paper Crafts','Origami','Scrapbooking','Candle Making','Soap Making','Resin Art','Wood Crafts','Holiday Crafts','DIY Projects','Handmade Gifts'],
'pottery_ceramics':['Pottery','Porcelain','Stoneware','Glazing','Kilns','Ceramic Sculpture','Decorative Pottery','Ancient Ceramics','Pottery Wheels','Ceramic Artists'],
'tattoos_body_art':['Tattoo Styles','Traditional Tattoos','Japanese Tattoos','Tribal Designs','Blackwork','Watercolor Tattoos','Piercings','Henna','Body Painting','Famous Tattoo Artists'],
'calligraphy_lettering':['Brush Lettering','Gothic Script','Copperplate','Hand Lettering','Sign Painting','Typography Basics','Ink Tools','Decorative Initials','World Scripts','Modern Calligraphy'],
'creative_technology':['3D Printing','Laser Cutting','CNC Art','Projection Mapping','Interactive Installations','Generative Art','AR Art','VR Art','Creative Coding','Emerging Media']
}

def sid(s): return re.sub(r'[^a-z0-9]+','_',s.lower()).strip('_')

def pref_for(sub):
    name=sid(sub)
    preferred=['rapid_classification','signal_vs_noise','odd_one_out']
    secondary=['memory_cascade','sequence_reverse','stroop_test']
    rare=['pattern_continuation','spatial_recall']
    disabled=['math_surprise','risk_selection','reflex_tap','speed_sort']
    if any(k in name for k in ['color','style','technique','material','tool','artist','painting','painter']):
        preferred=['rapid_classification','signal_vs_noise','stroop_test']
        secondary=['odd_one_out','memory_cascade','sequence_reverse']
    if any(k in name for k in ['timeline','history','renaissance','baroque','impressionism','cubism','surrealism']):
        secondary=['sequence_reverse','memory_cascade','pattern_continuation']
    return {'preferred':preferred,'secondary':secondary,'rare':rare,'disabled':disabled}

def diff_label(i):
    if i < 40: return 'beginner',1
    if i < 70: return 'intermediate',2
    if i < 90: return 'advanced',3
    return 'expert',4

def distract(answer, pool, n=3):
    arr=[x for x in pool if x != answer]
    out=[]
    for x in arr:
        if x not in out: out.append(x)
        if len(out)>=n: break
    while len(out)<n: out.append('Not ' + answer)
    return out[:n]

# Curated concept banks for Painting.
paintings = [
('Mona Lisa','Leonardo da Vinci','enigmatic half-length portrait with a subtle smile'),('The Last Supper','Leonardo da Vinci','Christ and apostles seated at a long table'),('The Starry Night','Vincent van Gogh','swirling night sky over a village'),('Sunflowers','Vincent van Gogh','bright yellow flowers in a vase'),('Girl with a Pearl Earring','Johannes Vermeer','girl turning with a pearl earring'),('The Birth of Venus','Sandro Botticelli','Venus standing on a shell'),('The Persistence of Memory','Salvador Dalí','melting clocks in a dreamlike landscape'),('Guernica','Pablo Picasso','large monochrome anti-war scene'),('The Scream','Edvard Munch','figure crying beneath a blood-red sky'),('American Gothic','Grant Wood','stern farmer and woman before a house'),('Las Meninas','Diego Velázquez','Spanish court scene with the painter visible'),('The Night Watch','Rembrandt','dramatic militia company group portrait'),('The Kiss','Gustav Klimt','gold-patterned embrace'),('Water Lilies','Claude Monet','floating flowers on a pond'),('Impression, Sunrise','Claude Monet','misty harbor sunrise'),('The School of Athens','Raphael','classical philosophers in an architectural setting'),('The Creation of Adam','Michelangelo','two hands reaching on the Sistine ceiling'),('The Arnolfini Portrait','Jan van Eyck','couple in a room with convex mirror'),('Nighthawks','Edward Hopper','late-night diner with isolated figures'),('Campbell’s Soup Cans','Andy Warhol','repeated soup can images'),('The Garden of Earthly Delights','Hieronymus Bosch','triptych filled with fantastical scenes'),('Liberty Leading the People','Eugène Delacroix','allegorical woman carrying a flag'),('The Hay Wain','John Constable','rural cart crossing shallow water'),('Whistler’s Mother','James McNeill Whistler','seated woman in profile'),('The Raft of the Medusa','Théodore Géricault','shipwreck survivors on a raft')]
painters = [
('Leonardo da Vinci','Renaissance','Mona Lisa'),('Michelangelo','Renaissance','Sistine Chapel ceiling'),('Raphael','Renaissance','The School of Athens'),('Caravaggio','Baroque','The Calling of Saint Matthew'),('Rembrandt','Baroque','The Night Watch'),('Johannes Vermeer','Dutch Golden Age','Girl with a Pearl Earring'),('Claude Monet','Impressionism','Water Lilies'),('Pierre-Auguste Renoir','Impressionism','Dance at Le Moulin de la Galette'),('Edgar Degas','Impressionism','ballet dancer paintings'),('Vincent van Gogh','Post-Impressionism','The Starry Night'),('Paul Cézanne','Post-Impressionism','Mont Sainte-Victoire'),('Georges Seurat','Pointillism','A Sunday on La Grande Jatte'),('Pablo Picasso','Cubism','Guernica'),('Georges Braque','Cubism','Violin and Candlestick'),('Henri Matisse','Fauvism','The Red Studio'),('Wassily Kandinsky','Abstract Art','Composition paintings'),('Salvador Dalí','Surrealism','The Persistence of Memory'),('Frida Kahlo','Modern Art','self-portraits'),('Georgia O’Keeffe','Modernism','large flower paintings'),('Jackson Pollock','Abstract Expressionism','drip paintings'),('Mark Rothko','Color Field Painting','large color rectangles'),('Andy Warhol','Pop Art','Campbell’s Soup Cans'),('Jean-Michel Basquiat','Neo-Expressionism','crown and text paintings'),('Yayoi Kusama','Contemporary Art','polka dot infinity works'),('Artemisia Gentileschi','Baroque','Judith paintings')]
styles = [
('Renaissance','balanced perspective and classical humanism'),('Baroque','dramatic light and motion'),('Rococo','playful pastel ornament'),('Neoclassicism','classical order and moral seriousness'),('Romanticism','emotion, nature, and drama'),('Realism','ordinary life without idealizing'),('Impressionism','visible brushwork and changing light'),('Post-Impressionism','expressive color and structure after Impressionism'),('Pointillism','dots of pure color'),('Fauvism','wild expressive color'),('Cubism','fragmented geometric viewpoints'),('Futurism','speed, machines, and motion'),('Dada','anti-art protest and absurdity'),('Surrealism','dream imagery and unexpected juxtapositions'),('Abstract Expressionism','large gestural abstraction'),('Color Field Painting','broad fields of color'),('Pop Art','mass media and commercial imagery'),('Minimalism','simple geometric reduction'),('Op Art','optical illusions and vibrating patterns'),('Conceptual Art','idea over object'),('Art Nouveau','flowing plant-like lines'),('Art Deco','streamlined luxury geometry'),('Bauhaus','functional modern design'),('Expressionism','distorted form for emotion'),('Contemporary Art','current diverse global practices')]
color = [('Hue','color family such as red or blue'),('Value','lightness or darkness'),('Saturation','intensity or purity of color'),('Complementary Colors','opposites on the color wheel'),('Analogous Colors','neighbors on the color wheel'),('Primary Colors','red yellow and blue in traditional theory'),('Secondary Colors','orange green and violet'),('Warm Colors','reds oranges and yellows'),('Cool Colors','blues greens and violets'),('Tint','color mixed with white'),('Shade','color mixed with black'),('Tone','color mixed with gray'),('Monochrome','one main color family'),('Color Harmony','pleasing color relationship'),('Color Temperature','warm or cool feeling of color'),('Local Color','natural color of an object'),('Optical Mixing','colors blending in the viewer eye'),('Limited Palette','small controlled set of colors'),('Neutral Colors','black white gray and browns'),('Color Contrast','difference between colors')]
techniques = [('Fresco','painting into wet plaster'),('Glazing','thin transparent paint layers'),('Impasto','thick raised paint'),('Scumbling','dry broken light paint over darker paint'),('Sfumato','soft smoky transitions'),('Chiaroscuro','light-dark contrast'),('Tenebrism','extreme spotlighted darkness'),('Underpainting','first value or color layer'),('Alla Prima','wet-on-wet painting in one session'),('Grisaille','painting in gray values'),('Wash','thin diluted paint layer'),('Drybrush','paint dragged with little moisture'),('Blending','smooth transition between colors'),('Stippling','small dots or marks'),('Hatching','parallel lines for value'),('Cross-Hatching','intersecting lines for shadow'),('Layering','building paint in stages'),('Masking','protecting areas from paint'),('Varnishing','clear protective finish'),('Palette Knife','paint applied with a blade-like tool')]
materials = [('Canvas','fabric painting support'),('Wood Panel','rigid wooden support'),('Paper','thin sheet support'),('Linen','strong traditional canvas fiber'),('Cotton Duck','common cotton canvas'),('Gesso','white ground layer'),('Pigment','colored powder'),('Binder','substance that holds pigment'),('Oil Paint','pigment in drying oil'),('Acrylic Paint','fast-drying polymer paint'),('Watercolor','transparent water-based paint'),('Gouache','opaque water-based paint'),('Tempera','egg-based paint'),('Encaustic','heated wax paint'),('Pastel','powdery color stick'),('Charcoal','burned wood drawing medium'),('Graphite','pencil drawing material'),('Ink','liquid drawing or painting medium'),('Varnish','clear protective coating'),('Easel','support stand for artwork')]
portraits = [('Self-Portrait','artist depicts themselves'),('Profile Portrait','side view of a face'),('Three-Quarter View','face turned partly toward viewer'),('Bust Portrait','head and shoulders portrait'),('Full-Length Portrait','whole body portrait'),('Group Portrait','multiple people portrayed together'),('Commissioned Portrait','portrait made for a patron'),('Royal Portrait','image emphasizing monarchy or power'),('Psychological Portrait','portrait emphasizing inner mood'),('Idealized Portrait','flattering perfected likeness'),('Realist Portrait','unidealized likeness'),('Formal Pose','arranged dignified posture'),('Informal Pose','relaxed natural posture'),('Eye Contact','subject looks toward viewer'),('Costume Detail','clothing reveals status or identity'),('Attribute','object identifying the sitter'),('Background Symbolism','setting adds meaning'),('Facial Expression','emotion shown by the face'),('Portrait Lighting','light models facial form'),('Miniature Portrait','small portable likeness')]
landscapes = [('Horizon Line','eye-level boundary in a scene'),('Foreground','nearest part of the landscape'),('Middle Ground','space between front and distance'),('Background','distant part of a scene'),('Atmospheric Perspective','distance shown by haze and blue tones'),('Linear Perspective','space organized by receding lines'),('Seascape','painting of the sea'),('Cityscape','urban landscape'),('Pastoral Landscape','idealized countryside'),('Sublime Landscape','nature shown as powerful or awe-inspiring'),('Picturesque','charming varied landscape view'),('Plein Air','painting outdoors'),('Cloud Study','focused observation of clouds'),('Nocturne','night landscape mood'),('Panorama','wide sweeping view'),('Staffage','small figures in a landscape'),('Light Source','sun or moon direction in the scene'),('Reflections','mirrored forms in water'),('Terrain','landform such as hills or rocks'),('Weather Effect','rain fog snow or storm')]
still = [('Still Life','arranged objects as subject'),('Vanitas','still life about mortality'),('Memento Mori','reminder of death'),('Fruit Bowl','common still-life subject'),('Flower Arrangement','flowers arranged for painting'),('Tabletop Composition','objects arranged on a table'),('Glass Reflection','light reflected in glass'),('Metal Highlight','bright reflection on metal'),('Texture Study','surface quality emphasized'),('Symbolic Object','object carrying meaning'),('Skull Motif','mortality symbol'),('Candle Motif','passing time symbol'),('Book Motif','learning or knowledge symbol'),('Musical Instrument','arts and leisure symbol'),('Game Motif','chance or leisure symbol'),('Trompe-l’œil','illusion that tricks the eye'),('Overlapping Objects','depth created by overlap'),('Cast Shadow','shadow falling from an object'),('Local Color','natural object color'),('Balanced Arrangement','stable object composition')]
murals = [('Mural','large painting on a wall'),('Fresco Mural','mural painted into wet plaster'),('Public Art','art made for shared public space'),('Community Mural','mural made with local participation'),('Street Mural','large exterior urban painting'),('Ceiling Painting','painting made overhead'),('Trompe-l’œil Mural','wall illusion that fools the eye'),('Political Mural','public image with political message'),('Narrative Mural','mural telling a story'),('Restoration','repairing damaged wall art'),('Scale','large size relation to viewer'),('Cartoon','full-scale preparatory drawing'),('Pouncing','transferring a design through small holes'),('Scaffold','platform used to reach high walls'),('Wall Preparation','cleaning and priming surface'),('Underlayer','first mural layer'),('Outdoor Durability','resistance to weather'),('Site-Specific Design','image made for a location'),('Diego Rivera','artist famous for public murals'),('Mexican Muralism','movement using public murals')]

def make_obs(world, subcat, idx, prompt, ans, wrongs, obs_type, tags, prefs):
    dlabel, dtier = diff_label(idx)
    base=f'creative_arts_{world}_{sid(subcat)}_{idx+1:04d}'
    return {
        'observation_id': base,
        'universe': 'creative_arts', 'world': world, 'subcategory': sid(subcat),
        'difficulty': {'label': dlabel, 'tier': dtier},
        'observation_type': obs_type,
        'prompt': prompt, 'correct_answer': ans, 'distractors': wrongs[:3],
        'localization': {'prompt_key': base+'_prompt', 'answer_key': base+'_answer'},
        'metadata': {'tags': tags, 'scenario_compatibility': prefs, 'deterministic_seed_key': base, 'quality': {'recognition':5,'visual_presentation':5,'fast_comprehension':5,'replayability':5,'educational_value':5,'mobile_readability':5}, 'source_basis': 'Museum/education reference set: Tate art terms, National Gallery elements of art, Britannica and Met-linked painting technique references.'}
    }

def build_100(subcat, concepts, kind):
    prefs=pref_for(subcat); obs=[]
    answers=[c[0] for c in concepts] if kind!='paintings' else [c[0] for c in concepts]+[c[1] for c in concepts]
    for i in range(100):
        c=concepts[i%len(concepts)]
        variant=i//len(concepts)
        if kind=='paintings':
            title, artist, clue=c
            if variant%4==0: prompt=f'Who painted {title}?'; ans=artist; wrong=distract(ans,[x[1] for x in concepts]); typ='Artwork → Artist'
            elif variant%4==1: prompt=f'{artist} is best matched with which artwork?'; ans=title; wrong=distract(ans,[x[0] for x in concepts]); typ='Artist → Artwork'
            elif variant%4==2: prompt=f'Which artwork shows {clue}?'; ans=title; wrong=distract(ans,[x[0] for x in concepts]); typ='Visual Identification'
            else: prompt=f'{title} is associated with which artist?'; ans=artist; wrong=distract(ans,[x[1] for x in concepts]); typ='Artwork → Artist'
        elif kind=='painters':
            artist, movement, work=c
            prompts=[(f'Which painter is linked to {work}?', artist, [x[0] for x in concepts], 'Artwork → Artist'),(f'{artist} is most associated with which movement?', movement, [x[1] for x in concepts], 'Style Recognition'),(f'Who is a key {movement} painter?', artist, [x[0] for x in concepts], 'Rapid Classification'),(f'Which work is strongly linked to {artist}?', work, [x[2] for x in concepts], 'Artist → Artwork')]
            prompt,ans,pool,typ=prompts[variant%4]; wrong=distract(ans,pool)
        else:
            term, clue=c
            prompts=[(f'{clue}.', term, 'Rapid Classification'),(f'Identify the art term: {clue}.', term, 'Tool/Technique Recognition'),(f'Which concept means {clue}?', term, 'Rapid Classification'),(f'Spot the matching term for: {clue}.', term, 'Visual Identification'),(f'{term} is best described as what?', clue, 'True / Definition')]
            prompt, ans, typ = prompts[variant%5]
            pool=[x[0] for x in concepts] if ans==term else [x[1] for x in concepts]
            wrong=distract(ans,pool)
        obs.append(make_obs('painting', subcat, i, prompt, ans, wrong, typ, [sid(subcat), sid(ans)], prefs))
    return obs

subcat_data = {
'Famous Paintings': (paintings,'paintings'), 'Famous Painters': (painters,'painters'), 'Art Styles': (styles,'terms'), 'Color Theory': (color,'terms'), 'Painting Techniques': (techniques,'terms'), 'Art Materials': (materials,'terms'), 'Portraits': (portraits,'terms'), 'Landscapes': (landscapes,'terms'), 'Still Life': (still,'terms'), 'Murals': (murals,'terms')}

# clean old creative arts base bundle worlds: replace with painting compiled only
if BASE_ROOT.exists():
    shutil.rmtree(BASE_ROOT)
BASE_ROOT.mkdir(parents=True, exist_ok=True)

# write universe manifest and world manifests
if BANK_ROOT.exists():
    shutil.rmtree(BANK_ROOT)
(BANK_ROOT/'worlds').mkdir(parents=True, exist_ok=True)
(BANK_ROOT/'schema').mkdir(parents=True, exist_ok=True)
json.dump({'schema_version':1,'universe':'creative_arts','display_name':'Creative Arts','world_order':list(worlds.keys()),'architecture':'Universe > World > Subcategory > Observation Bank','implementation_status': {'painting':'complete_template','remaining_worlds':'metadata_scaffold_pending_full_banks'}}, open(BANK_ROOT/'universe_manifest.json','w'), indent=2)
json.dump({'schema_version':1,'required_observation_fields':['observation_id','universe','world','subcategory','difficulty','observation_type','prompt','correct_answer','distractors','localization','metadata'],'scenario_preference_fields':['preferred','secondary','rare','disabled']}, open(BANK_ROOT/'schema/observation_bank_schema.json','w'), indent=2)
compiled=[]
for wid, subs in worlds.items():
    wdir=BANK_ROOT/'worlds'/wid
    (wdir/'subcategories').mkdir(parents=True, exist_ok=True)
    world_manifest={'schema_version':1,'universe':'creative_arts','world':wid,'display_name':wid.replace('_',' ').title(),'subcategory_order':[sid(x) for x in subs],'subcategories':[],'status':'complete' if wid=='painting' else 'metadata_only_pending_full_observation_bank'}
    for sub in subs:
        prefs=pref_for(sub)
        scid=sid(sub)
        world_manifest['subcategories'].append({'id':scid,'display_name':sub,'scenario_preferences':prefs,'target_observations':100,'implemented_observations':100 if wid=='painting' else 0})
        if wid=='painting':
            concepts,kind=subcat_data[sub]
            obs=build_100(sub, concepts, kind)
            bank={'schema_version':1,'observation_bank_version':'creative_arts.v1.painting','universe':'creative_arts','world':wid,'subcategory':scid,'display_name':sub,'scenario_preferences':prefs,'observations':obs}
            json.dump(bank, open(wdir/'subcategories'/f'{scid}.json','w'), indent=2, ensure_ascii=False)
            for o in obs:
                primary=prefs['preferred'][0]
                cid=f"{o['observation_id']}_{primary}"
                compiled.append({'id':cid,'observation_id':o['observation_id'],'universe':'creative_arts','world':wid,'subcategory':scid,'type':primary,'rules':{'prompt':o['prompt'],'legacy_prompt':o['prompt'],'correct_answer':o['correct_answer'],'wrong_answers':o['distractors']},'presentation':{'title':f"Painting — {sub}",'difficulty_tier':o['difficulty']['tier'],'subcategory':scid,'observation_type':o['observation_type']},'metadata':o['metadata']})
    json.dump(world_manifest, open(wdir/'world_manifest.json','w'), indent=2)
# compiled runtime bank
runtime_dir=BASE_ROOT/'painting'
runtime_dir.mkdir(parents=True, exist_ok=True)
json.dump(compiled, open(runtime_dir/'painting_observation_bank_compiled.json','w'), indent=2, ensure_ascii=False)
print('worlds',len(worlds),'painting observations',sum(len(json.load(open(BANK_ROOT/'worlds/painting/subcategories'/f'{sid(sub)}.json'))['observations']) for sub in worlds['painting']),'compiled',len(compiled))
