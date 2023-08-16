import yaml
import numpy as np

# Parameters
infile, outdir, bname, absdir, nowtimestr=config['infile'].split(','), config['outdir'], config['bname'].split(','), config['absdir'], config['nowtimestr']
config['infile'], config['bname']=infile, bname
files=dict(zip(bname, infile))

# global wildcards constraints for all rules
# https://snakemake.readthedocs.io/en/stable/snakefiles/rules.html#wildcards
wildcard_constraints:
    name="[^/]+"

# for rules using a function
def get_file(wildcards):
	return files[wildcards.name]

if config['condaenv']=='None':
	config['condaenv']=None

# Default parameters
if 'scrnah5adscvi2leidensbyresolution' not in config:
	config['scrnah5adscvi2leidensbyresolution']={
		'condaenv': config['condaenv'],
		'label': ['resolution_1'],
		'resolution_1': np.arange(0.1, 1.0+0.1, 0.1).round(1).tolist(),
		'seed': 12345,
	}
if config['condaenv']:
	config['scrnah5adscvi2leidensbyresolution']['condaenv']=config['condaenv']

scrnah5adscvi2leidensbyresolution_cmd=' '.join([
	f"scrnah5adscvi2leidensbyresolution",
	f"-s {config['scrnah5adscvi2leidensbyresolution']['seed']}",
	])
if config['scrnah5adscvi2leidensbyresolution']['condaenv']:
	scrnah5adscvi2leidensbyresolution_cmd+=f" -e {config['scrnah5adscvi2leidensbyresolution']['condaenv']}"


mergeimg2htmlbyjinja_cmd=' '.join([
	f"mergeimg2htmlbyjinja",
	])

# save parameters
with open(f"config_{nowtimestr}.yaml", 'w') as f:
	yaml.dump(config, f, sort_keys=False)
