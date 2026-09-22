//
//  CallingView.swift
//  voip-ios
//
//  Created by 강준현 on 9/18/26.
//

import OSLog
import SwiftUI

struct CallingView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var timer: Timer
    @State private var vm: CallingViewModel

    private let roomCode: String

    init(roomCode: String, timeLimitSeconds: Int) {
        self.roomCode = roomCode
        _timer = State(
            initialValue: Timer(
                limit: timeLimitSeconds
            )
        )
        _vm = State(
            initialValue: CallingViewModel(
                signalClient: SignalClientImpl(
                    url: URL(string: "ws://localhost:8080/signaling")!
                )
            )
        )
    }

    var body: some View {
        VStack {
            Text("연결 중")
            Text(roomCode)
            Text("상대방을 기다리고 있어요")
            Text("같은 코드 \(roomCode) 를 다른 기기에서 입력하면 바로 통화가 시작됩니다")
            Text("\(timer.time)초 후 자동 종료")
            Button("취소") {
                dismiss()
            }
            .accessibilityIdentifier("cancel_button")
        }
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("calling_view")
        .task {
            timer.startTimer()
            await self.vm.startCall(roomCode: roomCode)
        }
        .onChange(of: timer.time) { _, new in
            if new == 0 {
                dismiss()
            }
        }
    }
}

#Preview {
    CallingView(roomCode: "0000", timeLimitSeconds: 60)
}
