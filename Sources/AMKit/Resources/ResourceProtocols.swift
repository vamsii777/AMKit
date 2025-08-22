import Foundation
import AsyncHTTPClient
import NIOCore
import NIOHTTP1

// MARK: - Core Resource Protocols

/// A protocol for Apple Music API resource types.
/// 
/// All resource types (artists, albums, playlists, etc.) conform to this protocol
/// to provide a consistent interface for accessing the API client.
public protocol AMResource: Sendable {
    /// The underlying client used to make API requests.
    var client: any AMClientProtocol { get }
    
    /// Creates a new resource instance with the given client.
    /// - Parameter client: The API client to use for requests
    init(client: any AMClientProtocol)
}

/// A protocol for Apple Music API clients.
/// 
/// Clients conforming to this protocol can execute API requests and return decoded responses.
public protocol AMClientProtocol: Sendable {
    /// Executes an API request and returns the decoded response.
    /// - Parameter request: The request to execute
    /// - Returns: The decoded response of the specified type
    /// - Throws: An error if the request fails or response cannot be decoded
    func execute<T: Codable & Sendable>(_ request: AMRequest) async throws -> T
}

// MARK: - Request Building

/// Represents an API request to the Apple Music service.
/// 
/// This structure encapsulates all the necessary information to make an HTTP request
/// to the Apple Music API, including the HTTP method, path, query parameters, and headers.
public struct AMRequest: Sendable {
    /// The HTTP method for the request.
    public let method: HTTPMethod
    
    /// The API path for the request.
    public let path: String
    
    /// Query parameters to include in the request URL.
    public let queryItems: [URLQueryItem]
    
    /// Additional HTTP headers for the request.
    public let headers: HTTPHeaders
    
    /// Creates a new API request.
    /// - Parameters:
    ///   - method: The HTTP method (defaults to GET)
    ///   - path: The API path
    ///   - queryItems: Query parameters (defaults to empty)
    ///   - headers: Additional headers (defaults to empty)
    public init(
        method: HTTPMethod = .GET,
        path: String,
        queryItems: [URLQueryItem] = [],
        headers: HTTPHeaders = HTTPHeaders()
    ) {
        self.method = method
        self.path = path
        self.queryItems = queryItems
        self.headers = headers
    }
    
    /// Builds the complete URL for this request.
    /// - Parameter baseURL: The base URL for the API
    /// - Returns: The complete URL, or nil if construction fails
    public func buildURL(baseURL: String) -> URL? {
        var components = URLComponents(string: baseURL + path)
        if !queryItems.isEmpty {
            components?.queryItems = queryItems
        }
        return components?.url
    }
}

// MARK: - Catalog Resource Protocol

/// A protocol for resources that provide access to Apple Music catalog content.
/// 
/// Catalog resources represent content available in the Apple Music catalog,
/// such as artists, albums, songs, and playlists.
public protocol CatalogResource: AMResource {
    /// The type of catalog item this resource provides.
    associatedtype CatalogItem: Codable & Sendable
    
    /// The type of response returned by catalog requests.
    associatedtype CatalogResponse: Codable & Sendable
    
    /// The type of include options for this resource.
    associatedtype IncludeType: RawRepresentable & Sendable where IncludeType.RawValue == String
    
    /// Fetches a single catalog item by its identifier.
    /// - Parameters:
    ///   - id: The unique identifier for the catalog item
    ///   - storefront: The storefront to search in
    ///   - include: Related resources to include in the response
    ///   - localization: The localization for the response
    /// - Returns: The catalog response containing the requested item
    /// - Throws: An error if the request fails or the item is not found
    func fetch(
        id: String,
        storefront: AppleMusicStorefront,
        include: [IncludeType]?,
        localization: AppleMusicLocalization?
    ) async throws -> CatalogResponse
}



// MARK: - Note
// Error handling has been moved to Core/Errors module for modularity.
// See AMError.swift and AppleMusicAPIError.swift for the complete error system.

