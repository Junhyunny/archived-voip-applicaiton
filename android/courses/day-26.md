# Day 26 — Compose Performance와 State

- [ ] 완료

### 사용자 스토리

> 사용자로서 통화 시간이나 신호 상태가 자주 갱신돼도 화면이 불필요하게 다시 그려지지 않고 부드럽게 동작하기를 원한다.

### 중점 학습

- 상태 경계와 recomposition 범위
- stable key, immutable model, derived state
- Profiler, Layout Inspector, recomposition 도구로 근거 수집

### 실습

30개 필드의 `HugeUiState`와 잦은 Flow emission으로 jank를 만든 뒤 다음을 적용한다.

```text
변경 빈도가 다른 state 분리
derived state
stable item key
immutable model
불필요한 emission 제거
distinctUntilChanged
```

### 완료 조건

- 변경 전후 recomposition 또는 frame 지표를 기록한다.
- 추측이 아니라 측정 근거로 최적화한다.
