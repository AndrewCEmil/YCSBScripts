MONGO_PATH=/mnt/workspace/mongo/mongo
MONGOD_PATH=/mnt/workspace/mongo/mongod
MONGOS_PATH=/mnt/workspace/mongo/mongos

#do we need port for config servers?
BASE_MONGOD_PORT=27017

#TODO base log + journal paths here
BASE_DATA_PATH=/mnt/data10/datatest
BASE_LOG_PATH=/mnt/log10/datatest
BASE_DUR_PATH=/mnt/journal10/datatest

NUM_SHARDS=2
NUM_MONGOS=1

SHARD_DB="ycsb"
SHARD_COLLECTION="usertable"
SHARD_PATTERN="{_id: 1}"
