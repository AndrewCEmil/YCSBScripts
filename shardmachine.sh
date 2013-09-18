
#note: we assume that the mongos/mongods are all already dead

#1) initialization
CONF_PATH=/mnt/workspace/YCSBScripts/shardconf.sh
. $CONF_PATH

#2) turn on mongods
echo "****************** turning on mongods"
#TODO NUMA fixes #TODO
CUR_MONGOD_PORT=$BASE_MONGOD_PORT
for i in `seq $NUM_SHARDS`; do
    mkdir $BASE_DATA_PATH/mongod_$i
    mkdir $BASE_DUR_PATH/mongod_$i
    ln -s $BASE_DUR_PATH/mongod_$i/ $BASE_DATA_PATH/mongod_$i/journal
    echo "$MONGOD_PATH --port $CUR_MONGOD_PORT --dbpath $BASE_DATA_PATH/mongod_$i --logpath $BASE_LOG_PATH/mongod_log_$i --fork"
    numactl --interleave=all $MONGOD_PATH --port $CUR_MONGOD_PORT --dbpath $BASE_DATA_PATH/mongod_$i --logpath $BASE_LOG_PATH/mongod_$i.log --fork
    CUR_MONGOD_PORT=$(($CUR_MONGOD_PORT + 1))
done;

echo "******************* turning on config server"
#3) set up config server
#for now, single config server
mkdir $BASE_DATA_PATH/config
mkdir $BASE_DUR_PATH/mongod_config
ln -s $BASE_DUR_PATH/mongod_config/ $BASE_DATA_PATH/mongod_$i/journal
echo "$MONGOD_PATH --port $CUR_MONGOD_PORT --dbpath $BASE_DATA_PATH/config --logpath $BASE_LOG_PATH/config_log --fork"
numactl --interleave=all $MONGOD_PATH --port $CUR_MONGOD_PORT --dbpath $BASE_DATA_PATH/config --logpath $BASE_LOG_PATH/config.log --fork
CONF_PORT=$CUR_MONGOD_PORT
CUR_MONGOD_PORT=$(($CUR_MONGOD_PORT + 1))

sleep 100
echo "********************* turning on mongos"
#4) set up mongos instaces
mkdir $BASE_DATA_PATH/mongos
for i in `seq $NUM_MONGOS`; do
    numactl --interleave=all $MONGOS_PATH --logpath $BASE_LOG_PATH/mongos_$i.log --configdb "localhost:$CONF_PORT" --port $CUR_MONGOD_PORT --fork
    CUR_MONGOD_PORT=$(($CUR_MONGOD_PORT + 1))
done;
MONGOS_PORT=$(($CUR_MONGOD_PORT - 1))

sleep 100 
#5) start up cluster
echo "*********************** initializing cluster"
#first we sleep to allow all the wakeups to occur
TEMP_MONGOD_PORT=$BASE_MONGOD_PORT
for i in `seq $NUM_SHARDS`; do
    $MONGO_PATH --port $MONGOS_PORT --eval "sh.addShard('localhost:$TEMP_MONGOD_PORT')"
    TEMP_MONGOD_PORT=$(($TEMP_MONGOD_PORT + 1))
done

#enable sharding for the db
$MONGO_PATH --port $MONGOS_PORT --eval "sh.enableSharding('$SHARD_DB')"
$MONGO_PATH --port $MONGOS_PORT --eval "sh.shardCollection('$SHARD_DB.$SHARD_COLLECTION', $SHARD_PATTERN)"

echo "done!"
