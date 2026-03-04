./setup.sh
make rebuild 2>&1 | tee rebuild.log 
make sync 2>&1 | tee sync.log 
