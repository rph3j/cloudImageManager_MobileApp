# NASA Gallery
## Przeznaczenie: 
Aplikacja umozliwia przglądania i wyszukiwanie obrazów i dotyczących ich dabych z bazy Landsat.
JEst to uproszczona i ograniczona wersjia bardziej rozbódowanej wersji web'owej.
## Implemętacja 
Zdjęcia są pobierana do pamięci za pośrednictwem Cloud Function która zwraca listę przeskalowanych zdięć.
Szczegułowe dane dortyczące poszczegulnych zdięć są trzymane w Firebase Storage.
W momęcie w którym użytkownik zechce je wyświtlać są one zaciągane za pomocą odwołania do konkretnego pliku w kolekcji zawierającego dane danego zdięcia.
