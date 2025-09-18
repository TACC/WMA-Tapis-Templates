import numpy as np
import matplotlib.pyplot as plt


def plot_profile(ndof=2, nstraincomp=3, nstresscomp=5):
    """
    Plot maximum displacement, PGA and maximum shear strain and maximum cyclic stress ratio
    """
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

    plt.figure(figsize=(12, 6))
    plt.subplot(1, 4, 1)
    plt.plot(maxdisp[0, ::2], np.flipud(nodes[::2, 2]))
    plt.xticks(np.arange(0.0, max(maxdisp[0, ::2]), 0.2))
    plt.grid()
    plt.show()
    plt.xlabel('Maximum Displacement(m)')
    plt.ylabel('Depth(m)')
    plt.gca().invert_yaxis()

    plt.subplot(1, 4, 2)
    plt.plot(pga[0, ::2] / 9.81, np.flipud(nodes[::2, 2]))
    plt.xticks(np.arange(0.0, max(pga[0, ::2]) / 9.81, 0.2))
    plt.grid()
    plt.xlabel('PGA(g)')
    plt.gca().invert_yaxis()

    plt.subplot(1, 4, 3)
    plt.plot(maxstrain[2, :]*100.0, np.flipud(nodes[:-2:2, 2] + np.diff(nodes[::2, 2])-sizeElem/2))
    plt.grid()
    plt.xlabel('Maximum Shear Strain(%)')
    plt.gca().invert_yaxis()

    plt.subplot(1, 4, 4)
    plt.plot(maxstressratio, np.flipud(nodes[:-2:2, 2] + np.diff(nodes[::2, 2])-sizeElem/2))
    plt.xticks(np.arange(0.0, max(maxstressratio), 0.2))
    plt.grid()
    plt.xlabel('$(\\tau / \sigma_{v0})_{max} $')
    plt.gca().invert_yaxis()
    #plt.savefig('profilePlot.eps')
    #plt.savefig('profilePlot.png')
	
if __name__ == "__main__":
    plot_profile()
