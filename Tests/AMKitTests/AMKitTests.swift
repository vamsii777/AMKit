import Foundation
import AsyncHTTPClient
import JWTKit
import XCTest
@testable import AMKit

// MARK: - Apple Music Client Tests

final class AppleMusicClientTests: XCTestCase {
    
    func testClientInitializationWithToken() async throws {
        let client = AppleMusicClient(
            developerToken: "test-token",
            configuration: .default
        )
        
        // Client should be created successfully
        XCTAssertTrue(type(of: client.artists) == ArtistsResource.self)
        XCTAssertTrue(type(of: client.storefronts) == StorefrontsResource.self)
    }
    
    func testClientInitializationWithTokenGenerator() async throws {
        let privateKey = ES256PrivateKey()
        let privateKeyPEM = privateKey.pemRepresentation
        
        let tokenGenerator = try await AppleMusicTokenGenerator(
            teamID: "ABC123DEFG",
            keyID: "DEF456GHIJ",
            privateKey: privateKeyPEM
        )
        
        let client = AppleMusicClient(
            tokenGenerator: tokenGenerator,
            configuration: .default
        )
        
        // Client should be created successfully
        XCTAssertTrue(type(of: client.artists) == ArtistsResource.self)
    }
    
    func testFluentClientInitializationWithJWTCredentials() async throws {
        let privateKey = ES256PrivateKey()
        let privateKeyPEM = privateKey.pemRepresentation
        
        // Test fluent API with JWT credentials
        let client = try await AppleMusicClient(
            teamID: "ABC123DEFG",
            keyID: "DEF456GHIJ",
            privateKey: privateKeyPEM,
            configuration: .default
        )
        
        // Client should be created successfully
        XCTAssertTrue(type(of: client.artists) == ArtistsResource.self)
        XCTAssertTrue(type(of: client.storefronts) == StorefrontsResource.self)
    }
    
    func testFluentStructuredConcurrencyWithJWTCredentials() async throws {
        let privateKey = ES256PrivateKey()
        let privateKeyPEM = privateKey.pemRepresentation
        
        // Test structured concurrency with JWT credentials
        do {
            let _ = try await AppleMusicClient.withClient(
                teamID: "ABC123DEFG",
                keyID: "DEF456GHIJ",
                privateKey: privateKeyPEM
            ) { client in
                return try await client.artists.catalog.fetch(
                    id: "test-id",
                    storefront: .us,
                    include: [.albums],
                    localization: .enUS
                )
            }
            XCTFail("Should fail due to invalid credentials")
        } catch {
            // Expected to fail due to invalid credentials, but API signature works
            XCTAssertTrue(true)
        }
    }
    
    func testDeveloperTokenStructuredConcurrency() async throws {
        // Test the developer token variant of structured concurrency
        do {
            let _ = try await AppleMusicClient.withClient(
                developerToken: "test-token",
                configuration: .default
            ) { client in
                return try await client.artists.catalog.fetch(
                    id: "",
                    storefront: .us,
                    include: nil as [ArtistInclude]?,
                    localization: nil
                )
            }
            XCTFail("Should fail for empty ID")
        } catch let error as AMError {
            XCTAssertEqual(error.category, .validation)
        }
    }
}

// MARK: - AMKit Main Entry Point Tests

final class AMKitMainEntryTests: XCTestCase {
    
    func testAMKitClientFactoryWithDeveloperToken() async {
        let amkit = AMKit.client(developerToken: "test-token")
        
        let artistsType = await type(of: amkit.artists)
        let storefrontsType = await type(of: amkit.storefronts)
        
        XCTAssertTrue(artistsType == ArtistsResource.self)
        XCTAssertTrue(storefrontsType == StorefrontsResource.self)
    }
    
    func testAMKitClientFactoryWithJWTCredentials() async throws {
        let privateKey = ES256PrivateKey()
        let privateKeyPEM = privateKey.pemRepresentation
        
        let amkit = try await AMKit.client(
            teamID: "ABC123DEFG",
            keyID: "DEF456GHIJ",
            privateKey: privateKeyPEM
        )
        
        let artistsType = await type(of: amkit.artists)
        let storefrontsType = await type(of: amkit.storefronts)
        
        XCTAssertTrue(artistsType == ArtistsResource.self)
        XCTAssertTrue(storefrontsType == StorefrontsResource.self)
    }
    
    func testAMKitQuickFetchArtist() async throws {
        do {
            let _ = try await AMKit.fetchArtist(
                "test-id",
                developerToken: "test-token",
                from: .us,
                including: [.albums],
                localization: .enUS
            )
            XCTFail("Should fail due to invalid token")
        } catch {
            // Expected to fail due to invalid token, but API signature works
            XCTAssertTrue(true)
        }
    }
    
    func testAMKitQuickFetchStorefront() async throws {
        do {
            let _ = try await AMKit.fetchStorefront(
                .us,
                developerToken: "test-token",
                localization: .enUS
            )
            XCTFail("Should fail due to invalid token")
        } catch {
            // Expected to fail due to invalid token, but API signature works
            XCTAssertTrue(true)
        }
    }
    
    func testAMKitWithClientMethod() async throws {
        do {
            let _ = try await AMKit.withClient(
                developerToken: "test-token"
            ) { amkit in
                return try await amkit.artists.fetch(
                    "test-id",
                    from: .us,
                    including: [.albums],
                    localization: .enUS
                )
            }
            XCTFail("Should fail due to invalid token")
        } catch {
            // Expected to fail due to invalid token, but API signature works
            XCTAssertTrue(true)
        }
    }
    
    func testAMKitInfo() {
        XCTAssertEqual(AMKit.version, "1.0.0")
        XCTAssertEqual(AMKit.info.name, "AMKit")
        XCTAssertEqual(AMKit.info.version, AMKit.version)
        XCTAssertEqual(AMKit.info.apiVersion, "v1")
        XCTAssertTrue(AMKit.info.features.contains("Fluent API Design"))
        XCTAssertTrue(AMKit.info.platforms.contains("macOS 14+"))
    }
    
    func testAMKitConvenienceCollections() {
        // Test storefront collections
        XCTAssertTrue(AMKit.Storefronts.english.contains(.us))
        XCTAssertTrue(AMKit.Storefronts.english.contains(.gb))
        XCTAssertTrue(AMKit.Storefronts.europe.contains(.de))
        XCTAssertTrue(AMKit.Storefronts.asia.contains(.jp))
        
        // Test localization collections
        XCTAssertTrue(AMKit.Localizations.english.contains(.enUS))
        XCTAssertTrue(AMKit.Localizations.europe.contains(.deDE))
        XCTAssertTrue(AMKit.Localizations.asia.contains(.jaJP))
        
        // Test artist include collections
        XCTAssertEqual(AMKit.ArtistIncludes.media, ArtistInclude.Combinations.media)
        XCTAssertEqual(AMKit.ArtistIncludes.all, ArtistInclude.Combinations.full)
        XCTAssertEqual(AMKit.ArtistIncludes.essential, [.albums, .musicVideos])
    }
}

// MARK: - Error Handling Tests

final class ErrorHandlingTests: XCTestCase {
    
    func testErrorResponseDecoding() async throws {
        let jsonData = """
        {
            "errors": [
                {
                    "id": "AAPL:ERROR-ID-123",
                    "status": "400",
                    "code": "40000",
                    "title": "Bad Request",
                    "detail": "Invalid request"
                }
            ]
        }
        """.data(using: .utf8)!
        
        let errorResponse = try JSONDecoder().decode(AppleMusicErrorResponse.self, from: jsonData)
        
        XCTAssertEqual(errorResponse.errors.count, 1)
        XCTAssertEqual(errorResponse.errors.first?.id, "AAPL:ERROR-ID-123")
        XCTAssertEqual(errorResponse.errors.first?.status, "400")
        XCTAssertEqual(errorResponse.errors.first?.code, "40000")
        XCTAssertEqual(errorResponse.errors.first?.title, "Bad Request")
    }
    
    func testAppleMusicAPIErrorHandling() async throws {
        // Test 422 Unprocessable Entity error
        let validationJsonData = """
        {
            "errors": [
                {
                    "id": "AAPL:VALIDATION-ERROR-456",
                    "status": "422",
                    "code": "42200",
                    "title": "Unprocessable Entity",
                    "detail": "The request body contains semantic errors",
                    "source": {
                        "parameter": "include",
                        "pointer": "/data/attributes/include"
                    }
                }
            ]
        }
        """.data(using: .utf8)!
        
        let validationErrorResponse = try JSONDecoder().decode(AppleMusicErrorResponse.self, from: validationJsonData)
        
        XCTAssertEqual(validationErrorResponse.errors.count, 1)
        XCTAssertEqual(validationErrorResponse.errors.first?.status, "422")
        XCTAssertEqual(validationErrorResponse.errors.first?.code, "42200")
        XCTAssertEqual(validationErrorResponse.errors.first?.source?.parameter, "include")
        XCTAssertEqual(validationErrorResponse.errors.first?.source?.pointer, "/data/attributes/include")
    }
    
    func testErrorCreation() async throws {
        let authError = AMError.authentication("Token expired")
        XCTAssertEqual(authError.category, .network)
        XCTAssertEqual(authError.message, "Token expired")
        
        let validationError = AMError.validation("Invalid input")
        XCTAssertEqual(validationError.category, .validation)
        XCTAssertEqual(validationError.message, "Invalid input")
        
        let notFoundError = AMError.notFound("The requested resource was not found")
        XCTAssertEqual(notFoundError.category, .validation)
        XCTAssertEqual(notFoundError.message, "The requested resource was not found")
    }
    
    func testAppleMusicAPIError() async throws {
        let apiError = AppleMusicAPIError(
            id: "AAPL:TEST-ERROR",
            about: "https://example.com",
            status: "400",
            code: "40000",
            title: "Test Error",
            detail: "Test error detail",
            source: nil,
            meta: nil
        )
        
        let amError = AMError.api(apiError)
        XCTAssertEqual(amError.category, .api)
        XCTAssertNotNil(amError.appleMusicError)
        XCTAssertEqual(amError.appleMusicError?.title, "Test Error")
        XCTAssertEqual(amError.appleMusicError?.code, "40000")
    }
}

// MARK: - Artist Model Tests

final class ArtistModelTests: XCTestCase {
    
    func testArtistResponseDecoding() async throws {
        let jsonData = """
        {
            "data": [
                {
                    "id": "178834",
                    "type": "artists",
                    "href": "/v1/catalog/us/artists/178834",
                    "attributes": {
                        "name": "Bruce Springsteen",
                        "genreNames": ["Rock"],
                        "url": "https://music.apple.com/us/artist/bruce-springsteen/178834"
                    }
                }
            ]
        }
        """.data(using: .utf8)!
        
        let response = try JSONDecoder().decode(ArtistResponse.self, from: jsonData)
        
        XCTAssertEqual(response.data.count, 1)
        XCTAssertEqual(response.data.first?.id, "178834")
        XCTAssertEqual(response.data.first?.attributes.name, "Bruce Springsteen")
        XCTAssertEqual(response.data.first?.attributes.genreNames.first, "Rock")
    }
}

// MARK: - JWT Token Generation Tests

final class JWTTokenTests: XCTestCase {
    
    func testJWTPayloadCreation() async throws {
        let payload = AppleMusicJWTPayload(
            teamID: "ABC123DEFG",
            keyID: "DEF456GHIJ",
            issuedAt: Date(),
            expiration: Date().addingTimeInterval(3600)
        )
        
        XCTAssertEqual(payload.iss.value, "ABC123DEFG")
        XCTAssertGreaterThan(payload.exp.value, payload.iat.value)
    }
    
    func testTokenGenerator() async throws {
        let privateKey = ES256PrivateKey()
        let privateKeyPEM = privateKey.pemRepresentation
        
        let generator = try await AppleMusicTokenGenerator(
            teamID: "ABC123DEFG",
            keyID: "DEF456GHIJ",
            privateKey: privateKeyPEM
        )
        
        let token = try await generator.generateToken()
        XCTAssertFalse(token.isEmpty)
        XCTAssertTrue(token.contains("."))
    }
}

// MARK: - Storefront Tests

final class StorefrontTests: XCTestCase {
    
    func testStorefrontModelDecoding() async throws {
        let jsonData = """
        {
            "data": [
                {
                    "id": "us",
                    "type": "storefronts",
                    "href": "/v1/storefronts/us",
                    "attributes": {
                        "defaultLanguageTag": "en-US",
                        "name": "United States",
                        "explicitContentPolicy": "allowed",
                        "supportedLanguageTags": ["en-US", "es-MX"]
                    }
                }
            ]
        }
        """.data(using: .utf8)!
        
        let response = try JSONDecoder().decode(StorefrontsResponse.self, from: jsonData)
        
        XCTAssertEqual(response.data.count, 1)
        XCTAssertEqual(response.data.first?.id, "us")
        XCTAssertEqual(response.data.first?.attributes.name, "United States")
        XCTAssertEqual(response.data.first?.attributes.defaultLanguageTag, "en-US")
        XCTAssertTrue(response.data.first?.attributes.supportedLanguageTags.contains("en-US") == true)
    }
    
    func testStorefrontFetchValidation() async throws {
        let client = AppleMusicClient(
            developerToken: "test-token",
            configuration: .default
        )
        
        do {
            let _ = try await client.storefronts.fetch(id: "")
            XCTFail("Should fail for empty ID")
        } catch let error as AMError {
            XCTAssertEqual(error.category, .validation)
            XCTAssertTrue(error.message?.contains("Storefront ID cannot be empty") == true)
        }
    }
    
    func testTypedStorefrontFetch() async throws {
        let client = AppleMusicClient(
            developerToken: "test-token",
            configuration: .default
        )
        
        // Test that typed storefront method exists and compiles
        // This would fail at network level but proves the API works
        do {
            let _ = try await client.storefronts.fetch(.us, localization: .enUS)
            XCTFail("Should fail due to invalid token")
        } catch {
            // Expected to fail due to invalid token, but API signature works
            XCTAssertTrue(true)
        }
    }
    
    func testLocalizationEnum() async throws {
        // Test localization enum values
        XCTAssertEqual(AppleMusicLocalization.enUS.rawValue, "en-US")
        XCTAssertEqual(AppleMusicLocalization.jaJP.rawValue, "ja-JP")
        XCTAssertEqual(AppleMusicLocalization.frFR.rawValue, "fr-FR")
        XCTAssertEqual(AppleMusicLocalization.deDE.rawValue, "de-DE")
        
        // Test common localizations
        XCTAssertTrue(AppleMusicLocalization.common.contains(.enUS))
        XCTAssertTrue(AppleMusicLocalization.common.contains(.jaJP))
        XCTAssertTrue(AppleMusicLocalization.common.contains(.frFR))
    }
}

// MARK: - API Integration Tests

final class APIIntegrationTests: XCTestCase {
    
    func testArtistCatalogFetchValidation() async throws {
        let client = AppleMusicClient(
            developerToken: "test-token",
            configuration: .default
        )
        
        do {
            let _ = try await client.artists.catalog.fetch(
                id: "",
                storefront: .us,
                include: nil as [ArtistInclude]?,
                localization: nil
            )
            XCTFail("Should fail for empty ID")
        } catch let error as AMError {
            XCTAssertEqual(error.category, .validation)
            XCTAssertTrue(error.message?.contains("Artist ID cannot be empty") == true)
        }
    }
}

// MARK: - Type Safety Tests

final class TypeSafetyTests: XCTestCase {
    
    func testArtistIncludeCombinations() async throws {
        XCTAssertTrue(ArtistInclude.Combinations.media.contains(.albums))
        XCTAssertTrue(ArtistInclude.Combinations.media.contains(.musicVideos))
        XCTAssertEqual(ArtistInclude.Combinations.full.count, 5)
        XCTAssertEqual(ArtistInclude.all.count, ArtistInclude.allCases.count)
    }
    
    func testTypedIncludeUsage() async throws {
        let client = AppleMusicClient(
            developerToken: "test-token",
            configuration: .default
        )
        
        // Test that typed include methods compile correctly
        do {
            let _ = try await client.artists.catalog.fetch(
                id: "test-id",
                storefront: .us,
                include: [.albums, .musicVideos, .playlists],
                localization: .enUS
            )
            XCTFail("Should fail due to invalid token")
        } catch {
            // Expected to fail due to invalid token, but API signature works
            XCTAssertTrue(true)
        }
        
        // Test convenience method with typed includes
        do {
            let _ = try await client.artists.fetch(
                "test-id",
                from: .jp,
                including: [.albums, .genres],
                localization: .jaJP
            )
            XCTFail("Should fail due to invalid token")
        } catch {
            // Expected to fail due to invalid token, but API signature works
            XCTAssertTrue(true)
        }
    }
}