# Animation specification

| Storyboard | Trigger | Duration | Easing | Message |
| --- | --- | --- | --- | --- |
| Set completion | Set write succeeds | 220 ms | Curves.easeOutCubic | Set 1 saved - 1 of 2 sets |
| Workout completion | Finish transaction succeeds | 320 ms | Curves.easeInOut | Workout recorded - 2 of 2 sets |
| Plan expansion | User taps Expand details | 180 ms | Curves.easeInOutCubic | Plan details expanded |

The three PNG pages show before/during/after frames. Timings are design targets. Use explicit accessible controls; no animation performs database writes. No success feedback before persistence. Rebuilds/relaunches must not replay saved-success celebrations. Reduced motion presents the same final state immediately. Expand is reversible through Collapse; Undo changes saved set progress before the UI reflects the result. Completion summarizes user records without performance/health claims.
