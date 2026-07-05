# System Contracts

**Phase:** 3 | **Status:** Additive documentation (no runtime changes) | **Date:** 2026-07-05

## How to read a contract
- **Inputs:** What the system accepts from callers
- **Outputs:** What the system produces/emits
- **Allowed mutations:** Internal state this system may write
- **Forbidden mutations:** State belonging to other systems it must NOT touch
- **Dependencies:** Other autoloads this one reads

## 1. NavigationRouter
- **Inputs:** _on_play_requested(), _on_play_universe_requested(u_id), _on_world_selected(u_id, w_id), _on_cascade_completed(), goto_landing()
- **Outputs:** Signal routed_to(destination); screen instantiation under MainShell/UILayer/NavigationUI
- **Allowed mutations:** active_landing_screen, persistent_mirror_instance, nav log, NavigationUI/HUDRoot children
- **Forbidden mutations:** PlayerProfile; ContentRegistry; ScenarioExecutionEngine; any singleton internals
- **Dependencies:** ModalWindowManager, InteractionKernel, AudioManager

## 2. NavigationEngine
- **Inputs:** navigate_to(data), process_selection(portal, type, data)
- **Outputs:** Signals transition_sequence_started, navigation_event(payload); portal state transitions
- **Allowed mutations:** Portal visibility; transition tweens
- **Forbidden mutations:** Screen instantiation (Router domain); ContentRegistry; PlayerProfile
- **Dependencies:** Listens to NavigationRouter.routed_to; reads NavigationState
- **Boundary:** Engine owns visual transitions; Router owns which screen is active.

## 3. NavigationState
- **Inputs:** Transition context data
- **Outputs:** NavigationMode enum; immutable transition context
- **Allowed mutations:** Own enum during committed transition (immutable thereafter)
- **Forbidden mutations:** Cannot trigger transitions; other systems
- **Dependencies:** Read by Router and Engine

## 4. ContentRegistry
- **Inputs:** register_scenario(data), register_world(), register_subcategory() from ContentLoader; queries
- **Outputs:** Metadata; playability verdicts; runtime_index
- **Allowed mutations:** runtime_index, _registered_ids, _world_metadata, _subcategory_index
- **Forbidden mutations:** Disk files; PlayerProfile; selection history; asset loading
- **Authority:** THE SOLE CONTENT AUTHORITY. No other system registers scenarios.

## 5. ContentLoader
- **Inputs:** load_world_content(u, w), load_universe_content(u), load_all_content()
- **Outputs:** Calls ContentRegistry.register_scenario(normalized_item)
- **Allowed mutations:** Own caching state (_indexed_files, _loaded_worlds)
- **Forbidden mutations:** ContentRegistry.runtime_index directly (use register_scenario()); PlayerProfile
- **Authority:** THE SOLE INGESTION PATH. No other system reads bank JSON.

## 6. ObservationCollection
- **Inputs:** next_observation(u, w, sub, mechanic, seed, filters), get_collection(), mark_observation_used()
- **Outputs:** Standardized observation Dictionary; signal observation_served(obs_id, scope)
- **Allowed mutations:** _recent_by_scope, _recent_global, _served_counts, _standardization_cache
- **Forbidden mutations:** ContentRegistry index; source data; PlayerProfile
- **Dependencies:** ContentRegistry (queries + lazy-load trigger)

## 7. ObservationBuilder
- **Inputs:** build_payload(cko, mechanic_id, context)
- **Outputs:** Gameplay payload (rules, presentation, metadata)
- **Allowed mutations:** None (stateless transform)
- **Forbidden mutations:** Any runtime state
- **Dependencies:** None (pure function)

## 8. SamplingController
- **Inputs:** _initialize_weekly_rotation(); get_next_scenario()
- **Outputs:** active_sampling_pool, featured_universes, target_quotas
- **Allowed mutations:** current_week_seed, active_sampling_pool, featured_universes
- **Forbidden mutations:** ContentRegistry; PlayerProfile
- **Dependencies:** WeeklyRotationManager; ContentRegistry

## 9. WeeklyRotationManager
- **Inputs:** refresh_weekly_rotation(force); is_universe_active(u_id)
- **Outputs:** Signal rotation_refreshed(active, seed); seed/universe queries
- **Allowed mutations:** Weekly rotation state
- **Forbidden mutations:** ContentRegistry; SamplingController; PlayerProfile
- **Dependencies:** Time; ContentRegistry

## 10. PlayerProfile
- **Inputs:** record_cognitive_event(), record_purchase_receipt(), evaluate_entitlements(), save_profile()
- **Outputs:** experience, current_level, player_title, coins, unlocked_*, cognitive_baseline
- **Allowed mutations:** All progression fields; user://profile.save
- **Forbidden mutations:** ContentRegistry; navigation; any singleton
- **Authority:** THE SOLE PROGRESSION STATE AUTHORITY.

## 11. MirrorNarrator (Mirror)
- **Inputs:** get_journey_narration(profile), get_strength_cards(profile), get_insights(profile)
- **Outputs:** Narration Dictionaries for Mirror UI
- **Allowed mutations:** None — READ-ONLY interpreter
- **Forbidden mutations:** PlayerProfile; ContentRegistry
- **Dependencies:** PlayerProfile (read-only)

## 12. SessionTracker
- **Inputs:** Session lifecycle events
- **Outputs:** Session metadata
- **Allowed mutations:** Own timer/state
- **Forbidden mutations:** PlayerProfile; ContentRegistry

## 13. ModalWindowManager
- **Inputs:** push_modal(screen, is_modal, caller), pop_modal(screen, caller), toggle_utility()
- **Outputs:** Signal modal_stack_changed; input blocker; z-ordering
- **Allowed mutations:** Modal stack; input blocker visibility
- **Forbidden mutations:** Navigation screens; PlayerProfile; ContentRegistry
- **Authority:** THE SOLE MODAL STACK OWNER.

## 14. InteractionKernel
- **Inputs:** consume_provenance(event_id, event), commit_intent(intent), register_panel()
- **Outputs:** Signals ui_lock_state_changed, epoch_resolved
- **Allowed mutations:** Input lock state; panel registry; epoch counter
- **Forbidden mutations:** Modal stack; navigation; PlayerProfile
- **Authority:** THE SOLE INPUT ELIGIBILITY AUTHORITY. 1 input -> 1 token.

## 15. ThemeManager
- **Inputs:** apply_theme(theme_id)
- **Outputs:** StyleBox/font overrides
- **Allowed mutations:** Theme resource state
- **Forbidden mutations:** ContentRegistry; PlayerProfile; navigation
- **Dependencies:** ContentRegistry identity API

## 16. AdManager
- **Inputs:** show_banner(), hide_banner()
- **Outputs:** Banner visibility
- **Allowed mutations:** Ad display state
- **Forbidden mutations:** Navigation; PlayerProfile; content

## 17. StoreManager
- **Inputs:** Purchase flows via billing callbacks
- **Outputs:** PlayerProfile.record_purchase_receipt(); entitlement signals
- **Forbidden mutations:** Does NOT directly set unlocked_* (use record_purchase_receipt())
- **Dependencies:** GooglePlayBilling; PlayerProfile; StoreTransactionState

## 18. GitHubSyncManager
- **Inputs:** manifest.json version check; OTA patches
- **Outputs:** Content version status; patches to user://live_content/
- **Allowed mutations:** user://live_content/patches/ directory
- **Forbidden mutations:** res:// bundle; ContentRegistry index; PlayerProfile

## 19. UIInputArbiter
**Does not exist as a runtime system.** Referenced in specs but fulfilled by InteractionKernel. Naming drift — flagged, not fixed.

## Cross-Reference: Boundary Resolutions
### C.1 Navigation split: Router=active screen, Engine=visual transition, State=context. Valid split, under-documented.
### C.2 PlayerProfile sole progression authority: CONFIRMED. No violations.
### C.3 ContentRegistry sole content authority: CONFIRMED. register_scenario only called by ContentLoader.
### C.4 ModalWindowManager sole modal owner: CONFIRMED. All modals via push_modal with caller.
