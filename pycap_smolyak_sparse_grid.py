import puq
import pycap

def run():
    # parse uq database
    uq_database=pycap.PropertyTree()
    uq_database.parse_xml('uq.xml')
    # get number of parameters
    params=uq_database.get_int('uq.params')
    # declare parameters
    parameter_list=[]
    for p in range(params):
        parameter_database=uq_database.get_child('uq.param_'+str(p))
        distribution_type=parameter_database.get_string('distribution_type')
        parameter_name=parameter_database.get_string('name')
        if distribution_type=='uniform':
            parameter_range=parameter_database.get_string('range').split(',')
            parameter_list.append(puq.UniformParameter('param_'+str(p),
                                                       parameter_name,
                                                       min=float(parameter_range[0]),
                                                       max=float(parameter_range[1])))
        elif distribution_type=='normal':
            parameter_mean=parameter_database.get_double('mean')
            parameter_standard_deviation=parameter_database.get_double('standard_deviation')
            parameter_list.append(puq.NormalParameter('param_'+str(p),
                                                      parameter_name,
                                                      mean=parameter_mean,
                                                      dev=parameter_standard_deviation))
        else:
            raise RuntimeError('invalid distribution type '+distribution_type+' for param_'+str(p))

    # create a host
    host=puq.InteractiveHost()
    # pick UQ method
    uq=puq.Smolyak(parameter_list,level=2)
    # make a test program
    executable_name='./pycap_measure_impedance.py'
    description='pycap electrochemical impedance spectroscopy'
    for p in range(params):
        executable_name+=' --param_'+str(p)+' $param_'+str(p)
    prog=puq.TestProgram(exe=executable_name,
                         desc=description)
    # run
    return puq.Sweep(uq,host,prog)