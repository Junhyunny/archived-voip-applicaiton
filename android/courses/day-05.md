# Day 05 — Compose State Holder와 DialPad

- [ ] 완료

### 사용자 스토리

> 사용자로서 DialPad 입력과 커서가 회전 후에도 자연스럽게 유지되기를 원한다. 그래야 번호를 다시 입력하지 않아도 된다.

### 중점 학습

- `remember`, `rememberSaveable`, plain state holder, ViewModel의 수명
- state hoisting과 가장 가까운 소유자
- 입력, focus, IME, cursor를 UI 로직으로 다루기

### 구현

`DialPadState`에 전화번호, cursor, 키패드 표시 여부, 입력 포맷을 둔다. 전화번호 검증이 비즈니스 규칙으로 커지면 Strategy로 분리할 seam만 남긴다.

### TDD·UI 시나리오

```text
숫자 입력과 삭제
붙여넣기
잘못된 문자 무시
cursor 이동
회전 후 입력 복원
Composable 제거 후 불필요한 상태 정리
```

### 완료 조건

- ViewModel로 올리지 않은 이유를 상태 수명으로 설명한다.
- UI 테스트가 렌더링과 callback을 검증한다.
