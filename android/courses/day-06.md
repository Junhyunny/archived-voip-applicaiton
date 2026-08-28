# Day 06 — Process Death와 State Ownership

- [ ] 완료

### 사용자 스토리

> 사용자로서 프로세스가 시스템에 의해 종료된 뒤에도 검색 맥락을 최소 정보로 복원하기를 원한다. 그래야 큰 데이터를 잘못 저장하지 않고 작업을 이어갈 수 있다.

### 중점 학습

- recomposition, configuration change, system process death의 차이
- `rememberSaveable`, ViewModel, `SavedStateHandle`, Room의 복원 범위
- 복원 키와 다시 계산할 데이터 분리

### 구현

검색어, filter, scroll, 선택 `callId`, 검색 결과, 통화 내역의 소유자를 각각 결정한다.

### TDD·복원 시나리오

```text
회전 후 검색어와 filter 유지
process recreation 후 callId 복원
검색 결과는 복원 키로 Repository에서 다시 생산
큰 목록을 SavedStateHandle에 저장하지 않음
사용자가 앱을 명시적으로 종료한 경우의 기대 동작 구분
```

### 완료 조건

- 각 상태의 source of truth와 복구 순서를 표로 남긴다.
- `StateRestorationTester` 또는 가능한 복원 테스트와 수동 process death 검증을 수행한다.
