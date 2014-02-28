-- ,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,
-- ;	author:		Daniel Koprowski		;
-- ;	website:	www.koprowski.it		;
-- ;	mail:		contact@koprowski.it	;
-- ;	date:		28 May 2013				;
-- ,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,

--@ Views, functions, triggers etc. for my Small-business-database. 


--1) widok 1 ---------------------------------------------------------------------------------------------------------------

-- Pokaz wiek urzadzen (w latach) oraz ile razy przez ten czas dane urzadzenie bylo serwisowane,
-- nie pokazuj urz¹dzeñ które zosta³y kupione w bie¿¹cym roku.
CREATE VIEW wiek_serwis
AS
	SELECT 
		u.id_urzadzenie,m.nazwa, 
		DATEDIFF ( yyyy , u.data_prod , GETDATE() ) as 'Wiek w latach', 
		u.wizyt_w_serwis as 'Wizyt w serwisie'
	FROM dbo.urzadzenie u JOIN dbo.model m
	ON u.id_model=m.id_model
	GROUP BY u.id_urzadzenie, m.nazwa, u.data_prod, u.wizyt_w_serwis
	HAVING DATEDIFF (yyyy , u.data_prod , GETDATE())>=1;

-- przykladowe uzycie: Pokaz tylko sprzet ktory byl serwisowany
SELECT * 
FROM wiek_serwis
WHERE [Wizyt w serwisie]!=0
ORDER BY [Wiek w latach] DESC;

--2) widok 2 ---------------------------------------------------------------------------------------------------------------
-- Widok pokazujacy stanowiska, pensje oraz ilosc pracownikow na stanowiskach technicznych
-- z wy³¹czeniem ksiêgowoœci oraz premi.
-
CREATE VIEW stanowiska
AS
	SELECT s.id_stanowisko, COUNT(p.id_pracownik) AS 'Ilosc pracownikow', s.nazwa, s.pensja_godz, s.min_ilosc_godz
	FROM stanowisko s JOIN pracownik p
	ON s.id_stanowisko=p.id_stanowisko
	GROUP BY s.id_stanowisko, p.id_stanowisko, s.nazwa, s.pensja_godz, s.min_ilosc_godz
	HAVING s.id_stanowisko<>4
--	SELECT COUNT(id_pracownik) AS 'Ogólna liczba pracowników technicznych' FROM pracownik WHERE id_stanowisko<>4 

--Przyklad - pokaz ile dzienie kosztuja wszyscy technicy.
SELECT SUM([Ilosc pracownikow]*pensja_godz*8) AS 'Dzienny koszt etatowych pracowników'
FROM stanowiska
WHERE min_ilosc_godz>6

--3) funkcja 1 ---------------------------------------------------------------------------------------------------------------
-- Funkcja ma pokazywaæ uprawnienia pracownika którego ID trzeba wprowadziæ rêcznie
CREATE FUNCTION uprawn(@id INT)
RETURNS @upr TABLE
(id INT NULL, imie VARCHAR(25) NULL, nazwisko VARCHAR(30) NULL, nazwa VARCHAR(90) NULL) AS
BEGIN
	INSERT @upr(id,imie,nazwisko,nazwa)
	SELECT p.id_pracownik, p.imie, p.nazwisko, u.nazwa
	FROM pracownik p JOIN prac_upr_urzadz puu
	ON p.id_pracownik=puu.id_pracownik
	JOIN uprawnienia u
	ON u.id_uprawnienia=puu.id_uprawnienia
	WHERE p.id_pracownik=@id
	RETURN
END;
GO
-- Przyk³adowe u¿ycie: Poka¿ personalia, uprawnienia oraz ilosc upr. pracownika posiadaj¹cego id = 7
DECLARE @suma INT, @idx INT
SET @suma = 0
SELECT @suma=COUNT(id)	FROM dbo.uprawn(7)	-- tutaj nalezy wstawic id
PRINT 'Ilosc uprawnien ='+STR(@suma)		-- wyswietlane w 'Messages'
SELECT *				FROM dbo.uprawn(7)	-- tutaj nalezy wstawic id


--4) funkcja 2 ---------------------------------------------------------------------------------------------------------------
-- Funkcja zwracaj¹ca adres i dane kontaktowe serwisu przypisanego do danej marki. Nalezy jako parametr podac nazwe marki.

CREATE FUNCTION aserwis(@name VARCHAR(10))
RETURNS @adres TABLE (nazwa VARCHAR(10) NULL, nr_telefonu Varchar(20) NULL, email Varchar(55) NULL, 
miejscowosc VARCHAR(15) NULL,kod_poczt VARCHAR(6) NULL, nr_budynku VARCHAR(10) NULL) AS
BEGIN
	INSERT @adres(nazwa, nr_telefonu, email, miejscowosc,kod_poczt,nr_budynku)
	SELECT m.nazwa, s.telefon, s.email, a.miejscowosc, a.kod_poczt, a.nr_budynku
	FROM marka m 
	JOIN serwis s	ON m.id_marka=s.id_marka 
	JOIN adres a	ON s.id_adres=a.id_adres
	WHERE m.nazwa=@name
	RETURN
END;
GO
-- Uzycie funkcji do wyœwietlenia adresu serwisu Samsunga.
SELECT * FROM dbo.aserwis('samsung');


--5) funkcja 3 ---------------------------------------------------------------------------------------------------------------
-- funkcja pokazuje pod jakim adresem mozna znalezc dane urzadzenie, oraz kto jest za nie odpowiedzialny
CREATE FUNCTION adres_urzadzenia(@x INT)
	RETURNS @dane TABLE 
	(ID INT NULL, Nazwa Varchar(60) NULL, miejscowosc Varchar(25) NULL, Kod_Pocztowy Varchar(6) NULL, Nr_Budynku Varchar(15) NULL, 
	Nr_Pokoju INT NULL, Imie Varchar(20) NULL, Nazwisko Varchar(30) NULL) AS
	BEGIN
		INSERT @dane(ID,Nazwa,miejscowosc,Kod_Pocztowy,Nr_Budynku,Nr_Pokoju,Imie,Nazwisko)
		SELECT u.id_urzadzenie as 'ID', m.nazwa, a.miejscowosc, a.kod_poczt, a.nr_budynku, p.nr_pokoju, pr.imie, pr.nazwisko
		FROM urzadzenie u 
		JOIN pomieszczenie p		ON u.id_pomieszczenie=p.id_pomieszczenie
		JOIN budynek b				ON p.id_budynek=b.id_budynek
		JOIN model m				ON u.id_model=m.id_model
		JOIN adres a				ON b.id_adres=a.id_adres
		JOIN prac_upr_urzadz puu	ON puu.id_urzadzenie=u.id_urzadzenie
		JOIN pracownik pr			ON pr.id_pracownik=puu.id_pracownik
		WHERE u.id_urzadzenie=@x
		ORDER BY u.id_urzadzenie
		RETURN
	END;
GO

-- Przyk³adowe wywo³anie Poka¿ nazwe, miasto oraz osobê odpowiedzialn¹ za sprzêt:
select Nazwa, miejscowosc, Imie, Nazwisko from dbo.adres_urzadzenia(2)


--6) funkcja 4 ---------------------------------------------------------------------------------------------------------------
-- Funkcja wczytuje imie i nazwisko pracownika, a nastêpnie wyœwietla jego pensjê:
CREATE FUNCTION show_pensja(@imie Varchar(12), @nazwisko Varchar(15))
RETURNS MONEY
	BEGIN
	DECLARE @pensja MONEY
	SET @pensja=(SELECT (s.pensja_godz*p.ilosc_h_dz)*20+p.premia
				FROM pracownik p 
				JOIN stanowisko s ON p.id_stanowisko=s.id_stanowisko
				WHERE p.imie=@imie AND p.nazwisko=@nazwisko)
	RETURN @pensja;
	END;
GO
--Poka¿ pensjê pracownika Michal Michalski.
SELECT dbo.show_pensja('Michal','Michalski') AS 'Pensja'


--7) procedura 1 -------------------------------------------------------------------------------------------------------------
-- Procedura która dodaje do bazy danych nowego pracownika:
CREATE PROC nowy_pracownik
	@id_pomieszczenie INT, @id_stanowisko INT,
	@imie VARCHAR(15), @nazwisko VARCHAR(20),
	@data_zatr DATE, @data_ur DATE, @ilosc INT
AS
	IF @ilosc<(SELECT min_ilosc_godz FROM stanowisko 
					WHERE id_stanowisko=@id_stanowisko)
		BEGIN
			PRINT 'B£¥D! Ilosc godzin zbyt ma³a.'
			PRINT '- Pracownika nie dodano do bazy danych.'
		END;
	ELSE
		BEGIN
			INSERT INTO pracownik(id_pomieszczenie,id_stanowisko,
						imie,nazwisko,data_zatr,data_ur,ilosc_h_dz)
			VALUES (@id_pomieszczenie,@id_stanowisko,
					@imie,@nazwisko,@data_zatr,@data_ur,@ilosc)
			PRINT 'Pracownika poprawnie dodano do systemu.'

		END;
GO
--Przyk³adowe u¿ycie 1: Spróbuj dodaæ do bazy danych pracownika,
-- który bêdzie pracowa³ tylko 3 godziny dziennie:
EXEC nowy_pracownik 4, 2, 'Ewelina', 'Gadatliwa', '26-05-2013','07-09-1990', 3;

--Przyk³adowe u¿ycie 2: Dodaj do bazy danych pracownika który pracuje 8 godzin:
EXEC nowy_pracownik 4, 2, 'Arkadiusz', 'Polak', '26-05-2013','07-09-1990', 8;

SELECT * FROM pracownik
WHERE imie='Arkadiusz' AND nazwisko='Polak'


--8) procedura 2 -------------------------------------------------------------------------------------------------------------
-- Procedura przyznaje premie dla pracownikow pracujacych wiecej niz 5, 3 lub 1 lat
-- odpowiednio 750, 400 lub 100 z³. Je¿eli pracownik otrzyma³ inn¹ premiê która
-- przekracza premiê 'lojalnoœciow¹' nie otrzymuje dodatkowego wynagrodzenia.
CREATE PROC premia
AS
BEGIN
	DECLARE @Max INT, @id INT
	SET @Max=(SELECT COUNT(id_pracownik) FROM pracownik)
	SET @id=1
	WHILE @id<=@Max
		BEGIN
			UPDATE pracownik SET premia=750.00
			WHERE DATEDIFF( yyyy , pracownik.data_zatr , GETDATE())>=5 AND premia<750.00 AND id_pracownik=@id
			UPDATE pracownik SET premia=400.00
			WHERE DATEDIFF( yyyy , pracownik.data_zatr , GETDATE())>=3 AND premia<400.00 AND id_pracownik=@id
			UPDATE pracownik SET premia=100.00
			WHERE DATEDIFF( yyyy , pracownik.data_zatr , GETDATE())>=1 AND premia<100.00 AND id_pracownik=@id
			
			DECLARE @imie Varchar(12), @nazwisko Varchar(15), @premia MONEY
			SELECT @imie=imie, @nazwisko=nazwisko, @premia=premia FROM pracownik WHERE id_pracownik=@id	
			PRINT 'Pracownik - '+@imie+' '+@nazwisko+' ma premiê w wysokoœci: '+STR(@premia)+' z³';
			SET @id+=1
		END;
END;
GO
-- Wykonanie procedury 'premia':
EXEC premia
-- TEST DZIALANIA:
SELECT * FROM pracownik


--9) procedura 3 -------------------------------------------------------------------------------------------------------------
-- Procedura pokazuj¹ca jak¹ sk³adkê nale¿y odprowadzaæ od danego pracownika w zaleznosci od pensji:
CREATE PROC podatek
AS
BEGIN
		SELECT p.id_pracownik AS 'ID' ,p.imie, p.nazwisko, p.ilosc_h_dz AS 'Iloœæ h', p.ilosc_h_dz*s.pensja_godz*20+p.premia AS 'Wyp³ata',
			(CASE	WHEN (p.ilosc_h_dz*s.pensja_godz*20+p.premia)<=2000 THEN '0.08'
					WHEN (p.ilosc_h_dz*s.pensja_godz*20+p.premia)>2000 AND (p.ilosc_h_dz*s.pensja_godz*20+p.premia)<=3500 THEN '0.23'
					WHEN (p.ilosc_h_dz*s.pensja_godz*20+p.premia)>3500 THEN '0.35'
					ELSE 'Brak danych'
			END) AS Podatek
		FROM pracownik p 
		JOIN stanowisko s ON p.id_stanowisko=s.id_stanowisko
END;
-- Wykonanie procedury 'podatek':
EXEC podatek


--10) procedura 4 ------------------------------------------------------------------------------------------------------------
-- Procedura pokazuje osobn¹ kolumnê obok nazwy sprzêtu oraz oprogramowania z informacj¹,
-- czy dane oprogramowanie jest darmowe, tanie czy drogie. Mo¿na wybraæ aby procedura wyœwietli³a
-- wszyskie mo¿liwoœci (all) lub tylko jedn¹ tj. (tanie),(drogie) lub (darmowe).
CREATE PROC koszt_opr
	@jakie Varchar(7)
AS
BEGIN
	IF @jakie='all'
		BEGIN
			SELECT ma.nazwa, o.wersja,
				(CASE	WHEN o.cena=0.00 THEN 'Darmowe'
						WHEN o.cena BETWEEN 0.00 AND 500.00 THEN 'Tanie'
						ELSE 'Drogie' END) AS Koszt_Opr
			FROM model m 
			JOIN oprogramowanie o ON m.id_oprogramowanie=o.id_oprogramowanie
			JOIN marka ma ON m.id_marka=ma.id_marka
		END;
	ELSE 
		BEGIN
			IF EXISTS
					(SELECT ma.nazwa, o.wersja,
						(CASE	WHEN o.cena=0.00 THEN 'Darmowe'
						WHEN o.cena BETWEEN 0.00 AND 500.00 THEN 'Tanie'
						ELSE 'Drogie' END) AS Koszt_Opr
						FROM model m 
						JOIN oprogramowanie o ON m.id_oprogramowanie=o.id_oprogramowanie
						JOIN marka ma ON m.id_marka=ma.id_marka
						WHERE (CASE	WHEN o.cena=0.00 THEN 'Darmowe'
						WHEN o.cena BETWEEN 0.00 AND 500.00 THEN 'Tanie'
						ELSE 'Drogie' END)=@jakie 
					)	
				BEGIN
					SELECT ma.nazwa, o.wersja,
						(CASE	WHEN o.cena=0.00 THEN 'Darmowe'
								WHEN o.cena BETWEEN 0.00 AND 500.00 THEN 'Tanie'
								ELSE 'Drogie' END) AS Koszt_Opr
					FROM model m 
					JOIN oprogramowanie o ON m.id_oprogramowanie=o.id_oprogramowanie
					JOIN marka ma ON m.id_marka=ma.id_marka

					WHERE (CASE	WHEN o.cena=0.00 THEN 'Darmowe'
								WHEN o.cena BETWEEN 0.00 AND 500.00 THEN 'Tanie'
								ELSE 'Drogie' END)=@jakie 
				END;
			ELSE	
				BEGIN
					Print 'B£¥D! Jedyne dozwolone opcje do wpisania to:'
					Print '- "Tanie"'
					Print '- "Drogie"'
					Print '- "Darmowe"'
					Print '- "all" - (pokaz wszystkie powyzsze opcje)'
				END;
		END;
END;

-- Przyk³adowe wywo³ania tej procedury:
	EXEC koszt_opr 'Darmowe'
	EXEC koszt_opr 'Tanie'
	EXEC koszt_opr 'Œredniodrogawe' -- Powinien wyœwietliæ siê komunikat w 'Messages'
	EXEC koszt_opr 'all'
	

--11) wyzwalacz 1 ------------------------------------------------------------------------------------------------------------
-- Wyzwalacz oddaje b³¹d je¿eli pracownik nie ma ukoñczonych 16 lat
-- lub data zatrudnienia jest wczeœniejsza ni¿ urodzenia. (Zabezpieczenie przed roztargnion¹ ksiêgow¹)
CREATE TRIGGER prac_insert ON pracownik
AFTER INSERT AS
BEGIN
	DECLARE @blad INT
	IF EXISTS(SELECT data_ur, data_zatr FROM INSERTED WHERE data_ur>=data_zatr) SET @blad=1
	IF @blad=1
	  BEGIN
		  RAISERROR('B£¥D! Pracownik nie mo¿e zostaæ zatrudniony przed swoimi narodzinami!',10,20)
		  ROLLBACK
	  END
	  
	DECLARE @wiek INT
	SELECT @wiek=(DATEDIFF( yyyy , data_ur , GETDATE())) FROM INSERTED WHERE (DATEDIFF( yyyy , data_ur , GETDATE()))<16
	IF @wiek<16
	  BEGIN
	  	RAISERROR('Pracownik nie ukoñczy³ 16 roku ¿ycia!',10,20)
	  	PRINT 'Nasza firma nie mo¿e przyj¹æ pracownika w wieku'+STR(@wiek)+' lat'
		ROLLBACK	
	  END
END
GO

-- Przyk³ad 1: Próba wprowadzenia jedenastolatka jako pracownika:
INSERT INTO pracownik(imie,nazwisko,data_ur,id_pomieszczenie,id_stanowisko)
VALUES ('Staszek','M³ody','2002-09-07',2,2);

-- Przyk³ad 2: Próba dodania do tabeli pracownika który pracuje w firmie od 1991 r. pomimo tego ¿e urodzi³ siê w 2013 r.:
INSERT INTO pracownik(imie,nazwisko,data_ur,data_zatr,id_stanowisko,id_pomieszczenie)
VALUES ('Kamil','Nienarodzony','2013-05-27','1991-12-17',2,2);

--Sprawdzenie:
SELECT * FROM pracownik;


--12) wyzwalacz 2 ------------------------------------------------------------------------------------------------------------
-- W przypadku usuniêcia sprzêtu wyzwalacz przenosi dane urz¹dzenia do 'magazynu nieuzywanych urzadzen' 
--i drukuje potwierdzenie, jezeli nie udalo sie usunac to nie przenosi do archiwum lecz drukuje komunikat.

CREATE TRIGGER urzadz_archiw ON urzadzenie
AFTER DELETE
AS
	BEGIN
		IF EXISTS(SELECT * FROM deleted)
		BEGIN
			PRINT 'Usuniêto pomyœlnie'
			DECLARE kursor1 CURSOR
			FOR (		SELECT id_model, funkcja,data_prod,wizyt_w_serwis
						FROM deleted
				)
			DECLARE @model INT, @funkcja Varchar(25),@data_prod DATE, @serw INT
			OPEN kursor1
			FETCH NEXT FROM kursor1 INTO @model, @funkcja, @data_prod, @serw
			WHILE @@FETCH_STATUS=0
				BEGIN
				INSERT INTO nieuzywane VALUES(@model, @funkcja, @data_prod, @serw)
				FETCH NEXT FROM kursor1 INTO @model, @funkcja, @data_prod, @serw
				END
			CLOSE kursor1
			DEALLOCATE kursor1
		END
		ELSE
			PRINT 'Nie usuniêto'

	END
GO

--Przyk³adowe u¿ycie: Usuñ urz¹dzenie o id=2
	DELETE FROM urzadzenie
	WHERE id_urzadzenie=2
-- Sprawdzenie dzia³ania:
SELECT * FROM nieuzywane
SELECT * FROM urzadzenie


--13) wyzwalacz 3 ------------------------------------------------------------------------------------------------------------
-- Wyzwalacz który zamiast usun¹æ z bazy danych stanowisko, 
-- archiwizuje je w tej samej tabeli w kolumnach które normalnie s¹ nieu¿ywane i maj¹ wartoœæ NULL.
-- W przypadku gdy stanowisko zosta³o ju¿ wczeœniej usuniête np, przez kogoœ innego, wyzwalacz wydrukuje specjaln¹ informacjê.
CREATE TRIGGER del_stan ON stanowisko
INSTEAD OF DELETE
AS
	DECLARE @id INT, @name Varchar(20)
	SET @id=(SELECT id_stanowisko FROM deleted)
	SET @name=(SELECT nazwa FROM deleted)

	BEGIN
		IF (77777.00)=(SELECT stara_pensja FROM stanowisko WHERE id_stanowisko=@id)
		  BEGIN
		  	PRINT 'Stanowisko '+@name+'zosta³o zarchiwizowane.'
			UPDATE stanowisko SET stara_pensja=pensja_godz		WHERE id_stanowisko=@id
			UPDATE stanowisko SET stare_godz=min_ilosc_godz		WHERE id_stanowisko=@id
			UPDATE stanowisko SET data_wygasniecia = GETDATE()	WHERE id_stanowisko=@id
			UPDATE stanowisko SET pensja_godz = 0				WHERE id_stanowisko=@id
			UPDATE stanowisko SET min_ilosc_godz = 0			WHERE id_stanowisko=@id
		  END
		 ELSE
		  BEGIN
			PRINT 'Operacja nie powiod³a siê poniewa¿:'
			PRINT 'Stanowisko '+@name+'zosta³o zarchiwizowane wczeœniej.'
		  END
	END
GO
-- Usuwanie stanowiska Konserwator Sprzêtu
DELETE FROM stanowisko WHERE nazwa='Konserwator Sprzetu'
-- Próba ponownego usuniêcia tego samego stanowiska
DELETE FROM stanowisko WHERE nazwa='Konserwator Sprzetu'
-- Sprawdzenie dzialania
select * from stanowisko

--14) wyzwalacz 4 ------------------------------------------------------------------------------------------------------------
-- Wyzwalacz pokazuje dodane oprogramowanie lub usuniête oprogramowanie.
CREATE TRIGGER czy_update ON oprogramowanie
AFTER INSERT, DELETE
AS
BEGIN
	IF EXISTS(SELECT id_oprogramowanie FROM inserted)
		BEGIN
			DECLARE kursor2 CURSOR
			FOR (SELECT id_oprogramowanie, wydawca,wersja,last_update, cena FROM inserted)
			
			DECLARE @id INT, @wydawca Varchar(25),@wersja Varchar(25), @last DATE, @cena MONEY
			OPEN kursor2
			FETCH NEXT FROM kursor2 INTO @id, @wydawca, @wersja, @last, @cena
			WHILE @@FETCH_STATUS=0
				BEGIN
				PRINT 'Dodano nowe oprogramowanie: '
				PRINT @wydawca
				PRINT @wersja
				FETCH NEXT FROM kursor2 INTO @id, @wydawca, @wersja, @last, @cena
				END
			CLOSE kursor2
			DEALLOCATE kursor2
		END
	IF EXISTS(SELECT * FROM deleted)
		BEGIN
			DECLARE kursor3 CURSOR
			FOR (SELECT id_oprogramowanie, wydawca,wersja,last_update, cena FROM deleted)
			DECLARE @id2 INT, @wydawca2 Varchar(25),@wersja2 Varchar(25), @last2 DATE, @cena2 MONEY
			OPEN kursor3
			FETCH NEXT FROM kursor3 INTO @id2, @wydawca2, @wersja2, @last2, @cena2
			WHILE @@FETCH_STATUS=0
				BEGIN
				PRINT 'Usuniêto nastêpuj¹ce oprogramowanie: '
				PRINT @wydawca2
				PRINT @wersja2
				FETCH NEXT FROM kursor3 INTO @id2, @wydawca2, @wersja2, @last2, @cena2
				END
			CLOSE kursor3
			DEALLOCATE kursor3
		END
		ELSE 
			PRINT 'B³¹d! Nie ma takiego oprogramowania.'
END
GO


-- Dodanie do tabeli dwóch rekordów z oprogramowaniem.
INSERT INTO oprogramowanie	(wydawca,wersja,last_update,cena) 
					VALUES	('Microsoft','SQL Server 2012',GETDATE(),550.00),
							('Firefox','OS',GETDATE(),0.00)

-- Usuniêcie oprogramowania z id=2
DELETE FROM oprogramowanie WHERE id_oprogramowanie=2

-- Sprawdzenie:
select * from oprogramowanie


--15) pivot 1 ----------------------------------------------------------------------------------------------------------------
-- Zaznaznacz w tabeli (liczba 1) ile godzin pracuje dana osoba.

SELECT imie, nazwisko, [6],[7],[8],[12]
FROM (select p.id_stanowisko, p.ilosc_h_dz, s.pensja_godz, p.imie, p.nazwisko
 from stanowisko s join pracownik p 
ON p.id_stanowisko=s.id_stanowisko) zrodlo
PIVOT(
COUNT(id_stanowisko)
FOR [ilosc_h_dz] IN ([6],[7],[8],[12])
) as ile_godzin;



--16) pivot 2 ----------------------------------------------------------------------------------------------------------------
-- ile pr¹du na godzinê  zu¿ywa dana marka. Obliczenia s¹ podstawie informacji z ³¹czenia tabel model oraz urz¹dzenie.

SELECT ROUND(SUM([1]),6) AS Samsung,ROUND(SUM([2]),6) AS HP,ROUND(SUM([3]),6) AS Dell,
ROUND(SUM([4]),6) AS Toshiba,ROUND(SUM([5]),6)AS Brother 
FROM (select m.id_model, m.id_marka, m.zuzycie_pradu_kWh
from model m join urzadzenie u
ON u.id_model=m.id_model) zrodlo
PIVOT(
SUM(zuzycie_pradu_kWh)
FOR [id_marka] IN ([1],[2],[3],[4],[5])
) as ile_pradu;


------------------------------------------------------------------------------------------------------------------------------

