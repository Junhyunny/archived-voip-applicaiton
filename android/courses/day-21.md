# Day 21 — Binder/AIDL와 Facade

- [ ] 완료

### 사용자 스토리

> 사용자로서 원격 radio 프로세스가 죽거나 Binder 호출이 실패해도 앱이 멈추지 않고 복구 가능한 상태를 보여주기를 원한다.

### 중점 학습

- Binder thread, 동기 호출, `RemoteException`, process death
- AIDL service를 앱 도메인 API 뒤에 숨기는 Facade
- Telecom에서 Telephony, IMS, RIL, Radio HAL로 이어지는 계층 읽기

### 구현

별도 `:radio` process의 `FakeRadioService`와 `RadioServiceFacade`를 만든다.

### TDD·통합 시나리오

```text
서비스 연결과 명령 전달
callback 수신
원격 process 종료
DeathRecipient 또는 연결 끊김
재연결
중복 callback
main thread 장기 blocking 방지
```

### 완료 조건

- AIDL 모델을 UI나 Domain에 그대로 노출하지 않는다.
- 일반 다운로드 앱이 IMS/RIL 구현을 소유하지 않는 경계를 설명한다.

---
