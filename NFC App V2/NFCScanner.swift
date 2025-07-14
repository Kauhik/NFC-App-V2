// NFCScanner.swift

import Foundation
import CoreNFC

/// Simple NFCNDEFReaderSession manager with no pop-up alerts
final class NFCScanner: NSObject, ObservableObject, NFCNDEFReaderSessionDelegate {
    @Published var scannedMessages: [String] = []

    private var session: NFCNDEFReaderSession?

    /// Start a new NFC scan session
    func beginScanning() {
        guard NFCNDEFReaderSession.readingAvailable else {
            // silently fail if NFC not supported
            return
        }
        session = NFCNDEFReaderSession(
            delegate: self,
            queue: nil,
            invalidateAfterFirstRead: true
        )
        session?.alertMessage = "Hold iPhone near tag"
        session?.begin()
    }

    // MARK: - NFCNDEFReaderSessionDelegate

    func readerSession(_ session: NFCNDEFReaderSession, didInvalidateWithError error: Error) {
        // no-op: ignore session invalidation
    }

    func readerSession(_ session: NFCNDEFReaderSession, didDetectNDEFs messages: [NFCNDEFMessage]) {
        for message in messages {
            for record in message.records {
                let payloadString: String
                if let str = String(data: record.payload, encoding: .utf8),
                   !str.isEmpty {
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
}
