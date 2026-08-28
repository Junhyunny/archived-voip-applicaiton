# Day 20 — Background 작업과 Coordinator

- [ ] 완료

### 사용자 스토리

> 사용자로서 통화 진단 저장과 리포트 업로드가 화면 종료나 앱 재시작 뒤에도 중복 없이 이어지기를 원한다.

### 중점 학습

- ViewModel scope, app scope, Foreground Service, WorkManager의 수명
- 진행 중 통화 진단과 완료 후 업로드의 소유자 분리
- WorkManager와 DB 중 작업 상태의 source of truth 결정

### 구현

```text
CallSessionController
→ DiagnosisRepository
→ Room
→ ReportUploadWorker
```

### TDD 시나리오

```text
화면 이탈 중 진단 지속
통화 종료 후 진단 저장
오프라인이면 업로드 대기
네트워크 복구 후 재시도
동일 리포트 중복 enqueue 방지
앱 재시작 후 작업 상태 관찰
```

### 완료 조건

- ViewModel을 지속 작업의 SSOT로 사용하지 않는다.
- Foreground Service와 WorkManager 선택 기준을 설명한다.
