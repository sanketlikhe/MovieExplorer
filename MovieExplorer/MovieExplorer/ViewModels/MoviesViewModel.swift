//
//  MoviesViewModel.swift
//  MovieExplorer
//
//  Created by Sanket Likhe on 10/5/25.
//

import Foundation
import Combine

/// ViewModel for the movies list screen
@MainActor
final class MoviesViewModel: ObservableObject {
    
    // MARK: - Published Properties
    
    @Published var movies: [Movie] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var searchQuery = ""
    @Published var isSearching = false
    
    // MARK: - Properties
    
    private let repository: MovieRepositoryProtocol
    private var currentPage = 1
    private var canLoadMore = true
    private var searchTask: Task<Void, Never>?
    
    // MARK: - Initialization
    
    init(repository: MovieRepositoryProtocol = MovieRepository()) {
        self.repository = repository
    }
    
    // MARK: - Public Methods
    
    /// Load popular movies (initial load or refresh)
    func loadMovies(refresh: Bool = false) async {
        guard !isLoading else { return }
        
        if refresh {
            currentPage = 1
            canLoadMore = true
            movies = []
        }
        
        isLoading = true
        errorMessage = nil
        
        do {
            let fetchedMovies = try await repository.fetchPopularMovies(page: currentPage)
            
            if refresh {
                movies = fetchedMovies
            } else {
                movies.append(contentsOf: fetchedMovies)
            }
            
            currentPage += 1
            canLoadMore = !fetchedMovies.isEmpty
            
        } catch let error as NetworkError {
            if case .noInternetConnection = error {
                // Load from cache
                let cachedMovies = repository.getCachedMovies()
                if !cachedMovies.isEmpty {
                    movies = cachedMovies
                    errorMessage = "Showing cached movies (offline mode)"
                } else {
                    errorMessage = error.localizedDescription
                }
            } else {
                errorMessage = error.localizedDescription
            }
        } catch {
            errorMessage = "An unexpected error occurred"
        }
        
        isLoading = false
    }
    
    /// Load more movies for pagination
    func loadMoreMoviesIfNeeded(currentMovie: Movie) async {
        guard let lastMovie = movies.last,
              currentMovie.id == lastMovie.id,
              canLoadMore,
              !isLoading else {
            return
        }
        
        await loadMovies()
    }
    
    /// Search movies by query
    func searchMovies() {
        // Cancel previous search task
        searchTask?.cancel()
        
        guard !searchQuery.trimmingCharacters(in: .whitespaces).isEmpty else {
            isSearching = false
            Task {
                await loadMovies(refresh: true)
            }
            return
        }
        
        searchTask = Task {
            isSearching = true
            isLoading = true
            errorMessage = nil
            
            // Debounce search
            try? await Task.sleep(nanoseconds: 500_000_000) // 0.5 seconds
            
            guard !Task.isCancelled else { return }
            
            do {
                let results = try await repository.searchMovies(query: searchQuery, page: 1)
                movies = results
            } catch {
                errorMessage = "Search failed: \(error.localizedDescription)"
            }
            
            isLoading = false
        }
    }
    
    /// Clear search and reload popular movies
    func clearSearch() {
        searchQuery = ""
        isSearching = false
        Task {
            await loadMovies(refresh: true)
        }
    }
}
