//
//  MovieListView.swift
//  MovieExplorer
//
//  Created by Sanket Likhe on 10/5/25.
//

import SwiftUI
internal import CoreData

/// Main movie list screen
struct MovieListView: View {
    @StateObject private var viewModel = MoviesViewModel()
    @State private var showingSearchBar = false
    
    var body: some View {
        NavigationView {
            ZStack {
                if viewModel.movies.isEmpty && !viewModel.isLoading {
                    // Empty state or error
                    if let errorMessage = viewModel.errorMessage {
                        ErrorView(message: errorMessage) {
                            Task {
                                await viewModel.loadMovies(refresh: true)
                            }
                        }
                    } else {
                        VStack(spacing: 16) {
                            Image(systemName: "film")
                                .font(.system(size: 60))
                                .foregroundColor(.gray)
                            Text("No movies found")
                                .font(.headline)
                                .foregroundColor(.secondary)
                        }
                    }
                } else {
                    // Movie List
                    movieListContent
                }
                
                // Loading overlay for initial load
                if viewModel.isLoading && viewModel.movies.isEmpty {
                    LoadingView()
                }
            }
            .navigationTitle("Movie Explorer")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingSearchBar.toggle() }) {
                        Image(systemName: "magnifyingglass")
                    }
                }
            }
            .searchable(
                text: $viewModel.searchQuery,
                isPresented: $showingSearchBar,
                prompt: "Search movies..."
            )
            .onChange(of: viewModel.searchQuery) { _ in
                viewModel.searchMovies()
            }
            .task {
                if viewModel.movies.isEmpty {
                    await viewModel.loadMovies()
                }
            }
        }
    }
    
    // MARK: - Subviews
    
    private var movieListContent: some View {
        VStack(spacing: 0) {
            // Error banner if present
            if let errorMessage = viewModel.errorMessage {
                HStack {
                    Image(systemName: "wifi.slash")
                        .foregroundColor(.white)
                    Text(errorMessage)
                        .font(.caption)
                        .foregroundColor(.white)
                }
                .padding(8)
                .frame(maxWidth: .infinity)
                .background(Color.orange)
            }
            
            // Movie list
            List {
                ForEach(viewModel.movies) { movie in
                    NavigationLink(destination: MovieDetailView(movie: movie)) {
                        MovieRowView(movie: movie)
                    }
                    .buttonStyle(PlainButtonStyle())
                    .task {
                        // Pagination: Load more when reaching last item
                        await viewModel.loadMoreMoviesIfNeeded(currentMovie: movie)
                    }
                }
                
                // Loading indicator for pagination
                if viewModel.isLoading && !viewModel.movies.isEmpty {
                    HStack {
                        Spacer()
                        ProgressView()
                            .padding()
                        Spacer()
                    }
                }
            }
            .listStyle(.plain)
            .refreshable {
                await viewModel.loadMovies(refresh: true)
            }
        }
    }
}

#Preview("Movie List") {
    MovieListView()
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
