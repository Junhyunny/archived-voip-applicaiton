# Course Day 09 — CallHistory Repository와 Pagination

[이전 Day](day-08.md) · [전체 진도](day-00.md) · [다음 Day](day-10.md)

- [ ] Day 09 완료

## 중점 학습

- Remote+Cache CallHistoryRepository, LoadPolicy, 목록·상세·페이지네이션과 요청 중복·취소

## 과정 내용

> 아래 과정 내용은 `plan.md`의 해당 Day 구간을 빠짐없이 옮긴 것이다.

## Day 9 — CallHistory Repository와 Pagination

구현:

```text
통화 기록 목록
날짜별 Section
Pull to refresh
무한 스크롤
통화 상세
CallHistoryRepository
Remote + Memory Cache
```

TDD:

```text
첫 페이지 로딩
다음 페이지 로딩
마지막 페이지 이후 요청하지 않음
refresh 중 기존 pagination 취소
동일 데이터 중복 제거
pagination 오류 후 retry
화면 종료 시 요청 취소
```

Repository는 데이터가 Remote, Cache, Persistence 중 어디서 오는지 숨긴다. `cacheFirst`, `remoteFirst` 같은 `LoadPolicy`를 요구사항이 실제로 필요로 할 때 추가하며, 처음부터 모든 조합을 만들지 않는다.

UI 확인:

```text
0건
1건
1,000건
매우 긴 사용자 이름
번호가 없는 통화
삭제된 사용자
```

---
