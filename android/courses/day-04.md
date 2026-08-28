# Day 04 — MVI의 도구화와 CallReducer

- [ ] 완료

### 사용자 스토리

> 통화 사용자로서 중복·역순·지연 이벤트가 발생해도 통화 단계가 결정적으로 전이되기를 원한다. 그래야 race condition이 UI를 깨뜨리지 않는다.

### 중점 학습

- MVI를 앱 전체 규칙이 아니라 복잡한 상태 전이 도구로 사용하기
- 순수 Reducer와 외부 Effect 경계
- 중복·역순·지연 이벤트의 결정적 처리

### 구현

```text
현재 CallState + CallEvent → CallReducer → 새 CallState
```

### TDD 시나리오

정상 흐름뿐 아니라 최소 20개의 표 기반 테스트를 작성한다.

```text
timeout
duplicate
out-of-order
late callback
disconnect race
hold/resume race
Disconnected 이후 모든 활성 이벤트 무시
```

### 완료 조건

- 같은 State와 Event는 항상 같은 결과를 만든다.
- Reducer에 Android, coroutine, DB 의존성이 없다.
- 단순 설정 화면에 Reducer를 쓰지 않을 이유를 설명한다.
