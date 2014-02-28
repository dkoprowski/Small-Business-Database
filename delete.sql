-- ,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,
-- ;	author:		Daniel Koprowski		;
-- ;	website:	www.koprowski.it		;
-- ;	mail:		contact@koprowski.it	;
-- ;	date:		28 May 2013				;
-- ,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,

--@ Script deletes all functions and tables from database.
-- SKRYPT DO USUNIECIA BAZY DANYCH:

-- Usuwanie projekt 3:
-- usuniecie widoku 1
IF (OBJECT_ID('wiek_serwis') IS NOT NULL)
DROP VIEW wiek_serwis
-- usuniecie widoku 2
IF (OBJECT_ID('stanowiska') IS NOT NULL)
DROP VIEW stanowiska
-- Usuniecie funkcji 1
IF (OBJECT_ID('uprawn') IS NOT NULL)
DROP FUNCTION uprawn;
-- Usuniecie funkcji 2
IF (OBJECT_ID('aserwis') IS NOT NULL)
DROP FUNCTION aserwis;
-- Usuniecie funkcji 3
IF (OBJECT_ID('adres_urzadzenia') IS NOT NULL)
DROP FUNCTION adres_urzadzenia;
-- Usuniecie funkcji 4
IF (OBJECT_ID('show_pensja') IS NOT NULL)
DROP FUNCTION show_pensja;
-- Usuniecie procedury 1
IF (OBJECT_ID('nowy_pracownik') IS NOT NULL)
DROP PROC nowy_pracownik;
-- Usuniecie procedury 2
IF (OBJECT_ID('premia') IS NOT NULL)
DROP PROC premia;
-- Usuniecie procedury 3
IF (OBJECT_ID('podatek') IS NOT NULL)
DROP PROC podatek;
-- Usuniecie procedury 4
IF (OBJECT_ID('koszt_opr') IS NOT NULL)
DROP PROC koszt_opr;
-- Usuniecie wyzwalacza 1
IF (OBJECT_ID('prac_insert') IS NOT NULL)
DROP TRIGGER prac_insert;
-- Usuniecie wyzwalacza 2
IF (OBJECT_ID('urzadz_archiw') IS NOT NULL)
DROP TRIGGER urzadz_archiw;
-- Usuniecie wyzwalacza 3
IF (OBJECT_ID('del_stan') IS NOT NULL)
DROP TRIGGER del_stan;
-- Usuniecie wyzwalacza 3
IF (OBJECT_ID('czy_update') IS NOT NULL)
DROP TRIGGER czy_update;



-- Usuwanie tabel:
DROP TABLE prac_upr_urzadz;
DROP TABLE nieuzywane;
DROP TABLE urzadzenie;
DROP TABLE serwis;
DROP TABLE model;
DROP TABLE marka;
DROP TABLE oprogramowanie;
DROP TABLE pracownik;
DROP TABLE pomieszczenie;
DROP TABLE budynek;
DROP TABLE uprawnienia;
DROP TABLE stanowisko;
DROP TABLE adres;
