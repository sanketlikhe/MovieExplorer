//
//  MockMovieRepository.swift
//  MovieExplorer
//
//  Created by Sanket Likhe on 10/5/25.
//

import Foundation
@testable import MovieExplorer

/// Mock repository for testing ViewModels
final class MockMovieRepository: MovieRepositoryProtocol {
    
    var shouldThrowError = false
    var errorToThrow: Error = NetworkError.noData
    var mockMovies: [Movie] = []
    var mockMovie: Movie?
    var fetchPopularMoviesCallCount = 0
    var fetchMovieDetailCallCount = 0
    var searchMoviesCallCount = 0
    
    func fetchPopularMovies(page: Int) async throws -> [Movie] {
        fetchPopularMoviesCallCount += 1
        
        if shouldThrowError {
            throw errorToThrow
        }
        
        return mockMovies
    }
    
    func fetchMovieDetail(id: Int) async throws -> Movie {
        fetchMovieDetailCallCount += 1
        
        if shouldThrowError {
            throw errorToThrow
        }
        
        guard let movie = mockMovie else {
            throw NetworkError.noData
        }
        
        return movie
    }
    
    func searchMovies(query: String, page: Int) async throws -> [Movie] {
        searchMoviesCallCount += 1
        
        if shouldThrowError {
            throw errorToThrow
        }
        
        return mockMovies.filter { $0.title.localizedCaseInsensitiveContains(query) }
    }
    
    func getCachedMovies() -> [Movie] {
        return mockMovies
    }
}
