# Course Day 28 — Environment Factory와 실기기 테스트

[이전 Day](day-27.md) · [전체 진도](day-00.md) · [다음 Day](day-29.md)

- [ ] Day 28 완료

## 중점 학습

- 환경별 Dependency Factory와 기기·네트워크·오디오·권한·생명주기 실기기 테스트

## 과정 내용

> 아래 과정 내용은 `plan.md`의 해당 Day 구간을 빠짐없이 옮긴 것이다.

## Day 28 — Environment Factory와 실기기 테스트

Composition Root에서 환경별 dependency를 Factory로 조립한다.

```text
Development / Staging / Production
├── API endpoint
├── Logger / Analytics
├── Feature Flag
├── Push / Call server
└── Persistence policy
```

환경 분기는 Feature 내부에 흩뿌리지 않는다. Secret을 소스에 넣지 않고, UI 테스트는 별도의 stub dependency 구성을 사용한다.

| 영역 | 시나리오 |
|---|---|
| 화면 | 작은 iPhone, 큰 iPhone |
| Appearance | Light, Dark |
| 글자 | 기본, 큰 Dynamic Type |
| 네트워크 | Wi-Fi, Cellular, Offline, 전환 |
| 오디오 | Receiver, Speaker, Wired, Bluetooth |
| 권한 | 허용, 거부, 이전에 거부 |
| Lifecycle | Foreground, Background, 잠금 |
| 통화 | 수신, 발신, 취소, timeout, remote end |
| 언어 | 한국어, 영어 |
| 장애 | 느린 응답, 500, 중복 이벤트 |

---
