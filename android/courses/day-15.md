# Day 15 — Permission State Machine

- [ ] 완료

### 사용자 스토리

> 사용자로서 권한 상태와 단말 지원 여부에 맞는 안내와 대체 행동을 제공받기를 원한다. 그래야 막힌 기능의 이유를 이해할 수 있다.

### 중점 학습

- Manifest permission, runtime permission, System Role 구분
- 권한을 Boolean이 아닌 상태 전이로 모델링
- 지원하지 않는 단말과 제한 기능의 대체 UX

### 구현

```text
Unknown → Checking → Granted
                   → Denied
                   → NeedsRationale
                   → Unavailable
```

### TDD 시나리오

```text
Granted → 기능 활성
Denied → 제한 UI
NeedsRationale → 설명 후 재요청
사용 중 권한 제거
다시 허용
API 자체 미지원
중복 권한 결과 callback
```

### 완료 조건

- 권한 요청 UI와 권한 상태 정책을 분리한다.
- 백그라운드에서 권한이 제거된 뒤 복귀하는 흐름을 검증한다.
