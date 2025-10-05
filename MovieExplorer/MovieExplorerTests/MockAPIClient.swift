//
//  MockAPIClient.swift
//  MovieExplorer
//
//  Created by Sanket Likhe on 10/5/25.
//

import Foundation
@testable import MovieExplorer

/// Mock API client for testing
final class MockAPIClient: APIClientProtocol {
    
    var shouldReturnError = false
    var errorToReturn: NetworkError = .noData
    var mockMovieResponse: MovieResponse?
    var mockMovie: Movie?
    
    func request<T: Decodable>(_ endpoint: APIEndpoint) async throws -> T {
        if shouldReturnError {
            throw errorToReturn
        }
        
        // Return appropriate mock data based on endpoint
        switch endpoint {
        case .popularMovies:
            if let response = mockMovieResponse as? T {
                return response
            }
        case .movieDetail:
            if let movie = mockMovie as? T {
                return movie
            }
        case .searchMovies:
            if let response = mockMovieResponse as? T {
                return response
            }
        }
        
        throw NetworkError.noData
    }
}
