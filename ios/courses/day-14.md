# Course Day 14 — MVVM vs Action/Reducer 탐색과 UI 테스트

[이전 Day](day-13.md) · [전체 진도](day-00.md) · [다음 Day](day-15.md)

- [ ] Day 14 완료

## 중점 학습

- 동일 검색 Feature의 MVVM vs 직접 Action/Reducer 비교와 Stub dependency 기반 핵심 XCUITest

## 과정 내용

> 아래 과정 내용은 `plan.md`의 해당 Day 구간을 빠짐없이 옮긴 것이다.

## Day 14 — MVVM vs Action/Reducer 탐색과 UI 테스트

Week 2의 검색 기능을 복사하지 않고, 동일한 인수 예제를 만족하는 두 번째 구현을 작은 `State + Action + reduce` 형태로 만든다. 아직 TCA를 설치하지 않는다.

비교 기록:

```text
상태 변화 위치는 어디가 더 명확한가?
비동기 응답은 어떤 경로로 돌아오는가?
취소와 늦은 응답 처리는 어디에 있는가?
현재 크기에서 추가된 코드 비용은 정당한가?
```

XCUITest 3개를 만든다.

```text
로그인 성공 → 홈 표시
통화 검색 → 상세 진입
장애 신고 작성 → 제출 성공
```

테스트 전용 launch argument를 사용한다.

```text
-ui-testing
-stub-scenario login-success
-stub-scenario call-history-empty
-stub-scenario support-submit-failure
```

UI 테스트가 실제 서버에 의존하지 않도록 앱 시작 시 Stub dependency를 주입한다.

---
