# Course Day 22 — Shared State와 Localization

[이전 Day](day-21.md) · [전체 진도](day-00.md) · [다음 Day](day-23.md)

- [ ] Day 22 완료

## 중점 학습

- local/feature/shared/persistent/server state 소유권 구분과 String Catalog 기반 Localization

## 과정 내용

> 아래 과정 내용은 `plan.md`의 해당 Day 구간을 빠짐없이 옮긴 것이다.

# Week 4 — Production-ready Architecture와 운영 품질

## Day 22 — Shared State와 Localization

먼저 앱의 데이터를 다음 다섯 범주로 분류한다.

| 데이터 | 상태 종류와 소유자 |
|---|---|
| TextField, focus, sheet | View local state |
| 통화 기록 검색 결과 | CallHistory feature state |
| 로그인 사용자, 실제 진행 중 통화 | Session / shared state |
| 사용자 설정, draft | Repository / persistent state |
| 서버 요금제와 통화 기록 원본 | Server state + Repository cache |

전역 `AppState`에는 session, 현재 진행 중인 call, app navigation처럼 여러 Feature가 같은 생명주기로 공유해야 하는 값만 둔다. 검색어, loading, validation error, 선택 row를 올리지 않는다.

지원 언어는 우선 한국어와 영어로 한다.

검증:

```text
긴 영어 문장
매우 짧은 한국어 문장
날짜
시간
백분율
전화번호
파일 크기
복수형
```

String Catalog를 이용하면 문자열 추출, 번역, 복수형, 기기별 표현을 한곳에서 관리할 수 있다.

피해야 할 코드:

```swift
Text("총 " + String(count) + "개의 기록")
```

선호:

```swift
Text("\(count) call records")
```

실제 표현과 복수형은 String Catalog에서 관리한다.

---
