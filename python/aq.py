from oct2py import Oct2Py

octave = Oct2Py()

ruta = "/Users/diegobravosoto/Desktop/codigos_dos/1D IRIS DB"
octave.addpath(ruta)
N, T, conv = octave.feval("aquila", nout=3)

print(conv)