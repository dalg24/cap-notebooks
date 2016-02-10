from pycap import PropertyTree
from puq import UniformParameter,NormalParameter
from puq import MonteCarlo,LHS,Smolyak
from puq import InteractiveHost,TestProgram,Sweep

def run():
    # parse uq database
    input_database=PropertyTree()
    input_database.parse_xml('uq.xml')
    uq_database=input_database.get_child('uq')

    # declare parameters
    params=uq_database.get_int('params')
    parameter_list=[]
    for p in range(params):
        parameter_database=uq_database.get_child('param_'+str(p))
        distribution_type=parameter_database.get_string('distribution_type')
        parameter_name=parameter_database.get_string('name')
        if distribution_type=='uniform':
            parameter_range=parameter_database.get_array_double('range')
            parameter_list.append(UniformParameter('param_'+str(p),
                                                   parameter_name,
                                                   min=parameter_range[0],
                                                   max=parameter_range[1]))
        elif distribution_type=='normal':
            parameter_mean=parameter_database.get_double('mean')
            parameter_standard_deviation=parameter_database.get_double('standard_deviation')
            parameter_list.append(NormalParameter('param_'+str(p),
                                                  parameter_name,
                                                  mean=parameter_mean,
                                                  dev=parameter_standard_deviation))
        else:
            raise RuntimeError('invalid distribution type '+distribution_type+' for param_'+str(p))

    # create a host
    host_database=uq_database.get_child('host')
    host_type=host_database.get_string('type')
    if host_type=="Interactive":
        host=InteractiveHost(cpus=host_database.get_int_with_default_value('cpus',1),
                             cpus_per_node=host_database.get_int_with_default_value('cpus_per_node',0))
    elif host_type=="PBS":
        host=PBSHost(host_database.get_string('env'),
                     cpus=host_database.get_int_with_default_value('cpus',0),
                     cpus_per_node=host_database.get_int_with_default_value('cpus_per_node',0),
                     qname=host_database.get_string_with_default_value('qname','standby'),
                     walltime=host_database.get_string_with_default_value('walltime','1:00:00'),
                     modules=host_database.get_string_with_default_value('modules',''),
                     pack=host_database.get_int_with_default_value('pack',1),
                     qlimit=host_database.get_int_with_default_value('qlimit',200))
    else:
        raise RuntimeError('invalid host type '+host_type)

    # pick UQ method
    method=uq_database.get_string('method')
    if method=='SmolyakSparseGrid':
        level=uq_database.get_int('level')
        uq=Smolyak(parameter_list,level=level)
    elif method=='MonteCarlo':
        samples=uq_database.get_int('samples')
        uq=MonteCarlo(parameter_list,num=samples)
    elif method=='LatinHypercubeSampling':
        samples=uq_database.get_int('samples')
        uq=LHS(parameter_list,num=samples)
    else:
        raise RuntimeError('invalid UQ method '+method)

    # make a test program
    test_program_database=uq_database.get_child('test_program')
    description=test_program_database.get_string('description')
    executable_name=test_program_database.get_string('executable')
    for p in range(params):
        executable_name+=' --param_'+str(p)+' $param_'+str(p)
    prog=TestProgram(exe=executable_name,
                     desc=description)

    # run
    return Sweep(uq,host,prog)