# 2 Second Witness (Liquid Memory V2 Engine)

This is the production repository for **2 Second Witness**, running on the Liquid Memory V2 Godot 4.6 Engine. 

## Repository Structure
The repository is split into two distinct operational domains to support Over-The-Air (OTA) updates:

### `/app/` (The Engine)
This directory contains the Godot 4.6 project. It handles all rendering, state management, cognitive measurement logic, and the offline fallback bundle.
- **Do NOT** update content here if you want it to push to live users. This requires a full App Store update.
- Contains the `FidelityEnforcer`, `SystemHealthMonitor`, and the `UniverseRenderer` manifolds.

### `/live_content/` (The OTA Pipeline)
This directory is the live production database. 
- When the app boots, `GitHubSyncManager` pings `manifest.json`.
- Drop new Scenario JSONs or `Universe` assets here to instantly push content to players without a Godot rebuild.

---

## Developer Setup (Windows 11)
To begin development and testing on your local machine:

1. **Clone the Repository:**
   ```bash
   git clone https://github.com/ITTYBITTYBITES/2-second-witness-mobile.git
   ```
2. **Install Godot 4.3 (or 4.6):**
   Download the standard 64-bit version of Godot 4 from the official website.
3. **Open the Project:**
   Open Godot, click **Import**, and navigate to the `/app/project.godot` file.
4. **Android Export Requirements:**
   To build the APK on Windows 11, you must install:
   - **Android Studio** (for the Android SDK and Platform Tools).
   - **OpenJDK 17** (for the Java keystore).
   - In Godot, go to `Editor -> Editor Settings -> Export -> Android` and link your SDK and Java paths.

## Architecture Documentation
Please read the following documents in the root directory before modifying the codebase:
- `PLATFORM_CONSTITUTION.md` (Immutability Rules)
- `ASSET_CONTRACT_SPEC.md` (Art Pipeline Rules)
- `FIDELITY_BUDGET_SPEC.md` (Performance Budgets)
- `THE_ROAD_TO_ALPHA.md` (Product Milestones)
