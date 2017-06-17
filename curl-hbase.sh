function encode {
  echo $1 | tr -d "\n" | base64
}

FAMILY1='data'
FAMILY2='text'
TABLE='ztable'
HOST="http://127.0.0.1:20550/$TABLE"

curl -vi -X GET -H "Accept: application/json" "$HOST/schema"
#commands that create an HBase table, using HBase REST server (needs to be enabled/installed if not there)
#first create a table called 'test' with a CF called 'data'
curl -v -X PUT "$HOST/schema" -H "Accept: application/json" -H "Content-Type: application/json" -d "{\"@name\":\"ztable\",\"ColumnSchema\":[{\"name\":\"$FAMILY1\"},{\"name\":\"$FAMILY2\"}]}"

COL1=$(encode "$FAMILY1:subcol1")
COL2=$(encode "$FAMILY1:subcol2")
COL3=$(encode "$FAMILY2:subcol1")
COL4=$(encode "$FAMILY2:subcol2")

for iter in `seq 100 200`;
do
  KEY=$(encode "row$iter")
  DATA1=$(encode "value of row$iter")
  DATA2=$(encode "$iter other value")
  DATA3=`cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 16 | head -n 1`
  DATA4=`cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 8 | head -n 1`
  curl -v -X PUT "$HOST/zzz" -H "Accept: application/json" -H "Content-Type: application/json" -d "{\"Row\":[{\"key\":\"$KEY\", \"Cell\": [{\"column\":\"$COL1\", \"$\":\"$DATA1\"},{\"column\":\"$COL2\", \"$\":\"$DATA2\"},{\"column\":\"$COL3\", \"$\":\"$DATA3\"},{\"column\":\"$COL4\", \"$\":\"$DATA4\"}]}]}"
done
