import Foundation

// MARK: - Core Error Types

/// Represents different categories of errors that can occur in AMKit.
public enum AMErrorCategory: String, CaseIterable, Sendable, CustomStringConvertible {
    case network = "network"
    case parsing = "parsing"
    case validation = "validation"
    case api = "api"
    case unknown = "unknown"
    
    public var description: String { rawValue }
}

/// A lightweight error wrapper that preserves the original Apple Music API error.
///
/// This error type is designed to be transparent and show the actual API errors
/// from Apple Music while providing minimal categorization for error handling.
public struct AMError: Error, LocalizedError, Sendable {
    /// The category of error for basic error handling.
    public let category: AMErrorCategory
    
    /// The original Apple Music API error, if applicable.
    public let appleMusicError: AppleMusicAPIError?
    
    /// A simple message for non-API errors.
    public let message: String?
    
    /// The underlying system error, if applicable.
    public let underlyingError: String?
    
    /// Creates a network error.
    public static func network(_ error: any Error) -> AMError {
        AMError(
            category: .network,
            appleMusicError: nil,
            message: "Network error occurred",
            underlyingError: error.localizedDescription
        )
    }
    
    /// Creates a parsing error.
    public static func parsing(_ error: any Error) -> AMError {
        AMError(
            category: .parsing,
            appleMusicError: nil,
            message: "Failed to parse response",
            underlyingError: error.localizedDescription
        )
    }
    
    /// Creates a validation error.
    public static func validation(_ message: String) -> AMError {
        AMError(
            category: .validation,
            appleMusicError: nil,
            message: message,
            underlyingError: nil
        )
    }
    
    /// Creates an error from an Apple Music API error.
    public static func api(_ apiError: AppleMusicAPIError) -> AMError {
        AMError(
            category: .api,
            appleMusicError: apiError,
            message: nil,
            underlyingError: nil
        )
    }
    
    /// Creates an unknown error.
    public static func unknown(_ error: (any Error)? = nil) -> AMError {
        AMError(
            category: .unknown,
            appleMusicError: nil,
            message: "An unknown error occurred",
            underlyingError: error?.localizedDescription
        )
    }
    
    /// Creates an authentication error.
    public static func authentication(_ message: String) -> AMError {
        AMError(
            category: .network,
            appleMusicError: nil,
            message: message,
            underlyingError: nil
        )
    }
    
    /// Creates an authorization error.
    public static func authorization(_ message: String) -> AMError {
        AMError(
            category: .network,
            appleMusicError: nil,
            message: message,
            underlyingError: nil
        )
    }
    
    /// Creates a not found error.
    public static func notFound(_ message: String) -> AMError {
        AMError(
            category: .validation,
            appleMusicError: nil,
            message: message,
            underlyingError: nil
        )
    }
    
    /// Creates a rate limited error.
    public static func rateLimited() -> AMError {
        AMError(
            category: .validation,
            appleMusicError: nil,
            message: "Rate limit exceeded",
            underlyingError: nil
        )
    }
    
    /// Creates a server error.
    public static func server(_ statusCode: Int, message: String) -> AMError {
        AMError(
            category: .network,
            appleMusicError: nil,
            message: message,
            underlyingError: nil
        )
    }
    
    // MARK: - LocalizedError
    
    public var errorDescription: String? {
        if let appleMusicError = appleMusicError {
            return appleMusicError.localizedDescription
        }
        
        var description = "[\(category.rawValue)]"
        if let message = message {
            description += " \(message)"
        }
        if let underlyingError = underlyingError {
            description += ": \(underlyingError)"
        }
        return description
    }
    
    public var failureReason: String? {
        appleMusicError?.title ?? message
    }
    
    public var recoverySuggestion: String? {
        appleMusicError?.detail
    }
}