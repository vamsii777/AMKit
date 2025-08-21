import Foundation

/// A client for interacting with the Apple Music API
///
/// Use this actor to access Apple Music's catalog and user data services.
///
/// ## Overview
/// The AMKit client provides a Swift interface to Apple Music's APIs.
/// It handles authentication and provides type-safe access to various API endpoints.
///
/// ```swift
/// let client = AppleMusicClient(developerToken: "your-token")
/// let amkit = AMKit(client)
///
/// // Fetch an artist
/// let artist = try await amkit.artists.fetch(
///     "178834",
///     from: .us,
///     including: [.albums, .musicVideos],
///     localization: .enUS
/// )
/// ```
///
/// ## Topics
/// ### Creating a Client
/// - ``init(_:)``
/// - ``init(developerToken:)``
/// - ``init(teamID:keyID:privateKey:)``
/// - ``init(teamID:keyID:privateKeyPath:)``
///
/// ### Available Services
/// - ``artists``
/// - ``storefronts``
public actor AMKit {
    /// The underlying Apple Music client used for API requests
    private let client: AppleMusicClient

    /// Routes for interacting with Apple Music artists
    public let artists: ArtistsResource
    
    /// Routes for interacting with Apple Music storefronts
    public let storefronts: StorefrontsResource

    /// Creates a new AMKit client
    /// - Parameter appleMusicClient: The AppleMusicClient to use for API requests
    public init(_ appleMusicClient: AppleMusicClient) {
        self.client = appleMusicClient
        self.artists = appleMusicClient.artists
        self.storefronts = appleMusicClient.storefronts
    }
    
    /// Creates a new AMKit client with a developer token
    /// - Parameters:
    ///   - developerToken: A valid Apple Music API developer token
    ///   - configuration: The client configuration (defaults to `.default`)
    public init(
        developerToken: String,
        configuration: AppleMusicClientConfiguration = .default
    ) {
        self.client = AppleMusicClient(
            developerToken: developerToken,
            configuration: configuration
        )
        self.artists = self.client.artists
        self.storefronts = self.client.storefronts
    }
    
    /// Creates a new AMKit client with JWT credentials
    /// - Parameters:
    ///   - teamID: Your Apple Developer Team ID
    ///   - keyID: Your Apple Music API Key ID
    ///   - privateKey: Your ES256 private key as a string
    ///   - configuration: The client configuration (defaults to `.default`)
    public init(
        teamID: String,
        keyID: String,
        privateKey: String,
        configuration: AppleMusicClientConfiguration = .default
    ) async throws {
        self.client = try await AppleMusicClient(
            teamID: teamID,
            keyID: keyID,
            privateKey: privateKey,
            configuration: configuration
        )
        self.artists = self.client.artists
        self.storefronts = self.client.storefronts
    }
    
    /// Creates a new AMKit client with JWT credentials from a file
    /// - Parameters:
    ///   - teamID: Your Apple Developer Team ID
    ///   - keyID: Your Apple Music API Key ID
    ///   - privateKeyPath: Path to your ES256 private key file
    ///   - configuration: The client configuration (defaults to `.default`)
    public init(
        teamID: String,
        keyID: String,
        privateKeyPath: String,
        configuration: AppleMusicClientConfiguration = .default
    ) async throws {
        self.client = try await AppleMusicClient(
            teamID: teamID,
            keyID: keyID,
            privateKeyPath: privateKeyPath,
            configuration: configuration
        )
        self.artists = self.client.artists
        self.storefronts = self.client.storefronts
    }
}

// MARK: - Convenience Extensions

extension AMKit {
    
    /// Common storefront configurations for quick access.
    public enum Storefronts {
        /// Major English-speaking markets.
        public static let english: [AppleMusicStorefront] = [.us, .gb, .ca, .au]
        
        /// Major European markets.
        public static let europe: [AppleMusicStorefront] = [.gb, .de, .fr, .es, .it, .nl]
        
        /// Major Asian markets.
        public static let asia: [AppleMusicStorefront] = [.jp, .kr, .tw, .in]
        
        /// All major global markets.
        public static let global: [AppleMusicStorefront] = english + europe + asia
    }
    
    /// Common localization configurations for quick access.
    public enum Localizations {
        /// English localizations.
        public static let english: [AppleMusicLocalization] = [.enUS, .enGB, .enCA, .enAU]
        
        /// European localizations.
        public static let europe: [AppleMusicLocalization] = [.enGB, .deDE, .frFR, .esES, .itIT, .nlNL]
        
        /// Asian localizations.
        public static let asia: [AppleMusicLocalization] = [.jaJP, .koKR, .zhTW, .hiIN]
        
        /// Most commonly used localizations.
        public static let common = AppleMusicLocalization.common
    }
    
    /// Common artist include configurations for quick access.
    public enum ArtistIncludes {
        /// Media-related includes.
        public static let media: [ArtistInclude] = ArtistInclude.Combinations.media
        
        /// All available includes.
        public static let all: [ArtistInclude] = ArtistInclude.Combinations.full
        
        /// Essential includes for most use cases.
        public static let essential: [ArtistInclude] = [.albums, .musicVideos]
    }
}