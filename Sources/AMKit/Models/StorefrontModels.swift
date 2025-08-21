import Foundation

// MARK: - Storefront Models

/// Represents a response containing storefront information from the Apple Music API.
///
/// This response structure contains one or more storefront objects that provide
/// information about Apple Music availability and localization in different regions.
public struct StorefrontsResponse: Codable, Sendable {
    /// An array of storefront objects.
    public let data: [Storefront]
    
    /// A relative cursor to fetch the next paginated collection of results.
    public let next: String?
    
    /// Information about the request or response.
    public let meta: ResponseMeta?
}

/// Represents a single storefront in the Apple Music service.
///
/// A storefront defines a region where Apple Music is available and provides
/// information about supported languages, currencies, and content availability.
public struct Storefront: Codable, Sendable {
    /// The persistent identifier for the storefront.
    public let id: String
    
    /// The type of the resource (always "storefronts").
    public let type: String
    
    /// A URL subpath that fetches the resource.
    public let href: String?
    
    /// The attributes for the storefront.
    public let attributes: StorefrontAttributes
}

/// Contains the attributes for a storefront.
///
/// These attributes provide detailed information about the storefront's
/// configuration, supported languages, and regional settings.
public struct StorefrontAttributes: Codable, Sendable {
    /// The default language tag for the storefront.
    public let defaultLanguageTag: String
    
    /// The name of the storefront.
    public let name: String
    
    /// Whether the storefront supports explicit content.
    public let explicitContentPolicy: String
    
    /// The supported language tags for the storefront.
    public let supportedLanguageTags: [String]
}

