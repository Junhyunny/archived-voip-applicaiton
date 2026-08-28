# Course Day 19 — Child Feature Composition과 Lifecycle

[이전 Day](day-18.md) · [전체 진도](day-00.md) · [다음 Day](day-20.md)

- [ ] Day 19 완료

## 중점 학습

- ActiveCall parent/child Feature composition, lifecycle·권한 callback을 Reducer Action으로 처리

## 과정 내용

> 아래 과정 내용은 `plan.md`의 해당 Day 구간을 빠짐없이 옮긴 것이다.

## Day 19 — Child Feature Composition과 Lifecycle

`ActiveCallFeature`를 다음처럼 나누되, 각 child가 독립 상태와 행동을 가질 이유가 있을 때만 추출한다.

```text
ActiveCallFeature
├── CallControlsFeature
├── QualityFeature
└── AudioRouteFeature
```

Parent는 child Action을 필요한 Domain event로 번역하고, child의 local state를 AppState에 중복 저장하지 않는다.

구현:

```text
Foreground
Background
전화 잠금 상태
마이크 권한
알림 권한
진단 데이터 수집 동의
```

권한 화면에서는 “허용해 주세요”만 표시하지 않는다.

```text
왜 필요한가?
허용하지 않으면 무엇이 제한되는가?
지금 요청할 필요가 있는가?
거부 후 어떤 대체 흐름이 있는가?
설정 앱으로 이동해야 하는가?
```

TDD:

```text
notDetermined → 설명 후 요청
denied → 시스템 요청 반복하지 않음
denied → 설정 이동 안내
restricted → 설정 이동 버튼 미표시
통화 시작 직전 권한 거부
```

앱 lifecycle과 권한 callback도 Action으로 들어오게 해 순서가 바뀐 경우를 Reducer 테스트로 재생한다.

---
