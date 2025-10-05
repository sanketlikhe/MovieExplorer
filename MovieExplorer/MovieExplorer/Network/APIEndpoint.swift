//
//  APIEndpoint.swift
//  MovieExplorer
//
//  Created by Sanket Likhe on 10/5/25.
//

import Foundation

/// Defines API endpoints with associated values
enum APIEndpoint {
    case popularMovies(page: Int)
    case movieDetail(id: Int)
    case searchMovies(query: String, page: Int)
    
    var path: String {
        switch self {
        case .popularMovies:
            return "/3/movie/popular"
        case .movieDetail(let id):
            return "/3/movie/\(id)"
        case .searchMovies:
            return "/3/search/movie"
        }
    }
    
    var queryItems: [URLQueryItem] {
        switch self {
        case .popularMovies(let page):
            return [URLQueryItem(name: "page", value: "\(page)")]
        case .movieDetail:
            return []
        case .searchMovies(let query, let page):
            return [
                URLQueryItem(name: "query", value: query),
                URLQueryItem(name: "page", value: "\(page)")
            ]
        }
    }
}
