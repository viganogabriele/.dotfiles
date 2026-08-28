-- Workspaces 1-5 always exist because the bar widget (gabriele.workspaces)
-- hardcodes them. Hyprland itself destroys any other empty, unfocused
-- workspace, so 6-10 would flash into the bar and vanish again as soon as
-- you left them. Mark them persistent so they stick around like 1-5 do.
for workspace = 6, 10 do
  hl.workspace_rule({ workspace = tostring(workspace), persistent = true })
end
