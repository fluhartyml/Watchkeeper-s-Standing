//
//  ReceiptPanelView.swift
//  Watchkeeper's Standing
//
//  Created by Michael Fluharty on 3/21/26.
//

import SwiftUI
import SwiftData
import PhotosUI

struct ReceiptPanelView: View {
    @Environment(\.modelContext) private var modelContext
    let selectedDate: Date
    @Binding var selectedHour: Int?
    @Query private var allEntries: [LogEntry]

    private var entry: LogEntry? {
        guard let hour = selectedHour else { return nil }
        let start = Calendar.current.startOfDay(for: selectedDate)
        return allEntries.first {
            Calendar.current.isDate($0.date, inSameDayAs: start) && $0.hour == hour
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            panelHeader

            if let entry = entry {
                ReceiptEntryView(entry: entry)
            } else {
                emptyState
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
            Image(systemName: "doc.text")
                .foregroundStyle(.secondary)
            Text("RECEIPT")
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundStyle(.secondary)
                .tracking(2)
            Spacer()
            if let entry = entry {
                Text(entry.hasReceiptDiverged ? "DIVERGED" : "MIRRORING")
                    .font(.system(size: 9, weight: .medium, design: .monospaced))
                    .foregroundStyle(entry.hasReceiptDiverged ? .orange : .green)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(
                        Capsule()
                            .fill(entry.hasReceiptDiverged
                                  ? Color.orange.opacity(0.12)
                                  : Color.green.opacity(0.12))
                    )
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(Color(.secondarySystemBackground))
    }

    private var emptyState: some View {
        VStack {
            Spacer()
            Text("Select an hour")
                .font(.subheadline)
                .foregroundStyle(.tertiary)
            Spacer()
        }
        .frame(maxWidth: .infinity)
    }
}

struct ReceiptEntryView: View {
    @Bindable var entry: LogEntry
    @State private var receiptText: String = ""
    @State private var titleText: String = ""
    @State private var selectedPhoto: PhotosPickerItem?

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 12) {
                // Hour and title
                HStack {
                    Text(entry.hourDisplay)
                        .font(.system(.title3, design: .monospaced))
                        .fontWeight(.semibold)
                        .foregroundStyle(.secondary)

                    TextField("Title", text: $titleText)
                        .font(.title3)
                        .fontWeight(.semibold)
                        .textFieldStyle(.plain)
                        .onChange(of: titleText) { _, newValue in
                            entry.title = newValue.isEmpty ? nil : newValue
                            entry.modifiedAt = Date()
                        }
                }
                .padding(.horizontal, 16)
                .padding(.top, 12)

                // Hero image slot
                heroImageSection
                    .padding(.horizontal, 16)

                // Receipt body
                TextEditor(text: $receiptText)
                    .font(.body)
                    .scrollContentBackground(.hidden)
                    .frame(minHeight: 200)
                    .padding(.horizontal, 12)
                    .onChange(of: receiptText) { _, newValue in
                        if !entry.hasReceiptDiverged {
                            if newValue != (entry.logBody ?? "") {
                                entry.hasReceiptDiverged = true
                                entry.receiptBody = newValue
                            }
                        } else {
                            entry.receiptBody = newValue
                        }
                        entry.modifiedAt = Date()
                    }

                Spacer()
            }
        }
        .onAppear { loadContent() }
        .onChange(of: entry.id) { _, _ in loadContent() }
        .onChange(of: entry.logBody) { _, newValue in
            if !entry.hasReceiptDiverged {
                receiptText = newValue ?? ""
            }
        }
    }

    private var heroImageSection: some View {
        VStack(spacing: 0) {
            if let imageData = entry.heroImageData,
               let nsImage = PlatformImage(data: imageData) {
                Image(platformImage: nsImage)
                    .resizable()
                    .scaledToFill()
                    .frame(maxWidth: .infinity)
                    .frame(height: 200)
                    .clipped()
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                    .overlay(alignment: .topTrailing) {
                        Button {
                            entry.heroImageData = nil
                            entry.modifiedAt = Date()
                        } label: {
                            Image(systemName: "xmark.circle.fill")
                                .font(.title3)
                                .foregroundStyle(.white)
                                .shadow(radius: 2)
                        }
                        .padding(8)
                    }
            } else {
                PhotosPicker(selection: $selectedPhoto, matching: .images) {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.secondary.opacity(0.06))
                        .frame(height: 120)
                        .overlay(
                            VStack(spacing: 6) {
                                Image(systemName: "photo.badge.plus")
                                    .font(.title2)
                                    .foregroundStyle(.tertiary)
                                Text("Insert Image")
                                    .font(.caption)
                                    .foregroundStyle(.tertiary)
                            }
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .strokeBorder(style: StrokeStyle(lineWidth: 1, dash: [6]))
                                .foregroundStyle(Color.secondary.opacity(0.2))
                        )
                }
                .buttonStyle(.plain)
            }
        }
        .onChange(of: selectedPhoto) { _, newItem in
            Task {
                if let data = try? await newItem?.loadTransferable(type: Data.self) {
                    entry.heroImageData = data
                    entry.modifiedAt = Date()
                }
            }
        }
    }

    private func loadContent() {
        titleText = entry.title ?? ""
        receiptText = entry.displayReceiptBody
    }
}

// Cross-platform image handling
#if os(macOS)
typealias PlatformImage = NSImage
extension Image {
    init(platformImage: NSImage) {
        self.init(nsImage: platformImage)
    }
}
#else
typealias PlatformImage = UIImage
extension Image {
    init(platformImage: UIImage) {
        self.init(uiImage: platformImage)
    }
}
#endif
