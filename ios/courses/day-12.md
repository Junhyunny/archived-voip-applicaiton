# Course Day 12 — Repository, Persistence와 Offline UX

[이전 Day](day-11.md) · [전체 진도](day-00.md) · [다음 Day](day-13.md)

- [ ] Day 12 완료

## 중점 학습

- Repository의 Memory/Local/Remote 조합, stale fallback, 중복 fetch 공유와 Offline UX

## 과정 내용

> 아래 과정 내용은 `plan.md`의 해당 Day 구간을 빠짐없이 옮긴 것이다.

## Day 12 — Repository, Persistence와 Offline UX

구현:

```text
마지막 통화 품질 결과 저장
통화 기록 cache
장애 신고 draft
설정 저장
```

TDD:

```text
cache가 있으면 우선 표시
백그라운드에서 최신 데이터 갱신
cache가 오래됐으면 stale 표시
offline에서 마지막 데이터 표시
저장 데이터 손상 시 안전하게 초기화
```

`CallHistoryRepository`를 Memory Cache → Local Persistence → Remote API로 확장한다. cache hit, stale refresh, remote 실패 시 stale fallback, 중복 fetch 공유를 Repository 통합 테스트로 검증한다.

화면은 다음을 구분해야 한다.

```text
데이터가 없음
아직 데이터를 불러오지 않음
오프라인이지만 이전 데이터가 있음
오프라인이고 이전 데이터도 없음
```

---
