//
//  MovieViewModelTests.swift
//  MovieExplorer
//
//  Created by Sanket Likhe on 10/5/25.
//

import XCTest
@testable import MovieExplorer

@MainActor
final class MoviesViewModelTests: XCTestCase {
    
    var sut: MoviesViewModel!
    var mockRepository: MockMovieRepository!
    
    override func setUp() {
        super.setUp()
        mockRepository = MockMovieRepository()
        sut = MoviesViewModel(repository: mockRepository)
    }
    
    override func tearDown() {
        sut = nil
        mockRepository = nil
        super.tearDown()
    }
    
    func testLoadMoviesSuccess() async {
        // Given
        let mockMovies = [
            Movie(id: 1, title: "Movie 1", overview: nil, posterPath: nil, backdropPath: nil, releaseDate: nil, voteAverage: nil, voteCount: nil, popularity: nil, originalLanguage: nil, adult: nil),
            Movie(id: 2, title: "Movie 2", overview: nil, posterPath: nil, backdropPath: nil, releaseDate: nil, voteAverage: nil, voteCount: nil, popularity: nil, originalLanguage: nil, adult: nil)
        ]
        mockRepository.mockMovies = mockMovies
        
        // When
        await sut.loadMovies()
        
        // Then
        XCTAssertEqual(sut.movies.count, 2)
        XCTAssertFalse(sut.isLoading)
        XCTAssertNil(sut.errorMessage)
        XCTAssertEqual(mockRepository.fetchPopularMoviesCallCount, 1)
    }
    
    func testLoadMoviesFailure() async {
        // Given
        mockRepository.shouldThrowError = true
        mockRepository.errorToThrow = NetworkError.serverError(statusCode: 500)
        
        // When
        await sut.loadMovies()
        
        // Then
        XCTAssertTrue(sut.movies.isEmpty)
        XCTAssertFalse(sut.isLoading)
        XCTAssertNotNil(sut.errorMessage)
    }
    
    func testLoadMoviesRefresh() async {
        // Given
        mockRepository.mockMovies = [
            Movie(id: 1, title: "Movie 1", overview: nil, posterPath: nil, backdropPath: nil, releaseDate: nil, voteAverage: nil, voteCount: nil, popularity: nil, originalLanguage: nil, adult: nil)
        ]
        
        // Load initial movies
        await sut.loadMovies()
        XCTAssertEqual(sut.movies.count, 1)
        
        // Update mock data
        mockRepository.mockMovies = [
            Movie(id: 2, title: "Movie 2", overview: nil, posterPath: nil, backdropPath: nil, releaseDate: nil, voteAverage: nil, voteCount: nil, popularity: nil, originalLanguage: nil, adult: nil),
            Movie(id: 3, title: "Movie 3", overview: nil, posterPath: nil, backdropPath: nil, releaseDate: nil, voteAverage: nil, voteCount: nil, popularity: nil, originalLanguage: nil, adult: nil)
        ]
        
        // When
        await sut.loadMovies(refresh: true)
        
        // Then
        XCTAssertEqual(sut.movies.count, 2)
        XCTAssertEqual(sut.movies.first?.id, 2)
    }
    
    func testSearchMovies() async {
        // Given
        mockRepository.mockMovies = [
            Movie(id: 1, title: "Star Wars", overview: nil, posterPath: nil, backdropPath: nil, releaseDate: nil, voteAverage: nil, voteCount: nil, popularity: nil, originalLanguage: nil, adult: nil),
            Movie(id: 2, title: "Star Trek", overview: nil, posterPath: nil, backdropPath: nil, releaseDate: nil, voteAverage: nil, voteCount: nil, popularity: nil, originalLanguage: nil, adult: nil),
            Movie(id: 3, title: "Avatar", overview: nil, posterPath: nil, backdropPath: nil, releaseDate: nil, voteAverage: nil, voteCount: nil, popularity: nil, originalLanguage: nil, adult: nil)
        ]
        sut.searchQuery = "star"
        
        // When
        sut.searchMovies()
        
        // Wait for debounce
        try? await Task.sleep(nanoseconds: 600_000_000)
        
        // Then
        XCTAssertEqual(sut.movies.count, 2)
        XCTAssertTrue(sut.isSearching)
    }
    
    func testClearSearch() async {
        // Given
        mockRepository.mockMovies = [
            Movie(id: 1, title: "Movie 1", overview: nil, posterPath: nil, backdropPath: nil, releaseDate: nil, voteAverage: nil, voteCount: nil, popularity: nil, originalLanguage: nil, adult: nil)
        ]
        sut.searchQuery = "test"
        sut.isSearching = true
        
        // When
        sut.clearSearch()
        
        // Wait for async operation
        try? await Task.sleep(nanoseconds: 100_000_000)
        
        // Then
        XCTAssertEqual(sut.searchQuery, "")
        XCTAssertFalse(sut.isSearching)
    }
}
