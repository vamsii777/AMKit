import Foundation

// MARK: - Artists Resource

/// Provides access to artist-related endpoints in the Apple Music API.
/// 
/// This resource allows you to fetch artist information, including their catalog details,
/// albums, music videos, and other related content.
public struct ArtistsResource: AMResource {
    /// The underlying client used to make API requests.
    public let client: any AMClientProtocol
    
    /// Creates a new artists resource with the given client.
    /// - Parameter client: The API client to use for requests
    public init(client: any AMClientProtocol) {
        self.client = client
    }
    
    /// Provides direct access to artist catalog operations.
    public var catalog: ArtistsCatalogResource {
        ArtistsCatalogResource(client: client)
    }
    
    /// Fetches an artist from the catalog with the specified parameters.
    /// - Parameters:
    ///   - id: The unique identifier for the artist
    ///   - storefront: The storefront to search in (defaults to US)
    ///   - relationships: Related resources to include in the response
    ///   - localization: The localization for the response
    /// - Returns: The artist response containing the requested artist
    /// - Throws: An error if the request fails or the artist is not found
    public func fetch(
        _ id: String,
        from storefront: AppleMusicStorefront = .us,
        including relationships: [ArtistInclude] = [],
        localization: AppleMusicLocalization? = nil
    ) async throws -> ArtistResponse {
        try await catalog.fetch(
            id: id,
            storefront: storefront,
            include: relationships.isEmpty ? nil : relationships,
            localization: localization
        )
    }
}

// MARK: - Artists Catalog Resource

/// Provides access to artist catalog operations in the Apple Music API.
/// 
/// This resource handles direct catalog requests for artist data, including
/// validation, request building, and response processing.
public struct ArtistsCatalogResource: CatalogResource {
    public typealias CatalogItem = Artist
    public typealias CatalogResponse = ArtistResponse
    public typealias IncludeType = ArtistInclude
    
    /// The underlying client used to make API requests.
    public let client: any AMClientProtocol
    
    /// Creates a new artists catalog resource with the given client.
    /// - Parameter client: The API client to use for requests
    public init(client: any AMClientProtocol) {
        self.client = client
    }
    
    // MARK: - CatalogResource Implementation
    
    /// Fetches an artist from the catalog by its identifier.
    /// - Parameters:
    ///   - id: The unique identifier for the artist
    ///   - storefront: The storefront to search in
    ///   - include: Related resources to include in the response
    ///   - localization: The localization for the response
    /// - Returns: The artist response containing the requested artist
    /// - Throws: An error if the request fails or the artist is not found
    public func fetch(
        id: String,
        storefront: AppleMusicStorefront,
        include: [IncludeType]?,
        localization: AppleMusicLocalization?
    ) async throws -> ArtistResponse {
        guard !id.isEmpty else {
            throw AMError.validation("Artist ID cannot be empty")
        }
        
        let storefrontString = storefront.rawValue
        guard storefrontString.count == 2 else {
            throw AMError.validation("Invalid storefront code")
        }
        
        var queryItems: [URLQueryItem] = []
        
        if let include = include, !include.isEmpty {
            queryItems.append(URLQueryItem(name: "include", value: include.map(\.rawValue).joined(separator: ",")))
        }
        
        if let localization = localization {
            queryItems.append(URLQueryItem(name: "l", value: localization.rawValue))
        }
        
        let request = AMRequest(
            method: .GET,
            path: "/catalog/\(storefrontString)/artists/\(id)",
            queryItems: queryItems
        )
        
        return try await client.execute(request)
    }
    
    
}

// MARK: - Artist Include Options

/// Represents the related resources that can be included in artist requests.
/// 
/// Use these values to specify which related content should be included
/// in the response when fetching artist information.
public enum ArtistInclude: String, CaseIterable, Sendable, CustomStringConvertible {
    /// Include the artist's albums in the response.
    case albums
    
    /// Include the artist's music videos in the response.
    case musicVideos = "music-videos"
    
    /// Include playlists featuring the artist in the response.
    case playlists
    
    /// Include the artist's station in the response.
    case station
    
    /// Include genre information for the artist in the response.
    case genres
    
    public var description: String { rawValue }
    
    /// All available include options.
    public static let all: [ArtistInclude] = ArtistInclude.allCases
    
    /// Common combinations of include options for convenience.
    public struct Combinations {
        /// Media-related content (albums and music videos).
        public static let media: [ArtistInclude] = [.albums, .musicVideos]
        
        /// Discovery-related content (albums, playlists, and station).
        public static let discovery: [ArtistInclude] = [.albums, .playlists, .station]
        
        /// All available content types.
        public static let full: [ArtistInclude] = [.albums, .musicVideos, .playlists, .station, .genres]
    }
}

// MARK: - Convenience Extensions

extension ArtistsCatalogResource {
    /// Convenience method with more natural parameter names
    public func fetch(
        _ id: String,
        from storefront: AppleMusicStorefront,
        including relationships: [ArtistInclude] = [],
        localization: AppleMusicLocalization? = nil
    ) async throws -> ArtistResponse {
        try await fetch(
            id: id,
            storefront: storefront,
            include: relationships.isEmpty ? nil : relationships,
            localization: localization
        )
    }
    
    /// Get a single artist (first from the response)
    public func fetchArtist(
        _ id: String,
        from storefront: AppleMusicStorefront
    ) async throws -> Artist? {
        let response = try await fetch(id: id, storefront: storefront, include: nil, localization: nil)
        return response.data.first
    }
    
}