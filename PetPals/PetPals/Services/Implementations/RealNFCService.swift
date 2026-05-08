import Foundation
import CoreNFC

final class RealNFCService: NSObject, NFCServiceProtocol, NFCNDEFReaderSessionDelegate {
    private var session: NFCNDEFReaderSession?
    private var scanContinuation: CheckedContinuation<String, Error>?
    
    func scanCollar() async throws -> String {
        return try await withCheckedThrowingContinuation { continuation in
            self.scanContinuation = continuation
            self.session = NFCNDEFReaderSession(delegate: self, queue: nil, invalidateAfterFirstRead: true)
            self.session?.alertMessage = "Hold your iPhone near the smart collar."
            self.session?.begin()
        }
    }
    
    // MARK: - NFCNDEFReaderSessionDelegate
    func readerSession(_ session: NFCNDEFReaderSession, didInvalidateWithError error: Error) {
        scanContinuation?.resume(throwing: error)
        scanContinuation = nil
    }
    
    func readerSession(_ session: NFCNDEFReaderSession, didDetectNDEFs messages: [NFCNDEFMessage]) {
        // Simple implementation: extract the first record's payload
        if let firstMessage = messages.first,
           let firstRecord = firstMessage.records.first {
            let payload = String(data: firstRecord.payload, encoding: .utf8) ?? "Unknown"
            scanContinuation?.resume(returning: payload)
        } else {
            scanContinuation?.resume(throwing: NSError(domain: "NFCService", code: 404, userInfo: [NSLocalizedDescriptionKey: "No data found on collar"]))
        }
        scanContinuation = nil
    }
}
