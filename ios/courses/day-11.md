# Course Day 11 — Explicit State와 다단계 장애 신고 Form

[이전 Day](day-10.md) · [전체 진도](day-00.md) · [다음 Day](day-12.md)

- [ ] Day 11 완료

## 중점 학습

- 명시적 State로 모델링한 다단계 Form, 단계별 검증·draft 복원·중복 제출과 실패 복구 UX

## 과정 내용

> 아래 과정 내용은 `plan.md`의 해당 Day 구간을 빠짐없이 옮긴 것이다.

## Day 11 — Explicit State와 다단계 장애 신고 Form

구현:

```text
1단계: 문제 유형
2단계: 발생 시점과 위치
3단계: 증상 설명
4단계: 진단 정보 첨부 동의
5단계: 제출 확인
```

여러 `isStep...`, `isSubmitting`, `hasError` Boolean 대신 Form의 유효한 단계와 제출 상태를 명시적인 enum state로 모델링한다. 여기서 State pattern을 통화 기능보다 작은 문제로 먼저 연습한다.

TDD:

```text
필수 입력 검증
이전 단계 이동 시 입력 보존
앱 종료 후 draft 복원
중복 제출 방지
제출 실패 후 입력 보존
제출 성공 후 draft 삭제
```

UX 연습:

```text
오류를 Alert 하나로만 표시하지 않기
문제가 있는 입력 가까이에 설명 표시
오류 발생 시 해당 필드로 포커스
작성 중 나가기 전에 확인
제출 중 버튼 비활성화
```

---
