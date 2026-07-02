# MECHANICS_SPEC.md — Busa Fantasi
### Crafting & Game Mechanics Production Spec v1.0
> "Semua kombinasi valid. Tidak ada 'salah'. Yang ada cuma 'ideal', 'lumayan', 'eksperimental', atau 'absurd lucu'."

---

## Filosofi Mekanik

Crafting di Busa Fantasi mengikuti **3 aturan absolut**:

1. **NO FAIL STATE.** Tidak ada game over. Tidak ada retry. Setiap kombinasi tetap progress cerita.
2. **NO VISIBLE SCORE.** Tidak ada bintang, angka, atau bar. Pemain dapat feedback lewat **reaksi customer + dialog Pak Guyon**.
3. **EXPLORATION REWARDED.** Pemain yang eksperimen dapat reaksi unik (lucu/absurd). Pemain yang konservatif dapat reaksi standar.

Internal scoring **ada** untuk drive variasi reaksi, tapi **pemain tidak pernah lihat angka**.

---

## 1. Bahan (Ingredients) — 4 Dasar + 1 Special

### Bahan Dasar (Available dari Awal)

| Symbol | Nama | Tipe | Visual | Crafting Property |
|---|---|---|---|---|
| **S** | Sabun Batang | Padat | Putih, ukuran kepalan tangan | Tumbuk 3-5 klik → serpihan halus. Busa tebal stabil. |
| **Sh** | Shampoo | Cair (sachet) | Sachet Sunsilk hitam jadul | Tidak perlu tumbuk, langsung drag. Busa gelembung cepat. |
| **M** | Daun Mint Segar | Padat (organic) | Bunch daun hijau | Tumbuk 2-3 klik → halus. Aroma segar, busa tipis. |
| **B** | Bedak Bayi | Bubuk | Tin Marcks ungu | Tidak perlu tumbuk, langsung tabur. Busa lembut, calming. |

### Bahan Special (Unlocked Mid-Game)

| Symbol | Nama | Unlock Trigger | Crafting Property |
|---|---|---|---|
| **G** | Garam Mandi | **Pegawai Bayangan (Customer 4) leave as memento** di rak Pak Guyon saat exit | Kristal biru muda. Larut perlahan. Busa "dalam" — efek relaks + cleansing. |

**Alternative trigger (kalau team prefer):** Pak Guyon kasih garam mandi sebagai gift sebelum Mystery Child datang. *"Tunggu, ngger. Ada satu lagi yang gua simpen khusus."*

**Tim brainstorm besok:** decide trigger method, finalize nama (Garam Mandi atau alternative seperti Bunga Melati Kecil).

---

## 2. Alat (Tools) — Hanya 2

| Symbol | Nama | Function |
|---|---|---|
| **U** | Ulekan + Cobek | Tumbuk bahan padat (Sabun, Mint) |
| **PG** | Pak Guyon (Gayung) | Pour air + carry foam ke customer |

**Tidak ada:** sponge, wooden spoon, giant toothbrush, bucket. Hapus per Director's Cut.

---

## 3. Crafting Flow (Detailed)

### Per-Customer Crafting Interaction

```
[LISTEN PHASE] → [PREPARE PHASE] → [POUR PHASE] → [REVEAL PHASE]
   30-60 sec        60-90 sec         5-10 sec       5 sec
```

#### LISTEN PHASE (30-60 sec)

- Customer ngobrol problem mereka
- Pak Guyon sesekali ngomong (banter)
- **Player Agency:** Bisa click untuk advance dialog
- **NO INTERACTION** dengan bahan dulu — fokus dengar

#### PREPARE PHASE (60-90 sec)

Step-by-step interaction:

**Step 1 — Pick Bahan (5-10 sec)**
- Cursor hover bahan di rak → bahan slight glow + nama appear floating
- Click + drag bahan ke area ulekan
- Bahan masuk ke ulekan (animasi: drop in)
- **Max 3 bahan per ramuan**
- Player bisa drag bahan keluar ulekan kalau berubah pikiran (sebelum tumbuk)

**Step 2 — Tumbuk (Optional, 10-20 sec)**
- Hanya untuk bahan padat: Sabun (S), Mint (M)
- Click pada ulekan untuk tumbuk
- Visual: tangan + ulekan animation, particle keluar
- Audio: "TUK" satisfying per klik
- Setelah 3-5 klik → "halus" state achieved
- **Visual feedback:** bahan berubah dari chunk → granules → halus
- **Lebih banyak klik tidak menambah skor** (max stop di "halus")

**Step 3 — Toggle Suhu Air (Optional, 2 sec)**
- Icon kran kecil di samping ulekan
- Click toggle: ❄️ Dingin / 🔥 Panas / (default: neutral, no icon)
- Default: tidak menyalakan = air netral
- **TIDAK COUNTED di scoring** (cuma flavor visual + Pak Guyon dialog occasional)
- Effect visual: air biru muda (dingin) atau uap kecil (panas) saat dituang

**Step 4 — Drag Pak Guyon Untuk Pour Air (5 sec)**
- Cursor hover Pak Guyon → dia "wake up" alert
- Drag Pak Guyon ke ulekan
- Klik + hold untuk pour
- Visual: air mengalir dari mulut Pak Guyon ke ulekan
- Audio: water_pour SFX (sesuai panas/dingin/neutral)

**Step 5 — Mix dengan Pak Guyon (10-30 sec)**
- Cursor pegang Pak Guyon
- **Drag CIRCULAR gesture** untuk aduk
- Visual: Pak Guyon berputar di dalam ulekan, foam mulai muncul
- Audio: water sloshing + foam grow whoosh
- **Timing matters:** 
  - Terlalu cepat → foam tidak optimal (slight skor penalty)
  - Terlalu lama → foam pecah (slight skor penalty)
  - Pas 3-5 putaran → optimal
- Visual cue: foam pelan-pelan terbentuk → climax → mulai over-mix kalau diteruskan

**Step 6 — Foam Settle (auto, 2 sec)**
- Player release click
- Foam settles di Pak Guyon
- Pak Guyon "carries" foam
- Ready untuk pour ke customer

#### POUR PHASE (5-10 sec)

**Step 7 — Pour ke Customer**
- Drag Pak Guyon ke arah customer
- Klik + hold untuk pour foam
- Visual: foam mengalir ke customer
- Customer animation: receive foam (specific per character)

#### REVEAL PHASE (5 sec)

**Step 8 — Foam Memory Reveal (auto)**
- Music ducks 60%, ambient mute
- Bonang chime SFX
- Vignette dim 30%
- Foam membentuk siluet kenangan
- Hold 2.3 detik
- Siluet dissolve 1.1 detik
- Music + ambient kembali pelan

**Step 9 — Customer Reaction (15-30 sec)**
- Customer animation + dialog sesuai **tier reaction**
- Pak Guyon dialog mengkomentari pilihan player
- Customer exit
- Pak Guyon brief reflection

---

## 4. Internal Scoring System (Hidden from Player)

### Komponen Skor (Total 100 points)

| Komponen | Bobot | Detail |
|---|---|---|
| **Bahan Match** | 70% | Berapa bahan dari resep ideal customer yang dipakai |
| **Bahan Bonus** | 10% | Bahan yang aligned dengan tema customer (bukan ideal tapi cocok) |
| **Mix Technique** | 15% | Tumbuk + aduk timing |
| **No Wrong Excess** | 5% | Tidak menambah bahan random |

**Suhu air: TIDAK COUNTED.** Cuma flavor.

### Rumus Bahan Match (70%)

```
Score = (Bahan Ideal yang Dipakai / Total Bahan Ideal di Resep) × 70

Contoh resep ideal Customer 1: S + Sh (2 bahan)
- Player pakai S + Sh           → 70 (100% match)
- Player pakai S saja           → 35 (50% match)
- Player pakai Sh saja          → 35 (50% match)
- Player pakai S + Sh + M       → 70 (100% match, M = ekstra)
- Player pakai M + B            → 0 (0% match)
```

### Rumus Bahan Bonus (10%)

Beberapa bahan punya "tema cocok" walau bukan ideal. Misal:
- Mint cocok untuk Ksatria Naga, Bocah Lumpur (segar)
- Bedak cocok untuk Pegawai Bayangan, Monster Debu (calming)
- Sabun universal cocok untuk semua

```
Jika bahan tidak di resep ideal tapi tema cocok → +5 per bahan
Max bonus: 10 points
```

### Rumus Mix Technique (15%)

```
Tumbuk technique: +7 (pas 3-5 klik), +3 (kurang), +5 (kelebihan)
Aduk technique:   +8 (pas 3-5 putaran), +4 (kurang), +5 (kelebihan)
Total max: 15 points
```

### Rumus Wrong Excess Penalty (5%)

```
Bahan random yang TIDAK cocok dengan tema customer:
- 0 bahan random: +5
- 1 bahan random: +2
- 2 bahan random: 0
- 3 bahan random (semua salah): -5
```

### Konversi ke Reaction Tier

| Total Internal Score | Tier | Hidden Name |
|---|---|---|
| 85-100 | **Tier 1** | EXCELLENT |
| 65-84 | **Tier 2** | GOOD |
| 45-64 | **Tier 3** | OK |
| 25-44 | **Tier 4** | SURPRISED |
| 0-24 | **Tier 5** | CONFUSED |

**Player tidak pernah lihat angka ini.** Dia hanya lihat reaksi customer + dialog Pak Guyon.

---

## 5. Reaction Tier — Player-Facing Behavior

### Tier 1 — EXCELLENT (85-100)

**Customer Animation:**
- Big smile / wide grin / bounce / spin (sesuai personality)
- Particle effect: sparkle warm yellow
- Hold pose 3 detik before exit

**Pak Guyon Dialog (random pick dari pool):**
- *"Pas banget pilihan lo, ngger!"*
- *"Mantep. Itu yang dia butuhin."*
- *"Hahaha, lo bakat juga ya."*

**Customer Final Dialog (per character, custom):**
- Bocah Lumpur: *"AHHHH! Segeeer! Makasih ya, om!"*
- Ksatria Naga: *"BERKAT KAMU, AKU SIAP MENGHADAPI NAGA TERHEBAT!"*
- Monster Debu: *"...mmh. Nyaman. Aku bisa tidur sekarang."*
- Pegawai Bayangan: *"...gua udah lupa kalau bisa seseneng ini. Makasih."*

**Foam Memory Reveal:** Full quality, 2.3 detik hold, glow extra

### Tier 2 — GOOD (65-84)

**Customer Animation:**
- Smile, satisfied nod
- Subtle bounce
- Standard exit

**Pak Guyon Dialog:**
- *"Bagus, ngger."*
- *"Yo, dia seneng tuh."*
- *"Nice."*

**Customer Dialog:** Versi normal "puas tapi tidak overflowing."

**Foam Memory Reveal:** Normal quality

### Tier 3 — OK (45-64)

**Customer Animation:**
- Gentle smile, slight nod
- "Cukup" feeling
- Standard exit

**Pak Guyon Dialog:**
- *"Lumayan, ya."*
- *"Boleh juga."*
- *"Cukup, lah."*

**Customer Dialog:** *"...Hmm. Lumayan, om. Makasih."*

**Foam Memory Reveal:** Normal quality

### Tier 4 — SURPRISED (25-44)

**Customer Animation:**
- Confused face, then surprise → light laugh
- "Eh, kok... eh, jalan juga ya"
- Standard exit

**Pak Guyon Dialog (humor-leaning):**
- *"Wah, eksperimental ya lo. Tapi jalan juga kok."*
- *"Hmm. Original. Pertama kali liat yang kayak gini."*
- *"Hahaha. Anak kreatif emang."*

**Customer Dialog:** *"...okay, ini... aneh tapi enak. Mungkin?"*

**Foam Memory Reveal:** Quality bagus tetap (siluet tidak diturunkan)

### Tier 5 — CONFUSED (0-24)

**Customer Animation:**
- Bingung face, head tilt, hesitant smile
- "Erm... ya udah, makasih"
- Standard exit (gak ada hukuman visual)

**Pak Guyon Dialog (lebih humor):**
- *"...nak. Lo niat banget ya bikin yang absurd."*
- *"Hahaha. Yah, kreatif lah. Customer berikutnya kita coba lebih pas?"*
- *"Wah, gua sampe bingung itu apaan. Tapi dia tetep ambil."*

**Customer Dialog:** *"...err... yauda, makasih?"* (forced smile)

**Foam Memory Reveal:** **TETAP MUNCUL.** Quality sama. (No punishment di moment penting.)

**Penting:** Tier 5 **TIDAK** = game over. Cerita TETAP lanjut. Cuma dialog lebih komedi.

### Pak Guyon Hint System

Kalau player dapat Tier 4 atau Tier 5 **berturut-turut untuk customer yang sama atau 2 customer berbeda**, di customer berikutnya Pak Guyon kasih hint halus:

> *"Eh, ngger. Coba dengerin baik-baik apa yang dia bilang ya. Kadang clue-nya ada di dialog."*

Hint TIDAK diberikan langsung. Pemain tetap harus deduce. Pak Guyon cuma reminder untuk listen carefully.

---

## 6. Ideal Recipe per Customer

**PLACEHOLDER customer names — finalize di brainstorm tim besok.**

### Customer 1 — Bocah Lumpur (Joy)

**Tema:** Banyak gelembung, segar, energi anak

**Ideal Recipe:** S + Sh (Cloud Foam)

**Theme-matching bahan (bonus):** M (mint segar)

**Anti-tema bahan:** B (terlalu calming untuk anak yang excited)

**Resep alternatif yang dapat Tier 1/2:**
- S + Sh + M → Cloud Foam Premium (Tier 1)
- S + Sh → Cloud Foam (Tier 1)
- Sh + M → Sparkling Mint (Tier 2)
- S saja → Crystal Foam (Tier 3)
- Sh + B → Soft Bubbles (Tier 3-4, cocok ya tapi gak matching joy tone)
- B saja → Soft Powder (Tier 4-5, terlalu calming)

**Dialog clue (hint untuk player):**
- *"Aku mau yang banyak gelembungnyaaa! Buat main!"*
- *"Yang segeeeer, biar aku gak ngantuk lagi!"*

**Foam memory siluet:** Anak melompat di genangan air, tangan ke atas

---

### Customer 2 — Ksatria Naga (Confidence)

**Tema:** Segar tajam, percaya diri, fresh

**Ideal Recipe:** S + M (Mint Crystal)

**Theme-matching bahan (bonus):** Sh (untuk gelembung sparkle)

**Anti-tema bahan:** B (terlalu lembut)

**Resep alternatif:**
- S + M + Sh → Mint Cloud Premium (Tier 1)
- S + M → Mint Crystal (Tier 1)
- M saja → Fresh Leaf (Tier 2)
- S + B → Hug Crystal (Tier 4, calming bukan confidence)
- Sh + B → Soft Bubbles (Tier 4)

**Dialog clue:**
- *"Aku harus berani lawan naga! Butuh yang minty, biar nafasku fresh!"*
- *"Yang menyegarkan! Yang bikin dada terasa lapang!"*

**Foam memory siluet:** Anak dengan handuk di pundak, pose ksatria, ekspresi PD

---

### Customer 3 — Monster Debu (Anger → Calm)

**Tema:** Cleansing, calming setelah grumpy

**Ideal Recipe:** S + B (Hug Crystal) atau M + B (Gentle Breeze)

**Theme-matching bahan (bonus):** G (saat sudah unlock) — perfect untuk cleansing deep

**Anti-tema bahan:** Sh (gelembung berlebihan = annoying untuk yang grumpy)

**Resep alternatif:**
- S + B + M → Gentle Crystal (Tier 1)
- S + B → Hug Crystal (Tier 1)
- M + B → Gentle Breeze (Tier 1)
- S + M → Mint Crystal (Tier 3, segar tapi gak calming)
- Sh + apapun → Tier 4 (terlalu energetik untuk grumpy creature)

**Dialog clue:**
- *"GRR! Debu ini bikin gatel! Mau yang lembut tapi bersih..."*
- *"Yang lembut. Yang bikin tenang. Aku capek marah."*

**Foam memory siluet:** Anak meringkuk di tempat tidur, selimut hangat, lampu malam

---

### Customer 4 — Pegawai Bayangan (Burnout)

**Tema:** Comfort, warm, deep relaxation

**Ideal Recipe:** S + B (Hug Crystal) atau S + Sh + B (Comfort Cloud)

**Theme-matching bahan (bonus):** G (saat unlock — perfect comfort) — TAPI Garam diberikan SETELAH Pegawai Bayangan exit, jadi tidak available untuk dia

**Anti-tema bahan:** M (terlalu sharp untuk yang lelah)

**Resep alternatif:**
- S + Sh + B → Comfort Cloud (Tier 1)
- S + B → Hug Crystal (Tier 1)
- B saja → Soft Powder (Tier 2, lembut tapi kurang substansi)
- M + apapun → Tier 4 (terlalu segar untuk yang capek)

**Dialog clue:**
- *"...capek banget. Mau yang... hangat. Yang kayak dipeluk."*
- *"Yang lembut. Yang gak ribet. Tolong ya, om."*

**Foam memory siluet:** Anak duduk di kursi plastik, main busa di ember, tertawa kecil

**SPECIAL EVENT setelah Pegawai Bayangan exit:** Pegawai leave Garam Mandi sebagai memento di rak. Pak Guyon notice. *"Lho, dia ninggalin sesuatu. Garam mandi... mahal nih, ngger. Simpen aja dulu."* — UNLOCK Garam Mandi untuk Mystery Child.

---

### Customer 5 — Mystery Child (Self Acceptance)

**Tema:** ALL ELEMENTS — segar, gelembung, lembut, cleansing, warm

**Ideal Recipe:** S + Sh + M + B + G (all 5 — Morning Breeze)

**Theme-matching:** SEMUA bahan cocok

**Anti-tema:** TIDAK ADA — Mystery Child accept apapun karena tema self-acceptance

**Resep alternatif (semua DAPAT Tier 1 atau 2):**
- All 5 → Morning Breeze Premium (Tier 1, ultimate ending)
- 4 dari 5 → Morning Glow (Tier 2, ending bagus)
- 3 dari 5 → Balanced Foam (Tier 2, ending sweet)
- 2 dari 5 → Cozy Foam (Tier 3, ending OK)
- 1 dari 5 atau random → Simple Foam (Tier 3-4, ending bittersweet warm)

**CRITICAL DESIGN RULE:** Mystery Child **TIDAK PERNAH** dapat Tier 5 (Confused). Minimum dia dapat Tier 3 (OK). Karena tema self-acceptance — bahkan ramuan terburuk tetap dia terima dengan senyum.

**Customer dialog hint:**
- *"Aku... cuma mau yang lengkap. Yang mewakili semuanya."*
- *"Apapun yang kamu pilih, aku terima."*

**Foam memory siluet:** Anak kecil dan dewasa SAMA-SAMA main busa di ember, ketawa bareng (the warm closure moment)

---

## 7. Foam Visual Variation

Setiap kombinasi punya **visual signature** yang berbeda. Felicia + Gio bikin 12-15 variant foam sprite.

### Kombinasi Tunggal (1 bahan)

| Bahan | Nama Foam | Warna Dominan | Karakter Visual |
|---|---|---|---|
| S | Crystal Foam | Putih cream | Bulky, stable, rounded bubbles |
| Sh | Quick Bubbles | Putih translucent | Banyak gelembung kecil, cepat hilang |
| M | Fresh Leaf | Putih dengan partikel hijau | Tipis, ada daun mint floating |
| B | Soft Powder | Pink-cream lembut | Halus, downy, hampir tidak bergelembung |
| G (special) | Salt Wave | Biru muda | Dalam, undulating motion, garam kristal sparkle |

### Kombinasi 2 Bahan

| Combo | Nama | Visual |
|---|---|---|
| S + Sh | Cloud Foam | Putih banyak gelembung, bouncy |
| S + M | Mint Crystal | Putih dengan green tinge + partikel daun |
| S + B | Hug Crystal | Cream pink-ish, soft + stable |
| Sh + M | Sparkling Mint | Translucent banyak gelembung kecil + green sparkle |
| Sh + B | Soft Bubbles | Translucent dengan pink hue, gentle |
| M + B | Gentle Breeze | Light green + pink-ish, calming |

### Kombinasi 3 Bahan (Premium for Customers)

| Combo | Nama | Visual |
|---|---|---|
| S + Sh + M | **Cloud Foam Premium** | Putih bouncy + green sparkle (BOCAH LUMPUR ★) |
| S + M + B | Gentle Crystal | Putih cream + hint green, soft |
| S + Sh + B | **Comfort Cloud** | Putih creamy + pink-soft hue (PEGAWAI ★) |
| Sh + M + B | Cool Cloud | Translucent + green + pink |

### Kombinasi 4+ Bahan (Final/Mystery Child)

| Combo | Nama | Visual |
|---|---|---|
| S + Sh + M + B | Morning Glow | Gradient putih→green→pink, mild sparkle |
| All 5 (with G) | **Morning Breeze** | Gradient lembut semua warna + ekstra light particle (THE ULTIMATE) |

### Foam Visual Quality per Tier

- **Tier 1:** Foam visual penuh, glow extra, particle ekstra
- **Tier 2:** Foam visual normal, kualitas standar
- **Tier 3:** Foam visual sedikit kurang stable, masih terlihat OK
- **Tier 4:** Foam visual unik/aneh tapi tidak ugly (warna mix sedikit weird)
- **Tier 5:** Foam visual messy/lumpy, comedy-look (tapi bukan disgusting)

---

## 8. Suhu Air System (Toggle, Simple)

### UI Implementation

- Icon kran kecil di samping ulekan (40×40 px)
- Default state: tidak menyala (air netral)
- Click toggle cycle: Netral → Dingin → Panas → Netral
- Visual feedback saat pour:
  - Netral: air jernih biasa
  - Dingin: tint biru muda + slight glow + droplet partikel
  - Panas: tint kuning hangat + uap kecil

### Effect (Flavor Only, NOT Scoring)

| Suhu | Visual Effect on Foam | Pak Guyon Occasional Comment |
|---|---|---|
| Netral | Standard | (nothing) |
| Dingin | Foam slightly more sparkle | *"Air anget enak juga sebenernya buat dia."* (kalau customer comfort) |
| Panas | Foam slightly more steamy | *"Wah, air panas. Hati-hati ya, ngger."* |

**Catatan:** Suhu air **TIDAK** affect tier/scoring. Pemain bebas pilih. Cuma flavor visual + dialog occasional.

---

## 9. Special Easter Egg Combinations

Beberapa kombinasi punya **hidden reaction** yang lucu — buat reward eksperimentasi.

### "Bedak Saja" (Solo B untuk customer apapun)

Pak Guyon: *"Cuma bedak doang? Lo niat banget bikin bayi ini, ya."* (chuckle)

### "Mint + Mint + Mint" (Mint dipilih 3x)

Pak Guyon: *"Mint mulu. Lo pencinta dingin ya, ngger? Atau lo punya saham di pabrik permen?"*

### "Sabun + Sabun + Sabun" (Sabun dipilih 3x)

Pak Guyon: *"Sabun overload. Tapi yang clean banget kayak gini... lucu juga, sih."*

### "All 4 bahan dasar untuk Customer 1" (Cloud Foam Premium overkill)

Pak Guyon: *"Lo masukin semua? Hahaha, ngger. Tapi gak salah juga sih."* (Tier 1 tetap)

### "Garam Mandi sebelum unlock" (Impossible — but if dev bug allows)

(N/A, garam tidak accessible sebelum unlock)

---

## 10. Save Point Logic

Auto-save setelah:
1. End of Phase 3 (First meeting Pak Guyon)
2. End of Customer 1
3. End of Customer 2
4. End of Customer 3
5. End of Customer 4 (BEFORE Garam Mandi unlock + Mystery Child)

**Mystery Child scene + ending TIDAK ada save di tengah** — harus dimainkan dalam 1 sitting (~5 menit).

Save data per slot:
- Current scene/customer index
- Reaction tier hasil customer-customer sebelumnya (untuk trigger Pak Guyon hint atau bukan)
- Garam Mandi unlock status

---

## 11. Engineering Implementation Notes

### Untuk Andhika (Lead Programmer)

- **State machine** per scene: SCENE_INTRO → DIALOG_LISTEN → CRAFTING → POUR → REVEAL → REACTION → EXIT → REFLECTION
- **Crafting state:** ULEKAN_EMPTY → BAHAN_ADDED → TUMBUK → WATER_ADDED → MIXING → READY_TO_POUR
- **Internal scoring:** calculated AFTER pour, stored in customer_result struct
- **Tier mapping:** simple if-elif based on score range
- **Hint system trigger:** cek last 2 customer tiers, if avg <50% → trigger hint dialog di customer berikutnya

### Untuk Aldi (Gameplay Programmer)

- **Drag-and-drop bahan:** standard mouse drag with snap target (ulekan)
- **Tumbuk:** click counter, max 5 clicks → state "halus"
- **Aduk gesture:** detect circular mouse movement (calculate angular displacement)
- **Pour:** click-and-hold, drain animation, duration affects pour amount (not scoring, flavor)

### Untuk Nazril (FX Programmer)

- **Foam particle:** 12-15 sprite variants (per combination)
- **Foam grow animation:** 8-frame loop per variant
- **Bubble pop SFX:** randomize per variant
- **Foam Memory reveal sequence:** 4 SFX in 3.8s window (per Audio Bible)
- **Vignette + music duck:** trigger on foam memory reveal

---

## 12. QA Test Cases (Untuk Rafli)

Critical bugs untuk dicheck:

- [ ] Tier 5 reaction **TIDAK** trigger game over / retry screen
- [ ] Mystery Child **TIDAK PERNAH** dapat Tier 5 (minimum Tier 3)
- [ ] Garam Mandi **TIDAK** appear di rak sebelum Customer 4 exit
- [ ] Suhu air toggle TIDAK affect internal score
- [ ] Foam memory reveal MUNCUL di semua tier (1-5)
- [ ] Pak Guyon hint dialog trigger correctly setelah 2x low-tier consecutive
- [ ] Save/load preserves reaction tier history
- [ ] 4-bahan dipilih (max+1) tetap bisa = bahan tertua di-replace? Atau tidak boleh? **Decision needed.**
  - **REKOMENDASI:** Max 3 bahan strict, klik bahan ke-4 → bunyi "nope" subtle + no action

### Edge Cases

- Apa yang terjadi kalau player pour TANPA bahan apapun (cuma air)?
  - **Answer:** Foam tetap muncul minimal (air saja = busa transparan), Tier 5 reaction, Pak Guyon comment lucu: *"Cuma air? Yo udah, dia tetep nerima sih."*

- Apa yang terjadi kalau player pour sebelum mix (langsung tuang setelah add bahan)?
  - **Answer:** Foam tidak optimal, Tier 4-5, Pak Guyon: *"Lo lupa aduk, ngger. Tapi yowis, jalan juga kok."*

- Apa yang terjadi kalau player skip tumbuk untuk bahan padat?
  - **Answer:** Foam ada chunks (visual gritty), Tier 3-4, Pak Guyon: *"Sabun belum lembut tuh. Tapi customer keras juga, jadi gapapa."*

---

## 13. Final Lock Summary

**Aturan yang harus tim hormati DAY 1 onwards:**

1. ✅ **4 bahan dasar + 1 special unlock** (S, Sh, M, B + G)
2. ✅ **Max 3 bahan per ramuan**
3. ✅ **No fail state** — semua tier tetap progress cerita
4. ✅ **Hidden internal scoring** — pemain tidak lihat angka
5. ✅ **5 reaction tiers** dengan dialog Pak Guyon + customer unik
6. ✅ **Suhu air toggle simple, tidak counted scoring**
7. ✅ **Mystery Child minimum Tier 3** — never confused
8. ✅ **Pak Guyon hint system** trigger kalau 2x low-tier
9. ✅ **Foam memory reveal** tampil di semua tier
10. ✅ **Auto-save** di 5 titik

**Lock di standup besok. Setelah itu, jangan dibuka diskusi lagi.**

---

> *"Cozy crafting bukan tentang menemukan resep yang benar. Tentang menemukan kombinasi yang membuatmu tertawa."*
