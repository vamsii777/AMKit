# AMKit
[![](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2Fvamsii777%2FAMKit%2Fbadge%3Ftype%3Dswift-versions)](https://swiftpackageindex.com/vamsii777/AMKit)
[![](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2Fvamsii777%2FAMKit%2Fbadge%3Ftype%3Dplatforms)](https://swiftpackageindex.com/vamsii777/AMKit)

AMKit is a modern, fluent Swift on Server SDK for Apple Music API.

## Installation

### Swift Package Manager

You can add AMKit to your project via Swift Package Manager (SPM) by adding the following dependency to your `Package.swift` file:

```swift
dependencies: [
    .package(url: "https://github.com/vamsii777/AMKit.git", branch: "main")
]
```

## Using the API

Initialize the `AMKit` actor with your Apple Music credentials. This actor will be your gateway to interacting with the Apple Music API.

```swift
import AMKit

// Using developer token
let amkit = AMKit(developerToken: "your-developer-token")

// Using JWT credentials
let amkit = try await AMKit(
    teamID: "YOUR_TEAM_ID",
    keyID: "YOUR_KEY_ID", 
    privateKey: """
    -----BEGIN PRIVATE KEY-----
    YOUR_PRIVATE_KEY_CONTENT
    -----END PRIVATE KEY-----
    """
)
```

And now you have access to the APIs via `amkit`.

The APIs you have available correspond to what's implemented.

For example to use the `artists` API, the AMKit actor has a property to access that API via routes.

#### Fetching an Artist

```swift
let artist = try await amkit.artists.fetch(
    "178834",
    from: .us,
    including: [.albums, .musicVideos],
    localization: .enUS
)
print("Fetched Artist: \(artist.data)
```

#### Fetching a Storefront

```swift
let storefront = try await amkit.storefronts.fetch(.us, localization: .enUS)
print("Fetched Storefront: \(storefront.data)
```

## What's Implemented

### Core Resources
* [x] **Artists** - Fetch artist information, albums, music videos, and related content
* [x] **Storefronts** - Access Apple Music storefront information and localization
* [ ] **Albums** - Browse and search albums (planned)
* [ ] **Songs** - Access song catalog and metadata (planned)
* [ ] **Playlists** - Manage and browse playlists (planned)
* [ ] **Search** - Search across Apple Music catalog (planned)
* [ ] **Charts** - Access music charts and trending content (planned)
* [ ] **Genres** - Browse music by genre (planned)

### Authentication & Security
* [x] **JWT Token Generation** - Automatic ES256 JWT token generation using your Apple Developer credentials
* [x] **Developer Token Support** - Direct developer token authentication

### Multiple Initialization Patterns

```swift
// Static factory methods
let amkit = AMKit.client(developerToken: "your-token")
let amkit = try await AMKit.client(teamID: "...", keyID: "...", privateKey: "...")

// Direct initialization
let amkit = AMKit(developerToken: "your-token")
let amkit = try await AMKit(teamID: "...", keyID: "...", privateKey: "...")

// Wrap existing AppleMusicClient
let client = AppleMusicClient(developerToken: "your-token")
let amkit = AMKit(client)

// From file
let amkit = try await AMKit(
    teamID: "YOUR_TEAM_ID",
    keyID: "YOUR_KEY_ID",
    privateKeyPath: "/path/to/AuthKey_YOUR_KEY_ID.p8"
)
```

## LICENSE

AMKit is available under the MIT license. See the [LICENSE](LICENSE) file for more info.