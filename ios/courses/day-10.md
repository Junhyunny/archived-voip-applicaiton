# Course Day 10 — Strategy와 검색·필터·Debounce

[이전 Day](day-09.md) · [전체 진도](day-00.md) · [다음 Day](day-11.md)

- [ ] Day 10 완료

## 중점 학습

- Retry/debounce Strategy, 검색·필터 조합, 이전 Task 취소와 late response 무시, 주입 가능한 Clock

## 과정 내용

> 아래 과정 내용은 `plan.md`의 해당 Day 구간을 빠짐없이 옮긴 것이다.

## Day 10 — Strategy와 검색·필터·Debounce

구현:

```text
전화번호 또는 이름 검색
수신/발신/부재중 필터
기간 필터
최근 검색어
RetryPolicy / Debounce 정책
```

TDD:

```text
빈 검색어는 전체 목록
300ms 동안 입력이 없을 때 검색
새 입력이 오면 이전 검색 취소
이전 요청이 늦게 도착해도 최신 결과 유지
필터와 검색어 동시 적용
```

실제 300ms를 기다리는 테스트는 만들지 않는다. Clock 또는 Debouncer를 주입해 즉시 진행 가능한 테스트를 만든다.

검색 debounce, retry, 품질 분류처럼 교체 가능한 규칙을 Strategy로 분리한다. 단 하나의 고정 규칙뿐이라면 Protocol부터 만들지 않고 순수 함수나 값 타입으로 시작한다.

---
