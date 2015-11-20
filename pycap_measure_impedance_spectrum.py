#!/usr/bin/env python

from puq import dump_hdf5
from optparse import OptionParser
from pycap import PropertyTree,EnergyStorageDevice
from pycap import measure_impedance_spectrum
from numpy import real,imag,log10,absolute,angle

# read uq database
uq_database=PropertyTree()
uq_database.parse_xml('uq.xml')
# get number of parameters
params=uq_database.get_int('uq.params')

# usage
usage='usage: %prog'
for p in range(params):
    usage+=' --param_'+str(p)+' val_'+str(p)
parser=OptionParser(usage)
# register options
for p in range(params):
    parser.add_option('--param_'+str(p),type=float)
# parse the command line arguments
(options,args)=parser.parse_args()

# make device database
device_database=PropertyTree()
device_database.parse_xml('super_capacitor.xml')
# adjust the parameters in the database
options_dict=vars(options)
for var in options_dict:
    path=uq_database.get_string('uq.'+var+'.name')
    # next line is there to ensure that path already exists
    old_value=device_database.get_double(path)
    new_value=options_dict[var]
    print var,path,new_value
    device_database.put_double(path,new_value)
# build the energy storage device
device=EnergyStorageDevice(device_database.get_child('device'))

# parse the electrochmical impedance spectroscopy database
eis_database=PropertyTree()
eis_database.parse_xml('eis.xml')
# measure the impedance
impedance_spectrum_data=measure_impedance_spectrum(device,eis_database.get_child('eis'))
# extract the results
frequency=impedance_spectrum_data['frequency']
complex_impedance=impedance_spectrum_data['impedance']
resistance=real(complex_impedance)
reactance=imag(complex_impedance)
modulus=absolute(complex_impedance)
argument=angle(complex_impedance,deg=True)
magnitude=20*log10(absolute(complex_impedance))
# and report 
dump_hdf5('frequency',frequency)
dump_hdf5('resistance',resistance)
dump_hdf5('reactance',reactance)
dump_hdf5('modulus',modulus)
dump_hdf5('argument',argument)
dump_hdf5('magnitude',magnitude)