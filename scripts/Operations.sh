#!/bin/sh
#
#
export SCR_HOME=[[[ScriptHomeDirectory]]]
export TIBEMS_ADMIN=[[[TIBCO_EMS_BIN_Directory]]]
export SCR=${SCR_HOME}/scripts
export CFG=${SCR_HOME}/config
export TMP=${SCR_HOME}/tmp

#Checking for correct input and active status of EMS
${TIBEMS_ADMIN}/tibemsadmin -server $EMS -user $USER -password $PW -script ${SCR}/Exit.txt > ${TMP}/exitresult_${env}.txt
tail -n +9 ${TMP}/exitresult_${env}.txt > ${TMP}/exitresult_${env}_tmp.txt && mv ${TMP}/exitresult_${env}_tmp.txt ${TMP}/exitresult_${env}.txt

if [ -s ${TMP}/exitresult_${env}.txt ];
then
		#Data Collection
        ${TIBEMS_ADMIN}/tibemsadmin -server $EMS -user $USER -password $PW -script ${SCR}/EMSCheck.txt > ${TMP}/emsinfo_${env}.txt
	    ${TIBEMS_ADMIN}/tibemsadmin -server $EMS -user $USER -password $PW -script ${SCR}/QueuesCheck.txt > ${TMP}/queues_${env}.txt
        ${TIBEMS_ADMIN}/tibemsadmin -server $EMS -user $USER -password $PW -script ${SCR}/TopicsCheck.txt > ${TMP}/topics_${env}.txt

	    #Processing data for further operation
        tail -n +10 ${TMP}/emsinfo_${env}.txt > ${TMP}/emsinfo_${env}_tmp.txt && mv ${TMP}/emsinfo_${env}_tmp.txt ${TMP}/emsinfo_${env}.txt
	    tail -n +11 ${TMP}/queues_${env}.txt | sed 's/Queue Name/Queue-Name/' > ${TMP}/queues_${env}_tmp.txt && mv ${TMP}/queues_${env}_tmp.txt ${TMP}/queues_${env}.txt
        tail -n +11 ${TMP}/topics_${env}.txt | sed 's/Topic Name/Topic-Name/' > ${TMP}/topics_${env}_tmp.txt && mv ${TMP}/topics_${env}_tmp.txt ${TMP}/topics_${env}.txt

		Status=`cat ${TMP}/emsinfo_${env}.txt | awk NR==3'{print$2}'`
		Active="active" #For active status of EMS
fi

#Printing Actions and Output Format Operations
if [ "$Status" == "$Active" ];
then
		echo "_____________________________________________________________"
        echo "Current statistics of the EMS are as follows :"
        cat ${TMP}/emsinfo_${env}.txt
		echo "_____________________________________________________________"

		echo "Top 10 queues having most number of pending messages :"
		cat ${TMP}/queues_${env}.txt | awk '{ if ($1 == "*") {$1 = " "; print} else { print }; }' | awk '{$8=$9=$10=""; print $0}' | column -t | sed 's/  Kb/Kb/g' | sed 's/  MB/MB/g' | sed 's/  GB/GB/g' > ${TMP}/queues_${env}_tmp.txt && mv ${TMP}/queues_${env}_tmp.txt ${TMP}/queues_${env}.txt

		cat ${TMP}/queues_${env}.txt | awk '{ if ($1 == "*") {$1 = " "; print} else { print }; }' | awk '{$7=$8=$9=$10=""; print $0}' | column -t | head -1 > tmp/queues_${env}_head.txt

		tail -n +2 ${TMP}/queues_${env}.txt > ${TMP}/queues_${env}_tmp.txt
		cat tmp/queues_${env}_head.txt > ${TMP}/queues_${env}.txt
		cat ${TMP}/queues_${env}_tmp.txt >> ${TMP}/queues_${env}.txt

		head -1 ${TMP}/queues_${env}.txt > ${TMP}/queues_${env}_Kb.txt
		awk '$7 == "Kb" { print }' ${TMP}/queues_${env}.txt >> ${TMP}/queues_${env}_Kb.txt
		awk 'NR == 1; NR > 1 {print $0 | "sort -nrk5"}' ${TMP}/queues_${env}_Kb.txt >> ${TMP}/queues_${env}_tmp_Kb.txt
		
		mv ${TMP}/queues_${env}_tmp_Kb.txt ${TMP}/queues_${env}_Kb.txt

		head -1 ${TMP}/queues_${env}.txt > ${TMP}/queues_${env}_MB.txt
		awk '$7 == "MB" { print }' ${TMP}/queues_${env}.txt >> ${TMP}/queues_${env}_MB.txt
		awk 'NR == 1; NR > 1 {print $0 | "sort -nrk5"}' ${TMP}/queues_${env}_MB.txt >> ${TMP}/queues_${env}_tmp_MB.txt
        mv ${TMP}/queues_${env}_tmp_MB.txt ${TMP}/queues_${env}_MB.txt

		head -1 ${TMP}/queues_${env}.txt > ${TMP}/queues_${env}_GB.txt
		awk '$7 == "GB" { print }' ${TMP}/queues_${env}.txt >> ${TMP}/queues_${env}_GB.txt
		awk 'NR == 1; NR > 1 {print $0 | "sort -nrk5"}' ${TMP}/queues_${env}_GB.txt >> ${TMP}/queues_${env}_tmp_GB.txt
        mv ${TMP}/queues_${env}_tmp_GB.txt ${TMP}/queues_${env}_GB.txt

		GB_Q=`cat ${TMP}/queues_${env}_GB.txt | wc -l`
		MB_Q=`cat ${TMP}/queues_${env}_MB.txt | wc -l`
		Kb_Q=`cat ${TMP}/queues_${env}_Kb.txt | wc -l`

		if [ "$GB_Q" -gt 1 -a "$GB_Q" -lt 11 ];
		then 
				cat ${TMP}/queues_${env}_GB.txt
				GB_q=$((GB_Q-1))
				RemG_Q1=$((10-GB_q))
				if [ "$RemG_Q1" -gt 0 -a "$MB_Q" -ge 1 ];
				then
						tail -n +2 ${TMP}/queues_${env}_MB.txt | head -n $RemG_Q1
						RemG_Q1_trace=`tail -n +2 ${TMP}/queues_${env}_MB.txt | head -n $RemG_Q1 | wc -l`
						RemG_Q2=$((RemG_Q1-RemG_Q1_trace))

						if [ "$RemG_Q2" -gt 0 ];
						then
								tail -n +2 ${TMP}/queues_${env}_Kb.txt | head -n $RemG_Q2
						fi
				fi

		elif [ "$GB_Q" -ge 11 ];
		then 
				head -11 ${TMP}/queues_${env}_GB.txt

		elif [ "$GB_Q" -le 1 ];
		then
				if [ "$MB_Q" -gt 1 -a "$MB_Q" -lt 11 ];
                then
                		cat ${TMP}/queues_${env}_MB.txt
                        MB_q=$((MB_Q-1))
                        RemM_Q1=$((10-MB_q))
	                    if [ "$RemM_Q1" -gt 0 -a "$Kb_Q" -gt 1 ];
        	            then
                	    		tail -n +2 ${TMP}/queues_${env}_Kb.txt | head -n $RemM_Q1
						fi

				elif [ "$MB_Q" -ge 11 ];
                then
	            		head -11 ${TMP}/queues_${env}_MB.txt
				
				elif [ "$MB_Q" -le 1 ];
	            then
						head -11 ${TMP}/queues_${env}_Kb.txt
				fi
		fi

		echo "_____________________________________________________________"

		echo "Top 10 topics having most number of pending messages :"
        cat ${TMP}/topics_${env}.txt | awk '{ if ($1 == "*") {$1 = " "; print} else { print }; }' | awk '{$8=$9=$10=""; print $0}' | column -t | sed 's/  Kb/Kb/g' | sed 's/  MB/MB/g' | sed 's/  GB/GB/g' > ${TMP}/topics_${env}_tmp.txt && mv ${TMP}/topics_${env}_tmp.txt ${TMP}/topics_${env}.txt

		cat ${TMP}/topics_${env}.txt | awk '{ if ($1 == "*") {$1 = " "; print} else { print }; }' | awk '{$7=$8=$9=$10=""; print $0}' | column -t | head -1 > ${TMP}/topics_${env}_head.txt

		tail -n +2 ${TMP}/topics_${env}.txt > ${TMP}/topics_${env}_tmp.txt
		cat ${TMP}/topics_${env}_head.txt > ${TMP}/topics_${env}.txt
		cat ${TMP}/topics_${env}_tmp.txt >> ${TMP}/topics_${env}.txt

        head -1 ${TMP}/topics_${env}.txt > ${TMP}/topics_${env}_Kb.txt
        awk '$7 == "Kb" { print }' ${TMP}/topics_${env}.txt >> ${TMP}/topics_${env}_Kb.txt
        awk 'NR == 1; NR > 1 {print $0 | "sort -nrk5"}' ${TMP}/topics_${env}_Kb.txt >> ${TMP}/topics_${env}_tmp_Kb.txt
        mv ${TMP}/topics_${env}_tmp_Kb.txt ${TMP}/topics_${env}_Kb.txt
                        
		head -1 ${TMP}/topics_${env}.txt > ${TMP}/topics_${env}_MB.txt
        awk '$7 == "MB" { print }' ${TMP}/topics_${env}.txt >> ${TMP}/topics_${env}_MB.txt
        awk 'NR == 1; NR > 1 {print $0 | "sort -nrk5"}' ${TMP}/topics_${env}_MB.txt >> ${TMP}/topics_${env}_tmp_MB.txt
        mv ${TMP}/topics_${env}_tmp_MB.txt ${TMP}/topics_${env}_MB.txt
                       
		head -1 ${TMP}/topics_${env}.txt > ${TMP}/topics_${env}_GB.txt
        awk '$7 == "GB" { print }' ${TMP}/topics_${env}.txt >> ${TMP}/topics_${env}_GB.txt
        awk 'NR == 1; NR > 1 {print $0 | "sort -nrk5"}' ${TMP}/topics_${env}_GB.txt >> ${TMP}/topics_${env}_tmp_GB.txt
        mv ${TMP}/topics_${env}_tmp_GB.txt ${TMP}/topics_${env}_GB.txt

        GB_T=`cat ${TMP}/topics_${env}_GB.txt | wc -l`
        MB_T=`cat ${TMP}/topics_${env}_MB.txt | wc -l`
        Kb_T=`cat ${TMP}/topics_${env}_Kb.txt | wc -l`

        if [ "$GB_T" -gt 1 -a "$GB_T" -lt 11 ];
        then
        		cat ${TMP}/topics_${env}_GB.txt
                GB_t=$((GB_T-1))
                RemG_T1=$((10-GB_t))
                if [ "$RemG_T1" -gt 0 -a "$MB_T" -ge 1 ];
                then
                		tail -n +2 ${TMP}/topics_${env}_MB.txt | head -n $RemG_T1
                        RemG_T1_trace=`tail -n +2 ${TMP}/topics_${env}_MB.txt | head -n $RemT1 | wc -l`
						RemG_T2=$((RemT1-RemG_T1_trace))

                        if [ "$RemG_T2" -gt 0 ];
                        then
                        		tail -n +2 ${TMP}/topics_${env}_Kb.txt | head -n $RemG_T2
                        fi
                fi

        elif [ "$GB_T" -ge 11 ];
        then
        		head -11 ${TMP}/topics_${env}_GB.txt

        elif [ "$GB_T" -le 1 ];
        then
        		if [ "$MB_T" -gt 1 -a "$MB_T" -lt 11 ];
                then
                		cat ${TMP}/topics_${env}_MB.txt
                        MB_t=$((MB_T-1))
                        RemM_T1=$((10-MB_t))
                        if [ "$RemM_T1" -gt 0 -a "$Kb_T" -gt 1 ];
                        then
								tail -n +2 ${TMP}/topics_${env}_Kb.txt | head -n $RemM_T1
	                    fi

                elif [ "$MB_T" -ge 11 ];
                then
                		head -11 ${TMP}/topics_${env}_MB.txt

                elif [ "$MB_T" -le 1 ];
                then
                		head -11 ${TMP}/topics_${env}_Kb.txt
                fi
        fi
			
		echo "_____________________________________________________________"

		rm -rf ${TMP}/queues_*txt ${TMP}/topics_*.txt ${TMP}/emsinfo_*.txt ${TMP}/exitresult_*.txt

elif [ "$Status" != "$Active" ];
then
		echo "Unable to connect to EMS URL. Kindly check if the EMS URL, User name,and Password are corect. Also, kindly check if EMS is up and running, and not in standby or hung status"
fi
exit