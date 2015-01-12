clc;clear all;close all;

% Az objektum megõrzi az állapotokat. Ha az identifikációt már futtattuk
% egyszer, akkor pl. a másodlagos szûrõ értékeire minden további 
% függvényhívás esetén "emlékezni fog".
fs = 8000;
steps = 20000;

noise = [
    PointSource([0 10], bandnoise(1000, steps, fs), fs)
    PointSource([0 -10], bandnoise(1000, steps, fs), fs)
    ];

% W: elsõdleges szûrõ
% S: másodlagos szûrõ
% T: referenciaszûrõ
% D_: adott szûrõhöz tartozó késleltetés
%          N_W   N_S  D_S  N_T  D_T
anc = ELMS(1000, 500, 200, 5000, 250, fs);

% Megadjuk a referencia-, hiba- és beavatkozópozíciókat. Ezek mindaddig
% érvényesek, amíg a Set[...]Positions függvény ismételt meghívásával nem
% módosítjuk õket.
anc.SetReferencePositions([0 2; 0 -2]);
anc.SetErrorPositions([0 0]);
anc.SetActuatorPositions([0.2 0]);
anc.AddSources(noise);

% Az alábbi függvények bármikor és bármilyen sorrendben meghívhatók, ahogy
% a DSP-n is bármikor futtathatjuk az egyes részfeladatokat. Nem minden
% sorrendben van természetesen értelme futtatni õket. A parancsok a
% konzolból is kiadhatók.
anc.SetOption('mu_reference_filter_identification', 2e-1);
anc.IdentifyReferenceFilter(steps);

% Nem tetszik a kapott eredmény, újra futtatni szeretném a függvényt kisebb
% bátorsági tényezõvel.

% Törlöm a korábbi eredményeket
anc.ResetReferenceFilter();

% Csökkentem a bátorsági tényezõt
anc.SetOption('mu_reference_filter_identification', 5e-2);

% Ismételten futtatom a referenciaszûrõk identifikálását
anc.IdentifyReferenceFilter(steps);

% Most már elégedett vagyok az eredménnyel, a zajcsökkentés elõtt még
% identifikálni kell a másodlagos utakat
anc.Identify(80000);

% Jöhet a zajcsökkentés
anc.Simulate(steps);

% Elszállt a rendszer, törlöm az együtthatókat, csökkentem a bátorsági
% tényezõt és újra futtatom a zajcsökkentést. Identifikálni,
% referenciaszûrõt meghatározni nem kell megint.
anc.ResetPrimaryFilter();
anc.SetOption('mu', 1e-2);
anc.Simulate(steps);

% Még nem állt be teljesen az elnyomás, futtatom a szimulációt további
% simlength ütemig. A szûrõt most nem resetelem, tehát nem 0-áról, hanem az
% elõbb elért szintrõl fognak indulni az együtthatók.
anc.Simulate(steps);

% Megj.: korlátozás, hogy a Simulate és IdentifyReferenceFilter függvények
% egyszerre legfeljebb akkora idõtartamig futtathatók, ahány mintát az
% AddSources függvényben megadott zajforrások tartalmaznak.

% Használható függvény továbbá
anc.ResetSecondaryFilter();
