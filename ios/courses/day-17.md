# Course Day 17 — ActiveCall Reducer와 Audio Facade

[이전 Day](day-16.md) · [전체 진도](day-00.md) · [다음 Day](day-18.md)

- [ ] Day 17 완료

## 중점 학습

- ActiveCall의 State/Action/Reducer/Effect와 AVAudioSession Adapter·Audio Facade 연결

## 과정 내용

> 아래 과정 내용은 `plan.md`의 해당 Day 구간을 빠짐없이 옮긴 것이다.

## Day 17 — ActiveCall Reducer와 Audio Facade

학습:

```text
microphone permission
audio category/mode
speaker
receiver
Bluetooth
wired headset
route change
interruption
State / Action / Reducer / Effect
```

구현:

```text
ActiveCall State / Action
순수 reduce 함수
Effect 명령 모델
오디오 출력 선택 Sheet
현재 route 표시
마이크 권한 거부 안내
interruption 상태 배너
```

View와 시스템 Adapter의 모든 입력을 `ActiveCallAction`으로 바꾸고, Reducer만 state를 변경한다. Reducer가 `AVAudioSession`을 직접 호출하지 않고 `prepareAudio`, `activateAudio`, `deactivateAudio` 같은 Effect를 반환하게 한다.

TDD:

```text
통화 시작 시 audio configuration 요청
이어폰 제거 시 fallback route 정책
Bluetooth 연결
권한 거부
interruption began
interruption ended + shouldResume
통화 종료 후 route event 무시
```

시스템 API 자체가 아닌 **정책과 adapter 변환**을 테스트한다.

```text
AVAudioSession notification
        ↓
AudioSessionAdapter
        ↓
AudioEvent
        ↓
ActiveCallAction
        ↓
Reducer → State + Effect
```

`AVAudioSession`, route observer, interruption observer의 복잡한 순서는 `CallAudioSystem` Facade 뒤에 둔다.

---
