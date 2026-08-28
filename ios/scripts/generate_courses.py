#!/usr/bin/env python3
"""Split plan.md into a losslessly covered Day 00 index and Day 01-30 courses."""

from __future__ import annotations

import re
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
PLAN_PATH = ROOT / "plan.md"
COURSES_PATH = ROOT / "courses"

FOCUS = {
    1: "Xcode 프로젝트·테스트 기반, Feature-first 구조, View local state와 필요할 때만 확장하는 Composition Root",
    2: "SwiftUI 기본 레이아웃, View identity, `ForEach`의 안정적인 ID, 화면 상태를 표현하는 ViewState",
    3: "Observation과 single source of truth, View local state와 `@Observable` Feature Model/MVVM의 소유권 경계",
    4: "Login MVVM, Form 검증, AuthClient·Clock·Logger의 명시적 DI, 중복 입력과 취소 가능한 요청",
    5: "Navigation도 state라는 관점, 타입 안전한 Router, 딥링크, 인증 전후 목적지 복원과 중복 Route 방지",
    6: "의미 기반 디자인 토큰과 최소 Design System, Dynamic Type·VoiceOver·Dark Mode 등 접근성",
    7: "Login/Home/Router 재구현 뒤 View·Feature·Composition Root 책임과 아직 필요 없는 추상화 구분",
    8: "URLSession을 HTTPClient로 바꾸는 Adapter, DTO/Domain 분리, 계층별 Error mapping과 Fake",
    9: "Remote+Cache CallHistoryRepository, LoadPolicy, 목록·상세·페이지네이션과 요청 중복·취소",
    10: "Retry/debounce Strategy, 검색·필터 조합, 이전 Task 취소와 late response 무시, 주입 가능한 Clock",
    11: "명시적 State로 모델링한 다단계 Form, 단계별 검증·draft 복원·중복 제출과 실패 복구 UX",
    12: "Repository의 Memory/Local/Remote 조합, stale fallback, 중복 fetch 공유와 Offline UX",
    13: "UIKit Adapter와 Facade의 역할, Representable/Coordinator를 통한 callback→Feature Action 변환",
    14: "동일 검색 Feature의 MVVM vs 직접 Action/Reducer 비교와 Stub dependency 기반 핵심 XCUITest",
    15: "Observer와 AsyncStream, NWPathMonitor를 Domain에서 격리하는 Adapter, 구독 Task 생명주기",
    16: "Domain Call State Machine, 유효하지 않거나 순서가 바뀌고 늦고 중복된 Event의 전이 정책",
    17: "ActiveCall의 State/Action/Reducer/Effect와 AVAudioSession Adapter·Audio Facade 연결",
    18: "Async Effect 실행·Task cancellation, CallKit/PushKit 이벤트 변환과 비정상 event 순서",
    19: "ActiveCall parent/child Feature composition, lifecycle·권한 callback을 Reducer Action으로 처리",
    20: "직접 Reducer 뒤 TCA State/Action/Reducer/Store/Dependency를 적용하고 품질 Strategy를 격리",
    21: "TCA TestStore·child scoping, MVVM/직접 Reducer/TCA 비교와 다중 시스템 Failure Drill",
    22: "local/feature/shared/persistent/server state 소유권 구분과 String Catalog 기반 Localization",
    23: "Infrastructure→Domain→Presentation Error architecture와 VoiceOver·Dynamic Type 실기기 검증",
    24: "Task ownership/cancellation 계약을 테스트하고 Instruments로 CPU·메모리·누수를 측정",
    25: "Logging/Retry/Metrics Decorator와 production diagnostics, 상태를 설명하는 사용자 feedback",
    26: "Characterization test 뒤 Adapter·Repository·Policy·State Machine·Navigation을 점진 추출",
    27: "단위/통합/UI 테스트 경계와 PR·main·nightly CI, 실패 artifact와 TestFlight 내부 배포",
    28: "환경별 Dependency Factory와 기기·네트워크·오디오·권한·생명주기 실기기 테스트",
    29: "대형 Feature composition에서 parent/shared state를 판단하며 실무 요구 변경과 PR을 완주",
    30: "장애 재현·회귀 검증 뒤 Architecture 선택 근거와 다음 전환 신호를 ADR로 작성",
}

WEEK_NAMES = {
    1: "Week 1 — Local State에서 MVVM·DI·Router까지",
    2: "Week 2 — Adapter·Repository·Strategy와 일반 Feature",
    3: "Week 3 — State Machine·Reducer·TCA와 시스템 이벤트",
    4: "Week 4 — Production-ready Architecture와 운영 품질",
}


def week_for(day: int) -> int:
    if day <= 7:
        return 1
    if day <= 14:
        return 2
    if day <= 21:
        return 3
    return 4


def main() -> None:
    source = PLAN_PATH.read_text(encoding="utf-8")
    day_matches = list(re.finditer(r"(?m)^## Day (\d+) — (.+)$", source))
    if [int(match.group(1)) for match in day_matches] != list(range(1, 31)):
        raise SystemExit("plan.md must contain each Day heading from 1 through 30 exactly once")

    common_end_match = re.search(r"(?m)^# 세 번씩 반복할 UI TDD 과제$", source)
    if common_end_match is None:
        raise SystemExit("Could not find the final common curriculum section")

    week_starts = {}
    for match in re.finditer(r"(?m)^# Week (\d+) — .+$", source):
        week_starts[int(match.group(1))] = match.start()
    if sorted(week_starts) != [1, 2, 3, 4]:
        raise SystemExit("plan.md must contain Week 1 through Week 4")

    starts = []
    for match in day_matches:
        day = int(match.group(1))
        starts.append(week_starts[week_for(day)] if day in (1, 8, 15, 22) else match.start())

    prefix = source[: starts[0]]
    suffix = source[common_end_match.start() :]
    slices = []
    for index, start in enumerate(starts):
        end = starts[index + 1] if index + 1 < len(starts) else common_end_match.start()
        slices.append(source[start:end])

    if prefix + "".join(slices) + suffix != source:
        raise SystemExit("Lossless split check failed; no course files were written")

    COURSES_PATH.mkdir(exist_ok=True)
    titles = {int(match.group(1)): match.group(2) for match in day_matches}

    completed_days = set()
    day_zero_ready = False
    existing_index_path = COURSES_PATH / "day-00.md"
    if existing_index_path.exists():
        existing_index = existing_index_path.read_text(encoding="utf-8")
        day_zero_ready = bool(re.search(r"(?m)^- \[[xX]\] Day 00 준비 완료:", existing_index))
        completed_days.update(
            int(match.group(1))
            for match in re.finditer(r"(?m)^- \[[xX]\] \[Day (\d{2}) —", existing_index)
        )
    for day in range(1, 31):
        existing_day_path = COURSES_PATH / f"day-{day:02d}.md"
        if not existing_day_path.exists():
            continue
        existing_day = existing_day_path.read_text(encoding="utf-8")
        if re.search(rf"(?m)^- \[[xX]\] Day {day:02d} 완료$", existing_day):
            completed_days.add(day)

    index_parts = [
        "# Day 00 — 전체 과정 안내와 진도표\n\n",
        "이 파일은 30일 과정의 진행 상황과 각 Day의 중점 학습을 한눈에 확인하는 대시보드다. "
        "Day를 마치면 이 표와 해당 Day 파일의 완료 체크박스를 함께 표시한다.\n\n",
        f"- [{'x' if day_zero_ready else ' '}] Day 00 준비 완료: 전체 과정과 완료 기준을 읽고 첫 학습 세션을 정했다.\n\n",
        "## 과정 진도와 중점 학습\n\n",
    ]
    for week in range(1, 5):
        index_parts.append(f"### {WEEK_NAMES[week]}\n\n")
        for day in range(1, 31):
            if week_for(day) != week:
                continue
            completion_mark = "x" if day in completed_days else " "
            index_parts.append(
                f"- [{completion_mark}] [Day {day:02d} — {titles[day]}](day-{day:02d}.md)\n"
                f"  **중점:** {FOCUS[day]}\n"
            )
        index_parts.append("\n")

    index_parts.extend(
        [
            "## 전체 과정 공통 안내\n\n",
            "> 아래 내용은 `plan.md`의 Day별 과정 앞에 있는 공통 안내를 빠짐없이 옮긴 것이다.\n\n",
            prefix,
            "\n## 전체 과정 공통 연습과 완료 기준\n\n",
            "> 아래 내용은 `plan.md`의 Day 30 뒤에 있는 공통 과제, 화면 완료 기준, 안티패턴, 최종 산출물 목표다.\n\n",
            suffix,
        ]
    )
    (COURSES_PATH / "day-00.md").write_text("".join(index_parts), encoding="utf-8")

    for day, excerpt in enumerate(slices, start=1):
        navigation = ["[전체 진도](day-00.md)"]
        if day > 1:
            navigation.insert(0, f"[이전 Day](day-{day - 1:02d}.md)")
        if day < 30:
            navigation.append(f"[다음 Day](day-{day + 1:02d}.md)")
        completion_mark = "x" if day in completed_days else " "
        output = (
            f"# Course Day {day:02d} — {titles[day]}\n\n"
            f"{' · '.join(navigation)}\n\n"
            f"- [{completion_mark}] Day {day:02d} 완료\n\n"
            "## 중점 학습\n\n"
            f"- {FOCUS[day]}\n\n"
            "## 과정 내용\n\n"
            "> 아래 과정 내용은 `plan.md`의 해당 Day 구간을 빠짐없이 옮긴 것이다.\n\n"
            f"{excerpt.rstrip()}\n"
        )
        (COURSES_PATH / f"day-{day:02d}.md").write_text(output, encoding="utf-8")

    print(f"Generated day-00.md through day-30.md in {COURSES_PATH}")
    print("Verified: every character from plan.md is covered exactly once by the source slices")


if __name__ == "__main__":
    main()
