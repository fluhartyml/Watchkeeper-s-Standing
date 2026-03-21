//
//  LogPanelView.swift
//  Watchkeeper's Standing
//
//  Created by Michael Fluharty on 3/21/26.
//

import SwiftUI
import SwiftData

struct LogPanelView: View {
    @Environment(\.modelContext) private var modelContext
    let selectedDate: Date
    @Binding var selectedHour: Int?
    @Query private var allEntries: [LogEntry]

    private var entries: [LogEntry] {
        let start = Calendar.current.startOfDay(for: selectedDate)
        return allEntries.filter { Calendar.current.isDate($0.date, inSameDayAs: start) }
    }

    private func entry(for hour: Int) -> LogEntry? {
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
                        isSelected: selectedHour == hour
                    )
                    .id(hour)
                    .contentShape(Rectangle())
                    .onTapGesture {
                        selectedHour = hour
                        ensureEntry(for: hour)
                    }
                    .listRowInsets(EdgeInsets(top: 2, leading: 8, bottom: 2, trailing: 8))
                    .listRowBackground(
                        selectedHour == hour
                            ? Color.accentColor.opacity(0.12)
                            : Color.clear
                    )
                }
                .listStyle(.plain)
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
            Spacer()
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(Color(.secondarySystemBackground))
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

    private var hourLabel: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH"
        var components = DateComponents()
        components.hour = hour
        let date = Calendar.current.date(from: components) ?? Date()
        return formatter.string(from: date)
    }

    var body: some View {
        HStack(spacing: 8) {
            Text(hourLabel)
                .font(.system(.caption, design: .monospaced))
                .fontWeight(.medium)
                .foregroundStyle(.tertiary)
                .frame(width: 24, alignment: .trailing)

            Rectangle()
                .fill(Color.secondary.opacity(0.15))
                .frame(width: 1)
                .frame(maxHeight: .infinity)

            if let entry = entry, entry.hasContent {
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
            } else {
                Color.clear
                    .frame(height: 1)
            }

            Spacer(minLength: 0)
        }
        .frame(minHeight: 32)
        .padding(.vertical, 2)
    }
}
