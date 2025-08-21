import Foundation

// MARK: - Storefronts Resource

/// Provides access to storefront-related endpoints in the Apple Music API.
///
/// This resource allows you to fetch information about Apple Music storefronts,
/// including supported languages, explicit content policies, and regional settings.
public struct StorefrontsResource: AMResource {
    /// The underlying client used to make API requests.
    public let client: any AMClientProtocol
    
    /// Creates a new storefronts resource with the given client.
    /// - Parameter client: The API client to use for requests
    public init(client: any AMClientProtocol) {
        self.client = client
    }
    
    /// Fetches information about a specific storefront.
    /// - Parameters:
    ///   - storefront: The storefront to fetch information for
    ///   - localization: The localization for the response
    /// - Returns: The storefront response containing the requested storefront
    /// - Throws: An error if the request fails or the storefront is not found
    public func fetch(
        _ storefront: AppleMusicStorefront,
        localization: AppleMusicLocalization? = nil
    ) async throws -> StorefrontsResponse {
        var queryItems: [URLQueryItem] = []
        
        if let localization = localization {
            queryItems.append(URLQueryItem(name: "l", value: localization.rawValue))
        }
        
        let request = AMRequest(
            method: .GET,
            path: "/storefronts/\(storefront.rawValue)",
            queryItems: queryItems
        )
        
        return try await client.execute(request)
    }
    
    /// Fetches information about a specific storefront using a string identifier.
    /// - Parameters:
    ///   - id: The unique identifier for the storefront
    ///   - localization: The localization for the response
    /// - Returns: The storefront response containing the requested storefront
    /// - Throws: An error if the request fails or the storefront is not found
    public func fetch(
        id: String,
        localization: String? = nil
    ) async throws -> StorefrontsResponse {
        guard !id.isEmpty else {
            throw AMError.validation("Storefront ID cannot be empty")
        }
        
        var queryItems: [URLQueryItem] = []
        
        if let localization = localization {
            queryItems.append(URLQueryItem(name: "l", value: localization))
        }
        
        let request = AMRequest(
            method: .GET,
            path: "/storefronts/\(id)",
            queryItems: queryItems
        )
        
        return try await client.execute(request)
    }
    
    /// Fetches all available storefronts.
    /// - Parameters:
    ///   - limit: The maximum number of results to return
    ///   - offset: The offset for pagination
    ///   - localization: The localization for the response
    /// - Returns: The storefronts response containing available storefronts
    /// - Throws: An error if the request fails
    public func fetchAll(
        limit: Int? = nil,
        offset: Int? = nil,
        localization: AppleMusicLocalization? = nil
    ) async throws -> StorefrontsResponse {
        var queryItems: [URLQueryItem] = []
        
        if let limit = limit {
            queryItems.append(URLQueryItem(name: "limit", value: String(limit)))
        }
        
        if let offset = offset {
            queryItems.append(URLQueryItem(name: "offset", value: String(offset)))
        }
        
        if let localization = localization {
            queryItems.append(URLQueryItem(name: "l", value: localization.rawValue))
        }
        
        let request = AMRequest(
            method: .GET,
            path: "/storefronts",
            queryItems: queryItems
        )
        
        return try await client.execute(request)
    }
    
    /// Fetches all available storefronts using string-based localization.
    /// - Parameters:
    ///   - limit: The maximum number of results to return
    ///   - offset: The offset for pagination
    ///   - localization: The localization string for the response
    /// - Returns: The storefronts response containing available storefronts
    /// - Throws: An error if the request fails
    public func fetchAll(
        limit: Int? = nil,
        offset: Int? = nil,
        localization: String? = nil
    ) async throws -> StorefrontsResponse {
        var queryItems: [URLQueryItem] = []
        
        if let limit = limit {
            queryItems.append(URLQueryItem(name: "limit", value: String(limit)))
        }
        
        if let offset = offset {
            queryItems.append(URLQueryItem(name: "offset", value: String(offset)))
        }
        
        if let localization = localization {
            queryItems.append(URLQueryItem(name: "l", value: localization))
        }
        
        let request = AMRequest(
            method: .GET,
            path: "/storefronts",
            queryItems: queryItems
        )
        
        return try await client.execute(request)
    }
}