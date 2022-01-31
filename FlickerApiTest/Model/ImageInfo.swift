//
//  Image.swift
//  FlickerApiTest
//
//  Created by  Егор Шуляк on 26.01.22.
//

import Foundation
import UIKit

struct ImageInfo: Decodable {
    var id: String
    var owner: String
    var title: String
    var secret: String
    var server: String
    var imageAspectRatio: CGFloat?
}
