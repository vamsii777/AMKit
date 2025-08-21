import Foundation
import JWTKit

/// A generator for Apple Music API JWT developer tokens.
///
/// Use this class to create signed JWT tokens for authenticating requests to the Apple Music API.
/// Supports initialization from an in-memory ES256 private key, a PEM string, or a file path.
/// Tokens can be generated with custom expiration and optional origin claims.
///
/// - Note: The maximum allowed expiration for Apple Music tokens is 6 months.
public final class AppleMusicTokenGenerator: Sendable {
    private let keys: JWTKeyCollection
    private let teamID: String
    private let keyID: String

    /// Initializes the token generator with an in-memory ES256 private key.
    ///
    /// - Parameters:
    ///   - teamID: Your Apple Developer Team ID.
    ///   - keyID: Your Apple Music API Key ID.
    ///   - privateKey: The ES256 private key.
    public init(
        teamID: String,
        keyID: String,
        privateKey: ES256PrivateKey
    ) async throws {
        self.teamID = teamID
        self.keyID = keyID
        self.keys = JWTKeyCollection()
        await keys.add(ecdsa: privateKey, kid: JWKIdentifier(string: keyID))
    }
    
    /// Initializes the token generator with a PEM-encoded ES256 private key string.
    ///
    /// - Parameters:
    ///   - teamID: Your Apple Developer Team ID.
    ///   - keyID: Your Apple Music API Key ID.
    ///   - privateKey: The ES256 private key as a PEM string.
    public init(
        teamID: String,
        keyID: String,
        privateKey: String
    ) async throws {
        self.teamID = teamID
        self.keyID = keyID
        self.keys = JWTKeyCollection()
        
        let key = try ES256PrivateKey(pem: privateKey)
        await keys.add(ecdsa: key, kid: JWKIdentifier(string: keyID))
    }
    
    /// Initializes the token generator with a file path to a PEM-encoded ES256 private key.
    ///
    /// - Parameters:
    ///   - teamID: Your Apple Developer Team ID.
    ///   - keyID: Your Apple Music API Key ID.
    ///   - privateKeyPath: The file path to the ES256 private key in PEM format.
    /// - Throws: `AppleMusicAuthenticationError.invalidPrivateKey` if the file cannot be read or parsed.
    public init(
        teamID: String,
        keyID: String,
        privateKeyPath: String
    ) async throws {
        self.teamID = teamID
        self.keyID = keyID
        self.keys = JWTKeyCollection()
        
        let privateKeyData = try Data(contentsOf: URL(fileURLWithPath: privateKeyPath))
        guard let privateKeyString = String(data: privateKeyData, encoding: .utf8) else {
            throw AppleMusicAuthenticationError.invalidPrivateKey("Unable to read private key file")
        }
        
        let key = try ES256PrivateKey(pem: privateKeyString)
        await keys.add(ecdsa: key, kid: JWKIdentifier(string: keyID))
    }
    
    /// Generates a signed Apple Music developer token (JWT).
    ///
    /// - Parameters:
    ///   - expiration: The expiration date for the token. Defaults to 1 hour from now.
    ///   - origin: An optional array of allowed origins for the token.
    /// - Returns: A signed JWT as a `String`.
    /// - Throws: Any error thrown during signing or payload creation.
    public func generateToken(
        expiration: Date = Date().addingTimeInterval(3600), // 1 hour default
        origin: [String]? = nil
    ) async throws -> String {
        let payload = AppleMusicJWTPayload(
            teamID: teamID,
            keyID: keyID,
            expiration: expiration,
            origin: origin
        )
        
        return try await keys.sign(payload, kid: JWKIdentifier(string: keyID))
    }
    
    /// Generates a long-lived Apple Music developer token (up to 6 months).
    ///
    /// - Parameters:
    ///   - months: The number of months until expiration (maximum 6). Defaults to 6.
    ///   - origin: An optional array of allowed origins for the token.
    /// - Returns: A signed JWT as a `String`.
    /// - Throws: `AppleMusicAuthenticationError.invalidExpiration` if the requested duration exceeds 6 months.
    public func generateLongLivedToken(
        months: Int = 6,
        origin: [String]? = nil
    ) async throws -> String {
        guard months <= 6 else {
            throw AppleMusicAuthenticationError.invalidExpiration("Token expiration cannot exceed 6 months")
        }
        
        let expiration = Calendar.current.date(
            byAdding: .month,
            value: months,
            to: Date()
        ) ?? Date().addingTimeInterval(15777000) // Fallback to 6 months in seconds
        
        return try await generateToken(expiration: expiration, origin: origin)
    }
}

/// Errors that can occur during Apple Music authentication and token generation.
public enum AppleMusicAuthenticationError: Error, LocalizedError {
    /// The provided private key is invalid or could not be parsed.
    case invalidPrivateKey(String)
    /// The requested expiration is invalid (e.g., exceeds 6 months).
    case invalidExpiration(String)
    /// The key generation process failed.
    case keyGenerationFailed(String)
    
    public var errorDescription: String? {
        switch self {
        case .invalidPrivateKey(let message):
            return "Invalid private key: \(message)"
        case .invalidExpiration(let message):
            return "Invalid expiration: \(message)"
        case .keyGenerationFailed(let message):
            return "Key generation failed: \(message)"
        }
    }
}