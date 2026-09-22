# CocoaPods 도입 시 겪은 문제와 해결

> SPM만 쓰던 iOS 프로젝트에 CocoaPods로 WebRTC-SDK를 추가하면서 빌드가 깨졌다.
> 원인이 두 가지가 겹쳐 있었고, 진단 중 원인이 아닌 증상도 하나 나왔다.
> 관련 커밋: `9ca8035`

## 요약

| # | 증상 | 원인 | 해결 |
| --- | --- | --- | --- |
| 1 | `ld: framework 'WebRTC' not found` | `-project`로 빌드 (워크스페이스 아님) | Makefile을 `-workspace`로 |
| 2 | `Sandbox: rsync(...) deny(1)` | `ENABLE_USER_SCRIPT_SANDBOXING = YES` | `NO`로 변경 |
| 3 | UI 테스트 8건 앱 실행 실패 | **CocoaPods 무관** — 시뮬레이터 종료 상태 | 시뮬레이터 부팅 후 재실행 |

1번을 고치면 2번이 드러나고, 2번을 고치면 3번이 나타나는 식이라 한 번에 보이지 않았다.

## 배경

이 프로젝트는 이미 SPM으로 FlyingFox(테스트용 웹소켓 서버)를 쓰고 있었다.
여기에 CocoaPods로 WebRTC-SDK를 추가했다.

```ruby
# Podfile
source 'https://github.com/webrtc-sdk/Specs.git'
source 'https://cdn.cocoapods.org/'

target 'voip-ios' do
  use_frameworks!
  pod 'WebRTC-SDK', '= 150.7871.01'

  target 'voip-iosTests' do
    inherit! :search_paths
  end
  target 'voip-iosUITests' do
  end
end
```

`pod install` 자체는 성공했고 `Pods/`, `Podfile.lock`, `voip-ios.xcworkspace`가 생성됐다.
그런데 `make test`가 실패했다.

---

## 문제 1 — `framework 'WebRTC' not found`

### 증상

```
ld: warning: search path '.../XCFrameworkIntermediates/WebRTC-SDK' not found
ld: framework 'WebRTC' not found
clang: error: linker command failed with exit code 1
```

### 진단

먼저 링커에 넘어간 플래그를 확인했다. 결정적인 단서가 여기 있었다.

```
-F /Users/.../voip-ios/Pods/WebRTC-SDK
-F /Users/.../Build/Products/Debug-iphonesimulator/XCFrameworkIntermediates/WebRTC-SDK
-framework WebRTC
-framework Pods_voip_ios
```

**`-framework WebRTC`가 이미 들어가 있다.** 즉 "WebRTC를 링크하라"는 지시는 제대로 전달됐다.
`pod install`이 앱 타깃의 `baseConfigurationReference`를 `Pods-voip-ios.debug.xcconfig`로
연결해뒀기 때문이다.

문제는 **링크할 프레임워크가 준비되지 않았다**는 것이다. 경고가 그걸 말한다 —
`XCFrameworkIntermediates/WebRTC-SDK` 디렉터리가 없다.

빌드 로그의 타깃 표기도 단서였다.

```
Ld ... (in target 'voip-ios' from project 'voip-ios')
```

`from project 'voip-ios'` — 워크스페이스가 아니라 프로젝트 단독 빌드다.

### 원인

`pod install`은 **`Pods.xcodeproj`라는 별도 프로젝트**를 만들고,
`voip-ios.xcworkspace`가 앱 프로젝트와 Pods 프로젝트를 묶는다.

```
voip-ios.xcworkspace
├── voip-ios.xcodeproj     ← 앱
└── Pods/Pods.xcodeproj    ← 의존성 (pod install이 생성)
```

`-project voip-ios.xcodeproj`로 빌드하면 **Pods 프로젝트가 빌드에 참여하지 않는다.**
XCFramework를 풀어 `XCFrameworkIntermediates/`에 배치하는 `[CP] Copy XCFrameworks`
스크립트 페이즈가 Pods 타깃에 있기 때문에, 그 산출물이 만들어지지 않는다.

정리하면 이런 어긋남이다.

| 항목 | 출처 | 프로젝트 단독 빌드 시 |
| --- | --- | --- |
| `-framework WebRTC` 플래그 | 앱 타깃의 xcconfig | ✅ 적용됨 |
| `WebRTC.framework` 실체 | Pods 타깃의 스크립트 페이즈 | ❌ 생성 안 됨 |

앱 프로젝트 파일만 보면 정상이라 원인을 찾기 어렵다.

### 해결

```makefile
WORKSPACE := voip-ios.xcworkspace
SCHEME := voip-ios
DESTINATION := platform=iOS Simulator,name=iPhone 17 Pro,OS=26.5

test:
	xcodebuild test \
		-workspace "$(WORKSPACE)" \
		-scheme "$(SCHEME)" \
		-destination "$(DESTINATION)"
```

**Xcode에서도 이제 `voip-ios.xcodeproj`가 아니라 `voip-ios.xcworkspace`를 열어야 한다.**
프로젝트를 열면 같은 이유로 빌드가 깨진다.

---

## 문제 2 — 스크립트 샌드박스가 rsync를 막는다

### 증상

워크스페이스로 바꾸자 링커 에러는 사라지고 다음이 나왔다.

```
error: Sandbox: rsync(99557) deny(1) file-read-data
  .../XCFrameworkIntermediates/WebRTC-SDK/WebRTC.framework/Info.plist
error: Sandbox: rsync(99557) deny(1) file-read-data
  .../XCFrameworkIntermediates/WebRTC-SDK/WebRTC.framework/PrivacyInfo.xcprivacy
error: Sandbox: rsync(99558) deny(1) file-write-create
  .../voip-ios.app/Frameworks/WebRTC.framework/.WebRTC.Lr2Wv33qsY

rsync(99557): error: ...: open (2) in /Users/.../voip-ios: Operation not permitted
```

진전은 있었다. XCFramework가 `XCFrameworkIntermediates/`에 풀렸다는 뜻이다.
이번엔 그걸 앱 번들로 복사하는 단계에서 막혔다.

### 원인

```
ENABLE_USER_SCRIPT_SANDBOXING = YES
```

**Xcode 15부터 새 프로젝트의 기본값이 `YES`다.** 빌드 스크립트가 프로젝트 디렉터리와
지정된 입출력 파일 밖을 건드리지 못하게 막는 보안 기능이다.

CocoaPods의 `[CP] Embed Pods Frameworks` 스크립트는 `rsync`로 DerivedData 안팎을
읽고 쓰는데, 이 경로들이 샌드박스 허용 범위를 벗어난다.

**CocoaPods를 쓰는 이상 반드시 부딪히는 문제다.** SPM에는 이 제약이 없다 —
빌드 스크립트 페이즈를 쓰지 않기 때문이다.

### 해결

Xcode에서 앱 타깃 → **Build Settings** → `User Script Sandboxing` → **No**

`project.pbxproj`에서는 Debug/Release 양쪽 설정이 바뀐다.

```diff
-				ENABLE_USER_SCRIPT_SANDBOXING = YES;
+				ENABLE_USER_SCRIPT_SANDBOXING = NO;
```

### 보안 트레이드오프

이건 **작은 보안 후퇴가 맞다.** 이 프로젝트의 초기 보안 검토에서
`ENABLE_USER_SCRIPT_SANDBOXING = YES`를 긍정적 항목으로 기록했었다.
끄면 빌드 스크립트가 샌드박스 밖을 자유롭게 접근하게 된다.

다만 CocoaPods를 쓰는 이상 선택지가 없다. WebRTC를 SPM으로 가져올 수 있다면
CocoaPods를 걷어내고 샌드박싱을 다시 켤 수 있다. 검토해볼 만하다.

---

## 문제 3 — 원인이 아니었던 것

### 증상

위 둘을 고친 뒤 전체 테스트를 돌리니 **UI 테스트 8건이 실패했다.**

```
Simulator device failed to launch junhyunny.voip-ios.
Error Domain=FBProcessExit Code=64 "The process failed to launch."
Error Domain=RBSRequestErrorDomain Code=5 "Launch failed."
```

유닛 테스트 23건은 통과하고 UI 테스트만 앱을 띄우지 못했다.
임베드된 WebRTC 프레임워크 때문인 것처럼 보였다.

### 확인한 것

의심 가는 것들을 하나씩 배제했다.

| 가설 | 확인 방법 | 결과 |
| --- | --- | --- |
| 시뮬레이터 아키텍처 불일치 | `WebRTC.xcframework/Info.plist` 슬라이스 확인 | `ios-arm64_x86_64-simulator` 존재 ✅ |
| 앱 번들이 너무 큼 | `du -sh voip-ios.app` | 16MB — 정상 범위 ✅ |
| 프레임워크 임베드 실패 | `ls voip-ios.app/Frameworks` | `WebRTC.framework` 존재 ✅ |
| 코드 서명 문제 | `simctl install` + `simctl launch` 수동 실행 | **정상 기동, PID 부여됨** ✅ |

수동 실행이 결정적이었다. 앱 자체는 멀쩡했다.

### 실제 원인

**시뮬레이터가 `Shutdown` 상태였다.** `xcodebuild test`는 시뮬레이터를 복제해
병렬 실행하는데(`Clone 1 of iPhone 17 Pro`), 종료 상태에서 복제될 때 일시적으로
앱 실행이 실패했다.

시뮬레이터를 부팅한 뒤 같은 명령을 다시 돌리니 **32건 전부 통과**했다.

```bash
xcrun simctl boot BC371661-CFDA-4682-9355-A3604F1749E7
make test
# → ** TEST SUCCEEDED **  통과 32건 / 실패 0건
```

### 교훈

**"CocoaPods를 넣은 직후 실패했다"가 "CocoaPods 때문이다"를 뜻하지 않는다.**
증상이 새 의존성을 가리키는 것처럼 보일 때일수록, 배제 실험으로 확인하는 편이 빠르다.
여기서는 `simctl`로 수동 설치·실행한 것이 5분을 아꼈다.

---

## 함께 정리한 것

### 커밋해야 하는 파일

| 파일 | 커밋 | 이유 |
| --- | --- | --- |
| `Podfile` | ✅ | 의존성 선언 |
| `Podfile.lock` | ✅ | 버전 고정 (팀 전체가 같은 버전을 써야 함) |
| `voip-ios.xcworkspace/` | ✅ | **없으면 아무도 빌드 못 한다** |
| `voip-ios.xcworkspace/xcshareddata/swiftpm/Package.resolved` | ✅ | SPM 해석 결과가 워크스페이스로 이동 |
| `Pods/` | ❌ | `.gitignore`에 있음 — 클론 후 `pod install` 필요 |

`Pods/`를 커밋하지 않는 선택이라면 README나 온보딩 문서에 `pod install`을 명시해야 한다.

### 의존성 관리자가 둘이 됐다

| 관리자 | 대상 | 비고 |
| --- | --- | --- |
| SPM | FlyingFox, FlyingSocks | 테스트 타깃 전용 |
| CocoaPods | WebRTC-SDK | 앱 타깃 |

둘이 공존하는 것 자체는 문제없지만, 샌드박싱을 끈 대가가 CocoaPods 쪽에서 왔다.
WebRTC-SDK의 SPM 배포가 가능하다면 CocoaPods를 걷어내는 것이 더 단순하다.

---

## 부록 — 같은 시기에 겪은 별개 문제

CocoaPods와 무관하지만 Makefile을 건드리게 된 또 다른 원인이다.

### 증상

```
xcodebuild: error: Unable to find a device matching the provided destination specifier:
                { platform:iOS Simulator, OS:latest, name:iPhone 17 Pro }
```

코드도 Makefile도 그대로인데 어느 날 갑자기 깨졌다.

### 원인

destination에 OS를 생략하면 xcodebuild가 **`OS=latest`로 채운다.**

```makefile
DESTINATION := platform=iOS Simulator,name=iPhone 17 Pro    # OS 없음
```

머신에 iOS 27.0 런타임이 설치되면서 "latest"가 26.5 → 27.0으로 바뀌었고,
**iOS 27.0에는 iPhone 17 Pro가 없다.**

| 런타임 | iPhone 17 Pro |
| --- | --- |
| iOS 26.5 | ✅ 있음 |
| iOS 27.0 | ❌ 없음 |

런타임이 하나 설치되면서 암묵적인 "latest"가 발밑에서 움직인 것이다.

### 해결

```makefile
DESTINATION := platform=iOS Simulator,name=iPhone 17 Pro,OS=26.5
```

**OS를 명시적으로 고정한다.** 재현 가능한 빌드에는 이쪽이 맞다.
새 런타임이 깔려도 흔들리지 않는다.

UDID 직접 지정(`id=BC371661-...`)은 디버깅에는 편하지만 Makefile에 넣으면 안 된다.
UDID는 머신마다 달라서 커밋하는 순간 다른 개발자와 CI에서 깨진다.

---

## 확인 명령

```bash
# 사용 가능한 시뮬레이터와 런타임
xcrun simctl list devices available
xcrun simctl list runtimes

# XCFramework 슬라이스 확인
cat Pods/WebRTC-SDK/WebRTC.xcframework/Info.plist | grep -A3 SupportedPlatform

# 앱 번들에 프레임워크가 임베드됐는지
ls ~/Library/Developer/Xcode/DerivedData/voip-ios-*/Build/Products/Debug-iphonesimulator/voip-ios.app/Frameworks

# 앱만 수동으로 설치·실행 (테스트 러너 배제)
xcrun simctl boot <UDID>
xcrun simctl install <UDID> <경로>/voip-ios.app
xcrun simctl launch <UDID> junhyunny.voip-ios

# 타깃 멤버십이 어긋났는지 (동기화 폴더 프로젝트)
grep -c membershipExceptions voip-ios.xcodeproj/project.pbxproj
```

## 체크리스트

- [ ] CocoaPods 도입 후에는 `.xcodeproj`가 아니라 `.xcworkspace`를 빌드/열어야 하는 이유를 설명할 수 있다.
- [ ] `-framework WebRTC` 플래그가 있는데도 `framework not found`가 나는 상황을 설명할 수 있다.
- [ ] `[CP] Copy XCFrameworks`와 `[CP] Embed Pods Frameworks`가 어느 타깃에 속하는지 안다.
- [ ] `ENABLE_USER_SCRIPT_SANDBOXING`이 무엇을 막는지, 왜 CocoaPods와 충돌하는지 안다.
- [ ] 샌드박싱을 끄는 것이 보안 트레이드오프임을 인지하고 있다.
- [ ] `Podfile.lock`과 워크스페이스를 커밋해야 하는 이유를 설명할 수 있다.
- [ ] destination에 OS를 생략하면 `OS=latest`로 해석된다는 것을 안다.
- [ ] 빌드 실패 원인이 새 의존성처럼 보일 때 배제 실험으로 확인하는 방법을 안다.

## 참고

- [CocoaPods Guides: Using CocoaPods](https://guides.cocoapods.org/using/using-cocoapods.html)
- [Apple Developer: Build settings reference — ENABLE_USER_SCRIPT_SANDBOXING](https://developer.apple.com/documentation/xcode/build-settings-reference)
- [Apple Developer: Distributing binary frameworks as Swift packages](https://developer.apple.com/documentation/xcode/distributing-binary-frameworks-as-swift-packages)
- [webrtc-sdk/Specs](https://github.com/webrtc-sdk/Specs)
