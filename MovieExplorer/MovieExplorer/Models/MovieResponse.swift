//
//  MovieResponse.swift
//  MovieExplorer
//
//  Created by Sanket Likhe on 10/5/25.
//

/// Response model for paginated movie lists from TMDb API
struct MovieResponse: Codable {
    let page: Int
    let results: [Movie]
    let totalPages: Int
    let totalResults: Int
    
    enum CodingKeys: String, CodingKey {
        case page, results
        case totalPages = "total_pages"
        case totalResults = "total_results"
    }
}
