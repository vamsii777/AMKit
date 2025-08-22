import Foundation

// MARK: - Songs Resource

/// Provides access to song-related endpoints in the Apple Music API.
/// 
/// This resource allows you to fetch song information, including their catalog details,
/// artists, albums, and other related content.
public struct SongsResource: AMResource {
    /// The underlying client used to make API requests.
    public let client: any AMClientProtocol
    
    /// Creates a new songs resource with the given client.
    /// - Parameter client: The API client to use for requests
    public init(client: any AMClientProtocol) {
        self.client = client
    }
    
    /// Provides direct access to song catalog operations.
    public var catalog: SongsCatalogResource {
        SongsCatalogResource(client: client)
    }
    
    /// Fetches a song from the catalog with the specified parameters.
    /// - Parameters:
    ///   - id: The unique identifier for the song
    ///   - storefront: The storefront to search in (defaults to US)
    ///   - relationships: Related resources to include in the response
    ///   - localization: The localization for the response
    /// - Returns: The song response containing the requested song
    /// - Throws: An error if the request fails or the song is not found
    public func fetch(
        _ id: String,
        from storefront: AppleMusicStorefront = .us,
        including relationships: [SongInclude] = [],
        localization: AppleMusicLocalization? = nil
    ) async throws -> SingleSongResponse {
        try await catalog.fetch(
            id: id,
            storefront: storefront,
            include: relationships.isEmpty ? nil : relationships,
            localization: localization
        )
    }
    
    /// Fetches multiple songs from the catalog with the specified parameters.
    /// - Parameters:
    ///   - ids: The unique identifiers for the songs
    ///   - storefront: The storefront to search in (defaults to US)
    ///   - relationships: Related resources to include in the response
    ///   - localization: The localization for the response
    /// - Returns: The song response containing the requested songs
    /// - Throws: An error if the request fails
    public func fetch(
        _ ids: [String],
        from storefront: AppleMusicStorefront = .us,
        including relationships: [SongInclude] = [],
        localization: AppleMusicLocalization? = nil
    ) async throws -> SongResponse {
        try await catalog.fetchMultiple(
            ids: ids,
            storefront: storefront,
            include: relationships.isEmpty ? nil : relationships,
            localization: localization
        )
    }
}

// MARK: - Songs Catalog Resource

/// Provides access to song catalog operations in the Apple Music API.
/// 
/// This resource handles direct catalog requests for song data, including
/// validation, request building, and response processing.
public struct SongsCatalogResource: CatalogResource {
    public typealias CatalogItem = Song
    public typealias CatalogResponse = SingleSongResponse
    public typealias IncludeType = SongInclude
    
    /// The underlying client used to make API requests.
    public let client: any AMClientProtocol
    
    /// Creates a new songs catalog resource with the given client.
    /// - Parameter client: The API client to use for requests
    public init(client: any AMClientProtocol) {
        self.client = client
    }
    
    // MARK: - CatalogResource Implementation
    
    /// Fetches a song from the catalog by its identifier.
    /// - Parameters:
    ///   - id: The unique identifier for the song
    ///   - storefront: The storefront to search in
    ///   - include: Related resources to include in the response
    ///   - localization: The localization for the response
    /// - Returns: The song response containing the requested song
    /// - Throws: An error if the request fails or the song is not found
    public func fetch(
        id: String,
        storefront: AppleMusicStorefront,
        include: [IncludeType]?,
        localization: AppleMusicLocalization?
    ) async throws -> SingleSongResponse {
        guard !id.isEmpty else {
            throw AMError.validation("Song ID cannot be empty")
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
            path: "/catalog/\(storefrontString)/songs/\(id)",
            queryItems: queryItems
        )
        
        return try await client.execute(request)
    }
    
    /// Fetches multiple songs from the catalog by their identifiers.
    /// - Parameters:
    ///   - ids: The unique identifiers for the songs
    ///   - storefront: The storefront to search in
    ///   - include: Related resources to include in the response
    ///   - localization: The localization for the response
    /// - Returns: The song response containing the requested songs
    /// - Throws: An error if the request fails
    public func fetchMultiple(
        ids: [String],
        storefront: AppleMusicStorefront,
        include: [SongInclude]?,
        localization: AppleMusicLocalization?
    ) async throws -> SongResponse {
        guard !ids.isEmpty else {
            throw AMError.validation("Song IDs cannot be empty")
        }
        
        guard ids.allSatisfy({ !$0.isEmpty }) else {
            throw AMError.validation("Individual song IDs cannot be empty")
        }
        
        let storefrontString = storefront.rawValue
        guard storefrontString.count == 2 else {
            throw AMError.validation("Invalid storefront code")
        }
        
        var queryItems: [URLQueryItem] = []
        
        // Add the IDs as a comma-separated list
        queryItems.append(URLQueryItem(name: "ids", value: ids.joined(separator: ",")))
        
        if let include = include, !include.isEmpty {
            queryItems.append(URLQueryItem(name: "include", value: include.map(\.rawValue).joined(separator: ",")))
        }
        
        if let localization = localization {
            queryItems.append(URLQueryItem(name: "l", value: localization.rawValue))
        }
        
        let request = AMRequest(
            method: .GET,
            path: "/catalog/\(storefrontString)/songs",
            queryItems: queryItems
        )
        
        return try await client.execute(request)
    }
}

// MARK: - Convenience Extensions

extension SongsCatalogResource {
    /// Convenience method with more natural parameter names for single song fetch
    public func fetch(
        _ id: String,
        from storefront: AppleMusicStorefront,
        including relationships: [SongInclude] = [],
        localization: AppleMusicLocalization? = nil
    ) async throws -> SingleSongResponse {
        try await self.fetch(
            id: id,
            storefront: storefront,
            include: relationships.isEmpty ? nil : relationships,
            localization: localization
        )
    }
    
    /// Convenience method with more natural parameter names for multiple songs fetch
    public func fetch(
        _ ids: [String],
        from storefront: AppleMusicStorefront,
        including relationships: [SongInclude] = [],
        localization: AppleMusicLocalization? = nil
    ) async throws -> SongResponse {
        try await fetchMultiple(
            ids: ids,
            storefront: storefront,
            include: relationships.isEmpty ? nil : relationships,
            localization: localization
        )
    }
}