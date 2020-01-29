# EMSHealthCheck



	Conduct EMS Health Check to print important runtime information.

Objective: Quickly print important information about EMS, top 10 queues and topics with highest number and largest size of pending messages.

Usage Methodology: It can be used manually any time on any machine that has TIBCO EMS's 'tibemsadmin' utility present. It can be used for two types of inputs.

	1.	Pre-configured standalone EMS instances or EMS FT pairs.
	2.	Any EMS instance or FT pair, details of which aren't pre-configured but can be provided as user input.

Changes Required in Scripts: Few changes are required in scripts to make the solution compatible with, and aware of the environment/server on which it has to run. Also, if required, details of pre-configured EMS instances have to be registered in configuration files.

	1.	Go to the path where you have placed the scripted solution.
	2.	Open script named EMSHealthCheck.sh
	3.	Change [[[ScriptHomeDirectory]]] with relevant script home path.
	4.	Save and Close script EMSHealthCheck.sh
	5.	Further, go to the path- scripts/
	6.	Open script Operations.sh
	7.	Replace [[[ScriptHomeDirectory]]] with relevant script home path.
	8.	Replace [[[TIBCO_EMS_BIN_Directory]]] with relevant 'tibemsadmin' utility path.
	9.	Save and Close script Operations.sh
	10.	Repeat steps 7 and 8 for script Operations_FT.sh
	11.	Save and Close script Operations_FT.sh

Changes required in configuration files: EMS URL, User name, Password, etc. are to be provided in configuration files for pre-configured EMS.

[Only in case you wish to use the functionality of conducting quick health check of any Pre-Configured EMS, otherwise you can skip this section. This spares the user from entering the EMS details manually every time the script is triggered.]

	1.	Go to the path where you have placed the scripted solution.
	2.	Further, go to the path- config/
	3.	Two of the files namely Project1_Standalone.cfg and Project2_Standalone.cfg are defined for andalone EMS instances whereas Project3_FT.cfg and Project4_FT.cfg are defined for EMS FT irs.
	4.	Open configuration file Project1_Standalone.cfg
	5.	Replace dummy values of variables- env, EMS, USER, PW with real appropriate values.
	6.	Save and Close configuration file Project1_Standalone.cfg
	7.	Repeat steps 4 and 5 for configuration file Project2_Standalone.cfg
	8.	Open configuration file Project3_FT.cfg
	9.	Replace dummy values of variables- env, EMS1, EMS2, USER, PW with real appropriate values.
	10.	Save and Close configuration file Project3_FT.cfg
	11.	Repeat steps 9 and 10 for configuration file Project4_FT.cfg

Usage Command: As it is a Unix Shell scripted solution, kindly use the below command to trigger it.

	1.	Go to the path- [[[ScriptHomeDirectory]]]
	2.	Run the Command- ./EMSHealthCheck.sh

Mandatory Requirements: TIBCO EMS utility namely 'tibemsadmin' should be present on the Unix machine on which this scripted solution has to be used and should be accessible to it without any permissions issue.
