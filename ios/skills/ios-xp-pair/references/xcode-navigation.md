# Xcode 탐색과 피드백

안내하기 전에 화면에 보이는 프로젝트 상태를 확인한다. Target, Scheme, Group 같은 이름은 추측하지 말고 저장소나 학습자의 화면에서 확인한다.

## 위치를 짚어 안내하기

실행할 수 있는 Xcode 안내에는 다음 내용이 들어간다.

1. 열어야 할 Navigator나 Editor 영역
2. 선택할 구체적인 항목
3. 찾아야 할 Field, Button, Symbol
4. 화면에 나타나야 할 결과

예시: “왼쪽 Project Navigator에서 파란 프로젝트 아이콘을 선택하고 TARGETS의 앱 Target을 연 뒤, General > Minimum Deployments에서 현재 버전을 확인하세요. 이 값이 API 사용 가능 범위를 결정합니다.”

## 처음 필요해졌을 때 구분해서 설명할 개념

- **Project**는 파일과 Build 설정을 저장한다. **Target**은 앱이나 Test Bundle 하나를 만든다. **Scheme**은 Xcode가 Build, 실행, 테스트할 대상을 선택한다.
- 노란 Group은 실제 디스크 Directory와 일치하지 않으면서 Xcode Navigator 안의 항목만 정리할 수 있다. 파일을 이동하기 전에 Navigator와 File System을 모두 확인한다.
- Target Membership은 어떤 Source나 Resource가 Build 결과에 포함되는지 결정한다.
- 선택한 Run Destination은 Simulator와 실기기를 결정하며 사용할 수 있는 Capability에도 영향을 준다.
- Build 오류는 Issue Navigator, 실행 중 값과 Console 출력은 Debug Area, 테스트 결과는 Test Navigator와 Report Navigator에서 확인한다.

## 짧은 피드백 주기

유용한 범위 안에서 가장 좁은 피드백 주기를 선택한다.

- 문법과 Type 오류는 영향을 받은 Target을 Compile해서 확인한다.
- 동작은 관련 단위 테스트 하나를 실행해서 확인한다.
- 시각 상태는 Preview로 확인한다.
- Navigation과 생명주기 동작은 앱을 실행해 확인한다.
- 중요한 사용자 흐름은 XCUITest로 확인한다.
- Simulator가 입증할 수 없는 Hardware, Entitlement, 성능, 실제 서비스 동작만 실기기로 확인한다.

실행하기 전에 예상 결과를 알려준다. Build가 실패하면 가장 먼저 발생한 원인 오류부터 확인하고, 관련 파일과 Build Phase를 찾으며, 그 오류 때문에 연쇄적으로 발생한 다음 오류를 쫓지 않는다.

## 초보자를 배려한 설정 안내

Signing, Bundle Identifier, Capability, Deployment Target, Package 의존성, Info.plist 개인정보 보호 문구는 변경하기 직전에 설명한다. 이 설정은 Swift Source 밖의 동작에 영향을 주며 Apple 계정이나 기기에 의존할 수 있다.

인증서, Provisioning Profile, Token, 계정 인증 정보를 공개하도록 요청하지 않는다. 실제 서비스를 사용할 수 없으면 Fake Adapter로 학습 피드백 주기를 유지하고 아직 검증하지 못한 내용을 표시한다.
