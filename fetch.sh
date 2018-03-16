
echo "=========DATE: $(date)" 

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

repo_list=$(cat ${DIR}/repo_list.txt)
echo "repo_list: $repo_list"
if [ ! -d $DIR/lucy ] ; then
    echo "mkdir $DIR/lucy"
    mkdir $DIR/lucy
fi

for repo in $repo_list;do
    echo "--Fetching $rep..."
    if [ ! -d $DIR/lucy/$repo ]; then
	echo "-Checking out $repo"
	git clone git@git.gitlab-sj.thalesesec.com:lucy/${repo}.git $DIR/lucy/$repo
    fi	
    pushd .
    cd $DIR/lucy/$repo
    echo "-update latest master"
    git pull origin master
    popd
done

## compose data.js
rm -f data.js || true
echo "var apis = [" > data.js
for repo in $repo_list ; do
    if [ -f $DIR/lucy/$repo/swagger.yaml ]; then
	echo " {" >> data.js
	echo "  name: '$repo'," >> data.js
	echo "  url: 'http://192.168.16.86/Lucy_api/lucy/${repo}/swagger.yaml'" >> data.js
	echo " }," >> data.js

    elif [ -f $DIR/lucy/$repo/swagger.yml ]; then
	echo " {" >> data.js
	echo "  name: '$repo'," >> data.js
	echo "  url: 'http://192.168.16.86/Lucy_api/lucy/${repo}/swagger.yml'" >> data.js
	echo " }," >> data.js


    else
	echo "$DIR/lucy/$repo/swagger.yaml does not exist"
    fi
done
echo "];" >> data.js

echo "===================="
cat data.js

