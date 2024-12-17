//
//  LazyView.swift
//  chatbot
//
//  Created by 문시현 on 12/17/24.
//

import SwiftUI

struct LazyView<Content: View>: View {
    let build: () -> Content
    init(_ build: @escaping () -> Content) {
        self.build = build
    }
    var body: Content {
        build()
    }
}
