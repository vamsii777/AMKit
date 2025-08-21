import Foundation
import JWTKit

/// The JWT payload for Apple Music API authentication.
///
/// This payload is used to generate a signed JWT for authenticating requests to the Apple Music API.
/// It includes the required claims as specified by Apple, such as issuer, issued at, and expiration.
/// Optionally, an `origin` claim can be included for additional context.
///
/// - Note: The maximum allowed expiration is 6 months (15777000 seconds) from the issued at date.
public struct AppleMusicJWTPayload: JWTPayload {
    /// The issuer claim, representing your Apple Developer Team ID.
    public let iss: IssuerClaim

    /// The issued at claim, representing the time at which the token was generated.
    public let iat: IssuedAtClaim

    /// The expiration claim, representing the time at which the token expires.
    public let exp: ExpirationClaim

    /// The optional origin claim, which can be used to specify allowed origins.
    public let origin: [String]?
    
    /// Creates a new Apple Music JWT payload.
    ///
    /// - Parameters:
    ///   - teamID: Your Apple Developer Team ID.
    ///   - keyID: Your Apple Music API Key ID. (Unused in payload, but may be used for header.)
    ///   - issuedAt: The date and time at which the token is issued. Defaults to the current date and time.
    ///   - expiration: The date and time at which the token expires. Defaults to 6 months from now.
    ///   - origin: An optional array of allowed origins.
    public init(
        teamID: String,
        keyID: String,
        issuedAt: Date = Date(),
        expiration: Date = Date().addingTimeInterval(15777000), // 6 months max
        origin: [String]? = nil
    ) {
        self.iss = IssuerClaim(value: teamID)
        self.iat = IssuedAtClaim(value: issuedAt)
        self.exp = ExpirationClaim(value: expiration)
        self.origin = origin
    }
    
    /// Verifies the payload claims according to Apple Music API requirements.
    ///
    /// - Parameter algorithm: The JWT algorithm used for signing.
    /// - Throws: `JWTError.claimVerificationFailure` if the token is expired or the expiration exceeds 6 months.
    public func verify(using algorithm: some JWTAlgorithm) async throws {
        try self.exp.verifyNotExpired()
        
        let maxExpiration = self.iat.value.addingTimeInterval(15777000) // 6 months
        guard self.exp.value <= maxExpiration else {
            throw JWTError.claimVerificationFailure(
                failedClaim: self.exp,
                reason: "Token expiration exceeds maximum allowed duration of 6 months"
            )
        }
    }
}

extension AppleMusicJWTPayload {
    /// The coding keys for encoding and decoding the payload.
    enum CodingKeys: String, CodingKey {
        case iss, iat, exp, origin
    }
}