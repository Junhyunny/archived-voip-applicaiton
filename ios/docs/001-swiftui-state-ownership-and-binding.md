# SwiftUI 상태 소유와 @Binding

> 질문: Compose의 "자식에게 MutableState를 넘기지 말고 값 + 콜백을 넘겨라"가
> iOS/SwiftUI에도 그대로 적용되는가?

## 결론

원칙은 그대로 적용되지만, Android 문서가 ①번을 안티패턴으로 본 대목은 SwiftUI에서 뒤집힌다.

Compose에서 `MutableState<T>`를 자식에게 넘기는 것에 대응하는 것이 SwiftUI의 `@Binding`이다.
그런데 **`@Binding`은 Apple이 직접 설계해 표준 라이브러리 전체에서 쓰는 1급 패턴이다.**
`TextField(text: $name)`, `Toggle(isOn: $flag)`, `Picker(selection: $choice)` 모두 자식이
부모의 값을 직접 쓴다. "자식에게 쓰기 권한을 주지 마라"를 그대로 옮기면 프레임워크와 싸우게 된다.

그렇다고 Android 문서가 틀린 것도 아니다. 다섯 가지 이점 중 **Interceptable(가로채기)** 는
`@Binding`에서도 똑같이 사라지고, 현재 `NumberKeypad`가 정확히 그 대가를 치르고 있다.
4자리 제한 정책이 자식 안에 들어가 있다.

| 항목 | Compose | SwiftUI |
| --- | --- | --- |
| 원시 가변 상태를 자식에게 | `MutableState<T>` — 피하라 | `@Binding` — 관용적이다 |
| 단방향 데이터 흐름 | 권장 | 권장 (동일) |
| 자식이 값을 안 읽으면 값을 빼라 | 권장 | 권장 (동일) |
| 상태 배치 기준 | 최소 공통 조상 | 동일 |
| 부모의 정책 강제 | 값 + 콜백 | 콜백 **또는** `Binding(get:set:)` |

마지막 행이 이 문서의 핵심이다. SwiftUI에는 Compose에 없는 중간 길이 있어서,
`@Binding`을 유지한 채로도 부모가 쓰기를 가로채어 Interceptable을 되찾을 수 있다.

## 전제 점검

Android 문서의 주장을 하나씩 SwiftUI에 대입해 본다.

**"상태는 내려가고 이벤트는 올라간다"** → **맞다.**
SwiftUI도 단일 진실공급원(single source of truth)을 명시적으로 내세우고, 값은 위에서 아래로 흐른다.
Apple은 WWDC "Data Essentials in SwiftUI"에서 상태를 복제하지 말고 하나를 파생시키라고 설명한다.

**"날것의 가변 상태를 자식에게 넘기지 마라"** → **SwiftUI에서는 아니다.**
여기가 갈라지는 지점이다. `@Binding`이 바로 "부모가 소유한 값을 자식이 읽고 쓸 수 있게 하는 장치"이고,
Apple은 이걸 권장한다. `@Binding`의 문서 설명 자체가 "a two-way connection"이다.

**"자식이 값을 읽지 않으면 값을 주지 마라"** → **맞다.**
프레임워크와 무관한 설계 원칙이다. 현재 `NumberKeypad`는 `roomCode.count < 4` 검사와 `popLast()`
때문에 값을 읽고 있지만, **그 읽기 자체가 있어야 할 이유가 없다.** 정책을 부모로 올리면 키패드는
방 번호를 몰라도 된다.

**"다섯 가지 이점"** → **네 개는 `@Binding`으로도 얻는다. Interceptable 하나만 잃는다.**

| 이점 | `@Binding`으로 얻는가 | 이 코드에서 |
| --- | --- | --- |
| Single source of truth | ✅ | `roomCode`는 `EnterRoomView`에만 있다 |
| Shareable | ✅ | 자릿수 `Text` 4개와 통화 버튼이 같은 값을 본다 |
| Decoupled | ✅ | 소유자를 `@Observable`로 옮겨도 자식은 그대로 |
| Encapsulated | ⚠️ 절반 | 키패드가 직접 쓴다 |
| **Interceptable** | **❌** | **4자리 제한을 부모가 걸 자리가 없다** |

**"`by` 위임은 구조를 바꾸지 않는다"** → **맞고, SwiftUI에는 이 단계 자체가 없다.**
Kotlin의 `by`는 `.value`를 감추는 문법 설탕인데, SwiftUI는 `@Binding`이 그 일을 이미 하고 있다.
`roomCode.append("1")`처럼 바로 쓴다. 즉 Android 문서의 ①과 ②가 SwiftUI에서는 한 개로 합쳐진다.

**"`LazyVerticalGrid`는 과하다"** → **맞고, 현재 코드에도 같은 문제가 있다.**
`NumberKeypad`가 `LazyVGrid`를 두 번 쓰는데, 항목이 12개 고정이고 스크롤도 없다.
`Grid` 또는 `VStack` + `HStack`으로 충분하다.

## SwiftUI의 상태 소유 모델

Compose는 `remember { mutableStateOf() }` 하나로 대부분을 처리하고 소유권은 관습으로 구분한다.
SwiftUI는 **소유 형태별로 프로퍼티 래퍼가 나뉘어 있어서, 선언만 보고도 누가 소유자인지 알 수 있다.**
이게 SwiftUI의 구조적 강점이다.

| 래퍼 | 소유권 | 수명 | Compose 대응 |
| --- | --- | --- | --- |
| `@State` | **이 뷰가 소유** | 뷰 정체성과 함께 | `remember { mutableStateOf() }` |
| `@Binding` | 다른 곳이 소유, 여기서 읽고 쓴다 | 없음 (참조) | `MutableState<T>` 전달 |
| `@Observable` + `@State` | 뷰가 객체를 소유 | 뷰 정체성과 함께 | `viewModel()` / 상태 홀더 |
| `@Bindable` | 객체가 소유, 바인딩만 만든다 | 없음 | — |
| `@Environment` | 상위 계층이 소유 | 계층 | `CompositionLocal` |
| `let` 프로퍼티 | 아무것도 — 값만 받는다 | 없음 | 일반 파라미터 |

### 이 코드의 현재 구조

```
EnterRoomView
  @State private var roomCode: String     ← 소유자
       │                    ▲
       │ $roomCode          │ roomCode.append("1")
       ▼                    │
  NumberKeypad
  @Binding var roomCode: String           ← 직접 쓴다
```

`@State`가 `private`인 것은 중요하다. Apple은 `@State`를 `private`으로 선언하라고 명시한다 —
소유자가 밖에서 초기화되면 진실공급원이 흔들리기 때문이다. 현재 코드는 이걸 지키고 있다.

### `$` 달러 표기가 하는 일

Kotlin의 `by`에 해당하는 설명이 필요한 자리다.

```swift
@State private var roomCode: String = ""

roomCode         // wrappedValue — String
$roomCode        // projectedValue — Binding<String>
_roomCode        // 래퍼 자체 — State<String>
```

`$roomCode`는 **값의 복사본이 아니라 그 저장소로 가는 getter/setter 쌍**이다. 자식이
`roomCode.append()`를 호출하면 부모의 `@State`가 직접 바뀐다. Compose에서 `MutableState`
객체를 넘긴 것과 **소유권 구조가 정확히 같다.**

### 어느 계층에서든 반복되는 원칙

Android 문서가 "`MutableStateFlow`를 노출하는 것과 같은 실수"라고 한 대목은 SwiftUI에서도 성립한다.

```swift
@Observable
final class CallingViewModel {
    private(set) var callStatus: CallStatus = .unconnected   // 밖으로는 읽기 전용
    func startCall(roomCode: String) async { ... }           // 변경은 메서드로
}
```

이미 `CallingViewModel`에서 이 패턴을 쓰고 있다. `private(set)`이 "밖으로는 불변, 안으로는 가변"을
타입 수준에서 강제한다. **같은 원칙을 뷰 계층에도 적용할 것인가가 이 문서의 질문이다.**

## `@Binding`은 `MutableState`와 지위가 다르다

소유권 **구조**는 같지만 프레임워크가 부여한 **지위**가 다르다. 이 차이를 무시하고 Android 규칙을
그대로 옮기면 SwiftUI를 거스르게 된다.

### 근거 1 — 표준 라이브러리가 전부 이렇게 생겼다

```swift
TextField("이름", text: $name)          // 자식이 name을 직접 쓴다
Toggle("알림", isOn: $enabled)
Picker("항목", selection: $choice) { ... }
Stepper("수량", value: $count, in: 0...10)
Slider(value: $volume)
.sheet(isPresented: $showing) { ... }
```

Compose는 같은 것들을 **값 + 콜백**으로 만들었다.

```kotlin
TextField(value = name, onValueChange = { name = it })
Switch(checked = enabled, onCheckedChange = { enabled = it })
```

같은 문제에 두 프레임워크가 반대 답을 골랐다. 그래서 **"어느 쪽이 절대적으로 옳다"가 아니라,
각 생태계의 관습을 따르는 것이 우선**이다. SwiftUI 코드를 읽는 사람은 `$`를 보면 양방향 연결을
즉시 알아본다.

### 근거 2 — 값 타입 의미론 때문에 필요했다

Swift의 `String`, 구조체, 배열은 전부 **값 타입**이라 넘기면 복사된다. 자식이 복사본을 고쳐봐야
부모는 모른다. `@Binding`은 바로 이 간극을 메우려고 만들어졌다 — 참조 의미론을 필요한 곳에만
주는 장치다.

Kotlin에서 `MutableState`는 이미 참조 타입이라 그냥 넘길 수 있었고, 그래서 가이드라인이 따로
"넘기지 말라"고 말해야 했다. SwiftUI는 그 허가를 **명시적으로 요구**한다 — `$`를 붙이지 않으면
쓸 수 없다. 호출부에 흔적이 남는 것이 Compose보다 나은 점이다.

```swift
NumberKeypad(roomCode: $roomCode)   // 부모 코드에 "쓰기 권한을 줌"이 보인다
```

### 그래서 정확한 규칙은

> `@Binding`을 피하라가 아니라, **자식이 정책까지 가져가지 않게 하라**다.

`TextField`가 좋은 예다. 이것은 바인딩을 받지만 **입력 규칙을 소유하지 않는다.** 길이 제한이나
형식 검증을 넣고 싶으면 부모가 `onChange`나 커스텀 `Binding`으로 걸어야 한다. 즉
**값의 전달과 정책의 소유는 별개의 문제**다.

현재 `NumberKeypad`는 둘 다 가져갔다.

## 현재 코드의 실제 문제 — 정책이 자식에 있다

`@Binding` 자체는 문제가 아니다. 문제는 그 옆에 따라들어온 것이다.

```swift
// NumberKeypad.swift — 현재
struct NumberKeypad: View {
    @Binding var roomCode: String

    private func tapKeypad(number: String) {
        if roomCode.count < 4 {        // ← 방 코드가 4자리라는 걸 키패드가 안다
            roomCode.append(number)
        }
    }
    // ...
    Button("delete") { _ = roomCode.popLast() }   // ← 삭제 규칙도 키패드가 소유
}
```

**숫자 키패드가 "방 코드는 4자리다"라는 도메인 규칙을 알고 있다.** 이게 정확히 Android 문서가
말한 *Interceptable 상실*이다.

### 구체적으로 뭐가 손해인가

**재사용이 막힌다.** 전화번호 입력(11자리)이나 PIN(6자리)에 같은 키패드를 쓰려면 `NumberKeypad`를
고쳐야 한다. 키패드는 숫자 버튼 12개를 그리는 일만 하면 되는데도.

**정책이 세 곳으로 갈라졌다.** `4`라는 숫자가 지금 세 군데 있다.

| 위치 | 역할 |
| --- | --- |
| `NumberKeypad.tapKeypad` | 입력 상한 |
| `EnterRoomView.RoomCodeSection` | `ForEach(0..<4)` 표시 칸 개수 |
| `EnterRoomView` 통화 버튼 | `roomCode.count != 4` 활성화 조건 |

하나만 고치면 조용히 어긋난다. 이전에 이미 같은 종류의 버그를 겪었다 — 5번째 숫자를 누르면
통화 버튼이 도로 비활성화되던 그 문제다. 상수를 `roomCodeLength` 하나로 묶어도
**어느 타입이 이 규칙을 책임지는가**는 여전히 모호하다.

**부모가 입력을 가로채지 못한다.** 예를 들어 "4자리가 채워지면 자동으로 통화 시작",
"입력할 때마다 햅틱 피드백", "서버에 중복 여부 조회" 같은 요구가 오면 걸 자리가 없다.
지금은 자식이 부모 몰래 `roomCode`를 바꾸고 끝난다.

**빈 버튼이 아무것도 안 한다.** `print("Actions for empty")`가 남아 있다. 키를 타입으로
모델링했다면 빈 칸을 `Spacer`로 두는 것이 자연스럽다.

**문자열 키가 위험하다.** `"delete"`가 문자 그대로 `roomCode`에 붙을 수 있는 구조다. 지금은
삭제 버튼이 `popLast()`를 직접 불러서 문제가 안 드러나지만, 타입이 막아주는 것과 우연히
안 일어나는 것은 다르다.

## 네 가지 방식 비교

### ① `@Binding` — 현재 코드

```swift
struct NumberKeypad: View {
    @Binding var roomCode: String
}
```

- 👍 SwiftUI 관용적 표현. 호출부가 `NumberKeypad(roomCode: $roomCode)` 한 줄
- 👍 호출부의 `$`가 쓰기 권한을 드러낸다
- 👎 자식이 정책을 가져가기 쉬워진다 (지금 그렇다)
- 👎 부모가 가로채지 못한다 — 단, `Binding(get:set:)`으로 해결 가능
- 👎 읽기 전용 화면에 재사용할 수 없다
- 👎 프리뷰마다 `@Previewable @State` 또는 `.constant()`가 필요하다

### ② 값 + 콜백 — Compose 표준의 직역

```swift
struct NumberKeypad: View {
    let roomCode: String
    let onRoomCodeChange: (String) -> Void
}
```

- 👍 부모가 검증하고 거절할 수 있다
- 👍 프리뷰가 `NumberKeypad(roomCode: "12", onRoomCodeChange: { _ in })` 한 줄
- 👎 **SwiftUI에서는 어색하다.** 표준 컴포넌트 중 이 형태가 거의 없다
- 👎 이 코드에서는 자식이 쓰지도 않는 값을 받는다

### ③ 이벤트 콜백만 — 이 코드에 가장 맞는 형태

```swift
struct NumberKeypad: View {
    let onKeyPress: (KeypadKey) -> Void
}
```

- 👍 키패드가 방 번호를 모른다 — 알 이유가 없다
- 👍 재사용성이 가장 높다. 방 코드든 PIN이든 전화번호든 같은 키패드
- 👍 조립 정책(길이 제한, 삭제, 빈 키)을 부모가 전부 소유한다
- 👍 프리뷰가 `NumberKeypad(onKeyPress: { _ in })` 한 줄
- 👍 SwiftUI 관용과 충돌하지 않는다 — `Button(action:)`도 이벤트 콜백이다
- 👎 자식 UI가 값에 의존하면(4자리 차면 키 비활성화) 값을 따로 받아야 한다

### ④ `@Observable` 상태 타입 — 상태가 얽힐 때

```swift
@Observable
final class RoomCodeField {
    private(set) var code: String = ""
    let length: Int

    var isComplete: Bool { code.count == length }

    func append(_ digit: Character) {
        guard code.count < length else { return }
        code.append(digit)
    }
    func deleteLast() { _ = code.popLast() }
}
```

- 👍 정책을 타입 안에 가둔다. `4`가 한 군데만 있게 된다
- 👍 파라미터 폭발을 막는다
- 👍 `private(set)`으로 "밖으로는 불변"을 강제 — `CallingViewModel`과 같은 패턴
- 👍 유닛 테스트로 규칙을 검증할 수 있다 (현재는 UI 테스트만 있다)
- 👎 버튼 12개짜리 키패드에는 과하다

### 판단 기준

> 자식이 값을 안 읽으면 ③. 읽지만 정책은 부모 것이면 ① + `Binding(get:set:)`.
> 상태와 규칙이 얽히면 ④.

**이 코드는 ③가 답이다.** 키패드는 "어떤 키를 눌렀다"만 알리면 된다. 나중에 입력 규칙이
복잡해지면(서버 검증, 자동 전송) 그때 ④로 옮기면 되고, 그때도 `NumberKeypad`는 한 글자도
안 바뀐다.

## SwiftUI만의 중간 길 — `Binding(get:set:)`

Compose에는 없는 선택지다. Android 문서가 "MutableState를 넘기면 검증을 걸 자리가 없다"고 한
대목이 SwiftUI에서는 **반만 맞다.** 바인딩을 직접 만들면 그 자리가 생긴다.

`Binding`은 마법이 아니라 **getter/setter 한 쌍을 담은 구조체**라, 직접 만들면서 쓰기 경로에
정책을 끼워 넣을 수 있다.

```swift
// EnterRoomView — @Binding을 유지하면서 부모가 규칙을 강제한다
NumberKeypad(
    roomCode: Binding(
        get: { roomCode },
        set: { newValue in
            // 정책은 부모의 것 — 키패드는 이 규칙을 모른다
            roomCode = String(newValue.prefix(roomCodeLength))
        }
    )
)
```

이제 `NumberKeypad`가 `roomCode.append()`를 몇 번 호출하든 4자리를 넘지 못한다. 자식 코드는
한 글자도 바뀌지 않고, **Interceptable을 되찾았다.**

### 언제 이걸 쓰나

`Binding(get:set:)`은 **내가 소유하지 않은 컴포넌트에 정책을 걸 때** 제값이다.
`TextField`가 전형적인 예다.

```swift
// TextField는 수정할 수 없다. 그래도 입력을 통제한다
TextField("방 코드", text: Binding(
    get: { roomCode },
    set: { roomCode = String($0.filter(\.isNumber).prefix(4)) }
))
```

반면 **내가 만든 컴포넌트라면 애초에 이벤트 콜백으로 설계하는 것이 낫다.** `NumberKeypad`는
직접 만든 것이니 ③가 맞다. `Binding(get:set:)`은 "SwiftUI에는 탈출구가 있다"는 걸 보이려는
예시이지, 권장 최종형은 아니다.

### 주의 한 가지

`Binding(get:set:)`은 뷰가 다시 그려질 때마다 **새 인스턴스가 만들어진다.** `Binding`은
`Equatable`이 아니라 이게 문제되는 경우는 드물지만, 값이 바뀌지 않았는데도 뷰가 갱신되는
상황이라면 의심해볼 지점이다. 역시 이벤트 콜백이 더 단순하다.

## 상태를 어디에 둘 것인가

이 부분은 **Android 규칙과 사실상 동일하다.** 프레임워크가 아니라 UI 아키텍처의 문제이기 때문이다.

1. 그 상태를 **읽는 모든 뷰의 최소 공통 조상**으로 올린다
2. **쓰는 가장 높은 지점**까지는 올린다
3. 같은 이벤트로 함께 변하는 상태는 **같이 올린다**

필요보다 더 올리는 것은 괜찮지만, 덜 올리면 단방향 흐름이 깨진다.

### 이 코드에 대입하면

`roomCode`를 쓰는 곳은 `NumberKeypad`, 읽는 곳은 자릿수 `Text` 4개와 통화 버튼, 그리고
`NavigationLink(value:)`다. 이 셋의 최소 공통 조상은 `EnterRoomView`다.

**지금 위치가 정확하다.** 더 올릴 이유가 없다.

### 올리지 않아도 되는 상태

Apple도 모든 상태를 올리라고 하지 않는다. 밖에서 아무도 안 보는 상태는 안에 두는 것이 맞다.

```swift
struct KeypadButton: View {
    @State private var isPressed = false   // 부모가 알 필요 없다
}
```

애니메이션 진행률, 펼침/접힘, 포커스, 스크롤 오프셋이 여기 속한다.

### 뷰모델까지 올릴 것인가

Android 문서의 구분과 같다.

| 상태 | 어디에 | 이 프로젝트에서 |
| --- | --- | --- |
| UI 요소 상태 (눌림, 포커스, 애니메이션) | `@State` — 뷰 안 | 키 눌림 효과 |
| 화면 입력 상태 | `@State` — 화면 뷰 | `roomCode` |
| 화면 상태 + 비즈니스 로직 | `@Observable` 클래스 | `CallingViewModel` |

`roomCode` 입력 자체는 UI 상태라 `@State`가 맞다. 다만 **"방 번호가 서버에 존재하는지 조회"가
들어오는 순간** `EnterRoomViewModel`로 올라간다. 그때도 ③로 만들어둔 `NumberKeypad`는
그대로다 — 이게 Decoupled의 값어치다.

이미 `CallingView`가 같은 전환을 거쳤다. 타이머와 시그널링이 `CountDownTimer`와
`CallingViewModel`로 나가면서 뷰는 그리는 일만 남았다.

## 렌더링 관점 차이

Android 문서가 ③번을 미는 근거 중 하나가 재구성 건너뛰기였다.
**이 논거는 SwiftUI에 그대로 옮기면 안 된다.** 두 프레임워크의 갱신 모델이 다르다.

### Compose의 논리

람다가 `MutableState` 객체만 캡처하고 값은 캡처하지 않으면, 그 객체의 정체성이 변하지 않아
Compose가 람다를 메모이즈하고 **자식의 재구성을 건너뛴다.**

### SwiftUI는 그렇게 작동하지 않는다

SwiftUI에서 `View`는 가벼운 값 타입 기술서다. 부모 `body`가 재평가되면 자식 `View` 구조체도
다시 만들어진다. 그런 다음 SwiftUI가 이전 값과 비교해 **실제 렌더링만 건너뛴다.**
구조체 생성 자체는 사실상 공짜다.

그리고 **클로저를 가진 뷰는 이 비교에서 유리하지 않다.** Swift 클로저는 `Equatable`이 아니라,
콜백만 받는 뷰도 대개 "달라졌다"고 판정된다. 즉 **③로 바꿔도 Compose처럼 깔끔한 건너뛰기를
얻지는 못한다.**

### 그럼 SwiftUI에서는 무엇이 성능을 가르나

| Compose | SwiftUI 대응 |
| --- | --- |
| 람다 메모이즈로 재구성 건너뛰기 | `@Observable`의 **프로퍼티 단위 추적** |
| 상태 읽기를 최대한 늦추기 | 동일 — `body`가 읽는 프로퍼티만 구독된다 |
| `@Stable` 타입 | 뷰를 잘게 쪼개서 무효화 범위 줄이기 |

iOS 17의 `@Observable`이 Android 문서의 "Defer reads as long as possible"에 해당하는 장치다.
`body`가 **실제로 읽은 프로퍼티에만** 의존성이 생기므로, `CallingViewModel.callStatus`를
안 읽는 뷰는 그 값이 바뀌어도 갱신되지 않는다.

### 결론

**③를 고르는 이유에서 성능을 빼라.** Android 문서도 "버튼 12개짜리 키패드에서 이 차이는
체감되지 않는다"고 솔직히 적었는데, SwiftUI에서는 그 정도가 아니라 **아예 해당하지 않는다.**

그래도 ③가 맞다. 이유는 오직 **설계** 하나다 — 키패드는 방 번호를 모르는 것이 옳기 때문이다.

## 정리한 최종 코드

```swift
// voip-ios/Types/KeypadKey.swift
enum KeypadKey: Hashable {
    case digit(Character)
    case empty
    case delete

    var label: String {
        switch self {
        case .digit(let c): String(c)
        case .empty: ""
        case .delete: "⌫"
        }
    }

    // 눈에 보이는 순서 그대로
    static let grid: [KeypadKey] = [
        .digit("1"), .digit("2"), .digit("3"),
        .digit("4"), .digit("5"), .digit("6"),
        .digit("7"), .digit("8"), .digit("9"),
        .empty, .digit("0"), .delete,
    ]

    var accessibilityID: String {
        switch self {
        case .digit(let c): "keypad_\(c)"
        case .empty: "keypad_empty"
        case .delete: "keypad_delete"
        }
    }
}
```

```swift
// voip-ios/Components/NumberKeypad.swift
struct NumberKeypad: View {
    let onKeyPress: (KeypadKey) -> Void

    var body: some View {
        // 12개 고정에 스크롤도 없으므로 Lazy가 필요 없다
        Grid {
            ForEach(KeypadKey.grid.chunked(into: 3), id: \.self) { row in
                GridRow {
                    ForEach(row, id: \.self) { key in
                        if key == .empty {
                            Color.clear
                                .gridCellUnsizedAxes([.horizontal, .vertical])
                        } else {
                            Button(key.label) { onKeyPress(key) }
                                .accessibilityIdentifier(key.accessibilityID)
                        }
                    }
                }
            }
        }
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("numbers_keypad")
    }
}
```

```swift
// voip-ios/Views/EnterRoomView.swift
private let roomCodeLength = 4

struct EnterRoomView: View {
    @State private var roomCode: String = ""
    @Environment(\.appConfig) private var appConfig

    var body: some View {
        VStack {
            Text("방 코드")
            Text("두 기기에 같은 코드를 입력하세요")
            RoomCodeSection

            // 정책은 전부 여기 — 키패드는 4자리를 모른다
            NumberKeypad { key in
                switch key {
                case .delete:
                    _ = roomCode.popLast()
                case .empty:
                    break
                case .digit(let c):
                    guard roomCode.count < roomCodeLength else { return }
                    roomCode.append(c)
                }
            }

            NavigationLink(value: roomCode) { Text("통화 시작") }
                .disabled(roomCode.count != roomCodeLength)
                .accessibilityIdentifier("call_button")
        }
        .navigationDestination(for: String.self) { code in
            CallingView(
                roomCode: code,
                timeLimitSeconds: appConfig.timeLimitSeconds,
                signalingURL: appConfig.signalingURL
            )
        }
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("enter_room_view")
        .padding()
    }
}
```

### 바뀐 곳

| # | 변경 | 얻는 것 |
| --- | --- | --- |
| 1 | `@Binding` → `onKeyPress` 콜백 | 키패드가 방 번호를 모른다 |
| 2 | 4자리 제한을 부모로 | Interceptable 회복 |
| 3 | `String` → `KeypadKey` | `"delete"`가 문자로 붙는 사고를 타입이 막는다 |
| 4 | 빈 버튼 → `Color.clear` | `print` 플레이스홀더 제거 |
| 5 | `LazyVGrid` ×2 → `Grid` | 12개 고정 격자에 지연 레이아웃 불필요 |
| 6 | `4` → `roomCodeLength` | 세 군데 흩어져 있던 상수를 하나로 |

`NavigationLink(value:)`의 라우팅 타입이 `String`인 건 그대로 두었다. 별도 이슈다.

## 프리뷰와 테스트에서 드러나는 차이

호이스팅의 실익이 가장 눈에 보이는 자리다.

### 프리뷰

```swift
// ③ — 한 줄
#Preview { NumberKeypad(onKeyPress: { _ in }) }

// ① — 상태를 만들어 줘야 한다
#Preview {
    @Previewable @State var code = "12"
    NumberKeypad(roomCode: $code)
}

// ① 를 .constant 로 때우면 버튼이 동작하지 않는 죽은 프리뷰가 된다
#Preview { NumberKeypad(roomCode: .constant("12")) }
```

`@Previewable`은 iOS 18 / Xcode 16부터 쓸 수 있다. 그 전에는 래퍼 뷰를 따로 만들어야 했다.

### 유닛 테스트

③로 바꾸면 **조립 정책을 유닛 테스트로 검증할 수 있다.** 지금은 이 규칙이 뷰 안에 있어서
UI 테스트로만 확인 가능하고, 실제로 `EnterRoomViewUITests`의 여러 케이스가 시뮬레이터를 띄워
5~15초씩 쓰고 있다.

정책을 ④의 `RoomCodeField`로 빼면 이렇게 된다.

```swift
@MainActor
struct RoomCodeFieldTests {
    @Test func 네_자리를_넘겨_입력할_수_없다() {
        let sut = RoomCodeField(length: 4)

        for c in "12345" { sut.append(c) }

        #expect(sut.code == "1234")
        #expect(sut.isComplete)
    }

    @Test func 빈_상태에서_삭제해도_안전하다() {
        let sut = RoomCodeField(length: 4)

        sut.deleteLast()

        #expect(sut.code.isEmpty)
    }
}
```

밀리초 단위로 끝난다. UI 테스트는 "키패드가 화면에 보이고 탭이 전달된다"만 남기면 된다.

## 체크리스트

- [ ] SwiftUI의 `@Binding`이 Compose의 `MutableState` 전달과 소유권 구조가 같음을 설명할 수 있다.
- [ ] 그럼에도 `@Binding`이 SwiftUI에서 관용적인 이유 두 가지를 댈 수 있다.
- [ ] `$roomCode`가 값의 복사본이 아니라 저장소로 가는 접근자 쌍임을 설명할 수 있다.
- [ ] `@State`를 `private`으로 선언하는 이유를 설명할 수 있다.
- [ ] 다섯 가지 이점 중 `@Binding`이 잃는 것이 Interceptable 하나임을 말할 수 있다.
- [ ] 현재 `NumberKeypad`에서 `4`라는 숫자가 몇 군데 있는지 짚을 수 있다.
- [ ] 자식이 값을 읽지 않는다면 값 파라미터를 빼는 편이 나은 이유를 설명할 수 있다.
- [ ] `Binding(get:set:)`으로 부모가 쓰기를 가로챌 수 있음을 안다.
- [ ] `Binding(get:set:)`이 적절한 경우와 이벤트 콜백이 나은 경우를 구분할 수 있다.
- [ ] 상태를 어디에 올릴지 정하는 규칙 세 가지를 말할 수 있다.
- [ ] 호이스팅하지 않아도 되는 상태의 예를 들 수 있다.
- [ ] Compose의 재구성 건너뛰기 논리가 SwiftUI에 그대로 적용되지 않는 이유를 설명할 수 있다.
- [ ] `@Observable`의 프로퍼티 단위 추적이 무엇을 대체하는지 안다.
- [ ] `private(set)` + 메서드 패턴이 `MutableStateFlow` 캡슐화와 같은 원리임을 설명할 수 있다.
- [ ] 항목이 적고 스크롤이 없으면 `LazyVGrid`가 불필요한 이유를 안다.

## 공식 참고 자료

- Apple Developer: [Managing user interface state](https://developer.apple.com/documentation/swiftui/managing-user-interface-state)
- Apple Developer: [State](https://developer.apple.com/documentation/swiftui/state)
- Apple Developer: [Binding](https://developer.apple.com/documentation/swiftui/binding)
- Apple Developer: [Managing model data in your app](https://developer.apple.com/documentation/swiftui/managing-model-data-in-your-app)
- Apple Developer: [Migrating from the Observable Object protocol to the Observable macro](https://developer.apple.com/documentation/swiftui/migrating-from-the-observable-object-protocol-to-the-observable-macro)
- Apple Developer: [Grid](https://developer.apple.com/documentation/swiftui/grid)
- WWDC20: Data Essentials in SwiftUI
- WWDC23: Discover Observation in SwiftUI
- WWDC21: Demystify SwiftUI (뷰 정체성과 갱신)

> 인용 표기 없이 요지만 옮긴 곳이 있다. 정확한 문구가 필요하면 위 원문을 확인할 것.
