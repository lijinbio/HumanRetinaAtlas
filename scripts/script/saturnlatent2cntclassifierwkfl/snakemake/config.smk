import yaml
import subprocess
from pathlib import Path

# Parameters
infile, outdir, bname, nowtimestr=config['infile'].split(','), config['outdir'], config['bname'].split(','), config['nowtimestr']
config['infile'], config['bname']=infile, bname
files=dict(zip(bname, infile))

# for rules using a function
def get_file(wildcards):
	return files[wildcards.name]

if config['condaenv']=='None':
	config['condaenv']=None


if 'saturnh5adlatent2cntclassifier' not in config:
	config['saturnh5adlatent2cntclassifier']={
		'condaenv': config['condaenv'],
		'model': ['LogisticRegression', 'SVC', 'KNeighborsClassifier', 'NearestCentroid', 'RandomForestClassifier', 'SVClinear', 'SGDClassifier', 'MultinomialNB'],
		'modelby': {
			'LogisticRegression': { 'C': 1.0 },
			'SVC': {},
			'NearestCentroid': {},
			'KNeighborsClassifier': { 'n_neighbors': 100 },
			'RandomForestClassifier': {},
			'SVClinear': {},
			'SGDClassifier': {},
			'MultinomialNB': {},
		},
		'trainlabel': 'labels',
		'predictlabel': 'labels',
		'threshold': [0.55, 0.9],
		'seed': 12345,
		'runtrain': True,
		'runtrianby': True,
		'runtrainbywoscale': True,
	}
if config['condaenv']:
	config['saturnh5adlatent2cntclassifier']['condaenv']=config['condaenv']
# not run: modelby: collections.OrderedDict -> dict
# if 'modelby' in config['saturnh5adlatent2cntclassifier'] and len(config['saturnh5adlatent2cntclassifier']['modelby'])>0:
# 	config['saturnh5adlatent2cntclassifier']['modelby']=[dict(m) for m in config['saturnh5adlatent2cntclassifier']['modelby']]
if 'modelbyname' not in config['saturnh5adlatent2cntclassifier'] and 'modelby' in config['saturnh5adlatent2cntclassifier']:
	config['saturnh5adlatent2cntclassifier']['modelbyname']=list(config['saturnh5adlatent2cntclassifier']['modelby'].keys())

# saturnh5adlatent2cntclassifier train
saturnh5adlatent2cntclassifier_train_cmd=[
	f"saturnh5adlatent2cntclassifier train",
	f"-c {config['saturnh5adlatent2cntclassifier']['trainlabel']}",
	f"-s {config['saturnh5adlatent2cntclassifier']['seed']}",
	]
if config['saturnh5adlatent2cntclassifier']['condaenv']:
	saturnh5adlatent2cntclassifier_train_cmd+=[f"-e {config['saturnh5adlatent2cntclassifier']['condaenv']}"]
saturnh5adlatent2cntclassifier_train_cmd=' '.join(saturnh5adlatent2cntclassifier_train_cmd)


# saturnh5adlatent2cntclassifier trainby
saturnh5adlatent2cntclassifier_trainby_cmd=[
	f"saturnh5adlatent2cntclassifier trainby",
	f"-c {config['saturnh5adlatent2cntclassifier']['trainlabel']}",
	f"-s {config['saturnh5adlatent2cntclassifier']['seed']}",
	]
if config['saturnh5adlatent2cntclassifier']['condaenv']:
	saturnh5adlatent2cntclassifier_trainby_cmd+=[f"-e {config['saturnh5adlatent2cntclassifier']['condaenv']}"]
saturnh5adlatent2cntclassifier_trainby_cmd=' '.join(saturnh5adlatent2cntclassifier_trainby_cmd)


# saturnh5adlatent2cntclassifier predict
saturnh5adlatent2cntclassifier_predict_cmd=[
	f"saturnh5adlatent2cntclassifier predict",
	f"-l {config['saturnh5adlatent2cntclassifier']['predictlabel']}",
	]
if config['saturnh5adlatent2cntclassifier']['condaenv']:
	saturnh5adlatent2cntclassifier_predict_cmd+=[f"-e {config['saturnh5adlatent2cntclassifier']['condaenv']}"]
saturnh5adlatent2cntclassifier_predict_cmd=' '.join(saturnh5adlatent2cntclassifier_predict_cmd)

# saturnh5adlatent2cntclassifier predictproba
saturnh5adlatent2cntclassifier_predictproba_cmd=[
	f"saturnh5adlatent2cntclassifier predictproba",
	f"-l {config['saturnh5adlatent2cntclassifier']['predictlabel']}",
	]
if config['saturnh5adlatent2cntclassifier']['condaenv']:
	saturnh5adlatent2cntclassifier_predictproba_cmd+=[f"-e {config['saturnh5adlatent2cntclassifier']['condaenv']}"]
saturnh5adlatent2cntclassifier_predictproba_cmd=' '.join(saturnh5adlatent2cntclassifier_predictproba_cmd)


if 'rtable2sankeydiagram' not in config:
	config['rtable2sankeydiagram']={
		'condaenv': config['condaenv'],
		'iteration': 32,
	}
if config['condaenv']:
	config['rtable2sankeydiagram']['condaenv']=config['condaenv']

rtable2sankeydiagram_cmd=[
	f"rtable2sankeydiagram",
	f"-t {config['rtable2sankeydiagram']['iteration']}",
	]
if config['rtable2sankeydiagram']['condaenv']:
	rtable2sankeydiagram_cmd+=[f"-e {config['rtable2sankeydiagram']['condaenv']}"]
rtable2sankeydiagram_cmd=' '.join(rtable2sankeydiagram_cmd)


if 'tsvfileaddfromcolumn' not in config:
	config['tsvfileaddfromcolumn']={
		'key': ['predict', 'predict_max'],
	}
tsvfileaddfromcolumn_cmd=[
	f"tsvfileaddfromcolumn",
	]
if 'key' in config['tsvfileaddfromcolumn'] and len(config['tsvfileaddfromcolumn']['key'])>0:
	tsvfileaddfromcolumn_cmd+=[f"-k {k}" for k in config['tsvfileaddfromcolumn']['key']]
tsvfileaddfromcolumn_cmd=' '.join(tsvfileaddfromcolumn_cmd)


if 'saturncntclassifierpred2tab' not in config:
	config['saturncntclassifierpred2tab']={
		'xlabel': ['saturn_label', 'group1', 'group2', 'group3', 'cluster2'],
		'ylabel': ['predict', 'predict_max'],
	}

saturncntclassifierpred2tab_cmd=[
	f"saturncntclassifierpred2tab",
	]
if 'xlabel' in config['saturncntclassifierpred2tab'] and len(config['saturncntclassifierpred2tab']['xlabel'])>0:
	saturncntclassifierpred2tab_cmd+=[f"-x {k}" for k in config['saturncntclassifierpred2tab']['xlabel']]
if 'ylabel' in config['saturncntclassifierpred2tab'] and len(config['saturncntclassifierpred2tab']['ylabel'])>0:
	saturncntclassifierpred2tab_cmd+=[f"-y {k}" for k in config['saturncntclassifierpred2tab']['ylabel']]
saturncntclassifierpred2tab_cmd=' '.join(saturncntclassifierpred2tab_cmd)

# debug parameters
with open(f"config_{nowtimestr}.yaml", 'w') as f:
	yaml.dump(config, f, sort_keys=False)
