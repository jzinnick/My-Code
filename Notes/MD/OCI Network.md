Hi John!!  This is DONE!  There was a small complication that I overlooked when setting up the rules and had to go back in and fix it. 10.3.24.162, 10.3.24.164 & 192.168.3.143 are ALL overlap IP’s with FedEx.  So outside of the FSC network nobody could get to those IP’s as they belong to other FedEx OpCo’s.  

FSC’s allocated IP’s are in the 10.192.0.0/13 range (10.192.0.1 thru 10.199.255.254) so what I had to do is create NAT’s so that the FXL OCI network could access those devices.  Here is how they are broken out:

10.197.255.40	10.3.24.164
10.197.255.41	10.3.24.162
10.197.255.42	192.168.3.143


So when the traffic is coming from the FXL OCI 10.60.50.x IP’s you will go to the NAT’s above and NOT the native 10.3.24.x or 192.168.3.x IP’s.  Please test and let me know if everything is working.


[11:43 AM] Alexander Tucker
    fwnattrfdb02.genco.com
​[11:43 AM] Alexander Tucker
    10.3.24.164
​