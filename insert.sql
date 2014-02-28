-- ,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,
-- ;	author:		Daniel Koprowski		;
-- ;	website:	www.koprowski.it		;
-- ;	mail:		contact@koprowski.it	;
-- ;	date:		28 May 2013				;
-- ,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,

--@ Script inserts sample data in tables.


-- SKRYPT WYPELNIAJACY TABELE:

INSERT INTO adres(miejscowosc,kod_poczt,nr_budynku)
VALUES 
('Gdansk','80-304','5/23'),
('Gdansk','80-344','32c/2'),
('Elblag','43-432','5h/1'),
('Malbork','22-123','4a/4'),
('Sopot','11-123','54/1'),
('Gdynia','14-772','26/4'),
('Sopot','11-123','11c/5'),
('Zakopane','88-999','5');

INSERT INTO budynek(id_adres,nazwa,ilosc_pomieszczen)
VALUES
(1,'Instytut Matematyki',15),
(1,'Instytut Informatyki',25),
(1,'Instytut Fizyki',7),
(2,'Biuro',3),
(3,'Serwerownia',2);

INSERT INTO oprogramowanie(wydawca,wersja,last_update,cena)
VALUES
('Google','Android 4.3','2013-04-30',0.00),
('Google','Android 3.2','2012-12-20',0.00),
('Microsoft','Windows 8 Pro','2013-04-28',834.99),
('Microsoft','Windows 7 Enterprise','2013-04-03',499.99),
('Linux','Ubuntu 12.10','2013-04-03',0.0),
('Oprogramowanie sprzetowe','-','2010-01-01',0.0);
INSERT INTO marka(nazwa)
VALUES
('Samsung'),
('HP'),
('Dell'),
('Toshiba'),
('Brother');

INSERT INTO model(nazwa,typ,premiera,id_oprogramowanie,zuzycie_pradu_kWh, id_marka)
VALUES
('Galaxy S I9000','telefon','2010-09-02',2,0.001,1),
('Galaxy Tab','tablet','2012-04-12',1,0.008,1),
('HP pavilion dv6','laptop','2009-02-15',3,0.1,2),
('Dell inspiron 1510','laptop','2006-10-22',5,0.15,3),
('Komputer PC','PC','2012-09-22',4,0.6,3),
('Komputer PC','PC','2012-11-15',4,0.6,4),
('Komputer PC','PC','2012-09-07',3,0.45,4),
('Brother D195','Drukarka','2011-03-21',6,0.09,5),
('Komputer PC','PC','2013-11-15',4,0.6,1);

INSERT INTO pomieszczenie(id_budynek,nr_pokoju,funkcja,rozmiar_m2)
VALUES
(1,1,'Sala obliczen',55),
(1,2,'Sala statystyki',25),
(2,3,'Sala programistyczna',55),
(2,1,'Sala graficzna',25),
(2,2,'Drukarnia',75),
(4,1,'Biuro',15),
(4,2,'Magazynek',55),
(5,1,'Serwery glowne',60),
(5,2,'Serwer pomocniczy',25);

INSERT INTO stanowisko(nazwa, pensja_godz,min_ilosc_godz)
VALUES
('Mlodszy Programista',29.00,	8),
('Starszy Programista',38.00,	8),
('Grafik',16.00,				8),
('Sekretarka',15.00,			4),
('Konserwator Sprzetu',17.00,	7),
('Statystyk',22.00,				7);
INSERT INTO pracownik(id_pomieszczenie,id_stanowisko,imie,nazwisko,data_zatr,data_ur,ilosc_h_dz)
VALUES
(3,1,'Michal','Michalski',		'2008-05-27','1990-10-10',8),
(3,1,'Grzegorz','Grzegorov',	'2010-03-03','1989-09-10',8),
(3,2,'Mariusz','Koder',			'2011-01-11','1985-04-16',8),
(4,3,'Edyta','Plastyczna',		'2012-10-08','1992-05-10',8),
(6,4,'Grazyna','Papierkowa',	'2010-06-13','1981-11-22',6),
(7,5,'Marek','Dbalski',			'2010-07-24','1980-12-11',12),
(5,3,'Johannes','Guttenberg',	'2013-05-11','1988-04-04',7),
(2,6,'Flawiusz','Tales',		'2011-12-31','1972-10-10',7),
(2,6,'Eugeniusz','Pitagoras',	'2012-11-05','1971-06-19',7),
(8,5,'Fryderyk','Zuse',			'2012-09-01','1987-04-07',12);

INSERT INTO uprawnienia(nazwa)
VALUES
('drukowanie'),
('dostep do bazy danych'),
('konto programisty'),
('konto grafika'),
('dostep do chmury'),
('dostep do glownego repozytorium'),
('firmowy telefon'),
('firmowy laptop'),
('prywatne miejsce na firmowym dysku');

INSERT INTO serwis(id_adres,id_marka,nazwa,telefon,email)
VALUES
(5,3,'Fast laptop repair 3city','111222333','naprawa_laptopow@def.pl'),
(5,5,'Serwis urzadzen elekrycznych','876543211','drukarki@xxx.pl'),
(5,4,'Fast laptop repair 3city','111222333','naprawa_laptopow@def.pl'),
(7,2,'HP Tech support','111222333','hp_tech_support@hp.pl'),
(6,1,'Oficjalny serwis Samsung','333444222','official_samsung@sss.co.uk');



INSERT INTO urzadzenie(id_model,id_pomieszczenie,funkcja,cena,data_prod,wizyt_w_serwis)
VALUES
(1,7,'Kontakt z firma',900.00,'2010-12-10',0),
(1,4,'Kontakt z firma',900.00,'2010-12-10',0),
(1,3,'Kontakt z firma',900.00,'2010-12-10',1),
(2,3,'Kontakt z firma',1600.00,'2012-06-16',0),
(3,3,'Praca, programowanie',3000.00,'2010-01-20',0),
(3,3,'Praca, programowanie',3000.00,'2011-01-20',1),
(7,3,'Programowanie',4000.00,'2013-05-10',0),
(7,6,'Programowanie',4000.00,'2013-05-10',0),
(4,3,'Programowanie',3600.00,'2010-03-10',2),
(5,4,'Projektowanie Grafiki',5000.00,'2013-09-20',0),
(8,5,'Drukowanie',300.00,'2011-04-20',0);

INSERT INTO prac_upr_urzadz(id_pracownik,id_uprawnienia,id_urzadzenie)
VALUES
(1,3,7),(1,6,NULL),(2,3,8),(2,6,NULL),(3,3,5),(3,6,NULL),(3,5,NULL),(3,8,6),
(4,4,10),(4,5,NULL),(4,7,2),(4,9,NULL),(5,2,NULL),(5,1,8),(4,1,8),
(6,7,1),(7,2,NULL),(7,1,8),(8,2,NULL),(9,5,11);

-- 