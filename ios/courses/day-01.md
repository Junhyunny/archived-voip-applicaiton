# Course Day 01 — 프로젝트와 테스트 기반

[전체 진도](day-00.md) · [다음 Day](day-02.md)

- [ ] Day 01 완료

## 중점 학습

- Xcode 프로젝트·테스트 기반, Feature-first 구조, View local state와 필요할 때만 확장하는 Composition Root

## 과정 내용

> 아래 과정 내용은 `plan.md`의 해당 Day 구간을 빠짐없이 옮긴 것이다.

# Week 1 — Local State에서 MVVM·DI·Router까지

## Day 1 — 프로젝트와 테스트 기반

학습:

```text
Swift Package / Xcode target
Swift Testing
XCTest
Feature-first 구조
SwiftUI local state의 범위
Composition Root 개념
```

구현:

```text
앱 기본 구조
TabView
Home / Call History / Diagnostics / Settings 빈 화면
Test target
CI에서 unit test 실행
```

완료 조건:

```text
앱 실행 가능
현재 필요한 dependency만 App 시작 지점에서 구성
Feature 테스트에서 실제 네트워크를 사용하지 않음
```

첫날부터 빈 Protocol과 계층을 만들지는 않는다. 테스트가 통제해야 하는 첫 외부 경계가 생길 때 Composition Root에서 dependency를 조립한다.

---
