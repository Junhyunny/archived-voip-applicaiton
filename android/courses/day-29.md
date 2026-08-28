# Day 29 — Production Capstone

- [ ] 완료

### 사용자 스토리

> 사용자로서 대시보드부터 통화 종료와 리포트 업로드까지 전체 흐름이 오프라인·회전·멀티 SIM·오디오 변경에도 이어지기를 원한다.

### 중점 학습

- 모든 상태의 수명과 source of truth를 하나의 흐름에서 연결
- 자동 테스트와 기기 검증의 경계
- 접근성, adaptive UI, 오프라인, 복원까지 제품 수준으로 마감

### 최종 흐름

```text
대시보드
→ 통화 내역
→ 수신 화면
→ 통화 중 화면
→ Bluetooth 전환
→ 종료
→ 진단 저장
→ 리포트 업로드
```

### 필수 상태 소유권

```text
Button state → Compose
Screen state → ViewModel
Navigation state → Navigation
Call state → CallSessionController
App data → Repository + Room
Preferences → DataStore
Background work → WorkManager
Process restoration key → SavedStateHandle
```

### 인수 시나리오

```text
오프라인에서도 cached history 표시
통화 화면 제거 후 call session 지속
Bluetooth 해제 fallback
회전과 process recreation
멀티 SIM 전환과 stale callback
중복 업로드 방지
큰 글자와 expanded layout
```

### 완료 조건

- 핵심 흐름의 JVM, UI, 통합, 기기 테스트 증거를 모은다.
- 각 상태 owner와 복구 전략을 아키텍처 그림으로 설명한다.
