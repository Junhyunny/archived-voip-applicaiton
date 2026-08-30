# Day 01 — Layered Architecture와 테스트 기준점

- [ ] 완료

### 사용자 스토리

> 통화 사용자로서 종료된 통화 화면에 늦은 callback이 도착해도 `종료됨` 표시가 유지되기를 원한다. 그래야 화면에서 실제 통화가 다시 연결됐다고 오해하지 않는다.

### 중점 학습

- UI, Data, 선택적 Domain 레이어의 책임과 의존 방향
- UDF와 SSOT가 상태 변경을 한곳으로 모으는 이유
- JVM 테스트, 계측 테스트, Gradle 검증의 차이

### 구현

가장 작은 통화 상태 화면에서 시작해 순수 Kotlin `CallStateMachine`까지 하나의 슬라이스로 연결한다. `CallStateMachine`은 Android 타입을 사용하지 않는다.

```text
사용자에게 보이는 상태
→ CallStatusScreen
→ CallStateMachine
→ Idle → Dialing → Active → Holding → Disconnected
```

### TDD 시나리오

```text
화면이 Disconnected를 받음 → "종료됨" 표시
화면이 늦은 Connected 처리 결과를 받음 → 계속 "종료됨" 표시
Idle + StartOutgoing → Dialing
Dialing + Connected → Active
Active + Hold → Holding
Holding + Resume → Active
어떤 상태 + Disconnect → Disconnected
Disconnected + 늦은 Connected → Disconnected
```

### 완료 조건

- 화면의 사용자 행동에서 상태 정책까지 하나의 실행 가능한 슬라이스로 연결된다.
- 화면 수준 테스트 또는 기록된 UI 검증이 `종료됨` 표시 유지를 증명한다.
- Data나 Platform 구현이 UI 타입에 의존하지 않는다.
- 상태 전이 테스트가 Android 없이 실행된다.
- `testDebugUnitTest`, `lintDebug`, `assembleDebug`가 각각 무엇을 검증하는지 설명한다.
