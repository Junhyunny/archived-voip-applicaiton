# Course Day 06 — Design System과 접근성

[이전 Day](day-05.md) · [전체 진도](day-00.md) · [다음 Day](day-07.md)

- [ ] Day 06 완료

## 중점 학습

- 의미 기반 디자인 토큰과 최소 Design System, Dynamic Type·VoiceOver·Dark Mode 등 접근성

## 과정 내용

> 아래 과정 내용은 `plan.md`의 해당 Day 구간을 빠짐없이 옮긴 것이다.

## Day 6 — Design System과 접근성

Design System은 거대한 별도 프레임워크가 아니라 다음부터 시작한다.

```text
Spacing
Typography
Color semantics
Button styles
Text field styles
Card
Error banner
Loading indicator
Empty state
```

색상 이름은 시각적 색이 아니라 의미로 짓는다.

```text
좋음:
textPrimary
surfaceElevated
statusWarning
actionPrimary

피해야 함:
gray700
prettyBlue
darkCardColor
```

Apple HIG의 Foundations, Patterns, Components를 기준으로 시스템 컴포넌트를 먼저 사용하고, 제품 요구가 명확한 부분만 커스텀한다.

접근성 확인:

```text
VoiceOver label
VoiceOver reading order
Dynamic Type
버튼의 충분한 터치 영역
색상만으로 상태를 전달하지 않기
Reduce Motion
Dark Mode
```

SwiftUI 기본 컨트롤은 기본 접근성 정보를 제공하지만, 커스텀 카드나 차트, UIKit wrapper는 직접 label과 value를 보완해야 한다.

---
