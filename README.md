# Setupp

```powershell
podman run -e "ACCEPT_EULA=Y" -e "MSSQL_SA_PASSWORD=root_User_@123!" -e "MSSQL_PID=Express" -p 1434:1433 -d --hostname sqlserver2019 mcr.microsoft.com/mssql/server:2019-latest 
```