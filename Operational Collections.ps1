#############################################################################
# Edited by : Jorge E. Covarrubias
# LinkedIn  : https://www.linkedin.com/in/jorge-e-covarrubias-973217141/
#
# Author  : Benoit Lecours 
# Website : www.SystemCenterDudes.com
# Twitter : @scdudes
#
# Version   : 1.2
# Created   : 10/12/2017
# Modified  :
# 10/12/2017  - Restructed to add collections one by one and add if not present
#             - Fixed spacing issues after * and from in Collection 7 and 70
#             - Changed Collection4  to 1706 instead of 1702
#             - Changed Collection52 to include all 1602 client updates. 8355.1000 to 8355.1%
#             - Changed Collection53 to include all 1606 client updates. 8412.100% to 8412.1%
#             - Changed Collection68 to include all 1610 client updates. 8458.100% to 8458.1%
#             - Changed Collection69 to include all 1702 client updates. 8498.100% to 8498.1%
#             - Changed Collection72 to include all 1706 client updates. 8540.100% to 8540.1%
# 10/16/2017  - Reconfigured limiting collections in each Collection.
# 10/18/2017  - Fixed several collections that had LimittingCollection instead of LimitCollection.
#             - Fixed Move-CMObject and changed the Output color to green when new collection is created..
# 
# 
# Original Edits before my modification
# Version : 2.8
# Created : 2014/07/17
# Modified : 
# 2014/08/14 - Added Collection 34,35,36
# 2014/09/23 - Changed collection 4 to CU3 instead of CU2
# 2015/01/30 - Improve Android collection
# 2015/02/03 - Changed collection 4 to CU4 instead of CU3
# 2015/05/06 - Changed collection 4 to CU5 instead of CU4
# 2015/05/06 - Changed collection 4 to SP1 instead of CU5
#            - Add collections 37 to 42
# 2015/08/04 - Add collection 43,44
#            - Changed collection 4 to SP1 CU1 instead of SP1
# 2015/08/06 - Change collection 22 query
# 2015/08/12 - Added Windows 10 - Collection 45
# 2015/11/10 - Changed collection 4 to SP1 CU2 instead of CU1, Add collection 46
# 2015/12/04 - Changed collection 4 to SCCM 1511 instead of CU2, Add collection 47
# 2016/02/16 - Add collection 48 and 49. Complete Revamp of Collections naming. Comment added on all collections
# 2016/03/03 - Add collection 51
# 2016/03/14 - Add collection 52
# 2016/03/15 - Added Error handling and better output
# 2016/08/08 - Add collection 53-56. Modification to collection 4,31,32,33
# 2016/09/14 - Add collection 57
# 2016/10/03 - Add collection 58 to 63
# 2016/10/14 - Add collection 64 to 67
# 2016/10/28 - Bug fixes and updated collection 50
# 2016/11/18 - Add collection 68
# 2017/02/03 - Corrected collection 39 and 68
# 2017/03/27 - Add collection 69,70,71
# 2017/08/25 - Add collection 72
# 
#
# Purpose : This script create a set of SCCM collections and move it in an "Operational" folder
#
#############################################################################

#Load Configuration Manager PowerShell Module
Import-module ($Env:SMS_ADMIN_UI_PATH.Substring(0,$Env:SMS_ADMIN_UI_PATH.Length-5) + '\ConfigurationManager.psd1')

#Get SiteCode
$SiteCode = Get-PSDrive -PSProvider CMSITE
Set-location $SiteCode":"

#Error Handling and output
Clear-Host
$ErrorActionPreference= 'SilentlyContinue'
$Error1 = 0

#Refresh Schedule
$Schedule = New-CMSchedule -RecurInterval Days -RecurCount 7

#Create Defaut Folder 
$CollectionFolder = @{
    Name = "Operational";
    ObjectType = 5000; 
    ParentContainerNodeId = 0
}
Set-WmiInstance -Namespace "root\sms\site_$($SiteCode.Name)" -Class "SMS_ObjectContainerNode" -Arguments $CollectionFolder

#Create Default limiting collections
$LimitingCollection = "All Systems"

#List of Collections Query
#Make sure to update Collection4 when new client is released. Version # can be found https://goo.gl/3zSGc7
$Collection1 = @{
    Name = "Clients | All";
    Query = "select SMS_R_SYSTEM.ResourceID,SMS_R_SYSTEM.ResourceType,SMS_R_SYSTEM.Name,SMS_R_SYSTEM.SMSUniqueIdentifier,SMS_R_SYSTEM.ResourceDomainORWorkgroup,SMS_R_SYSTEM.Client from SMS_R_System where SMS_R_System.Client = 1";
    Comment = "All devices detected by SCCM";
    LimitCollection = $LimitingCollection
}
$Collection2 = @{
    Name = "System Health | Clients Inactive";
    Query = "select SMS_R_SYSTEM.ResourceID,SMS_R_SYSTEM.ResourceType,SMS_R_SYSTEM.Name,SMS_R_SYSTEM.SMSUniqueIdentifier,SMS_R_SYSTEM.ResourceDomainORWorkgroup,SMS_R_SYSTEM.Client from SMS_R_System inner join SMS_G_System_CH_ClientSummary on SMS_G_System_CH_ClientSummary.ResourceId = SMS_R_System.ResourceId where SMS_G_System_CH_ClientSummary.ClientActiveStatus = 0 and SMS_R_System.Client = 1 and SMS_R_System.Obsolete = 0";
    Comment = "All devices with SCCM client state inactive";
    LimitCollection = $Collection1.Name
}
$Collection3 = @{
    Name = "System Health | Clients Active";
    Query = "select SMS_R_SYSTEM.ResourceID,SMS_R_SYSTEM.ResourceType,SMS_R_SYSTEM.Name,SMS_R_SYSTEM.SMSUniqueIdentifier,SMS_R_SYSTEM.ResourceDomainORWorkgroup,SMS_R_SYSTEM.Client from SMS_R_System inner join SMS_G_System_CH_ClientSummary on SMS_G_System_CH_ClientSummary.ResourceId = SMS_R_System.ResourceId where SMS_G_System_CH_ClientSummary.ClientActiveStatus = 1 and SMS_R_System.Client = 1 and SMS_R_System.Obsolete = 0";
    Comment = "All devices with SCCM client state active";
    LimitCollection = $Collection1.Name
}
$Collection4 = @{
    Name = "Clients version | Not Latest (1706)";
    Query = "select SMS_R_SYSTEM.ResourceID,SMS_R_SYSTEM.ResourceType,SMS_R_SYSTEM.Name,SMS_R_SYSTEM.SMSUniqueIdentifier,SMS_R_SYSTEM.ResourceDomainORWorkgroup,SMS_R_SYSTEM.Client from SMS_R_System where SMS_R_System.ClientVersion != '5.00.8540.1007'";
    Comment = "All devices without SCCM client version 1706 (5.00.8540.1007)";
    LimitCollection = $Collection1.Name
}
$Collection5 = @{
    Name = "Hardware Inventory | Clients Not Reporting since 14 Days";
    Query = "select SMS_R_SYSTEM.ResourceID,SMS_R_SYSTEM.ResourceType,SMS_R_SYSTEM.Name,SMS_R_SYSTEM.SMSUniqueIdentifier,SMS_R_SYSTEM.ResourceDomainORWorkgroup,SMS_R_SYSTEM.Client from SMS_R_System where ResourceId in (select SMS_R_System.ResourceID from SMS_R_System inner join SMS_G_System_WORKSTATION_STATUS on SMS_G_System_WORKSTATION_STATUS.ResourceID = SMS_R_System.ResourceId where DATEDIFF(dd,SMS_G_System_WORKSTATION_STATUS.LastHardwareScan,GetDate()) > 14)";
    Comment = "All devices with SCCM client that have not communicated with hardware inventory over 14 days";
    LimitCollection = $Collection1.Name
}
$Collection6 = @{
    Name = "Clients | No";
    Query = "select SMS_R_SYSTEM.ResourceID,SMS_R_SYSTEM.ResourceType,SMS_R_SYSTEM.Name,SMS_R_SYSTEM.SMSUniqueIdentifier,SMS_R_SYSTEM.ResourceDomainORWorkgroup,SMS_R_SYSTEM.Client from SMS_R_System where SMS_R_System.Client = 0 OR SMS_R_System.Client is NULL";
    Comment = "All devices without SCCM client installed";
    LimitCollection = $LimitingCollection
}
$Collection7 = @{
    Name = "System Health | Obsolete";
    Query = "select * from SMS_R_System where SMS_R_System.Obsolete = 1";
    Comment = "All devices with SCCM client state obsolete";
    LimitCollection = $LimitingCollection
}
$Collection8 = @{
    Name = "Workstations | Active";
    Query = "select SMS_R_SYSTEM.ResourceID,SMS_R_SYSTEM.ResourceType,SMS_R_SYSTEM.Name,SMS_R_SYSTEM.SMSUniqueIdentifier,SMS_R_SYSTEM.ResourceDomainORWorkgroup,SMS_R_SYSTEM.Client from SMS_R_System inner join SMS_G_System_CH_ClientSummary on SMS_G_System_CH_ClientSummary.ResourceId = SMS_R_System.ResourceId where (SMS_R_System.OperatingSystemNameandVersion like 'Microsoft Windows NT%Workstation%' or SMS_R_System.OperatingSystemNameandVersion = 'Windows 7 Entreprise 6.1') and SMS_G_System_CH_ClientSummary.ClientActiveStatus = 1 and SMS_R_System.Client = 1 and SMS_R_System.Obsolete = 0";
    Comment = "All workstations with active state";
    LimitCollection = $LimitingCollection
}
$Collection9 = @{
    Name = "Laptops | All";
    Query = "select SMS_R_System.ResourceId, SMS_R_System.ResourceType, SMS_R_System.Name, SMS_R_System.SMSUniqueIdentifier, SMS_R_System.ResourceDomainORWorkgroup, SMS_R_System.Client from  SMS_R_System inner join SMS_G_System_SYSTEM_ENCLOSURE on SMS_G_System_SYSTEM_ENCLOSURE.ResourceID = SMS_R_System.ResourceId where SMS_G_System_SYSTEM_ENCLOSURE.ChassisTypes in ('8', '9', '10', '11', '12', '14', '18', '21')";
    Comment = "All laptops";
    LimitCollection = $LimitingCollection
}
$Collection10 = @{
    Name = "Servers | All";
    Query = "select SMS_R_SYSTEM.ResourceID,SMS_R_SYSTEM.ResourceType,SMS_R_SYSTEM.Name,SMS_R_SYSTEM.SMSUniqueIdentifier,SMS_R_SYSTEM.ResourceDomainORWorkgroup,SMS_R_SYSTEM.Client from SMS_R_System where OperatingSystemNameandVersion like '%Server%'";
    Comment = "All servers";
    LimitCollection = $LimitingCollection
}
$Collection11 = @{
    Name = "Servers | Physical";
    Query = "select SMS_R_SYSTEM.ResourceID,SMS_R_SYSTEM.ResourceType,SMS_R_SYSTEM.Name,SMS_R_SYSTEM.SMSUniqueIdentifier,SMS_R_SYSTEM.ResourceDomainORWorkgroup,SMS_R_SYSTEM.Client from SMS_R_System where SMS_R_System.ResourceId not in (select SMS_R_SYSTEM.ResourceID from SMS_R_System inner join SMS_G_System_COMPUTER_SYSTEM on SMS_G_System_COMPUTER_SYSTEM.ResourceId = SMS_R_System.ResourceId where SMS_R_System.IsVirtualMachine = 'True') and SMS_R_System.OperatingSystemNameandVersion like 'Microsoft Windows NT%Server%'";
    Comment = "All physical servers";
    LimitCollection = $Collection10.Name
}
$Collection12 = @{
    Name = "Servers | Virtual";
    Query = "select SMS_R_SYSTEM.ResourceID,SMS_R_SYSTEM.ResourceType,SMS_R_SYSTEM.Name,SMS_R_SYSTEM.SMSUniqueIdentifier,SMS_R_SYSTEM.ResourceDomainORWorkgroup,SMS_R_SYSTEM.Client from SMS_R_System where SMS_R_System.IsVirtualMachine = 'True' and SMS_R_System.OperatingSystemNameandVersion like 'Microsoft Windows NT%Server%'";
    Comment = "All virtual servers";
    LimitCollection = $Collection10.Name
}
$Collection13 = @{
    Name = "Workstations | All";
    Query = "select SMS_R_SYSTEM.ResourceID,SMS_R_SYSTEM.ResourceType,SMS_R_SYSTEM.Name,SMS_R_SYSTEM.SMSUniqueIdentifier,SMS_R_SYSTEM.ResourceDomainORWorkgroup,SMS_R_SYSTEM.Client from SMS_R_System where OperatingSystemNameandVersion like '%Workstation%'";
    Comment = "All workstations";
    LimitCollection = $LimitingCollection
}
$Collection14 = @{
    Name = "Workstations | Windows 7";
    Query = "select SMS_R_System.ResourceID,SMS_R_System.ResourceType,SMS_R_System.Name,SMS_R_System.SMSUniqueIdentifier,SMS_R_System.ResourceDomainORWorkgroup,SMS_R_System.Client from SMS_R_System where OperatingSystemNameandVersion like '%Workstation 6.1%'";
    Comment = "All worsktations with Windows 7 operating system";
    LimitCollection = $Collection13.Name
}
$Collection15 = @{
    Name = "Workstations | Windows 8";
    Query = "select SMS_R_System.ResourceID,SMS_R_System.ResourceType,SMS_R_System.Name,SMS_R_System.SMSUniqueIdentifier,SMS_R_System.ResourceDomainORWorkgroup,SMS_R_System.Client from SMS_R_System where OperatingSystemNameandVersion like '%Workstation 6.2%'";
    Comment = "All workstations with Windows 8 operating system";
    LimitCollection = $Collection13.Name
}
$Collection16 = @{
    Name = "Workstations | Windows 8.1";
    Query = "select SMS_R_System.ResourceID,SMS_R_System.ResourceType,SMS_R_System.Name,SMS_R_System.SMSUniqueIdentifier,SMS_R_System.ResourceDomainORWorkgroup,SMS_R_System.Client from SMS_R_System where OperatingSystemNameandVersion like '%Workstation 6.3%'";
    Comment = "All workstations with Windows 8.1 operating system";
    LimitCollection = $Collection13.Name
}
$Collection17 = @{
    Name = "Workstations | Windows XP";
    Query = "select SMS_R_SYSTEM.ResourceID,SMS_R_SYSTEM.ResourceType,SMS_R_SYSTEM.Name,SMS_R_SYSTEM.SMSUniqueIdentifier,SMS_R_SYSTEM.ResourceDomainORWorkgroup,SMS_R_SYSTEM.Client from SMS_R_System   where OperatingSystemNameandVersion like '%Workstation 5.1%' or OperatingSystemNameandVersion like '%Workstation 5.2%'";
    Comment = "All workstations with Windows XP operating system";
    LimitCollection = $Collection13.Name
}
$Collection18 = @{
    Name = "Servers | Windows 2008 and 2008 R2";
    Query = "select SMS_R_System.ResourceID,SMS_R_System.ResourceType,SMS_R_System.Name,SMS_R_System.SMSUniqueIdentifier,SMS_R_System.ResourceDomainORWorkgroup,SMS_R_System.Client from SMS_R_System where OperatingSystemNameandVersion like '%Server 6.0%' or OperatingSystemNameandVersion like '%Server 6.1%'";
    Comment = "All servers with Windows 2008 or 2008 R2 operating system";
    LimitCollection = $Collection10.Name
}
$Collection19 = @{
    Name = "Servers | Windows 2012 and 2012 R2";
    Query = "select SMS_R_System.ResourceID,SMS_R_System.ResourceType,SMS_R_System.Name,SMS_R_System.SMSUniqueIdentifier,SMS_R_System.ResourceDomainORWorkgroup,SMS_R_System.Client from SMS_R_System where OperatingSystemNameandVersion like '%Server 6.2%' or OperatingSystemNameandVersion like '%Server 6.3%'";
    Comment = "All servers with Windows 2012 or 2012 R2 operating system";
    LimitCollection = $Collection10.Name
}
$Collection20 = @{
    Name = "Servers | Windows 2003 and 2003 R2";
    Query = "select SMS_R_System.ResourceID,SMS_R_System.ResourceType,SMS_R_System.Name,SMS_R_System.SMSUniqueIdentifier,SMS_R_System.ResourceDomainORWorkgroup,SMS_R_System.Client from SMS_R_System where OperatingSystemNameandVersion like '%Server 5.2%'";
    Comment = "All servers with Windows 2003 or 2003 R2 operating system";
    LimitCollection = $Collection10.Name
}
$Collection21 = @{
    Name = "Systems | Created Since 24h";
    Query = "select SMS_R_System.Name, SMS_R_System.CreationDate FROM SMS_R_System WHERE DateDiff(dd,SMS_R_System.CreationDate, GetDate()) <= 1";
    Comment = "All systems created in the last 24 hours";
    LimitCollection = $LimitingCollection
}
$Collection22 = @{
    Name = "SCCM | Console";
    Query = "select SMS_R_SYSTEM.ResourceID,SMS_R_SYSTEM.ResourceType,SMS_R_SYSTEM.Name,SMS_R_SYSTEM.SMSUniqueIdentifier,SMS_R_SYSTEM.ResourceDomainORWorkgroup,SMS_R_SYSTEM.Client from SMS_R_System inner join SMS_G_System_ADD_REMOVE_PROGRAMS on SMS_G_System_ADD_REMOVE_PROGRAMS.ResourceID = SMS_R_System.ResourceId where SMS_G_System_ADD_REMOVE_PROGRAMS.DisplayName like '%Configuration Manager Console%'";
    Comment = "All systems with SCCM console installed";
    LimitCollection = $LimitingCollection
}
$Collection23 = @{
    Name = "SCCM | Site System";
    Query = "select SMS_R_System.ResourceId, SMS_R_System.ResourceType, SMS_R_System.Name, SMS_R_System.SMSUniqueIdentifier, SMS_R_System.ResourceDomainORWorkgroup, SMS_R_System.Client from  SMS_R_System where SMS_R_System.SystemRoles = 'SMS Site System'";
    Comment = "All systems that is SCCM site system";
    LimitCollection = $Collection10.Name
}
$Collection24 = @{
    Name = "SCCM | Site Servers";
    Query = "select SMS_R_System.ResourceId, SMS_R_System.ResourceType, SMS_R_System.Name, SMS_R_System.SMSUniqueIdentifier, SMS_R_System.ResourceDomainORWorkgroup, SMS_R_System.Client from  SMS_R_System where SMS_R_System.SystemRoles = 'SMS Site Server'";
    Comment = "All systems that is SCCM site server";
    LimitCollection = $Collection10.Name
}
$Collection25 = @{
    Name = "SCCM | Distribution Points";
    Query = "select SMS_R_System.ResourceId, SMS_R_System.ResourceType, SMS_R_System.Name, SMS_R_System.SMSUniqueIdentifier, SMS_R_System.ResourceDomainORWorkgroup, SMS_R_System.Client from  SMS_R_System where SMS_R_System.SystemRoles = 'SMS Distribution Point'";
    Comment = "All systems that is SCCM distribution point";
    LimitCollection = $Collection10.Name
}
$Collection26 = @{
    Name = "Windows Update Agent | Outdated Version Win7 RTM and Lower";
    Query = "select SMS_R_SYSTEM.ResourceID,SMS_R_SYSTEM.ResourceType,SMS_R_SYSTEM.Name,SMS_R_SYSTEM.SMSUniqueIdentifier,SMS_R_SYSTEM.ResourceDomainORWorkgroup,SMS_R_SYSTEM.Client from SMS_R_System inner join SMS_G_System_WINDOWSUPDATEAGENTVERSION on SMS_G_System_WINDOWSUPDATEAGENTVERSION.ResourceID = SMS_R_System.ResourceId inner join SMS_G_System_OPERATING_SYSTEM on SMS_G_System_OPERATING_SYSTEM.ResourceID = SMS_R_System.ResourceId where SMS_G_System_WINDOWSUPDATEAGENTVERSION.Version < '7.6.7600.256' and SMS_G_System_OPERATING_SYSTEM.Version <= '6.1.7600'";
    Comment = "All systems with windows update agent with outdated version Win7 RTM and lower";
    LimitCollection = $Collection13.Name
}
$Collection27 = @{
    Name = "Windows Update Agent | Outdated Version Win7 SP1 and Higher";
    Query = "select SMS_R_SYSTEM.ResourceID,SMS_R_SYSTEM.ResourceType,SMS_R_SYSTEM.Name,SMS_R_SYSTEM.SMSUniqueIdentifier,SMS_R_SYSTEM.ResourceDomainORWorkgroup,SMS_R_SYSTEM.Client from SMS_R_System inner join SMS_G_System_WINDOWSUPDATEAGENTVERSION on SMS_G_System_WINDOWSUPDATEAGENTVERSION.ResourceID = SMS_R_System.ResourceId inner join SMS_G_System_OPERATING_SYSTEM on SMS_G_System_OPERATING_SYSTEM.ResourceID = SMS_R_System.ResourceId where SMS_G_System_WINDOWSUPDATEAGENTVERSION.Version < '7.6.7600.320' and SMS_G_System_OPERATING_SYSTEM.Version >= '6.1.7601'";
    Comment = "All systems with windows update agent with outdated version Win7 SP1 and higher";
    LimitCollection = $Collection13.Name
}
$Collection28 = @{
    Name = "Mobile Devices | Android";
    Query = "SELECT SMS_R_System.ResourceId, SMS_R_System.ResourceType, SMS_R_System.Name, SMS_R_System.SMSUniqueIdentifier, SMS_R_System.ResourceDomainORWorkgroup, SMS_R_System.Client FROM SMS_R_System INNER JOIN SMS_G_System_DEVICE_OSINFORMATION ON SMS_G_System_DEVICE_OSINFORMATION.ResourceID = SMS_R_System.ResourceId WHERE SMS_G_System_DEVICE_OSINFORMATION.Platform like 'Android%'";
    Comment = "All Android modible devices";
    LimitCollection = $LimitingCollection
}
$Collection29 = @{
    Name = "Mobile Devices | Iphone";
    Query = "select SMS_R_SYSTEM.ResourceID,SMS_R_SYSTEM.ResourceType,SMS_R_SYSTEM.Name,SMS_R_SYSTEM.SMSUniqueIdentifier,SMS_R_SYSTEM.ResourceDomainORWorkgroup,SMS_R_SYSTEM.Client from SMS_R_System inner join SMS_G_System_DEVICE_COMPUTERSYSTEM on SMS_G_System_DEVICE_COMPUTERSYSTEM.ResourceId = SMS_R_System.ResourceId where SMS_G_System_DEVICE_COMPUTERSYSTEM.DeviceModel like '%Iphone%'";
    Comment = "All Iphone modible devices";
    LimitCollection = $LimitingCollection
}
$Collection30 = @{
    Name = "Mobile Devices | Ipad";
    Query = "select SMS_R_SYSTEM.ResourceID,SMS_R_SYSTEM.ResourceType,SMS_R_SYSTEM.Name,SMS_R_SYSTEM.SMSUniqueIdentifier,SMS_R_SYSTEM.ResourceDomainORWorkgroup,SMS_R_SYSTEM.Client from SMS_R_System inner join SMS_G_System_DEVICE_COMPUTERSYSTEM on SMS_G_System_DEVICE_COMPUTERSYSTEM.ResourceId = SMS_R_System.ResourceId where SMS_G_System_DEVICE_COMPUTERSYSTEM.DeviceModel like '%Ipad%'";
    Comment = "All Ipad mobile devices";
    LimitCollection = $LimitingCollection
}
$Collection31 = @{
    Name = "Mobile Devices | Windows Phone 8";
    Query = "select SMS_R_System.ResourceId, SMS_R_System.ResourceType, SMS_R_System.Name, SMS_R_System.SMSUniqueIdentifier, SMS_R_System.ResourceDomainORWorkgroup, SMS_R_System.Client from SMS_R_System inner join SMS_G_System_DEVICE_OSINFORMATION on SMS_G_System_DEVICE_OSINFORMATION.ResourceID = SMS_R_System.ResourceId where SMS_G_System_DEVICE_OSINFORMATION.Platform = 'Windows Phone' and SMS_G_System_DEVICE_OSINFORMATION.Version like '8.0%'";
    Comment = "All Windows 8 mobile devices";
    LimitCollection = $LimitingCollection
}
$Collection32 = @{
    Name = "Mobile Devices | Windows Phone 8.1";
    Query = "select SMS_R_System.ResourceId, SMS_R_System.ResourceType, SMS_R_System.Name, SMS_R_System.SMSUniqueIdentifier, SMS_R_System.ResourceDomainORWorkgroup, SMS_R_System.Client from SMS_R_System inner join SMS_G_System_DEVICE_OSINFORMATION on SMS_G_System_DEVICE_OSINFORMATION.ResourceID = SMS_R_System.ResourceId where SMS_G_System_DEVICE_OSINFORMATION.Platform = 'Windows Phone' and SMS_G_System_DEVICE_OSINFORMATION.Version like '8.1%'";
    Comment = "All Windows 8.1 mobile devices";
    LimitCollection = $LimitingCollection
}
$Collection33 = @{
    Name = "Mobile Devices | Microsoft Surface";
    Query = "select SMS_R_System.ResourceId, SMS_R_System.ResourceType, SMS_R_System.Name, SMS_R_System.SMSUniqueIdentifier, SMS_R_System.ResourceDomainORWorkgroup, SMS_R_System.Client from SMS_R_System inner join SMS_G_System_COMPUTER_SYSTEM on SMS_G_System_COMPUTER_SYSTEM.ResourceId = SMS_R_System.ResourceId where SMS_G_System_COMPUTER_SYSTEM.Model like '%Surface%'";
    Comment = "All Windows RT mobile devices";
    LimitCollection = $LimitingCollection
}
$Collection34 = @{
    Name = "System Health | Disabled";
    Query = "select SMS_R_SYSTEM.ResourceID,SMS_R_SYSTEM.ResourceType,SMS_R_SYSTEM.Name,SMS_R_SYSTEM.SMSUniqueIdentifier,SMS_R_SYSTEM.ResourceDomainORWorkgroup,SMS_R_SYSTEM.Client from SMS_R_System where SMS_R_System.UserAccountControl ='4098'";
    Comment = "All systems with client state disabled";
    LimitCollection = $LimitingCollection
}
$Collection35 = @{
    Name = "Systems | x86";
    Query = "select SMS_R_SYSTEM.ResourceID,SMS_R_SYSTEM.ResourceType,SMS_R_SYSTEM.Name,SMS_R_SYSTEM.SMSUniqueIdentifier,SMS_R_SYSTEM.ResourceDomainORWorkgroup,SMS_R_SYSTEM.Client from SMS_R_System inner join SMS_G_System_COMPUTER_SYSTEM on SMS_G_System_COMPUTER_SYSTEM.ResourceID = SMS_R_System.ResourceId where SMS_G_System_COMPUTER_SYSTEM.SystemType = 'X86-based PC'";
    Comment = "All systems with 32-bit system type";
    LimitCollection = $LimitingCollection
}
$Collection36 = @{
    Name = "Systems | x64";
    Query = "select SMS_R_SYSTEM.ResourceID,SMS_R_SYSTEM.ResourceType,SMS_R_SYSTEM.Name,SMS_R_SYSTEM.SMSUniqueIdentifier,SMS_R_SYSTEM.ResourceDomainORWorkgroup,SMS_R_SYSTEM.Client from SMS_R_System inner join SMS_G_System_COMPUTER_SYSTEM on SMS_G_System_COMPUTER_SYSTEM.ResourceID = SMS_R_System.ResourceId where SMS_G_System_COMPUTER_SYSTEM.SystemType = 'X64-based PC'";
    Comment = "All systems with 64-bit system type";
    LimitCollection = $LimitingCollection
}
$Collection37 = @{
    Name = "Clients Version | R2 CU1";
    Query = "select SMS_R_SYSTEM.ResourceID,SMS_R_SYSTEM.ResourceType,SMS_R_SYSTEM.Name,SMS_R_SYSTEM.SMSUniqueIdentifier,SMS_R_SYSTEM.ResourceDomainORWorkgroup,SMS_R_SYSTEM.Client from SMS_R_System where SMS_R_System.ClientVersion = '5.00.7958.1203'";
    Comment = "All systems with SCCM client version R2 CU1 installed";
    LimitCollection = $LimitingCollection
}
$Collection38 = @{
    Name = "Clients Version | R2 CU2";
    Query = "select SMS_R_SYSTEM.ResourceID,SMS_R_SYSTEM.ResourceType,SMS_R_SYSTEM.Name,SMS_R_SYSTEM.SMSUniqueIdentifier,SMS_R_SYSTEM.ResourceDomainORWorkgroup,SMS_R_SYSTEM.Client from SMS_R_System where SMS_R_System.ClientVersion = '5.00.7958.1303'";
    Comment = "All systems with SCCM client version R2 CU2 installed";
    LimitCollection = $LimitingCollection
}
$Collection39 = @{
    Name = "Clients Version | R2 CU3";
    Query = "select SMS_R_SYSTEM.ResourceID,SMS_R_SYSTEM.ResourceType,SMS_R_SYSTEM.Name,SMS_R_SYSTEM.SMSUniqueIdentifier,SMS_R_SYSTEM.ResourceDomainORWorkgroup,SMS_R_SYSTEM.Client from SMS_R_System where SMS_R_System.ClientVersion like '5.00.7958.14%'";
    Comment = "All systems with SCCM client version R2 CU3 installed";
    LimitCollection = $LimitingCollection
}
$Collection40 = @{
    Name = "Clients Version | R2 CU4";
    Query = "select SMS_R_SYSTEM.ResourceID,SMS_R_SYSTEM.ResourceType,SMS_R_SYSTEM.Name,SMS_R_SYSTEM.SMSUniqueIdentifier,SMS_R_SYSTEM.ResourceDomainORWorkgroup,SMS_R_SYSTEM.Client from SMS_R_System where SMS_R_System.ClientVersion = '5.00.7958.1501'";
    Comment = "All systems with SCCM client version R2 CU4 installed";
    LimitCollection = $LimitingCollection
}
$Collection41 = @{
    Name = "Clients Version | R2 CU5";
    Query = "select SMS_R_SYSTEM.ResourceID,SMS_R_SYSTEM.ResourceType,SMS_R_SYSTEM.Name,SMS_R_SYSTEM.SMSUniqueIdentifier,SMS_R_SYSTEM.ResourceDomainORWorkgroup,SMS_R_SYSTEM.Client from SMS_R_System where SMS_R_System.ClientVersion = '5.00.7958.1604'";
    Comment = "All systems with SCCM client version R2 CU5 installed";
    LimitCollection = $LimitingCollection
}
$Collection42 = @{
    Name = "Clients Version | R2 CU0";
    Query = "select SMS_R_SYSTEM.ResourceID,SMS_R_SYSTEM.ResourceType,SMS_R_SYSTEM.Name,SMS_R_SYSTEM.SMSUniqueIdentifier,SMS_R_SYSTEM.ResourceDomainORWorkgroup,SMS_R_SYSTEM.Client from SMS_R_System where SMS_R_System.ClientVersion = '5.00.7958.1000'";
    Comment = "All systems with SCCM client version R2 CU0 installed";
    LimitCollection = $LimitingCollection
}
$Collection43 = @{
    Name = "Clients Version | R2 SP1";
    Query = "select SMS_R_SYSTEM.ResourceID,SMS_R_SYSTEM.ResourceType,SMS_R_SYSTEM.Name,SMS_R_SYSTEM.SMSUniqueIdentifier,SMS_R_SYSTEM.ResourceDomainORWorkgroup,SMS_R_SYSTEM.Client from SMS_R_System where SMS_R_System.ClientVersion = '5.00.8239.1000'";
    Comment = "All systems with SCCM client version R2 SP1 installed";
    LimitCollection = $LimitingCollection
}
$Collection44 = @{
    Name = "Clients Version | R2 SP1 CU1";
    Query = "select SMS_R_SYSTEM.ResourceID,SMS_R_SYSTEM.ResourceType,SMS_R_SYSTEM.Name,SMS_R_SYSTEM.SMSUniqueIdentifier,SMS_R_SYSTEM.ResourceDomainORWorkgroup,SMS_R_SYSTEM.Client from SMS_R_System where SMS_R_System.ClientVersion = '5.00.8239.1203'";
    Comment = "All systems with SCCM client version R2 SP1 CU1 installed";
    LimitCollection = $LimitingCollection
}
$Collection45 = @{
    Name = "Workstations | Windows 10";
    Query = "select SMS_R_System.ResourceID,SMS_R_System.ResourceType,SMS_R_System.Name,SMS_R_System.SMSUniqueIdentifier,SMS_R_System.ResourceDomainORWorkgroup,SMS_R_System.Client from SMS_R_System where OperatingSystemNameandVersion like '%Workstation 10.0%'";
    Comment = "All workstations with Windows 10 operating system";
    LimitCollection = $LimitingCollection
}
$Collection46 = @{
    Name = "Clients Version | R2 SP1 CU2";
    Query = "select SMS_R_SYSTEM.ResourceID,SMS_R_SYSTEM.ResourceType,SMS_R_SYSTEM.Name,SMS_R_SYSTEM.SMSUniqueIdentifier,SMS_R_SYSTEM.ResourceDomainORWorkgroup,SMS_R_SYSTEM.Client from SMS_R_System where SMS_R_System.ClientVersion = '5.00.8239.1301'";
    Comment = "All systems with SCCM client version R2 SP1 CU2 installed";
    LimitCollection = $LimitingCollection
}
$Collection47 = @{
    Name = "Clients Version | 1511";
    Query = "select SMS_R_SYSTEM.ResourceID,SMS_R_SYSTEM.ResourceType,SMS_R_SYSTEM.Name,SMS_R_SYSTEM.SMSUniqueIdentifier,SMS_R_SYSTEM.ResourceDomainORWorkgroup,SMS_R_SYSTEM.Client from SMS_R_System where SMS_R_System.ClientVersion = '5.00.8325.1000'";
    Comment = "ll systems with SCCM client version 1511 installed";
    LimitCollection = $LimitingCollection
}
$Collection48 = @{
    Name = "Laptops | Dell";
    Query = "select SMS_R_SYSTEM.ResourceID,SMS_R_SYSTEM.ResourceType,SMS_R_SYSTEM.Name,SMS_R_SYSTEM.SMSUniqueIdentifier,SMS_R_SYSTEM.ResourceDomainORWorkgroup,SMS_R_SYSTEM.Client from SMS_R_System inner join SMS_G_System_COMPUTER_SYSTEM on SMS_G_System_COMPUTER_SYSTEM.ResourceId = SMS_R_System.ResourceId where SMS_G_System_COMPUTER_SYSTEM.Manufacturer like '%Dell%'";
    Comment = "All laptops with Dell manufacturer";
    LimitCollection = $Collection9.Name
}
$Collection49 = @{
    Name = "Laptops | Lenovo";
    Query = "select SMS_R_SYSTEM.ResourceID,SMS_R_SYSTEM.ResourceType,SMS_R_SYSTEM.Name,SMS_R_SYSTEM.SMSUniqueIdentifier,SMS_R_SYSTEM.ResourceDomainORWorkgroup,SMS_R_SYSTEM.Client from SMS_R_System inner join SMS_G_System_COMPUTER_SYSTEM on SMS_G_System_COMPUTER_SYSTEM.ResourceId = SMS_R_System.ResourceId where SMS_G_System_COMPUTER_SYSTEM.Manufacturer like '%Lenovo%'";
    Comment = "All laptops with Lenovo manufacturer";
    LimitCollection = $Collection9.Name
}
$Collection50 = @{
    Name = "Laptops | HP";
    Query = "select SMS_R_SYSTEM.ResourceID,SMS_R_SYSTEM.ResourceType,SMS_R_SYSTEM.Name,SMS_R_SYSTEM.SMSUniqueIdentifier,SMS_R_SYSTEM.ResourceDomainORWorkgroup,SMS_R_SYSTEM.Client from SMS_R_System inner join SMS_G_System_COMPUTER_SYSTEM on SMS_G_System_COMPUTER_SYSTEM.ResourceId = SMS_R_System.ResourceId where SMS_G_System_COMPUTER_SYSTEM.Manufacturer like '%HP%' or SMS_G_System_COMPUTER_SYSTEM.Manufacturer like '%Hewlett-Packard%'";
    Comment = "All laptops with HP manufacturer";
    LimitCollection = $Collection9.Name
}
$Collection51 = @{
    Name = "Clients Version | R2 SP1 CU3";
    Query = "select SMS_R_SYSTEM.ResourceID,SMS_R_SYSTEM.ResourceType,SMS_R_SYSTEM.Name,SMS_R_SYSTEM.SMSUniqueIdentifier,SMS_R_SYSTEM.ResourceDomainORWorkgroup,SMS_R_SYSTEM.Client from SMS_R_System where SMS_R_System.ClientVersion = '5.00.8239.1403'";
    Comment = "All systems with SCCM client version R2 SP1 CU3 installed";
    LimitCollection = $LimitingCollection
}
$Collection52 = @{
    Name = "Clients Version | 1602";
    Query = "select SMS_R_SYSTEM.ResourceID,SMS_R_SYSTEM.ResourceType,SMS_R_SYSTEM.Name,SMS_R_SYSTEM.SMSUniqueIdentifier,SMS_R_SYSTEM.ResourceDomainORWorkgroup,SMS_R_SYSTEM.Client from SMS_R_System where SMS_R_System.ClientVersion = '5.00.8355.1%'";
    Comment = "All systems with SCCM client version 1602 installed";
    LimitCollection = $LimitingCollection
}
$Collection53 = @{
    Name = "Clients Version | 1606";
    Query = "select SMS_R_SYSTEM.ResourceID,SMS_R_SYSTEM.ResourceType,SMS_R_SYSTEM.Name,SMS_R_SYSTEM.SMSUniqueIdentifier,SMS_R_SYSTEM.ResourceDomainORWorkgroup,SMS_R_SYSTEM.Client from SMS_R_System where SMS_R_System.ClientVersion like '5.00.8412.1%'";
    Comment = "All systems with SCCM client version 1606 installed";
    LimitCollection = $LimitingCollection
}
$Collection54 = @{
    Name = "Mobile Devices | Microsoft Surface 3";
    Query = "select SMS_R_System.ResourceId, SMS_R_System.ResourceType, SMS_R_System.Name, SMS_R_System.SMSUniqueIdentifier, SMS_R_System.ResourceDomainORWorkgroup, SMS_R_System.Client from SMS_R_System inner join SMS_G_System_COMPUTER_SYSTEM on SMS_G_System_COMPUTER_SYSTEM.ResourceId = SMS_R_System.ResourceId where SMS_G_System_COMPUTER_SYSTEM.Model = 'Surface Pro 3' OR SMS_G_System_COMPUTER_SYSTEM.Model = 'Surface 3'";
    Comment = "All Microsoft Surface 3";
    LimitCollection = $LimitingCollection
}
$Collection55 = @{
    Name = "Mobile Devices | Microsoft Surface 4";
    Query = "select SMS_R_System.ResourceId, SMS_R_System.ResourceType, SMS_R_System.Name, SMS_R_System.SMSUniqueIdentifier, SMS_R_System.ResourceDomainORWorkgroup, SMS_R_System.Client from SMS_R_System inner join SMS_G_System_COMPUTER_SYSTEM on SMS_G_System_COMPUTER_SYSTEM.ResourceId = SMS_R_System.ResourceId where SMS_G_System_COMPUTER_SYSTEM.Model = 'Surface Pro 4'";
    Comment = "All Microsoft Surface 4";
    LimitCollection = $LimitingCollection
}
$Collection56 = @{
    Name = "Mobile Devices | Windows Phone 10";
    Query = "select SMS_R_System.ResourceId, SMS_R_System.ResourceType, SMS_R_System.Name, SMS_R_System.SMSUniqueIdentifier, SMS_R_System.ResourceDomainORWorkgroup, SMS_R_System.Client from SMS_R_System inner join SMS_G_System_DEVICE_OSINFORMATION on SMS_G_System_DEVICE_OSINFORMATION.ResourceID = SMS_R_System.ResourceId where SMS_G_System_DEVICE_OSINFORMATION.Platform = 'Windows Phone' and SMS_G_System_DEVICE_OSINFORMATION.Version like '10%'";
    Comment = "All Windows Phone 10";
    LimitCollection = $LimitingCollection
}
$Collection57 = @{
    Name = "Mobile Devices | All";
    Query = "select * from SMS_R_System where SMS_R_System.ClientType = 3";
    Comment = "All Mobile Devices";
    LimitCollection = $LimitingCollection
}
$Collection58 = @{
    Name = "Workstations | Windows 10 v1507";
    Query = "select SMS_R_SYSTEM.ResourceID,SMS_R_SYSTEM.ResourceType,SMS_R_SYSTEM.Name,SMS_R_SYSTEM.SMSUniqueIdentifier,SMS_R_SYSTEM.ResourceDomainORWorkgroup,SMS_R_SYSTEM.Client from SMS_R_System where SMS_R_System.Build like '10.0.10240%'";
    Comment = "All workstations with Windows 10 operating system v1507";
    LimitCollection = $Collection13.Name
}
$Collection59 = @{
    Name = "Workstations | Windows 10 v1511";
    Query = "select SMS_R_SYSTEM.ResourceID,SMS_R_SYSTEM.ResourceType,SMS_R_SYSTEM.Name,SMS_R_SYSTEM.SMSUniqueIdentifier,SMS_R_SYSTEM.ResourceDomainORWorkgroup,SMS_R_SYSTEM.Client from SMS_R_System where SMS_R_System.Build like '10.0.10586%'";
    Comment = "All workstations with Windows 10 operating system v1511";
    LimitCollection = $Collection13.Name
}
$Collection60 = @{
    Name = "Workstations | Windows 10 v1607";
    Query = "select SMS_R_SYSTEM.ResourceID,SMS_R_SYSTEM.ResourceType,SMS_R_SYSTEM.Name,SMS_R_SYSTEM.SMSUniqueIdentifier,SMS_R_SYSTEM.ResourceDomainORWorkgroup,SMS_R_SYSTEM.Client from SMS_R_System where SMS_R_System.Build like '10.0.14393%'";
    Comment = "All workstations with Windows 10 operating system v1607";
    LimitCollection = $Collection13.Name
}
$Collection61 = @{
    Name = "Workstations | Windows 10 Current Branch (CB)";
    Query = "select SMS_R_SYSTEM.ResourceID,SMS_R_SYSTEM.ResourceType,SMS_R_SYSTEM.Name,SMS_R_SYSTEM.SMSUniqueIdentifier,SMS_R_SYSTEM.ResourceDomainORWorkgroup,SMS_R_SYSTEM.Client from SMS_R_System where SMS_R_System.OperatingSystemNameandVersion like '%Workstation 10.0%' and SMS_R_System.OSBranch = '0'";
    Comment = "All workstations with Windows 10 CB";
    LimitCollection = $Collection13.Name
}
$Collection62 = @{
    Name = "Workstations | Windows 10 Current Branch for Business (CBB)";
    Query = "select SMS_R_SYSTEM.ResourceID,SMS_R_SYSTEM.ResourceType,SMS_R_SYSTEM.Name,SMS_R_SYSTEM.SMSUniqueIdentifier,SMS_R_SYSTEM.ResourceDomainORWorkgroup,SMS_R_SYSTEM.Client from SMS_R_System where SMS_R_System.OperatingSystemNameandVersion like '%Workstation 10.0%' and SMS_R_System.OSBranch = '1'";
    Comment = "All workstations with Windows 10 CBB";
    LimitCollection = $Collection13.Name
}
$Collection63 = @{
    Name = "Workstations | Windows 10 Long Term Servicing Branch (LTSB)";
    Query = "select SMS_R_SYSTEM.ResourceID,SMS_R_SYSTEM.ResourceType,SMS_R_SYSTEM.Name,SMS_R_SYSTEM.SMSUniqueIdentifier,SMS_R_SYSTEM.ResourceDomainORWorkgroup,SMS_R_SYSTEM.Client from SMS_R_System where SMS_R_System.OperatingSystemNameandVersion like '%Workstation 10.0%' and SMS_R_System.OSBranch = '2'";
    Comment = "All workstations with Windows 10 LTSB";
    LimitCollection = $Collection13.Name
}
$Collection64 = @{
    Name = "Workstations | Windows 10 Support State - Current";
    Query = "select SMS_R_SYSTEM.ResourceID,SMS_R_SYSTEM.ResourceType,SMS_R_SYSTEM.Name,SMS_R_SYSTEM.SMSUniqueIdentifier,SMS_R_SYSTEM.ResourceDomainORWorkgroup,SMS_R_SYSTEM.Client from SMS_R_System  LEFT OUTER JOIN SMS_WindowsServicingStates ON SMS_WindowsServicingStates.Build = SMS_R_System.build01 AND SMS_WindowsServicingStates.branch = SMS_R_System.osbranch01 where SMS_WindowsServicingStates.State = '2'";
    Comment = "Windows 10 Support State - Current";
    LimitCollection = $Collection13.Name
}
$Collection65 = @{
    Name = "Workstations | Windows 10 Support State - Expired Soon";
    Query = "select SMS_R_SYSTEM.ResourceID,SMS_R_SYSTEM.ResourceType,SMS_R_SYSTEM.Name,SMS_R_SYSTEM.SMSUniqueIdentifier,SMS_R_SYSTEM.ResourceDomainORWorkgroup,SMS_R_SYSTEM.Client from SMS_R_System  LEFT OUTER JOIN SMS_WindowsServicingStates ON SMS_WindowsServicingStates.Build = SMS_R_System.build01 AND SMS_WindowsServicingStates.branch = SMS_R_System.osbranch01 where SMS_WindowsServicingStates.State = '3'";
    Comment = "Windows 10 Support State - Expired Soon";
    LimitCollection = $Collection13.Name
}
$Collection66 = @{
    Name = "Workstations | Windows 10 Support State - Expired";
    Query = "select SMS_R_SYSTEM.ResourceID,SMS_R_SYSTEM.ResourceType,SMS_R_SYSTEM.Name,SMS_R_SYSTEM.SMSUniqueIdentifier,SMS_R_SYSTEM.ResourceDomainORWorkgroup,SMS_R_SYSTEM.Client from SMS_R_System  LEFT OUTER JOIN SMS_WindowsServicingStates ON SMS_WindowsServicingStates.Build = SMS_R_System.build01 AND SMS_WindowsServicingStates.branch = SMS_R_System.osbranch01 where SMS_WindowsServicingStates.State = '4'";
    Comment = "Windows 10 Support State - Expired";
    LimitCollection = $Collection13.Name
}
$Collection67 = @{
    Name = "Servers | Windows 2016";
    Query = "select SMS_R_System.ResourceID,SMS_R_System.ResourceType,SMS_R_System.Name,SMS_R_System.SMSUniqueIdentifier,SMS_R_System.ResourceDomainORWorkgroup,SMS_R_System.Client from SMS_R_System where OperatingSystemNameandVersion like '%Server 10%'";
    Comment = "All Servers with Windows 2016";
    LimitCollection = $Collection10.Name
}
$Collection68 = @{
    Name = "Clients Version | 1610";
    Query = "select SMS_R_SYSTEM.ResourceID,SMS_R_SYSTEM.ResourceType,SMS_R_SYSTEM.Name,SMS_R_SYSTEM.SMSUniqueIdentifier,SMS_R_SYSTEM.ResourceDomainORWorkgroup,SMS_R_SYSTEM.Client from SMS_R_System where SMS_R_System.ClientVersion like '5.00.8458.1%'";
    Comment = "All systems with SCCM client version 1610 installed";
    LimitCollection = $LimitingCollection
}
$Collection69 = @{
    Name = "Clients Version | 1702";
    Query = "select SMS_R_SYSTEM.ResourceID,SMS_R_SYSTEM.ResourceType,SMS_R_SYSTEM.Name,SMS_R_SYSTEM.SMSUniqueIdentifier,SMS_R_SYSTEM.ResourceDomainORWorkgroup,SMS_R_SYSTEM.Client from SMS_R_System where SMS_R_System.ClientVersion like '5.00.8498.1%'";
    Comment = "All systems with SCCM client version 1702 installed";
    LimitCollection = $LimitingCollection
}
$Collection70 = @{
    Name = "Others | Linux Devices";
    Query = "select * from SMS_R_System where SMS_R_System.ClientEdition = 13";
    Comment = "All systems with Linux";
    LimitCollection = $LimitingCollection
}
$Collection71 = @{
    Name = "Others | MAC OSX Devices";
    Query = "select SMS_R_SYSTEM.ResourceID,SMS_R_SYSTEM.ResourceType,SMS_R_SYSTEM.Name,SMS_R_SYSTEM.SMSUniqueIdentifier,SMS_R_SYSTEM.ResourceDomainORWorkgroup,SMS_R_SYSTEM.Client from SMS_R_System WHERE OperatingSystemNameandVersion LIKE 'Apple Mac OS X%'";
    Comment = "All workstations with MAC OSX";
    LimitCollection = $LimitingCollection
}
$Collection72 = @{
    Name = "Clients Version | 1706";
    Query = "select SMS_R_SYSTEM.ResourceID,SMS_R_SYSTEM.ResourceType,SMS_R_SYSTEM.Name,SMS_R_SYSTEM.SMSUniqueIdentifier,SMS_R_SYSTEM.ResourceDomainORWorkgroup,SMS_R_SYSTEM.Client from SMS_R_System where SMS_R_System.ClientVersion like '5.00.8540.1%'";
    Comment = "All systems with SCCM client version 1706 installed";
    LimitCollection = $LimitingCollection
}

$Collections = $Collection1,$Collection2,$Collection3,$Collection4,$Collection5,$Collection6,$Collection7,$Collection8,$Collection9,$Collection10,`
    $Collection11,$Collection12,$Collection13,$Collection14,$Collection15,$Collection16,$Collection17,$Collection18,$Collection19,$Collection20,`
    $Collection21,$Collection22,$Collection23,$Collection24,$Collection25,$Collection26,$Collection27,$Collection28,$Collection29,$Collection30,`
    $Collection31,$Collection32,$Collection33,$Collection34,$Collection35,$Collection36,$Collection37,$Collection38,$Collection39,$Collection40,`
    $Collection41,$Collection42,$Collection43,$Collection44,$Collection45,$Collection46,$Collection47,$Collection48,$Collection49,$Collection50,`
    $Collection51,$Collection52,$Collection53,$Collection54,$Collection55,$Collection56,$Collection57,$Collection58,$Collection59,$Collection60,`
    $Collection61,$Collection62,$Collection63,$Collection64,$Collection65,$Collection66,$Collection67,$Collection68,$Collection69,$Collection70,`
    $Collection71,$Collection72

# Creating collections and putting them in Operational folder
$FolderPath = $SiteCode.Name + ":\DeviceCollection\" + $CollectionFolder.Name
Foreach ($element in $Collections) {
    $CollectionName = $element.Name
    $CollectionComment = $element.Comment
    $CollectionQuery = $element.Query
    $CollectionExist = Get-CMDeviceCollection -Name "$CollectionName"
    $CollectionLimit = $element.LimitCollection
    If ($CollectionExist)   {
        Write-Host "The collection $CollectionName already exist"
    }
    Else    {
        New-CMDeviceCollection -Name $CollectionName -Comment $CollectionComment -LimitingCollectionName $CollectionLimit -RefreshSchedule $Schedule -RefreshType 2 | Out-Null
        Add-CMDeviceCollectionQueryMembershipRule -CollectionName $CollectionName -QueryExpression $CollectionQuery -RuleName $CollectionName
        Write-host -ForegroundColor Green "*** Collection $CollectionName created ***"
        Move-CMObject -FolderPath $FolderPath -InputObject (Get-CMDeviceCollection -Name $CollectionName)
    }
}
Pause