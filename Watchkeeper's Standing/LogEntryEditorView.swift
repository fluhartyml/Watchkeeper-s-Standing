//
//  LogEntryEditorView.swift
//  Watchkeeper's Standing
//
//  Created by Michael Fluharty on 3/21/26.
//

import SwiftUI

struct LogEntryEditorView: View {
    @Bindable var entry: LogEntry
    @Environment(\.dismiss) private var dismiss
    @State private var titleText: String = ""
    @State private var bodyText: String = ""
    @FocusState private var bodyFocused: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Header bar
            HStack {
                Text(entry.hourDisplay)
                    .font(.system(.headline, design: .monospaced))
                    .foregroundStyle(.secondary)

                TextField("Title", text: $titleText)
                    .font(.headline)
                    .textFieldStyle(.plain)
                    .onSubmit {
                        bodyFocused = true
                    }

                Spacer()

                Button("Done") {
                    save()
                    dismiss()
                }
                .keyboardShortcut(.return, modifiers: .command)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(Color(.secondarySystemBackground))

            Divider()

            // Body — the single infinite line concept, but in editor mode
            // we allow full multiline editing
            TextEditor(text: $bodyText)
                .font(.system(.body, design: .default))
                .scrollContentBackground(.hidden)
                .focused($bodyFocused)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
        }
        .onAppear {
            titleText = entry.title ?? ""
            bodyText = entry.logBody ?? ""
            bodyFocused = true
        }
        .onDisappear {
            save()
        }
    }

    private func save() {
        entry.title = titleText.isEmpty ? nil : titleText
        entry.logBody = bodyText.isEmpty ? nil : bodyText
        entry.modifiedAt = Date()
    }
}
