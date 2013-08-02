#how to use: execute with args being a sequence of paths to mongod binaries.  The paths must be explicit/complete
#change rhost and rport variables to point at a running mongod that will store the results of the testing
#change mperfpath to point to the directory of mongo-perf (should contain runner.py and allow for creating and 
#removing a dir called db
MPERFPATH=/Users/ace/mongo-perf
RHOST="localhost"
RPORT="27099"

cd $MPERFPATH
echo $#

while [[ $# -gt 0 ]] ; do
    echo $1
    python $MPERFPATH/runner.py --rhost=$RHOST --rport=$RPORT -l $# --mongod=$1
    rm -rf ./db
    shift
done

echo "Note: may need to remove the query on line 256 of server.py so it does not only find the most recent version one"
echo "Run server.py to see your results!"
