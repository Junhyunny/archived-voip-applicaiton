# Course Day 07 — 첫 번째 재구현과 책임 리팩터링

[이전 Day](day-06.md) · [전체 진도](day-00.md) · [다음 Day](day-08.md)

- [ ] Day 07 완료

## 중점 학습

- Login/Home/Router 재구현 뒤 View·Feature·Composition Root 책임과 아직 필요 없는 추상화 구분

## 과정 내용

> 아래 과정 내용은 `plan.md`의 해당 Day 구간을 빠짐없이 옮긴 것이다.

## Day 7 — 첫 번째 재구현과 책임 리팩터링

코드를 보지 않고 다시 만든다.

```text
Login
Home dashboard
AppRoute
Loadable 상태
```

이번에는 일부 요구를 변경한다.

```text
로그인에 OTP 단계 추가
Home에 offline 상태 추가
통화 상세 딥링크 추가
```

리팩터링할 때 다음 경계를 자기 말로 설명한다.

```text
View가 소유할 local state
Login/Home Model이 소유할 feature state
Composition Root가 조립할 dependency
Router가 소유할 navigation state
아직 만들 필요가 없는 Repository와 UseCase
```

TDD 반복의 목적은 완성 코드를 외우는 것이 아니라, 요구사항을 상태와 테스트로 변환하는 습관을 만드는 것이다.

---
