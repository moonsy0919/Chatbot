//
//  DallEResponse.swift
//  chatbot
//
//  Created by 문시현 on 12/8/24.
//

import Foundation

struct DallEResponse: Decodable {
    let data: [ImageURL]
}

struct ImageURL: Decodable {
    let url: String
}
