
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

        if ($sqlServerObject)
            {
                Invoke-Sqlcmd -ServerInstance $sqlServerInstaneName -Query "DROP DATABASE [$databaseName]"
                Write-Host "The ClientDB already has been deleted"
                Invoke-Sqlcmd -ServerInstance $sqlServerInstaneName -Query "CREATE DATABASE [$databaseName]"
                Write-Host -foregroundColor Cyan "The ClientDB has been created"
            }
        else
            {
                # Use the CREATE DATABASE query on the database object to create it
                Invoke-Sqlcmd -ServerInstance $sqlServerInstaneName -Query "CREATE DATABASE [$databaseName]"
                Write-Host -foregroundColor Cyan "The ClientDB has been created"
            }

    # Create a variable to hold the table name
    $tableName = 'ClientData'
    
    # Create the table 
    Invoke-Sqlcmd -ServerInstance $sqlServerInstaneName -Database $databaseName -InputFile $PSScriptRoot\CreateTable_ClientData.sql

    $Insert = "INSERT INTO [$($tableName)] (first_name, last_name, city, county, zip, officePhone, mobilePhone)"

    Write-Host -foregroundColor Cyan "The table $($tableName) has been created"

    # Create variable to hold the file import
    $NewClientData = Import-Csv $PSScriptRoot\NewClientData.csv

    ForEach($NewClient in $NewClientData)
    {
        $Values = "VALUES ( `
                        '$($NewClient.first_name)', `
                        '$($NewClient.last_name)', `
                        '$($NewClient.city)', `
                        '$($NewClient.county)', `
                        '$($NewClient.zip)', `
                        '$($NewClient.officePhone)', `
                        '$($NewClient.mobilePhone)')"

        $query = $Insert + $Values
        Invoke-Sqlcmd -Database $databaseName -ServerInstance $sqlServerInstaneName -Query $query
    }

    Invoke-Sqlcmd -Database ClientDB -ServerInstance .\SQLEXPRESS -Query 'SELECT * FROM dbo.ClientData' > .\SqlResults.txt
    }
Catch
{
$_
}
