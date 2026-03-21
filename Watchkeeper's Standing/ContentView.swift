//
//  ContentView.swift
//  Watchkeeper's Standing
//
//  Created by Michael Fluharty on 3/21/26.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var selectedDate: Date = Date()
    @State private var selectedHour: Int?
    @State private var showingEditor = false
    @Query private var allEntries: [LogEntry]

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
        .onChange(of: selectedHour) { oldValue, newValue in
            if newValue != nil && oldValue != newValue {
                // Double-tap or explicit edit trigger handled by log panel
            }
        }
    }

    // MARK: - 2x2 Grid Layout (iPad / Mac)

    private var gridLayout: some View {
        VStack(spacing: 8) {
            headerBar

            GeometryReader { geo in
                let spacing: CGFloat = 8
                let panelWidth = (geo.size.width - spacing) / 2
                let panelHeight = (geo.size.height - spacing) / 2

                VStack(spacing: spacing) {
                    HStack(spacing: spacing) {
                        MapPanelView(
                            selectedDate: selectedDate,
                            selectedHour: $selectedHour
                        )
                        .frame(width: panelWidth, height: panelHeight)

                        CalendarPanelView(
                            selectedDate: $selectedDate
                        )
                        .frame(width: panelWidth, height: panelHeight)
                    }

                    HStack(spacing: spacing) {
                        LogPanelView(
                            selectedDate: selectedDate,
                            selectedHour: $selectedHour
                        )
                        .frame(width: panelWidth, height: panelHeight)

                        ReceiptPanelView(
                            selectedDate: selectedDate,
                            selectedHour: $selectedHour
                        )
                        .frame(width: panelWidth, height: panelHeight)
                    }
                }
            }
            .padding(.horizontal, 8)
            .padding(.bottom, 8)
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
                        selectedHour: $selectedHour
                    )
                    .padding(8)
                }
            }

            Tab("Receipt", systemImage: "doc.text") {
                VStack(spacing: 0) {
                    headerBar
                    ReceiptPanelView(
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
                if let entry = selectedEntry {
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

#Preview {
    ContentView()
        .modelContainer(for: LogEntry.self, inMemory: true)
}
