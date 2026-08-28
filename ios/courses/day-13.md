# Course Day 13 — UIKit Adapter와 Facade

[이전 Day](day-12.md) · [전체 진도](day-00.md) · [다음 Day](day-14.md)

- [ ] Day 13 완료

## 중점 학습

- UIKit Adapter와 Facade의 역할, Representable/Coordinator를 통한 callback→Feature Action 변환

## 과정 내용

> 아래 과정 내용은 `plan.md`의 해당 Day 구간을 빠짐없이 옮긴 것이다.

## Day 13 — UIKit Adapter와 Facade

학습:

```text
UIView
UIViewController
viewDidLoad
viewWillAppear
UITableView / UICollectionView 개념
Auto Layout
Delegate
Target-action
Coordinator
Adapter / Facade 차이
```

실습:

```text
UIKit으로 만든 간단한 품질 차트 View
SwiftUI에서 UIViewRepresentable로 사용
UIKit delegate 이벤트를 Coordinator로 전달
화면 제거 시 observer와 delegate 정리
```

`UIViewRepresentable`과 `UIViewControllerRepresentable`은 UIKit 객체를 SwiftUI에 넣는 공식 경계다. UIKit에서 발생한 delegate나 target-action 이벤트는 Coordinator를 통해 SwiftUI 쪽으로 전달할 수 있다.

Adapter는 UIKit callback을 Feature action으로 번역하고, Facade는 여러 UIKit 객체의 복잡한 사용 순서를 하나의 앱 언어로 감춘다는 차이를 작은 예제로 확인한다.

TDD:

```text
새 데이터 입력 시 adapter 업데이트
동일 데이터면 불필요한 업데이트 방지
UIKit callback이 Feature action으로 변환
화면 제거 후 callback 무시
```

---
