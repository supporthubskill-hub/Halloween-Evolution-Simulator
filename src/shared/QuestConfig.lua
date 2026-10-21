-- Quest data only. Completion and rewards require server validation.
return {
 {Id="WELCOME", Name="Bienvenido al Pueblo Maldito", Giver="Luna", MinLevel=1, Objective={Type="Talk",Target="Luna",Count=1}, Reward={XP=150,Candy=25}},
 {Id="PUMPKINS", Name="Calabazas perdidas", Giver="Jack", MinLevel=3, Objective={Type="Collect",Target="Pumpkin",Count=5}, Reward={XP=150,Candy=50}},
 {Id="CEMETERY", Name="Secretos del cementerio", Giver="Bones", MinLevel=25, Objective={Type="Discover",Target="Cemetery",Count=1}, Reward={XP=200,Candy=75}},,
 {Id="SOUL_ENTRY", Name="Cruza el bosque", Giver="Boo", MinLevel=51, Objective={Type="Discover",Target="SoulForest",Count=1}, Reward={XP=350,Candy=100}},
 {Id="SOUL_HUNTER", Name="Espíritus inquietos", Giver="Bones", MinLevel=51, Objective={Type="Defeat",Target="SoulForest",Count=5}, Reward={XP=550,Candy=175}},
 {Id="SOUL_BOSS", Name="Guardián de las Almas", Giver="Luna", MinLevel=75, Objective={Type="Defeat",Target="SoulBoss",Count=1}, Reward={XP=1200,Candy=300}}
}
