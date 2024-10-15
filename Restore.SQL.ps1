
# Import SqlServer Module
if (Get-Module -Name sqlps) { Remove-Module sqlps }
Import-Module -Name SqlServer

Try
{
    # Set a variable equal to the name of the SQL Instance
    $sqlServerInstaneName = "SRV19-PRIMARY\SQLEXPRESS"

    # Create an object to reference the SQL Server instance
    $sqlServerObject = New-Object -TypeName Microsoft.SqlServer.Management.Smo.Server -ArgumentList $sqlServerInstaneName

    # Set a variable equal to the name of the Database
    $databaseName = 'ClientDB'

    # Create an object to reference the Database
    $databaseObject = New-Object -TypeName Microsoft.SqlServer.Smo.Database -ArgumentList $sqlServerObject, $databaseName

        if ($databaseObject)
            {
                $sqlServerObject.KillDatabase($databaseName)
                $sqlServerObject.DropDatabase($databaseName)
                Write-Host "The ClientDB already existed and has been deleted"
                # Call the create method on the database object to create it
                $databaseObject.Create()
                Write-Host -foregroundColor Cyan "The ClientDB has been created"
            }
        else
            {
                # Call the create method on the database object to create it
                $databaseObject.Create()
                Write-Host -foregroundColor Cyan "The ClientDB has been created"
            }

    $tableName = 'Client_A_Contacts'
    
    CREATE TABLE [$databaseName].[$databaseObject].[$tableName]
    (
        First_Name varchar(100),
        Last_Name varchar(100),
        City varchar (50),
        County varchar(50),
        Zip varchar(20),
        OfficePhone varchar(15),
        MobilePhone varchar(15)
    )

    $Insert = "INSERT INTO [$($tableName)] (first_name, last_name, city, county, zip, officePhone, mobilePhone)"

    Write-Host -foregroundColor Cyan "The table $($tableName) has been created"

    $NewCustomerLeads = Import-Csv $PSScriptRoot\NewCustomerLeads.Csv

    ForEach($NewLead in $NewCustomerLeads)
    {
        $Values = "VALUES ( `
                        '$($NewLead.first_name)', `
                        '$($NewLead.last_name)', `
                        '$($NewLead.city)', `
                        '$($NewLead.county)', `
                        '$($NewLead.zip)', `
                        '$($NewLead.officePhone)', `
                        '$($NewLead.mobilePhone)')"

        $query = $Insert + $Values
        Invoke-Sqlcmd -Database $databaseName -ServerInstance $sqlServerInstaneName -Query $query
    }

    Invoke-Sqlcmd -Database ClientDB -ServerInstance
    }
Catch
{
$_
}

