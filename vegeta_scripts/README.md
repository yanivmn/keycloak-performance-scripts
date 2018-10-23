# Performance benchmark to aerobase servers
## Vegeta 
Install vegeta using go 
```
go get -u github.com/tsenart/vegeta
```

### Create "performance" client under aerobase realm and update client_secret to vegeta_kc_perf.sh
```
LIENT_SECRET="86199ca4-73e0-423c-b64f-550abe5da3b4"
CLIENT_ID="performance"
```

### Run benchmark
```
./vegeta_kc_perf.sh
```
