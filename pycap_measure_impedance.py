#!/usr/bin/env python

import puq
import optparse
import numpy
import pycap

# read uq database
uq_database=pycap.PropertyTree()
uq_database.parse_xml('uq.xml')
# get number of parameters
params=uq_database.get_int('uq.params')

# usage
usage='usage: %prog'
for p in range(params):
    usage+=' --param_'+str(p)+' val_'+str(p)
parser=optparse.OptionParser(usage)

# register options
for p in range(params):
    parser.add_option('--param_'+str(p),type=float)
(options,args)=parser.parse_args()

# make device database
device_database=pycap.PropertyTree()
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
device=pycap.EnergyStorageDevice(device_database)

# parse the electrochmical impedance spectroscopy database
eis_database=pycap.PropertyTree()
eis_database.parse_xml('eis.xml')
# measure the impedance
data=pycap.ElectrochemicalImpedanceSpectroscopyData()
data.impedance_spectroscopy(device,eis_database)

# extract the results
frequency=numpy.array(data.get_frequency())
complex_impedance=numpy.array(data.get_complex_impedance())
resistance=numpy.real(complex_impedance)
reactance=numpy.imag(complex_impedance)
modulus=numpy.absolute(complex_impedance)
argument=numpy.angle(complex_impedance,deg=True)
# and report 
puq.dump_hdf5('frequency',frequency)
puq.dump_hdf5('resistance',resistance)
puq.dump_hdf5('reactance',reactance)
puq.dump_hdf5('modulus',modulus)
puq.dump_hdf5('argument',argument)
