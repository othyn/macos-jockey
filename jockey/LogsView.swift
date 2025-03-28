import SwiftUI

struct LogsView: View {
    @EnvironmentObject private var shareManager: SMBShareManager

    private var sortedLogs: [SMBShareManager.ReconnectionLog] {
        // Return sorted by timestamp (newest first)
        shareManager.reconnectionLogs.sorted { $0.timestamp > $1.timestamp }
    }

    var body: some View {
        VStack {
            Table(sortedLogs) {
                TableColumn("Time") { log in
                    Text(log.formattedTimestamp)
                }
                .width(min: 150, ideal: 180)

                TableColumn("Share") { log in
                    Text(log.shareName)
                }
                .width(min: 100, ideal: 120)

                TableColumn("URL") { log in
                    Text(log.shareURL)
                }
                .width(min: 150, ideal: 200)

                TableColumn("Mount Point") { log in
                    Text(log.mountPoint)
                }
                .width(min: 150, ideal: 200)

                TableColumn("Status") { log in
                    HStack {
                        Image(systemName: log.success ? "checkmark.circle.fill" : "xmark.circle.fill")
                            .foregroundColor(log.success ? .green : .red)
                        Text(log.success ? "Success" : "Failed")
                    }
                }
                .width(min: 80, ideal: 100)

                TableColumn("Message") { log in
                    Text(log.message)
                }
                .width(min: 200, ideal: 300)
            }
        }
    }
}

struct LogsView_Previews: PreviewProvider {
    static var previews: some View {
        LogsView()
            .environmentObject(SMBShareManager())
    }
}
