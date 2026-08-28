# Course Day 23 — Error Architecture와 접근성 실기기 점검

[이전 Day](day-22.md) · [전체 진도](day-00.md) · [다음 Day](day-24.md)

- [ ] Day 23 완료

## 중점 학습

- Infrastructure→Domain→Presentation Error architecture와 VoiceOver·Dynamic Type 실기기 검증

## 과정 내용

> 아래 과정 내용은 `plan.md`의 해당 Day 구간을 빠짐없이 옮긴 것이다.

## Day 23 — Error Architecture와 접근성 실기기 점검

에러를 한 종류의 문자열로 다루지 않고 경계마다 의미를 변환한다.

```text
Infrastructure Error
URLError / HTTP 500 / DecodingError
        ↓ Adapter / Repository mapping
Domain Error
unauthorized / temporarilyUnavailable / invalidCallState
        ↓ Presentation mapping
User-facing Error
행동 가능한 제목 / 설명 / 복구 동작
```

View 곳곳에서 `error.localizedDescription`을 바로 표시하지 않는다. 같은 Domain error라도 현재 화면과 사용자가 취할 수 있는 행동에 따라 presentation이 달라질 수 있다.

VoiceOver를 켜고 다음 전체 흐름을 직접 사용한다.

```text
로그인
홈 탐색
통화 기록 검색
품질 차트 확인
장애 신고
통화 응답과 종료
```

확인할 것:

```text
읽기 순서가 자연스러운가?
아이콘만 있는 버튼에 label이 있는가?
품질을 색상만으로 구분하지 않는가?
차트가 요약 설명을 제공하는가?
오류가 발생했을 때 VoiceOver가 알 수 있는가?
큰 글씨에서 버튼이나 텍스트가 잘리지 않는가?
```

---
