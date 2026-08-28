# Day 28 — Legacy Architecture 리팩터링

- [ ] 완료

### 사용자 스토리

> 레거시 화면 사용자로서 God ViewModel을 분리하는 동안 현재 동작이 그대로 유지되기를 원한다. 그래야 큰 재작성 없이 위험을 낮출 수 있다.

### 중점 학습

- God ViewModel의 현재 동작을 먼저 고정
- Adapter, Repository, Policy, Reducer를 한 번에 하나씩 추출
- 리팩터링 중 회귀와 scope 변경 감지

### 대상

```text
CallViewModel
├── TelephonyManager
├── TelecomManager
├── AudioManager
├── Room
├── HTTP client
├── Timer
├── Navigation
└── Analytics
```

### 작업 순서

```text
1. Characterization Test
2. Adapter 추출
3. Repository 추출
4. Policy 추출
5. Reducer 추출
6. UI state 정리
```

### 완료 조건

- 한 번에 Clean Architecture로 재작성하지 않는다.
- 매 단계 테스트가 통과하고 diff가 한 가지 이유로만 바뀐다.
