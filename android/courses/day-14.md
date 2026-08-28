# Day 14 — 수동 DI에서 Hilt로

- [ ] 완료

### 사용자 스토리

> 개발자로서 production 플랫폼 구현을 Fake로 교체해 같은 사용자 흐름을 빠르고 결정적으로 테스트하기를 원한다.

### 중점 학습

- constructor injection이 테스트 가능성을 만드는 이유
- scope가 객체의 lifetime과 일치해야 하는 이유
- production과 Fake binding 교체

### 구현

먼저 수동으로 Repository와 EventSource를 주입하고 테스트한다. 그 다음 같은 계약을 Hilt binding으로 옮긴다.

### TDD 시나리오

```text
FakeCallRepository 교체
FakeTelephonyEventSource 교체
scope가 다른 객체의 소유권 검증
Hilt를 제거해도 핵심 클래스 테스트 가능
```

### 완료 조건

- Hilt annotation보다 constructor dependency의 의미를 먼저 설명한다.
- app, Activity, ViewModel scope의 수명 차이를 말할 수 있다.

---
