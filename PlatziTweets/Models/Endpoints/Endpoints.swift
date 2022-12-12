//
//  Endpoints.swift
//  PlatziTweets
//
//  Created by Cesar Humberto Grifaldo Garcia on 09/11/22.
//

import Foundation


struct Endpoints{
    static let domain = "https://platzi-tweets-backend.herokuapp.com/api/v1"
    static let login = Endpoints.domain + "/auth"
    static let register = Endpoints.domain + "/register"
    static let getPosts = Endpoints.domain + "/posts"
    static let posts = Endpoints.domain + "/posts"
    static let delete = Endpoints.domain + "/posts/"
}
