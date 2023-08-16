from pathlib import Path
import pandas as pd
import re

rule scrnah5adscvi2leidensbyresolution:
  input:
    get_file,
  output:
    "{name}_{res0}_{res1}_{res2}_obs.txt.gz",
    "figures/umap{name}_{res0}_{res1}_{res2}_umap_leiden_0_ondata.png",
    "figures/umap{name}_{res0}_{res1}_{res2}_umap_leiden_0_wolabel.png",
    "figures/umap{name}_{res0}_{res1}_{res2}_umap_leiden_1_ondata.png",
    "figures/umap{name}_{res0}_{res1}_{res2}_umap_leiden_1_wolabel.png",
    "figures/umap{name}_{res0}_{res1}_{res2}_umap_leiden_2_ondata.png",
    "figures/umap{name}_{res0}_{res1}_{res2}_umap_leiden_2_wolabel.png",
  shell:
    "{scrnah5adscvi2leidensbyresolution_cmd} -d . -b {wildcards.name}_{wildcards.res0}_{wildcards.res1}_{wildcards.res2} -r {wildcards.res0} -r {wildcards.res1} -r {wildcards.res2} -- {input}"

rule mergeimg2htmlbyjinja:
  input:
    leiden0=expand(
      [
        "figures/umap{{name}}_{res0}_{res1}_{res2}_umap_leiden_0_{labelpos}.png",
      ],
      name=bname,
      res0=config['scrnah5adscvi2leidensbyresolution'][config['scrnah5adscvi2leidensbyresolution']['label'][0]],
      res1=config['scrnah5adscvi2leidensbyresolution'][config['scrnah5adscvi2leidensbyresolution']['label'][1]],
      res2=config['scrnah5adscvi2leidensbyresolution'][config['scrnah5adscvi2leidensbyresolution']['label'][2]],
      labelpos=['ondata', 'wolabel'],
      ),
    leiden1=expand(
      [
        "figures/umap{{name}}_{res0}_{res1}_{res2}_umap_leiden_1_{labelpos}.png",
      ],
      name=bname,
      res0=config['scrnah5adscvi2leidensbyresolution'][config['scrnah5adscvi2leidensbyresolution']['label'][0]],
      res1=config['scrnah5adscvi2leidensbyresolution'][config['scrnah5adscvi2leidensbyresolution']['label'][1]],
      res2=config['scrnah5adscvi2leidensbyresolution'][config['scrnah5adscvi2leidensbyresolution']['label'][2]],
      labelpos=['ondata', 'wolabel'],
      ),
    leiden2=expand(
      [
        "figures/umap{{name}}_{res0}_{res1}_{res2}_umap_leiden_2_{labelpos}.png",
      ],
      name=bname,
      res0=config['scrnah5adscvi2leidensbyresolution'][config['scrnah5adscvi2leidensbyresolution']['label'][0]],
      res1=config['scrnah5adscvi2leidensbyresolution'][config['scrnah5adscvi2leidensbyresolution']['label'][1]],
      res2=config['scrnah5adscvi2leidensbyresolution'][config['scrnah5adscvi2leidensbyresolution']['label'][2]],
      labelpos=['ondata', 'wolabel'],
      ),
  output:
    "{name}_leiden_0.html",
    "{name}_leiden_1.html",
    "{name}_leiden_2.html",
  shell:
    """
    {mergeimg2htmlbyjinja_cmd} -d . -b {wildcards.name}_leiden_0 -- {input.leiden0}
    {mergeimg2htmlbyjinja_cmd} -d . -b {wildcards.name}_leiden_1 -- {input.leiden1}
    {mergeimg2htmlbyjinja_cmd} -d . -b {wildcards.name}_leiden_2 -- {input.leiden2}
    """

rule numcluster:
  input:
    expand(
      [
        "{name}_{res0}_{res1}_obs.txt.gz",
      ],
      name=bname,
      res0=config['scrnah5adscvi2leidensbyresolution'][config['scrnah5adscvi2leidensbyresolution']['label'][0]],
      res1=config['scrnah5adscvi2leidensbyresolution'][config['scrnah5adscvi2leidensbyresolution']['label'][1]],
      ),
  output:
    "ncluster.txt.gz",
  run:
    name, res_0, res_1, res_2=map(list, zip(*(re.match('(\w+)_([\.\d]+)_([\.\d]+)_([\.\d]+)_obs.txt.gz', Path(file).name).groups() for file in input)))
    leiden_0=[pd.read_csv(file, sep='\t', header=0)['leiden_0'].unique().shape[0] for file in input]
    leiden_1=[pd.read_csv(file, sep='\t', header=0)['leiden_1'].unique().shape[0] for file in input]
    leiden_2=[pd.read_csv(file, sep='\t', header=0)['leiden_2'].unique().shape[0] for file in input]
    tmp=pd.DataFrame({'name': name, 'res_0': res_0, 'res_1': res_1, 'res_2':res_2, 'leiden_0': leiden_0, 'leiden_1': leiden_1, 'leiden_2': leiden_2})
    tmp.sort_values(by=['name', 'leiden_2', 'leiden_1', 'leiden_0', 'res_0', 'res_1', 'res_2'], ascending=[True, False, False, False, True, True, True], inplace=True)
    tmp.to_csv(output[0], sep='\t', index=False)
