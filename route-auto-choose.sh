source ./route-env
echo "START $(date +%Y"-"%m"-"%d"-"%H":"%M":"%S)"
#r Get active Route
getActive ()
{

gwGet
 
  activeLine=$(grep 'a,' $invFile )
  activeGW=$( grep 'a,' $invFile | cut -d"," -f2 | head -n 1 | xargs  )
  isActiveOK=$(ping -c 10 $activeGW | grep ', 0% packet loss' | wc -l)
  
  echo Current entry : $activeLine
  if [ ${isActiveOK} -eq 1  ] ;
         then
		x=$(grep 'a,' $invFile | gawk -F "," '{print $1 "," $2","0}' )
		
		echo "Gateway is online, updating state to:"
		echo $x
		sed -i "s@$activeLine@$x@g" $invFile
		
		
		if [ $(echo $activeGW | grep $whatGW | wc -l) -eq 1 ];
		  then
			  echo "Env and Route GW are synced";
		  else
			echo Inventory: [$activeGW] and Kernel: [$whatGW];
			  echo "Unsynced but main route on inventory is online, so resyncing GW";
			  bash route-change.sh $activeGW;
		  fi

		#echo ' #In order to simulate an error, will force it to fail in the next run check'

        else
                x=$(grep 'a,' $invFile | gawk -F "," '{print $1 "," $2","$3+1}' )
                echo "Gateway is offline, updating [Failed Counter +1] to:"
                echo $x
                sed -i "s@$activeLine@$x@g" $invFile

	fi

  errorCount=$( grep 'a,' $invFile | cut -d"," -f3 | head -n 1  )

}
## Get standby Route
getStandby()
{
  standbyGW=$( grep "$1," $invFile | cut -d"," -f2 | head -n 1  )
}

## Emit found message
foundMsg(){
echo
echo " --- Found Standby: $standbyGW ";
echo " running 10 packets test before moving:"
echo 
}

## Failover inventory update 
failOver(){

#first one swaps failed main for standby (order defined in argument)
lx=$(grep "$1," $invFile | gawk -F "," -v a="$3"  '{print a","$2",0"}' )
#echo $lx
#the second swaps last standy by for secondary standby (order defined in argument)

ly=$(grep "$3," $invFile | gawk -F "," -v b="$2" '{print b","$2","$3}' )
#echo $ly
#the third one swaps failed main for standby (order defined in argument)

lz=$(grep "$2," $invFile | gawk -F "," -v c="$1" '{print c","$2",0"}' )
#echo $lz
   sleep 2
   echo;echo "old states:"
   cat $invFile

   echo $lx >> "$tmpFile" ; echo $ly  >> "$tmpFile"; echo $lz  >> "$tmpFile"
   sleep 2
   cat $tmpFile > "$invFile"
   echo; echo "new states:";
   cat $invFile

}

## Start execution
getActive
echo;echo Found : $activeGW with  $errorCount; 

    if [ ${errorCount} -gt 2 ] ;
    then
	echo "Active Gateway is offline ---> failing over..."
	#echo running special commands *beep boop beep*

	getStandby b
	foundMsg
	
	isitOK=$(ping -c 10  $standbyGW | grep ', 0% packet loss' | wc -l)

		if [ ${isitOK} -eq 1  ] ;
		then
			echo "running  bash route-change $standbyGW"
			bash route-change.sh $standbyGW
			failOver b c a 
		else
		echo Moving on to the third gw;
	        getStandby c
		foundMsg
	         
	        isitOK=$(ping -c10 $standbyGW | grep ', 0% packet loss' | wc -l)
		   if [ ${isitOK} -eq 1  ] ;
	                then
                        echo "running  bash route-change $standbyGW"
			bash route-change.sh $standbyGW
			failOver c b a
		   else 
			echo 'Send emergency email function'
		   fi
		fi
    else
	echo Not Changing it
	
	
    fi
echo '-------'

gwGet
echo Currently using gateway $whatGW  for $IP
