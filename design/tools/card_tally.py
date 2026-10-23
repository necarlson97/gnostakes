T = """
Hollowhead|key+
God-Struck Fool|gen
Knower of True Names|elem
Lockpicking Archon|keyreq
Famed Freemason|str kind color
Incorruptable Judge|elem iE tooth-
Plate-Plundering Deacon|sQ
Pious Parishioner|key+
Doomed Romantic|tooth-
Promising Pugilist|kind str num color key+ tooth-
Bruised Boxer|sAny
Hard-Weathered Quarryman|sA
Pillar-top Hermet|antiinc
Self-Sacrificant|sAny key+
Post-Fate Oblate|color
Toothless Grinner|sQ
Binger|str
Purger|tooth-
Pact Proctor|sQ tooth-
Wrathful Sovern|sF key+
Faustian Scholar|tooth-
Tumorous Magi|tooth-
Silent Companion|sQ
Marooned Wanderer|sQ
Insane Incandescent|keyreq
Reservoir of Sunshine|sQ
Wailing Confessor|elem tooth-
Voiceless Accused|gen
Carrier of the Droplet|sW
Primed Pomologist|gen iE iQ
Charitable Ciderist|elem key+
Alembic Servitor|iE iW
Burn-Scarred Glasswright|sE key+
Bezoar Seeker|iE sE
Sadistic Shepherd|sE key+
Reeking Husk|iE iA
Discarded Follower|sAny key+
Hard-Tack Baker|kind
Perennial Pruner|gen iE
Haphazard Herbalist|kind sE key- tooth+
Venemous Vessel|iE
Sinuous Acolyte|kind
Oathbreaker|sE
Oathkeeper|kind gen iQ
Solifactory Smith|elem num iE iQ
Brawny Striker|sE sQ tooth- key+
Hopeful Sower|kind iE
The Tallyman|sAny iQ
Spagyric Physician|kind iE iW iF iA
Lead Drinker|iW sW tooth-
Bacchus Host|elem key+
Noble Ghost-Writer|iW sW
Pilfered Penname|str key+
Gin-Soaked Gutter-Sweeper|iW sW
Dependable Tosspot|sW key+
Hollow-Bellied Saint|iW
Pot-Licking Friar|sW key+
Enthralling Eulogist|iW
Paid Mourner|sW key+
Twofold Widow|str
Lethean Elder|sW gen
Worm-Brained Absinthard|str
Fairy-Chaser|iW tooth+
Hairshirt Bearer|str sA
Fleabitten Penitent|str gen key+ tooth-
Epicurean Gourmand|elem iQ
Gout-Ridden Glutton|iW key+
Nubile Nymph|str key+
Broken Martyr|tooth- tooth+
Promethean Pyro|iW iE iF
Doomed Pandorite|elem key+
Branded Protege|iF iQ sF
Expendable Assistant|elem key+
Academic Artillerist|iF
Craven Cannoneer|sF key+
Fire-Drake|iF sF
Powder Miller|sF key+
Fingerless Sapper|iF sF
Powder Monkey|sF key+
Short-Lived Brute|iE
Timeless Warrior-Poet|iF sF
Witch Drowner|iQ
Corrupted Inquisitor|key+
Furnace Keeper|iF
Shunned Executioner|iQ
Bloodstained Recluse|elem key+
Covert Degenerate|sW
Closeted Apostate|iF
Strawman|sA tooth-
Epileptic Metallurgist|iA iF
Lithiated Assayer|iF key+
Vivisectionist|key+ key-
Glass-Eyed Alchemist|gen iA sA
Sun-Blinded Prismist|elem key+
Tongueless Traitor|iA sW
Candid Jester|elem key+
Persecuted Paranoiac|iA
Psychotic Christ|sA key+
Flayed Flagellant|iA sA
Lash-Blessed Monk|sA key+
Bodysnatcher|iA sA
Overworked Gravedigger|sA key+
Mummy Grinder|color
Intrepid Archaeologist|iE sE
Reliquary Larcenist|color iA
Finger-Bone Forager|sA
Footnoted Scholar|iF
Pedantic Pedagogue|elem tooth-opp
Shuar Headshrinker|elem
Ayahuascite|gen iA key+
Mercurial Monomaniac|key+
Haunted Mind|elem tooth- tooth-opp
Driveling Chemist|elem num
Feverish Scribe|key+
Back-Alley Butcher|key+ tooth-
Dubious Demonologist|iA sA
"""
from collections import defaultdict
d=defaultdict(list)
for l in T.strip().splitlines():
    n,t=l.split('|')
    for x in t.split(): d[x].append(n)
for k in sorted(d): print(f"{k:9} {len(d[k]):3}  {', '.join(d[k])}")
