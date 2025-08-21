import Foundation

// MARK: - Apple Music API Error Models

/// Represents an error response directly from the Apple Music API.
///
/// This structure preserves the exact format and content of errors returned
/// by the Apple Music service, providing complete transparency about what went wrong.
public struct AppleMusicErrorResponse: Codable, Equatable, Sendable {
    /// An array of error objects returned by the Apple Music API.
    public let errors: [AppleMusicAPIError]
    
    /// The primary error from the response (first error in the array).
    public var primaryError: AppleMusicAPIError? {
        errors.first
    }
}

/// Represents a single error object from the Apple Music API.
///
/// This is the exact structure returned by Apple Music and contains all the
/// information provided by the service about what went wrong.
public struct AppleMusicAPIError: Codable, Equatable, LocalizedError, Sendable {
    /// A unique identifier for this occurrence of the error.
    public let id: String
    
    /// A link to more information about this error.
    public let about: String?
    
    /// The HTTP status code for this error.
    public let status: String
    
    /// Apple Music's application-specific error code.
    public let code: String
    
    /// A short, human-readable summary of the error.
    public let title: String
    
    /// A detailed explanation of this specific error occurrence.
    public let detail: String?
    
    /// Information about which part of the request caused the error.
    public let source: AppleMusicErrorSource?
    
    /// Additional metadata about the error.
    public let meta: AppleMusicErrorMeta?
    
    // MARK: - LocalizedError
    
    public var errorDescription: String? {
        var description = "Apple Music API Error"
        if !code.isEmpty {
            description += " (\(code))"
        }
        description += ": \(title)"
        if let detail = detail {
            description += " - \(detail)"
        }
        return description
    }
    
    public var localizedDescription: String {
        errorDescription ?? "Apple Music API Error"
    }
    
    public var failureReason: String? {
        title
    }
    
    public var recoverySuggestion: String? {
        detail
    }
}

/// Contains information about which part of the request caused an error.
public struct AppleMusicErrorSource: Codable, Equatable, Sendable {
    /// The name of the parameter that caused the error.
    public let parameter: String?
    
    /// A JSON Pointer to the part of the request that caused the error.
    public let pointer: String?
}

/// Contains additional metadata about an Apple Music API error.
public struct AppleMusicErrorMeta: Codable, Equatable, Sendable {
    /// Raw metadata from the Apple Music API.
    private let rawData: [String: String]
    
    /// Provides access to the raw metadata.
    public var additionalInfo: [String: String] {
        rawData
    }
    
    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: DynamicCodingKey.self)
        var data: [String: String] = [:]
        
        for key in container.allKeys {
            if let value = try? container.decode(String.self, forKey: key) {
                data[key.stringValue] = value
            }
        }
        
        self.rawData = data
    }
    
    public func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: DynamicCodingKey.self)
        for (key, value) in rawData {
            let codingKey = DynamicCodingKey(stringValue: key)!
            try container.encode(value, forKey: codingKey)
        }
    }
}

// MARK: - Dynamic Coding Key

/// A coding key that can represent any string key for flexible JSON decoding.
struct DynamicCodingKey: CodingKey, Sendable {
    var stringValue: String
    var intValue: Int?
    
    init?(stringValue: String) {
        self.stringValue = stringValue
        self.intValue = nil
    }
    
    init?(intValue: Int) {
        self.stringValue = String(intValue)
        self.intValue = intValue
    }
}