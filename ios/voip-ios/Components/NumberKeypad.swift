//
//  Untitled.swift
//  voip-ios
//
//  Created by 강준현 on 9/17/26.
//

import SwiftUI

struct NumberKeypad: View {
    @Binding var roomCode: String

    private func tabKeypad(number: String) {
        if roomCode.count < 4 {
            roomCode.append(number)
        }
    }

    var body: some View {
        LazyVGrid(columns: [GridItem(), GridItem(), GridItem()]) {
            ForEach(1...9, id: \.self) { number in
                Button("\(number)") {
                    tabKeypad(number: "\(number)")
                }
                .accessibilityIdentifier("keypad_\(number)")
            }
        }
        LazyVGrid(columns: [GridItem(), GridItem(), GridItem()]) {
            Button("") {
                print("Actions for empty")
            }
            .accessibilityIdentifier("keypad_empty")
            Button("0") {
                tabKeypad(number: "0")
            }
            .accessibilityIdentifier("keypad_0")
            Button("delete") {
                if roomCode.isEmpty {
                    return
                }
                roomCode.remove(at: roomCode.index(before: roomCode.endIndex))
            }
            .accessibilityIdentifier("keypad_delete")
        }
    }
}
