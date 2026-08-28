# Day 01 — Layered Architecture와 테스트 기준점

- [ ] 완료

### 사용자 스토리

> 통화 사용자로서 늦은 callback이 와도 종료된 통화가 다시 활성화되지 않기를 원한다. 그래야 화면과 실제 통화 상태가 모순되지 않는다.

### 중점 학습

- UI, Data, 선택적 Domain 레이어의 책임과 의존 방향
- UDF와 SSOT가 상태 변경을 한곳으로 모으는 이유
- JVM 테스트, 계측 테스트, Gradle 검증의 차이

### 구현

순수 Kotlin `CallStateMachine`을 만든다. Android 타입을 사용하지 않는다.

```text
Idle → Dialing → Active → Holding → Disconnected
```

### TDD 시나리오

```text
Idle + StartOutgoing → Dialing
Dialing + Connected → Active
Active + Hold → Holding
Holding + Resume → Active
어떤 상태 + Disconnect → Disconnected
Disconnected + 늦은 Connected → Disconnected
```

### 완료 조건

- Data나 Platform 구현이 UI 타입에 의존하지 않는다.
- 상태 전이 테스트가 Android 없이 실행된다.
- `testDebugUnitTest`, `lintDebug`, `assembleDebug`가 각각 무엇을 검증하는지 설명한다.
