# aws-transit-fnet
AWS Aviatrix Transit Firenet

This builds a simple Aviatrix Transit Firenet with

1. Primary and HA transit gateways 
2. Palo Alto Netowrks VM-Series NGFWs attached to each gateway
3. Two spoke VPCs with spoke gateways.

It also creates a bootstrap package for Palo Alto Networks VM-Series firewalls with a template that configured firewall interfaces admin and vendor integration role based access.
There are two items that are left to get this operational.

1. Aviatrix Firenet Vendor Integration
2. Aviatrix Transit Firenet Inspection policy.
