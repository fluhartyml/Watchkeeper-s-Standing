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
 ├── audioFileURL: String?         — fair copy pane only
 ├── createdAt: Date
 └── modifiedAt: Date

 Unique constraint: compound key on (date, hour) — one entry per hour per day.

 ═══════════════════════════════════════════════════════════════
 LAYOUT — FOUR PANELS (2x2 GRID)
 ═══════════════════════════════════════════════════════════════

 ┌─────────────┬─────────────┐
 │     Map     │  Calendar   │
 ├─────────────┼─────────────┤
 │     Log     │ Fair Copy   │
 └─────────────┴─────────────┘

 Default layout shown above. User can drag to rearrange any panel
 into any slot. Panels can be collapsed when not needed.

 1) Map Panel — Dead Reckoning Track
    - MapKit, MKPolyline for chronological GPS path
    - MKAnnotation pins for entries with location
    - Tap pin → navigates Log and Fair Copy to that entry
    - Over time: geographic record of movement

 2) Calendar Panel — Date Navigation
    - Date picker, visual indicators for days with entries
    - Tap date → loads that day in Log and Fair Copy

 3) Log Panel — Primary Writing Interface
    - 24 hourly lines per day
    - Each line: title + truncated single-line preview (ellipsis)
    - Single-line display is deliberate — capture, not re-reading
    - Tap line → open entry for editing
    - Blank hours show empty lines (present, waiting, never demanding)

 4) Fair Copy Panel — Memory Layer
    - Mirrors log entry until edited, then diverges permanently
    - Full rich text display (carriage returns, paragraphs)
    - Hero image slot (top, between title and body)
    - Audio playback
    - Can become the source of truth

 ═══════════════════════════════════════════════════════════════
 KEY IMPLEMENTATION DETAILS
 ═══════════════════════════════════════════════════════════════

 Single-Line Log Entry:
   - TextField with .lineLimit(1) and .truncationMode(.tail)
   - Conceptually one infinitely long line — no word wrap
   - Tapping opens full editor

 Mirror/Diverge Mechanic:
   - Fair copy reads from logBody while hasFairCopyDiverged == false
   - First edit to fair copy: copy logBody → fairCopyBody, set flag true
   - Log edits never propagate to a diverged fair copy
   - Visual indicator distinguishes mirror vs diverged state

 Dead Reckoning Map:
   - MapKit with MKPolyline connecting chronological GPS points
   - Pins at hours with written entries
   - Tap pin → navigate other panels to that entry

 Hero Image:
   - Fixed slot in fair copy between title and body — layout never reflows
   - Empty placeholder with subtle "Insert Image" affordance
   - PhotosPicker for selection

 Media Separation:
   - Log pane = pure text only (capture mode)
   - Fair copy pane = rich text + hero image + audio (memory mode)

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
 - AVFoundation     (audio recording/playback in fair copy)
 - SwiftUI          (all UI)

 ═══════════════════════════════════════════════════════════════
 PERMISSIONS (Info.plist)
 ═══════════════════════════════════════════════════════════════

 - NSLocationWhenInUseUsageDescription  — geo-stamp entries
 - NSMicrophoneUsageDescription         — audio recording in fair copy
 - NSPhotoLibraryUsageDescription       — hero image selection

 ═══════════════════════════════════════════════════════════════
 PLATFORM BEHAVIOR
 ═══════════════════════════════════════════════════════════════

 iPad (Primary):
   - Full 2x2 grid, all four panels visible
   - Drag to rearrange panels
   - Collapse panels to thin strip or tab

 Mac (native SwiftUI):
   - Full 2x2 grid, resizable window
   - Same panel arrangement as iPad
   - Keyboard shortcuts for panel focus

 iPhone:
   - Single panel at a time or two-panel split
   - Swipe or tab navigation between panels
   - Log + Fair Copy as primary pair, Map + Calendar as secondary

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
   [ ] Collapse a panel — verify behavior (strip/tab/hidden)
   [ ] Restore collapsed panel
   [ ] Resize window — verify panels adapt

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
   [ ] Collapse/restore panels via touch
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
   [ ] Verify single-panel or two-panel display mode
   [ ] Verify swipe/tab navigation between panels
   [ ] Verify hourly line tap targets work on small screen

 Phase 2 — Fair Copy / Mirror-Diverge
   [ ] All Mac Phase 2 tests repeated on iPhone
   [ ] Hero image from camera (not just photo library)
   [ ] Audio recording on iPhone

 Phase 3 — Panel Navigation (iPhone-specific)
   [ ] Verify panel switching is intuitive (swipe, tabs, or segmented control)
   [ ] Log + Fair Copy as primary pair — verify side-by-side or stacked
   [ ] Map panel — verify usable on phone screen
   [ ] Calendar panel — verify date selection works at phone size
   [ ] Verify no panel arrangement drag on iPhone (fixed layout)

 Phase 4 — Location & Map
   [ ] Verify GPS stamp accuracy on iPhone (should be best of all platforms)
   [ ] Walk between locations, create entries — verify DR track on map
   [ ] Verify map pins and polyline at phone zoom levels

 Phase 5 — iCloud Sync
   [ ] Create entry on iPhone — verify appears on iPad and Mac
   [ ] Verify all three platforms reflect same diverged/mirror states
   [ ] Verify hero image and audio sync across all three

 ═══════════════════════════════════════════════════════════════
 KNOWN OPEN QUESTIONS
 ═══════════════════════════════════════════════════════════════

 - Fair copy scope: daily vs user-defined (per week/trip/project) — data model TBD
 - Export formats: plain text, PDF, share sheet — not yet designed
 - App icon and visual identity — not yet decided
 - Panel arrangement persistence: per-device or synced via iCloud?
 - Panel collapse behavior: thin strip, tab, or disappear?
 - iPhone layout: two panels with swipe, or single focused panel?

 ═══════════════════════════════════════════════════════════════
 CHANGELOG
 ═══════════════════════════════════════════════════════════════

 2026-03-21: Initial developer notes created from concept document
 2026-03-21: Renamed "Receipt" to "Fair Copy" throughout codebase and docs
 2026-03-21: Added live time red line indicator (proportional within current hour row)
 2026-03-21: Added 24H/12H time format toggle in Log panel header

 */
