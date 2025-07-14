// ContentView.swift

import SwiftUI

struct ContentView: View {
    @StateObject private var scanner = NFCScanner()

    var body: some View {
        NavigationView {
            List {
                if scanner.scannedMessages.isEmpty {
                    Text("No tags scanned yet")
                        .foregroundStyle(.secondary)
                } else {
                    ForEach(scanner.scannedMessages, id: \.self) { msg in
                        Text(msg)
                    }
                }
            }
            .navigationTitle("NFC Scanner")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Scan NFC") {
                        scanner.beginScanning()
                    }
                }
            }
            .alert(scanner.alertTitle, isPresented: $scanner.isAlertPresented) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(scanner.alertMessage)
            }
        }
    }
}
