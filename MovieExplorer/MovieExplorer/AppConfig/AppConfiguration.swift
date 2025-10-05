//
//  AppConfiguration.swift
//  MovieExplorer
//
//  Created by Sanket Likhe on 10/5/25.
//

import Foundation

/// Centralized configuration for the app
enum AppConfiguration {
    
    // MARK: - API Configuration
    
    static let apiBaseURL = "https://api.themoviedb.org"
    static let apiAccessToken = "eyJhbGciOiJIUzI1NiJ9.eyJhdWQiOiJkMDRiMWQ0Y2M1MDk0NDcwNWU5ZDVlZTQ3ZWYxNDNmMSIsIm5iZiI6MTc1OTY0MzI0NS40NjgsInN1YiI6IjY4ZTIwNjZkNWVkMGIwMGI4OTk2MTBjMiIsInNjb3BlcyI6WyJhcGlfcmVhZCJdLCJ2ZXJzaW9uIjoxfQ.jN5ezIe6mxMi2gSJtFJxTD7cZuu6VD0y0zYqvpnpO6g"
    static let apiKey = "d04b1d4cc50944705e9d5ee47ef143f1"
    
    // MARK: - Image URLs
    
    static let imageBaseURL = "https://image.tmdb.org/t/p"
    static let posterSize = "w500"
    static let backdropSize = "w780"
    
    // MARK: - Cache Configuration
    
    static let cacheExpirationDays = 30
    static let maxCachedMovies = 500
    
    // MARK: - Pagination
    
    static let moviesPerPage = 20
    
    // MARK: - Helper Methods
    
    static func posterURL(path: String) -> URL? {
        URL(string: "\(imageBaseURL)/\(posterSize)\(path)")
    }
    
    static func backdropURL(path: String) -> URL? {
        URL(string: "\(imageBaseURL)/\(backdropSize)\(path)")
    }
}
