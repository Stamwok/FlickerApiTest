//
//  User.swift
//  FlickerApiTest
//
//  Created by  Егор Шуляк on 31.01.22.
//

import Foundation

struct UserInfo: Decodable {
    var username: Content
    var realname: Content?
    var location: Content?
    var profileurl: Content?
}

struct Content: Decodable {
    var content: String
    enum CodingKeys: String, CodingKey {
        case content = "_content"
    }
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.content = try container.decode(String.self, forKey: .content)
    }
}
