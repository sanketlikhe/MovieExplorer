//
//  MovieRepositoryTests.swift
//  MovieExplorer
//
//  Created by Sanket Likhe on 10/5/25.
//

import XCTest
import CoreData
@testable import MovieExplorer

final class MovieRepositoryTests: XCTestCase {
    
    var sut: MovieRepository!
    var mockAPIClient: MockAPIClient!
    var testPersistenceController: PersistenceController!
    
    override func setUp() {
        super.setUp()
        mockAPIClient = MockAPIClient()
        testPersistenceController = PersistenceController(inMemory: true)
        sut = MovieRepository(
            apiClient: mockAPIClient,
            persistenceController: testPersistenceController
        )
    }
    
    override func tearDown() {
        sut = nil
        mockAPIClient = nil
        testPersistenceController = nil
        super.tearDown()
    }
    
    func testFetchPopularMoviesSuccess() async throws {
        // Given
        let mockMovies = [
            Movie(id: 1, title: "Movie 1", overview: "Overview 1", posterPath: nil, backdropPath: nil, releaseDate: nil, voteAverage: nil, voteCount: nil, popularity: nil, originalLanguage: nil, adult: nil),
            Movie(id: 2, title: "Movie 2", overview: "Overview 2", posterPath: nil, backdropPath: nil, releaseDate: nil, voteAverage: nil, voteCount: nil, popularity: nil, originalLanguage: nil, adult: nil)
        ]
        mockAPIClient.mockMovieResponse = MovieResponse(page: 1, results: mockMovies, totalPages: 1, totalResults: 2)
        
        // When
        let movies = try await sut.fetchPopularMovies(page: 1)
        
        // Then
        XCTAssertEqual(movies.count, 2)
        XCTAssertEqual(movies.first?.title, "Movie 1")
    }
    
    func testFetchPopularMoviesFailure() async {
        // Given
        mockAPIClient.shouldReturnError = true
        mockAPIClient.errorToReturn = .serverError(statusCode: 500)
        
        // When/Then
        do {
            _ = try await sut.fetchPopularMovies(page: 1)
            XCTFail("Should throw error")
        } catch {
            XCTAssertTrue(error is NetworkError)
        }
    }
    
    func testFetchMovieDetailSuccess() async throws {
        // Given
        let mockMovie = Movie(
            id: 11,
            title: "Star Wars",
            overview: "Epic space opera",
            posterPath: "/poster.jpg",
            backdropPath: nil,
            releaseDate: "1977-05-25",
            voteAverage: 8.2,
            voteCount: 19521,
            popularity: nil,
            originalLanguage: "en",
            adult: false
        )
        mockAPIClient.mockMovie = mockMovie
        
        // When
        let movie = try await sut.fetchMovieDetail(id: 11)
        
        // Then
        XCTAssertEqual(movie.id, 11)
        XCTAssertEqual(movie.title, "Star Wars")
    }
    
}
