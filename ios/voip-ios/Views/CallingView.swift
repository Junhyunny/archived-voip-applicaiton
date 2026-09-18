//
//  CallingView.swift
//  voip-ios
//
//  Created by 강준현 on 9/18/26.
//

import SwiftUI

struct CallingView: View {
    var roomCode: String

    var body: some View {
        VStack {
            Text( /*@START_MENU_TOKEN@*/"Hello, World!" /*@END_MENU_TOKEN@*/)
        }
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("calling_view")
    }
}

#Preview {
    CallingView(roomCode: "0000")
}
