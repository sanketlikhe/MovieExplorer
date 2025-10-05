//
//  MovieDetailViewModelTests.swift
//  MovieExplorer
//
//  Created by Sanket Likhe on 10/5/25.
//

import XCTest
@testable import MovieExplorer

@MainActor
final class MovieDetailViewModelTests: XCTestCase {
    
    var sut: MovieDetailViewModel!
    var mockRepository: MockMovieRepository!
    var testMovie: Movie!
    
    override func setUp() {
        super.setUp()
        mockRepository = MockMovieRepository()
        testMovie = Movie(
            id: 11,
            title: "Star Wars",
            overview: "Epic space opera",
            posterPath: "/poster.jpg",
            backdropPath: nil,
            releaseDate: "1977-05-25",
            voteAverage: 8.2,
            voteCount: 19521,
            popularity: 87.737,
            originalLanguage: "en",
            adult: false
        )
        sut = MovieDetailViewModel(movie: testMovie, repository: mockRepository)
    }
    
    override func tearDown() {
        sut = nil
        mockRepository = nil
        testMovie = nil
        super.tearDown()
    }
    
    func testLoadMovieDetailsSuccess() async {
        // Given
        let detailedMovie = Movie(
            id: 11,
            title: "Star Wars: A New Hope",
            overview: "Full detailed overview",
            posterPath: "/poster.jpg",
            backdropPath: "/backdrop.jpg",
            releaseDate: "1977-05-25",
            voteAverage: 8.2,
            voteCount: 19521,
            popularity: 87.737,
            originalLanguage: "en",
            adult: false
        )
        mockRepository.mockMovie = detailedMovie
        
        // When
        await sut.loadMovieDetails()
        
        // Then
        XCTAssertEqual(sut.movie.title, "Star Wars: A New Hope")
        XCTAssertEqual(sut.movie.overview, "Full detailed overview")
        XCTAssertFalse(sut.isLoading)
        XCTAssertNil(sut.errorMessage)
        XCTAssertEqual(mockRepository.fetchMovieDetailCallCount, 1)
    }
    
    func testLoadMovieDetailsFailure() async {
        // Given
        mockRepository.shouldThrowError = true
        mockRepository.errorToThrow = NetworkError.noData
        
        // When
        await sut.loadMovieDetails()
        
        // Then
        XCTAssertFalse(sut.isLoading)
        XCTAssertNotNil(sut.errorMessage)
    }
}
