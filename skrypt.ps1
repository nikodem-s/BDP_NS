$Data = (Get-Date).ToString('MMddyyyy')
$log_path = "D:\Bazydanych\lab8\PROCESSED\automat2_$Data.log"
function CHECKER
{
    if($? -eq 1)
    {
         $data2=(Get-Date).ToString('MMddyyyyHHmmss')
        switch($args[0])
        {
            1{Add-Content -Path $log_path -Value "Downloading file - SUCESS $data2"}
            2{Add-Content -Path $log_path -Value "Uzipping file - SUCESS $data2"}
            3{Add-Content -Path $log_path -Value "Creating table in Database - SUCESS $data2"}
            4{Add-Content -Path $log_path -Value "Adding to table in Database - SUCESS $data2"}
            5{Add-Content -Path $log_path -Value "Moving file to PROCESSED directory - SUCESS $data2"}
            6{Add-Content -Path $log_path -Value "Sending email - SUCESS $data2"}
            7{Add-Content -Path $log_path -Value "Query Usage - SUCESS $data2"}
            8{Add-Content -Path $log_path -Value "Export to CSV - SUCESS $data2"}
            9{Add-Content -Path $log_path -Value "Archiving file - SUCESS $data2"}
            10{Add-Content -Path $log_path -Value "Import CSV - SUCESS $data2"}

        }
    
    }    
    elseif($? -eq 0)
    {
         $data2=(Get-Date).ToString('MMddyyyyHHmmss')
        switch($args[0])
        {
            1{Add-Content -Path $log_path -Value "Downloading file - FAILURE $data2"}
            2{Add-Content -Path $log_path -Value "Uzipping file - FAILURE $data2"}
            3{Add-Content -Path $log_path -Value "Creating table in Database - FAILURE $data2"}
            4{Add-Content -Path $log_path -Value "Adding to table in Database - FAILURE $data2"}
            5{Add-Content -Path $log_path -Value "Moving file to PROCESSED directory - FAILURE $data2"}
            6{Add-Content -Path $log_path -Value "Sending email - FAILURE $data2"}
            7{Add-Content -Path $log_path -Value "Query Usage - FAILURE $data2"}
            8{Add-Content -Path $log_path -Value "Export to CSV - FAILURE $data2"}
            9{Add-Content -Path $log_path -Value "Archiving file - FAILURE $data2"}
            10{Add-Content -Path $log_path -Value "Import CSV - FAILURE $data2"}

        }
    }   
}

function SentEmail
{
    if($args[0] -eq 1)
    {
        $From = "nikosala27@gmail.com"
        $To = "bogusiasal@onet.pl"
        $Subject = "CUSTOMERS LOAD - $Data"
        $Body = "Liczba wierszy w pliku załadowanym z internetu - $linesofDOC
        Liczba poprawnych wierszy po oczyszczeniu $liczba_oryginalych
        Liczba zduplikowanych wierszy $liczba_zduplikwanych
        Liczba dodanych do bazy danych - $liczba_w"
        $SMTPServer = "smtp.gmail.com"
        $SMTPPort = "587"
        Send-MailMessage -From $From -to $To -Subject $Subject `
        -Body $Body -SmtpServer $SMTPServer -port $SMTPPort -UseSsl ` -Credential (Get-Credential) 
        CHECKER 6
    }
    if($args[0] -eq 2)
    {
        $From = "nikosala27@gmail.com"
        $To = "bogusiasal@onet.pl"
        $Subject = "CUSTOMERS LOAD - $Data"
        $Body = "Liczba rekordow $NumberOfLines
        Data ostatniej modyfikacji $LastWriteTime"
        $SMTPServer = "smtp.gmail.com"
        $SMTPPort = "587"
        $Attachment = $path
        Send-MailMessage -From $From -to $To -Subject $Subject `
        -Body $Body -SmtpServer $SMTPServer -port $SMTPPort -UseSsl ` -Credential (Get-Credential) -Attachments $Attachment
        CHECKER 6


    }

}
$index = "401529"
$archw = "agh"
#Pobieranie pliku z internetu
$link = 'https://home.agh.edu.pl/~wsarlej/Customers_Nov2021.zip'
$destination = 'D:\Bazydanych\lab8\zip'
Invoke-RestMethod -Uri $link -OutFile $destination\Customers_Nov2021.zip
CHECKER 1
#rozpakowyanie pliku
$destination_unzipped = 'D:\Bazydanych\lab8\zip\Customers_Nov2021.zip'
Expand-7Zip -ArchiveFileName $destination_unzipped -Password $archw -TargetPath D:\Bazydanych\lab8
CHECKER 2
#Sciezki
#Importowanie plików csv
$newCustomers = Import-Csv -Path D:\Bazydanych\lab8\Customers_Nov2021.csv | Where-Object{ ($_.PSObject.Properties | ForEach-Object {$_.Value}) -ne $null}
$oldCustomers = Import-Csv -Path D:\Bazydanych\lab8\Customers_old.csv | Where-Object{ ($_.PSObject.Properties | ForEach-Object {$_.Value}) -ne $null}
CHECKER 10
#etap porownywania plikow csv
$Compare = Compare-Object  $newCustomers $oldCustomers -Property first_name,last_name,email,lat,long -IncludeEqual
$Compare
#zadeklarowanie pustej tablicy 
$Array = @() #dla obiektow zlych
$Array2 = @()
Foreach($R in $Compare)
{
    #znaczek "<=" przy oznacza, ze obieekt jest unikatowy dla tego po leewej stronie w porowaniu, czyli u mnie $newCustomers
    #znaczek "==" oznacza natomaist, ze obikety powtarzaja sie w obu plikach
    If( $R.sideindicator -eq "==")
    {
        $Linia = [pscustomobject][ordered]@{
        first_name = $R.first_name
        last_name = $R.last_name
        email = $R.email
        lat = $R.lat
        long = $R.long
        }
    $Array += $Linia
     }
     If( $R.sideindicator -eq "<=")
    {
        $Linia2 = [pscustomobject][ordered]@{
        first_name = $R.first_name
        last_name = $R.last_name
        email = $R.email
        lat = $R.lat
        long = $R.long
        }
    $Array2 += $Linia2 #Array2.Length to bedzie liczba wierszy po czyszczeniu, Array.Length - liczba wierszy odrzuconych
     }
        
}
$Array | Export-Csv -Path D:\Bazydanych\lab8\Customers_Nov2021_bad_$Data.csv -NoTypeInformation
#export przetworzonego juz pliku naszego, bez pustych linii oraz bez powtarzajacych sie z OldCustomers
$Array2 | Export-Csv -Path "D:\Bazydanych\lab8\PROCESSED\Customers_$Data.csv" -NoTypeInformation
CHECKER 8 

Set-Location 'C:\Program Files\PostgreSQL\14\bin\'
#pobranie mojego hasla i nazwy uzytkowniak do postgresa
$User="postgres"
$Password = "admin"
$env:PGPASSWORD = $Password
$Database="LAB8"
$Server="PostgreSQL 14"
$Port="5432"
$table = "CUSTOMERS_$index"

#stworzenie tej tabelki za pomocą psql
psql -U postgres -d $Database -w -c "CREATE TABLE IF NOT EXISTS $table (first_name varchar(27), last_name varchar(27), email varchar(40), lat REAL, long REAL)"
CHECKER 3
#import ze zweryfikowanego już pliku XML:
$przed = psql -U postgres -d $Database -w -c 'SELECT COUNT(*) FROM customers_401529'
psql -U postgres -d $Database -w -c 'COPY customers_401529(first_name,last_name,email,lat,long) FROM ''D:\Bazydanych\lab8\PROCESSED\Customers_01052022.csv'' DELIMITER '',''
CSV HEADER;'
CHECKER 4
$po = psql -U postgres -d $Database -w -c 'SELECT COUNT(*) FROM CUSTOMERS_401529'
#---------------------
#Dodane wiersze do tabeli, porownuje ich ilosc przed kopiowaniem, a po kopiwaniu
$liczba_w = $po.GetValue(2) - $przed.GetValue(2)
$liczba_zduplikwanych = $Array.Length 
$liczba_oryginalych = (Get-Content -Path D:\Bazydanych\lab8\Customers_Nov2021.csv | Select-Object -Skip 1).Length 
#Stworzenie tabelki BEST CUSTOMERS
$table2 ="BEST_CUSTOMERS$index"
psql -U postgres -d $Database -w -c "CREATE TABLE IF NOT EXISTS $table2 (first_name varchar(27), last_name varchar(27), email varchar(40), lat REAL, long REAL)"
CHECKER 3
#---------------------------------
#zapytanie by wsadzic tylko 
psql -U postgres -d $Database -w -f 'D:\Bazydanych\lab8\sql.txt'
CHECKER 4
#eksport do pliku csv
psql -U postgres -d $Database -w -c 'COPY (SELECT * FROM BEST_CUSTOMERS401529) TO ''D:\Bazydanych\lab8\BEST_CUSTOMERS_401529.csv'' WITH CSV HEADER'
CHECKER 8
#nastepnie kompresaj do csv
$compress = @{
  Path = "D:\Bazydanych\lab8\BEST_CUSTOMERS_401529.csv"
  CompressionLevel = "Fastest"
  DestinationPath = "D:\Bazydanych\lab8\zip\BEST_CUSTOMERS_401529.zip"
}
Compress-Archive @compress
CHECKER 9
#mail2 rzeczy
$LastWriteTime = (Get-item D:\Bazydanych\lab8\BEST_CUSTOMERS_401529.csv).LastWriteTime.ToString('dd/MM/yyyy HH:mm')
$NumberOfLines = (Get-Content D:\Bazydanych\lab8\BEST_CUSTOMERS_401529.csv | Select-Object -Skip 1).Length
$path = "D:\Bazydanych\lab8\zip\BEST_CUSTOMERS_401529.zip"

#--------------------------
#Wysyłanie maila
SentEmail 1
SentEmail 2

