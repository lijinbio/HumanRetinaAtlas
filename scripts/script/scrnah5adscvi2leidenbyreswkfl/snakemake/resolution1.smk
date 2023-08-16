from pathlib import Path
import pandas as pd
import re

rule scrnah5adscvi2leidensbyresolution:
  input:
    get_file,
  output:
    "{name}_{res0}_obs.txt.gz",
    "figures/umap{name}_{res0}_umap_leiden_0_ondata.png",
    "figures/umap{name}_{res0}_umap_leiden_0_wolabel.png",
  shell:
    "{scrnah5adscvi2leidensbyresolution_cmd} -d . -b {wildcards.name}_{wildcards.res0} -r {wildcards.res0} -- {input}"

rule mergeimg2htmlbyjinja:
  input:
    expand(
      [
        "figures/umap{{name}}_{res0}_umap_leiden_0_{labelpos}.png",
      ],
      name=bname,
      res0=config['scrnah5adscvi2leidensbyresolution'][config['scrnah5adscvi2leidensbyresolution']['label'][0]],
      labelpos=['ondata', 'wolabel'],
      ),
  output:
    "{name}_leiden_0.html",
  shell:
    "{mergeimg2htmlbyjinja_cmd} -d . -b {wildcards.name}_leiden_0 -- {input}"

rule numcluster:
  input:
    expand(
      [
        "{name}_{res0}_obs.txt.gz",
      ],
      name=bname,
      res0=config['scrnah5adscvi2leidensbyresolution'][config['scrnah5adscvi2leidensbyresolution']['label'][0]],
      ),
  output:
    "ncluster.txt.gz",
  run:
    name, res_0=map(list, zip(*(re.match('(\w+)_([\.\d]+)_obs.txt.gz', Path(file).name).groups() for file in input)))
    leiden_0=[pd.read_csv(file, sep='\t', header=0)['leiden_0'].unique().shape[0] for file in input]
    tmp=pd.DataFrame({'name': name, 'res_0': res_0, 'leiden_0': leiden_0})
    tmp.sort_values(by=['name', 'leiden_0', 'res_0'], ascending=[True, False, True], inplace=True)
    tmp.to_csv(output[0], sep='\t', index=False)
