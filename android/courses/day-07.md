# Day 07 — Fragment/View 레거시와 Characterization Test

- [ ] 완료

### 사용자 스토리

> 레거시 화면 사용자로서 내부 구조를 개선하는 동안 기존 로딩·오류·재시도 동작이 바뀌지 않기를 원한다. 그래야 안전하게 점진적으로 현대화할 수 있다.

### 중점 학습

- Activity, Fragment, View lifecycle
- XML View와 ComposeView 상호운용
- 동작을 고정한 뒤 seam을 추출하는 레거시 변경

### 구현

API, DB, TelephonyManager, Navigation, Timer, formatting이 섞인 `CallFragment` 예제를 만든다. 먼저 Characterization Test를 추가하고 ViewModel, Repository, Platform Adapter를 한 경계씩 추출한다.

### TDD 시나리오

```text
기존 로딩·오류·재시도 동작 보존
Fragment view 재생성 후 observer 중복 없음
ComposeView composition 정리
기존 View와 Compose에 동일 상태를 중복 저장하지 않음
```

### 완료 조건

- 재작성 없이 작은 단계로 구조를 개선한다.
- 추출 전후 Characterization Test가 동일하게 통과한다.

---
