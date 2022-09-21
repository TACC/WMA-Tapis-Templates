FULL_GREETING="${Greeting} ${Target}. My name is ${_tapisJobOwner}"
echo "$FULL_GREETING"

if [ -e $"fileToModify" ]
then
    echo $FULL_GREETING >> $fileToModify
else
    echo $FULL_GREETING > out.txt
fi
