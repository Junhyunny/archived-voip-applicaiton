# Day 00 — 패스투프로덕션 과정 안내와 진도표

이 문서는 프로덕션 상태 관리를 중심으로 개편한 30일 과정의 진입점입니다. 각 Day를 마치면 `[ ]`를 `[x]`로 바꾸고, 해당 문서의 테스트·복원·실패 시나리오와 완료 조건을 근거로 남깁니다.

## 과정 완료 현황

| 완료 | 과정 | 주제 | 가장 중요한 학습 초점 |
|---|---|---|---|
| [ ] | [Day 01](day-01.md) | Layered Architecture와 테스트 기준점 | UI, Data, 선택적 Domain 레이어의 책임과 의존 방향 |
| [ ] | [Day 02](day-02.md) | MVVM + UDF 대시보드 | ViewModel을 UI controller가 아니라 screen state producer로 이해하기 |
| [ ] | [Day 03](day-03.md) | State Pattern과 상태 불변식 | 상호 배타적인 상태와 동시에 존재 가능한 상태의 차이 |
| [ ] | [Day 04](day-04.md) | MVI의 도구화와 CallReducer | MVI를 앱 전체 규칙이 아니라 복잡한 상태 전이 도구로 사용하기 |
| [ ] | [Day 05](day-05.md) | Compose State Holder와 DialPad | `remember`, `rememberSaveable`, plain state holder, ViewModel의 수명 |
| [ ] | [Day 06](day-06.md) | Process Death와 State Ownership | recomposition, configuration change, system process death의 차이 |
| [ ] | [Day 07](day-07.md) | Fragment/View 레거시와 Characterization Test | Activity, Fragment, View lifecycle |
| [ ] | [Day 08](day-08.md) | Navigation State와 Back Stack | Navigation 3에서 앱이 소유하는 back stack |
| [ ] | [Day 09](day-09.md) | UI Composition, Design System과 접근성 | 상속보다 작은 UI 조합과 Slot API |
| [ ] | [Day 10](day-10.md) | Form State와 Strategy | 전화번호 입력 상태와 비즈니스 검증 분리 |
| [ ] | [Day 11](day-11.md) | 목록, Paging과 Repository | `CallHistoryRepository`와 데이터 소스 추상화 |
| [ ] | [Day 12](day-12.md) | Retry Strategy와 Decorator | 오류 종류와 retry 정책 분리 |
| [ ] | [Day 13](day-13.md) | Offline-first와 Room SSOT | 로컬 데이터 소스를 canonical source of truth로 사용하기 |
| [ ] | [Day 14](day-14.md) | 수동 DI에서 Hilt로 | constructor injection이 테스트 가능성을 만드는 이유 |
| [ ] | [Day 15](day-15.md) | Permission State Machine | Manifest permission, runtime permission, System Role 구분 |
| [ ] | [Day 16](day-16.md) | Connectivity Adapter와 Observer | `ConnectivityManager` callback을 앱 모델의 Flow로 변환 |
| [ ] | [Day 17](day-17.md) | Subscription과 Telephony | SIM slot과 subscriptionId 구분 |
| [ ] | [Day 18](day-18.md) | Telecom State Machine과 CallSessionController | Telecom, InCallService, ConnectionService의 책임 차이 |
| [ ] | [Day 19](day-19.md) | Audio Route Strategy | Bluetooth, Speaker, Wired, Earpiece endpoint 모델 |
| [ ] | [Day 20](day-20.md) | Background 작업과 Coordinator | ViewModel scope, app scope, Foreground Service, WorkManager의 수명 |
| [ ] | [Day 21](day-21.md) | Binder/AIDL와 Facade | Binder thread, 동기 호출, `RemoteException`, process death |
| [ ] | [Day 22](day-22.md) | Feature 기반 모듈화 판단 | high cohesion과 low coupling |
| [ ] | [Day 23](day-23.md) | Domain Layer와 Mapper를 만드는 기준 | 여러 Repository를 조합하거나 재사용되는 복잡한 정책에 UseCase 사용 |
| [ ] | [Day 24](day-24.md) | Concurrency와 Race Condition | duplicate, out-of-order, late response, cancellation |
| [ ] | [Day 25](day-25.md) | Process Death Chaos Test | 상태별 복원 요구사항을 제품 관점에서 결정 |
| [ ] | [Day 26](day-26.md) | Compose Performance와 State | 상태 경계와 recomposition 범위 |
| [ ] | [Day 27](day-27.md) | Observability와 Privacy-safe Decorator | Logging, Metrics, Analytics, Tracing을 핵심 로직과 분리 |
| [ ] | [Day 28](day-28.md) | Legacy Architecture 리팩터링 | God ViewModel의 현재 동작을 먼저 고정 |
| [ ] | [Day 29](day-29.md) | Production Capstone | 모든 상태의 수명과 source of truth를 하나의 흐름에서 연결 |
| [ ] | [Day 30](day-30.md) | 실제 장애 대응 모의 PR | 로그와 상태 timeline으로 race condition을 재현하기 |

## 주차별 목표

- **Week 1 — UI Architecture와 State Management:** 상태 수명과 소유권을 기준으로 Compose, ViewModel, Reducer, process death를 다룹니다.
- **Week 2 — 실제 사용자 앱 패턴:** Navigation, 디자인 시스템, 입력, Paging, Retry, offline-first, DI를 제품 흐름으로 연결합니다.
- **Week 3 — Telecom과 플랫폼 패턴:** 권한, Connectivity, 멀티 SIM, Telecom, Audio, background, Binder callback을 Adapter 뒤에 둡니다.
- **Week 4 — 프로덕션 아키텍처와 통합:** 모듈 경계, race, 복원, 성능, 관측 가능성, 레거시 변경과 장애 대응을 검증합니다.

## 완료 표시 기준

- 인수 조건을 자동 테스트나 기록된 수동 검사로 증명했습니다.
- 정상 흐름뿐 아니라 해당 Day의 중복·역순·취소·복원 실패 조건을 확인했습니다.
- 상태의 owner, source of truth, lifetime과 process death 후 복구 경로를 설명할 수 있습니다.
- 집중 테스트와 위험에 비례하는 넓은 빌드·테스트가 통과합니다.
- 의도적으로 남긴 제약과 다음 작은 스토리를 학습 노트에 기록했습니다.

## 계획 전체의 공통 원칙과 참고 자료

목표, 기준 아키텍처, 상태 소유권 표, 하루 운영 방식, 주차별 품질 게이트, 실패 행렬과 공식 자료는 [`plan.md`](../plan.md)를 단일 원본으로 사용합니다. 이 문서는 진도와 완료 증거만 관리해 두 문서가 서로 어긋나지 않게 합니다.
