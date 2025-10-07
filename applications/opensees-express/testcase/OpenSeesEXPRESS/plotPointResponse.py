import numpy as np
import matplotlib.pyplot as plt


def plot_pointResponse(ndof=2, nstraincomp=3, nstresscomp=5):
    
    nodes = np.loadtxt('nodesInfo.dat')
    disp = np.loadtxt('displacement.out')
    acc = np.loadtxt('acceleration.out')
    strain = np.loadtxt('strain.out')
    stress = np.loadtxt('stress.out')

    time = acc[:,0]
    disp = np.delete(disp, 0, 1)
    acc = np.delete(acc, 0, 1)
    strain = np.delete(strain, 0, 1)
    stress = np.delete(stress, 0, 1)

    # Bandaid to remove last 2 nodes associated with dashpot (not correct for all Openees) 
    #disp = disp[:,0:-4]
    #acc = acc[:,0:-4]
	
	# subtact base displacement
    disp = (disp.transpose() - disp[:,0]).transpose()
    maxdisp = np.amax(np.abs(disp), axis=0)
    pga = np.amax(np.abs(acc), axis=0)
    maxstrain = np.amax(np.abs(strain), axis=0)
    maxstressratio = np.amax(np.abs(stress[:, 3::nstresscomp]), axis=0)
    maxstressratio = maxstressratio / np.abs(stress[0, 1::nstresscomp])

    [nstep, temp] = strain.shape
    nelem = int(temp / nstraincomp)
    nnodes = nodes.shape[0]
    sizeElem=nodes[-1, 2]/nelem
	
    stress = stress.reshape(nstep, nstresscomp, nelem, order="F")
    strain = strain.reshape(nstep, nstraincomp, nelem, order="F")
    maxdisp = maxdisp.reshape(ndof, nnodes, order="F")
    pga = pga.reshape(ndof, nnodes, order="F")
    maxstrain = maxstrain.reshape(nstraincomp, nelem, order="F")
    maxStrain_index = np.where(maxstrain[2, :] == np.amax(maxstrain[2, :]))
    index= (int(maxStrain_index[0]))
    depth_vec=np.flipud(nodes[:-2:2, 2] + np.diff(nodes[::2, 2])-sizeElem/2)
    z_p=depth_vec[index]    
    
    plt.figure()
    plt.plot(strain[:, 2, index]*100.0, stress[:, 3, index])
    plt.xlabel('strain(%)')
    plt.ylabel('stress(kPa)')
    plt.grid()
    plt.show()
    plt.title('Stress-strain at depth %1.3f m' %z_p)
    #plt.savefig('stressstrain.eps')
    #plt.savefig('stressstrain.png')
        
    """
    Plot pore water pressure
    """
    porepressure = np.loadtxt('porePressure.out')
    time = porepressure[:, 0]
    porepressure = np.delete(porepressure, 0, 1)
    uexcess = porepressure - porepressure[0, :]

    plt.figure()
    plt.plot(time, uexcess[:, index])
    plt.xlabel('Time(s)')
    plt.ylabel('u_excess(kPa)')
    plt.grid()
    plt.show()
    plt.title('Pore Pressure at depth %1.3f m' %z_p)
    #plt.savefig('porePressure.eps')
    #plt.savefig('porePressure.png')

if __name__ == "__main__":
    plot_pointResponse()

