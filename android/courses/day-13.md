# Day 13 — Offline-first와 Room SSOT

- [ ] 완료

### 사용자 스토리

> 사용자로서 네트워크가 없어도 저장된 통화 내역을 보고, 연결이 돌아오면 최신 데이터로 갱신되기를 원한다.

### 중점 학습

- 로컬 데이터 소스를 canonical source of truth로 사용하기
- 네트워크 결과를 Room에 반영하고 UI는 Room Flow 관찰하기
- DataStore에 적합한 설정과 Room 데이터 구분

### 구현

```text
Server → Repository → Room → Flow → UI
```

### TDD 시나리오

```text
offline 시작과 cached data
refresh 성공
refresh 실패 + stale data warning
server와 DB conflict
중복 원격 응답
앱 재시작 후 데이터와 설정 복원
```

### 완료 조건

- UI가 서버 Response를 직접 관찰하지 않는다.
- conflict, stale, freshness 정책을 문서화한다.
