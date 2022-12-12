//
//  LoginResponse.swift
//  PlatziTweets
//
//  Created by Cesar Humberto Grifaldo Garcia on 10/11/22.
//

import Foundation

struct LoginResponse: Codable{
    let user: User
    let token: String
}


