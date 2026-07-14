# Label OCR Mapper — Flutter Specification Document

## 1. Project Purpose

**Label OCR Mapper** is a mobile-first application that enables users to photograph product labels, automatically detect text regions using Google ML Kit OCR, and map each detected text block to structured API fields (e.g., `product.name`, `product.ean`, `product.batch`). The app supports creating reusable **templates** — predefined field layouts tied to specific label types (dairy products, canned goods, cosmetics, etc.) — so that repeated scanning of similar labels becomes a fast one-tap operation.

### Core User Journeys

1. **Scan & Extract**: Open camera → photograph a label → OCR detects text regions → user reviews extracted data → send/export results.
2. **Template Management**: Create/edit templates by uploading a reference label image, defining field positions via coordinate-based mapping, and associating each position with an API field name.

### Target Platforms

- Android (primary)
- iOS (secondary)

---

## 2. Tech Stack & Dependencies

| Layer             | Technology                                                                                                         |
| ----------------- | ------------------------------------------------------------------------------------------------------------------ |
| Framework         | Flutter 3.x (Dart)                                                                                                 |
| State Management  | `riverpod` or `provider` (choose one, document choice)                                                             |
| Navigation        | `go_router`                                                                                                        |
| OCR Engine        | Google ML Kit Text Recognition (`google_mlkit_text_recognition`)                                                   |
| Camera            | `camera` package + native camera intent via `image_picker` with `CameraDevice.rear` for direct rear-camera capture |
| Local Storage     | `sqflite` (SQLite) or `hive` — must persist templates, scans, and captured images                                  |
| Image Persistence | File system (`path_provider` for app data directory)                                                               |
| Icons             | `lucide_icons` (or equivalent Flutter icon set matching the original design)                                       |

---

## 3. Data Models

### Template

```dart
class Template {
  final int id;
  final String name;
  final String description;
  final String labelPhotoPath; // path to reference image on disk
  final String icon;           // emoji string, e.g. "🥛"
  final int fieldsCount;
  final String lastUsed;       // human-readable date string
  final Color color;           // background tint for icon area
  final Color accent;          // primary action color
  final List<TemplateField> fields;
}

class TemplateField {
  final int id;
  final String apiField;       // e.g. "product.name"
  final double x;              // normalized X coordinate (0–1 or pixel-based)
  final double y;              // normalized Y coordinate (0–1 or pixel-based)
  final double confidence;     // OCR confidence score for this field (0–100)
}
```

### Scan Record

```dart
class ScanRecord {
  final int id;
  final int? templateId;       // nullable — scans can be standalone
  final String ocrText;        // raw full-text OCR output
  final double confidence;     // average confidence across all detected regions
  final String? imagePath;     // path to captured image on disk
  final String metadataJson;   // JSON string of structured field mappings
  final DateTime createdAt;
}
```

### Detected Text Region (from ML Kit)

```dart
class DetectedTextRegion {
  final int id;                // unique local ID for UI tracking
  final String text;           // recognized text content
  final double confidence;     // OCR confidence percentage (0–100)
  final Rect boundingBox;      // pixel coordinates in the captured image
}
```

### API Field Enum / Constants

```dart
const List<String> API_FIELDS = [
  '-- Sélectionner --',
  'product.name',
  'product.sku',
  'product.ean',
  'product.batch',
  'product.expiry_date',
  'product.weight',
  'product.origin',
  'product.manufacturer',
  'product.category',
];
```

---

## 4. Application Screens & Navigation Flow

### 4.1 Screen Overview

| Route                      | Screen Name                  | Description                                                       |
| -------------------------- | ---------------------------- | ----------------------------------------------------------------- |
| `/`                        | TemplateListScreen           | Home screen showing all saved templates as cards with stats strip |
| `/templates/new`           | TemplateScreen (create mode) | Create a new template from scratch                                |
| `/templates/:id/configure` | TemplateScreen (edit mode)   | Edit an existing template's fields and mappings                   |
| `/scan`                    | ScanScreen                   | Capture photo, run OCR, review extracted data                     |

### 4.2 Global Layout Structure

Every screen shares the same outer shell:

```
┌──────────────────────────────┐
│   Navbar (64px fixed height) │  ← bg-[#111218], full width
├──────────────────────────────┤
│                              │
│   Screen Content             │  ← fills remaining viewport, scrollable
│   (flex-1, overflow-y:auto)  │
│                              │
└──────────────────────────────┘
```

The root container uses:

- Background color: `--background` (#F2F2EE light / oklch(0.145 0 0) dark)
- Text color: `--foreground` (#111218 light / oklch(0.985 0 0) dark)
- Font family: DM Sans (body), JetBrains Mono (monospace labels/coordinates)

---

### 4.3 Navbar Component

**Dimensions**: Full width, 64px height, fixed at top of viewport.

**Background**: Solid `#111218` (near-black).

**Layout**: Horizontal flex row with `space-between`.

#### Left Side

- **Back button** (visible on all screens except template-list):
    - Icon: ArrowLeft, 18px, color `white/60`
    - Padding: `p-1`, negative left margin `-ml-1` for tighter alignment
    - On press: navigate back via router

- **Title block** (always visible):
    - Subtitle: "Label Scanner" — 10px font, uppercase, tracking-widest, color `white/50`, JetBrains Mono
    - Title: Dynamic label from route name ("Mes Templates", "Nouveau template", "Configuration du template", "Scanner une étiquette") — 14px (text-sm), semibold, white, DM Sans

#### Right Side

- **"Nouveau" button** (only on template-list screen):
    - Layout: Horizontal flex row with Plus icon + text
    - Icon: Plus, 12px
    - Text: "Nouveau", 12px font, semibold
    - Background: `--primary` (#0047CC), text: white
    - Padding: `px-3 py-1.5`, border-radius: `calc(var(--radius) - 4px)` (~8px)
    - On press: navigate to `/templates/new`

---

### 4.4 TemplateListScreen (Home Screen)

**Layout**: Full-height scrollable column with a fixed stats strip at the top and a floating "create new" button at the bottom.

#### Stats Strip

- **Position**: Top of screen, below navbar, full width
- **Background**: `--card` (#FFFFFF light / dark mode card color)
- **Border-bottom**: 1px solid `--border` (rgba(17,18,24,0.12))
- **Padding**: Horizontal 16px, vertical 10px
- **Layout**: Horizontal flex row with items centered vertically

**Stats Items** (two items separated by gap):

1. **Templates count**:
    - Icon: LayersIcon, 11px, color `--muted-foreground` (#6B6B72)
    - Label: "{count} templates" — 10px font, `--muted-foreground`, monospace
    - The numeric count is rendered in `--foreground` with medium weight

2. **Scans this month**:
    - Icon: PackageSearch, 11px, color `--muted-foreground`
    - Label: "312 scans ce mois" — same styling as templates count
    - The numeric value is bold/medium in `--foreground`

#### Template Cards List

- **Container**: Scrollable area with hidden scrollbar (`scrollbar-width: none`)
- **Padding**: Horizontal 16px, top 12px, bottom 16px
- **Gap between cards**: 8px (gap-2)

**Each card structure**:

```
┌───────────────────────────────┐
│ [Icon] Name        X champs   │  ← Card header row
│       Description              │
│ ───────────────────────────── │  ← Border-top separator
│ 🏷️ Last used    ⚙️  ▶ Scan   │  ← Card footer actions
└───────────────────────────────┘
```

**Card Header Row**:

- **Background**: `--card` (#FFFFFF)
- **Border**: 1px solid `--border`, border-radius: 2px (rounded-sm)
- **Padding**: Horizontal 12px, vertical 12px
- **Layout**: Horizontal flex row

**Icon area**:

- Dimensions: 36×36px (w-9 h-9), border-radius: 2px
- Background: Template-specific `color` (#E8F0FE for dairy, #FEF3E8 for canned goods, etc.)
- Content: Emoji string centered, font-size ~18px

**Name & Description**:

- Name: 14px (text-sm), semibold, `--foreground`, single-line truncated with ellipsis
- Description: 10px font, `--muted-foreground`, single-line truncated

**Fields count badge**:

- Font-size: 9px, medium weight, monospace
- Background: Template-specific `accent` color
- Text color: Computed for contrast (typically white)
- Padding: Horizontal 6px, vertical 2px, border-radius: 2px
- Text format: "{count} champs"

**Card Footer Row**:

- **Separator**: Top border 1px solid `--border`
- **Layout**: Horizontal flex row with two sections separated by a left border on the right section

**Left section (last used)**:

- Padding: Horizontal 12px, vertical 8px
- Icon: TagIcon, 9px, `--muted-foreground`, shrink-0
- Text: Last-used timestamp like "Aujourd'hui, 09:14" — 9px font, `--muted-foreground`, monospace

**Right section (action buttons)**:

- **Border-left**: 1px solid `--border` to separate from left section
- **Layout**: Horizontal flex row with two buttons separated by a vertical divider
- **Divider between buttons**: 1px solid `--border`

**Settings button** (left of the action pair):

- Layout: Horizontal flex row with SettingsIcon + invisible text area
- Icon: SettingsIcon, 13px, `--foreground`
- Text color on hover: `--muted-foreground`, background on hover: `--muted/50`
- Padding: Horizontal 16px, vertical 8px
- On press: navigate to `/templates/{id}/configure`

**Scan button** (right of the action pair):

- Background: Template-specific `accent` color
- Icon: ScanLine, 13px, white
- Text color on hover: `--muted-foreground`, background on hover: `--muted/50`
- Padding: Horizontal 16px, vertical 8px
- On press: navigate to `/scan`

#### Create New Template Button (Bottom)

- **Position**: Bottom of scrollable area, full width
- **Padding**: Horizontal 16px, bottom 24px
- **Style**: Dashed border (`border-dashed`), `--border` color, 2px width
- Border-radius: 2px
- Layout: Horizontal flex row centered with Plus icon + text
- Icon: Plus, 14px
- Text: "Créer un nouveau template", 14px font, `--muted-foreground`
- On press: navigate to `/templates/new`

---

### 4.5 TemplateScreen (Create / Edit)

**Layout**: Full-height scrollable column with a fixed bottom save bar.

#### Title & Description Section

- **Padding**: Horizontal 16px, top 16px, bottom 8px
- **Gap between rows**: 12px

**Icon & Title Row**:

- Label: "Icône & Titre" — 10px font, uppercase, tracking-widest, `--muted-foreground`, monospace
- Layout: Horizontal flex row with gap of 8px
    - **EmojiPicker button**: 36×36px square, border-radius: 2px, border 1px solid `--border`, background `--card`
        - Content: Current emoji value (default "😀"), centered, font-size ~16px
        - On press: toggle emoji picker dropdown
    - **Name input**:
        - Background: `--card`, border 1px solid `--border`, border-radius: 2px
        - Padding: Horizontal 12px, vertical 8px
        - Font-size: 14px (text-sm), DM Sans
        - Placeholder: "Nom de l'étiquette…", color `--muted-foreground`
        - Focus ring: 1px solid `--ring` (#0047CC)

**Description Row**:

- Label: "Description" — same style as above label
- **Textarea**:
    - Background: `--card`, border 1px solid `--border`, border-radius: 2px
    - Padding: Horizontal 12px, vertical 8px
    - Rows: 2 (fixed height)
    - Font-size: 14px, DM Sans, resize: none
    - Placeholder styling same as name input

#### Reference Label Image Zone

- **Padding**: Horizontal 16px, top 8px, bottom 8px
- **Label**: "Étiquette de référence" — 10px font, uppercase, tracking-widest, `--muted-foreground`, monospace

**Image container**:

- Width: full width
- Border: 2px dashed `--border`
- Border-radius: 2px
- Min-height: 144px (min-h-36)
- Overflow: hidden

**When image is loaded**:

- **Layout**: Relative positioned container, min-height 144px
- **Image**: Full width, full height, `object-fit: contain`
- **Overlay boxes**: Semi-transparent rectangles with primary color border and 15% opacity fill, positioned absolutely based on field coordinates
    - Each box has a label badge at the top-left corner showing the API field name (7px font, white text on primary background)
- **"Changer" button**: Absolute positioned at top-right, semi-transparent dark background (`#111218` with 80% opacity), white text, 9px font — replaces the image
- **Detection badge**: Absolute positioned at bottom-right, same semi-transparent dark background, shows "N zones détectées" with a Zap icon

**When no image is loaded (empty state)**:

- Layout: Centered vertically and horizontally within container
- Icon circle: 40×40px, border-radius: 50%, `--muted` background, ImagePlus icon centered at 18px
- Title text: "Photographier une étiquette", 14px font, `--foreground`
- Subtitle: "L'OCR détectera automatiquement les textes", 10px font, `--muted-foreground`, centered
- On press (entire area): opens file picker / camera

#### Detected Texts → API Fields Mapping Section

- **Section divider**: Horizontal flex row with label + line + count badge
    - Label: "Textes détectés → Champs API" — 10px font, uppercase, tracking-widest, `--muted-foreground`, monospace
    - Divider line: Full remaining width, 1px solid `--border`
    - Count badge: "{count}" — 9px font, `--muted-foreground`, `--muted` background, border-radius: 2px

**Mapping rows**: One row per template field.

Each mapping card structure:

```
┌───────────────────────────────┐
│ Texte détected    [Conf%]     │  ← Header with confidence pill
│ 🔍 Detected text...           │
│ x: 42 / y: 18                │
│ ───────────────────────────── │
│ Champ API                    │
│ [Dropdown ▼]                 │
└───────────────────────────────┘
```

**Card structure**:

- Background: `--card`
- Border: 1px solid `--border`, border-radius: 2px
- Overflow: hidden

**Header section** (top half):

- **Background**: `--muted/40` tint
- **Border-bottom**: 1px solid `--border`
- Padding: Horizontal 12px, top 10px, bottom 8px

**"Texte détecté" label**:

- Font-size: 9px, uppercase, tracking-wider, `--muted-foreground`, monospace
- Layout: Flex row with space-between to push confidence pill to the right

**ConfidencePill component** (top-right):

- Font-size: 9px, padding horizontal 6px, vertical 2px, border-radius: 2px, medium weight, monospace
- Color coding based on value:
    - ≥ 97%: `--emerald-100` background, `--emerald-700` text
    - ≥ 94%: `--amber-100` background, `--amber-700` text
    - < 94%: `--red-100` background, `--red-700` text
- Display format: "{value}%"

**Detected text display**:

- Icon: ScanLine, 11px, primary color, shrink-0
- Text: Detected OCR text, 14px font, semibold, `--foreground`, monospace
- If no match at this coordinate: italic placeholder "Aucun texte détecté à cette position", 9px, `--muted-foreground`

**Coordinate display**:

- Font-size: 9px, `--muted-foreground`, monospace
- Format: "x: {field.x} / y: {field.y}"

**Field section** (bottom half):

- Padding: Horizontal 12px, vertical 8px

**"Champ API" label**:

- Font-size: 9px, uppercase, tracking-wider, `--muted-foreground`, monospace

**Dropdown selector**:

- Full width, appearance: native select styling
- Background: `--background`, border 1px solid `--border`, border-radius: 2px
- Padding: Horizontal 10px, vertical 6px, right padding 28px (for chevron)
- Font-size: 12px (text-xs), `--foreground`
- Options: All API_FIELDS values
- Default option: "-- Sélectionner --" (disabled)
- Chevron icon: ChevronDown, 12px, absolute positioned at right-center, color `--muted-foreground`, pointer-events-none
- Focus ring: 1px solid `--ring`

#### Bottom Save Bar

- **Position**: Fixed at bottom of screen
- **Background**: `--card`
- **Border-top**: 1px solid `--border`
- Padding: Horizontal 16px, vertical 12px
- Layout: Horizontal flex row with space-between

**Left side (progress indicator)**:

- Text: "{activeCount}/{totalCount} champs liés" — 10px font, `--muted-foreground`

**Right side (save button)**:

- **Default state**:
    - Background: `--primary` (#0047CC), text: white (`--primary-foreground`)
    - Layout: Horizontal flex row with SettingsIcon + "Enregistrer" text
    - Icon: 14px, text: 14px font, semibold
    - Padding: Horizontal 16px, vertical 8px, border-radius: 2px
    - On press: save template, show success state briefly

- **Success state** (shown for 2 seconds after save):
    - Background: `--emerald-600`, text: white
    - Icon: CheckCircle2, 14px, text: "Sauvegardé"

---

### 4.6 ScanScreen

**Layout**: Full-height column with a dark app bar at top, scrollable content area, and fixed bottom action bar.

#### App Bar (Dark Header)

- **Background**: `#111218` (near-black)
- Padding: Horizontal 16px, vertical 12px, bottom 16px
- Layout: Horizontal flex row with gap of 12px

**Back button**: ArrowLeft icon, 18px, color `white/60`, negative left margin `-ml-1`
**Title block**:

- Subtitle: "OCR Mapper" — 10px font, uppercase, tracking-widest, `white/50`, monospace
- Title: "Scanner une étiquette" — 14px (text-base), semibold, white, DM Sans

#### Camera / Scan Zone

- **Dimensions**: Full width, fixed height of 180px
- Background: `#111218`
- Border-radius: 2px
- Overflow: hidden
- Position: relative

**Three states**:

##### State 1: Captured Image with OCR Overlays (scanned=true, sent=false, has image)

- **Image layer**: Full width/height, `object-fit: cover`, opacity 85%
- **Overlay boxes**: Semi-transparent rectangles positioned absolutely based on field coordinates
    - Border: 1px solid primary color
    - Fill: primary color at 15% opacity
    - Position calculation: `top: ${(field.y / imageHeight) * 100}%`, left: 10%, width: 45%, height: 8%
- **Field labels on boxes**: Small badge at top-left of each box showing the API field name — 7px font, white text on primary background
- **Status badge** (bottom-right): Semi-transparent dark overlay (`#111218` at 80%), shows checkmark icon + "{count} champs reconnus" — 9px font

##### State 2: Scanning / Processing (scanning=true)

- **Video layer**: Hidden video element with blur effect and 40% opacity as background placeholder
- **Center content** (vertically & horizontally centered):
    - Corner frame: 128×128px square, border 2px solid `white/20`, border-radius: 2px
        - Four corner accents: Each corner has a thicker colored border segment (4px for top corners, 3px for bottom) in primary color
        - Scanning line: Horizontal line at 50% vertical position, animated to sweep from top to bottom and back continuously (1.4s ease-in-out infinite loop)
    - Status text: "Analyse en cours…" — 14px font, `white/60`, monospace

##### State 3: Empty / No Capture Yet (default state)

- **Video layer**: Hidden video element as subtle background
- **Center content** (vertically & horizontally centered):
    - Camera icon frame: 112×112px square, border 1px solid `white/20`, border-radius: 2px
        - Four corner accents: Each corner has a thicker colored border segment in `white/50`
        - Center icon: Camera icon, 24px, white at 30% opacity
    - Status text: "Appuyez sur le bouton ci-dessous pour ouvrir la caméra." — 14px font, `white/50`, monospace

#### Scan Action Buttons (below camera zone)

- **Padding**: Horizontal 16px, top 12px, bottom 8px

**"Prendre une photo" button** (shown when no scan yet):

- Full width, horizontal flex row centered with Camera icon + text
- Border: 1px solid `--border`, background `--card`
- Text: "Prendre une photo", 14px font, semibold
- Icon: Camera, 15px
- Padding: Vertical 10px, horizontal 16px, border-radius: 2px
- Disabled state (during scanning): opacity 50%

**"Rescanner" button** (shown after scan, before send):

- Full width, same style as above but smaller
- Text: "Rescanner", 14px font, medium weight
- Icon: Camera, 13px
- On press: reset scanned state and captured image

#### Extracted Data Section (visible only when scanned)

- **Section divider**: Same pattern as TemplateScreen — label + line
    - Label: "Données extraites" — 10px font, uppercase, tracking-widest, `--muted-foreground`, monospace

**Data field cards**: One card per detected/recognized field.

Each card structure:

```
┌───────────────────────────────┐
│ product.name                 │  ← Field name header (primary color)
│ ───────────────────────────── │
│ LAIT ENTIER BIO      [98%] ● │  ← Value + confidence + green dot
└───────────────────────────────┘
```

**Card structure**:

- Background: `--card`
- Border: 1px solid `--border`, border-radius: 2px
- Overflow: hidden

**Header section**:

- Padding: Horizontal 12px, top 8px, bottom 6px
- Border-bottom: 1px solid `--border`
- Background: `--muted/30` tint
- Text: API field name (e.g., "product.name") — 9px font, primary color, uppercase, tracking-wider, monospace

**Value section**:

- Padding: Horizontal 12px, vertical 8px
- Layout: Horizontal flex row with space-between

**Left side (value)**:

- Text: Detected value string (e.g., "LAIT ENTIER BIO") or em-dash "—" if not yet detected
- Font-size: 14px, medium weight, `--foreground`, monospace

**Right side**: Horizontal flex row with gap of 8px

- **ConfidencePill**: Same component as in TemplateScreen (see section 4.5)
- **Status dot**: 8×8px circle, solid emerald-500 (#10B981 or equivalent)

#### Bottom Send Bar

- **Background**: `--card`
- **Border-top**: 1px solid `--border`
- Padding: Horizontal 16px, vertical 12px

**Success state** (after sending):

- Full width bar with emerald-600 background, white text
- Layout: Centered horizontal flex row with CheckCircle2 icon + "Données envoyées avec succès" text
- Icon: 16px, text: 14px font, semibold

**Send button** (default state):

- Full width, horizontal flex row centered with SendIcon + "Envoyer" text
- Background: `--primary` (#0047CC), text: white (`--primary-foreground`)
- Font-size: 14px, semibold
- Padding: Vertical 12px, border-radius: 2px
- Disabled state (when not scanned): opacity 30%

---

## 5. Camera & OCR Flow

### 5.1 Camera Capture

The app uses the device's native rear camera for label capture. Two approaches are combined:

1. **Direct camera intent** (primary, mobile): Use `image_picker` with `CameraDevice.rear` to launch the native camera app directly. This provides the best image quality and lowest latency. The user takes a photo within the native camera UI and confirms.

2. **File picker fallback** (desktop / when camera unavailable): Fall back to standard file picker accepting only images (`image/*`).

**Camera settings**:

- Camera device: Rear-facing (environment)
- Image format: JPEG or PNG (whichever the device provides natively)
- Resolution: Maximum available from the device camera

### 5.2 OCR Processing with Google ML Kit

After capturing an image, the following steps occur:

1. **Image preparation**: Convert the captured image to the format expected by ML Kit (`InputImage.fromFilePath` for file paths or `InputImage.fromBytes` for byte arrays).

2. **Text recognition**: Run Google ML Kit's Text Recognition API on the image. This returns a list of `TextBlock` objects, each containing:
    - The recognized text string
    - A bounding box (`Rect`) in pixel coordinates relative to the original image dimensions
    - Confidence score per character (aggregate to block-level confidence)

3. **Coordinate normalization**: Convert raw pixel coordinates from the captured image to normalized values (0–1 or percentage-based) for consistent overlay rendering regardless of image resolution. The reference coordinate system uses a 320px height baseline: `normalizedY = (pixelY / 320) * 100`.

4. **Field matching**: For each detected text block, find the closest template field by coordinate proximity using Euclidean distance with a threshold of 15 pixels in both X and Y axes. If no field is within range, the text remains unmapped.

### 5.3 OCR Data Structure

Each OCR result must include:

- **text**: The recognized string content
- **confidence**: A percentage value (0–100) representing recognition confidence
- **boundingBox**: A `Rect` with left, top, width, height in pixel coordinates relative to the captured image
- **id**: A unique local identifier for UI tracking and mapping

---

## 6. Color System & Design Tokens

### Light Theme (Default)

| Token                  | Value                  | Usage                                 |
| ---------------------- | ---------------------- | ------------------------------------- |
| `--background`         | #F2F2EE                | Page background                       |
| `--foreground`         | #111218                | Primary text                          |
| `--card`               | #FFFFFF                | Card backgrounds, panels              |
| `--border`             | rgba(17, 18, 24, 0.12) | Borders, dividers                     |
| `--primary`            | #0047CC                | Primary actions, links                |
| `--primary-foreground` | #FFFFFF                | Text on primary background            |
| `--muted`              | #E2E2DC                | Muted backgrounds, secondary surfaces |
| `--muted-foreground`   | #6B6B72                | Secondary text, placeholders          |
| `--accent`             | #0047CC                | Accent color (same as primary)        |
| `--ring`               | #0047CC                | Focus rings                           |
| `--destructive`        | #CC2200                | Error states                          |

### Dark Theme

| Token                | Value            | Usage                         |
| -------------------- | ---------------- | ----------------------------- |
| `--background`       | oklch(0.145 0 0) | Page background               |
| `--foreground`       | oklch(0.985 0 0) | Primary text                  |
| `--card`             | oklch(0.145 0 0) | Card backgrounds (same as bg) |
| `--border`           | oklch(0.269 0 0) | Borders, dividers             |
| `--primary`          | oklch(0.985 0 0) | Primary actions (inverted)    |
| `--muted`            | oklch(0.269 0 0) | Muted backgrounds             |
| `--muted-foreground` | oklch(0.708 0 0) | Secondary text                |

### Template-Specific Colors (Sample Data)

| Template               | Icon Background | Accent Color |
| ---------------------- | --------------- | ------------ |
| Produit laitier        | #E8F0FE         | #0047CC      |
| Conserves alimentaires | #FEF3E8         | #CC5200      |
| Surgelés               | #E8F8FE         | #0092CC      |
| Cosmétiques            | #F5E8FE         | #7A00CC      |
| Médicaments OTC        | #FEE8E8         | #CC0022      |

### Confidence Pill Colors

| Range | Background            | Text Color            |
| ----- | --------------------- | --------------------- |
| ≥ 97% | Emerald-100 (#D1FAE5) | Emerald-700 (#047857) |
| ≥ 94% | Amber-100 (#FEF3C7)   | Amber-700 (#B45309)   |
| < 94% | Red-100 (#FEE2E2)     | Red-700 (#DC2626)     |

---

## 7. Typography System

### Font Families

- **Sans-serif (body)**: DM Sans — used for all general text, headings, input fields
- **Monospace**: JetBrains Mono — used exclusively for labels, coordinates, field names, confidence values, timestamps, and technical data

### Type Scale

| Size  | px                           | Weight                        | Usage                                             |
| ----- | ---------------------------- | ----------------------------- | ------------------------------------------------- |
| 9px   | 0.5625rem                    | medium (500)                  | Badge text, coordinate labels, tiny metadata      |
| 10px  | 0.625rem                     | medium (500)                  | Section headers, stat labels, progress indicators |
| 12px  | 0.75rem                      | medium (500)                  | Dropdown options, small buttons                   |
| 14px  | 0.875rem (text-sm/text-base) | semibold (600) / medium (500) | Card titles, body text, input fields, buttons     |
| 16px+ | 1rem+                        | semibold (600)                | Screen headings, app bar title                    |

### Text Styles by Context

- **Section labels** (e.g., "Icône & Titre", "Textes détectés → Champs API"): 10px, uppercase, tracking-widest (letter-spacing: 0.1em), `--muted-foreground`, monospace
- **Field names in headers**: 9px, uppercase, tracking-wider, primary color, monospace
- **Detected text values**: 14px, medium/semibold, `--foreground`, monospace
- **Coordinates** (e.g., "x: 42 / y: 18"): 9px, `--muted-foreground`, monospace
- **Timestamps** (e.g., "Aujourd'hui, 09:14"): 9px, `--muted-foreground`, monospace

---

## 8. Border Radius System

All interactive elements and cards use a consistent small border-radius approach:

| Class        | CSS Value                       | Used On                          |
| ------------ | ------------------------------- | -------------------------------- |
| rounded-sm   | 2px (calc(var(--radius) - 4px)) | Cards, buttons, inputs, badges   |
| rounded-full | 9999px                          | Emoji picker toggle, status dots |

---

## 9. Spacing & Layout Conventions

- **Horizontal padding**: 16px (px-4) for most screens; 12px (px-3) for card internals
- **Vertical gaps**: 8px (gap-2), 12px (gap-3), 16px (gap-4) between major sections
- **Card internal padding**: 12px horizontal, variable vertical based on content density
- **Button padding**: Vertical 8–12px, Horizontal 12–16px depending on button size

---

## 10. Animations & Micro-interactions

### Scanning Line Animation (ScanScreen)

- A horizontal line sweeps vertically within the scanning frame
- Duration: 1.4 seconds per cycle
- Easing: ease-in-out
- Direction: infinite loop from top (10%) to bottom (85%) and back

### Save Button Feedback (TemplateScreen)

- On save click: button background transitions from `--primary` (#0047CC) to emerald-600
- Icon changes from SettingsIcon to CheckCircle2
- Text changes from "Enregistrer" to "Sauvegardé"
- Duration: 2 seconds, then reverts to default state

### Confidence Pill Color Transition

- Background and text color change based on confidence value thresholds (94%, 97%)
- No explicit animation; color updates reactively with OCR results

---

## 11. Screen-by-Screen State Machine

### TemplateListScreen

| State   | Conditions                              | UI Changes                                              |
| ------- | --------------------------------------- | ------------------------------------------------------- |
| Default | Templates loaded, no action in progress | Shows stats strip + template cards list + create button |

### TemplateScreen (Create Mode)

| State        | Conditions                  | UI Changes                                                                                        |
| ------------ | --------------------------- | ------------------------------------------------------------------------------------------------- |
| Empty image  | No reference image uploaded | Shows camera/upload placeholder with icon and instructions                                        |
| Image loaded | Reference image selected    | Shows image with overlay boxes for each field position + "Changer" button + detection count badge |
| Saving       | Save button pressed         | Button shows success state (green, checkmark) for 2 seconds                                       |

### TemplateScreen (Edit Mode)

| State          | Conditions                                                             | UI Changes                                                           |
| -------------- | ---------------------------------------------------------------------- | -------------------------------------------------------------------- |
| Loaded from DB | Existing template loaded                                               | Pre-populates name, description, icon, fields with existing mappings |
| Auto-mapped    | On mount, detected texts snap to nearest field by coordinate proximity | Mappings pre-filled where coordinates match within 15px threshold    |

### ScanScreen

| State             | Conditions                             | UI Changes                                                                                                                  |
| ----------------- | -------------------------------------- | --------------------------------------------------------------------------------------------------------------------------- |
| Idle (no capture) | App opened, no photo taken             | Shows camera icon frame + instruction text + "Prendre une photo" button                                                     |
| Scanning          | Photo captured, processing in progress | Shows scanning animation with corner frame and animated scan line                                                           |
| Result ready      | OCR complete, data displayed           | Shows captured image with overlay boxes + extracted field values + confidence pills + "Rescanner" button + "Envoyer" button |
| Sent              | Send button pressed                    | Bottom bar shows success message (green background)                                                                         |

---

## 12. Local Storage Schema (SQLite)

### Templates Table

```sql
CREATE TABLE templates (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT NOT NULL,
    description TEXT DEFAULT '',
    icon TEXT DEFAULT '😀',
    color TEXT DEFAULT '#E8F0FE',
    accent TEXT DEFAULT '#0047CC',
    label_photo_path TEXT,
    created_at TEXT DEFAULT (datetime('now')),
    updated_at TEXT DEFAULT (datetime('now'))
);
```

### Template Fields Table

```sql
CREATE TABLE template_fields (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    template_id INTEGER NOT NULL REFERENCES templates(id) ON DELETE CASCADE,
    api_field TEXT NOT NULL,
    x REAL NOT NULL,
    y REAL NOT NULL,
    confidence REAL DEFAULT 0.0
);
```

### Scans Table

```sql
CREATE TABLE scans (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    template_id INTEGER REFERENCES templates(id),
    ocr_text TEXT NOT NULL,
    confidence REAL DEFAULT 0.0,
    image_path TEXT,
    metadata_json TEXT,
    created_at TEXT DEFAULT (datetime('now'))
);
```

### Captures Directory

- Path: `{app_data_directory}/captures/`
- File naming: `capture_{timestamp}.{jpg|png}` where timestamp is `YYYYMMDD_HHMMSSmmm`
- Supported formats: JPG, PNG

---

## 13. Camera Service Implementation Details

### Native Camera Capture (Android/iOS)

```dart
// Use image_picker with camera source for direct rear-camera launch
final picker = ImagePicker();
final XFile? photo = await picker.pickImage(
  source: ImageSource.camera,
  preferredCameraDevice: CameraDevice.rear, // environment-facing camera
  imageQuality: 95, // high quality for OCR accuracy
);
```

### Image Processing Pipeline

1. **Capture**: Get `XFile` from camera intent
2. **Save to disk**: Copy file to `{app_data}/captures/capture_{timestamp}.jpg`
3. **Run OCR**: Pass image path to Google ML Kit Text Recognition
4. **Parse results**: Extract text blocks with bounding boxes and confidence scores
5. **Normalize coordinates**: Convert pixel coordinates to percentage-based for overlay rendering
6. **Match fields**: For each detected block, find nearest template field by coordinate proximity (threshold: 15px)

### OCR Confidence Calculation

- ML Kit provides per-character confidence; aggregate to block level using weighted average
- Display as integer percentage (0–100) in the ConfidencePill component

---

## 14. Responsive & Platform Considerations

### Mobile-First Design

- All layouts are designed for portrait orientation on phones
- The camera zone is fixed at 180px height to leave room for extracted data below
- Touch targets are minimum 36×36px (icon buttons) and 44×44px (action areas)

### Platform-Specific Camera Behavior

- **Android**: `image_picker` with `CameraDevice.rear` opens the native camera app directly, providing full camera controls and best image quality
- **iOS**: Same approach; iOS handles rear-camera launch natively via `ImageSource.camera`
- **No live preview in-app**: The app does not implement a custom camera preview widget. It delegates to the OS camera app for capture, then processes the result

---

## 15. Iconography

All icons use Lucide icon set (or Flutter equivalent):

| Icon           | Usage                                | Typical Size |
| -------------- | ------------------------------------ | ------------ |
| ArrowLeft      | Back navigation                      | 18px         |
| Plus           | Create new template, navbar button   | 12–14px      |
| Settings / Cog | Template configuration               | 13–14px      |
| ScanLine       | Scan action, detected text indicator | 11–15px      |
| Camera         | Camera trigger buttons               | 15–24px      |
| Send           | Send data button                     | 15px         |
| CheckCircle2   | Success states, save confirmation    | 14–16px      |
| Tag            | Last-used timestamp indicator        | 9px          |
| Layers         | Templates count in stats strip       | 11px         |
| PackageSearch  | Scans count in stats strip           | 11px         |
| ImagePlus      | Upload image placeholder             | 18px         |
| Zap            | Detection count badge                | 9–10px       |
| ChevronDown    | Dropdown indicator                   | 12px         |

---

## 16. Accessibility & UX Notes

- **Color contrast**: All text meets WCAG AA minimum (4.5:1 for normal text, 3:1 for large text)
- **Touch targets**: Minimum 36×36px for icon buttons; full-width buttons for primary actions
- **Loading states**: Scanning animation provides clear visual feedback during OCR processing
- **Empty states**: Each screen has a descriptive empty state with actionable guidance (e.g., "Appuyez sur 'Prendre une photo' pour ouvrir la caméra.")
- **Error handling**: Camera timeout of 60 seconds if user doesn't complete capture; graceful fallback to file picker on desktop

---

## 17. Build & Configuration

### pubspec.yaml Key Dependencies

```yaml
dependencies:
    flutter:
        sdk: flutter
    go_router: ^14.0.0
    google_mlkit_text_recognition: ^0.13.0
    camera: ^0.10.5+2
    image_picker: ^1.1.0
    path_provider: ^2.1.1
    sqflite: ^2.3.0
    path: ^1.8.3
    lucide_icons: ^0.254.0
    google_fonts: ^6.1.0
```

### Android Permissions (AndroidManifest.xml)

```xml
<uses-permission android:name="android.permission.CAMERA" />
<uses-feature android:name="android.hardware.camera" android:required="true" />
<uses-feature android:name="android.hardware.camera.autofocus" android:required="false" />
```

### iOS Permissions (Info.plist)

```xml
<key>NSCameraUsageDescription</key>
<string>Cette application utilise la caméra pour photographier des étiquettes produits et extraire du texte via OCR.</string>
```

---

## 18. File Structure (Flutter Project)

```
lib/
├── main.dart                          # App entry point, router setup
├── app/
│   ├── routes.dart                    # go_router configuration
│   └── theme/
│       ├── app_theme.dart             # Light/dark theme definitions
│       ├── colors.dart                # Color tokens
│       ├── typography.dart            # Font families and type scale
│       └── spacing.dart               # Spacing constants
├── screens/
│   ├── template_list_screen.dart      # Home screen with template cards
│   ├── template_screen.dart           # Create/Edit template (unified)
│   └── scan_screen.dart               # Camera capture + OCR results
├── components/
│   ├── navbar.dart                    # Global top navigation bar
│   ├── confidence_pill.dart           # Confidence percentage badge
│   └── emoji_picker.dart              # Emoji selection dropdown
├── services/
│   ├── camera_service.dart            # Camera capture (image_picker)
│   ├── ocr_service.dart               # Google ML Kit text recognition
│   ├── storage_service.dart           # SQLite operations + file I/O
│   └── image_service.dart             # Image saving, conversion helpers
├── models/
│   ├── template.dart                  # Template + TemplateField data classes
│   ├── scan_record.dart               # ScanRecord model
│   └── ocr_result.dart                # DetectedTextRegion model
└── utils/
    ├── constants.dart                 # API_FIELDS, route labels, defaults
    └── coordinate_utils.dart          # Coordinate normalization & matching
```

---

## 19. Key Implementation Notes for Flutter Port

### Coordinate System

The original Vue app uses pixel-based coordinates (e.g., x:42, y:18) relative to a reference image height of 320px. In Flutter, these should be stored as normalized values (0–1 or percentage) so that overlay boxes render correctly regardless of the actual captured image resolution.

**Conversion formula**:

```dart
// Pixel → Percentage for Y axis (reference height = 320px)
double yPercent = (pixelY / 320.0) * 100.0;

// For rendering on an image of any size:
double topPx = (yPercent / 100.0) * imageHeight;
```

### OCR Text-to-Field Matching Algorithm

When a template is loaded in edit mode, the app automatically attempts to match detected text regions to template fields based on coordinate proximity:

```dart
// For each detected text region with bounding box center (tx, ty):
// Find the field where both |field.x - tx| <= 15 AND |field.y - ty| <= 15
TemplateField? findMatchingField(double textX, double textY) {
  return fields.firstWhere(
    (f) => (f.x - textX).abs() <= 15 && (f.y - textY).abs() <= 15,
    orElse: () => throw Exception('No match'),
  );
}
```

### Image Overlay Rendering

The captured image with OCR overlay boxes is rendered using a `Stack` widget in Flutter:

```dart
Stack(
  children: [
    // Layer 1: Captured image (85% opacity)
    Opacity(
      opacity: 0.85,
      child: Image.file(File(imagePath), fit: BoxFit.cover),
    ),
    // Layer 2: Overlay boxes with field labels
    Positioned.fill(
      child: Stack(
        children: fields.map((field) {
          final topPercent = (field.y / 320.0) * 100;
          return Positioned(
            top: '${topPercent}%',
            left: '10%',
            width: '45%',
            height: '8%',
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.blue, width: 1),
                color: Colors.blue.withOpacity(0.15),
              ),
              child: Positioned(
                top: -14, // -top-3.5 equivalent
                left: 0,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 1),
                  color: Colors.blue,
                  child: Text(field.apiField, style: TextStyle(fontSize: 7)),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    ),
  ],
)
```

### Camera Capture Flow (Flutter)

1. User taps "Prendre une photo" button
2. `ImagePicker.pickImage(source: ImageSource.camera, preferredCameraDevice: CameraDevice.rear)` launches native camera
3. On capture confirmation, the image file path is received
4. File is copied to `{app_data}/captures/capture_{timestamp}.jpg`
5. OCR service processes the image via Google ML Kit
6. Results are displayed with overlay boxes and extracted field values
