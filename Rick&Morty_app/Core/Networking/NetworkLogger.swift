import Foundation
import os

// MARK: - Logger

/// Thin wrapper over `OSLog`. Messages show up in Console.app and the Xcode
/// debug console, filterable by the "Network" category.
struct Logger: Sendable {
    private let logger: OSLog

    init(
        subsystem: String = Bundle.main.bundleIdentifier ?? "com.rickandmorty.app",
        category: String
    ) {
        self.logger = OSLog(subsystem: subsystem, category: category)
    }

    func info(_ message: String) {
        os_log("%{public}@", log: logger, type: .info, message)
    }

    func debug(_ message: String) {
        os_log("%{public}@", log: logger, type: .debug, message)
    }

    func warning(_ message: String) {
        os_log("⚠️ %{public}@", log: logger, type: .default, message)
    }

    func error(_ message: String) {
        os_log("%{public}@", log: logger, type: .error, message)
    }

    func fault(_ message: String) {
        os_log("🚨 %{public}@", log: logger, type: .fault, message)
    }
}

// MARK: - Network Logger

/// Logs every API request, response, and failure. All output is compiled
/// out of release builds so response bodies never leak to production logs.
enum NetworkLogger {
    private static let logger = Logger(category: "Network")

    static func logRequest(_ request: URLRequest) {
        #if DEBUG
        let method = request.httpMethod ?? "UNKNOWN"
        let url = request.url?.absoluteString ?? "No URL"
        let headers = request.allHTTPHeaderFields ?? [:]
        let body = request.httpBody?.prettyPrintedJSONString ?? "No Body"

        logger.info("🚀 [Request] \(method) \(url)")
        logger.debug("📋 [Headers] \(headers)")
        logger.debug("📦 [Body] \(body)")
        #endif
    }

    static func logResponse(request: URLRequest, response: HTTPURLResponse, data: Data) {
        #if DEBUG
        let url = request.url?.absoluteString ?? "No URL"
        let body = data.prettyPrintedJSONString ?? "No Response Body"

        logger.info("✅ [Response] \(response.statusCode) \(url)")
        logger.debug("📦 [Body]\n\(body)")
        #endif
    }

    static func logError(
        request: URLRequest?,
        response: HTTPURLResponse? = nil,
        data: Data? = nil,
        error: String
    ) {
        #if DEBUG
        let url = request?.url?.absoluteString ?? "No URL"
        let status = response?.statusCode ?? 0
        let body = data?.prettyPrintedJSONString ?? "No Response Body"

        logger.error("❌ [Error] \(url)")
        logger.debug("❌ [Detail] \(error)")
        logger.debug("🔢 [Status] \(status)")
        logger.debug("📦 [Body]\n\(body)")
        #endif
    }
}

// MARK: - Pretty Printed JSON

private extension Data {
    var prettyPrintedJSONString: String? {
        guard
            let object = try? JSONSerialization.jsonObject(with: self, options: [.mutableContainers]),
            let prettyData = try? JSONSerialization.data(withJSONObject: object, options: [.prettyPrinted]),
            let prettyString = String(data: prettyData, encoding: .utf8)
        else {
            return nil
        }
        return prettyString
    }
}
