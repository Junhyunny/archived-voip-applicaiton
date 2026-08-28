# 진도 재개와 Homework

## 마지막 학습 지점 찾기

사용자가 별도 Day를 지정하지 않고 “개발 시작하자” 또는 이어서 진행하자고 하면 다음 증거를 함께 확인한다.

1. `courses/day-00.md` 진도표의 완료 체크
2. `courses/day-XX.md`의 `Day XX 완료` 체크
3. 관련 production code와 test code
4. 해당 Day의 완료 조건을 입증하는 최근 실행 결과
5. `homework/day-XX.md`가 있다면 해결되지 않은 위험과 다음 Story

체크된 마지막 Day의 다음 Day를 기본 후보로 삼는다. 다만 후보 Day가 이미 일부 구현되어 있으면 처음부터 다시 만들지 말고 현재 통과하는 테스트와 남은 완료 조건을 찾아 가장 작은 미완료 Story부터 이어간다.

체크 상태, Homework, 코드가 서로 다르면 다음 우선순위를 사용한다.

```text
실행 가능한 테스트와 관찰 결과
→ 현재 코드
→ Day 파일 완료 체크
→ Homework 기록
```

문서만 보고 동작 완료를 추측하지 않는다. 테스트를 실행할 수 없는 환경이면 확인하지 못한 조건을 밝히고 체크 상태를 유지한다. 완료된 Day가 없다면 Day 01부터 시작한다. Day 30까지 완료됐다면 새 요구를 `plan.md`의 Architecture 판단 기준에 맞는 후속 Story로 정의한다.

## 시작 안내

코드를 바꾸기 전에 다음 내용을 짧게 제시한다.

```text
이어갈 위치: Day와 미완료 Story
오늘 코스의 의도: 끝나면 내릴 수 있어야 할 판단
지금 배울 개념: 한두 개
첫 Red: 실패시킬 가장 작은 동작 예제
Green 범위: 테스트를 통과할 최소 구현
관찰 방법: 테스트 / Preview / Simulator / 실기기 중 적합한 것
```

이 안내는 강의 목차가 아니라 현재 코드에서 바로 수행할 행동이어야 한다.

## 코드 내비게이션 주석

사용자가 다음 행동을 파일에서 찾을 수 있도록 필요한 위치에만 다음 형식을 사용한다.

```swift
// LEARNING: 이 값의 source of truth를 View가 소유하는 이유를 확인한다.
// TODO(TEST): Given/When/Then으로 실패 예제를 먼저 추가한다.
// TODO(IMPLEMENT): 위 테스트를 통과할 최소 상태 전이만 구현한다.
// VERIFY: Preview의 Empty와 Error 상태가 서로 다르게 보이는지 확인한다.
```

주석을 추가할 때 지킬 조건:

- 실제 파일과 symbol을 확인한 뒤 가장 가까운 구현 위치에 둔다.
- test navigation은 대상 test file 또는 test suite에 둔다.
- implementation navigation은 production symbol에 둔다.
- Xcode 설정 작업은 Source 주석으로 흉내 내지 않고 대화에서 정확한 Navigator 경로를 안내한다.
- 정답 코드, 긴 이론, 여러 Day 뒤의 설계를 TODO에 넣지 않는다.
- 완료된 TODO는 제거한다. 여전히 코드 의도를 설명하는 가치가 있을 때만 일반 주석으로 바꾼다.

## Day 완료 판정과 진도 갱신

해당 Day 파일의 완료 조건과 현재 Story의 인수 예제를 모두 만족하고 필요한 검증을 수행했을 때만 Day를 완료한다.

1. 집중 테스트를 실행한다.
2. 관련된 더 넓은 테스트 묶음을 실행한다.
3. Preview, Simulator, XCUITest, 실기기 중 Day가 요구하는 관찰 결과를 확인한다.
4. 미완료 `TODO(TEST)`와 `TODO(IMPLEMENT)`가 Day 필수 범위에 남아 있지 않은지 확인한다.
5. `courses/day-XX.md`의 `- [ ] Day XX 완료`를 `- [x]`로 바꾼다.
6. `courses/day-00.md`의 해당 Day 체크도 `- [x]`로 바꾼다.
7. `homework/day-XX.md`를 작성하거나 갱신한다.

일부만 끝났다면 체크하지 않는다. 대신 마지막 Green 상태, 남은 실패 또는 수동 검증, 다음 시작 지점을 세션 결과에 적는다.

## Homework 형식

`homework/`가 없으면 Day를 처음 완료할 때 만든다. 파일명은 `homework/day-XX.md`를 사용하고, 이미 있으면 기존 학습자의 메모를 보존하면서 이번 완료 내용을 갱신한다.

```markdown
# Day XX Homework — <Day 제목>

## 이 코스가 알려주려던 것

<기능이 아니라 학습자가 스스로 내릴 수 있어야 할 판단>

## 오늘 구현한 사용자 동작

- <Given/When/Then 또는 관찰 가능한 결과>

## Red → Green → Refactor

- Red: <실패 테스트와 실패 이유>
- Green: <최소 구현>
- Refactor: <책임·이름·중복이 어떻게 개선됐는지>

## 구현 내비게이션 복습

- Production: `<파일과 symbol>` — <책임>
- Test: `<파일과 test>` — <입증하는 동작>
- Feedback: <Preview/Simulator/실기기 확인 경로와 결과>

## 복습할 개념

### <한국어 용어 (English Term)>

<현재 코드에 연결한 쉬운 설명, 흔한 실수, 언제 다른 선택을 고려하는지>

## 직접 다시 실행하기

```text
<정확한 테스트 또는 빌드 명령>
```

## 스스로 확인하기

1. <결과 예측 또는 자기 말로 설명하는 질문>
2. <작은 변형 과제>

## 남은 위험과 다음 Story

- 남은 위험: <없으면 없음>
- 다음 Story: <다음 Day의 가장 작은 사용자 가치>
```

Homework는 강의 원문을 복사하지 않는다. 그날 실제로 변경한 코드와 검증 결과를 근거로 작성하고, 아직 배우지 않은 다음 Day의 정답을 미리 제공하지 않는다.
