//
//  ContentView.swift
//  voip-ios
//
//  Created by 강준현 on 9/17/26.
//

import SwiftUI

struct ContentView: View {
    @State private var roomCode: String = ""

    private func character(at index: Int) -> String? {
        guard index < roomCode.count else {
            return nil
        }
        let index = roomCode.index(roomCode.startIndex, offsetBy: index)
        return String(roomCode[index])
    }

    @ViewBuilder
    var RoomCodeSection: some View {
        HStack {
            ForEach(0..<4, id: \.self) { index in
                Text(character(at: index) ?? "")
                    .accessibilityIdentifier("room_code_digit_\(index)")
            }
        }
    }
    
    var body: some View {
        VStack {
            Text("방 코드")
            Text("두 기기에 같은 코드를 입력하세요")
            RoomCodeSection
            NumberKeypad(roomCode: $roomCode)
            Button("통화 시작") {
                print("Start Call")
            }
            .disabled(roomCode.count != 4)
            .accessibilityIdentifier("call_button")
        }
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("numbers_keypad")
        .padding()
    }
}

#Preview {
    ContentView()
}
