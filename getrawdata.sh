#execute in container
wget https://raw.githubusercontent.com/academyofdata/inputs/master/movies.csv
wget https://raw.githubusercontent.com/academyofdata/inputs/master/users.csv
wget https://raw.githubusercontent.com/academyofdata/inputs/master/ratings2.csv
wget https://raw.githubusercontent.com/academyofdata/inputs/master/ratings.csv.gz
gunzip ratings.csv.gz 
mv ratings.csv ratings-all.csv
mv ratings2.csv ratings.csv

