# Day 16 — Connectivity Adapter와 Observer

- [ ] 완료

### 사용자 스토리

> 사용자로서 Wi‑Fi·셀룰러·오프라인 전환이 중복 callback에도 정확히 한 현재 연결 상태로 표시되기를 원한다.

### 중점 학습

- `ConnectivityManager` callback을 앱 모델의 Flow로 변환
- callbackFlow의 등록, `awaitClose`, 중복 제거
- 연결됨과 실제 인터넷 사용 가능 여부 구분

### 구현

```text
ConnectivityManager
→ AndroidConnectivityMonitor
→ Flow<Connectivity>
```

### TDD 시나리오

```text
Wi-Fi, Cellular, Offline
Wi-Fi → Cellular
중복 callback
등록 직후 초기 상태
수집 취소 후 unregister
늦은 callback 무시
```

### 완료 조건

- 등록과 해제를 같은 Adapter가 소유한다.
- 화면 재생성으로 callback이 중복 등록되지 않는다.
