//
//  ContentView.swift
//  Watchkeeper's Standing
//
//  Created by Michael Fluharty on 3/21/26.
//

import SwiftUI
import SwiftData
import UniformTypeIdentifiers

enum PanelType: String, Codable, CaseIterable {
    case map
    case calendar
    case log
    case fairCopy

    var label: String {
        switch self {
        case .map: return "Map"
        case .calendar: return "Calendar"
        case .log: return "Log"
        case .fairCopy: return "Fair Copy"
        }
    }

    var icon: String {
        switch self {
        case .map: return "map"
        case .calendar: return "calendar"
        case .log: return "text.justify.left"
        case .fairCopy: return "doc.text"
        }
    }
}

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var selectedDate: Date = Date()
    @State private var selectedHour: Int?
    @State private var showingEditor = false
    @State private var use24HourFormat = true
    @Query private var allEntries: [LogEntry]

    // Panel positions: index 0=topLeft, 1=topRight, 2=bottomLeft, 3=bottomRight
    @State private var panelLayout: [PanelType] = [.map, .calendar, .log, .fairCopy]
    @State private var draggingPanel: PanelType?
    @State private var dropTargetIndex: Int?

    // Resize split ratios (0.0–1.0)
    @State private var horizontalSplit: CGFloat = 0.5
    @State private var verticalSplit: CGFloat = 0.5

    private var selectedEntry: LogEntry? {
        guard let hour = selectedHour else { return nil }
        let start = Calendar.current.startOfDay(for: selectedDate)
        return allEntries.first {
            Calendar.current.isDate($0.date, inSameDayAs: start) && $0.hour == hour
        }
    }

    var body: some View {
        GeometryReader { geo in
            let isCompact = geo.size.width < 600

            if isCompact {
                compactLayout
            } else {
                gridLayout
            }
        }
        .sheet(isPresented: $showingEditor) {
            if let entry = selectedEntry {
                LogEntryEditorView(entry: entry)
                    #if os(macOS)
                    .frame(minWidth: 500, minHeight: 400)
                    #endif
            }
        }
    }

    // MARK: - 2x2 Grid Layout with Drag-to-Rearrange (iPad / Mac)

    private var gridLayout: some View {
        VStack(spacing: 0) {
            headerBar

            GeometryReader { geo in
                let dividerSize: CGFloat = 8
                let totalWidth = geo.size.width
                let totalHeight = geo.size.height

                let leftWidth = max(100, (totalWidth - dividerSize) * horizontalSplit)
                let rightWidth = max(100, (totalWidth - dividerSize) * (1 - horizontalSplit))
                let topHeight = max(80, (totalHeight - dividerSize) * verticalSplit)
                let bottomHeight = max(80, (totalHeight - dividerSize) * (1 - verticalSplit))

                VStack(spacing: 0) {
                    // Top row
                    HStack(spacing: 0) {
                        panelSlot(index: 0, width: leftWidth, height: topHeight)
                        verticalDivider(height: topHeight, totalWidth: totalWidth)
                        panelSlot(index: 1, width: rightWidth, height: topHeight)
                    }

                    // Horizontal divider
                    horizontalDivider(totalHeight: totalHeight)

                    // Bottom row
                    HStack(spacing: 0) {
                        panelSlot(index: 2, width: leftWidth, height: bottomHeight)
                        verticalDivider(height: bottomHeight, totalWidth: totalWidth)
                        panelSlot(index: 3, width: rightWidth, height: bottomHeight)
                    }
                }
            }
            .padding(4)
        }
    }

    private func panelSlot(index: Int, width: CGFloat, height: CGFloat) -> some View {
        let panelType = panelLayout[index]
        let isDropTarget = dropTargetIndex == index && draggingPanel != nil && draggingPanel != panelType

        return ZStack(alignment: .topTrailing) {
            panelView(for: panelType)
                .frame(width: width, height: height)

            grabberHandle(for: panelType)
                .padding(.top, 4)
                .padding(.trailing, 6)
        }
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(isDropTarget ? Color.accentColor : Color.clear, lineWidth: 3)
        )
        .opacity(draggingPanel == panelType ? 0.5 : 1.0)
        .onDrop(of: [.text], delegate: PanelDropDelegate(
            index: index,
            panelLayout: $panelLayout,
            draggingPanel: $draggingPanel,
            dropTargetIndex: $dropTargetIndex
        ))
    }

    // MARK: - Resize Dividers

    private func verticalDivider(height: CGFloat, totalWidth: CGFloat) -> some View {
        Rectangle()
            .fill(Color.clear)
            .frame(width: 8, height: height)
            .contentShape(Rectangle())
            .overlay(
                RoundedRectangle(cornerRadius: 2)
                    .fill(Color.secondary.opacity(0.3))
                    .frame(width: 4, height: 40)
            )
            .gesture(
                DragGesture()
                    .onChanged { value in
                        let delta = value.translation.width / totalWidth
                        let newSplit = horizontalSplit + delta
                        horizontalSplit = min(max(newSplit, 0.2), 0.8)
                    }
            )
            #if os(macOS)
            .onHover { hovering in
                if hovering {
                    NSCursor.resizeLeftRight.push()
                } else {
                    NSCursor.pop()
                }
            }
            #endif
    }

    private func horizontalDivider(totalHeight: CGFloat) -> some View {
        Rectangle()
            .fill(Color.clear)
            .frame(height: 8)
            .contentShape(Rectangle())
            .overlay(
                RoundedRectangle(cornerRadius: 2)
                    .fill(Color.secondary.opacity(0.3))
                    .frame(width: 40, height: 4)
            )
            .gesture(
                DragGesture()
                    .onChanged { value in
                        let delta = value.translation.height / totalHeight
                        let newSplit = verticalSplit + delta
                        verticalSplit = min(max(newSplit, 0.2), 0.8)
                    }
            )
            #if os(macOS)
            .onHover { hovering in
                if hovering {
                    NSCursor.resizeUpDown.push()
                } else {
                    NSCursor.pop()
                }
            }
            #endif
    }

    private func grabberHandle(for panel: PanelType) -> some View {
        Image(systemName: "line.3.horizontal")
            .font(.system(size: 11, weight: .bold))
            .foregroundStyle(.secondary.opacity(0.6))
            .padding(4)
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 4))
            .onDrag {
                draggingPanel = panel
                return NSItemProvider(object: panel.rawValue as NSString)
            }
    }

    // MARK: - Drag-to-Rearrange Grabber

    @ViewBuilder
    private func panelView(for type: PanelType) -> some View {
        switch type {
        case .map:
            MapPanelView(
                selectedDate: selectedDate,
                selectedHour: $selectedHour
            )
        case .calendar:
            CalendarPanelView(
                selectedDate: $selectedDate
            )
        case .log:
            LogPanelView(
                selectedDate: selectedDate,
                selectedHour: $selectedHour,
                use24HourFormat: $use24HourFormat
            )
        case .fairCopy:
            FairCopyPanelView(
                selectedDate: selectedDate,
                selectedHour: $selectedHour
            )
        }
    }

    // MARK: - Compact Layout (iPhone)

    private var compactLayout: some View {
        TabView {
            Tab("Log", systemImage: "text.justify.left") {
                VStack(spacing: 0) {
                    headerBar
                    LogPanelView(
                        selectedDate: selectedDate,
                        selectedHour: $selectedHour,
                        use24HourFormat: $use24HourFormat
                    )
                    .padding(8)
                }
            }

            Tab("Fair Copy", systemImage: "doc.text") {
                VStack(spacing: 0) {
                    headerBar
                    FairCopyPanelView(
                        selectedDate: selectedDate,
                        selectedHour: $selectedHour
                    )
                    .padding(8)
                }
            }

            Tab("Map", systemImage: "map") {
                VStack(spacing: 0) {
                    headerBar
                    MapPanelView(
                        selectedDate: selectedDate,
                        selectedHour: $selectedHour
                    )
                    .padding(8)
                }
            }

            Tab("Calendar", systemImage: "calendar") {
                VStack(spacing: 0) {
                    headerBar
                    CalendarPanelView(
                        selectedDate: $selectedDate
                    )
                    .padding(8)
                }
            }
        }
    }

    // MARK: - Header

    private var headerBar: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text("Watchkeeper's Standing")
                    .font(.system(.headline, design: .default))
                Text(selectedDate, format: .dateTime.weekday(.wide).month(.abbreviated).day().year())
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            Button {
                if selectedEntry != nil {
                    showingEditor = true
                } else if let hour = selectedHour {
                    let newEntry = LogEntry(date: selectedDate, hour: hour)
                    modelContext.insert(newEntry)
                    showingEditor = true
                }
            } label: {
                Image(systemName: "square.and.pencil")
            }
            .disabled(selectedHour == nil)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
    }
}

struct PanelDropDelegate: DropDelegate {
    let index: Int
    @Binding var panelLayout: [PanelType]
    @Binding var draggingPanel: PanelType?
    @Binding var dropTargetIndex: Int?

    func dropEntered(info: DropInfo) {
        dropTargetIndex = index
    }

    func dropExited(info: DropInfo) {
        if dropTargetIndex == index {
            dropTargetIndex = nil
        }
    }

    func performDrop(info: DropInfo) -> Bool {
        guard let dragging = draggingPanel,
              let sourceIndex = panelLayout.firstIndex(of: dragging) else {
            draggingPanel = nil
            dropTargetIndex = nil
            return false
        }

        withAnimation(.easeInOut(duration: 0.25)) {
            panelLayout.swapAt(sourceIndex, index)
        }

        draggingPanel = nil
        dropTargetIndex = nil
        return true
    }

    func dropUpdated(info: DropInfo) -> DropProposal? {
        DropProposal(operation: .move)
    }
}

#Preview {
    ContentView()
        .modelContainer(for: LogEntry.self, inMemory: true)
}
