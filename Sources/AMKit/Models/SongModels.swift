import Foundation

// MARK: - Song Response Models

/// A response object containing an array of songs and pagination metadata from the Apple Music API.
public struct SongResponse: Codable, Sendable {
    /// The array of song resources returned by the API.
    public let data: [Song]
    /// The URL for the current resource.
    public let href: String?
    /// The URL for the next page of results, if available.
    public let next: String?
    /// Metadata about the response, such as total count and filters.
    public let meta: ResponseMeta?
}

/// A response object containing a single song resource from the Apple Music API.
public struct SingleSongResponse: Codable, Sendable {
    /// The song resource returned by the API.
    public let data: [Song]
    /// The URL for the current resource.
    public let href: String?
    /// Metadata about the response.
    public let meta: ResponseMeta?
}

/// Represents a song resource from the Apple Music API.
public struct Song: Codable, Sendable, Identifiable {
    /// The unique identifier for the song.
    public let id: String
    /// The type of the resource (should be "songs").
    public let type: String
    /// The URL for the song resource.
    public let href: String
    /// The attributes describing the song.
    public let attributes: SongAttributes
    /// The relationships to other resources (e.g., artists, albums).
    public let relationships: SongRelationships?
}

/// Attributes describing a song, such as name, artist, album, and playback information.
public struct SongAttributes: Codable, Sendable {
    /// The name of the song.
    public let name: String
    /// The name of the artist who performed the song.
    public let artistName: String
    /// The name of the album that contains the song.
    public let albumName: String
    /// The duration of the song in milliseconds.
    public let durationInMillis: Int?
    /// The genres associated with the song.
    public let genreNames: [String]
    /// The release date of the song.
    public let releaseDate: String?
    /// The International Standard Recording Code (ISRC) for the song.
    public let isrc: String?
    /// The artwork associated with the song.
    public let artwork: Artwork?
    /// The composer of the song.
    public let composerName: String?
    /// Editorial notes about the song, if available.
    public let editorialNotes: EditorialNotes?
    /// The Apple Music web URL for the song.
    public let url: String
    /// The disc number in the album.
    public let discNumber: Int?
    /// The track number on the disc.
    public let trackNumber: Int?
    /// Indicates if the song has lyrics available.
    public let hasLyrics: Bool?
    /// Indicates if the song contains explicit content.
    public let contentRating: String?
    /// A preview URL for the song (30-second sample).
    public let previews: [Preview]?
    /// The playback parameters for the song.
    public let playParams: PlayParameters?
    
    enum CodingKeys: String, CodingKey {
        case name, artistName, albumName, durationInMillis, genreNames, releaseDate
        case isrc, artwork, composerName, editorialNotes, url, discNumber, trackNumber
        case hasLyrics, contentRating, previews, playParams
    }
}

/// Preview information for a song, including URL and artwork.
public struct Preview: Codable, Sendable {
    /// The URL for the preview audio.
    public let url: String
    /// The artwork associated with the preview, if different from the main artwork.
    public let artwork: Artwork?
}

/// Playback parameters for a song in Apple Music.
public struct PlayParameters: Codable, Sendable {
    /// The unique identifier used for playback.
    public let id: String
    /// The kind of content (e.g., "song").
    public let kind: String
    /// Indicates if the song can be purchased.
    public let purchaseDate: String?
    /// Catalog identifier for playback.
    public let catalogId: String?
}

/// Relationships from a song to other resources, such as artists, albums, and composers.
public struct SongRelationships: Codable, Sendable {
    /// The relationship to the song's artists.
    public let artists: ResourceRelationship?
    /// The relationship to the song's albums.
    public let albums: ResourceRelationship?
    /// The relationship to the song's genres.
    public let genres: ResourceRelationship?
    /// The relationship to the song's composers.
    public let composers: ResourceRelationship?
    /// The relationship to the song's station.
    public let station: ResourceRelationship?
    /// The relationship to the song's music videos.
    public let musicVideos: ResourceRelationship?
    
    enum CodingKeys: String, CodingKey {
        case artists, albums, genres, composers, station
        case musicVideos = "music-videos"
    }
}

// MARK: - Song Include Options

/// Options for including related resources when fetching songs.
public enum SongInclude: String, CaseIterable, Sendable {
    /// Include artists related to the song.
    case artists = "artists"
    /// Include albums related to the song.
    case albums = "albums"
    /// Include genres related to the song.
    case genres = "genres"
    /// Include composers related to the song.
    case composers = "composers"
    /// Include the station related to the song.
    case station = "station"
    /// Include music videos related to the song.
    case musicVideos = "music-videos"
    
    /// All available include options for songs.
    public static var all: [SongInclude] {
        return SongInclude.allCases
    }
}