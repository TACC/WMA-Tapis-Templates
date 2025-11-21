import numpy as np


def resp_spectra(a, time, nstep):
    """
    This function builds response spectra from acceleration time history,
    a should be a numpy array,T and nStep should be integers.
    """
    
    # add initial zero value to acceleration and change units
    a = np.insert(a, 0, 0)*9.81
    # number of periods at which spectral values are to be computed
    nperiod = 100
    # define range of considered periods by power of 10
    minpower = -3.0
    maxpower = 1.0
    # create vector of considered periods
    p = np.logspace(minpower, maxpower, nperiod)
    # incremental circular frequency
    dw = 2.0 * np.pi / time
    # vector of circular freq
    w = np.arange(0, (nstep+1)*dw, dw)
    # fast fourier Horm of acceleration
    afft = np.fft.fft(a)
    # arbitrary stiffness value
    k = 1000.0
    # damping ratio
    damp = 0.05
    umax = np.zeros(nperiod)
    vmax = np.zeros(nperiod)
    amax = np.zeros(nperiod)
    # loop to compute spectral values at each period
    for j in range(0, nperiod):
        # compute mass and dashpot coeff to produce desired periods
        m = ((p[j]/(2*np.pi))**2)*k
        c = 2*damp*(k*m)**0.5
        h = np.zeros(nstep+2, dtype=complex)
        # compute transfer function 
        for l in range(0, nstep//2+1):
            h[l] = 1./(-m*w[l]*w[l] + 1j*c*w[l] + k)
            # mirror image of Her function
            h[nstep+1-l] = np.conj(h[l])
        
        # compute displacement in frequency domain using Her function
        qfft = -m*afft
        u = np.zeros(nstep+1, dtype=complex)
        for l in range(0, nstep+1):
            u[l] = h[l]*qfft[l]
        
        # compute displacement in time domain (ignore imaginary part)
        utime = np.real(np.fft.ifft(u))
        
        # spectral displacement, velocity, and acceleration
        umax[j] = np.max(np.abs(utime))
        vmax[j] = (2*np.pi/p[j])*umax[j]
        amax[j] = (2*np.pi/p[j])*vmax[j]/9.81
    
    return p, umax, vmax, amax
