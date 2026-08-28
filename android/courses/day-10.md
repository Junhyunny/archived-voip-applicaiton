# Day 10 — Form State와 Strategy

- [ ] 완료

### 사용자 스토리

> 사용자로서 붙여넣기와 국가 코드가 포함된 전화번호도 일관되게 포맷·검증되기를 원한다. 그래야 잘못된 번호로 통화를 시도하지 않는다.

### 중점 학습

- 전화번호 입력 상태와 비즈니스 검증 분리
- Formatter와 Validator Strategy
- focus, IME, 붙여넣기, 복원

### 구현

```kotlin
interface PhoneNumberFormatter
interface PhoneNumberValidator
```

### TDD 시나리오

```text
숫자와 공백
붙여넣기
길이 제한
국가 코드
잘못된 문자
formatter 교체
회전·process recreation 후 최소 입력 복원
```

### 완료 조건

- UI 상태와 교체 가능한 정책의 경계가 분명하다.
- 오류가 문자열이 아니라 UI에서 변환 가능한 이유로 모델링된다.
