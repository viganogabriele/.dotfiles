-- Keep window opacity stable when focus changes, independent of Ruixen's glass profile.
hl.config({ decoration = { active_opacity = 1.0, inactive_opacity = 1.0 } })
o.window(".*", { opacity = "1.0 1.0" })
