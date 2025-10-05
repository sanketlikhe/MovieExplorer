//
//  MovieModelTests.swift
//  MovieExplorer
//
//  Created by Sanket Likhe on 10/5/25.
//

import XCTest
@testable import MovieExplorer

final class MovieModelTests: XCTestCase {
    
    func testMovieDecoding() throws {
        // Given
        let json = """
        {
            "id": 11,
            "title": "Star Wars",
            "overview": "An epic space opera",
            "poster_path": "/6FfCtAuVAW8XJjZ7eWeLibRLWTw.jpg",
            "backdrop_path": "/zqkmTXzjkAgXmEWLRsY4UpTWCeo.jpg",
            "release_date": "1977-05-25",
            "vote_average": 8.2,
            "vote_count": 19521,
            "popularity": 87.737,
            "original_language": "en",
            "adult": false
        }
        """.data(using: .utf8)!
        
        // When
        let decoder = JSONDecoder()
        let movie = try decoder.decode(Movie.self, from: json)
        
        // Then
        XCTAssertEqual(movie.id, 11)
        XCTAssertEqual(movie.title, "Star Wars")
        XCTAssertEqual(movie.releaseYear, "1977")
        XCTAssertEqual(movie.formattedRating, "8.2")
        XCTAssertNotNil(movie.posterURL)
        XCTAssertNotNil(movie.backdropURL)
    }
    
    func testMovieResponseDecoding() throws {
        // Given
        let json = """
        {
            "page": 1,
            "results": [
                {
                    "id": 11,
                    "title": "Star Wars",
                    "overview": "An epic space opera",
                    "poster_path": "/poster.jpg",
                    "release_date": "1977-05-25",
                    "vote_average": 8.2,
                    "vote_count": 19521
                }
            ],
            "total_pages": 100,
            "total_results": 2000
        }
        """.data(using: .utf8)!
        
        // When
        let decoder = JSONDecoder()
        let response = try decoder.decode(MovieResponse.self, from: json)
        
        // Then
        XCTAssertEqual(response.page, 1)
        XCTAssertEqual(response.results.count, 1)
        XCTAssertEqual(response.totalPages, 100)
        XCTAssertEqual(response.totalResults, 2000)
        XCTAssertEqual(response.results.first?.title, "Star Wars")
    }
    
    func testPosterURL() {
        // Given
        let movie = Movie(
            id: 1,
            title: "Test",
            overview: nil,
            posterPath: "/test.jpg",
            backdropPath: nil,
            releaseDate: nil,
            voteAverage: nil,
            voteCount: nil,
            popularity: nil,
            originalLanguage: nil,
            adult: nil
        )
        
        // When
        let url = movie.posterURL
        
        // Then
        XCTAssertNotNil(url)
        XCTAssertEqual(url?.absoluteString, "https://image.tmdb.org/t/p/w500/test.jpg")
    }
    
    func testReleaseYearParsing() {
        // Given
        let movie = Movie(
            id: 1,
            title: "Test",
            overview: nil,
            posterPath: nil,
            backdropPath: nil,
            releaseDate: "2024-03-15",
            voteAverage: nil,
            voteCount: nil,
            popularity: nil,
            originalLanguage: nil,
            adult: nil
        )
        
        // When
        let year = movie.releaseYear
        
        // Then
        XCTAssertEqual(year, "2024")
    }
}
