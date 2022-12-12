//
//  RegisterRequest.swift
//  PlatziTweets
//
//  Created by Cesar Humberto Grifaldo Garcia on 10/11/22.
//

import Foundation

struct RegisterRequest: Codable{
    let email: String
    let password: String
    let names: String
}
