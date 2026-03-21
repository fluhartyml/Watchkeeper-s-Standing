//
//  CalendarPanelView.swift
//  Watchkeeper's Standing
//
//  Created by Michael Fluharty on 3/21/26.
//

import SwiftUI
import SwiftData

struct CalendarPanelView: View {
    @Binding var selectedDate: Date
    @Query private var allEntries: [LogEntry]

    private var datesWithEntries: Set<String> {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        var dates = Set<String>()
        for entry in allEntries where entry.hasContent {
            dates.insert(formatter.string(from: entry.date))
        }
        return dates
    }

    var body: some View {
        VStack(spacing: 0) {
            panelHeader

            VStack(spacing: 12) {
                DatePicker(
                    "Date",
                    selection: $selectedDate,
                    displayedComponents: .date
                )
                .datePickerStyle(.graphical)
                .padding(.horizontal, 8)

                Divider()

                todaySummary
                    .padding(.horizontal, 12)
                    .padding(.bottom, 8)
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
            Image(systemName: "calendar")
                .foregroundStyle(.secondary)
            Text("CALENDAR")
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundStyle(.secondary)
                .tracking(2)
            Button {
                selectedDate = Date()
            } label: {
                Text("Today")
                    .font(.caption)
                    .fontWeight(.medium)
            }
            Spacer()
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(Color(.secondarySystemBackground))
    }

    private var todaySummary: some View {
        let start = Calendar.current.startOfDay(for: selectedDate)
        let dayEntries = allEntries.filter {
            Calendar.current.isDate($0.date, inSameDayAs: start) && $0.hasContent
        }
        let divergedCount = dayEntries.filter { $0.hasFairCopyDiverged }.count

        return VStack(alignment: .leading, spacing: 4) {
            let dateFormatter: DateFormatter = {
                let f = DateFormatter()
                f.dateFormat = "EEEE, MMM d yyyy"
                return f
            }()

            Text(dateFormatter.string(from: selectedDate))
                .font(.caption)
                .fontWeight(.medium)

            HStack(spacing: 16) {
                Label("\(dayEntries.count) entries", systemImage: "pencil.line")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                if divergedCount > 0 {
                    Label("\(divergedCount) diverged", systemImage: "arrow.triangle.branch")
                        .font(.caption2)
                        .foregroundStyle(.orange)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}
