
import Foundation
import CoreNFC

/// A simple ObservableObject that manages an NFCNDEFReaderSession
final class NFCScanner: NSObject, ObservableObject, NFCNDEFReaderSessionDelegate {
    @Published var scannedMessages: [String] = []
    @Published var isAlertPresented = false

    /// Title & message for the alert
    var alertTitle = ""
    var alertMessage = ""

    private var session: NFCNDEFReaderSession?

    /// Call this to start a new NFC‐scanning session
    func beginScanning() {
        guard NFCNDEFReaderSession.readingAvailable else {
            showAlert(title: "NFC not supported", message: "This device doesn’t support NFC scanning.")
            return
        }
        // Invalidate after first read so you get fresh data each time
        session = NFCNDEFReaderSession(
            delegate: self,
            queue: nil,
            invalidateAfterFirstRead: true
        )
        session?.alertMessage = "Hold your iPhone near the NFC tag."
        session?.begin()
    }

    // MARK: - NFCNDEFReaderSessionDelegate

    func readerSession(_ session: NFCNDEFReaderSession, didInvalidateWithError error: Error) {
        showAlert(title: "Session Ended", message: error.localizedDescription)
    }

    func readerSession(_ session: NFCNDEFReaderSession, didDetectNDEFs messages: [NFCNDEFMessage]) {
        for message in messages {
            for record in message.records {
                let payloadString: String
                // Try UTF-8 decode, otherwise hex
                if let str = String(data: record.payload, encoding: .utf8), !str.isEmpty {
                    payloadString = str
                } else {
                    payloadString = record.payload.map {
                        String(format: "%.2hhx", $0)
                    }.joined()
                }
                DispatchQueue.main.async {
                    self.scannedMessages.append(payloadString)
                }
            }
        }
    }

    // MARK: - Helpers

    private func showAlert(title: String, message: String) {
        DispatchQueue.main.async {
            self.alertTitle = title
            self.alertMessage = message
            self.isAlertPresented = true
        }
    }
}
