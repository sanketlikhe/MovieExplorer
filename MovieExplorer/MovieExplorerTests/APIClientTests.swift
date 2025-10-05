//
//  APIClientTests.swift
//  MovieExplorer
//
//  Created by Sanket Likhe on 10/5/25.
//

import XCTest
@testable import MovieExplorer

final class APIClientTests: XCTestCase {
    
    var sut: APIClient!
    
    override func setUp() {
        super.setUp()
        sut = APIClient()
    }
    
    override func tearDown() {
        sut = nil
        super.tearDown()
    }
    
    func testAPIEndpointPath() {
        // Given
        let popularEndpoint = APIEndpoint.popularMovies(page: 1)
        let detailEndpoint = APIEndpoint.movieDetail(id: 11)
        let searchEndpoint = APIEndpoint.searchMovies(query: "star wars", page: 1)
        
        // Then
        XCTAssertEqual(popularEndpoint.path, "/3/movie/popular")
        XCTAssertEqual(detailEndpoint.path, "/3/movie/11")
        XCTAssertEqual(searchEndpoint.path, "/3/search/movie")
    }
    
    func testAPIEndpointQueryItems() {
        // Given
        let popularEndpoint = APIEndpoint.popularMovies(page: 2)
        let searchEndpoint = APIEndpoint.searchMovies(query: "star wars", page: 1)
        
        // When
        let popularQuery = popularEndpoint.queryItems
        let searchQuery = searchEndpoint.queryItems
        
        // Then
        XCTAssertEqual(popularQuery.count, 1)
        XCTAssertEqual(popularQuery.first?.name, "page")
        XCTAssertEqual(popularQuery.first?.value, "2")
        
        XCTAssertEqual(searchQuery.count, 2)
        XCTAssertTrue(searchQuery.contains(where: { $0.name == "query" && $0.value == "star wars" }))
        XCTAssertTrue(searchQuery.contains(where: { $0.name == "page" && $0.value == "1" }))
    }
}
