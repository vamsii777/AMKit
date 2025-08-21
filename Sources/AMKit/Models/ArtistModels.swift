import Foundation

// MARK: - Artist Response Models

/// A response object containing an array of artists and pagination metadata from the Apple Music API.
public struct ArtistResponse: Codable, Sendable {
    /// The array of artist resources returned by the API.
    public let data: [Artist]
    /// The URL for the current resource.
    public let href: String?
    /// The URL for the next page of results, if available.
    public let next: String?
    /// Metadata about the response, such as total count and filters.
    public let meta: ResponseMeta?
}

/// Represents an artist resource from the Apple Music API.
public struct Artist: Codable, Sendable, Identifiable {
    /// The unique identifier for the artist.
    public let id: String
    /// The type of the resource (should be "artists").
    public let type: String
    /// The URL for the artist resource.
    public let href: String
    /// The attributes describing the artist.
    public let attributes: ArtistAttributes
    /// The relationships to other resources (e.g., albums, genres).
    public let relationships: ArtistRelationships?
}

/// Attributes describing an artist, such as name, genres, and artwork.
public struct ArtistAttributes: Codable, Sendable {
    /// The name of the artist.
    public let name: String
    /// The genres associated with the artist.
    public let genreNames: [String]
    /// Editorial notes about the artist, if available.
    public let editorialNotes: EditorialNotes?
    /// The artwork associated with the artist, if available.
    public let artwork: Artwork?
    /// The Apple Music web URL for the artist.
    public let url: String
}

/// Editorial notes for an artist, such as short and standard descriptions.
public struct EditorialNotes: Codable, Sendable {
    /// A short editorial note, if available.
    public let short: String?
    /// A standard (longer) editorial note, if available.
    public let standard: String?
    /// The name of the editor or source, if available.
    public let name: String?
    /// A tagline for the artist, if available.
    public let tagline: String?
}

/// Artwork information for an artist, including dimensions and color details.
public struct Artwork: Codable, Sendable {
    /// The width of the artwork image.
    public let width: Int
    /// The height of the artwork image.
    public let height: Int
    /// The URL template for the artwork image, with `{w}` and `{h}` placeholders for dimensions.
    public let url: String
    /// The background color for the artwork, if available.
    public let bgColor: String?
    /// The first text color for overlaying on the artwork, if available.
    public let textColor1: String?
    /// The second text color for overlaying on the artwork, if available.
    public let textColor2: String?
    /// The third text color for overlaying on the artwork, if available.
    public let textColor3: String?
    /// The fourth text color for overlaying on the artwork, if available.
    public let textColor4: String?
    
    /// Returns the artwork URL with the specified width and height.
    /// - Parameters:
    ///   - width: The desired width of the artwork.
    ///   - height: The desired height of the artwork.
    /// - Returns: The artwork URL with the width and height placeholders replaced.
    public func url(width: Int, height: Int) -> String {
        return url.replacingOccurrences(of: "{w}", with: "\(width)")
                  .replacingOccurrences(of: "{h}", with: "\(height)")
    }
}

/// Relationships from an artist to other resources, such as albums and genres.
public struct ArtistRelationships: Codable, Sendable {
    /// The relationship to the artist's albums.
    public let albums: ResourceRelationship?
    /// The relationship to the artist's genres.
    public let genres: ResourceRelationship?
    /// The relationship to the artist's music videos.
    public let musicVideos: ResourceRelationship?
    /// The relationship to the artist's playlists.
    public let playlists: ResourceRelationship?
    /// The relationship to the artist's station.
    public let station: ResourceRelationship?
    
    enum CodingKeys: String, CodingKey {
        case albums, genres, playlists, station
        case musicVideos = "music-videos"
    }
}

/// A relationship to a collection of related resources, such as albums or genres.
public struct ResourceRelationship: Codable, Sendable {
    /// The URL for the related resource.
    public let href: String?
    /// The URL for the next page of related resources, if available.
    public let next: String?
    /// The array of related resource objects.
    public let data: [ResourceObject]?
}

/// A minimal representation of a related resource, such as an album or genre.
public struct ResourceObject: Codable, Sendable, Identifiable {
    /// The unique identifier for the related resource.
    public let id: String
    /// The type of the related resource (e.g., "albums", "genres").
    public let type: String
    /// The URL for the related resource.
    public let href: String
}

/// Metadata about a response, such as total count and applied filters.
/// 
/// - Note: Filters are simplified to `[String: String]` for Swift 6 Sendable compliance.
public struct ResponseMeta: Codable, Sendable {
    /// The total number of resources available.
    public let total: Int?
    
    /// The filters applied to the response, as key-value pairs.
    /// In practice, Apple Music API filters are typically strings.
    public let filters: [String: String]?
    
    enum CodingKeys: String, CodingKey {
        case total, filters
    }
}