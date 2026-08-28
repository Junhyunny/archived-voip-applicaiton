# Day 30 — 실제 장애 대응 모의 PR

- [ ] 완료

### 사용자 스토리

> 운영팀으로서 SIM 전환과 Bluetooth 해제가 겹칠 때 이전 SIM 상태가 표시되는 장애를 재현·수정·회귀 검증할 수 있기를 원한다.

### 중점 학습

- 로그와 상태 timeline으로 race condition을 재현하기
- callback부터 UI까지 아키텍처 경계를 따라 근본 원인 찾기
- 실패 테스트, 기기 검증, 회귀 위험과 rollback을 담은 PR 작성

### 버그

> SIM 1로 통화하던 중 SIM 설정이 변경되고 Bluetooth가 해제되면 통화 화면이 이전 SIM 신호 상태를 표시한다.

### 분석 경계

```text
Telephony callback
→ Subscription Adapter
→ Repository
→ CallSessionController
→ ViewModel
→ UI
```

### 실패 테스트

```gherkin
시나리오: Subscription 전환 후 이전 SIM callback 무시
  조건 SIM 1로 통화 중이다.
  만일 SIM 2를 선택한 뒤 SIM 1의 늦은 callback이 도착하면
  그러면 SIM 1 callback을 무시한다.
  그리고 UI에는 SIM 2 상태를 표시한다.
```

Bluetooth 해제 event와 remote disconnect까지 동시에 발생하는 race 테스트를 추가한다.

### 모의 PR

```text
Problem
Reproduction
Root Cause
State Owner와 Architecture Boundary
Change
Unit Test
Integration Test
Device Test
Process-death Test
Regression Risk
Rollback
```

### 완료 조건

- 재현 → 실패 테스트 → 최소 수정 → 회귀 검증 순서를 지킨다.
- 로그 타임라인과 테스트가 근본 원인을 함께 설명한다.
- 코드를 보지 않고 핵심 CallReducer와 FakeEventSource를 다시 구현해본다.

---
