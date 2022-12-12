//
//  RegisterResponse.swift
//  PlatziTweets
//
//  Created by Cesar Humberto Grifaldo Garcia on 10/11/22.
//

import Foundation

struct RegisterResponse: Codable{
    let user: User
    let token: String
}
