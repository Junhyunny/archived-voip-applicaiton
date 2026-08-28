# Course Day 02 — SwiftUI Layout과 View identity

[이전 Day](day-01.md) · [전체 진도](day-00.md) · [다음 Day](day-03.md)

- [ ] Day 02 완료

## 중점 학습

- SwiftUI 기본 레이아웃, View identity, `ForEach`의 안정적인 ID, 화면 상태를 표현하는 ViewState

## 과정 내용

> 아래 과정 내용은 `plan.md`의 해당 Day 구간을 빠짐없이 옮긴 것이다.

## Day 2 — SwiftUI Layout과 View identity

학습:

```text
VStack / HStack / ZStack
ScrollView
List
Grid
safeAreaInset
View identity
ForEach의 안정적인 ID
```

구현:

```text
홈 대시보드
요금제 카드
데이터 사용량 카드
현재 네트워크 카드
공지 배너
```

TDD:

```text
데이터가 모두 있으면 카드가 표시될 상태 생성
사용량 데이터가 없으면 unavailable 상태
사용량 100% 이상이면 경고 상태
오래된 데이터면 stale 표시
```

여기서는 View 자체보다 `HomeViewState` 생성 규칙을 테스트한다.

---
