#install pdfminer.six – will only produce Terminal output, if already installed
pip install pdfminer.six

#install pdfannots
curl -s -L https://github.com/0xabu/pdfannots/archive/refs/heads/master.zip -o $HOME/Downloads/pdfannots_install.zip
mkdir -p /usr/local/lib/python3.9/site-packages/pdfannots-master/
unzip -q -o $HOME/Downloads/pdfannots_install.zip -d /usr/local/lib/python3.9/site-packages/
rm $HOME/Downloads/pdfannots_install.zip
temp=$PWD
cd /usr/local/lib/python3.9/site-packages/pdfannots-master/
python3 setup.py install
cd $temp
echo 'pdf-annots installation finished'
