function encode {
  echo $1 | tr -d "\n" | base64
}

curl -vi -X GET -H "Accept: application/json" 'http://localhost:20550/test/schema'
#commands that create an HBase table, using HBase REST server (needs to be enabled/installed if not there)
#first create a table called 'test' with a CF called 'data'
curl -v -X PUT 'http://localhost:20550/test/schema' -H "Accept: application/json" -H "Content-Type: application/json" -d '{"@name":"test","ColumnSchema":[{"name":"data"}]}'

TABLE='test'
FAMILY='data'
COLUMN=$(encode "$FAMILY:$TABLE")


echo "We will send TABLE=$TABLE, KEY=$KEY, COLUMN=$COLUMN, DATA=$DATA"

for iter in `seq 100 101`;
do
  KEY=$(encode "row$iter")
  DATA=$(encode "value of row$iter")
  curl -v -X PUT 'http://localhost:20550/test/row1' -H "Accept: application/json" -H "Content-Type: application/json" -d "{\"Row\":[{\"key\":\"$KEY\", \"Cell\": [{\"column\":\"$COLUMN\", \"$\":\"$DATA\"}]}]}"
done
