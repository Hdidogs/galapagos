// 1. Création des Îles (Utilisation de MERGE pour éviter les doublons)
MERGE (bal:Island {island_code: "BAL"}) SET bal.name = "Baltra", bal.location = point({srid:4326, x:-90.25, y:-0.45}), bal.area_km2 = 27
MERGE (bar:Island {island_code: "BAR"}) SET bar.name = "Bartolomé", bar.location = point({srid:4326, x:-90.548611, y:-0.285}), bar.area_km2 = 1.2
MERGE (dar:Island {island_code: "DAR"}) SET dar.name = "Darwin", dar.location = point({srid:4326, x:-92.003288, y:1.678286}), dar.area_km2 = 1.1
MERGE (esp:Island {island_code: "ESP"}) SET esp.name = "Espanola", esp.location = point({srid:4326, x:-89.683333, y:-1.366667}), esp.area_km2 = 61
MERGE (fer:Island {island_code: "FER"}) SET fer.name = "Fernandina", fer.location = point({srid:4326, x:-91.55, y:-0.37}), fer.area_km2 = 642
MERGE (flo:Island {island_code: "FLO"}) SET flo.name = "Floreana", flo.location = point({srid:4326, x:-90.434167, y:-1.2975}), flo.area_km2 = 173
MERGE (gen:Island {island_code: "GEN"}) SET gen.name = "Genovesa", gen.location = point({srid:4326, x:-89.958, y:0.32}), gen.area_km2 = 14
MERGE (isa:Island {island_code: "ISA"}) SET isa.name = "Isabela", isa.location = point({srid:4326, x:-91.150818, y:-0.496438}), isa.area_km2 = 4588
MERGE (mar:Island {island_code: "MAR"}) SET mar.name = "Marchena", mar.location = point({srid:4326, x:-90.5, y:0.35}), mar.area_km2 = 130
MERGE (sey:Island {island_code: "SEY"}) SET sey.name = "Seymour Nord", sey.location = point({srid:4326, x:-90.2841, y:-0.3915}), sey.area_km2 = 1.9
MERGE (pin:Island {island_code: "PIN"}) SET pin.name = "Pinta", pin.location = point({srid:4326, x:-90.75, y:0.58}), pin.area_km2 = 60
MERGE (piz:Island {island_code: "PIZ"}) SET piz.name = "Pinzon", piz.location = point({srid:4326, x:-90.665703, y:-0.612648}), piz.area_km2 = 18
MERGE (rab:Island {island_code: "RAB"}) SET rab.name = "Rabida", rab.location = point({srid:4326, x:-90.709133, y:-0.414087}), rab.area_km2 = 4.9
MERGE (sanc:Island {island_code: "SC"}) SET sanc.name = "San Cristobal", sanc.location = point({srid:4326, x:-89.5, y:-0.88}), sanc.area_km2 = 558
MERGE (sac:Island {island_code: "SAC"}) SET sac.name = "Santa Cruz", sac.location = point({srid:4326, x:-90.33, y:-0.62}), sac.area_km2 = 986
MERGE (saf:Island {island_code: "SAF"}) SET saf.name = "Santa Fe", saf.location = point({srid:4326, x:-90.07, y:-0.806}), saf.area_km2 = 24
MERGE (sat:Island {island_code: "SAT"}) SET sat.name = "Santiago", sat.location = point({srid:4326, x:-90.77, y:-0.22}), sat.area_km2 = 585
MERGE (pla:Island {island_code: "PLA"}) SET pla.name = "Plaza", pla.location = point({srid:4326, x:-90.1625, y:-0.5818}), pla.area_km2 = 0.22
MERGE (wol:Island {island_code: "WOL"}) SET wol.name = "Wolf", wol.location = point({srid:4326, x:-91.815319, y:1.381611}), wol.area_km2 = 1.3

// 2. Création des Zones Hydravion et lien avec les Îles
// On utilise WITH pour passer les variables ou on refait des MATCH propres

// Gardner Bay (Espanola)
MERGE (z1:HydroplaneZone {zone_code: "ZONE_ES_GB"})
SET z1.name = "Gardner Bay Marine Dock", z1.location = point({srid:4326, x:-89.62, y:-1.38}), z1.type = "Zone de ravitaillement"
WITH z1
MATCH (i:Island {island_code: "ESP"})
MERGE (i)-[:HAS_ZONE]->(z1);

// Punta Espinosa (Fernandina)
MERGE (z2:HydroplaneZone {zone_code: "ZONE_FE_PE"})
SET z2.name = "Punta Espinosa Hydro Point", z2.location = point({srid:4326, x:-91.545, y:-0.2755}), z2.type = "Point de ravitaillement isolé"
WITH z2
MATCH (i:Island {island_code: "FER"})
MERGE (i)-[:HAS_ZONE]->(z2);

// Post Office Bay (Floreana)
MERGE (z3:HydroplaneZone {zone_code: "ZONE_FL_POB"})
SET z3.name = "Post Office Bay Water Landing", z3.location = point({srid:4326, x:-90.445, y:-1.237}), z3.type = "Point historique + livraisons"
WITH z3
MATCH (i:Island {island_code: "FLO"})
MERGE (i)-[:HAS_ZONE]->(z3);

// Darwin Bay (Genovesa)
MERGE (z4:HydroplaneZone {zone_code: "ZONE_GE_DB"})
SET z4.name = "Darwin Bay Float Stop", z4.location = point({srid:4326, x:-89.96, y:0.316}), z4.type = "Site scientifique isolé"
WITH z4
MATCH (i:Island {island_code: "GEN"})
MERGE (i)-[:HAS_ZONE]->(z4);

// Tagus Cove (Isabela)
MERGE (z5:HydroplaneZone {zone_code: "ZONE_IS_TC"})
SET z5.name = "Tagus Cove Aquatic Station", z5.location = point({srid:4326, x:-91.36, y:-0.275}), z5.type = "Station scientifique"
WITH z5
MATCH (i:Island {island_code: "ISA"})
MERGE (i)-[:HAS_ZONE]->(z5);

// Puerto Villamil (Isabela)
MERGE (z6:HydroplaneZone {zone_code: "ZONE_IS_PV"})
SET z6.name = "Puerto Villamil Sea-Air Dock", z6.location = point({srid:4326, x:-90.965, y:-0.9485}), z6.type = "Port majeur d'Isabela"
WITH z6
MATCH (i:Island {island_code: "ISA"})
MERGE (i)-[:HAS_ZONE]->(z6);

// Wreck Bay (San Cristobal)
MERGE (z7:HydroplaneZone {zone_code: "ZONE_SC_WB"})
SET z7.name = "Wreck Bay Hydro Platform", z7.location = point({srid:4326, x:-89.6155, y:-0.8955}), z7.type = "Plateforme de chargement"
WITH z7
MATCH (i:Island {island_code: "SC"})
MERGE (i)-[:HAS_ZONE]->(z7);

// Puerto Baquerizo (San Cristobal)
MERGE (z8:HydroplaneZone {zone_code: "ZONE_SC_PB"})
SET z8.name = "Puerto Baquerizo Air Dock", z8.location = point({srid:4326, x:-89.61, y:-0.905}), z8.type = "Base principale / Entrepôt"
WITH z8
MATCH (i:Island {island_code: "SC"})
MERGE (i)-[:HAS_ZONE]->(z8);

// Turtle Cove (Santa Cruz)
MERGE (z9:HydroplaneZone {zone_code: "ZONE_SCZ_TC"})
SET z9.name = "Turtle Cove Float Hub", z9.location = point({srid:4326, x:-90.3802, y:-0.5885}), z9.type = "Petit port logistique"
WITH z9
MATCH (i:Island {island_code: "SAC"})
MERGE (i)-[:HAS_ZONE]->(z9);

// Academy Bay (Santa Cruz)
MERGE (z10:HydroplaneZone {zone_code: "ZONE_SCZ_AB"})
SET z10.name = "Academy Bay Air Point", z10.location = point({srid:4326, x:-90.31, y:-0.747}), z10.type = "Port scientifique principal"
WITH z10
MATCH (i:Island {island_code: "SAC"})
MERGE (i)-[:HAS_ZONE]->(z10);


// 3. Création des Routes entre Zones (Relation [:ROUTE] au lieu de [:None])
// J'ai regroupé les liens car votre script créait des liens "tout vers tout"
MATCH (pb:HydroplaneZone {zone_code: "ZONE_SC_PB"})
MATCH (db:HydroplaneZone {zone_code: "ZONE_GE_DB"})
MERGE (pb)-[:ROUTE]->(db);

MATCH (pb:HydroplaneZone {zone_code: "ZONE_SC_PB"})
MATCH (gb:HydroplaneZone {zone_code: "ZONE_ES_GB"})
MERGE (pb)-[:ROUTE]->(gb);

MATCH (pb:HydroplaneZone {zone_code: "ZONE_SC_PB"})
MATCH (pob:HydroplaneZone {zone_code: "ZONE_FL_POB"})
MERGE (pb)-[:ROUTE]->(pob);

MATCH (pb:HydroplaneZone {zone_code: "ZONE_SC_PB"})
MATCH (pe:HydroplaneZone {zone_code: "ZONE_FE_PE"})
MERGE (pb)-[:ROUTE]->(pe);

MATCH (pb:HydroplaneZone {zone_code: "ZONE_SC_PB"})
MATCH (tc:HydroplaneZone {zone_code: "ZONE_IS_TC"})
MERGE (pb)-[:ROUTE]->(tc);

MATCH (pb:HydroplaneZone {zone_code: "ZONE_SC_PB"})
MATCH (pv:HydroplaneZone {zone_code: "ZONE_IS_PV"})
MERGE (pb)-[:ROUTE]->(pv);

MATCH (pb:HydroplaneZone {zone_code: "ZONE_SC_PB"})
MATCH (tcf:HydroplaneZone {zone_code: "ZONE_SCZ_TC"})
MERGE (pb)-[:ROUTE]->(tcf);

MATCH (pb:HydroplaneZone {zone_code: "ZONE_SC_PB"})
MATCH (ab:HydroplaneZone {zone_code: "ZONE_SCZ_AB"})
MERGE (pb)-[:ROUTE]->(ab);

MATCH (pb:HydroplaneZone {zone_code: "ZONE_SC_PB"})
MATCH (wb:HydroplaneZone {zone_code: "ZONE_SC_WB"})
MERGE (pb)-[:ROUTE]->(wb);

// Liens depuis Wreck Bay
MATCH (wb:HydroplaneZone {zone_code: "ZONE_SC_WB"})
MATCH (db:HydroplaneZone {zone_code: "ZONE_GE_DB"})
MERGE (wb)-[:ROUTE]->(db);

MATCH (wb:HydroplaneZone {zone_code: "ZONE_SC_WB"})
MATCH (gb:HydroplaneZone {zone_code: "ZONE_ES_GB"})
MERGE (wb)-[:ROUTE]->(gb);

MATCH (wb:HydroplaneZone {zone_code: "ZONE_SC_WB"})
MATCH (pob:HydroplaneZone {zone_code: "ZONE_FL_POB"})
MERGE (wb)-[:ROUTE]->(pob);

MATCH (wb:HydroplaneZone {zone_code: "ZONE_SC_WB"})
MATCH (pe:HydroplaneZone {zone_code: "ZONE_FE_PE"})
MERGE (wb)-[:ROUTE]->(pe);

MATCH (wb:HydroplaneZone {zone_code: "ZONE_SC_WB"})
MATCH (tc:HydroplaneZone {zone_code: "ZONE_IS_TC"})
MERGE (wb)-[:ROUTE]->(tc);

MATCH (wb:HydroplaneZone {zone_code: "ZONE_SC_WB"})
MATCH (pv:HydroplaneZone {zone_code: "ZONE_IS_PV"})
MERGE (wb)-[:ROUTE]->(pv);

MATCH (wb:HydroplaneZone {zone_code: "ZONE_SC_WB"})
MATCH (tcf:HydroplaneZone {zone_code: "ZONE_SCZ_TC"})
MERGE (wb)-[:ROUTE]->(tcf);

MATCH (wb:HydroplaneZone {zone_code: "ZONE_SC_WB"})
MATCH (ab:HydroplaneZone {zone_code: "ZONE_SCZ_AB"})
MERGE (wb)-[:ROUTE]->(ab);


// 4. Création des Hydravions (Seaplanes)
MERGE (sp1:Seaplane {id: "SP001"}) SET sp1.model = "Cessna 208", sp1.fuel = 25.0, sp1.status = "docked", sp1.capacity = 100
MERGE (sp2:Seaplane {id: "SP002"}) SET sp2.model = "DHC-2 Beaver", sp2.fuel = 30.5, sp2.status = "in_flight", sp2.capacity = 120
MERGE (sp3:Seaplane {id: "SP003"}) SET sp3.model = "Icon A5", sp3.fuel = 22.0, sp3.status = "docked", sp3.capacity = 80
MERGE (sp4:Seaplane {id: "SP004"}) SET sp4.model = "Seawind 3000", sp4.fuel = 28.5, sp4.status = "maintenance", sp4.capacity = 150
MERGE (sp5:Seaplane {id: "SP005"}) SET sp5.model = "Lake Buccaneer", sp5.fuel = 26.0, sp5.status = "docked", sp5.capacity = 110
MERGE (sp6:Seaplane {id: "SP006"}) SET sp6.model = "Cessna 208", sp6.fuel = 24.5, sp6.status = "docked", sp6.capacity = 95
MERGE (sp7:Seaplane {id: "SP007"}) SET sp7.model = "DHC-2 Beaver", sp7.fuel = 31.0, sp7.status = "in_flight", sp7.capacity = 130
MERGE (sp8:Seaplane {id: "SP008"}) SET sp8.model = "Icon A5", sp8.fuel = 23.0, sp8.status = "docked", sp8.capacity = 85
MERGE (sp9:Seaplane {id: "SP009"}) SET sp9.model = "Seawind 3000", sp9.fuel = 29.0, sp9.status = "maintenance", sp9.capacity = 140
MERGE (sp10:Seaplane {id: "SP010"}) SET sp10.model = "Lake Buccaneer", sp10.fuel = 27.0, sp10.status = "docked", sp10.capacity = 115
MERGE (sp11:Seaplane {id: "SP011"}) SET sp11.model = "Cessna 208", sp11.fuel = 25.0, sp11.status = "in_flight", sp11.capacity = 100
MERGE (sp12:Seaplane {id: "SP012"}) SET sp12.model = "DHC-2 Beaver", sp12.fuel = 30.0, sp12.status = "docked", sp12.capacity = 120
MERGE (sp13:Seaplane {id: "SP013"}) SET sp13.model = "Icon A5", sp13.fuel = 23.5, sp13.status = "docked", sp13.capacity = 90
MERGE (sp14:Seaplane {id: "SP014"}) SET sp14.model = "Seawind 3000", sp14.fuel = 28.0, sp14.status = "in_flight", sp14.capacity = 150
MERGE (sp15:Seaplane {id: "SP015"}) SET sp15.model = "Lake Buccaneer", sp15.fuel = 26.5, sp15.status = "docked", sp15.capacity = 110

MATCH (i:Island)
WHERE i.area_km2 IS NOT NULL
SET i.area_km2 = toFloat(i.area_km2)
RETURN i.name, i.area_km2

MATCH (s:Seaplane {id:"SP001"})
SET s.location = point({srid:4326, x:-90.82, y:0.12});

MATCH (s:Seaplane {id:"SP002"})
SET s.location = point({srid:4326, x:-91.34, y:-0.22});

MATCH (s:Seaplane {id:"SP003"})
SET s.location = point({srid:4326, x:-90.11, y:-0.95});

MATCH (s:Seaplane {id:"SP004"})
SET s.location = point({srid:4326, x:-91.78, y:0.64});

MATCH (s:Seaplane {id:"SP005"})
SET s.location = point({srid:4326, x:-90.52, y:0.41});

MATCH (s:Seaplane {id:"SP006"})
SET s.location = point({srid:4326, x:-89.92, y:-0.74});

MATCH (s:Seaplane {id:"SP007"})
SET s.location = point({srid:4326, x:-91.02, y:1.12});

MATCH (s:Seaplane {id:"SP008"})
SET s.location = point({srid:4326, x:-90.67, y:-1.14});

MATCH (s:Seaplane {id:"SP009"})
SET s.location = point({srid:4326, x:-90.38, y:0.26});

MATCH (s:Seaplane {id:"SP010"})
SET s.location = point({srid:4326, x:-91.48, y:0.05});

MATCH (n:Seaplane {id:"SP009"})
SET n.location = point({srid:4326, x:-90.5, y:0.36});

MATCH (n:Seaplane {id:"SP004"})
SET n.location = point({srid:4326, x:-91.55, y:-0.30});

MATCH (n:Seaplane {id:"SP004"})
SET n.location = point({srid:4326, x:-90.5, y:0.34});
MATCH (n:Seaplane {id:"SP001"}) SET n.status = "in_flight" ;
MATCH (n:Seaplane {id:"SP008"}) SET n.status = "in_flight" ;
MATCH (n:Seaplane {id:"SP003"}) SET n.status = "in_flight" ;
MATCH (n:Seaplane {id:"SP006"}) SET n.status = "in_flight" ;
MATCH (n:Seaplane {id:"SP002"}) SET n.status = "docked" ;