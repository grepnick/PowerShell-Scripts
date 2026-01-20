certutil.exe -generateSSTFromWU C:\roots.sst
Get-ChildItem -Path C:\roots.sst | Import-Certificate -CertStoreLocation Cert:\LocalMachine\Root
