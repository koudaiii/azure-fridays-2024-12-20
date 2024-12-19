# azure-fridays-2024-12-20

## Setup

* required Azure subscription and az cli
* Contribute role

```console
$ script/bootstrap

# Check client_id = appId, client_secret = password, tenant_id = tenant
$ cat principal.json

# Set `client_id`, `client_secret`, `tenant_id`, `subscription_id` in variables.auto.pkrvars.hcl
$ cp variables.auto.pkrvars.hcl.sample variables.auto.pkrvars.hcl
$ {EDITOR} variables.auto.pkrvars.hcl

$ packer build .
```

create vm using image on https://portal.azure.com/

* ISUCON14 ref https://github.com/isucon/isucon14
* Create VM Image ref https://github.com/matsuu/aws-isucon/blob/main/isucon14
* Create Image Gallery on Azure ref https://github.com/tsubasaxZZZ/azure-isucon/tree/main/isucon14
