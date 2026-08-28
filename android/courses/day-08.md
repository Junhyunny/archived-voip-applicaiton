# Day 08 — Navigation State와 Back Stack

- [ ] 완료

### 사용자 스토리

> 사용자로서 목록·상세 탐색이 화면 크기 변경과 프로세스 복원 뒤에도 같은 맥락을 유지하기를 원한다. 그래야 compact와 expanded 환경에서 길을 잃지 않는다.

### 중점 학습

- Navigation 3에서 앱이 소유하는 back stack
- type-safe key, deep link, process restoration
- compact·expanded layout에서 동일한 탐색 상태 사용

### 구현

```text
Home → CallHistory → CallDetail(id) → Diagnosis(id)
```

### TDD 시나리오

```text
push와 pop
잘못된 id
deep link 직접 진입
process recreation 후 back stack 복원
expanded layout에서 목록과 상세 동시 표시
뒤로 가기 후 예상 상태
```

### 완료 조건

- 하위 Composable에 navigation controller를 퍼뜨리지 않고 callback을 전달한다.
- Navigation state와 화면 business state의 소유자를 구분한다.
