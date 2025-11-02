L = LANG.GetLanguageTableReference("en")

L[BEEKEEPER.name] = "Beekeeper"
L["info_popup_" .. BEEKEEPER.name] = [[You are a Beekeeper! You deal no direct damage and instead must summon bees and other monsters to kill the innocents!]]
L["body_found_" .. BEEKEEPER.abbr] = "They were a Beekeeper!"
L["search_role_" .. BEEKEEPER.abbr] = "This person was a Beekeeper!"
L["target_" .. BEEKEEPER.name] = "Beekeeper"
L["ttt2_desc_" .. BEEKEEPER.name] = [[The Beekeeper is a Traitor role that cannot deal any damage directly, but can repeatedly summon bees and other monsters to indirectly kill their opponents.]]

L.label_ttt2_beekeeper_damage_mult = "Beekeeper Damage Multiplier"
