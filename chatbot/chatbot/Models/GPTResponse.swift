//
//  GPTResponse.swift
//  chatbot
//
//  Created by 문시현 on 12/8/24.
//
import Foundation

struct GPTResponse: Decodable {
    let choices: [GPTCompletion]
}

struct GPTCompletion: Decodable{
    let text: String
    let finishReason: String
}
