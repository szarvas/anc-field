clc;clear all;close all;

% Az objektum meg�rzi az �llapotokat. Ha az identifik�ci�t m�r futtattuk
% egyszer, akkor pl. a m�sodlagos sz�r� �rt�keire minden tov�bbi 
% f�ggv�nyh�v�s eset�n "eml�kezni fog".
fs = 8000;
steps = 20000;

noise = [
    PointSource([0 10], bandnoise(1000, steps, fs), fs)
    PointSource([0 -10], bandnoise(1000, steps, fs), fs)
    ];

% W: els�dleges sz�r�
% S: m�sodlagos sz�r�
% T: referenciasz�r�
% D_: adott sz�r�h�z tartoz� k�sleltet�s
%          N_W   N_S  D_S  N_T  D_T
anc = ELMS(1000, 500, 200, 5000, 250, fs);

% Megadjuk a referencia-, hiba- �s beavatkoz�poz�ci�kat. Ezek mindaddig
% �rv�nyesek, am�g a Set[...]Positions f�ggv�ny ism�telt megh�v�s�val nem
% m�dos�tjuk �ket.
anc.SetReferencePositions([0 2; 0 -2]);
anc.SetErrorPositions([0 0]);
anc.SetActuatorPositions([0.2 0]);
anc.AddSources(noise);

% Az al�bbi f�ggv�nyek b�rmikor �s b�rmilyen sorrendben megh�vhat�k, ahogy
% a DSP-n is b�rmikor futtathatjuk az egyes r�szfeladatokat. Nem minden
% sorrendben van term�szetesen �rtelme futtatni �ket. A parancsok a
% konzolb�l is kiadhat�k.
anc.SetOption('mu_reference_filter_identification', 2e-1);
anc.IdentifyReferenceFilter(steps);

% Nem tetszik a kapott eredm�ny, �jra futtatni szeretn�m a f�ggv�nyt kisebb
% b�tors�gi t�nyez�vel.

% T�rl�m a kor�bbi eredm�nyeket
anc.ResetReferenceFilter();

% Cs�kkentem a b�tors�gi t�nyez�t
anc.SetOption('mu_reference_filter_identification', 5e-2);

% Ism�telten futtatom a referenciasz�r�k identifik�l�s�t
anc.IdentifyReferenceFilter(steps);

% Most m�r el�gedett vagyok az eredm�nnyel, a zajcs�kkent�s el�tt m�g
% identifik�lni kell a m�sodlagos utakat
anc.Identify(80000);

% J�het a zajcs�kkent�s
anc.Simulate(steps);

% Elsz�llt a rendszer, t�rl�m az egy�tthat�kat, cs�kkentem a b�tors�gi
% t�nyez�t �s �jra futtatom a zajcs�kkent�st. Identifik�lni,
% referenciasz�r�t meghat�rozni nem kell megint.
anc.ResetPrimaryFilter();
anc.SetOption('mu', 1e-2);
anc.Simulate(steps);

% M�g nem �llt be teljesen az elnyom�s, futtatom a szimul�ci�t tov�bbi
% simlength �temig. A sz�r�t most nem resetelem, teh�t nem 0-�r�l, hanem az
% el�bb el�rt szintr�l fognak indulni az egy�tthat�k.
anc.Simulate(steps);

% Megj.: korl�toz�s, hogy a Simulate �s IdentifyReferenceFilter f�ggv�nyek
% egyszerre legfeljebb akkora id�tartamig futtathat�k, ah�ny mint�t az
% AddSources f�ggv�nyben megadott zajforr�sok tartalmaznak.

% Haszn�lhat� f�ggv�ny tov�bb�
anc.ResetSecondaryFilter();
