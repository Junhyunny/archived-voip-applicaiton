# Day 17 — Subscription과 Telephony

- [ ] 완료

### 사용자 스토리

> 멀티 SIM 사용자로서 선택한 Subscription이 바뀌거나 SIM이 제거돼도 이전 SIM의 늦은 callback이 현재 상태를 덮어쓰지 않기를 원한다.

### 중점 학습

- SIM slot과 subscriptionId 구분
- 선택 Subscription 변경 시 TelephonyCallback 교체
- 권한·SIM 제거·오래된 callback 처리

### 구현

```text
SubscriptionManager / TelephonyManager / TelephonyCallback
→ TelephonyAdapter
→ TelephonyRepository
→ StateFlow<TelephonyState>
```

### TDD 시나리오

```text
SIM 1 선택
SIM 2 전환
SIM 제거·재활성화
callback 재등록
SIM 1의 늦은 callback 무시
권한 제거
중복 signal event
```

### 완료 조건

- 활성 subscriptionId를 하드코딩하지 않는다.
- 교체 전후 callback owner와 generation/token 정책을 설명한다.
