//
//  ChartsView.swift
//  reddit-analyzer
//
//  Created by Emir Byashimov on 28.12.2024.
//

import Foundation
import SwiftUI
import Charts

struct SimpleCommentChart: View {
    let data: [CommentDataPoint]
    
    @State var datesOfMaximumScore: [
        (date: Date, name: String, yStart: Float, yEnd: Float)
    ] = []
    
    var body: some View {
        Chart {
            // График лайков по времени
            ForEach(data) { point in
                AreaMark(
                    x: .value("Date", point.date),
                    y: .value("Score", point.score),
                    stacking: .center
                ).foregroundStyle(by: .value("Username", point.username))
            }
            
            // Отметки для максимальных лайков
            ForEach(
                datesOfMaximumScore,
                id: \.name
            ) { point in
                RuleMark(
                    x: .value(
                        "Date of highest score for \(point.name)",
                        point.date
                    )
                )
                .foregroundStyle(
                    LinearGradient(
                        gradient: Gradient (
                            colors: [
                                .indigo.opacity(0.05),
                                .purple.opacity(0.5)
                            ]
                        ),
                        startPoint: .top,
                        endPoint: .bottom
                    ).blendMode(.darken)
                )
            }
            
            // Добавляем текстовые аннотации для каждого имени
            ForEach(datesOfMaximumScore, id: \.name) { point in
                RuleMark(
                    x: .value("Date of highest score for \(point.name)", point.date),
                    yStart: .value("", point.yStart),
                    yEnd: .value("", point.yEnd)
                )
                .lineStyle(StrokeStyle(lineWidth: 0))
                    
                .annotation(
                    position: .overlay,
                    alignment: .center,
                    spacing: 4
                ){ context in
                    Text(point.name)
                        .font(.subheadline)
                        .padding(2)
                        .fixedSize()
                        .background(
                            RoundedRectangle(cornerRadius: 2)
                                .fill(.ultraThinMaterial)
                        )
                        .rotationEffect(
                            .degrees(-90),
                            anchor: .center
                        )
                        .fixedSize()
                        .foregroundColor(.secondary)
                }
            }
        }
        .chartForegroundStyleScale(
            range: Gradient (
                colors: [
                    .purple,
                    .blue.opacity(0.3)
                ]
            )
        )
        // Обновляем данные, если количество данных изменится
        .task(id: data.count) {

            self.datesOfMaximumScore = []

            var usernamesToMaxScore: [String: (score: Float, date: Date)] = [:]
            for point in self.data {
                if usernamesToMaxScore[point.username]?.score ?? 0 < point.score {
                    usernamesToMaxScore[point.username] = (point.score, point.date)
                }
            }
            
            self.datesOfMaximumScore = usernamesToMaxScore.map { (key: String, value) in
                let name = key
                var scoreOnDate = 0
                var scoreBeforeOnDate = 0
                var scoreAfterOnDate = 0
                
                // Loop over all the data
                for point in self.data {
                    // Мы учитываем только данные для этой даты
                    if point.date != value.date { continue }
                    if point.username == name {
                        scoreOnDate = Int(point.score)
                        continue
                    }
                    
                    if scoreOnDate != 0 {
                        // Секции после выбранной даты
                        scoreAfterOnDate += Int(point.score)
                    } else {
                        // Секции до выбранной даты
                        scoreBeforeOnDate += Int(point.score)
                    }
                }
                
                let totalScoreOnDate = scoreOnDate + scoreAfterOnDate + scoreBeforeOnDate
                // Центрируем по оси Y
                let lowestValue = -1 * Float(totalScoreOnDate) / 2.0
                let yStart = lowestValue + Float(scoreBeforeOnDate)
                let yEnd = yStart  + Float(scoreOnDate)
                
                return (value.date, key, yStart, yEnd)
            }
        }
    }
}

struct SimpleCommentChart_Previews: PreviewProvider {
    static var previews: some View {
        let sampleData: [CommentDataPoint] = [
            CommentDataPoint(id: 1, parentId: 1, subreddit: "wallstreetbets", username: "user1", type: "comment", emoji: "😂", message: "Test message 1", score: 50.0, upvotes: 100, downvotes: 10, upvoteRatio: 0.9, date: Date(), userIds: ["user1"], sentiment: .positive, sentimentScore: 0.95),
            CommentDataPoint(id: 2, parentId: 2, subreddit: "wallstreetbets", username: "user2", type: "comment", emoji: "😂", message: "Test message 2", score: 30.0, upvotes: 60, downvotes: 5, upvoteRatio: 0.8, date: Date().addingTimeInterval(-86400), userIds: ["user2"], sentiment: .neutral, sentimentScore: 0.5),
            CommentDataPoint(id: 3, parentId: 3, subreddit: "wallstreetbets", username: "user1", type: "comment", emoji: "😂", message: "Test message 3", score: 70.0, upvotes: 120, downvotes: 15, upvoteRatio: 0.85, date: Date().addingTimeInterval(-172800), userIds: ["user1"], sentiment: .positive, sentimentScore: 0.9)
        ]
        
        SimpleCommentChart(data: sampleData)
            .frame(height: 300)
            .padding()
    }
}

