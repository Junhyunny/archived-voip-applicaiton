# Day 23 — Domain Layer와 Mapper를 만드는 기준

- [ ] 완료

### 사용자 스토리

> 개발자로서 복잡하거나 재사용되는 비즈니스 규칙만 UseCase로 분리하고 각 레이어 모델의 의미를 명확히 유지하기를 원한다.

### 중점 학습

- 여러 Repository를 조합하거나 재사용되는 복잡한 정책에 UseCase 사용
- 단순 전달 UseCase를 만들지 않기
- HTTP DTO, Room Entity, Framework Object, UI Model의 의미 경계

### 구현

좋은 후보 하나를 선택한다.

```text
ObserveActiveCallUseCase
SwitchSubscriptionUseCase
DiagnoseCallQualityUseCase
RetryFailedReportUseCase
```

### TDD 시나리오

```text
두 Repository 결과 조합
정책 변경 시 UI와 data source 영향 없음
DTO 필드 추가가 UI 모델을 깨지 않음
Framework 객체가 Domain으로 새지 않음
```

### 완료 조건

- Repository 한 줄 호출만 감싼 UseCase는 제거한다.
- 모델 분리 여부를 의미, 수명, 변경 빈도로 설명한다.
