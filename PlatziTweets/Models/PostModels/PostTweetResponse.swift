//
//  PostTweetResponse.swift
//  PlatziTweets
//
//  Created by Cesar Humberto Grifaldo Garcia on 10/11/22.
//

import Foundation

struct PostTweetResponse: Codable{
    let id: String
    let author: User
    let imageUrl: String
    let text: String
    let videoUrl: String
    let location: Location
    let hasVideo: Bool
    let hasImage: Bool
    let hasLocation: Bool
    let createdAt: String
}
