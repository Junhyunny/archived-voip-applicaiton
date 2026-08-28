# Day 09 — UI Composition, Design System과 접근성

- [ ] 완료

### 사용자 스토리

> 다양한 접근성 요구를 가진 사용자로서 통화 제어 컴포넌트를 큰 글자와 TalkBack에서도 명확히 사용하기를 원한다.

### 중점 학습

- 상속보다 작은 UI 조합과 Slot API
- Material 3 token과 stable UI model
- semantics, 큰 글자, touch target, 색상 외 정보

### 구현

```text
TelecomTheme
AppButton
CallControlButton
NetworkStatusCard
SubscriptionChip
ErrorBanner
LoadingContent
```

### TDD·수동 시나리오

```text
enabled/disabled/loading
오류 semantics
TalkBack 읽기 순서
200% 글자 크기
compact/expanded Preview
다국어 문자열 길이
```

### 완료 조건

- UI 컴포넌트가 ViewModel이나 Repository를 직접 참조하지 않는다.
- 접근성 검사를 완료 조건에 포함한다.
