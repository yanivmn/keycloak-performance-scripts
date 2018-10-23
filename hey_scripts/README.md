# Performance benchmark to aerobase servers
## Hey
Install hey using go 
```
go get -u github.com/rakyll/hey
```

### Create "performance" client under aerobase realm and update client_secret to vegeta_kc_perf.sh
```
LIENT_SECRET="86199ca4-73e0-423c-b64f-550abe5da3b4"
CLIENT_ID="performance"
```

### Run benchmark
```
./hey_kc_perf.sh
```
