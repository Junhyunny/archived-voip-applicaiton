# Day 02 — MVVM + UDF 대시보드

- [ ] 완료

### 사용자 스토리

> 사용자로서 대시보드가 로딩·성공·실패·재시도 상태를 일관되게 보여주기를 원한다. 그래야 현재 상황과 다음 행동을 알 수 있다.

### 중점 학습

- ViewModel을 UI controller가 아니라 screen state producer로 이해하기
- `StateFlow`와 `collectAsStateWithLifecycle()`
- Stateless Screen과 Route 분리

### 구현

```text
DashboardScreen
      ↑ UiState
DashboardViewModel
      ↓
FakeDashboardRepository
```

### TDD 시나리오

```text
초기 → Loading
Repository 성공 → Content
Repository 실패 → Error
Retry → Loading → Content
화면 수집 중지 → 불필요한 작업 중지 또는 정책대로 유지
```

### 완료 조건

- Screen은 상태와 callback만 받는다.
- ViewModel은 Android `Activity`, `Context`, View를 참조하지 않는다.
- 회전 후 ViewModel 상태가 유지되는 이유를 설명한다.
