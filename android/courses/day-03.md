# Day 03 — State Pattern과 상태 불변식

- [ ] 완료

### 사용자 스토리

> 사용자로서 화면에 서로 모순되는 로딩·오류·콘텐츠 표시가 나타나지 않기를 원한다. 그래야 앱 상태를 신뢰할 수 있다.

### 중점 학습

- 상호 배타적인 상태와 동시에 존재 가능한 상태의 차이
- Boolean 조합이 만드는 불가능한 상태
- 타입으로 invariant 보호하기

### 구현

먼저 `isLoading`, `hasError`, `hasContent` Boolean 모델로 모순 상태를 재현한 뒤 `sealed interface LoadState`로 바꾼다. 이후 목록 표시 + refresh + offline warning처럼 함께 존재하는 상태는 data class 필드로 분리한다.

### TDD 시나리오

```text
Loading과 Content가 동시에 표현되지 않음
Failed는 오류 이유를 반드시 가짐
Content는 empty 목록도 명시적으로 표현함
기존 목록 + refreshing + warning은 함께 표현됨
```

### 완료 조건

- 상태 타입만 읽어도 가능한 상태 조합을 설명할 수 있다.
- sealed state와 data class를 선택한 근거를 말할 수 있다.
