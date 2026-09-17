//
//  Untitled.swift
//  voip-ios
//
//  Created by 강준현 on 9/17/26.
//

import SwiftUI

struct NumberKeypad: View {
    @Binding var roomCode: String
    
    var body: some View {
        LazyVGrid(columns: [GridItem(), GridItem(), GridItem()]) {
            ForEach(1...9, id: \.self) { number in
                Button("\(number)") {
                    roomCode.append("\(number)")
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
                roomCode.append("0")
            }
            .accessibilityIdentifier("keypad_0")
            Button("delete") {
                print("Actions for delete")
            }
            .accessibilityIdentifier("keypad_delete")
        }
    }
}
