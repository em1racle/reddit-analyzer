//
//  DownloadCSV.swift
//  reddit-analyzer
//
//  Created by Emir Byashimov on 28.12.2024.
//

import Foundation
import TabularData

struct CommentDataPoint {
    static let url = URL(string: "https://drive.google.com/file/d/1ll5mBZ2Fzr1unUSXfzsUZ4WTLcs_JIO3/view?usp=share_link")!
    
    enum Sentiment: String {
        case neutral = "Neutral"
        case positive = "Positive"
        case negative = "Negative"
    }
    
    let id: Int
    let parentId: Int
    let subreddit: String
    let username: String
    let type: String
    let emoji: String
    let message: String
    let score: Float
    let upvotes: Int
    let downvotes: Int
    let upvoteRatio: Float
    let date: Date
    let userIds: [String]
    let sentiment: Sentiment
    let sentimentScore: Float
    
    static func load() async throws -> [Self] {
        let (data, _) = try await URLSession.shared.data(from: Self.url)
        
        var dataFrame = try DataFrame(
            csvData: data,
            columns: [
                "id",
                "parentId",
                "subreddit",
                "username",
                "type",
                "emoji",
                "message",
                "score",
                "upvotes",
                "downvotes",
                "upvoteRatio",
                "date",
                "userIds",
                "sentiment",
                "sentimentScore"
            ],
            types: [
                "id": CSVType.integer,
                "parentId": CSVType.integer,
                "subreddit": CSVType.string,
                "username": CSVType.string,
                "type": CSVType.string,
                "emoji": CSVType.string,
                "message": CSVType.string,
                "score": CSVType.float,
                "upvotes": CSVType.integer,
                "downvotes": CSVType.integer,
                "upvoteRatio": CSVType.float,
                "date": CSVType.string, // Assuming the date is in ISO format (e.g., "2023-08-07T18:44:27Z")
                "userIds": CSVType.string,
                "sentiment": CSVType.string,
                "sentimentScore": CSVType.float
            ],
            options: CSVReadingOptions(hasHeaderRow: true)
        )
        
        dataFrame.sort(on: "date")
        
        return dataFrame.rows.compactMap { row in
            guard
                let id = row["id", Int.self],
                let parentId = row["parentId", Int.self],
                let subreddit = row["subreddit", String.self],
                let username = row["username", String.self],
                let type = row["type", String.self],
                let emoji = row["emoji", String.self],
                let message = row["message", String.self],
                let score = row["score", Float.self],
                let upvotes = row["upvotes", Int.self],
                let downvotes = row["downvotes", Int.self],
                let upvoteRatio = row["upvoteRatio", Float.self],
                let dateString = row["date", String.self],
                let date = ISO8601DateFormatter().date(from: dateString), // Convert ISO string to Date
                let userIdsString = row["userIds", String.self],
                let sentimentString = row["sentiment", String.self],
                let sentiment = Sentiment(rawValue: sentimentString),
                let sentimentScore = row["sentimentScore", Float.self]
            else {
                return nil
            }
            
            // Split userIds string into an array
            let userIds = userIdsString.isEmpty ? [] : userIdsString.split(separator: ",").map { String($0) }
            
            return Self(
                id: id,
                parentId: parentId,
                subreddit: subreddit,
                username: username,
                type: type,
                emoji: emoji,
                message: message,
                score: score,
                upvotes: upvotes,
                downvotes: downvotes,
                upvoteRatio: upvoteRatio,
                date: date,
                userIds: userIds,
                sentiment: sentiment,
                sentimentScore: sentimentScore
            )
        }
    }
}

// `Identifiable` протокол автоматически использует свойство `id` из структуры
extension CommentDataPoint: Identifiable {
    // Теперь `id` не нужно дублировать. Он уже есть в структуре.
}


