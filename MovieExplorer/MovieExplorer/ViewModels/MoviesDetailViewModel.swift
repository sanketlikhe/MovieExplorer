//
//  MoviesDetailViewModel.swift
//  MovieExplorer
//
//  Created by Sanket Likhe on 10/5/25.
//

import Foundation
import Combine

/// ViewModel for the movie detail screen
@MainActor
final class MovieDetailViewModel: ObservableObject {
    
    
    // MARK: - Published Properties
    
    @Published var movie: Movie
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    // MARK: - Properties
    
    private let repository: MovieRepositoryProtocol
    
    // MARK: - Initialization
    
    init(movie: Movie, repository: MovieRepositoryProtocol = MovieRepository()) {
        self.movie = movie
        self.repository = repository
    }
    
    // MARK: - Public Methods
    
    /// Load full movie details
    func loadMovieDetails() async {
        isLoading = true
        errorMessage = nil
        
        do {
            let detailedMovie = try await repository.fetchMovieDetail(id: movie.id)
            movie = detailedMovie
        } catch let error as NetworkError {
            errorMessage = error.localizedDescription
        } catch {
            errorMessage = "Failed to load movie details"
        }
        
        isLoading = false
    }
}
