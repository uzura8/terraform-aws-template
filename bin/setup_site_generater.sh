# include config file

## include config file
CONFIG_FILE="`dirname $0`/setup.conf"
if [ ! -f $CONFIG_FILE ]; then
  echo "Not found config file : ${CONFIG_FILE}" ; exit 1
fi
. $CONFIG_FILE


GIT_REPO_URL=$1
STRAGE_NAME=$2

## For Debug
#echo $GIT_REPO_URL
#echo $STRAGE_NAME
#${PIP} --version
#${PYTHON} --version

cd var/
git clone ${GIT_REPO_URL} site-generator
cd site-generator
${PIP} install -r requirements.txt
cp config.yml.sample config.yml
cp content/en.yml.sample content/en.yml
cp content/ja.yml.sample content/ja.yml
${PYTHON} builder.py
