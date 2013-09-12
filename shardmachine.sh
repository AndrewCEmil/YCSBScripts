
#note: we assume that the mongos/mongods are all already dead

#1) initialization
MONGO_PATH=/mnt/workspace/mongo/mongo
MONGOD_PATH=/mnt/workspace/mongo/mongod
MONGOS_PATH=/mnt/workspace/mongo/mongos

#do we need port for config servers?
BASE_MONGOD_PORT=27017

#TODO base log + journal paths here
BASE_DATA_PATH=/mnt/data10/datatest

NUM_SHARDS=2
NUM_MONGOS=1

SHARD_DB="ycsb"
SHARD_COLLECTION="usertable"
SHARD_PATTERN="{_id: 1}"



#2) turn on mongods
echo "****************** turning on mongods"
#TODO NUMA fixes #TODO
CUR_MONGOD_PORT=$BASE_MONGOD_PORT
for i in `seq $NUM_SHARDS`; do
    mkdir $BASE_DATA_PATH/mongod_$i
    $MONGOD_PATH --port $CUR_MONGOD_PORT --dbpath $BASE_DATA_PATH/mongod_$i --logpath $BASE_DATA_PATH/mongod_$i/log --fork
    CUR_MONGOD_PORT=$(($CUR_MONGOD_PORT + 1))
done;

echo "******************* turning on config server"
#3) set up config server
#for now, single config server
mkdir $BASE_DATA_PATH/config
echo "$MONGOD_PATH --port $CUR_MONGOD_PORT --dbpath $BASE_DATA_PATH/config --logpath $BASE_MONGOD_PATH/config/log --fork"
$MONGOD_PATH --port $CUR_MONGOD_PORT --dbpath $BASE_DATA_PATH/config --logpath $BASE_DATA_PATH/config/log --fork
CONF_PORT=$CUR_MONGOD_PORT
CUR_MONGOD_PORT=$(($CUR_MONGOD_PORT + 1))

sleep 100
echo "********************* turning on mongos"
#4) set up mongos instaces
mkdir $BASE_DATA_PATH/mongos
for i in `seq $NUM_MONGOS`; do
    echo "$MONGOS_PATH --logpath $BASE_DATA_PATH/mongos/$i.log --configdb "localhost:$CONF_PORT" --port $CUR_MONGOD_PORT --fork"
    $MONGOS_PATH --logpath $BASE_DATA_PATH/mongos/$i.log --configdb "localhost:$CONF_PORT" --port $CUR_MONGOD_PORT --fork
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
