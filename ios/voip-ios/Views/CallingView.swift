//
//  CallingView.swift
//  voip-ios
//
//  Created by 강준현 on 9/18/26.
//

import OSLog
import SwiftUI

private let logger = Logger(
    subsystem: "com.example.voip-ios",
    category: "Signaling"
)

struct JoinMessage: Codable {
    let type = "join"
    let roomCode: String
}

struct CallingView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var vm: CallingViewModel

    private let roomCode: String

    init(roomCode: String, timeLimitSeconds: Int) {
        self.roomCode = roomCode
        _vm = State(
            initialValue: CallingViewModel(
                limit: timeLimitSeconds
            )
        )
    }

    var body: some View {
        VStack {
            Text("연결 중")
            Text(roomCode)
            Text("상대방을 기다리고 있어요")
            Text("같은 코드 \(roomCode) 를 다른 기기에서 입력하면 바로 통화가 시작됩니다")
            Text("\(vm.time)초 후 자동 종료")
            Button("취소") {
                dismiss()
            }
            .accessibilityIdentifier("cancel_button")
        }
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("calling_view")
        .task {
            let url = URL(string: "ws://localhost:8080/signaling")!
            let webSocketTask =
                URLSession.shared.webSocketTask(with: url)
            webSocketTask.resume()
            do {
                let message = JoinMessage(roomCode: roomCode)
                let data = try JSONEncoder().encode(message)
                let string = String(decoding: data, as: UTF8.self)
                try await webSocketTask.send(.string(string))
                logger.info("CLIENT SENT: \(string)")
                let response = try await webSocketTask.receive()
                switch response {
                case .string(let text):
                    print("received text:", text)
                case .data(let data):
                    print("received data:", data)
                @unknown default:
                    break
                }
            } catch {
                logger.info("websocket error: \(error)")
            }
            await vm.startTimer()
        }
        .onChange(of: vm.time) { _, new in
            if new == 0 {
                dismiss()
            }
        }
    }
}

#Preview {
    CallingView(roomCode: "0000", timeLimitSeconds: 60)
}
