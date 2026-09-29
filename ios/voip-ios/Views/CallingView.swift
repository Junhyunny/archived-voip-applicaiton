//
//  CallingView.swift
//  voip-ios
//
//  Created by 강준현 on 9/18/26.
//

import SwiftUI

struct CallingView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var timer: CountDownTimer
    @State private var vm: CallingViewModel

    private let roomCode: String

    init(roomCode: String, timeLimitSeconds: Int, signalingURL: URL) {
        self.roomCode = roomCode
        _timer = State(
            initialValue: CountDownTimer(
                limit: timeLimitSeconds
            )
        )
        _vm = State(
            initialValue: CallingViewModel(
                signalClient: SignalClientImpl(url: signalingURL)
            )
        )
    }

    private func checkIcon(isChecked: Bool, identifier: String) -> some View {
        Image(systemName: isChecked ? "checkmark.square.fill" : "square")
            .accessibilityIdentifier(identifier)
            .accessibilityValue(isChecked ? "checked" : "unchecked")
    }

    @ViewBuilder
    private var InfoSection: some View {
        switch vm.callStatus {
        case .idle, .joined, .peerJoined:
            VStack {
                Text("상대방을 기다리고 있어요")
                Text("같은 코드 \(roomCode) 를 다른 기기에서 입력하면 바로 통화가 시작됩니다")
            }
        case .negotiating:
            VStack {
                Text("상대방이 입장했어요")
                Text("음성을 연결하고 있어요")
                Text("잠시 후 통화 화면으로 이동합니다")
            }
        default:
            EmptyView()
        }
    }

    @ViewBuilder
    private var CheckList: some View {
        VStack {
            HStack {
                checkIcon(
                    isChecked: vm.callStatus == .joined
                        || vm.callStatus == .negotiating,
                    identifier: "checkbox_signaling_server"
                )
                Text("시그널링 서버 연결")
            }
            HStack {
                checkIcon(
                    isChecked: vm.callStatus == .negotiating,
                    identifier: "checkbox_peer_joined"
                )
                Text("상대방 입장")
            }
        }
    }

    @ViewBuilder
    private var MainSection: some View {
        switch vm.callStatus {
        case .connected:
            VStack {
                Text("연결됨 · P2P")
                Text(roomCode)
                Text("방 코드 \(roomCode) 로 통화 중")
                VStack {
                    Text("AI가 통화를 듣고 있어요")
                    Text("자막은 표시하지 않습니다. 통화가 끝나면 요약이 만들어집니다.")
                }
                Button(action: {
                    dismiss()
                }) {
                    Text("통화 종료")
                }
                .accessibilityIdentifier("leave_call")
            }
        default:
            VStack {
                Text("연결 중")
                Text(roomCode)
                InfoSection
                CheckList
                Text("\(timer.time)초 후 자동 종료")
                Button("취소") {
                    dismiss()
                }
                .accessibilityIdentifier("cancel_button")
            }
        }
    }

    var body: some View {
        MainSection
            .accessibilityElement(children: .contain)
            .accessibilityIdentifier("calling_view")
            .task {
                async let startCall = self.vm.startCall(roomCode: roomCode)
                async let startTimer = timer.startTimer()
                _ = await (startCall, startTimer)
            }
            .onChange(of: vm.callStatus) { _, new in
                switch new {
                case .connected:
                    timer.stop()
                case .disconnected:
                    dismiss()
                default:
                    break
                }
            }
            .onDisappear {
                vm.close()
            }
            .onChange(of: timer.time) { _, new in
                if new == 0 {
                    dismiss()
                }
            }
    }
}

#Preview {
    CallingView(
        roomCode: "0000",
        timeLimitSeconds: 60,
        signalingURL: AppConfiguration().signalingURL
    )
}
