# Homework18 Vault

1. git clone https://github.com/hashicorp/consul-helm.git
2. kubectl create ns homework18
3. выполнил: kubectl apply -f pvc.yaml
4. helm install consul --namespace=homework18 .
5. git clone https://github.com/hashicorp/vault-helm.git
6. поправил параметры values.yaml
7. helm install vault -n homework18 .
8. helm status vault -n homework18
```angular2html
NAME: vault
LAST DEPLOYED: Wed May 10 17:27:00 2023
NAMESPACE: homework18
STATUS: deployed
REVISION: 1
NOTES:
Thank you for installing HashiCorp Vault!

Now that you have deployed Vault, you should look over the docs on using
Vault with Kubernetes available here:

https://www.vaultproject.io/docs/


Your release is named vault. To learn more about the release, try:

  $ helm status vault
  $ helm get manifest vault
```
9. kubectl exec -it -n homework18 vault-0 -- vault operator init -key-shares=1 -key-threshold=1
```angular2html
Unseal Key 1: BYoHJ6SIgAWLu9CewsnHTl87Y0BysUQ5EFeMOUi2b9I=
Initial Root Token: hvs.77Fyv0dwxxJUhjcONaJITiKn
```
10. kubectl exec -it -n homework18 vault-0 -- vault operator unseal
```angular2html
Key             Value
---             -----
Seal Type       shamir
Initialized     true
Sealed          false
Total Shares    1
Threshold       1
Version         1.13.1
Build Date      2023-03-23T12:51:35Z
Storage Type    consul
Cluster Name    vault-cluster-a5e556fb
Cluster ID      ccefc9d7-5f60-b9b4-0eb7-7a53e98fb780
HA Enabled      true
HA Cluster      https://vault-0.vault-internal:8201
HA Mode         active
Active Since    2023-05-10T14:51:02.726946939Z
```
11. kubectl exec -it -n homework18 vault-1 -- vault operator unseal
```angular2html
Key                    Value
---                    -----
Seal Type              shamir
Initialized            true
Sealed                 false
Total Shares           1
Threshold              1
Version                1.13.1
Build Date             2023-03-23T12:51:35Z
Storage Type           consul
Cluster Name           vault-cluster-a5e556fb
Cluster ID             ccefc9d7-5f60-b9b4-0eb7-7a53e98fb780
HA Enabled             true
HA Cluster             https://vault-0.vault-internal:8201
HA Mode                standby
Active Node Address    http://10.244.0.148:8200
```
12. kubectl exec -it -n homework18 vault-2 -- vault operator unseal
```angular2html
Key                    Value
---                    -----
Seal Type              shamir
Initialized            true
Sealed                 false
Total Shares           1
Threshold              1
Version                1.13.1
Build Date             2023-03-23T12:51:35Z
Storage Type           consul
Cluster Name           vault-cluster-a5e556fb
Cluster ID             ccefc9d7-5f60-b9b4-0eb7-7a53e98fb780
HA Enabled             true
HA Cluster             https://vault-0.vault-internal:8201
HA Mode                standby
Active Node Address    http://10.244.0.148:8200
```
13. kubectl exec -it -n homework18 vault-0 -- vault auth list
14. kubectl exec -it -n homework18 vault-0 -- vault login
```angular2html
Key                  Value
---                  -----
token                hvs.77Fyv0dwxxJUhjcONaJITiKn
token_accessor       qKwa9L72YWGskmC4VSsrhVOP
token_duration       в€ћ
token_renewable      false
token_policies       ["root"]
identity_policies    []
policies             ["root"]
```
15. kubectl exec -it -n homework18 vault-0 -- vault auth list
```angular2html
Path      Type     Accessor               Description                Version
----      ----     --------               -----------                -------
token/    token    auth_token_e49b80e7    token based credentials    n/a
```
16. kubectl exec -it -n homework18 vault-0 -- vault secrets enable --path=otus kv
17. kubectl exec -it -n homework18 vault-0 -- vault secrets list --detailed
18. kubectl exec -it -n homework18 vault-0 -- vault kv put otus/otus-ro/config username='otus' password='asajkjkahs'
19. kubectl exec -it -n homework18 vault-0 -- vault kv put otus/otus-rw/config username='otus' password='asajkjkahs'
20. kubectl exec -it -n homework18 vault-0 -- vault read otus/otus-ro/config
```angular2html
Key                 Value
---                 -----
refresh_interval    768h
password            asajkjkahs
username            otus
```
21. kubectl exec -it -n homework18 vault-0 -- vault kv get otus/otus-rw/config
```angular2html
====== Data ======
Key         Value
---         -----
password    asajkjkahs
username    otus
```
22. kubectl exec -it -n homework18 vault-0 -- vault auth enable kubernetes
23. kubectl exec -it -n homework18 vault-0 -- vault auth list
```angular2html
Path           Type          Accessor                    Description                Version
----           ----          --------                    -----------                -------
kubernetes/    kubernetes    auth_kubernetes_fe8e4be2    n/a                        n/a
token/         token         auth_token_e49b80e7         token based credentials    n/a
```
24. kubectl create serviceaccount -n homework18 vault-auth
25. kubectl apply --filename vault-auth-service-account.yml
### Конфигурация VAULT
26. export VAULT_SA_NAME=$(kubectl get sa vault-auth -n homework18 -o jsonpath={.metadata.name})
27. kubectl apply -f secret.yaml
28. export SA_JWT_TOKEN=$(kubectl get secret $VAULT_SA_NAME -n homework18 -o jsonpath="{.data.token}" | base64 --decode)
29. export SA_CA_CRT=$(kubectl get secret $VAULT_SA_NAME -n homework18 -o jsonpath="{.data['ca\.crt']}" | base64 --decode)
30. export K8S_HOST=$(kubectl cluster-info | grep "Kubernetes control" | awk '/https/ {print $NF}' | sed 's/\x1b\[[0-9;]*m//g')
31. kubectl exec -it -n homework18 vault-0 -- vault write auth/kubernetes/config token_reviewer_jwt="$SA_JWT_TOKEN" kubernetes_host="$K8S_HOST" kubernetes_ca_cert="$SA_CA_CRT" disable_local_ca_jwt="true"
32. создали файл otus-policy.hcl
33. kubectl cp otus-policy.hcl -n homework18 vault-0:/tmp/
34. kubectl exec -it -n homework18 vault-0 -- vault policy write otus-policy /tmp/otus-policy.hcl
35. kubectl exec -it -n homework18 vault-0 -- vault write auth/kubernetes/role/otus bound_service_account_names=vault-auth bound_service_account_namespaces=homework18 policies=otus-policy ttl=24h
36. kubectl run -n homework18 tmp --rm -i --tty --image=alpine:3.18.0 --overrides='{ "spec": { "serviceAccount": "vault-auth" }  }' --command -- sh
    1. apk add curl jq
    2. VAULT_ADDR=http://vault:8200
    3. KUBE_TOKEN=$(cat /var/run/secrets/kubernetes.io/serviceaccount/token)
    4. curl --request POST --data '{"jwt": "$KUBE_TOKEN", "role": "otus"}' $VAULT_ADDR/v1/auth/kubernetes/login | jq
    5. Получил токен: hvs.CAESIP4pPjUFuRxZiKHhzTZqkaKoMy4WZWP1Eg-K1gCG2W-kGh4KHGh2cy5KS092ZlZtOUFlMUdaQzFIeEFjSGEzdGI
    6. curl --header "X-Vault-Token:hvs.CAESIP4pPjUFuRxZiKHhzTZqkaKoMy4WZWP1Eg-K1gCG2W-kGh4KHGh2cy5KS092ZlZtOUFlMUdaQzFIeEFjSGEzdGI" $VAULT_ADDR/v1/otus/otus-ro/config
    7. curl --header "X-Vault-Token:hvs.CAESIP4pPjUFuRxZiKHhzTZqkaKoMy4WZWP1Eg-K1gCG2W-kGh4KHGh2cy5KS092ZlZtOUFlMUdaQzFIeEFjSGEzdGI" $VAULT_ADDR/v1/otus/otus-rw/config
    8. curl --request POST --data '{"bar": "baz"}' --header "X-Vault-Token:hvs.CAESIP4pPjUFuRxZiKHhzTZqkaKoMy4WZWP1Eg-K1gCG2W-kGh4KHGh2cy5KS092ZlZtOUFlMUdaQzFIeEFjSGEzdGI" $VAULT_ADDR/v1/otus/otus-ro/config
    9. curl --request POST --data '{"bar": "baz"}' --header "X-Vault-Token:hvs.CAESIP4pPjUFuRxZiKHhzTZqkaKoMy4WZWP1Eg-K1gCG2W-kGh4KHGh2cy5KS092ZlZtOUFlMUdaQzFIeEFjSGEzdGI" $VAULT_ADDR/v1/otus/otus-rw/config
    10. curl --request POST --data '{"bar": "baz"}' --header "X-Vault-Token:hvs.CAESIP4pPjUFuRxZiKHhzTZqkaKoMy4WZWP1Eg-K1gCG2W-kGh4KHGh2cy5KS092ZlZtOUFlMUdaQzFIeEFjSGEzdGI" $VAULT_ADDR/v1/otus/otus-rw/config1
    11. Ответ на вопрос: Исправил полиси добавив "update", при изменении otus/otus-rw/config

### Use case использования авторизации через кубер

1. git clone https://github.com/hashicorp/vault-guides.git
2. cd vault-guides/identity/vault-agent-k8s-demo
3. Поправил конфигурационные файлы
4. kubectl apply -f ./configmap.yaml
5. kubectl apply -f example-k8s-spec.yaml
6. Вытащил и сохранил index.html

### создадим CA на базе vault
1. kubectl exec -it -n homework18 vault-0 -- vault secrets enable pki
2. kubectl exec -it -n homework18 vault-0 -- vault secrets tune -max-lease-ttl=87600h pki
3. kubectl exec -it -n homework18 vault-0 -- vault write -field=certificate pki/root/generate/internal common_name="exmaple.ru" ttl=87600h > CA_cert.crt
4. kubectl exec -it -n homework18 vault-0 -- vault write pki/config/urls issuing_certificates="http://vault:8200/v1/pki/ca" crl_distribution_points="http://vault:8200/v1/pki/crl"
5. kubectl exec -it -n homework18 vault-0 -- vault secrets enable --path=pki_int pki
6. kubectl exec -it -n homework18 vault-0 -- vault secrets tune -max-lease-ttl=87600h pki_int
7. kubectl exec -it -n homework18 vault-0 -- vault write -format=json pki_int/intermediate/generate/internal common_name="example.ru Intermediate Authority" | jq -r '.data.csr' > pki_intermediate.csr
8. kubectl cp pki_intermediate.csr -n homework18 vault-0:/tmp/
9. kubectl exec -it -n homework18 vault-0 -- vault write -format=json pki/root/sign-intermediate csr=@/tmp/pki_intermediate.csr format=pem_bundle ttl="43800h" | jq -r '.data.certificate' > intermediate.cert.pem
10. kubectl cp intermediate.cert.pem -n homework18 vault-0:/tmp/
11. kubectl exec -it -n homework18 vault-0 -- vault write pki_int/intermediate/set-signed certificate=@/tmp/intermediate.cert.pem
12. kubectl exec -it -n homework18 vault-0 -- vault write pki_int/roles/example-dot-ru allowed_domains="example.ru" allow_subdomains=true max_ttl="720h"
13. kubectl exec -it -n homework18 vault-0 -- vault write pki_int/issue/example-dot-ru common_name="gitlab.example.ru" ttl="24h"
```angular2html
Key                 Value
---                 -----
ca_chain            [-----BEGIN CERTIFICATE-----
MIIDnDCCAoSgAwIBAgIUT6GAWJ4f0k4pjJU7O1PYwk3VPW0wDQYJKoZIhvcNAQEL
BQAwFTETMBEGA1UEAxMKZXhtYXBsZS5ydTAeFw0yMzA1MTExNDQwMjBaFw0yODA1
MDkxNDQwNTBaMCwxKjAoBgNVBAMTIWV4YW1wbGUucnUgSW50ZXJtZWRpYXRlIEF1
dGhvcml0eTCCASIwDQYJKoZIhvcNAQEBBQADggEPADCCAQoCggEBALCGNlBmaLlW
v3mD0qvbpbQ83Gx8A+kaeMahuW4tlFC+MWjjXBHdtDL1GPF4IWJ56scn0v7C0381
2qXhjiMmb3yajyPDFukHJNQ3Qmjt5xX8imxozCKVIumQJt4jL8pq93HgR3nY+g/Y
L70O7pNU0ZLL3MMCG27e5ElFgLbBwPCIStTnLWB+B7vc5Kw+dHWsfXDePxEonPLn
LhEhvOY951dxf2J1Pa1ZWtxZFNnwKX+vNsMUl9N0snd6PpI5NfPljX//zA9JgfQl
b7dP+AhHvFBiYnbzbJBZNanZMnJvvHGwwC7WDObRiVwnFyjCTbFrCHos4NgX2TeF
OxpjAKun2iECAwEAAaOBzDCByTAOBgNVHQ8BAf8EBAMCAQYwDwYDVR0TAQH/BAUw
AwEB/zAdBgNVHQ4EFgQU5iKEI2L6EkHegiLt9p585+yGUowwHwYDVR0jBBgwFoAU
S6H0P/pQEXwiwoCjhI3/zQ0l3uAwNwYIKwYBBQUHAQEEKzApMCcGCCsGAQUFBzAC
hhtodHRwOi8vdmF1bHQ6ODIwMC92MS9wa2kvY2EwLQYDVR0fBCYwJDAioCCgHoYc
aHR0cDovL3ZhdWx0OjgyMDAvdjEvcGtpL2NybDANBgkqhkiG9w0BAQsFAAOCAQEA
XErtZtg70Wk9y6+vO/5804wl3Ad6QixYdzGWnzDsmH6HmUSv47ku7niPz6mhPqVY
Ul59XyvzPgk7i/i3irW5yCZ/K0uXAS58FHzb5eQDT+1Koa7pU8OUwulntVPvH01/
o+fbqFamhINK6gpvsxepJl4bBGN77xBBV/YIox6i2cx3KPxCh7udbkhNYuHJ33n0
fP5zdHI4INdZ/yLOs/YrbNo7SB6lf7P9YHodPmWpetkvD5q+cziy6W7Qpdo9nVhM
tXldgv/nO5tF5s+uZ6KjDq1P/XcMizugbRGIQ7hvtqm4E7y6Uf5NuGzbZQ3PXYhl
sGXabOeTmY5eQl7WIThTmQ==
-----END CERTIFICATE----- -----BEGIN CERTIFICATE-----
MIIDMjCCAhqgAwIBAgIUOhBw4m1/MYXuwcJFYX4hBM6pTE8wDQYJKoZIhvcNAQEL
BQAwFTETMBEGA1UEAxMKZXhtYXBsZS5ydTAeFw0yMzA1MTExNDIxMzhaFw0zMzA1
MDgxNDIyMDdaMBUxEzARBgNVBAMTCmV4bWFwbGUucnUwggEiMA0GCSqGSIb3DQEB
AQUAA4IBDwAwggEKAoIBAQC5SQK4ZyW59ryISnpxvJpgXmQl8SYp9Cyus7m56tWo
6CUjy5YT05d1A9/MfBWC0yVLxxgtcpgjwR7a4ihNS0BgU6IdS/SMGsetO2n9mF5x
wj/XMkMChEiqCedm44ozrrv+esxuSElOHy9bV4JNyq0avsOexK9Jd+KgVu7QALdH
vt5MdzhFV1f7dVVzmef3ONuzYWZYeHFjKbFUnmy8e214ehJRpaKG9hZENlr2S9pW
9sWKTHRDAQdyC23XRrjLxP1ti11uZlsbiZLa/yyB0JYPFIa7u+FKJDkKdEukWZCw
cXSZH7OYEmt6laahxkxMlTfmGAIMnzhWDx05mnB7gLMfAgMBAAGjejB4MA4GA1Ud
DwEB/wQEAwIBBjAPBgNVHRMBAf8EBTADAQH/MB0GA1UdDgQWBBRLofQ/+lARfCLC
gKOEjf/NDSXe4DAfBgNVHSMEGDAWgBRLofQ/+lARfCLCgKOEjf/NDSXe4DAVBgNV
HREEDjAMggpleG1hcGxlLnJ1MA0GCSqGSIb3DQEBCwUAA4IBAQATmH9tlXPWwBpV
ltdy+a1o1EHyfDMWHOWxs2VXFi5kEgh9Luc6xXlX6ZZ1gEPUiO0LY7oqtRAJVvKP
pyJlawCRiXPR5L0kWgCF5Dj0xEgzDRkGtzdcWvghL0v7bOzLIhMLBWM1FjbtNFkW
RIAeHNVM4qbYVxN8JQB/EO9qLKZtYsMDiqq5E/pAAKocxYZxr+eZ1n64/YNvVnNf
ZahEb+pK+iS7n/aO2sNBSG2ARW+Wz6dh0tCc3WZYisv9S8Cb8rcJeJ5Qf8L0eN2E
R/wVkvIzbV60Rb19/pfcDW4BcTC2+6ujvQA+9rkTqIBvdMaBXNctx8P6VQ+omY++
/g+O81Z4
-----END CERTIFICATE-----]
certificate         -----BEGIN CERTIFICATE-----
MIIDZzCCAk+gAwIBAgIUJ57mtheOxJgntmb9GYAH7AwH1oIwDQYJKoZIhvcNAQEL
BQAwLDEqMCgGA1UEAxMhZXhhbXBsZS5ydSBJbnRlcm1lZGlhdGUgQXV0aG9yaXR5
MB4XDTIzMDUxMTE0NDk1MFoXDTIzMDUxMjE0NTAyMFowHDEaMBgGA1UEAxMRZ2l0
bGFiLmV4YW1wbGUucnUwggEiMA0GCSqGSIb3DQEBAQUAA4IBDwAwggEKAoIBAQC9
0snUz3Z4ZyKJJrwW4uMnf3ZPRX4s2vWU5jPu3FuPQ9zkvug1oLbsXHXRX+rFXy1Y
EQ0l+QuVR7Q9L+ZLkl2xmnE66giu59ufsjyw+NHJnVBZws0cJUjKB9KXQqssM1cH
Hd8t93b90vCdDMsUTC6IpdE2Ufra/aqRa+QMG4sii5AL0qnJERc4um/DLhEDf5ep
CK1wKb/LwhHIE+IpJRGWHMAvei1WhC4H+TXcJ7egiJtsmLIgwuii6VU3nReFkRRO
nVyuTbwAzdDMBmxfUyUT5UkDSm63zUcOGIrhh/aommtVrOjYVclKusYWp4Bi2i2Q
ZrDG2ecPaaO9hIlsyHb1AgMBAAGjgZAwgY0wDgYDVR0PAQH/BAQDAgOoMB0GA1Ud
JQQWMBQGCCsGAQUFBwMBBggrBgEFBQcDAjAdBgNVHQ4EFgQUM6RIn4n7ZiYgo2QW
vpNG8B/PGGgwHwYDVR0jBBgwFoAU5iKEI2L6EkHegiLt9p585+yGUowwHAYDVR0R
BBUwE4IRZ2l0bGFiLmV4YW1wbGUucnUwDQYJKoZIhvcNAQELBQADggEBAAk49x5L
/+9lFrdgRGhpZpnphR/fVmq4D5aIfgJMP6txGycs2p8C5p7y6dGBdDRVdGvZoxuG
6PHxabmxaPViQf9/9ZQn/gUSoC46pG2JvGBxz5kpQ+H+D0l5TVIAKlJlG0OcqbV7
LIqlGJ7tD0CgNus25FjTcUy0MZqNwPZu2T/hP5vVVD5C0wp7p+UHZtRNIJeKa1Cq
EHxUu/GqL+OTkD64VKtI/1nP6gmHwSK8ewEJQr/NiEoa9i2ZhD4ABbrZifOkQCOQ
wOroi2R9d0z+mmHxaiUXPEY1kr8t+SQvMl4GThtN3SWKn3co4dhY/RbvMsqQj0P0
t6LOQem2NfdO0YE=
-----END CERTIFICATE-----
expiration          1683903020
issuing_ca          -----BEGIN CERTIFICATE-----
MIIDnDCCAoSgAwIBAgIUT6GAWJ4f0k4pjJU7O1PYwk3VPW0wDQYJKoZIhvcNAQEL
BQAwFTETMBEGA1UEAxMKZXhtYXBsZS5ydTAeFw0yMzA1MTExNDQwMjBaFw0yODA1
MDkxNDQwNTBaMCwxKjAoBgNVBAMTIWV4YW1wbGUucnUgSW50ZXJtZWRpYXRlIEF1
dGhvcml0eTCCASIwDQYJKoZIhvcNAQEBBQADggEPADCCAQoCggEBALCGNlBmaLlW
v3mD0qvbpbQ83Gx8A+kaeMahuW4tlFC+MWjjXBHdtDL1GPF4IWJ56scn0v7C0381
2qXhjiMmb3yajyPDFukHJNQ3Qmjt5xX8imxozCKVIumQJt4jL8pq93HgR3nY+g/Y
L70O7pNU0ZLL3MMCG27e5ElFgLbBwPCIStTnLWB+B7vc5Kw+dHWsfXDePxEonPLn
LhEhvOY951dxf2J1Pa1ZWtxZFNnwKX+vNsMUl9N0snd6PpI5NfPljX//zA9JgfQl
b7dP+AhHvFBiYnbzbJBZNanZMnJvvHGwwC7WDObRiVwnFyjCTbFrCHos4NgX2TeF
OxpjAKun2iECAwEAAaOBzDCByTAOBgNVHQ8BAf8EBAMCAQYwDwYDVR0TAQH/BAUw
AwEB/zAdBgNVHQ4EFgQU5iKEI2L6EkHegiLt9p585+yGUowwHwYDVR0jBBgwFoAU
S6H0P/pQEXwiwoCjhI3/zQ0l3uAwNwYIKwYBBQUHAQEEKzApMCcGCCsGAQUFBzAC
hhtodHRwOi8vdmF1bHQ6ODIwMC92MS9wa2kvY2EwLQYDVR0fBCYwJDAioCCgHoYc
aHR0cDovL3ZhdWx0OjgyMDAvdjEvcGtpL2NybDANBgkqhkiG9w0BAQsFAAOCAQEA
XErtZtg70Wk9y6+vO/5804wl3Ad6QixYdzGWnzDsmH6HmUSv47ku7niPz6mhPqVY
Ul59XyvzPgk7i/i3irW5yCZ/K0uXAS58FHzb5eQDT+1Koa7pU8OUwulntVPvH01/
o+fbqFamhINK6gpvsxepJl4bBGN77xBBV/YIox6i2cx3KPxCh7udbkhNYuHJ33n0
fP5zdHI4INdZ/yLOs/YrbNo7SB6lf7P9YHodPmWpetkvD5q+cziy6W7Qpdo9nVhM
tXldgv/nO5tF5s+uZ6KjDq1P/XcMizugbRGIQ7hvtqm4E7y6Uf5NuGzbZQ3PXYhl
sGXabOeTmY5eQl7WIThTmQ==
-----END CERTIFICATE-----
private_key         -----BEGIN RSA PRIVATE KEY-----
MIIEpAIBAAKCAQEAvdLJ1M92eGciiSa8FuLjJ392T0V+LNr1lOYz7txbj0Pc5L7o
NaC27Fx10V/qxV8tWBENJfkLlUe0PS/mS5JdsZpxOuoIrufbn7I8sPjRyZ1QWcLN
HCVIygfSl0KrLDNXBx3fLfd2/dLwnQzLFEwuiKXRNlH62v2qkWvkDBuLIouQC9Kp
yREXOLpvwy4RA3+XqQitcCm/y8IRyBPiKSURlhzAL3otVoQuB/k13Ce3oIibbJiy
IMLooulVN50XhZEUTp1crk28AM3QzAZsX1MlE+VJA0put81HDhiK4Yf2qJprVazo
2FXJSrrGFqeAYtotkGawxtnnD2mjvYSJbMh29QIDAQABAoIBABbuWN1xdoFTDDP/
TueA3yoNVtB6t6RZiyNCr/FiA1mKPCwR9+FKme5xuPXjHWxcdBDYdnso28Jb2CUw
HSTx+ImU+6q/TO88KSbglD5YwJcXfvZo9vg4dNObIFCPiDgdt5yveh+GboR5MAH4
4quADHsLdPuX6bL8w9cvbmwcA7HXbsZCd+5UX1/jU1gFLALU9TPCkrRl/BAQ08hj
7BcdKjJW6cc0JLMB/51IWgZVK41rxlGQABLddfUdgS1YspgOWSCn/Ms2jKZgPQvT
BJf5yrwLCHHOqRVVUYc7o9Fb83HyCQ43scDzvUGT2lk45NBlLgj3ZjvmnTNNvN8h
ZYLcIt0CgYEAycjn5bDV8KPhpWWrmGJI88JkuoiEnogCdqvJUkTKIO7v94Tbtra3
bIosH0bmR1XvL3vPAv4ba2dYF6EQNokLeihQDNAHF8b8SdbfcupR3ZmI2kgbL6w3
ZNB6K2D/zb3GCgmF9gECVSVo/BkpS3o3/2/Z+brvuyQBYP0ajuGelocCgYEA8NMo
ZClseM1YvAeLlrvkJr1KZZmIViGroKICDOZaDpRR3myqsHeuZ6/K+fnxJ0I/BSKb
QxtcipGQlZwuRGTF+eUT3p94JsyHNONdm56kAC7+nI5EZa+1F4tIdL8bxxLQJOL5
EMNLXPN0Y+/fNkHpd0wwQuuNRLk5f3teepV1KaMCgYEAgwJTvYdgf8qHGFG4ZUl6
v/i4WXuFT0BTCSVjomxTJ6q6VmQGGszqrifPmcb4f9xFXPjvYKwGtWb1hPHniuDT
eM5vmsH9uOxSpMZDcWK9IDks5zvlmsAffu70QvHJY5UQ3TdtqFjjYNDXJsZXT0/c
x5WhWkiKmWA5HPV3psjJpEUCgYEA2dnafwkt8/WmoKmer6OWlyjDJTeHKotY633C
pxK2QtwPV0sr+Wi6n1daIVnlueLmiWmt1D3rL/rQNVbMT9htc0qz976AfXClmsVX
B5CxwOzCLLNR0j7pbbv0to+uvB4bplKghnZ0NUiScFksrbNgVCfavJ7C83kvN1BN
vkx3aUsCgYBR7AwRQ1Rrz53vulMmM1pgrGtAlx7aPJORIYyBsO6AoJonOGFqwIhe
TLiZCbefwhA75RGiSii+C5H4elAyTUnZkYbBLiC6hjXBxYJpf9HOx124MkgpjLWX
WFHwQWMZk8bz/VRACsOMYmlCnOoU0DLi8IsQ9DSkRhpGLE+hre/Guw==
-----END RSA PRIVATE KEY-----
private_key_type    rsa
serial_number       27:9e:e6:b6:17:8e:c4:98:27:b6:66:fd:19:80:07:ec:0c:07:d6:82
```
14. s/n: 27:9e:e6:b6:17:8e:c4:98:27:b6:66:fd:19:80:07:ec:0c:07:d6:82
15. kubectl exec -it -n homework18 vault-0 -- vault write pki_int/revoke serial_number="27:9e:e6:b6:17:8e:c4:98:27:b6:66:fd:19:80:07:ec:0c:07:d6:82"
