# Day 25 — Process Death Chaos Test

- [ ] 완료

### 사용자 스토리

> 사용자로서 시스템이 앱 프로세스를 종료해도 영속 데이터와 최소 화면 맥락은 복원되고 진행 중 통화는 시스템 상태와 재동기화되기를 원한다.

### 중점 학습

- 상태별 복원 요구사항을 제품 관점에서 결정
- saved state, 영속 데이터, 지속 작업, 시스템 세션의 차이
- 재시작 시 시스템과 앱 상태 reconciliation

### Chaos 시점

```text
검색 중
목록 로딩 중
Call detail 열린 상태
권한 dialog 직후
Subscription 변경 직후
통화 중 UI 표시 중
리포트 업로드 중
```

### 기대 복구

```text
UI element state → rememberSaveable
screen input → SavedStateHandle
app data → Room/DataStore
ongoing persistent work → WorkManager
active telecom session → 시스템과 CallSessionController 재동기화
```

### 완료 조건

- 각 시점의 복구 여부, source of truth, 사용자 기대를 표로 남긴다.
- 단순 Activity recreate와 실제 process death 검증을 구분한다.
