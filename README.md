# bash-route-auto-chooser
A bash script that can be used on a cronjob for auto choosing a predetermined route for a certain IP

Usage:

Edit route-env with the desired 
   - Destination IP  to be routed
   - Ammount of retries before failover

Add to crontab
*/1 * * * * cd /root/gw-healthcheck; bash route-auto-choose.sh >> /var/log/route-change.log

Additional,
Can be run manually after sellecting the routed IP in the route-env file.

   bash route-change.sh the.new.gw.ip

# Example of log entry

START 2024-08-18-05:32:01
Current entry : a,10.10.20.1,0
Gateway is online, updating state to:
a,10.10.20.1,0
Env and Route GW are synced

Found : 10.10.20.1 with 0
Not Changing it
-------
Currently using gateway 10.10.20.1 for 142.250.186.78


START 2024-08-18-05:33:01
Current entry : a,10.10.20.1,0
Gateway is offline, updating [Failed Counter +1] to:
a,10.10.20.1,1

Found : 10.10.20.1 with 1
Active Gateway is offline ---> failing over...

 --- Found Standby: 172.16.30.1 
 running 10 packets test before moving:

running  bash route-change 172.16.30.1

Current Gateway for 142.250.186.78 is 10.10.20.1
Full line:
142.250.186.78 via 10.10.20.1 dev wgclient src 10.10.20.11 uid 0 
    cache 

You have selected [172.16.30.1] as new Gateway
Kernel IP routing table
Destination     Gateway         Genmask         Flags Metric Ref    Use Iface
0.0.0.0         10.0.100.1      0.0.0.0         UG    0      0        0 ens20
10.0.100.0      0.0.0.0         255.255.255.240 U     0      0        0 ens20
10.10.20.0      0.0.0.0         255.255.255.0   U     0      0        0 wgclient
172.16.30.0     0.0.0.0         255.255.255.0   U     0      0        0 ens18
172.16.30.0     172.16.30.1     255.255.255.0   UG    0      0        0 ens18
Trying 142.250.186.78...
Connected to 142.250.186.78.
Escape character is '^]'.
 
Current Gateway for 142.250.186.78 is 172.16.30.1
Full line:
142.250.186.78 via 172.16.30.1 dev ens18 src 172.16.30.125 uid 0 
    cache 

old states:
#priority,ip,failed_count
c,10.0.100.1,0
a,10.10.20.1,1
b,172.16.30.1,0

new states:
#priority,ip,failed_count
a,172.16.30.1,0
c,10.10.20.1,1
b,10.0.100.1,0
-------
Currently using gateway 172.16.30.1 for 142.250.186.78
