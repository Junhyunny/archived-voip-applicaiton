# Course Day 04 — Login MVVM과 Dependency Injection

[이전 Day](day-03.md) · [전체 진도](day-00.md) · [다음 Day](day-05.md)

- [ ] Day 04 완료

## 중점 학습

- Login MVVM, Form 검증, AuthClient·Clock·Logger의 명시적 DI, 중복 입력과 취소 가능한 요청

## 과정 내용

> 아래 과정 내용은 `plan.md`의 해당 Day 구간을 빠짐없이 옮긴 것이다.

## Day 4 — Login MVVM과 Dependency Injection

학습:

```text
TextField
SecureField
Form
FocusState
Keyboard submit
입력 오류 표시
버튼 활성화 조건
@Observable LoginModel
AuthClient / Clock / UUID / Logger 주입
```

구현:

```text
이메일
비밀번호
로그인 버튼
서버 오류 배너
Loading indicator
```

TDD:

```text
빈 이메일
잘못된 이메일 형식
빈 비밀번호
로그인 성공
잘못된 인증 정보
서버 오류
두 번 연속 버튼 선택
로그인 중 화면 종료
```

테스트에서는 `FakeAuthClient`, 제어 가능한 `Clock`, `SpyLogger`를 사용한다. Production 구현을 전역 Singleton에서 찾지 않고 initializer로 명시적으로 받는다.

`FocusState`로 유효하지 않은 입력 필드에 포커스를 이동하는 연습도 한다.

---
