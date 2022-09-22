FULL_GREETING="${Greeting} ${Target}. My name is ${_tapisJobOwner}"
echo "$FULL_GREETING"

if [ -e "$fileToModify" ]
then
    echo $FULL_GREETING >> $fileToModify
    cp $fileToModify /TapisOutput
else
    echo $FULL_GREETING > /TapisOutput/out.txt
fi
