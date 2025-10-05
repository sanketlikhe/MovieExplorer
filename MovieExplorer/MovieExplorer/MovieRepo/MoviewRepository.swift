//
//  MoviewRepository.swift
//  MovieExplorer
//
//  Created by Sanket Likhe on 10/5/25.
//

import Foundation
internal import CoreData

/// Protocol for movie repository to enable testing
protocol MovieRepositoryProtocol {
    func fetchPopularMovies(page: Int) async throws -> [Movie]
    func fetchMovieDetail(id: Int) async throws -> Movie
    func searchMovies(query: String, page: Int) async throws -> [Movie]
    func getCachedMovies() -> [Movie]
}

/// Repository that coordinates between network and cache layers
final class MovieRepository: MovieRepositoryProtocol {
    
    // MARK: - Properties
    
    private let apiClient: APIClientProtocol
    private let persistenceController: PersistenceController
    
    // MARK: - Initialization
    
    
    init(
        apiClient: APIClientProtocol = APIClient(),
        persistenceController: PersistenceController = .shared
    ) {
        self.apiClient = apiClient
        self.persistenceController = persistenceController
    }
    
    // MARK: - Public Methods
    
    /// Fetch popular movies from API and cache them
    func fetchPopularMovies(page: Int = 1) async throws -> [Movie] {
        do {
            let response: MovieResponse = try await apiClient.request(.popularMovies(page: page))
            
            // Cache movies in background
            await cacheMovies(response.results)
            
            return response.results
        } catch NetworkError.noInternetConnection {
            // Return cached movies if no internet
            return getCachedMovies()
        } catch {
            throw error
        }
    }
    
    /// Fetch movie detail from API and cache it
    func fetchMovieDetail(id: Int) async throws -> Movie {
        do {
            let movie: Movie = try await apiClient.request(.movieDetail(id: id))
            
            // Cache movie in background
            await cacheMovies([movie])
            
            return movie
        } catch NetworkError.noInternetConnection {
            // Try to get from cache
            if let cachedMovie = getCachedMovie(id: id) {
                return cachedMovie
            }
            throw NetworkError.noInternetConnection
        } catch {
            throw error
        }
    }
    
    /// Search movies by query
    func searchMovies(query: String, page: Int = 1) async throws -> [Movie] {
        let response: MovieResponse = try await apiClient.request(.searchMovies(query: query, page: page))
        return response.results
    }
    
    /// Get all cached movies from Core Data
    func getCachedMovies() -> [Movie] {
        let context = persistenceController.container.viewContext
        let fetchRequest: NSFetchRequest<CachedMovie> = CachedMovie.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "cachedAt", ascending: false)]
        
        do {
            let cachedMovies = try context.fetch(fetchRequest)
            return cachedMovies.map { $0.toMovie() }
        } catch {
            print("Failed to fetch cached movies: \(error)")
            return []
        }
    }
    
    // MARK: - Private Methods
    
    /// Cache movies in Core Data
    private func cacheMovies(_ movies: [Movie]) async {
        let context = persistenceController.container.newBackgroundContext()
        
        await context.perform {
            for movie in movies {
                CachedMovie.createOrUpdate(from: movie, in: context)
            }
            
            do {
                try context.save()
            } catch {
                print("Failed to save movies to cache: \(error)")
            }
        }
    }
    
    /// Get a specific cached movie by ID
    private func getCachedMovie(id: Int) -> Movie? {
        let context = persistenceController.container.viewContext
        let fetchRequest: NSFetchRequest<CachedMovie> = CachedMovie.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %d", id)
        
        do {
            let results = try context.fetch(fetchRequest)
            return results.first?.toMovie()
        } catch {
            print("Failed to fetch cached movie: \(error)")
            return nil
        }
    }
}
