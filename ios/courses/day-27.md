# Course Day 27 — 테스트 Architecture와 CI

[이전 Day](day-26.md) · [전체 진도](day-00.md) · [다음 Day](day-28.md)

- [ ] Day 27 완료

## 중점 학습

- 단위/통합/UI 테스트 경계와 PR·main·nightly CI, 실패 artifact와 TestFlight 내부 배포

## 과정 내용

> 아래 과정 내용은 `plan.md`의 해당 Day 구간을 빠짐없이 옮긴 것이다.

## Day 27 — 테스트 Architecture와 CI

테스트 개수 자체보다 경계별 위험에 맞는 가장 저렴한 피드백을 선택한다.

```text
많음  상태 전이·Policy·Reducer 단위 테스트
      Repository·Adapter 통합 테스트
적음  핵심 사용자 흐름 XCUITest
```

월말 목표 범위는 빠른 Unit 50~70개, Integration 10~15개, XCUITest 3~5개지만 숫자를 채우기 위해 구현 세부사항을 테스트하지 않는다.

```text
PR
├── Swift Testing
├── XCTest unit/integration
├── Lint
└── Build

main
├── PR 테스트
├── XCUITest smoke
└── TestFlight 내부 배포

Nightly
├── 전체 UI Test
├── 여러 기기
├── 성능 Test
└── Sanitizer
```

UI 테스트 실패 시 다음을 attachment로 남긴다.

```text
Screenshot
현재 화면 hierarchy
앱 로그
Stub scenario
실패 단계
```

---
