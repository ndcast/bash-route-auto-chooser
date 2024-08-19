# bash-route-auto-chooser
A bash script that can be used on a cronjob for auto choosing a predetermined route for a certain IP

Usage:

Edit route-env with the desired 
   - Destination IP  to be routed
   - Ammount of retries before failover

Add to crontab:

*/1 * * * * cd /root/gw-healthcheck; bash route-auto-choose.sh >> /var/log/route-change.log

Additional,
Can be run manually after sellecting the routed IP in the route-env file.

   bash route-change.sh the.new.gw.ip

# Example of log entry
![image](https://github.com/user-attachments/assets/80899fc6-af79-4cdc-8209-732f586b5864)
