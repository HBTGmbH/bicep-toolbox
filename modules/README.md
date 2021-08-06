# vm.bicep

Deploys a Virtual Machine.

```bash
az deployment group create --resource-group <resource group> --template-file vm.bicep
```

## Deployment Parameter

| Name           | Description                                               | Type   | Default                 |
| ---------------| ----------------------------------------------------------| ------ | ----------------------- |
| name           | Name of the virtual machine, also used for resource names | string |                         |
| location       | Azure region                                              | string | resource group location |
| instanceSize   | Size resp. type of the virtual machine                    | string | Standard_B2s            |
| network        | Name of the Virtual Network                               | string |                         |
| subnet         | Name of the Subnet                                        | string | default                 |
| adminUser      | Username to login with SSH                                | string |                         |
| adminPassword  | Password to login with SSH                                | string |                         |
