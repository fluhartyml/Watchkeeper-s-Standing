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
    var receiptBody: String?
    var hasReceiptDiverged: Bool
    var latitude: Double?
    var longitude: Double?
    @Attribute(.externalStorage) var heroImageData: Data?
    var audioFileURL: String?
    var createdAt: Date
    var modifiedAt: Date

    init(date: Date, hour: Int) {
        self.id = UUID()
        self.date = Calendar.current.startOfDay(for: date)
        self.hour = hour
        self.hasReceiptDiverged = false
        self.createdAt = Date()
        self.modifiedAt = Date()
    }

    var displayReceiptBody: String {
        if hasReceiptDiverged {
            return receiptBody ?? ""
        } else {
            return logBody ?? ""
        }
    }

    var hourLabel: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HHmm"
        var components = Calendar.current.dateComponents([.year, .month, .day], from: date)
        components.hour = hour
        components.minute = 0
        let hourDate = Calendar.current.date(from: components) ?? date
        return formatter.string(from: hourDate)
    }

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
