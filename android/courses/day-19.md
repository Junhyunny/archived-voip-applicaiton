# Day 19 — Audio Route Strategy

- [ ] 완료

### 사용자 스토리

> 통화 사용자로서 Bluetooth나 유선 endpoint가 사라지면 가능한 오디오 경로로 안전하게 전환되기를 원한다.

### 중점 학습

- Bluetooth, Speaker, Wired, Earpiece endpoint 모델
- 사용자의 선택과 fallback 정책 분리
- 요청 성공과 실제 callback 상태 구분

### 구현

`AudioRoutePolicy`와 Android Audio Adapter를 분리한다.

### TDD 시나리오

```text
Bluetooth 사라짐 → Wired
Wired 없음 → Earpiece
Speaker 강제 선택
route request 실패
선택 중 endpoint 소실
늦은 callback
Disconnected 이후 route event 무시
```

### 완료 조건

- Strategy는 Android 객체 없이 테스트된다.
- 실제 기기에서 Bluetooth 연결·해제와 실패 경로를 검증한다.
