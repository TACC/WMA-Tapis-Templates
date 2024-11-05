set -x

source $TACC_OPENFOAM_DIR/etc/bashrc

cd inputDirectory

v1="On"
v2="Off"
t2="olaFlow"

# Decomposition on/off
d1=${decomp}
echo "$d1"

# Meshing within solver on/off
m1=${mesh}
echo "$m1"

# solver type
t1=${solver}
echo "$t1"

if [ "$t1" == "$t2" ]; then
    # Include olaFlow binary and lib paths
	if [ "$d1" == "$v1" ] && [ "$m1" == "$v1" ]; then
        blockMesh > blockMesh.log; decomposePar > decomposePar.log; ibrun ${solver} -parallel > ${solver}.log; reconstructPar > reconstructPar.log
	elif [ "$d1" == "$v2" ] && [ "$m1" == "$v1" ]; then
        blockMesh > blockMesh.log; ibrun ${solver} > ${solver}.log
	elif [ "$d1" == "$v2" ] && [ "$m1" == "$v2" ]; then
        ibrun ${solver} > ${solver}.log
	elif [ "$d1" == "$v1" ] && [ "$m1" == "$v2" ]; then
        decomposePar > decomposePar.log; ibrun ${solver} -parallel > ${solver}.log; reconstructPar > reconstructPar.log
	else
        echo "Invalid Selection"
        exit 1
	fi
else
	if [ "$d1" == "$v1" ] && [ "$m1" == "$v1" ]; then
        blockMesh > blockMesh.log; decomposePar > decomposePar.log; ibrun ${solver} -parallel > ${solver}.log; reconstructPar > reconstructPar.log
    elif [ "$d1" == "$v2" ] && [ "$m1" == "$v1" ]; then
        blockMesh > blockMesh.log; ibrun ${solver} > ${solver}.log
    elif [ "$d1" == "$v2" ] && [ "$m1" == "$v2" ]; then
        ibrun ${solver} > ${solver}.log
    elif [ "$d1" == "$v1" ] && [ "$m1" == "$v2" ]; then
        decomposePar > decomposePar.log; ibrun ${solver} -parallel > ${solver}.log; reconstructPar > reconstructPar.log
    else
        echo "Invalid Selection"
        exit 1
    fi
fi

cd ..

if [ ! $? ]; then
    echo "OpenFoam ${solver} exited with an error status. $?" >&2
    exit 1
fi
