import numpy as np
import matplotlib.pyplot as plt

from respSpectra import resp_spectra


def plot_acc(ndof=2):
    """
    Plot acceleration time history and response spectra
    """
    acc = np.loadtxt('acceleration.out')
    time = acc[:, 0]
    acc = np.delete(acc, 0, 1)
    # Bandaid to remove last 2 nodes associated with dashpot (not for all Openees) 
    #acc = acc[:,0:-4]
    
    [nstep, temp] = acc.shape
    nnode = temp//ndof
    a = acc.reshape(nstep, ndof, nnode, order="F") / 9.81
    
    # plot acceleration time history
    plt.figure() 
    plt.plot(time, a[:, 0, 0])
    plt.grid()
    plt.show()
    plt.xlabel('time (sec)')
    plt.ylabel('acceleration (g)')
    plt.title('Input acceleration')
    #plt.savefig('InputAccel.eps',dpi=300)
    #plt.savefig('InputAccel.png',dpi=300)
    
    # plot acceleration time history
    plt.figure() 
    plt.plot(time, a[:, 0, nnode-1])
    plt.grid()
    plt.show()
    plt.xlabel('time (sec)')
    plt.ylabel('acceleration (g)')
    plt.title('Surface acceleration')
    #plt.savefig('surfaceAccel.eps',dpi=300)
    #plt.savefig('surfaceAccel.png',dpi=300)
    
    # build response spectra
    [p, umax, vmax, amax] = resp_spectra(a[:, 0, nnode-1], time[-1], nstep)
    
    # response spectra on log-linear plot
    plt.figure()
    plt.subplot(3, 1, 1)
    plt.semilogx(p, amax)
    plt.grid()
    plt.ylabel('$S_a (g)$')
    plt.subplot(3, 1, 2)
    plt.semilogx(p, vmax)
    plt.grid()
    plt.ylabel('$S_v (m/s)$')
    plt.subplot(3, 1, 3)
    plt.semilogx(p, umax)
    plt.grid()
    plt.ylabel('$S_d (m)$')
    plt.xlabel('Period (sec)')
    #plt.tight_layout(pad=0.4, w_pad=0.5, h_pad=1.0)
    plt.show()
    plt.suptitle('Log Spectra')
    #plt.savefig('logSpectra.eps',dpi=300)
    #plt.savefig('logSpectra.png',dpi=300)

if __name__ == "__main__":
    plot_acc()
