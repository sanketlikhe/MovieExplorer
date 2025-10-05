//
//  APIClient.swift
//  MovieExplorer
//
//  Created by Sanket Likhe on 10/5/25.
//

import Foundation

/// Protocol for API client to enable testing with mock implementations
protocol APIClientProtocol {
    func request<T: Decodable>(_ endpoint: APIEndpoint) async throws -> T
}

/// Main API client using URLSession with async/await
final class APIClient: APIClientProtocol {
    
    // MARK: - Properties
    
    private let baseURL = "https://api.themoviedb.org"
    private let accessToken = "eyJhbGciOiJIUzI1NiJ9.eyJhdWQiOiJkMDRiMWQ0Y2M1MDk0NDcwNWU5ZDVlZTQ3ZWYxNDNmMSIsIm5iZiI6MTc1OTY0MzI0NS40NjgsInN1YiI6IjY4ZTIwNjZkNWVkMGIwMGI4OTk2MTBjMiIsInNjb3BlcyI6WyJhcGlfcmVhZCJdLCJ2ZXJzaW9uIjoxfQ.jN5ezIe6mxMi2gSJtFJxTD7cZuu6VD0y0zYqvpnpO6g"
    
    private let session: URLSession
    
    // MARK: - Initialization
    
    init(session: URLSession = .shared) {
        self.session = session
    }
    
    // MARK: - Public Methods
    
    /// Generic request method using async/await
    /// - Parameter endpoint: The API endpoint to call
    /// - Returns: Decoded response of type T
    func request<T: Decodable>(_ endpoint: APIEndpoint) async throws -> T {
        // Build URL with query parameters
        guard var urlComponents = URLComponents(string: baseURL + endpoint.path) else {
            throw NetworkError.invalidURL
        }
        
        urlComponents.queryItems = endpoint.queryItems
        
        guard let url = urlComponents.url else {
            throw NetworkError.invalidURL
        }
        
        // Create request with Bearer token authentication
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        
        do {
            // Perform async request
            let (data, response) = try await session.data(for: request)
            
            // Validate HTTP response
            guard let httpResponse = response as? HTTPURLResponse else {
                throw NetworkError.noData
            }
            
            guard (200...299).contains(httpResponse.statusCode) else {
                throw NetworkError.serverError(statusCode: httpResponse.statusCode)
            }
            
            // Decode JSON response
            do {
                let decoder = JSONDecoder()
                return try decoder.decode(T.self, from: data)
            } catch {
                throw NetworkError.decodingError(error)
            }
            
        } catch let error as NetworkError {
            throw error
        } catch {
            // Check for no internet connection
            if (error as NSError).code == NSURLErrorNotConnectedToInternet {
                throw NetworkError.noInternetConnection
            }
            throw NetworkError.unknown(error)
        }
    }
}
