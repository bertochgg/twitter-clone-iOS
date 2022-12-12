//
//  PostTweetRequest.swift
//  PlatziTweets
//
//  Created by Cesar Humberto Grifaldo Garcia on 10/11/22.
//

import Foundation

struct PostTweetRequest: Codable{
    let text: String
    let imageUrl: String?
    let videoUrl: String?
    let location: Location?
}
