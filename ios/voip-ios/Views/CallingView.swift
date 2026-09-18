//
//  CallingView.swift
//  voip-ios
//
//  Created by 강준현 on 9/18/26.
//

import SwiftUI

struct CallingView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.appConfiguration) private var appConfiguration
    @State private var vm: CallingViewModel = CallingViewModel()

    var roomCode: String

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
            await vm.startTimer(limit: appConfiguration.timeLimitSeconds)
        }
        .onChange(of: vm.time) { old, new in
            print(old, new)
            if new == 0 {
                dismiss()
            }
        }
    }
}

#Preview {
    CallingView(roomCode: "0000")
}
