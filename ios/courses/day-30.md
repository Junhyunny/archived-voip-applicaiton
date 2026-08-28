# Course Day 30 — 장애 수정과 Architecture Decision Record

[이전 Day](day-29.md) · [전체 진도](day-00.md)

- [ ] Day 30 완료

## 중점 학습

- 장애 재현·회귀 검증 뒤 Architecture 선택 근거와 다음 전환 신호를 ADR로 작성

## 과정 내용

> 아래 과정 내용은 `plan.md`의 해당 Day 구간을 빠짐없이 옮긴 것이다.

## Day 30 — 장애 수정과 Architecture Decision Record

다음 중 하나를 일부러 발생시킨다.

```text
화면에 다시 들어오면 API가 두 번 호출됨
검색 결과가 이전 키워드 결과로 덮어씌워짐
통화 종료 후 오디오가 계속 활성화됨
네트워크 전환 후 화면이 Connecting에 멈춤
장애 신고 버튼을 두 번 눌러 두 번 제출됨
통화 상세 화면에서 메모리 누수
```

수정 순서:

```text
재현 조건 고정
로그 확인
실패 테스트 작성
원인 가설
최소 수정
회귀 테스트
Instruments 또는 실기기 재검증
```

마지막으로 가상의 PR “새로운 통화 품질 Feature의 architecture 결정”에 대한 ADR을 작성한다.

```text
왜 View local state / MVVM / Reducer / TCA 중 이것을 선택했는가?
왜 나머지는 지금 선택하지 않았는가?
어떤 state가 local, feature, shared인가?
Side effect와 error mapping은 어디에 있는가?
Navigation은 누가 소유하는가?
Task는 누가 cancel하는가?
Persistence와 cache 정책은 누가 담당하는가?
System API는 어디에서 감싸는가?
테스트 boundary와 production diagnostics는 어디인가?
요구가 커질 때 다음 architecture 전환 신호는 무엇인가?
```

정답 이름보다, 현재 요구와 위험에 근거해 선택하고 다음 변경 비용을 설명할 수 있으면 한 달의 Architecture 목표를 달성한 것이다.

---
