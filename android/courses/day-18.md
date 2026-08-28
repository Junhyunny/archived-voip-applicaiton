# Day 18 — Telecom State Machine과 CallSessionController

- [ ] 완료

### 사용자 스토리

> 통화 사용자로서 화면이 사라지거나 Telecom callback 순서가 바뀌어도 실제 통화 세션이 계속 정확히 유지되기를 원한다.

### 중점 학습

- Telecom, InCallService, ConnectionService의 책임 차이
- 실제 통화 lifetime과 화면 lifetime 분리
- Adapter, Reducer, Observer, Coordinator 결합

### 구현

```text
Telecom
→ CallEventSource
→ CallSessionController
→ CallReducer
→ StateFlow<CallSession>
   ├─ Notification
   └─ InCallViewModel → Compose
```

### TDD 시나리오

```text
incoming → answer → active → disconnect
hold/resume
두 통화 swap
중복 callback
역순 callback
화면 제거 중 통화 지속
process 재생성 후 Telecom과 재동기화
```

### 완료 조건

- ViewModel이 실제 통화 session을 소유하지 않는다.
- 시스템 상태와 앱 reducer 상태가 어긋날 때 reconciliation 규칙이 있다.
