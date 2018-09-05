# Group Policy Object (GPO) Configuration
## Windows Event Forwarding (WEF) GPO

On a Domain Controller, open the Group Policy Management console, and create a new GPO named "WEF Policy" and open it for editing. This first part of the GPO defines where hosts should send their logs.

Navigate to:

`Computer Configuration > Policies > Administrative Templates > Windows Components > Event Forwarding`

![GPO_config_1](https://github.com/SecureDataLabs/44Con-2018-Sysmon/blob/Rustycoin/config/images/GPO_config_1.png)

Right click on the Configure target Subscription Manager entry and select Edit. Select the Enabled radio button and "Show" next to Subscription Managers in the Options pane.

![GPO_config_2](https://github.com/SecureDataLabs/44Con-2018-Sysmon/blob/Rustycoin/config/images/GPO_config_2.png)

Enter the following line in for the value substituting the Fully Qualified Domain name of the Windows Event Collector for the \<FQDN\> portion of the URL:

Server=http://\<FQDN\>:5985/wsman/SubscriptionManager/WEC,Refresh=120

![GPO_config_3](https://github.com/SecureDataLabs/44Con-2018-Sysmon/blob/Rustycoin/config/images/GPO_config_3.png)

Click OK until you are back to the main Group Policy Manager window to apply the configuration. Next we will need to enable the Windows Remote Management Service on the hosts.

Navigate to Computer Configuration \> Windows Settings \> Security Settings \> System Services and right-click the Windows Remote Management service and select Properties. Check the box for 'Define this policy setting' and set Startup Mode to Automatic then click OK to apply the change.

![GPO_config_4](https://github.com/SecureDataLabs/44Con-2018-Sysmon/blob/Rustycoin/config/images/GPO_config_4.png)

Now we need to allow event log reader access for the Network Service account which will permit Windows RM to read and send logs.

Navigate to Computer Configuration \> Policies \> Windows Settings \> Restricted Groups. Right-click within the window and select Add Group.

![GPO_config_5](https://github.com/SecureDataLabs/44Con-2018-Sysmon/blob/Rustycoin/config/images/GPO_config_5.png)

On the window that opens click Browse, Advanced and then Find Now. Scroll down and select the Event Log Readers group and then click OK until the Event Log Readers Properties window is visible.

![GPO_config_6](https://github.com/SecureDataLabs/44Con-2018-Sysmon/blob/Rustycoin/config/images/GPO_config_6.png)

On Event Log Readers Properties click Add then type the below in the window that appears and click OK until you are back at the Group Policy Management console --

NT AUTHORITY\\NETWORK SERVICE

![GPO_config_7](https://github.com/SecureDataLabs/44Con-2018-Sysmon/blob/Rustycoin/config/images/GPO_config_7.png)

The final requirement is to allow Remote Server Management Through WinRM.

Navigate to Computer Configuration \> Policies \> Administrative Templates \> Windows Components \> Windows Remote Management (WinRM) \> WinRMService. Right click on Allow Remote Server Management through WinRM and select Edit. Check the Enabled radio button and set the value of IPv4 Filter & IPv6 Filter as \*.

![GPO_config_8](https://github.com/SecureDataLabs/44Con-2018-Sysmon/blob/Rustycoin/config/images/GPO_config_8.png)


## **Sysmon Deployment/Configuration Update GPO**

One of the easiest ways to deploy Sysmon is to use Group Policy to add a Startup Script, a Scheduled Task or a combination of both. This is achieved by staging the required installer, configuration and startup script files in a folder in the Domain SYSVOL folder, this ensures the files are readable by all users but can't be changed except by Domain Admins or users who have been given specific permissions.

The first step is to create a folder called "Sysmon" in replacing \<FQDN\> with your domain name. Then copy the 4 files below into that folder --

Sysmon.exe -- Standard Sysmon installer.

Sysmon64.exe -- 64 bit Sysmon installer.

SysmonStartup.bat -- Script to install and update the configuration of Sysmon, originally written by Ryan Watson (\@gentlemanwatson) with some minor changes.

Sysmonv7Config.xml -- The configuration file to be used with version 7 of Sysmon.

## **The SysmonStartup.bat file will need to be edited so that the line "SET FQDN=" has the domain name as its value.**

Once the above has been completed, on a Domain Controller, open the Group Policy Management console, and create a new GPO named "Sysmon Deployment" and open it for editing. This first part of the GPO configuration will configure a startup script.

Navigate to Computer Configuration \> Policies \> Windows Settings \> Scripts (Startup/Shutdown), right click on Startup and select Properties.

![GPO_config_9](https://github.com/SecureDataLabs/44Con-2018-Sysmon/blob/Rustycoin/config/images/GPO_config_9.png)

In the Startup Properties window, click on Add and then enter the full path to the SysmonStartup.bat file you copied to SYSVOL earlier in the Script Name field, then click OK until you are back to the main Group Policy Manager window to apply the configuration.

![GPO_config_10](https://github.com/SecureDataLabs/44Con-2018-Sysmon/blob/Rustycoin/config/images/GPO_config_10.png)

This next part of the configuration will create a scheduled task on the clients so they will pick up configuration changes in a timely fashion and also to ensure the Sysmon client is running.

Navigate to Computer Configuration \> Preferences \> Control Panel Settings \> Scheduled Tasks then right click and select New \> Scheduled Task (At least Windows 7).

![GPO_config_11](https://github.com/SecureDataLabs/44Con-2018-Sysmon/blob/Rustycoin/config/images/GPO_config_11.png)

On the General tab set the following values -- Action: Update, Name: SysMon Deployment, Security Options: NT AUTHORITY\\System & check 'Run whether user is logged on or not' radio button, Configure for: Windows 7.

![GPO_config_12](https://github.com/SecureDataLabs/44Con-2018-Sysmon/blob/Rustycoin/config/images/GPO_config_12.png)

On the Triggers tab set the following values -- Settings: Check the radio button for Daily and then for Start: Set an appropriate date and the time to 06:00:00. Advanced Settings: Check the box for 'Repeat task every' and set it to 1 hour for a duration of 12 hours and then check the box for Enabled.

![GPO_config_13](https://github.com/SecureDataLabs/44Con-2018-Sysmon/blob/Rustycoin/config/images/GPO_config_13.png)

On the Actions tab set the following values -- Action: Start a program, Settings: Enter the full UNC path for the SysmonStartup.bat file on the SYSVOL share.

![GPO_config_14](https://github.com/SecureDataLabs/44Con-2018-Sysmon/blob/Rustycoin/config/images/GPO_config_14.png)

On the Settings tab check the box for 'Allow task to be run on demand'.

![GPO_config_15](https://github.com/SecureDataLabs/44Con-2018-Sysmon/blob/Rustycoin/config/images/GPO_config_15.png)

## **Link GPO's**

In order to apply the settings to the clients the GPO's need to be linked to relevant OU's within Active Directory. To do this, in the left hand pane of the Group Policy Management console locate each OU you want to link the GPO's to and right click then select Link an Existing GPO, then select the GPO's from the list that appears.

![GPO_config_16](https://github.com/SecureDataLabs/44Con-2018-Sysmon/blob/Rustycoin/config/images/GPO_config_16.png)

