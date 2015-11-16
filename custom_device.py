__all__=['CustomDevice']

class CustomDevice():
    """An example of custom device for Leen"""
    def __init__(self,ptree):
        self.voltage=ptree.get_double('initial_voltage')
        self.current=0.0
    def evolve_one_time_step_constant_current(self,time_step,constant_current):
        self.current=constant_current
        self.voltage+=constant_current*time_step
    def evolve_one_time_step_constant_voltage(self,time_step,constant_voltage):
        raise RuntimeError('not impemented')
    def get_current(self):
        return self.current
    def get_voltage(self):
        return self.voltage