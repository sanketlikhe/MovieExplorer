//
//  MovieRowView.swift
//  MovieExplorer
//
//  Created by Sanket Likhe on 10/5/25.
//

import SwiftUI

/// Individual movie row component
struct MovieRowView: View {
    let movie: Movie
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            // Movie Poster
            AsyncImage(url: movie.posterURL) { phase in
                switch phase {
                case .empty:
                    Rectangle()
                        .fill(Color.gray.opacity(0.3))
                        .overlay(
                            ProgressView()
                        )
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
            .frame(width: 80, height: 120)
            .cornerRadius(8)
            .shadow(radius: 2)
            
            // Movie Info
            VStack(alignment: .leading, spacing: 6) {
                Text(movie.title)
                    .font(.headline)
                    .lineLimit(2)
                
                Text(movie.releaseYear)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                HStack(spacing: 4) {
                    Image(systemName: "star.fill")
                        .foregroundColor(.yellow)
                        .font(.caption)
                    
                    Text(movie.formattedRating)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    if let voteCount = movie.voteCount {
                        Text("(\(voteCount))")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                if let overview = movie.overview, !overview.isEmpty {
                    Text(overview)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                        .padding(.top, 2)
                }
                
                Spacer()
            }
            .padding(.vertical, 4)
            
            Spacer()
        }
        .padding(.vertical, 8)
    }
}


#Preview("Movie Row") {
    MovieRowView(movie: Movie(
        id: 1,
        title: "Star Wars",
        overview: "An epic space opera",
        posterPath: "/6FfCtAuVAW8XJjZ7eWeLibRLWTw.jpg",
        backdropPath: nil,
        releaseDate: "1977-05-25",
        voteAverage: 8.2,
        voteCount: 19521,
        popularity: 87.737,
        originalLanguage: "en",
        adult: false
    ))
    .previewLayout(.sizeThatFits)
    .padding()
}
