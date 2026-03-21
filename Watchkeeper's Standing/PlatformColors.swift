//
//  PlatformColors.swift
//  Watchkeeper's Standing
//
//  Created by Michael Fluharty on 3/21/26.
//

import SwiftUI

#if os(macOS)
extension NSColor {
    static let systemBackground = NSColor.windowBackgroundColor
    static let secondarySystemBackground = NSColor.controlBackgroundColor
}
#endif
