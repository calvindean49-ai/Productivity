import LockdownCore
import SwiftUI

struct LogView: View {
    @EnvironmentObject var coordinator: SessionCoordinator

    var body: some View {
        List {
            if coordinator.departures.isEmpty {
                Text("No departures yet.").foregroundStyle(.secondary)
            }
            ForEach(coordinator.departures.sorted { $0.at > $1.at }) { d in
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text(d.kind.rawValue).font(.caption).foregroundStyle(.secondary)
                        Spacer()
                        Text(d.at, style: .time).font(.caption)
                        Image(systemName: d.synced ? "checkmark.icloud" : "icloud.slash")
                            .foregroundStyle(d.synced ? .green : .secondary)
                    }
                    Text(d.leftForOrPlaceholder)
                    if let app = d.app, !app.isEmpty {
                        Text(app).font(.caption).foregroundStyle(.secondary)
                    }
                    if d.durationSeconds > 0 {
                        Text("\(Int(d.durationSeconds)) s").font(.caption).foregroundStyle(.secondary)
                    }
                }
            }
        }
        .navigationTitle("Departures")
    }
}
