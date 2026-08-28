# ios-study

`Telecom Companion`을 점진적으로 만들며 iOS와 XP를 학습하는 저장소입니다. SwiftUI local state에서 MVVM, Adapter/Repository, State Machine/Reducer, TCA 비교, production-ready architecture 판단까지 요구사항에 맞춰 구조를 발전시킵니다. 전체 커리큘럼 원문은 [plan.md](plan.md), Day별 과정과 진도표는 [courses/day-00.md](courses/day-00.md)에 있습니다.

## XP 페어 프로그래밍 코치

이 저장소의 에이전트는 iOS 학습·구현 요청을 받으면 [ios-xp-pair](skills/ios-xp-pair/SKILL.md)를 읽고 다음 방식으로 함께 작업합니다.

- 작은 사용자 가치 단위로 범위를 정합니다.
- 테스트 실패 → 최소 구현 → 리팩터링을 반복합니다.
- 현재 코드에 필요한 iOS 지식과 Xcode 이동 경로를 그때그때 설명합니다.
- 구현 결과뿐 아니라 직접 다시 실행하고 설명할 수 있는 상태를 목표로 합니다.

예시 요청:

```text
plan.md의 Day 1을 협업 구현 모드로 시작하자. 나는 iOS 완전 초보야.
로그인 화면은 내가 직접 코딩할게. 내비게이터 모드로 한 단계씩 안내해줘.
이 SwiftUI 컴파일 오류를 같이 고치면서 왜 발생했는지도 알려줘.
```
