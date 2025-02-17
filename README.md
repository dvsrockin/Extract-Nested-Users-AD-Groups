# Powershell Based Nested Users Extract from AD groups

What does the script do? 
Suppose you have nested AD groups and want to extract all the AD group members from that group
sometimes Get-ADgroupmember -recurve doesnt work, due to cross domain memberships as domain fecthing fails
Also command like Get-ADgroup -identity "Groupname" | Select-object Members doesnt help as it cannot list nested group members 
hence this Powershell Script helps in Extracted all Nested Users in AD groups till level 9

the usage syntax is as follow: 
# When using : Nested_Groups_Extract.ps1 
Browse to the path where script is saved and exeucted below commnd
Note: You can enter a few custom properties that you like and use the same to extract the data
   
    .\NestedGroups_Extract.ps1  -groupname "Ad-Group-Name" `
                                -Domain "corp.us.com" `
                                -Properties "SamAccountName,CanonicalName,mail,UserPrincipalName" `
                                -filepath "C:\temp\ADgroup-extract.csv"

# When using : GUI-Nested_Group-Extract.ps1
Execute the file with "Run in Powershell" and enter the details in Double qoutes ("")  for Groupname, domain, Properties and Filepath

![image](https://github.com/user-attachments/assets/b31fc061-f0eb-4260-9865-c07ddaee13ef)

You can fill the GUI based form as follows: 

![image](https://github.com/user-attachments/assets/4326a893-20c1-41fc-9594-36ec9ad55463)
