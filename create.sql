-- ,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,
-- ;	author:		Daniel Koprowski		;
-- ;	website:	www.koprowski.it		;
-- ;	mail:		contact@koprowski.it	;
-- ;	date:		28 May 2013				;
-- ,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,

--@ Scipt creates all tables in database.

-- SKRYPT TWORZACY BAZE DANYCH:
CREATE TABLE adres(
id_adres		INT	IDENTITY(1,1)	PRIMARY KEY,
miejscowosc	CHAR(30),
kod_poczt	CHAR(6),
nr_budynku	CHAR(6)
);

CREATE TABLE oprogramowanie(
id_oprogramowanie INT	IDENTITY(1,1)	PRIMARY KEY,
wydawca		CHAR(30),
wersja		CHAR(45),
last_update	DATE,
cena		MONEY
);

CREATE TABLE marka(
id_marka		INT	IDENTITY(1,1)	PRIMARY KEY,
nazwa			CHAR(40)
);
CREATE TABLE model(
id_model		INT IDENTITY(1,1)	PRIMARY KEY,
nazwa		CHAR(30),
typ			CHAR(30),
premiera	DATE,
id_marka				INT	NOT NULL	REFERENCES
						marka(id_marka) ON UPDATE CASCADE,

id_oprogramowanie		INT	REFERENCES
						oprogramowanie(id_oprogramowanie) ON DELETE SET NULL,
zuzycie_pradu_kWh	REAL
);



CREATE TABLE serwis(
id_serwis	INT	IDENTITY(1,1)	PRIMARY KEY,
id_adres		INT NOT NULL REFERENCES
adres(id_adres) ON UPDATE CASCADE,
id_marka		INT NOT NULL REFERENCES
marka(id_marka) ON UPDATE CASCADE,
nazwa		CHAR(35),
telefon		CHAR(9),
email		CHAR(65)
);

CREATE TABLE budynek(
id_budynek	INT	IDENTITY(1,1)	PRIMARY KEY,
id_adres		INT NOT NULL REFERENCES
adres(id_adres) ON UPDATE CASCADE,
nazwa		CHAR(30),
ilosc_pomieszczen	INT
);

CREATE TABLE pomieszczenie(
id_pomieszczenie INT	IDENTITY(1,1)	PRIMARY KEY,
id_budynek	INT NOT NULL REFERENCES
budynek(id_budynek) ON UPDATE CASCADE,
nr_pokoju	INT NOT NULL,
funkcja		CHAR(50),
rozmiar_m2	INT
);

CREATE TABLE uprawnienia(
id_uprawnienia	INT IDENTITY(1,1)	PRIMARY KEY,
nazwa			CHAR(45)
);

CREATE TABLE stanowisko(
id_stanowisko	INT IDENTITY(1,1)	PRIMARY KEY,
nazwa			CHAR(25),
pensja_godz		MONEY,
min_ilosc_godz	INT,
data_wygasniecia DATE NULL,
stara_pensja	MONEY DEFAULT 77777,
stare_godz		INT
);

CREATE TABLE pracownik(
id_pracownik		INT IDENTITY(1,1)	PRIMARY KEY,
id_pomieszczenie	INT NOT NULL REFERENCES
				pomieszczenie(id_pomieszczenie) ON UPDATE CASCADE,
id_stanowisko	INT NOT NULL REFERENCES
				stanowisko(id_stanowisko) ON UPDATE CASCADE,
imie		CHAR(20),
nazwisko	CHAR(40),
data_zatr	DATE,
data_ur		DATE,
ilosc_h_dz	INT,
premia		MONEY DEFAULT 0
);

											
CREATE TABLE urzadzenie(
id_urzadzenie		INT IDENTITY(1,1)	PRIMARY	KEY,
id_model			INT NOT NULL REFERENCES
					model(id_model) ON UPDATE CASCADE,
id_pomieszczenie		INT NOT NULL REFERENCES
					pomieszczenie(id_pomieszczenie) ON UPDATE CASCADE,
funkcja		CHAR(150),
cena		MONEY,
data_prod	DATE,
wizyt_w_serwis	INT
);

CREATE TABLE nieuzywane(
id_nieuzywane		INT IDENTITY(1,1)	PRIMARY	KEY,
id_model			INT NOT NULL REFERENCES
					model(id_model) ON UPDATE CASCADE,
funkcja		CHAR(150),
data_prod	DATE,
wizyt_w_serwis	INT
);

CREATE TABLE prac_upr_urzadz(
id_uprawnienia		INT NOT NULL REFERENCES
					uprawnienia(id_uprawnienia)
					ON UPDATE CASCADE,
id_pracownik		INT NOT NULL REFERENCES
					pracownik(id_pracownik)
					ON UPDATE CASCADE,
id_urzadzenie		INT REFERENCES
					urzadzenie(id_urzadzenie) 
					ON DELETE SET NULL

);

