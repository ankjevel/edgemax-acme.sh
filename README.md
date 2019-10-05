# acme-dns-challenge for EdgeMAX-router

This will run the **acme challenge** on an set inteval on a EdgeMax-router
This uses python2 for the xml-parser, since none really exist on and the router
(and I am not writing a parser using regexp).

How to make it work:

- ssh into router
- place [acme.sh](https://github.com/Neilpang/acme.sh)-script in `/config/.acme.sh/acme.sh`
- place `dns_glesys.sh` and `helper/` in `/config/.acme.sh/`
- place `renew.acme.sh` in `/config/scripts/`
- create new task in EdgeMAX-gui (Config Tree)
  - system / task-scheduler / task

configuration in gui:

```
task name: any
interval: 30d or 90d
executable:
  arguments: `-d example.com -d *.example.com -u cl11223 -k 00112233445566778899aabbccddeeff00112233
  path: /config/scripts/renew.acme.sh
```
