# Course Day 08 — URLSession Adapter와 Error Mapping

[이전 Day](day-07.md) · [전체 진도](day-00.md) · [다음 Day](day-09.md)

- [ ] Day 08 완료

## 중점 학습

- URLSession을 HTTPClient로 바꾸는 Adapter, DTO/Domain 분리, 계층별 Error mapping과 Fake

## 과정 내용

> 아래 과정 내용은 `plan.md`의 해당 Day 구간을 빠짐없이 옮긴 것이다.

# Week 2 — Adapter·Repository·Strategy와 일반 Feature

## Day 8 — URLSession Adapter와 Error Mapping

구현:

```text
CallHistoryClient
DTO
Domain Model
Error mapping
Fake client
Adapter 패턴
```

TDD:

```text
200 정상 응답
빈 목록
401
429
500
잘못된 JSON
timeout
cancellation
```

화면에서 `URLError`나 HTTP status를 직접 분기하지 않는다.

```swift
enum CallHistoryError {
    case unauthorized
    case temporarilyUnavailable
    case offline
    case invalidResponse
}
```

사용자 메시지는 기술 오류와 분리한다.

```text
기술 오류:
URLError.notConnectedToInternet

사용자 메시지:
네트워크에 연결할 수 없습니다.
연결 상태를 확인하고 다시 시도해 주세요.
```

`URLSessionHTTPClient`는 Apple API와 HTTP 표현을 앱의 `HTTPClient` 경계로 바꾸는 Adapter다. Feature는 `URLRequest`, `HTTPURLResponse`, `URLError`를 직접 알지 않는다.

---
