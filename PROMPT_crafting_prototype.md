# Prompt: Busa Fantasi — Coffee-Talk-Style Crafting Flow (Greybox / Placeholder Boxes)

> Paste everything below the line into your AI coding agent (Claude Code / Cursor) running inside this Godot project.
> It builds ONE playable, sequenced crafting screen made of swappable placeholder boxes that slide between phases like *Coffee Talk* (Toge Productions). No final art, no audio, no scoring yet — just layout + the panel-transition choreography that "feels right" and can later be reskinned by dropping in sprites.

---

## CONTEXT

You are working inside an existing **Godot 4.6** project (`gameseed-project`) for a cozy crafting game called **Busa Fantasi**. The theme is a child's bath-time imagination: a kid mixes ordinary bathroom items (soap, shampoo, toothpaste, etc.) and pretends to brew magical "potions." The UI layout and flow are modeled on **Coffee Talk**: a visual-novel dialogue, then a split-screen brewing station, then a serve/validation step, then a full-screen finishing minigame.

Relevant project facts (do not change these):
- Engine: **Godot 4.6**, Forward+ renderer.
- Design resolution: **1920 × 1080**, stretch mode `canvas_items`, aspect `keep`. Build the UI at 1920×1080 coordinates.
- Dialogue uses the **Dialogic** addon (already installed). Do NOT wire Dialogic into this prototype — the NPC dialogue here is a plain placeholder `Label`. We swap in Dialogic later.
- Existing folders to respect: `scenes/chapters/`, `scenes/ui/`, `scripts/systems/`, `scripts/dialogue/`, `resources/`, `assets/`.

## GOAL

Build a single playable, self-contained flow: **`scenes/chapters/level1.tscn`** with coordinator script **`scripts/systems/level1.gd`**, composed of the reusable panel sub-scenes listed below. (It's named `level1` because an intro scene will precede it later; this is the first playable level.) Running this scene must let me play the full Coffee-Talk-style loop **entirely in greyboxes**:

1. **Dialogue phase** — a full-screen visual-novel view: NPC portrait + a speech bubble I click to advance. When the dialogue ends, it transitions automatically into the brew phase.
2. **Brew phase** — the **ingredient/rack panel slides in from the right toward the center-left**, while the **NPC portrait stays visible** on the side (split-screen, like Coffee Talk's brewing screen). I pick up to **3** ingredients into the vessel slots and press **BREW**.
3. **Validation phase** — on **BREW**, the rack panel **slides further left** and a **new validation panel slides in from the right to center** offering **TRASH IT / SERVE IT / LATTE ART** (the "ngaduk / aduk-aduk" finishing step).
4. **Latte-art phase** — pressing **LATTE ART** brings up a **full-screen** stir/latte-art panel that **slides in from the top downward** (NOT split — it covers the whole screen, unlike the earlier split panels). I **stir by holding and dragging in circles** around the cup (rotary motion, NOT tapping), then **SERVE**.
5. **Serve / loop** — serving returns to the dialogue phase (or a short "nice, next!" placeholder), ready to start over.
6. See a live **debug Label** showing the current phase/state, the picked ingredients, and the stir count.

This is a **greybox prototype**. Everything visible is a labeled placeholder box. There is **no scoring, no tier system, no customer reaction, no menu** beyond what's described. **No gravity / physics** — ingredients are picked into slots, not dropped to fall (this replaces the earlier physics-drag concept entirely). Keep it to this crafting flow only.

## ARCHITECTURE (scene composition — build it this way)

Do **NOT** flatten every box into one giant `level1.tscn`, and do **NOT** use `change_scene_to_file` between phases (panels must overlap, slide, and the NPC must persist — `change_scene` destroys the previous scene). Instead:

- **`scenes/chapters/level1.tscn`** is a **thin coordinator**: a single root `Control` (full rect, 1920×1080) that **instances each panel as a child sub-scene**. Its script `level1.gd` owns the **state machine** and drives the **slide transitions** — it does not contain panel internals.
- **Each phase/panel is its own reusable `.tscn` + script**, so a designer can open one panel alone, reskin greybox → art, and run it standalone with **F6** without touching the others. Build these:

| Sub-scene | Script | Role |
|-----------|--------|------|
| `scenes/ui/panels/dialogue_panel.tscn` | `scripts/systems/dialogue_panel.gd` | Full-screen VN: NPC portrait + speech bubble + click-to-advance. |
| `scenes/ui/panels/npc_portrait_panel.tscn` | `scripts/systems/npc_portrait_panel.gd` | The persistent NPC face shown during the split brew/validation phases. |
| `scenes/ui/panels/brew_panel.tscn` | `scripts/systems/brew_panel.gd` | Ingredient rack + vessel slots (max 3) + RESET + BREW. Slides right→center-left. |
| `scenes/ui/panels/validation_panel.tscn` | `scripts/systems/validation_panel.gd` | Result name + TRASH IT / SERVE IT / LATTE ART. Slides right→center. |
| `scenes/ui/panels/latte_art_panel.tscn` | `scripts/systems/latte_art_panel.gd` | Full-screen stir/latte-art greybox + SERVE. Slides top→bottom. |
| `scenes/ui/placeholder_box.tscn` | `scripts/systems/placeholder_box.gd` | Reusable swappable greybox visual used everywhere (see Swappability). |

- The **full-screen latte-art panel** lives on a higher `CanvasLayer` (or is the top sibling) so it cleanly covers the split panels beneath it.
- Each panel **exposes a clean public API** for the coordinator to drive transitions, e.g. `func slide_in(from: int) -> void` and `func slide_out(to: int) -> void` where `from`/`to` is a direction enum (`LEFT, RIGHT, TOP, BOTTOM`). The coordinator calls these; the panel owns its own tween. This keeps `level1.gd` orchestrating *what* happens and each panel owning *how* it animates.

### Coordinator scene tree (target)

```
Level1 (Control, root, full rect)            # level1.gd  — state machine + orchestration
├── Background (PlaceholderBox, full rect)   # bathroom wall/floor greybox, swappable texture
├── NpcPortraitPanel (instanced)             # persistent face for split phases (hidden in pure dialogue)
├── DialoguePanel (instanced)                # full-screen VN
├── BrewPanel (instanced)                    # rack + slots, off-screen right at start
├── ValidationPanel (instanced)              # trash/serve/latte-art, off-screen right at start
├── LatteArtCanvas (CanvasLayer)
│   └── LatteArtPanel (instanced)            # full-screen stir, off-screen top at start
└── DebugLabel (Label, bottom-left, monospace)
```

## PHASES & TRANSITION CHOREOGRAPHY (the heart of this prototype)

Drive everything from a single phase enum in `level1.gd`. The transitions are the point — make them read clearly via `Tween` (position/anchor slides, ~0.35s, `EASE_OUT`/`TRANS_CUBIC`).

```
DIALOGUE   → full-screen DialoguePanel visible. NPC portrait + speech bubble. Click advances lines.
             On last line → start brew transition.

BREW       → DialoguePanel slides out (e.g. to the left / fades). NpcPortraitPanel takes/stays on
             one side. BrewPanel slides in from RIGHT → settles center-left (split layout).
             Player picks ≤3 ingredients into vessel slots, presses BREW.

VALIDATION → BrewPanel slides further LEFT (parks/exits left). ValidationPanel slides in from
             RIGHT → center. Shows result-name greybox + TRASH IT / SERVE IT / LATTE ART.
             NPC portrait stays visible.
               - TRASH IT  → discard, go back to BREW (rack slides back in).
               - SERVE IT  → finish (skip latte art), go to SERVE/loop.
               - LATTE ART → start latte-art transition.

LATTE_ART  → Full-screen LatteArtPanel slides in from TOP → DOWN, covering the whole screen
             (NOT split — full screen). Placeholder "stir" interaction increments a stir count;
             a SERVE button finishes.

SERVE      → Clear state, slide everything back, return to DIALOGUE (show a short "nice, next!"
             placeholder line). Loop.
```

Transition direction summary (must match this):
- DIALOGUE → BREW: brew panel enters **from RIGHT**, NPC remains; result is a **split** (NPC + rack).
- BREW → VALIDATION: brew panel exits **to LEFT**, validation enters **from RIGHT** (still split with NPC).
- VALIDATION → LATTE_ART: latte-art panel enters **from TOP**, **full screen** (covers the split).
- LATTE_ART → SERVE → DIALOGUE: panels slide back out; return to full-screen dialogue.

## PANEL LAYOUTS (greybox rects in design pixels — guides, tune for clean spacing)

All visible regions are `PlaceholderBox` instances (swappable to texture) unless noted.

**DialoguePanel (full-screen VN)**
- NPC portrait box — centered-ish or stage-left, ~`(700, 120)` size ~`(520, 720)`. Labeled "NPC".
- Speech bubble box — bottom strip, ~`(260, 820)` size ~`(1400, 200)`. Contains `Label` `dialog_label`, word-wrapped, placeholder text e.g. "Halo! Coba racik sesuatu yang ajaib buat aku ya." Click anywhere advances; a small ▼ indicator is fine.

**NpcPortraitPanel (persistent during split phases)**
- A portrait box pinned to one side (e.g. RIGHT, ~`(1480, 240)` size ~`(380, 600)`) labeled "NPC". Visible in BREW and VALIDATION, hidden in pure DIALOGUE and LATTE_ART.

**BrewPanel (rack + vessel, occupies center-left when settled)**
- Panel frame box, settled rect ~`(80, 120)` size ~`(1280, 840)`.
- **Ingredient rack** — a `GridContainer` (3 cols × 2 rows) of 6 ingredient source boxes (the 6 below). Picking one fills the next free vessel slot.
- **Vessel slots** — a row of **3** slot boxes labeled "1 / 2 / 3"; filled slots show the ingredient `id`. Tapping a filled slot clears it.
- **RESET button** — clears all vessel slots.
- **BREW button** — enabled only when ≥1 slot filled; triggers BREW → VALIDATION transition.
- (Optional, greybox only) decorative "meter" boxes (WARM/COOL/SWEET/BITTER style) to echo Coffee Talk — purely visual placeholders, no logic required.

**ValidationPanel (settles center)**
- Panel frame box, settled rect ~`(560, 200)` size ~`(820, 680)`.
- Result-name box — top, labeled with a placeholder result like "RAMUAN ???".
- Three buttons: **TRASH IT**, **SERVE IT**, **LATTE ART**.

**LatteArtPanel (full screen)**
- Full-rect frame box. A central "cup/vessel" greybox labeled "ADUK".
- **Rotary stir**: press inside the cup and **drag in circles**. Track the pointer's angle around the cup center and accumulate the total angular distance dragged; every full revolution (TAU) = one `stir_count`, capped at 5 (= "halus"). A **spoon indicator** follows the pointer around the rim and a **progress bar** fills smoothly. Direction-agnostic and forgiving, but taps/jitter barely register.
- A **SERVE** button to finish → SERVE phase.

**Background** — full-rect `PlaceholderBox` behind everything (bathroom wall+floor), greybox now, `@export texture` later.

**DebugLabel** — `Label` pinned bottom-left `(20, 1000)`, monospace, multiline.

## INGREDIENTS (data-driven so designers edit in the Inspector)

Create resource type **`scripts/systems/ingredient_def.gd`** (`extends Resource`, `class_name IngredientDef`):

```gdscript
@export var id: String            # e.g. "S"
@export var display_name: String  # e.g. "Sabun Batang"
@export var placeholder_color: Color  # box tint in greybox mode
@export var texture: Texture2D    # OPTIONAL art; null in prototype
```

Seed these 6 as an exported `Array[IngredientDef]` on `level1.gd` (or `brew_panel.gd`) so I can reorder/rename/add in the Inspector without touching code:

| id | display_name |
|----|--------------|
| S  | Sabun Batang |
| Sh | Shampoo      |
| P  | Pasta Gigi   |
| B  | Bedak Bayi   |
| M  | Daun Mint    |
| G  | Garam Mandi  |

(For the prototype, ignore unlock rules — show all 6. The rack is an infinite source; picking does not consume the rack slot.)

## INTERACTION MODEL (slot-based — NO gravity, NO physics)

- **Pick ingredient:** click (or click-drag) a rack box → it fills the next empty vessel slot (max 3). A 4th pick is rejected with a subtle red flash, no crash.
- **Clear a slot:** click a filled vessel slot → it empties.
- **RESET:** empties all vessel slots.
- **BREW:** only enabled with ≥1 ingredient; advances the phase.
- **Stir (latte-art):** hold and **drag in circles** around the cup; accumulated angular distance drives `stir_count` (1 revolution = 1 stir), capped at 5 (reads "halus"). No tap-to-stir.
- **Feedback:** valid action → brief green/scale pop; invalid (4th ingredient, BREW with empty vessel) → brief red flash/shake, no state change. Use `create_tween()`; no art needed.

There is **no falling, no clutter, no manual gravity** anywhere — that earlier model is dropped.

## SWAPPABILITY REQUIREMENT (this is the whole point of the prototype)

Every visible game object is a **self-contained, reskinnable node**. Build **`scenes/ui/placeholder_box.tscn`** + **`scripts/systems/placeholder_box.gd`** (`extends Control`, `class_name PlaceholderBox`), used for ALL static visuals (background, panel frames, NPC portrait, speech bubble, rack slots, vessel slots, result box, cup):

- `@export var display_name: String` — shown as a centered `Label`.
- `@export var texture: Texture2D` — when set, show it in a child `TextureRect` and hide the colored box; when null, show a `ColorRect` (greybox) plus the name Label.
- `@export var box_color: Color = Color(0.3, 0.3, 0.35)`.
- Clean public surface so swapping art later = drop a `Texture2D` into the export, zero code edits.

**The rule:** I must be able to turn any greybox into final art purely from the Inspector by assigning a texture. Do not bake names/colors into code paths that block this. Likewise, transitions must not assume any specific art size — they slide whatever the panel currently contains.

## STATE MACHINE

Single phase enum on `level1.gd`. Drive panel visibility, button enablement, and transitions off it; print it to the debug Label.

```
DIALOGUE     -> DialoguePanel full-screen; advancing lines; NPC portrait hidden as separate split element
BREW         -> BrewPanel settled center-left + NpcPortraitPanel visible (split); picking ingredients
VALIDATION   -> ValidationPanel settled center + NPC visible; awaiting trash/serve/latte-art
LATTE_ART    -> LatteArtPanel full-screen; stirring
SERVE        -> cleanup + return to DIALOGUE (loop)
```

- A phase change must (a) call the right `slide_out`/`slide_in` on the affected panels, and (b) only flip button enablement after the relevant tween, so the UI can't be double-triggered mid-transition (guard with an `is_transitioning` bool).

## DEBUG LABEL (always visible)

```
PHASE: <phase>
INGREDIENTS: [S, Sh, ...]  (count/3)
STIR: <n>/5  (halus=<true/false>)
TRANSITIONING: <true/false>
```

## CODE QUALITY

- Godot 4.6 GDScript, typed where practical, `@onready` for node refs.
- Keep scripts small and single-purpose: one script per panel sub-scene; `level1.gd` only orchestrates (state machine + which panel slides when). Panels own their own tweens via `slide_in`/`slide_out`.
- Comment the transition orchestration and the swappability export points clearly.
- No dependencies beyond core Godot + the existing project. Do NOT touch the Dialogic addon.
- Each panel sub-scene must also run standalone via **F6** without errors (guard for missing coordinator). The full `level1.tscn` must run standalone without errors.

## ACCEPTANCE CHECKLIST (verify before finishing)

- [ ] `level1.tscn` is a thin coordinator that **instances** the panel sub-scenes; panels are NOT flattened into it and NOT loaded via `change_scene_to_file`.
- [ ] Each panel sub-scene opens and runs standalone via F6 without errors.
- [ ] DIALOGUE → BREW: rack panel slides in **from the right** to center-left; NPC portrait stays visible (split).
- [ ] BREW → VALIDATION: rack panel slides **further left**; validation panel slides in **from the right** to center; NPC still visible.
- [ ] VALIDATION → LATTE_ART: latte-art panel slides in **from the top**, **full screen** (covers the split, not split itself).
- [ ] LATTE_ART → SERVE → DIALOGUE loops cleanly back to the full-screen dialogue.
- [ ] Ingredients are picked into ≤3 vessel slots (4th rejected); RESET clears; BREW enabled only with ≥1. No gravity/physics anywhere.
- [ ] Stir is rotary (drag in circles, not tap); accumulated rotations drive the count, caps at 5 ("halus"); spoon + progress bar track the motion.
- [ ] Every greybox is a `PlaceholderBox`; assigning a `texture` export swaps it to art with no code change (background, panel frames, NPC, speech bubble, rack slots, vessel slots, result box, cup).
- [ ] Ingredients are data-driven via an exported `Array[IngredientDef]`; editing them in the Inspector updates the rack.
- [ ] Buttons can't be double-triggered mid-transition (`is_transitioning` guard); Debug Label reflects phase, ingredients, stir count, and transition state live.
- [ ] No errors/warnings in the Godot output on run.
- [ ] Main menu "Mulai" button loads `level1.tscn` via `change_scene_to_file`; existing menu layout/other buttons untouched.

## MAIN MENU INTEGRATION (wire "Mulai" → crafting scene)

The existing main menu lives at `scenes/ui/main_menu/main_menu.tscn` with script `scenes/ui/main_menu/main_menu.gd`. It has a **"Mulai"** (Start) `Button` at node path `menu/PanelContainer/VBoxContainer/mulai` that is currently **not connected to anything** (only `pengaturan` and `keluar` have `pressed` signal connections).

Wire it up so pressing **Mulai** loads our crafting prototype directly:

1. Add a handler to `main_menu.gd`:
   ```gdscript
   func _on_mulai_pressed():
       get_tree().change_scene_to_file("res://scenes/chapters/level1.tscn")
   ```
2. Connect the `mulai` button's `pressed` signal to `_on_mulai_pressed` (add the `[connection ...]` line in `main_menu.tscn`, mirroring how `pengaturan`/`keluar` are connected).

Do NOT restructure or restyle the existing menu — only add this one signal connection + handler. Leave `pengaturan`, `kredit`, and `keluar` untouched (`kredit` is also currently unwired; ignore it).

Note: there is no save system yet, so "Mulai" and "Lanjutkan" are the same thing for now — just load the crafting scene.

## OUT OF SCOPE (do not build)

Scoring/tiers, customer reactions, Foam Memory reveal, audio, save system, multiple customers/phases, Dialogic integration, gravity/physics drag, real art/animation. Those come later.

(Note: wiring the main-menu "Mulai" button IS in scope — see Main Menu Integration. Only that one button connection; no other menu changes.)
