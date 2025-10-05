//
//  MovieDetailView.swift
//  MovieExplorer
//
//  Created by Sanket Likhe on 10/5/25.
//

import SwiftUI

/// Detailed movie screen with full information
struct MovieDetailView: View {
    @StateObject private var viewModel: MovieDetailViewModel
    @Environment(\.dismiss) private var dismiss
    
    init(movie: Movie) {
        _viewModel = StateObject(wrappedValue: MovieDetailViewModel(movie: movie))
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 8) {
                // Backdrop Image Header
                backdropHeader
                
                // Movie Content
                VStack(alignment: .leading, spacing: 20) {
                    // Title and Year
                    titleSection
                    
                    // Rating and Stats
                    statsSection
                    
                    Divider()
                    
                    // Overview
                    overviewSection
                    
                    // Additional Info
                    additionalInfoSection
                }
                .padding()
            }
        }
        .ignoresSafeArea(edges: .top)
        .navigationBarTitleDisplayMode(.inline)
        .task {
            await viewModel.loadMovieDetails()
        }
        .overlay {
            if viewModel.isLoading {
                ProgressView()
                    .scaleEffect(1.5)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color.black.opacity(0.2))
            }
        }
    }
    
    // MARK: - Subviews
    
    private var backdropHeader: some View {
        ZStack(alignment: .bottom) {
            // Backdrop Image
            AsyncImage(url: viewModel.movie.backdropURL ?? viewModel.movie.posterURL) { phase in
                switch phase {
                case .empty:
                    Rectangle()
                        .fill(LinearGradient(
                            colors: [Color.gray.opacity(0.3), Color.gray.opacity(0.1)],
                            startPoint: .top,
                            endPoint: .bottom
                        ))
                        .overlay(ProgressView())
                case .success(let image):
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                case .failure:
                    Rectangle()
                        .fill(LinearGradient(
                            colors: [Color.gray.opacity(0.3), Color.gray.opacity(0.1)],
                            startPoint: .top,
                            endPoint: .bottom
                        ))
                        .overlay(
                            Image(systemName: "photo.fill")
                                .font(.largeTitle)
                                .foregroundColor(.white.opacity(0.5))
                        )
                @unknown default:
                    EmptyView()
                }
            }
            .frame(height: 300)
            .clipped()
            
            // Gradient Overlay
            LinearGradient(
                colors: [Color.clear, Color.black.opacity(0.8)],
                startPoint: .top,
                endPoint: .bottom
            )
            .frame(height: 200)
            
            // Poster and Basic Info Overlay
            HStack(alignment: .bottom, spacing: 16) {
                // Poster
                AsyncImage(url: viewModel.movie.posterURL) { phase in
                    switch phase {
                    case .empty:
                        Rectangle()
                            .fill(Color.gray.opacity(0.3))
                            .overlay(ProgressView())
                    case .success(let image):
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    case .failure:
                        Rectangle()
                            .fill(Color.gray.opacity(0.3))
                            .overlay(
                                Image(systemName: "photo")
                                    .foregroundColor(.gray)
                            )
                    @unknown default:
                        EmptyView()
                    }
                }
                .frame(width: 120, height: 180)
                .cornerRadius(12)
                .shadow(radius: 8)
                
                // Quick Info
                VStack(alignment: .leading, spacing: 8) {
                    Spacer()
                    
                    Text(viewModel.movie.releaseYear)
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.9))
                    
                    HStack(spacing: 8) {
                        Image(systemName: "star.fill")
                            .foregroundColor(.yellow)
                        Text(viewModel.movie.formattedRating)
                            .font(.title3)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                        Text("/10")
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.7))
                    }
                    
                    if let voteCount = viewModel.movie.voteCount {
                        Text("\(voteCount) votes")
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.7))
                    }
                }
                
                Spacer()
            }
            .padding()
        }
    }
    
    private var titleSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(viewModel.movie.title)
                .font(.title)
                .fontWeight(.bold)
            
            if let language = viewModel.movie.originalLanguage {
                Text("Original Language: \(language.uppercased())")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
    }
    
    private var statsSection: some View {
        HStack(spacing: 24) {
            // Rating
            VStack(spacing: 4) {
                HStack(spacing: 4) {
                    Image(systemName: "star.fill")
                        .foregroundColor(.yellow)
                    Text(viewModel.movie.formattedRating)
                        .font(.headline)
                }
                Text("Rating")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Divider()
                .frame(height: 30)
            
            // Popularity
            if let popularity = viewModel.movie.popularity {
                VStack(spacing: 4) {
                    Text(String(format: "%.0f", popularity))
                        .font(.headline)
                    Text("Popularity")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            Divider()
                .frame(height: 30)
            
            // Votes
            if let voteCount = viewModel.movie.voteCount {
                VStack(spacing: 4) {
                    Text("\(voteCount)")
                        .font(.headline)
                    Text("Votes")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(12)
    }
    
    private var overviewSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Overview")
                .font(.headline)
            
            if let overview = viewModel.movie.overview, !overview.isEmpty {
                Text(overview)
                    .font(.body)
                    .foregroundColor(.secondary)
                    .lineSpacing(4)
            } else {
                Text("No overview available")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .italic()
            }
        }
    }
    
    private var additionalInfoSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Details")
                .font(.headline)
            
            if let releaseDate = viewModel.movie.releaseDate {
                InfoRow(title: "Release Date", value: formatDate(releaseDate))
            }
            
            if let language = viewModel.movie.originalLanguage {
                InfoRow(title: "Original Language", value: language.uppercased())
            }
            
            if let adult = viewModel.movie.adult {
                InfoRow(title: "Adult Content", value: adult ? "Yes" : "No")
            }
        }
    }
    
    // MARK: - Helper Methods
    
    private func formatDate(_ dateString: String) -> String {
        let inputFormatter = DateFormatter()
        inputFormatter.dateFormat = "yyyy-MM-dd"
        
        let outputFormatter = DateFormatter()
        outputFormatter.dateStyle = .long
        
        if let date = inputFormatter.date(from: dateString) {
            return outputFormatter.string(from: date)
        }
        return dateString
    }
}

// MARK: - Supporting View: InfoRow

struct InfoRow: View {
    let title: String
    let value: String
    
    var body: some View {
        HStack {
            Text(title)
                .font(.subheadline)
                .foregroundColor(.secondary)
            Spacer()
            Text(value)
                .font(.subheadline)
                .fontWeight(.medium)
        }
        .padding(.vertical, 4)
    }
}


#Preview("Movie Detail") {
    NavigationView {
        MovieDetailView(movie: Movie(
            id: 1,
            title: "Star Wars",
            overview: "Princess Leia is captured and held hostage by the evil Imperial forces in their effort to take over the galactic Empire. Venturesome Luke Skywalker and dashing captain Han Solo team together with the loveable robot duo R2-D2 and C-3PO to rescue the beautiful princess and restore peace and justice in the Empire.",
            posterPath: "/6FfCtAuVAW8XJjZ7eWeLibRLWTw.jpg",
            backdropPath: "/zqkmTXzjkAgXmEWLRsY4UpTWCeo.jpg",
            releaseDate: "1977-05-25",
            voteAverage: 8.2,
            voteCount: 19521,
            popularity: 87.737,
            originalLanguage: "en",
            adult: false
        ))
    }
}
