local L = LANG.GetLanguageTableReference("en")

--Role Language Strings
L[BAKER.name] = "Baker"
L[BAKER.defaultTeam] = "Team Horsemen"
L["hilite_win_" .. BAKER.defaultTeam] = "TEAM HORSEMEN WON"
L["win_" .. BAKER.defaultTeam] = "The Baker has won!"
L["info_popup_" .. BAKER.name] = [[You can spawn bread with your Baking gadget. If enough people eat your bread, turn into the Famine.]]
L["body_found_" .. BAKER.abbr] = "They were a Baker!"
L["search_role_" .. BAKER.abbr] = "This person was a Baker!"
L["ev_win_" .. BAKER.defaultTeam] = "The Baker has won!"
L["target_" .. BAKER.name] = "Baker"
L["ttt2_desc_" .. BAKER.name] = [[The Baker can spawn bread for people to eat, if enough bread is eaten he transforms into the Famine.]]