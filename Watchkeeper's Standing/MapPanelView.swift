//
//  MapPanelView.swift
//  Watchkeeper's Standing
//
//  Created by Michael Fluharty on 3/21/26.
//

import SwiftUI
import SwiftData
import MapKit

struct MapPanelView: View {
    let selectedDate: Date
    @Binding var selectedHour: Int?
    @Query private var allEntries: [LogEntry]

    @State private var cameraPosition: MapCameraPosition = .automatic

    private var entriesWithLocation: [LogEntry] {
        allEntries.filter { $0.latitude != nil && $0.longitude != nil && $0.hasContent }
    }

    private var todayEntriesWithLocation: [LogEntry] {
        let start = Calendar.current.startOfDay(for: selectedDate)
        return entriesWithLocation.filter {
            Calendar.current.isDate($0.date, inSameDayAs: start)
        }.sorted { $0.hour < $1.hour }
    }

    private var drCoordinates: [CLLocationCoordinate2D] {
        todayEntriesWithLocation.compactMap { entry in
            guard let lat = entry.latitude, let lon = entry.longitude else { return nil }
            return CLLocationCoordinate2D(latitude: lat, longitude: lon)
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            panelHeader

            Map(position: $cameraPosition) {
                // DR polyline track
                if drCoordinates.count >= 2 {
                    MapPolyline(coordinates: drCoordinates)
                        .stroke(.blue.opacity(0.6), lineWidth: 2)
                }

                // Entry pins
                ForEach(todayEntriesWithLocation, id: \.id) { entry in
                    if let lat = entry.latitude, let lon = entry.longitude {
                        Annotation(
                            entry.title ?? entry.hourLabel,
                            coordinate: CLLocationCoordinate2D(latitude: lat, longitude: lon)
                        ) {
                            Button {
                                selectedHour = entry.hour
                            } label: {
                                Circle()
                                    .fill(selectedHour == entry.hour ? Color.accentColor : Color.blue)
                                    .frame(width: 12, height: 12)
                                    .overlay(
                                        Circle()
                                            .stroke(.white, lineWidth: 2)
                                    )
                                    .shadow(radius: 2)
                            }
                        }
                    }
                }
            }
            .mapStyle(.standard(elevation: .flat))
            .overlay(alignment: .bottom) {
                if todayEntriesWithLocation.isEmpty {
                    mapEmptyOverlay
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
            Image(systemName: "map")
                .foregroundStyle(.secondary)
            Text("MAP")
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundStyle(.secondary)
                .tracking(2)
            Spacer()
            if !todayEntriesWithLocation.isEmpty {
                Text("\(todayEntriesWithLocation.count) pins")
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(Color(.secondarySystemBackground))
    }

    private var mapEmptyOverlay: some View {
        VStack(spacing: 4) {
            Image(systemName: "location.slash")
                .font(.caption)
            Text("No location data for this day")
                .font(.caption2)
        }
        .foregroundStyle(.secondary)
        .padding(8)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 8))
        .padding(8)
    }
}
