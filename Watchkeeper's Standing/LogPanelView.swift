//
//  LogPanelView.swift
//  Watchkeeper's Standing
//
//  Created by Michael Fluharty on 3/21/26.
//

import SwiftUI
import SwiftData
import Combine

struct LogPanelView: View {
    @Environment(\.modelContext) private var modelContext
    let selectedDate: Date
    @Binding var selectedHour: Int?
    @Binding var use24HourFormat: Bool
    @Query private var allEntries: [LogEntry]

    @State private var currentMinute: Int = Calendar.current.component(.minute, from: Date())
    @State private var currentHour: Int = Calendar.current.component(.hour, from: Date())

    private let timer = Timer.publish(every: 30, on: .main, in: .common).autoconnect()

    private var isToday: Bool {
        Calendar.current.isDateInToday(selectedDate)
    }

    private var entries: [LogEntry] {
        let start = Calendar.current.startOfDay(for: selectedDate)
        return allEntries.filter { Calendar.current.isDate($0.date, inSameDayAs: start) }
    }

    func entry(for hour: Int) -> LogEntry? {
        entries.first { $0.hour == hour }
    }

    var body: some View {
        VStack(spacing: 0) {
            panelHeader

            ScrollViewReader { proxy in
                List(0..<24, id: \.self) { hour in
                    HourlyLineView(
                        hour: hour,
                        entry: entry(for: hour),
                        isSelected: selectedHour == hour,
                        use24HourFormat: use24HourFormat,
                        isCurrentHour: isToday && hour == currentHour,
                        minuteProgress: isToday && hour == currentHour
                            ? Double(currentMinute) / 60.0
                            : nil,
                        onTap: {
                            selectedHour = hour
                            ensureEntry(for: hour)
                        },
                        onSubmitTitle: {
                            // Return key in title → jump to Fair Copy body
                            // This is handled by the Fair Copy pane via focus state
                        }
                    )
                    .id(hour)
                    .listRowInsets(EdgeInsets(top: 0, leading: 8, bottom: 0, trailing: 8))
                    .listRowBackground(
                        selectedHour == hour
                            ? Color.accentColor.opacity(0.12)
                            : Color.clear
                    )
                }
                .listStyle(.plain)
                .onAppear {
                    if isToday {
                        proxy.scrollTo(currentHour, anchor: .center)
                    }
                }
                .onChange(of: selectedHour) { _, newHour in
                    if let h = newHour {
                        withAnimation {
                            proxy.scrollTo(h, anchor: .center)
                        }
                    }
                }
            }
        }
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.secondary.opacity(0.2), lineWidth: 1)
        )
        .onReceive(timer) { _ in
            currentMinute = Calendar.current.component(.minute, from: Date())
            currentHour = Calendar.current.component(.hour, from: Date())
        }
    }

    private var panelHeader: some View {
        HStack {
            Image(systemName: "text.justify.left")
                .foregroundStyle(.secondary)
            Text("LOG")
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundStyle(.secondary)
                .tracking(2)

            Button {
                use24HourFormat.toggle()
            } label: {
                Text(use24HourFormat ? "24H" : "12H")
                    .font(.system(size: 10, weight: .semibold, design: .monospaced))
                    .foregroundStyle(.secondary)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(
                        Capsule()
                            .fill(Color.secondary.opacity(0.12))
                    )
            }
            .buttonStyle(.borderless)
            .contentShape(Rectangle())

            Spacer()

            if isToday {
                TimelineView(.periodic(from: .now, by: 30)) { context in
                    let components = Calendar.current.dateComponents([.hour, .minute], from: context.date)
                    let h = components.hour ?? 0
                    let m = components.minute ?? 0
                    let timeString: String = {
                        if use24HourFormat {
                            return String(format: "%02d:%02d", h, m)
                        } else {
                            let displayHour = ((h - 1) % 12) + 1
                            let ampm = h < 12 ? "AM" : "PM"
                            return String(format: "%d:%02d %@", displayHour, m, ampm)
                        }
                    }()
                    Text(timeString)
                        .font(.system(.caption, design: .monospaced))
                        .fontWeight(.semibold)
                        .foregroundStyle(.red)
                }
            }

            Spacer()
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(Color(.secondarySystemBackground))
    }

    private var currentTimeString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = use24HourFormat ? "HH:mm" : "h:mm a"
        return formatter.string(from: Date())
    }

    private func ensureEntry(for hour: Int) {
        if entry(for: hour) == nil {
            let newEntry = LogEntry(date: selectedDate, hour: hour)
            modelContext.insert(newEntry)
        }
    }
}

struct HourlyLineView: View {
    let hour: Int
    let entry: LogEntry?
    let isSelected: Bool
    let use24HourFormat: Bool
    let isCurrentHour: Bool
    let minuteProgress: Double?
    let onTap: () -> Void
    let onSubmitTitle: () -> Void

    @State private var editingTitle: String = ""

    private var hourLabel: String {
        if use24HourFormat {
            return String(format: "%02d", hour)
        } else {
            let displayHour = hour == 0 ? 12 : (hour > 12 ? hour - 12 : hour)
            let suffix = hour < 12 ? "a" : "p"
            return "\(displayHour)\(suffix)"
        }
    }

    private let rowHeight: CGFloat = 60

    var body: some View {
        ZStack(alignment: .topLeading) {
            // Main row content
            HStack(spacing: 8) {
                Text(hourLabel)
                    .font(.system(.caption, design: .monospaced))
                    .fontWeight(isCurrentHour ? .bold : .medium)
                    .foregroundStyle(isCurrentHour ? AnyShapeStyle(.red) : AnyShapeStyle(.tertiary))
                    .frame(width: use24HourFormat ? 24 : 30, alignment: .trailing)

                Rectangle()
                    .fill(Color.secondary.opacity(0.15))
                    .frame(width: 1)
                    .frame(maxHeight: .infinity)

                if isSelected, let entry = entry {
                    // Editable inline title when selected
                    TextField("", text: $editingTitle, prompt: Text("Title...").foregroundStyle(.quaternary))
                        .font(.system(.body, design: .default))
                        .fontWeight(.medium)
                        .textFieldStyle(.plain)
                        .lineLimit(1)
                        .truncationMode(.tail)
                        .onChange(of: editingTitle) { _, newValue in
                            entry.title = newValue.isEmpty ? nil : newValue
                            entry.modifiedAt = Date()
                        }
                        .onSubmit {
                            onSubmitTitle()
                        }
                        .onAppear {
                            editingTitle = entry.title ?? ""
                        }
                } else if let entry = entry, entry.hasContent {
                    // Read-only display when not selected
                    HStack(spacing: 6) {
                        if let title = entry.title, !title.isEmpty {
                            Text(title)
                                .font(.system(.body, design: .default))
                                .fontWeight(.medium)
                                .lineLimit(1)
                        }
                        if let body = entry.logBody, !body.isEmpty {
                            Text(body)
                                .font(.system(.body, design: .default))
                                .foregroundStyle(.secondary)
                                .lineLimit(1)
                                .truncationMode(.tail)
                        }
                    }
                    .contentShape(Rectangle())
                    .onTapGesture { onTap() }
                } else {
                    Color.clear
                        .frame(height: 1)
                        .contentShape(Rectangle())
                        .onTapGesture { onTap() }
                }

                Spacer(minLength: 0)
            }
            .frame(height: rowHeight)
            .contentShape(Rectangle())
            .onTapGesture { onTap() }

            // Red "now" line
            if let progress = minuteProgress {
                GeometryReader { geo in
                    let yOffset = progress * geo.size.height
                    Rectangle()
                        .fill(Color.red)
                        .frame(height: 2)
                        .offset(y: yOffset)

                    Circle()
                        .fill(Color.red)
                        .frame(width: 8, height: 8)
                        .offset(x: -4, y: yOffset - 3)
                }
            }
        }
        .frame(height: rowHeight)
        // Sync title from entry when it changes externally (e.g. typed in Fair Copy)
        .onChange(of: entry?.title) { _, newValue in
            if !isSelected { return }
            let incoming = newValue ?? ""
            if editingTitle != incoming {
                editingTitle = incoming
            }
        }
    }

    init(hour: Int, entry: LogEntry?, isSelected: Bool, use24HourFormat: Bool, isCurrentHour: Bool, minuteProgress: Double?, onTap: @escaping () -> Void, onSubmitTitle: @escaping () -> Void) {
        self.hour = hour
        self.entry = entry
        self.isSelected = isSelected
        self.use24HourFormat = use24HourFormat
        self.isCurrentHour = isCurrentHour
        self.minuteProgress = minuteProgress
        self.onTap = onTap
        self.onSubmitTitle = onSubmitTitle
    }
}
