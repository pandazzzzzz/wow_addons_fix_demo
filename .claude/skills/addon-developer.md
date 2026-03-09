# WoW Addon Developer

A specialized agent for analyzing, modifying, and debugging World of Warcraft addon code in the `addons/` directory.

## When to Use

Use this skill when:
- Analyzing existing addon code in the `addons/` folder
- Modifying or refactoring addon code
- Debugging errors found in `addons/error.txt`
- Creating new features for existing addons

## Core Knowledge

### Wow API Context

This agent works with WoW Retail (12.x) addons. Key namespaces:
- `C_QuestLog`, `C_Map`, `C_Timer`, `C_SuperTrack`, `C_CVar`
- `C_TaskQuest`, `C_WorldMap`, `C_MapExplorationInfo`

### File Patterns

- `.toc` - Addon metadata and file declarations
- `.lua` - Lua source code
- `.xml` - FrameXML definitions
- `libs/` - Third-party libraries (LibStub, Ace3, etc.)

### Code Patterns

**Event Handling**
```lua
frame:RegisterEvent("EVENT_NAME")
frame:SetScript("OnEvent", function(self, event, ...)
    -- handler
end)
```

**Mixin Pattern**
```lua
MyMixin = {}
function MyMixin:OnLoad() end
function MyMixin:OnEvent(event, ...) end
```

**Frame Pool**
```lua
local pool = CreateFramePool("BUTTON", parent, template, resetFunc)
local frame = pool:Acquire()
pool:Release(frame)
```

## Task Workflow

### Code Analysis
1. Identify addon structure from `.toc` file
2. Trace event flow and data dependencies
3. Identify API usage patterns
4. Check for performance issues (OnUpdate allocations, uncached globals)

### Code Modification
1. Read existing code before modifying
2. Follow existing code style and patterns
3. Use local variable caching for performance
4. Handle combat lockdown appropriately
5. Provide `/reload` testing instructions

### Error Handling
1. Parse `addons/error.txt` for stack traces
2. Identify file and line number
3. Analyze root cause
4. Suggest fix with code
5. Verify fix doesn't break other functionality

## Constraints

- Never modify `.git` directories inside addon folders
- Preserve backward compatibility where possible
- Test changes with `/reload` after modification
- Check combat lockdown before security-sensitive operations

## Common Issues

| Issue | Cause | Fix |
|-------|-------|-----|
| Nil error on load | Missing SavedVariables init | Add nil check or TOC entry |
| Taint error | Modifying secure frames | Use hooksecurefunc or avoid |
| Memory leak | OnUpdate creating tables | Use frame pool or reusable table |
| Event spam | No throttling | Add debounce/throttle logic |
