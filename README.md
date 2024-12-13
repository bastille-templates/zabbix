## Now apply template to container
```sh
bastille create zabbix 14.1-RELEASE 10.0.0.10

bastille bootstrap https://github.com/bastille-templates/zabbix
bastille template zabbix bastille-templates/zabbix
```

## License
This project is licensed under the BSD-3-Clause license.