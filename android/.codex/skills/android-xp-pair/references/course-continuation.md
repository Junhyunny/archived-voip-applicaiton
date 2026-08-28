# 연속 코스 진행과 학습 내비게이션

사용자가 “개발 시작하자”라고 하거나 마지막 진도에서 과정을 이어가길 원할 때 읽는다.

## 재개 지점 찾기

1. `courses/day-00.md`와 `courses/day-01.md`부터 `day-30.md`까지 완료 표시를 확인한다.
2. `- [x] 완료`가 연속된 마지막 Day의 다음 Day를 후보로 잡는다. 중간에 미완료 Day가 있으면 뒤의 체크 표시와 관계없이 첫 미완료 Day로 돌아간다.
3. 후보 Day의 `homework/day-XX.md`가 `진행 중`이면 그 문서의 `다음 시작점`부터 재개한다.
4. 현재 코드와 테스트가 문서의 기록과 일치하는지 가장 좁은 테스트나 읽기 전용 검사로 확인한다. 체크 표시만 믿고 이미 완료했다고 단정하지 않는다.
5. 모든 Day가 완료됐다면 capstone의 미검증 항목이나 사용자가 선택한 복습 스토리를 제안한다. 임의로 Day 31을 만들지 않는다.

세션을 시작할 때 다음을 짧게 알린다.

```text
재개 지점: Day XX / 마지막 건강한 체크포인트
오늘의 사용자 결과: ...
핵심 개념: ...
상태 owner와 수명: ...
첫 Red 테스트: ...
드라이버: 사용자 또는 코치
```

## 한 번에 구현할 범위

Day 전체를 한 번에 밀어 넣지 않는다. Day 문서의 시나리오 중 하나를 독립적으로 Green까지 만들 수 있는 가장 작은 수직 스토리로 선택한다. 하나의 플랫폼 경계와 상태에서 UI까지의 흐름을 우선하고, 남은 시나리오는 homework의 다음 시작점에 둔다.

새 개념을 구현하기 전에 다음 순서로 파일과 심볼을 안내한다.

```text
1. 실패 테스트: 깨질 행동을 먼저 볼 위치
2. 순수 상태·정책: Android 없이 결정할 위치
3. Android Adapter/Repository: 프레임워크가 들어오는 경계
4. ViewModel/State Holder: UI 상태를 생산하는 위치
5. Screen/Fragment: 사용자가 결과를 관찰하는 위치
```

실제 구조에 없는 계층은 만들지 않는다. UseCase, Reducer, Repository는 현재 복잡성이나 테스트 seam이 요구할 때만 도입한다.

## 코드 내 학습 주석

학습자가 입력에서 결과까지 다시 추적해야 하는 진입점, 상태 owner, Android 프레임워크 경계, 테스트 seam에만 다음 형식으로 남긴다.

```kotlin
// STUDY-NAV(Day 18)
// Concept: CallSessionController가 화면보다 긴 통화 수명을 소유한다.
// Flow: Telecom callback -> CallEventSource -> CallReducer -> StateFlow -> InCall UI.
// Implement: 이 경계에서는 framework Call을 AppCallEvent로 변환한다.
// Test: FakeCallEventSource로 중복·지연 callback의 최종 상태를 검증한다.
```

모든 줄이 항상 필요한 것은 아니다. 최소한 `Concept`와 `Test` 또는 `Flow`가 있어야 한다. 다음 원칙을 지킨다.

- `STUDY-NAV(Day XX)`를 공통 검색 키로 사용한다.
- 구현되지 않은 작업은 `Implement:`에 구체적인 파일·심볼·관찰 결과를 적고 모호한 `TODO`를 쓰지 않는다.
- 운영 제약이나 비즈니스 규칙은 학습 주석에만 의존하지 않고 타입·테스트·정식 문서로도 보호한다.
- 같은 내용을 여러 파일에 복제하지 않는다. 흐름의 다음 위치를 심볼 이름으로 가리킨다.
- Day가 끝나도 복습 가치가 있는 경계 주석은 유지한다. 자명해졌거나 코드와 어긋난 주석은 Refactor 단계에서 갱신하거나 제거한다.

## Day 완료와 homework

Day 완료 조건과 관련 테스트가 모두 통과해야 완료 표시를 갱신한다. `homework/day-XX.md`는 `homework/_template.md`를 바탕으로 다음을 구체적으로 채운다.

- 코스가 가르치려던 판단과 그 이유
- 사용자 동작에서 테스트까지 이어지는 코드 내비게이션
- Red 실패 메시지, 최소 Green, Refactor 결정
- JVM·UI·계측·기기 중 실행한 검증과 실행하지 못한 검증
- 상태 owner, lifetime, SSOT, process death 복구 경로
- 추가로 공부할 개념과 기억을 꺼내는 질문
- 다음 세션이 바로 실행할 파일, 심볼, 테스트 이름

완료하지 못한 세션도 같은 파일에 `진행 중`으로 기록한다. 다음 세션은 대화 기억이 아니라 이 기록과 저장소 상태에서 재개한다.
