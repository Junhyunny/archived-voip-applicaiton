# Course Day 21 — TCA Testing·Scoping과 통합 Failure Drill

[이전 Day](day-20.md) · [전체 진도](day-00.md) · [다음 Day](day-22.md)

- [ ] Day 21 완료

## 중점 학습

- TCA TestStore·child scoping, MVVM/직접 Reducer/TCA 비교와 다중 시스템 Failure Drill

## 과정 내용

> 아래 과정 내용은 `plan.md`의 해당 Day 구간을 빠짐없이 옮긴 것이다.

## Day 21 — TCA Testing·Scoping과 통합 Failure Drill

TCA 구현을 `TestStore`로 검증한다.

```text
send Action
→ State change
→ Effect
→ receive Action
→ final State
→ in-flight Effect 종료 확인
```

Parent Store를 child Feature에 scope하고, MVVM 버전·직접 Reducer 버전·TCA 버전을 다음 기준으로 비교한다.

```text
현재 코드량과 학습 비용
상태 전이와 event trace의 명확성
async cancellation
dependency override
navigation과 child composition
테스트가 놓치지 않게 강제하는 범위
팀 단위 일관성이 필요한 규모인지
```

다음 순서를 Fake event로 재생한다.

```text
수신 Push
→ CallKit 보고
→ 사용자 Answer
→ 서버 연결 중
→ Wi-Fi에서 Cellular로 변경
→ Bluetooth 연결
→ 오디오 interruption
→ 서버 연결 완료
→ 통화 활성화
→ 상대방 종료
```

그리고 순서를 일부러 바꾼다.

```text
상대방 종료가 Answer보다 먼저 도착
timeout 이후 transport 연결
통화 종료 후 route 변경
화면 종료 후 network callback
end 이벤트 두 번
```

각 버그를 발견하면 다음 순서로 수정한다.

```text
재현
→ 실패 테스트
→ 최소 수정
→ 회귀 테스트
→ UI 상태 확인
```

---
