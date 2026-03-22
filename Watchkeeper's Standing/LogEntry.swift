//
//  LogEntry.swift
//  Watchkeeper's Standing
//
//  Created by Michael Fluharty on 3/21/26.
//

import Foundation
import SwiftData

@Model
final class LogEntry {
    var id: UUID
    var date: Date
    var hour: Int
    var title: String?
    var logBody: String?
    var fairCopyBody: String?
    var hasFairCopyDiverged: Bool
    var latitude: Double?
    var longitude: Double?
    @Attribute(.externalStorage) var heroImageData: Data?
    var mediaFileURL: String?
    var mediaType: String? // "audio" or "video"
    var createdAt: Date
    var modifiedAt: Date

    // Relationship to FairCopyRun
    var fairCopyRun: FairCopyRun?

    init(date: Date, hour: Int) {
        self.id = UUID()
        self.date = Calendar.current.startOfDay(for: date)
        self.hour = hour
        self.hasFairCopyDiverged = false
        self.createdAt = Date()
        self.modifiedAt = Date()
    }

    /// The text to display in the Fair Copy pane
    var displayFairCopyBody: String {
        if hasFairCopyDiverged {
            return fairCopyBody ?? ""
        } else {
            return logBody ?? ""
        }
    }

    /// 24H format label (e.g. "0800")
    var hourLabel: String {
        String(format: "%02d00", hour)
    }

    /// 12H format label (e.g. "8 AM")
    var hourDisplay: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "h a"
        var components = Calendar.current.dateComponents([.year, .month, .day], from: date)
        components.hour = hour
        components.minute = 0
        let hourDate = Calendar.current.date(from: components) ?? date
        return formatter.string(from: hourDate)
    }

    var hasContent: Bool {
        (title != nil && !title!.isEmpty) || (logBody != nil && !logBody!.isEmpty)
    }
}

@Model
final class FairCopyRun {
    var id: UUID
    @Relationship(inverse: \LogEntry.fairCopyRun) var entries: [LogEntry]
    var isOpen: Bool
    var openedAt: Date
    var closedAt: Date?

    init() {
        self.id = UUID()
        self.entries = []
        self.isOpen = true
        self.openedAt = Date()
    }

    /// Perforate — seal this run and return a new open one
    func perforate() -> FairCopyRun {
        self.isOpen = false
        self.closedAt = Date()
        return FairCopyRun()
    }
}
