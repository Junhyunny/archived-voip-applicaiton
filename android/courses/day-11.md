# Day 11 — 목록, Paging과 Repository

- [ ] 완료

### 사용자 스토리

> 사용자로서 통화 내역을 새로고침하거나 다음 페이지를 불러오는 동안 중복·누락 없이 기존 콘텐츠를 계속 볼 수 있기를 원한다.

### 중점 학습

- `CallHistoryRepository`와 데이터 소스 추상화
- LazyColumn item key와 Paging 상태
- refresh와 pagination의 동시성

### TDD 시나리오

```text
첫 페이지와 다음 페이지
중복 데이터 제거
페이지 실패와 retry
마지막 페이지
refresh와 paging 동시 발생
늦게 도착한 이전 query 결과 무시
```

### 완료 조건

- ViewModel은 Room, HTTP 응답 형식, Paging 데이터 소스 세부를 모른다.
- 빈 상태, stale content, pagination 오류를 서로 구분한다.
