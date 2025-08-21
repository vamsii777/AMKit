import Foundation
import AsyncHTTPClient
import NIOCore
import NIOHTTP1
import JWTKit

/// A modern Apple Music API client that provides access to the Apple Music catalog and user data.
/// 
/// This client leverages AsyncHTTPClient and supports both JWT token generation
/// and developer token authentication methods.
public final class AppleMusicClient: AMClientProtocol, Sendable {
    
    // MARK: - Properties
    
    private let httpClient: HTTPClient
    private let configuration: AppleMusicClientConfiguration
    private let tokenGenerator: AppleMusicTokenGenerator?
    private let developerToken: String?
    private let ownsHTTPClient: Bool
    
    // MARK: - Initialization
    
    /// Creates a new Apple Music client with JWT token generation.
    /// - Parameters:
    ///   - tokenGenerator: The JWT token generator for Apple Music API authentication
    ///   - configuration: The client configuration (defaults to `.default`)
    public init(
        tokenGenerator: AppleMusicTokenGenerator,
        configuration: AppleMusicClientConfiguration = .default
    ) {
        self.tokenGenerator = tokenGenerator
        self.developerToken = nil
        self.configuration = configuration
        self.httpClient = configuration.effectiveHTTPClient
        self.ownsHTTPClient = configuration.httpClient == nil
    }
    
    /// Creates a new Apple Music client with a pre-generated developer token.
    /// - Parameters:
    ///   - developerToken: A valid Apple Music API developer token
    ///   - configuration: The client configuration (defaults to `.default`)
    public init(
        developerToken: String,
        configuration: AppleMusicClientConfiguration = .default
    ) {
        self.tokenGenerator = nil
        self.developerToken = developerToken
        self.configuration = configuration
        self.httpClient = configuration.effectiveHTTPClient
        self.ownsHTTPClient = configuration.httpClient == nil
    }
    
    /// Creates a new Apple Music client with JWT credentials (fluent API).
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
        self.tokenGenerator = try await AppleMusicTokenGenerator(
            teamID: teamID,
            keyID: keyID,
            privateKey: privateKey
        )
        self.developerToken = nil
        self.configuration = configuration
        self.httpClient = configuration.effectiveHTTPClient
        self.ownsHTTPClient = configuration.httpClient == nil
    }
    
    /// Creates a new Apple Music client with JWT credentials from a private key file path (fluent API).
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
        self.tokenGenerator = try await AppleMusicTokenGenerator(
            teamID: teamID,
            keyID: keyID,
            privateKeyPath: privateKeyPath
        )
        self.developerToken = nil
        self.configuration = configuration
        self.httpClient = configuration.effectiveHTTPClient
        self.ownsHTTPClient = configuration.httpClient == nil
    }
    
    /// Creates a new Apple Music client with an ES256 private key (fluent API).
    /// - Parameters:
    ///   - teamID: Your Apple Developer Team ID
    ///   - keyID: Your Apple Music API Key ID
    ///   - privateKey: Your ES256 private key
    ///   - configuration: The client configuration (defaults to `.default`)
    public init(
        teamID: String,
        keyID: String,
        privateKey: ES256PrivateKey,
        configuration: AppleMusicClientConfiguration = .default
    ) async throws {
        self.tokenGenerator = try await AppleMusicTokenGenerator(
            teamID: teamID,
            keyID: keyID,
            privateKey: privateKey
        )
        self.developerToken = nil
        self.configuration = configuration
        self.httpClient = configuration.effectiveHTTPClient
        self.ownsHTTPClient = configuration.httpClient == nil
    }
    
    // MARK: - API Resources
    
    /// Provides access to artist-related API endpoints.
    public var artists: ArtistsResource {
        ArtistsResource(client: self)
    }
    
    /// Provides access to storefront-related API endpoints.
    public var storefronts: StorefrontsResource {
        StorefrontsResource(client: self)
    }
    
    // MARK: - Lifecycle
    
    deinit {
        if ownsHTTPClient && httpClient !== HTTPClient.shared {
            try? httpClient.syncShutdown()
        }
    }
    
    // MARK: - Private Methods
    
    private func makeHeaders() async throws -> HTTPHeaders {
        var headers = HTTPHeaders()
        
        let token: String
        if let developerToken = developerToken {
            token = developerToken
        } else if let tokenGenerator = tokenGenerator {
            token = try await tokenGenerator.generateToken()
        } else {
            throw AMError.authentication("No authentication method provided")
        }
        
        headers.add(name: "Authorization", value: "Bearer \(token)")
        headers.add(name: "Content-Type", value: "application/json")
        
        return headers
    }
    
    // MARK: - AMClientProtocol Implementation
    
    /// Executes an API request and returns the decoded response.
    /// - Parameter request: The request to execute
    /// - Returns: The decoded response of type T
    /// - Throws: `AMError` for various failure conditions
    public func execute<T: Codable & Sendable>(_ request: AMRequest) async throws -> T {
        guard let url = request.buildURL(baseURL: configuration.baseURL) else {
            throw AMError.validation("Invalid URL construction")
        }
        
        do {
            var httpRequest = HTTPClientRequest(url: url.absoluteString)
            httpRequest.method = request.method
            httpRequest.headers = try await makeHeaders()
            
            for (name, value) in request.headers {
                httpRequest.headers.replaceOrAdd(name: name, value: value)
            }
            
            let response = try await httpClient.execute(httpRequest, timeout: configuration.timeout)
            let body = try await response.body.collect(upTo: 1024 * 1024)
            
            return try handleResponse(response, body: body, as: T.self)
        } catch let error as AMError {
            throw error
        } catch {
            throw AMError.network(error)
        }
    }
    
    // MARK: - Structured Concurrency Convenience
    
    /// Executes an operation with automatic HTTPClient lifecycle management using structured concurrency.
    /// - Parameters:
    ///   - tokenGenerator: The JWT token generator for authentication
    ///   - configuration: The client configuration
    ///   - operation: The operation to perform with the client
    /// - Returns: The result of the operation
    /// - Throws: Any error thrown by the operation or client creation
    public static func withClient<T: Sendable>(
        tokenGenerator: AppleMusicTokenGenerator,
        configuration: AppleMusicClientConfiguration = .default,
        _ operation: (AppleMusicClient) async throws -> T
    ) async throws -> T {
        if configuration.httpClient != nil {
            let client = AppleMusicClient(tokenGenerator: tokenGenerator, configuration: configuration)
            return try await operation(client)
        } else {
            return try await HTTPClient.withHTTPClient(
                configuration: .singletonConfiguration
            ) { httpClient in
                let clientConfig = AppleMusicClientConfiguration(
                    baseURL: configuration.baseURL,
                    timeout: configuration.timeout,
                    httpClient: httpClient
                )
                let client = AppleMusicClient(tokenGenerator: tokenGenerator, configuration: clientConfig)
                return try await operation(client)
            }
        }
    }
    
    /// Executes an operation with automatic HTTPClient lifecycle management using a developer token.
    /// - Parameters:
    ///   - developerToken: A valid Apple Music API developer token
    ///   - configuration: The client configuration
    ///   - operation: The operation to perform with the client
    /// - Returns: The result of the operation
    /// - Throws: Any error thrown by the operation or client creation
    public static func withClient<T: Sendable>(
        developerToken: String,
        configuration: AppleMusicClientConfiguration = .default,
        _ operation: (AppleMusicClient) async throws -> T
    ) async throws -> T {
        if configuration.httpClient != nil {
            // Use provided client
            let client = AppleMusicClient(developerToken: developerToken, configuration: configuration)
            return try await operation(client)
        } else {
            // Use structured concurrency for automatic lifecycle management
            return try await HTTPClient.withHTTPClient(
                configuration: .singletonConfiguration
            ) { httpClient in
                let clientConfig = AppleMusicClientConfiguration(
                    baseURL: configuration.baseURL,
                    timeout: configuration.timeout,
                    httpClient: httpClient
                )
                let client = AppleMusicClient(developerToken: developerToken, configuration: clientConfig)
                return try await operation(client)
            }
        }
    }
    
    /// Executes an operation with JWT credentials using structured concurrency (fluent API).
    /// - Parameters:
    ///   - teamID: Your Apple Developer Team ID
    ///   - keyID: Your Apple Music API Key ID
    ///   - privateKey: Your ES256 private key as a string
    ///   - configuration: The client configuration
    ///   - operation: The operation to perform with the client
    /// - Returns: The result of the operation
    /// - Throws: Any error thrown by the operation or client creation
    public static func withClient<T: Sendable>(
        teamID: String,
        keyID: String,
        privateKey: String,
        configuration: AppleMusicClientConfiguration = .default,
        _ operation: (AppleMusicClient) async throws -> T
    ) async throws -> T {
        if configuration.httpClient != nil {
            let client = try await AppleMusicClient(
                teamID: teamID,
                keyID: keyID,
                privateKey: privateKey,
                configuration: configuration
            )
            return try await operation(client)
        } else {
            return try await HTTPClient.withHTTPClient(
                configuration: .singletonConfiguration
            ) { httpClient in
                let clientConfig = AppleMusicClientConfiguration(
                    baseURL: configuration.baseURL,
                    timeout: configuration.timeout,
                    httpClient: httpClient
                )
                let client = try await AppleMusicClient(
                    teamID: teamID,
                    keyID: keyID,
                    privateKey: privateKey,
                    configuration: clientConfig
                )
                return try await operation(client)
            }
        }
    }
    
    /// Executes an operation with JWT credentials from a file using structured concurrency (fluent API).
    /// - Parameters:
    ///   - teamID: Your Apple Developer Team ID
    ///   - keyID: Your Apple Music API Key ID
    ///   - privateKeyPath: Path to your ES256 private key file
    ///   - configuration: The client configuration
    ///   - operation: The operation to perform with the client
    /// - Returns: The result of the operation
    /// - Throws: Any error thrown by the operation or client creation
    public static func withClient<T: Sendable>(
        teamID: String,
        keyID: String,
        privateKeyPath: String,
        configuration: AppleMusicClientConfiguration = .default,
        _ operation: (AppleMusicClient) async throws -> T
    ) async throws -> T {
        if configuration.httpClient != nil {
            let client = try await AppleMusicClient(
                teamID: teamID,
                keyID: keyID,
                privateKeyPath: privateKeyPath,
                configuration: configuration
            )
            return try await operation(client)
        } else {
            return try await HTTPClient.withHTTPClient(
                configuration: .singletonConfiguration
            ) { httpClient in
                let clientConfig = AppleMusicClientConfiguration(
                    baseURL: configuration.baseURL,
                    timeout: configuration.timeout,
                    httpClient: httpClient
                )
                let client = try await AppleMusicClient(
                    teamID: teamID,
                    keyID: keyID,
                    privateKeyPath: privateKeyPath,
                    configuration: clientConfig
                )
                return try await operation(client)
            }
        }
    }
    
    // MARK: - Enhanced Response Handling
    
    /// Modern response handler with optimized error parsing and better performance
    private func handleResponse<T: Codable & Sendable>(
        _ response: HTTPClientResponse, 
        body: ByteBuffer?, 
        as type: T.Type
    ) throws -> T {
        // Early validation
        guard let body = body, body.readableBytes > 0 else {
            throw AMError.parsing(ResponseError.noData(statusCode: Int(response.status.code)))
        }
        
        let statusCode = Int(response.status.code)
        
        // Success path - optimized for common case
        if (200...299).contains(statusCode) {
            return try decodeSuccessResponse(body, as: type)
        }
        
        // Error path - handle specific status codes with enhanced error information
        try handleErrorResponse(response, body: body, statusCode: statusCode)
    }
    
    /// Optimized success response decoder with better error context
    private func decodeSuccessResponse<T: Codable & Sendable>(
        _ body: ByteBuffer, 
        as type: T.Type
    ) throws -> T {
        let data = Data(buffer: body)
        
        do {
            let decoder = Self.optimizedJSONDecoder
            return try decoder.decode(type, from: data)
        } catch {
            throw AMError.parsing(error)
        }
    }
    
    /// Enhanced error response handler with structured error parsing
    private func handleErrorResponse(
        _ response: HTTPClientResponse,
        body: ByteBuffer,
        statusCode: Int
    ) throws -> Never {
        let data = Data(buffer: body)
        
        // Try to parse Apple Music API error format first
        if let apiError = try? parseAppleMusicError(from: data, statusCode: statusCode) {
            throw apiError
        }
        
        // Fallback to standard HTTP status code handling
        throw createStandardHTTPError(statusCode: statusCode, data: data, response: response)
    }
    
    /// Parse Apple Music API error format with transparency - shows direct Apple Music API errors
    private func parseAppleMusicError(from data: Data, statusCode: Int) throws -> AMError {
        let decoder = Self.optimizedJSONDecoder
        let errorResponse = try decoder.decode(AppleMusicErrorResponse.self, from: data)
        
        guard let firstError = errorResponse.errors.first else {
            throw ResponseError.malformedError
        }
        
        // Return AMError with the actual Apple Music API error for complete transparency
        return AMError.api(firstError)
    }
    
    /// Create standard HTTP error with enhanced context
    private func createStandardHTTPError(
        statusCode: Int,
        data: Data,
        response: HTTPClientResponse
    ) -> AMError {
        switch statusCode {
        case 400:
            return AMError.validation("Bad Request - Invalid parameters or request format")
            
        case 401:
            return AMError.authentication("Unauthorized - Invalid or missing authentication token")
            
        case 403:
            return AMError.authorization("Forbidden - Insufficient permissions for this operation")
            
        case 404:
            return AMError.notFound("The requested resource was not found")
            
        case 422:
            return AMError.validation("Unprocessable Entity - Request format is valid but contains semantic errors")
            
        case 429:
            return AMError.rateLimited()
            
        case 500...599:
            let serverMessage = String(data: data, encoding: .utf8)?
                .trimmingCharacters(in: .whitespacesAndNewlines)
            let detail = serverMessage?.isEmpty == false 
                        ? serverMessage! 
                        : "Internal server error (\(statusCode))"
            
            return AMError.server(statusCode, message: detail)
            
        default:
            return AMError.unknown()
        }
    }
    
    /// Optimized JSON decoder with reusable configuration
    private static let optimizedJSONDecoder: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        decoder.keyDecodingStrategy = .useDefaultKeys
        return decoder
    }()
    
    // MARK: - Response Error Types
    
    /// Internal error types for response handling
    private enum ResponseError: Error, LocalizedError {
        case noData(statusCode: Int)
        case malformedError
        
        var errorDescription: String? {
            switch self {
            case .noData(let statusCode):
                return "No response data received (HTTP \(statusCode))"
            case .malformedError:
                return "Malformed Apple Music API error response"
            }
        }
    }
    
}
