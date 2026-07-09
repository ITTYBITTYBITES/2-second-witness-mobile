# Implemented Foundation Systems

## Overview
8 core systems + 3 core app modules + 2 navigation modules + UI shell + 4 screens + experience module system. All implemented from scratch, independent, reusable, typed GDScript.

---

### Core App

#### AppBoot.gd (`src/core/app/AppBoot.gd`)
- **Role:** Clean startup flow orchestrator
- **Enum BootStep:** INIT_CONFIG, INIT_THEME, INIT_SETTINGS, INIT_SAVE, INIT_CONTENT, INIT_AUDIO, INIT_NAV, FINALIZE
- **Signals:** boot_step_started(step), boot_step_completed(step, duration_ms), boot_completed(), boot_failed(reason)
- **API:**
  - `start_boot()` async sequential
  - `_run_step(name, stepEnum, callable)` timed, fault-tolerant, sets loading state via AppState
  - Each step method `_boot_config()` etc returns {} or {error}
- **Integration:** Sets AppState loading message, logs via print, catches failures via ErrorHandler but continues
- **Future:** Can add retry, timeout, progress bar binding, dependency injection

#### AppState.gd (`src/core/app/AppState.gd`)
- **Role:** Single source of truth app phase + transient store
- **Enum AppPhase:** BOOT, SPLASH, HOME, EXPERIENCES, PROFILE, SETTINGS, EXPERIENCE_PLAYING
- **Signals:** phase_changed(new, old), state_updated(key, value), loading_changed(is_loading, message)
- **State:** current_phase, previous_phase, is_initialized, is_loading, loading_message, session_start_time, active_experience_id, transient_data dict, _state dict
- **API:** set_phase(), set_loading(), set_value()/get_value(), set_transient()/get_transient()/clear_transient(), get_session_duration_ms()
- **Usage:** Boot sets loading, Navigation updates phase via mapping route->phase, UI listens loading_changed to show overlay

#### ErrorHandler.gd (`src/core/app/ErrorHandler.gd`)
- **Role:** Central error handling + recovery
- **Enum Severity:** INFO, WARNING, ERROR, CRITICAL
- **Signals:** error_logged(entry), user_message_requested(message, severity)
- **API:** handle(code, message, context, severity), handle_exception(code, context), get_history(), clear_history(), _attempt_safe_recovery()
- **Logic:** On CRITICAL pushes error, emits user_message, navigates home safe. Logs to AnalyticsService optionally. History max 100.

#### EventBus.gd (`src/core/events/EventBus.gd`)
- **Role:** Decoupled messaging
- **Signals:** app_initialized, navigation_requested(route, params), navigation_changed(route, params), setting_changed(key, value), theme_changed(theme_name), audio_requested(bus, sound_id, params), profile_updated(profile_data), experience_unlocked(exp_id), experience_completed(exp_id, result), error_occurred(code, message, context), accessibility_changed(settings)
- **API:** emit_routed(), _log_event(), get_recent_events(count), publish_navigation(route, params), publish_error(code, message, context)
- **Buffer:** last 200 events with timestamp ticks
- **Usage:** All systems emit via this, no direct cross-service calls for most

### Navigation

#### AppRoutes.gd (`src/core/navigation/AppRoutes.gd`)
- **Role:** Route definitions validation
- **Const ROUTES:** dict route-> {screen, is_tab, requires_auth, icon, label}
- **Const TAB_ORDER:** ["home","experiences","profile","settings"]
- **Static API:** is_valid_route(route), is_tab_route(route), get_screen_name(route), get_tab_routes()

#### NavigationService.gd (`src/core/navigation/NavigationService.gd`)
- **Role:** Central router + history
- **Signals:** route_changed(route, params), route_change_requested(route, params), history_updated(history), deep_link_received(route, params)
- **State:** current_route default splash, current_params, history Array max 50
- **API:** initialize(), navigate_to(route, params) bool validates via AppRoutes, push history, emit signals, update AppState phase, analytics log; go_back() bool pops, can_go_back(), replace(route, params), clear_history(), _push_history(), get_current(), _on_navigation_requested()
- **Integration:** Listens EventBus.navigation_requested, updates AppState phase via _update_app_state_phase()

### Systems

#### ConfigService.gd (`src/systems/config/ConfigService.gd`)
- **Role:** App configuration + feature flags
- **Signals:** config_loaded(config), config_value_changed(key, value)
- **Const DEFAULT_CONFIG:** app_name, app_version 2.0.0-foundation, environment development, package_id, feature_flags {analytics true, ads false, iap false, debug_overlay false, experiences true etc}, content {version, auto_update, base_url}, gameplay {replay_delay, max_session_minutes, haptic_default}, ui {animation_duration, default_theme dark, reduced_motion_default false}
- **API:** initialize() merges user://app_config_override.json if exists, get_value(path dot notation, default), set_value(path, value), get_all(), is_feature_enabled(flag)
- **Internal:** _merge_config(target, override) recursive

#### ThemeService.gd (`src/systems/theme/ThemeService.gd`)
- **Role:** Design tokens + theme switching
- **Enum ThemeMode:** DARK, LIGHT, SYSTEM
- **Signals:** theme_changed(theme_name, tokens), theme_tokens_updated()
- **Consts:** DARK_TOKENS and LIGHT_TOKENS dicts with background, background_secondary/tertiary, surface/surface_elevated, primary #7C5CFF, primary_variant #9B83FF, secondary #2EE6A6, accent #FF6B6B, text_primary/secondary/tertiary, text_on_primary, border, error #FF4D5E etc, radius, spacing, typography map
- **State:** current_mode DARK default, current_theme_name, tokens dict
- **API:** initialize() reads theme_mode from SettingsService, set_theme_mode(mode) sets tokens duplicate and emits, get_color(token, fallback), get_spacing(size_name), get_radius(size_name), get_typography(style), apply_theme_to_control(control), _on_setting_changed()
- **Future:** Can load custom themes from ContentService JSON

#### AudioService.gd (`src/systems/audio/AudioService.gd`)
- **Role:** Central audio bus + players
- **Enum Bus:** MASTER, BGM, SFX, UI
- **Const BUS_NAMES:** mapping Bus->String
- **Signals:** volume_changed(bus, volume_db, linear), bus_muted(bus, muted), sound_played(sound_id, bus)
- **State:** _players dict, _bgm_player single AudioStreamPlayer, _sfx_pool Array 6 players, _ui_player, _initialized bool, _volumes dict Master 1.0 BGM 0.8 SFX 0.9 UI 0.8, _muted dict all false
- **API:** initialize() ensures buses via AudioServer, creates players, loads volumes/mutes from SettingsService, _ensure_buses(), play_ui(sound_id, volume), play_sfx(), play_bgm(sound_id, loop, fade), play_sound(sound_id, bus, volume, loop) loads via _get_stream_for_id() which tries res://assets/audio/{id}.wav/.ogg etc, _get_free_sfx_player(), _get_stream_for_id(), set_volume(bus, linear) clamp + AudioServer set + emit + save to Settings, get_volume(), set_muted()/is_muted(), _apply_all_volumes(), stop_bgm(fade), _on_audio_requested()
- **Foundation:** If sound file missing, logs placeholder but doesn't crash

#### SaveService.gd (`src/systems/save/SaveService.gd`)
- **Role:** Low-level persistence versioned
- **Const:** SAVE_VERSION 2, SAVE_DIR user://saves/, PROFILE_FILE user://profile_v2.json, SETTINGS_FILE user://settings_v2.json
- **Signals:** save_completed(slot), save_failed(slot, reason), save_loaded(slot, data)
- **API:** initialize() ensures SAVE_DIR exists, save_json(path, data, encrypt bool) wraps {version, timestamp, ticks, data} stringify with tab indent, handles FileAccess errors via ErrorHandler, load_json(path, default) parse, migration if version < SAVE_VERSION via _migrate(), delete_save(), has_save(), list_saves(dir), _migrate(data, from, to), convenience save_profile(data), load_profile(), save_settings(), load_settings()
- **Error handling:** Emits save_failed on open error, parse failed

#### ProfileService.gd (`src/systems/save/ProfileService.gd`)
- **Role:** Player profile + progress
- **Signals:** profile_loaded(profile), profile_saved(profile), profile_updated(field, value), experience_progress_updated(exp_id, progress), stats_updated(stats)
- **Const DEFAULT_PROFILE:** version 2, id empty, display_name Witness, created_at, last_seen, level 1, xp 0, xp_to_next 100, total_sessions 0, total_play_time_ms 0, experiences_unlocked ["flashword"], experiences_progress {exp_id->{played,best_score,last_played,total_score}}, stats {observations_made, correct_observations, fastest_reaction_ms 9999, streak_current, streak_best}, achievements [], preferences {onboarding_completed false}
- **API:** initialize() loads via SaveService.load_profile() or creates new with _generate_id(), merges via _merge_default(), increments total_sessions, last_seen, save(); _merge_default(loaded) deep merge, save() updates last_seen + save via SaveService + emits; get_value(key, default), set_value(key, value) save, add_xp(amount) level up loop xp*1.25, analytics log level_up; record_experience_play(exp_id, result) increments played, total_score, best_score, last_played, updates stats observations_made, correct, streak, fastest_reaction, emits progress/stats, EventBus experience_completed, save, analytics; unlock_experience(exp_id), is_experience_unlocked(), get_experience_progress(), get_stats(), _generate_id() witness_{ticks}_{rand}, reset_profile()
- **Integration:** Emits profile_updated to EventBus

#### SettingsService.gd (`src/systems/settings/SettingsService.gd`)
- **Role:** User prefs persistence
- **Signals:** setting_changed(key, value), settings_loaded(settings), settings_saved(settings), settings_reset()
- **Const DEFAULT_SETTINGS:** version 2, volumes master 1.0 bgm 0.7 sfx 0.9 ui 0.8, mutes false, haptics_enabled true, theme_mode dark, reduced_motion false, screen_shake true, font_scale 1.0, high_contrast false, show_tutorials true, auto_play_next false, confirm_exit true, analytics_enabled true, crash_reporting true, accessibility_font_scaling 1.0, accessibility_reduce_motion false, screen_reader_hints false, language en, first_launch_completed false
- **API:** initialize() loads via SaveService.load_settings() or defaults, merges via _merge_defaults(), _apply_settings(), get_value(key, default), set_value(key, value) save + emit setting_changed + EventBus + analytics unless volume, _save(), get_all(), reset_to_defaults(), is_haptics_enabled(), is_reduced_motion(), get_font_scale() clamped 0.8-1.4, get_theme_mode()
- **Usage:** Other systems listen setting_changed to apply immediately

#### AnalyticsService.gd (`src/systems/analytics/AnalyticsService.gd`)
- **Role:** Decoupled telemetry
- **Signals:** event_logged(event_name, params), screen_view_logged(screen_name)
- **Consts:** MAX_BUFFER 200, BUFFER_FILE user://analytics_buffer.jsonl, ANALYTICS_VERSION 1
- **State:** _event_buffer Array, _session_id string, _is_enabled bool, _initialized
- **API:** initialize() gen session_id sess_{ticks}_{rand}, reads analytics_enabled from SettingsService, logs session_start; _on_setting_changed(), log_event(event_name, params) if disabled skip except session_start, entry {v, event, params, timestamp, ticks_ms, session_id, phase}, push buffer pop-front if over max, emit, _append_to_file() FileAccess READ_WRITE seek_end store JSONL, print if dev env; log_screen_view(screen, params), log_error(code, message, context, severity), log_experience_event(exp_id, action, data), _generate_session_id(), get_buffered_events(), clear_buffer(), set_enabled()
- **Privacy:** Respects opt-out, buffers locally, ready for future endpoint POST (not implemented in foundation)

#### AccessibilityService.gd (`src/systems/accessibility/AccessibilityService.gd`)
- **Role:** Accessibility features
- **Signals:** accessibility_updated(settings), font_scale_changed(scale), reduced_motion_changed(enabled)
- **State:** _font_scale 1.0, _reduced_motion false, _high_contrast false, _haptics_enabled true, _screen_reader_hints false, _initialized
- **API:** initialize() reads from SettingsService accessibility_* keys, listens setting_changed, _on_setting_changed() match keys, updates state + emit, _accessibility_updated() emits snapshot, get_font_scale(), is_reduced_motion_enabled(), is_high_contrast_enabled(), is_haptics_enabled(), should_animate() not reduced_motion, get_animation_duration(base) 0.3x if reduced, apply_accessibility_to_control(control) font_size override for Label/Button if font_scale !=1, vibrate(duration_ms, amplitude) Input.vibrate_handheld if mobile and haptics enabled, get_settings_snapshot()
- **Future:** Screen reader hints, high contrast shader, larger touch targets

#### ContentService.gd (`src/systems/content/ContentService.gd`)
- **Role:** Content loading caching OTA ready
- **Signals:** content_loaded(content_id, data), content_load_failed(content_id, reason), content_cache_cleared()
- **Consts:** CONTENT_MANIFEST_PATH res://src/experiences/manifest.json, USER_CONTENT_DIR user://content/
- **State:** _cache dict id->data, _manifest dict, _initialized
- **API:** initialize() ensures USER_CONTENT_DIR, await _load_manifest(); _load_manifest() tries paths CONTENT_MANIFEST_PATH, res://src/systems/content/content_manifest.json, user://content_manifest.json via _load_json() else fallback {version 1, experiences ["flashword"]}; _load_json(path) FileAccess or ResourceLoader JSON; get_content(content_id) returns cache if exists else tries res://src/experiences/{id}/{id}.json, manifest.json, USER_CONTENT_DIR/{id}.json via _load_json and caches; preload_content(), cache_content(id, data) cache + persist to user file, clear_cache(), get_manifest(), get_content_list(), is_content_available()
- **OTA:** user:// overrides res:// - future GitHubSyncManager can drop JSONs to user:// without rebuild

#### ExperienceRegistry.gd (`src/systems/content/ExperienceRegistry.gd`)
- **Role:** Module registry, modular expansion core
- **Signals:** experience_registered(exp_id, manifest), experience_unregistered(exp_id), registry_updated(experiences Array)
- **Consts:** EXPERIENCE_BASE_PATH res://src/experiences/
- **State:** _experiences dict id->{manifest, registered_at, is_locked, is_coming_soon}, _initialized
- **API:** initialize() await _scan_and_register(); _scan_and_register() known_ids ["flashword"] + list from ContentService + dynamic DirAccess scan of EXPERIENCE_BASE_PATH for dirs not starting _/. ; for each _register_from_path(exp_id); _register_from_path() tries manifest_paths [exp/manifest.json, exp/{Cap}_manifest.json, FlashwordManifest.json if flashword], FileAccess parse else _create_default_manifest(exp_id); Ensure id,title, registers entry, emits registered; _create_default_manifest() for flashword returns detailed title Flashword, short_description Observe. Remember. Recall., description 2-second glance, category memory, tags memory/observation/quick, version 1.0.0-foundation, difficulty easy/medium/hard, duration 15, icon flashword, preview_color #7C5CFF, locked false, coming_soon false, else generic placeholder locked true coming_soon true; register_experience(id, manifest) update, unregister_experience(id), get_experience(id) entry, get_manifest(id), get_all_experiences() Array sorted by title merging runtime {is_locked, is_coming_soon, is_unlocked from ProfileService.is_experience_unlocked if available}, get_unlocked_experiences() filter is_unlocked and not coming_soon, is_registered(), count()
- **Key Feature:** New experiences added by folder copy, no core change

### UI Shell

#### AppShell.gd
- **Role:** Root container, layers management, screen cache
- **Onready:** content_container ContentLayer/ContentContainer, nav_bar NavigationLayer/MainNavigation, top_bar TopBarLayer/TopBar, loading_overlay OverlayLayer/LoadingOverlay, error_banner OverlayLayer/ErrorBanner, background_layer BackgroundLayer
- **State:** _current_screen Control, _screen_cache dict route->Control, _boot_flow Node
- **Const SCREEN_SCENES:** splash->SplashScreen.tscn etc
- **API:** _ready ensures boot flow, connects AppState phase_changed/loading_changed, NavigationService route_changed, ErrorHandler user_message, ThemeService; _ensure_boot_flow() loads AppBoot.gd script new() add_child; _on_boot_completed() set loading false, navigate home if splash else load current; _on_boot_failed(reason) show error; _on_route_changed(route, params) load screen + update chrome; _load_screen(route, params) hide current, if cache visible else try ResourceLoader scene_path SCREEN_SCENES[route] instantiate else _create_placeholder_screen(route) which loads PlaceholderScreen.gd, cache; _create_placeholder_screen(); _update_chrome(route) is_tab via AppRoutes, show/hide nav_bar and top_bar, set back visibility not is_tab, title map; _on_phase_changed(), _on_loading_changed() show overlay, _on_user_message(), _show_error() auto-hide 4 sec, _apply_theme() background panel style, _on_theme_changed(), _capitalize_first(s)
- **Cache:** Keeps tab screens alive, hides not frees

#### TopBar.gd
- **Role:** Header
- **Export:** title_text default "2 Second Witness" set via setter, show_back false, show_profile true
- **Signals:** back_pressed, profile_pressed, settings_pressed
- **Onready:** title_label, back_button, profile_button, settings_button
- **API:** _ready _ensure_ui builds programmatically if scene nodes missing: Margin->HBox Back < Title expand Settings ⚙ Profile ◉; _apply_theme border bottom, font color; _refresh show_back/show_profile; set_title(t), set_show_back(v), _on_theme_changed, _on_back() audio ui_click emit, _on_profile(), _on_settings()

#### MainNavigation.gd
- **Role:** Bottom tab nav 4 tabs
- **Const TABS:** [{route home label Home icon ⌂}, {experiences Play ◫}, {profile Profile ◉}, {settings Settings ⚙}]
- **Signal:** tab_selected(route)
- **State:** current_route home, _buttons dict route->Button, _indicator
- **API:** _ready _ensure_ui builds if missing: Margin->HBox each tab VBoxContainer expand Button 60px text icon newline label meta route stored; _wire_existing_buttons(); _apply_theme background_secondary, border top, corner radius lg top only, per button StyleBoxFlat corner md, bg primary if selected else transparent, font color text_on_primary if selected else text_secondary, font size 12; _refresh_selection() calls _apply_theme; _on_tab_pressed(route) if same vibrate 20 no nav else set current, refresh, vibrate 30, play ui_click, emit tab_selected, NavigationService.navigate_to, analytics; _on_route_changed(route) if tab route set current refresh; _on_theme_changed; set_current_route(route)

### Components

#### AppButton.gd
- **Enum Variant:** PRIMARY, SECONDARY, GHOST, DANGER
- **Export:** variant PRIMARY, full_width false, is_loading bool setter set_loading, icon_name
- **State:** _original_text
- **API:** _ready store original text, apply theme, connect ThemeService theme_changed, AccessibilityService accessibility_updated, focus_mode FOCUS_ALL; _apply_theme() builds StyleBoxFlat normal/hover/pressed/disabled per variant: PRIMARY bg primary, text_on_primary, radius md, content margin 20/12; SECONDARY bg surface_elevated border border; GHOST transparent text secondary; DANGER error bg; disabled 0.4 alpha; full_width size_flags expand else shrink center; _on_theme_changed, _on_accessibility_updated apply, set_loading(loading) disabled loading text Loading... else original

#### AppCard.gd
- **Export:** elevated bool, has_border bool true, corner_radius int -1 (use token if -1)
- **API:** _ready apply theme, connect theme_changed; _apply_theme() tokens surface elevated ? surface else surface etc, border token, radius lg default 20, content margin md 16, shadow 8 offset 0,4 if elevated, border blend

#### ExperienceCard.gd
- **Signals:** experience_selected(exp_id), info_requested(exp_id)
- **Export:** experience_id string
- **State:** manifest dict, onready card_root PanelContainer Card, title_label, desc_label, meta_label, icon_panel, play_button
- **API:** _ready if manifest empty and experience_id set and ExperienceRegistry get manifest, _ensure_wired() if nodes exist wire pressed else _build_ui() programmatic: custom_min 180, Panel Card Margin 16 VBox TopRow HBox IconWrapper 48x48 custom Title expand MetaRow Meta Description autowrap Play button; _apply_theme card surface border radius lg, title 18 text_primary, desc 13 text_secondary, meta 11 text_tertiary; _refresh_ui() from manifest title short_description category duration tags color_str preview_color coming_soon locked runtime is_locked is_unlocked etc update labels, play button text Play • Xs or Coming Soon disabled or Locked disabled, icon panel bg preview_color; _on_play_pressed() check coming_soon locked, haptics vibrate 30, audio ui_click, emit experience_selected; _on_card_input(event)

#### SectionHeader.gd
- **Export:** title_text Section, subtitle_text, show_action false, action_text See all
- **Signal:** action_pressed()
- **Onready:** title_label VBox/TitleRow/Title, subtitle_label VBox/Subtitle, action_button TitleRow/ActionButton
- **API:** _ready _ensure_ui builds VBox TitleRow HBox Title expand ActionButton visible show_action Subtitle visible if subtitle != ""; _apply_theme title text_primary 20 subtitle text_secondary 14; set_title, set_subtitle, _on_theme_changed, _on_ActionButton_pressed emit

### Screens

#### SplashScreen.gd
- **Onready:** title_label Center/VBox/Title, subtitle, progress_bar ProgressBar, status_label Status
- **State:** _boot_steps_completed int 0, _total_boot_steps 8
- **API:** _ready _ensure_ui builds Center VBox Icon ◉ 64 Title 36 "2 SECOND\nWITNESS" Subtitle "Observe. Remember. React." ProgressBar 200x8 max 100 value 0 Status "Initializing..." 11; _apply_theme title primary, subtitle text_secondary, status text_tertiary; _find_boot_node() tries paths /root/AppShell/AppBoot etc, _find_app_shell(); _ensure_ui, animate_in via modulate fade 0.5 if not reduced_motion; _on_boot_step_started(step) status "Loading {Step}..."; _on_boot_step_completed(step, duration) inc completed pct = completed/total*100 value; _on_boot_completed() status Ready value 100 delay 0.4 sec navigate home via NavigationService; on_navigated_to reset

#### HomeScreen.gd
- **Onready:** scroll Margin/Scroll, content_vbox Margin/Scroll/VBox
- **API:** _ready _ensure_ui builds hero card 160 primary bg "YOU ARE\nTHE WITNESS" subtitle, QuickPlay 56 Quick Play • 2 Seconds, SectionLabel Featured Experience, placeholder; wire QuickPlayButton pressed, ExperienceCard selected; _apply_theme; _refresh_data(): profile level/xp/streak stats, create StatsRow HBox 12 separation 3 cards each Panel 80 Value + Label config: if missing create; _create_hero_card() panel primary radius 24 title 28 white subtitle 14 0.8 alpha; _create_stats_row() HBox 3 cards 80; _update_stats_row(row, level, xp, streak); _refresh_featured_experience() remove old FeaturedExperienceCard/Placeholder, get ExperienceRegistry.get_all_experiences first, instantiate ExperienceCard via script set_experience manifest connect selected; on_navigated_to refresh + analytics log screen view home; _on_quick_play vibrate 30 ui_click pick random unlocked exp from registry navigate to experiences with auto_play param else experiences; _on_experience_selected(exp_id) navigate experiences highlight+auto_play; _on_theme_changed, _on_profile_updated, _on_registry_updated

#### ExperiencesScreen.gd
- **Onready:** scroll, list_vbox
- **State:** _current_filter all, _highlight_id
- **API:** _ready _ensure_ui builds Margin 80 top 90 bottom Scroll VBox separation 16 header Title 28 Experiences sub 13 grey "Short, replayable tests • New modules...", filter row HBox 8 separation all/memory/observation/reaction toggle buttons with meta filter, all pressed true; _wire_filters(); _apply_theme; _refresh_list(): remove old Exp_* cards, if no registry placeholder Coming Soon card, get all from registry, filter by category or tags if not all, for each create _create_experience_card(manifest) via script, name Exp_{id}, add, highlight logic; if empty label No experiences; if empty? _create_experience_card() ExperienceCard script set_experience connect; _create_coming_soon_card() panel 120 label Loading experiences; on_navigated_to(params) highlight_id params highlight, auto_play param call_deferred _play_experience(auto_play), analytics log; _play_experience(exp_id) print, ProfileService.record_experience_play random score, manifest via registry, if flashword _show_flashword_preview else _show_coming_soon; _show_flashword_preview dialog text preview; _show_coming_soon title coming soon ErrorHandler handle INFO; _on_experience_selected(exp_id) _play_experience; _on_filter_pressed(filter, button) set filter, update button states others false this true, refresh, vibrate 20 analytics; _on_theme_changed, _on_registry_updated

#### ProfileScreen.gd
- **Onready:** scroll, vbox
- **API:** _ready _ensure_ui builds avatar card 120 Panel Margin HBox Icon 64x64 VBox NameLabel Witness 20 IdLabel SinceLabel, LevelCard 100 Panel, StatsGrid GridContainer 2 columns, ProgressHeader Progress label 18, ExperienceProgress VBox, ResetButton 44 Reset Profile (Debug) pressed connect; _wire_actions; _create_avatar_card() as above; _apply_theme each PanelContainer surface border radius lg; _refresh(): profile display_name, id, created_at sessions, _refresh_level_card() clear LevelCard children build Margin VBox HBox Level 20 + XP / XP next right ProgressBar max xp_next value xp custom 8; _refresh_stats() clear StatsGrid for child free, stats via ProfileService.get_stats() definitions observations_made Observed icon 👁 etc fastest_reaction_ms format %d ms, streak_best Best Streak 🔥 etc _create_stat_card(label,value,icon) Panel 80 Margin VBox top HBox icon+value 18 label 11; _refresh_experience_progress() clear ExperienceProgress, progress_dict profile experiences_progress, for each exp from ExperienceRegistry get_all, prog played best_score title row HBox 50 Title 120 min Played X Best Y right; on_navigated_to refresh analytics log profile; _on_profile_updated, _on_stats_updated, _on_theme_changed, _on_reset_pressed ProfileService reset_profile refresh audio ui_click

#### SettingsScreen.gd
- **Onready:** scroll, vbox
- **API:** _ready _ensure_ui if no VBox Title Settings exists build Margin Scroll VBox sep 24 placeholder; _apply_theme; _refresh() clear VBox for child free, if not SettingsService return, Title 28 Settings, then sections: section_header Appearance label 16 #7C5CFF, setting_row_toggle Dark Mode theme_mode check SettingsService theme dark == dark via _on_theme_toggle, Reduced Motion reduced_motion _on_generic_toggle, slider Font Scale font_scale 1.0 min 0.8 max 1.4 step 0.1; Audio Section slider Master Volume volume_master 1.0 0-1 step 0.1 etc, toggle Haptics haptics_enabled; Accessibility high_contrast, screen_reader_hints, reduce_motion accessibility_reduce_motion; Gameplay show_tutorials, auto_play_next; Privacy analytics_enabled, crash_reporting; About info rows App Version ConfigService app_version, Package ID, Build Foundation Phase • 2026-07-09, Engine Godot 4.6 / GL Compatibility; Reset All Settings button 48 reset; _create_section_header(text) Label 16 #7C5CFF; _create_setting_row_toggle(label,key,value,callback) HBox 56 Label expand CheckButton button_pressed value meta key toggled -> callback.call(key, v), wrap PanelContainer surface border radius 12 content margin 12/8; _create_setting_row_slider(label,key,value,min,max,step) VBox HBox Label expand ValueLabel formatted Master 0% etc HSlider min max step value meta key+value_label value_changed -> update label formatted + _on_slider_changed(key, v); wrap Panel similar; _create_info_row(label,value) HBox 40 Label expand Value 12 0.6 alpha grey card alpha 0.5 radius 8; on_navigated_to refresh analytics; _on_generic_toggle(key,value) SettingsService.set_value vibrate 20 audio; _on_theme_toggle(_key,is_dark) mode dark/light set SettingsService theme_mode, ThemeService set_theme_mode DARK/LIGHT, vibrate; _on_slider_changed(key,value) SettingsService.set_value if volume_* AudioService.set_volume per bus; _on_reset_settings SettingsService.reset_to_defaults refresh audio; _on_setting_changed _key _value call_deferred refresh; _on_theme_changed apply

#### PlaceholderScreen.gd
- **Export:** route_name unknown
- **API:** _ready if no Center create Center VBox Label Screen: route (Placeholder) Back to Home button navigate home via NavigationService; on_navigated_to(params) route_name params route print

### Experiences

#### ExperienceBase.gd
- **class_name:** ExperienceBase
- **Props:** id string, manifest dict, is_active bool
- **Signals:** started(exp_id), completed(exp_id, result), failed(exp_id, reason)
- **API:** _init(exp_id, manifest_data), get_title(), get_description(), get_preview_color(), start(params) -> session dict status started exp_id params override, emit started; end(result) emit completed; abort(reason) emit failed; get_manifest(), get_progress_template() {played 0 best_score 0 last_played "" total_score 0 mastery 0.0}

#### FlashwordExperience.gd (extends ExperienceBase)
- **State:** _words Array 20 default list WITNESS... EYE, _current_word, _choices Array, _start_time_ms int
- **Const DEFAULT_WORDS:** 20 words
- **API:** _init(exp_id flashword, manifest_data) super, _words duplicate DEFAULT; start(params) difficulty param medium default _pick_word(diff) random, _generate_choices(correct,4) pool shuffle, _start_time = ticks, session dict exp_id word choices difficulty observation_ms from manifest rules 2000 recall_ms 5000 status observation is_active true started emit print; submit_answer(answer) elapsed ticks-_start, correct answer==current, base_points manifest scoring base_points 10 score base if correct else 0 speed bonus if correct factor clamp 1 - elapsed/max_time *10 int add, result dict exp_id correct answer expected score reaction_ms streak_bonus 0 is_active false completed emit if ProfileService record_experience_play id result print; _pick_word(_difficulty) if _words empty refill; _generate_choices(correct,count) pool duplicate erase correct shuffle, choices [correct] while size<count and pool>0 not has append, shuffle; load_word_list_from_json(path) FileAccess parse Array or dict words

#### TemplateExperience.gd (extends ExperienceBase)
- **Role:** Copy-paste guide
- **_init()** super
- **start(params)** is_active true started emit print, returns exp_id status started params observation_ms 2000
- **end_with_result(correct,reaction_ms)** result dict exp_id correct score 10 if correct else 0 reaction_ms is_active false completed emit if ProfileService record play

### Manifests

#### src/experiences/manifest.json
- version 2, app_version 2.0.0-foundation, last_updated 2026-07-09, experiences ["flashword"], categories [memory,observation,reaction,quick-decision], featured flashword, notes Foundation phase modular registry

#### flashword/manifest.json
- id flashword title Flashword short_description Observe. Remember. Recall. description 2-second glance, category memory tags memory/observation/quick/word version 1.0.0-foundation min_app_version 2.0.0 difficulty [easy,medium,hard] estimated_duration_sec 15 icon flashword preview_color #7C5CFF gradient [#7C5CFF,#9B83FF] is_locked false coming_soon false is_featured true author team rules observation_ms 2000 recall_ms 5000 choices_count 4 scoring base_points 10 speed_bonus true streak_bonus true assets word_list path

#### _template/manifest.json
- id template title Template Experience short_description Copy to create, category observation tags template version 0.1.0 duration 10 preview_color #2EE6A6 locked true coming_soon true

### Build Configs

#### project.godot
- name 2 Second Witness, description short replayable experiences, main_scene src/ui/shell/AppShell.tscn, icon brand/app_icon_1024.png, boot_splash image same bg_color 0.055 0.055 0.08, features 4.6 Mobile, autoloads ordered EventBus, AppConfig/ConfigService same script, ErrorHandler, AnalyticsService, SettingsService, SaveService, ProfileService, ThemeService, AudioService, AccessibilityService, ContentService, ExperienceRegistry, NavigationService, AppState, display viewport 1080x1920 resizable false stretch canvas_items expand orientation 1 portrait, input_devices emulate_touch, rendering gl_compatibility textures etc2_astc, default clear color 0.06 0.06 0.09

#### export_presets.cfg
- preset 0 Android_Development platform Android runnable true filter all_resources export_path build/android/2sw-dev.apk arch arm64 true version code 100 name 2.0.0-foundation package unique_name com.ittybittybites.the2secondwitness name 2 Second Witness show_in_app_library true show_as_launcher true launcher_icons main 192x192 brand/app_icon_1024 adaptive foreground/background brand/android/icon_foreground/background screen orientation 1 portrait background_color 0.06 0.06 0.09 immersive true 32bits true opengl_debug false permissions internet true access_network_state true vibrate true etc custom_permissions none, graphics frambuffer, xvfb check true
- preset 1 Android_PlayStore export_format 1 (AAB) path build/android/2sw-release.aab version same, package same, screen immersive, keystore debug "" release "" user "" password "" placeholder

## Test Coverage (Manual)

- Boot: AppBoot steps 8 timed, Splash progress bar updates
- Navigation: tabs switch, history push, back to home fallback
- Theme: toggle dark/light via Settings persists via SettingsService
- Audio: volume sliders immediately apply via AudioService.set_volume, mute toggles via generic toggle (though UI for mute separate)
- Save: profile auto-creates witness_id, persists level/xp across restarts via user://profile_v2.json
- Settings: all toggles persist to user://settings_v2.json
- Experiences: registry count 1 flashword, filtering all/memory etc, play records score to profile, stats update
- Error handling: invalid route logs via ErrorHandler, doesn't crash
- Accessibility: font scale slider affects label? partially via apply_to_control hook, reduced motion halves animation duration
- Content: manifest loads, cache, clear

## Known Placeholder

- Audio files missing (ui_click.wav etc) old assets deleted - AudioService logs placeholder not crash
- Flashword full gameplay not yet (Phase 2) - foundation records random score to profile to demonstrate pipeline
- No custom fonts - uses default Godot font but ThemeService ready for font_family override
- No high contrast shader - flag present but not applied
- No online leaderboard etc - phase 2
