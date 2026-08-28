# Course Day 29 — 대형 Feature 변경과 Architecture 판단

[이전 Day](day-28.md) · [전체 진도](day-00.md) · [다음 Day](day-30.md)

- [ ] Day 29 완료

## 중점 학습

- 대형 Feature composition에서 parent/shared state를 판단하며 실무 요구 변경과 PR을 완주

## 과정 내용

> 아래 과정 내용은 `plan.md`의 해당 Day 구간을 빠짐없이 옮긴 것이다.

## Day 29 — 대형 Feature 변경과 Architecture 판단

가상의 요구사항을 받았다고 가정한다.

> 통화 품질이 Poor로 5초 이상 유지되면 사용자에게 네트워크 전환 안내를 표시한다. 다만 통화가 종료됐거나 이미 한 번 닫은 안내는 다시 표시하지 않는다.

수행:

```text
Acceptance criteria 작성
State machine 영향 확인
실패 테스트 작성
Clock 주입
UI 구현
Preview
XCUITest 한 개
PR 설명 작성
```

PR에는 다음을 포함한다.

```text
문제
사용자 영향
상태 변화
변경 내용
추가한 테스트
수동 검증
남은 위험
```

변경이 `ActiveCall`, `Quality`, Navigation, Analytics에 걸쳐 번질 때 어느 state를 parent로 올리고 어느 action을 child에 남길지 결정한다. Composite 구조가 단순 전달 코드만 늘리면 다시 합친다.

---
