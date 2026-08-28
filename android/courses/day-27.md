# Day 27 — Observability와 Privacy-safe Decorator

- [ ] 완료

### 사용자 스토리

> 운영자로서 개인정보를 노출하지 않고도 통화 장애의 상태 전이 타임라인을 재구성하기를 원한다.

### 중점 학습

- Logging, Metrics, Analytics, Tracing을 핵심 로직과 분리
- 상태 전이 timeline 재구성
- 개인정보·전화번호·구독 정보의 안전한 기록

### 구현

```text
CallRepository
→ MetricsCallRepository
→ LoggingCallRepository
```

이벤트에는 필요한 최소한의 session ID, 익명화한 subscription 식별자, previous state, event, next state, elapsed time을 기록한다.

### TDD 시나리오

```text
정상 상태 전이 로그
중복 event 표시
민감 정보 미포함
Decorator 제거 후 핵심 동작 동일
로그 실패가 통화 동작을 깨지 않음
```

### 완료 조건

- 장애 타임라인을 로그에서 재구성할 수 있다.
- 운영 부가 기능이 핵심 인터페이스 계약을 바꾸지 않는다.
