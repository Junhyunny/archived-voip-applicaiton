# Course Day 26 — Architecture Refactoring 시험

[이전 Day](day-25.md) · [전체 진도](day-00.md) · [다음 Day](day-27.md)

- [ ] Day 26 완료

## 중점 학습

- Characterization test 뒤 Adapter·Repository·Policy·State Machine·Navigation을 점진 추출

## 과정 내용

> 아래 과정 내용은 `plan.md`의 해당 Day 구간을 빠짐없이 옮긴 것이다.

## Day 26 — Architecture Refactoring 시험

일부러 거대한 클래스를 만든다.

```swift
final class CallViewModel {
    // Navigation
    // URLSession
    // CallKit
    // AVAudioSession
    // UserDefaults
    // 화면 상태
    // Logger
    // Timer
    // 전부 포함
}
```

바로 전면 재작성하지 않는다.

```text
1. 현재 동작을 characterization test로 고정
2. 변경할 동작 하나 선택
3. system dependency에 seam 추가
4. 실패 테스트 작성
5. 최소 변경
6. 작은 책임 하나 추출
```

추출 순서는 이름난 Architecture를 완성하기 위한 것이 아니다. 현재 변경을 안전하게 만드는 순서로 Adapter → Repository → Policy → State Machine → Navigation 후보를 하나씩 검토하고, 이점이 없는 계층은 만들지 않는다.

입사 후 기존 코드를 만났을 때 가장 유용한 연습이다.

---
