# Day 22 — Feature 기반 모듈화 판단

- [ ] 완료

### 사용자 스토리

> 개발팀으로서 함께 변경되는 코드는 가깝게 두고 독립적으로 변경되는 기능만 모듈로 분리하기를 원한다. 그래야 구조 비용보다 실제 이점을 얻는다.

### 중점 학습

- high cohesion과 low coupling
- 패키지 경계와 Gradle 모듈 경계의 차이
- 모듈화의 빌드·소유권 이점과 복잡성 비용

### 실습

다음 후보 구조를 그리되 실제로 모두 분리하지 않는다.

```text
:app
:feature:dashboard
:feature:call-history
:feature:incall
:data:call
:core:model
:core:ui
:core:testing
```

### 검증 시나리오

```text
순환 의존성 탐지
feature 간 구현 타입 직접 참조 금지
공유 ID로 데이터 재조회
분리 전후 빌드·테스트 비용 비교
```

### 완료 조건

- 실제 독립 변경, 캡슐화, 재사용 이점이 있는 경계만 분리 후보로 선택한다.
- “모듈 수가 많으면 좋은 아키텍처”가 아닌 이유를 설명한다.
