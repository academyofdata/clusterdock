function encode {
  echo $1 | tr -d "\n" | base64
}

curl -vi -X GET -H "Accept: application/json" 'http://localhost:20550/test/schema'
#commands that create an HBase table, using HBase REST server (needs to be enabled/installed if not there)
#first create a table called 'test' with a CF called 'data'
curl -v -X PUT 'http://localhost:20550/test/schema' -H "Accept: application/json" -H "Content-Type: application/json" -d '{"@name":"test","ColumnSchema":[{"name":"data"}]}'

TABLE='test'
FAMILY='data'
COL1=$(encode "$FAMILY:subcol1")
COL2=$(encode "$FAMILY:subcol2")

echo "We will send TABLE=$TABLE, KEY=$KEY, COLUMN=$COLUMN, DATA=$DATA"

for iter in `seq 100 105`;
do
  KEY=$(encode "row$iter")
  DATA1=$(encode "value of row$iter")
  DATA2=$(encode "$iter other value")
  curl -v -X PUT 'http://localhost:20550/test/zzz' -H "Accept: application/json" -H "Content-Type: application/json" -d "{\"Row\":[{\"key\":\"$KEY\", \"Cell\": [{\"column\":\"$COL1\", \"$\":\"$DATA1\"},{\"column\":\"$COL2\", \"$\":\"$DATA2\"}]}]}"
done
