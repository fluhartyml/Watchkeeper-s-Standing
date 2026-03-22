//
//  FairCopyPanelView.swift
//  Watchkeeper's Standing
//
//  Created by Michael Fluharty on 3/21/26.
//

import SwiftUI
import SwiftData
import PhotosUI

struct FairCopyPanelView: View {
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
                FairCopyEntryView(entry: entry)
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
            Text("FAIR COPY")
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundStyle(.secondary)
                .tracking(2)
            Spacer()

            if let entry = entry {
                // Diverge status badge
                Text(entry.hasFairCopyDiverged ? "DIVERGED" : "MIRRORING")
                    .font(.system(size: 9, weight: .medium, design: .monospaced))
                    .foregroundStyle(entry.hasFairCopyDiverged ? .orange : .green)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(
                        Capsule()
                            .fill(entry.hasFairCopyDiverged
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

struct FairCopyEntryView: View {
    @Bindable var entry: LogEntry
    @State private var bodyText: String = ""
    @State private var titleText: String = ""
    @State private var selectedPhoto: PhotosPickerItem?
    @FocusState private var bodyFocused: Bool

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 12) {
                // Date header
                Text(dateHeader)
                    .font(.system(.caption, design: .monospaced))
                    .foregroundStyle(.tertiary)
                    .padding(.horizontal, 16)
                    .padding(.top, 8)

                // Title row: hour + editable title
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
                        .onSubmit {
                            // Return → jump to body
                            bodyFocused = true
                        }
                }
                .padding(.horizontal, 16)

                // Hero image slot — always present
                heroImageSection
                    .padding(.horizontal, 16)

                // Body text — shared with Log, full display here
                TextEditor(text: $bodyText)
                    .font(.body)
                    .scrollContentBackground(.hidden)
                    .frame(minHeight: 200)
                    .padding(.horizontal, 12)
                    .focused($bodyFocused)
                    .onChange(of: bodyText) { _, newValue in
                        if entry.hasFairCopyDiverged {
                            entry.fairCopyBody = newValue
                        } else {
                            // Shared body — writes to logBody, syncs to Log pane
                            entry.logBody = newValue.isEmpty ? nil : newValue
                        }
                        entry.modifiedAt = Date()
                    }

                // Geo location display
                if let lat = entry.latitude, let lon = entry.longitude {
                    geoLocationRow(lat: lat, lon: lon)
                        .padding(.horizontal, 16)
                }

                // Media slot placeholder
                mediaSection
                    .padding(.horizontal, 16)

                // Perforation button
                perforationButton
                    .padding(.horizontal, 16)
                    .padding(.bottom, 16)

                Spacer()
            }
        }
        .onAppear { loadContent() }
        .onChange(of: entry.id) { _, _ in loadContent() }
        // Live sync: when logBody changes externally (typed in Log), update body here
        .onChange(of: entry.logBody) { _, newValue in
            if !entry.hasFairCopyDiverged {
                let incoming = newValue ?? ""
                if bodyText != incoming {
                    bodyText = incoming
                }
            }
        }
        // Live sync: title typed in Log pane
        .onChange(of: entry.title) { _, newValue in
            let incoming = newValue ?? ""
            if titleText != incoming {
                titleText = incoming
            }
        }
    }

    private var dateHeader: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMM d yyyy"
        return formatter.string(from: entry.date)
    }

    // MARK: - Hero Image

    private var heroImageSection: some View {
        VStack(spacing: 0) {
            if let imageData = entry.heroImageData,
               let image = PlatformImage(data: imageData) {
                Image(platformImage: image)
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
                        .frame(height: 60)
                        .overlay(
                            HStack(spacing: 6) {
                                Image(systemName: "photo.badge.plus")
                                    .font(.caption)
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

    // MARK: - Geo Location

    private func geoLocationRow(lat: Double, lon: Double) -> some View {
        HStack(spacing: 6) {
            Image(systemName: "location.fill")
                .font(.caption2)
                .foregroundStyle(.secondary)
            Text(String(format: "%.4f, %.4f", lat, lon))
                .font(.system(.caption2, design: .monospaced))
                .foregroundStyle(.secondary)
        }
    }

    // MARK: - Media

    private var mediaSection: some View {
        Group {
            if entry.mediaFileURL != nil {
                HStack(spacing: 6) {
                    Image(systemName: entry.mediaType == "video" ? "video.fill" : "waveform")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text(entry.mediaType == "video" ? "Video attached" : "Audio attached")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Spacer()
                    Button {
                        entry.mediaFileURL = nil
                        entry.mediaType = nil
                        entry.modifiedAt = Date()
                    } label: {
                        Image(systemName: "xmark.circle")
                            .font(.caption)
                            .foregroundStyle(.tertiary)
                    }
                    .buttonStyle(.plain)
                }
                .padding(10)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.secondary.opacity(0.06))
                )
            } else {
                HStack(spacing: 12) {
                    Button {
                        // Audio recording — placeholder for now
                    } label: {
                        Label("Record Audio", systemImage: "mic")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    .buttonStyle(.plain)

                    Button {
                        // Video recording — placeholder for now
                    } label: {
                        Label("Record Video", systemImage: "video")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    .buttonStyle(.plain)

                    Spacer()
                }
                .padding(10)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.secondary.opacity(0.04))
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .strokeBorder(style: StrokeStyle(lineWidth: 1, dash: [6]))
                                .foregroundStyle(Color.secondary.opacity(0.15))
                        )
                )
            }
        }
    }

    // MARK: - Perforation

    private var perforationButton: some View {
        Button {
            // Perforate — seal current Fair Copy run
            // This will be wired to the FairCopyRun model
        } label: {
            HStack {
                Spacer()
                Image(systemName: "scissors")
                    .font(.caption)
                Text("Perforate")
                    .font(.caption)
                    .fontWeight(.medium)
                Spacer()
            }
            .foregroundStyle(.secondary)
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: 6)
                    .strokeBorder(style: StrokeStyle(lineWidth: 1, dash: [8, 4]))
                    .foregroundStyle(Color.secondary.opacity(0.3))
            )
        }
        .buttonStyle(.plain)
    }

    private func loadContent() {
        titleText = entry.title ?? ""
        bodyText = entry.displayFairCopyBody
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
