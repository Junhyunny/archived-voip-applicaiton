# Course Day 18 — Async Effect, Cancellation과 CallKit 경계

[이전 Day](day-17.md) · [전체 진도](day-00.md) · [다음 Day](day-19.md)

- [ ] Day 18 완료

## 중점 학습

- Async Effect 실행·Task cancellation, CallKit/PushKit 이벤트 변환과 비정상 event 순서

## 과정 내용

> 아래 과정 내용은 `plan.md`의 해당 Day 구간을 빠짐없이 옮긴 것이다.

## Day 18 — Async Effect, Cancellation과 CallKit 경계

구현 범위:

```text
CallKit adapter
수신 통화 보고
발신 통화 요청
Answer/End/Hold action 변환
Push payload parsing
Effect 실행기
Task ID와 cancellation
```

UI에서는 CallKit 객체를 직접 사용하지 않는다.

```text
CXAnswerCallAction
    ↓
CallKitAdapter
    ↓
ActiveCallAction.answerRequested
    ↓
Reducer
```

TDD:

```text
정상 수신 payload
UUID 누락
중복 incoming push
CallKit transaction 실패
answer가 transport 준비보다 먼저 도착
remote end가 UI 표시보다 먼저 도착
통화 종료 → transport/audio/network effect cancel
cancel 뒤 도착한 action 무시
```

Effect는 성공과 실패를 다시 Action으로 보내고, 화면 이탈이나 통화 종료가 어떤 Task를 취소하는지 명시한다. `Task {}`를 Reducer 곳곳에서 임의로 만들지 않는다.

---
