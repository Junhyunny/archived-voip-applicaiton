# android-study

안드로이드 앱을 만들며 XP와 TDD를 연습하는 학습 저장소입니다. 화면 회전, process death, 오프라인, 멀티 SIM, Telecom callback과 race condition을 견디는 프로덕션 상태 관리 로드맵은 [plan.md](plan.md)를 참고합니다.

30일 과정은 [courses/day-00.md](courses/day-00.md)의 완료 체크리스트에서 시작합니다. 전체 원칙은 `plan.md`를 단일 원본으로 삼고, 각 Day 문서에는 사용자 스토리, 중점 학습, TDD·복구·실패 시나리오와 완료 조건을 둡니다.

## 페어 프로그래밍 스킬

저장소 로컬 스킬 `android-xp-pair`가 초보자 눈높이의 코드 내비게이션, 작은 사용자 스토리, Red-Green-Refactor, Android 개념 설명과 회고를 안내합니다.

예시 호출:

```text
개발 시작하자.
```

그러면 완료 표시와 `homework/day-XX.md`를 확인해 마지막 건강한 체크포인트부터 재개합니다. 구현에는 `STUDY-NAV(Day XX)` 코드 내비게이션 주석을 남기고, Day가 끝나면 배운 개념, TDD 증거, 미검증 항목과 다음 시작점을 `homework/`에 정리합니다.

직접 코드를 작성하고 싶다면 “내가 드라이버를 할게”라고 덧붙이고, 완성된 예시를 먼저 보고 싶다면 “시범 모드로 진행해 줘”라고 요청합니다. 명시적으로 호출하려면 `$android-xp-pair 개발 시작하자`라고 입력할 수 있습니다.
