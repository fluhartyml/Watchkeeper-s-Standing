// WatchkeepersStanding_DeveloperNotes.swift
// Watchkeeper's Standing
//
// This file is not compiled — it exists as a living reference document inside the Xcode project.
// Updated: 2026-03-21

/*
 ═══════════════════════════════════════════════════════════════
 WATCHKEEPER'S STANDING — DEVELOPER NOTES
 ═══════════════════════════════════════════════════════════════

 Project:   Watchkeeper's Standing
 Status:    Pre-build — concept document complete, Xcode project created
 Replaces:  Inkwell Journal
 Platforms: iPhone, iPad, Mac
 Sync:      iCloud (SwiftData + CloudKit)

 ═══════════════════════════════════════════════════════════════
 CORE CONCEPT
 ═══════════════════════════════════════════════════════════════

 Personal logbook structured by the clock. 24 hourly slots per day —
 write or don't. Two-pane system: Log (raw capture) and Fair Copy
 (curated memory). Fair Copy mirrors Log until edited, then diverges
 permanently. Both versions preserved.

 The name comes from maritime tradition — the watchkeeper is the
 officer responsible for maintaining the ship's log during their watch.
 "Watchkeeper's Standing" = the standing record IS the logbook.

 ═══════════════════════════════════════════════════════════════
 DATA MODEL
 ═══════════════════════════════════════════════════════════════

 LogEntry (SwiftData @Model)
 ├── id: UUID
 ├── date: Date                    — calendar day
 ├── hour: Int (0-23)              — the only mandatory anchor
 ├── title: String?
 ├── logBody: String?              — raw capture text
 ├── fairCopyBody: String?         — curated text (nil = still mirroring)
 ├── hasFairCopyDiverged: Bool     — false until fair copy is edited
 ├── latitude: Double?
 ├── longitude: Double?
 ├── heroImageData: Data?          — fair copy pane only
 ├── mediaFileURL: String?         — audio or video, fair copy pane only
 ├── mediaType: String?            — "audio" or "video"
 ├── createdAt: Date
 └── modifiedAt: Date

 Unique constraint: compound key on (date, hour) — one entry per hour per day.

 FairCopyRun (SwiftData @Model)
 ├── id: UUID
 ├── entries: [LogEntry]           — ordered list of hourly entries in this run
 ├── isOpen: Bool                  — true until author perforates (closes)
 ├── openedAt: Date
 └── closedAt: Date?

 The Fair Copy is a continuous roll of receipt paper. The author writes
 entries and they accumulate into the current open FairCopyRun. When the
 author "perforates" (closes) the run, everything above the tear is sealed
 and a new FairCopyRun begins. Runs can span hours, days, or years — the
 author decides when to tear. Perforation can also be applied retroactively
 to split a long run after the fact.

 ═══════════════════════════════════════════════════════════════
 LAYOUT — FOUR PANELS (2x2 GRID)
 ═══════════════════════════════════════════════════════════════

 ┌─────────────┬─────────────┐
 │     Map     │  Calendar   │
 ├─────────────┼─────────────┤
 │     Log     │ Fair Copy   │
 └─────────────┴─────────────┘

 Default layout shown above. User can drag to rearrange any panel
 into any slot. All four panels are always visible — no collapse.
 Panel arrangement synced across devices via iCloud.

 Future upgrade: if user base requests it, allow closing panels.
 One closed panel → placeholder fills vacancy. Two closed panels →
 grid reflows from 2x2 to 1x2.

 1) Map Panel — Dead Reckoning Track
    - MapKit, MKPolyline for chronological GPS path
    - MKAnnotation pins for entries with location
    - Tap pin → navigates Log and Fair Copy to that entry
    - Over time: geographic record of movement

 2) Calendar Panel — Date Navigation
    - Date picker, visual indicators for days with entries
    - Tap date → loads that day in Log and Fair Copy

 3) Log Panel — Table of Contents / Navigation Index
    - 24 hourly lines per day
    - Each line: title + truncated single-line preview (ellipsis)
    - Single-line display is deliberate — the log is an index, not a reading surface
    - Two entry paths:
      a) Type title in Log line, hit Return → cursor jumps to Fair Copy body
      b) Tap empty hour in Log → Fair Copy opens blank entry with timestamp
    - Title syncs live between Log and Fair Copy (character by character)
    - Blank hours show empty lines (present, waiting, never demanding)

 4) Fair Copy Panel — Memory Layer / Primary Writing Surface
    - Where the actual writing happens (title, body, images, media)
    - Mirrors log entry until edited, then diverges permanently
    - Full rich text display (carriage returns, paragraphs)
    - Per-entry layout:
      [ Title                    ]
      [ Hero Image / Placeholder ]  — image optional, placeholder always present
      [ Journal Entry text...    ]  — or video journal, or dictation, or nothing
      [ Geo Location             ]
      [ Media: audio or video    ]  — optional, front/rear camera or audio-only
    - Video thumbnail can supplement or replace the hero image
    - Can become the source of truth
    - Continuous "receipt paper" — entries accumulate into a FairCopyRun
    - Author perforates (closes) a run to seal it and start a new one
    - Perforation can be applied retroactively to split long runs

 ═══════════════════════════════════════════════════════════════
 KEY IMPLEMENTATION DETAILS
 ═══════════════════════════════════════════════════════════════

 Single-Line Log Entry:
   - TextField with .lineLimit(1) and .truncationMode(.tail)
   - Conceptually one infinitely long line — no word wrap
   - Log is a table of contents / navigation index
   - Title typed in Log syncs character-by-character to Fair Copy (and vice versa)
   - Return key in Log jumps cursor to Fair Copy body (below hero image placeholder)

 Shared Body Text:
   - There is ONE body of text per entry — not two separate fields
   - Both panes are live writing surfaces for the same text
   - Type in Log → appears in Fair Copy. Type in Fair Copy → appears in Log.
   - The only difference is DISPLAY: Log truncates to single line, Fair Copy shows full text
   - Title also syncs character-by-character between both panes

 Mirror/Diverge Mechanic:
   - The diverge mechanic applies when the author explicitly edits the
     Fair Copy to CREATE a curated version separate from the raw entry
   - Once diverged, the Fair Copy has its own independent body text
   - The log retains the original raw text
   - Visual indicator distinguishes mirror vs diverged state

 Dead Reckoning Map:
   - MapKit with MKPolyline connecting chronological GPS points
   - Pins at hours with written entries
   - Tap pin → navigate other panels to that entry

 Hero Image:
   - Fixed slot in fair copy between title and body — layout never reflows
   - Empty placeholder with subtle "Insert Image" affordance
   - PhotosPicker for selection
   - Video thumbnail can supplement or replace the hero image

 Media:
   - Log pane = pure text only (capture mode)
   - Fair copy pane = rich text + hero image + audio/video (memory mode)
   - Media attachment supports: audio-only, video (front/rear/Mac webcam)
   - Input methods: typing, dictation, camera — the app doesn't care how content arrives

 Writing Tools:
   - No built-in AI summarization or paraphrasing
   - Apple Intelligence writing tools available as system-level assists

 ═══════════════════════════════════════════════════════════════
 FRAMEWORKS REQUIRED
 ═══════════════════════════════════════════════════════════════

 - SwiftData        (persistence + iCloud sync)
 - MapKit           (map panel, polyline, annotations)
 - CoreLocation     (GPS stamping on entry creation)
 - PhotosUI         (PhotosPicker for hero image)
 - AVFoundation     (audio/video recording and playback in fair copy)
 - AVKit            (video player UI)
 - SwiftUI          (all UI)

 ═══════════════════════════════════════════════════════════════
 PERMISSIONS (Info.plist)
 ═══════════════════════════════════════════════════════════════

 - NSLocationWhenInUseUsageDescription  — geo-stamp entries
 - NSMicrophoneUsageDescription         — audio/video recording in fair copy
 - NSCameraUsageDescription             — video journal recording (front/rear)
 - NSPhotoLibraryUsageDescription       — hero image selection

 ═══════════════════════════════════════════════════════════════
 PLATFORM BEHAVIOR
 ═══════════════════════════════════════════════════════════════

 iPad / Mac:
   - Full 2x2 grid, all four panels always visible
   - Drag to rearrange panels, arrangement synced via iCloud
   - No panel collapse (future upgrade if user base requests)
   - Mac: resizable window, keyboard shortcuts for panel focus

 iPhone:
   - Four full-screen pages, swipe navigation (TabView .page style)
   - Default page order: Log, Fair Copy, Calendar, Map
   - Author can rearrange page order to match their workflow
   - When iPhone Ultra ships (expected 7" foldable + outer screen):
     outer screen → compact single-panel (quick capture)
     inner 7" screen → iPad-style 2x2 grid
     Architecture uses size classes — no special-casing needed

 ═══════════════════════════════════════════════════════════════
 SHAKEDOWN PLAN — MAC
 ═══════════════════════════════════════════════════════════════

 Phase 1 — Core Data & Entry Flow
   [ ] Create entry for current hour — verify timestamp and location auto-stamp
   [ ] Edit entry body in Log pane — verify single-line truncated display
   [ ] Verify blank hours show empty lines (present, not hidden)
   [ ] Create entries across multiple hours — verify ordering
   [ ] Verify compound key constraint (one entry per hour per day)

 Phase 2 — Fair Copy / Mirror-Diverge
   [ ] Write log entry — verify fair copy mirrors it exactly
   [ ] Edit fair copy — verify it diverges and flag flips
   [ ] Edit log after diverge — verify fair copy is unchanged
   [ ] Verify visual indicator for mirror vs diverged state
   [ ] Add hero image to fair copy — verify display and placeholder behavior
   [ ] Add audio to fair copy — verify playback
   [ ] Verify log pane stays pure text (no media)

 Phase 3 — Calendar Panel
   [ ] Navigate to different dates — verify log/fair copy update
   [ ] Verify visual indicators on days with entries
   [ ] Verify days without entries show no indicator
   [ ] Navigate to blank day — verify 24 empty hourly lines

 Phase 4 — Map Panel
   [ ] Verify entry location pins appear on map
   [ ] Tap pin — verify other panels navigate to that entry
   [ ] Create entries at different locations — verify DR polyline connects them
   [ ] Verify entries without location don't break the map

 Phase 5 — Panel Layout
   [ ] Drag panels to rearrange — verify persistence
   [ ] Resize window — verify panels adapt
   [ ] Verify panel arrangement persists via iCloud

 Phase 6 — Search & Navigation
   [ ] Full-text search across log entries
   [ ] Full-text search across fair copy entries
   [ ] Navigate by location from map
   [ ] Navigate by date from calendar

 Phase 7 — Persistence & Sync
   [ ] Force quit and relaunch — verify all data persists
   [ ] Verify iCloud container is configured
   [ ] Check SwiftData CloudKit sync (test with second device if available)

 ═══════════════════════════════════════════════════════════════
 SHAKEDOWN PLAN — iPAD
 ═══════════════════════════════════════════════════════════════

 Phase 1 — Core Entry Flow
   [ ] All Mac Phase 1 tests repeated on iPad
   [ ] Verify touch targets on hourly lines are adequate
   [ ] Verify keyboard appears for log entry editing
   [ ] Test with external keyboard attached

 Phase 2 — Fair Copy / Mirror-Diverge
   [ ] All Mac Phase 2 tests repeated on iPad
   [ ] Hero image via PhotosPicker — verify camera roll access
   [ ] Audio recording — verify microphone permission prompt

 Phase 3 — Panel Layout (iPad-specific)
   [ ] Verify full 2x2 grid displays correctly in landscape
   [ ] Verify 2x2 grid in portrait — panels may need to stack or scroll
   [ ] Drag to rearrange panels via touch
   [ ] Test in Split View / Slide Over multitasking
   [ ] Test Stage Manager (if supported on device)

 Phase 4 — Map & Calendar
   [ ] All Mac Phase 3-4 tests repeated on iPad
   [ ] Verify map gestures (pinch zoom, pan) don't conflict with panel drag

 Phase 5 — iCloud Sync
   [ ] Create entry on iPad — verify appears on Mac
   [ ] Edit fair copy on Mac — verify diverged state syncs to iPad
   [ ] Add hero image on iPad — verify syncs to Mac

 ═══════════════════════════════════════════════════════════════
 SHAKEDOWN PLAN — iPHONE
 ═══════════════════════════════════════════════════════════════

 Phase 1 — Core Entry Flow
   [ ] All Mac Phase 1 tests repeated on iPhone
   [ ] Verify four full-screen swipeable pages
   [ ] Verify default page order: Log, Fair Copy, Calendar, Map
   [ ] Verify hourly line tap targets work on small screen

 Phase 2 — Fair Copy / Mirror-Diverge
   [ ] All Mac Phase 2 tests repeated on iPhone
   [ ] Hero image from camera (not just photo library)
   [ ] Audio recording on iPhone

 Phase 3 — Panel Navigation (iPhone-specific)
   [ ] Verify swipe between pages is smooth and intuitive
   [ ] Verify page order is rearrangeable
   [ ] Map panel — verify usable on phone screen
   [ ] Calendar panel — verify date selection works at phone size
   [ ] Verify page order preference syncs via iCloud

 Phase 4 — Location & Map
   [ ] Verify GPS stamp accuracy on iPhone (should be best of all platforms)
   [ ] Walk between locations, create entries — verify DR track on map
   [ ] Verify map pins and polyline at phone zoom levels

 Phase 5 — iCloud Sync
   [ ] Create entry on iPhone — verify appears on iPad and Mac
   [ ] Verify all three platforms reflect same diverged/mirror states
   [ ] Verify hero image and audio sync across all three

 ═══════════════════════════════════════════════════════════════
 EXPORT & IMPORT
 ═══════════════════════════════════════════════════════════════

 Export:
   - Print layout with user-customizable formatting (modeled on old iCal print)
   - Booklet mode: page ordering for fold-and-staple binding (n-up printing)
   - Share sheet (AirDrop, Messages, Mail, etc.)
   - Apple Notes export with formatting preserved (via share sheet + attributed text/HTML)
   - Page range selection
   - Print to PDF (native macOS/iOS)

 Import:
   - Evernote ENEX (XML format, well-documented)
   - Apple Notes (HTML/RTF)
   - Imported entries land at 0001 on their creation date
   - Author can manually adjust the hour after import
   - Additional import formats added based on user demand

 ═══════════════════════════════════════════════════════════════
 REMAINING OPEN QUESTIONS
 ═══════════════════════════════════════════════════════════════

 - App icon and visual identity — ChatGPT to design

 ═══════════════════════════════════════════════════════════════
 CHANGELOG
 ═══════════════════════════════════════════════════════════════

 2026-03-21: Initial developer notes created from concept document
 2026-03-21: Renamed "Receipt" to "Fair Copy" throughout codebase and docs
 2026-03-21: Added live time red line indicator (proportional within current hour row)
 2026-03-21: Added 24H/12H time format toggle in Log panel header
 2026-03-21: Q&A session — resolved all open questions:
             - Fair Copy scope: continuous receipt paper with perforation (FairCopyRun model)
             - Per-entry structure: title, hero image, body, geo, media (audio/video)
             - Video thumbnail can supplement or replace hero image
             - Input methods: typing, dictation, camera — app is agnostic
             - iPhone: four full-screen swipeable pages (Log, Fair Copy, Calendar, Map)
             - iPhone Ultra future: outer screen compact, inner 7" gets 2x2 grid via size classes
             - Panels always visible, no collapse (future upgrade if requested)
             - Panel arrangement synced via iCloud
             - Log pane is table of contents / navigation index, not primary writing surface
             - Title syncs character-by-character between Log and Fair Copy
             - Return in Log jumps cursor to Fair Copy body
             - Export: print layout (iCal-style), booklet mode, share sheet, Apple Notes, page range
             - Import: Evernote ENEX, Apple Notes HTML/RTF, imports land at 0001
             - Renamed audioFileURL to mediaFileURL, added mediaType field
             - Added FairCopyRun model for perforation/scope mechanic
             - Added NSCameraUsageDescription and AVKit framework

 */
