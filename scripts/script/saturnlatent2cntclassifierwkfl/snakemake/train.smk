rule saturnh5adlatent2cntclassifier_train:
  input:
    xconfig=get_file,
  output:
    outdir=directory("saturnh5adlatent2cntclassifier/{name}/train"),
    done="saturnh5adlatent2cntclassifier/{name}/train/train.done",
  wildcard_constraints:
    name="[^/]+",
  threads: workflow.cores * 0.9
  run:
    import yaml
    import itertools
    from multiprocess import Pool
    import pandas as pd
    with open(input.xconfig, 'r') as f:
      xconfig=yaml.load(f, yaml.Loader)
    xconfig=pd.DataFrame(xconfig)
    trainspcs=xconfig['species'][xconfig['classifier']=='train'].tolist()
    pathspcs=xconfig['path'][xconfig['classifier']=='train'].tolist()
    infiles=dict(zip(trainspcs, pathspcs))
    models=config['saturnh5adlatent2cntclassifier']['model']

    def cmdtraindefault(*args):
      trainspecies, model=args
      infile=infiles[trainspecies]
      trainname=f"{wildcards.name}_{trainspecies}_{model}"
      outdir=f"{output.outdir}"
      shell(
      """
      {saturnh5adlatent2cntclassifier_train_cmd} -d "{outdir}" -b "{trainname}" -m "{model}" -- "{infile}"
      """
      )

    with Pool(processes=threads) as p:
      p.starmap(cmdtraindefault, itertools.product(trainspcs, models))
    shell("touch {output.done}")

rule saturnh5adlatent2cntclassifier_train_predict:
  input:
    xconfig=get_file,
    modeldir="saturnh5adlatent2cntclassifier/{name}/train",
    done="saturnh5adlatent2cntclassifier/{name}/train/train.done",
  output:
    outdir=directory("saturnh5adlatent2cntclassifier/{name}/train_predict"),
    done="saturnh5adlatent2cntclassifier/{name}/train_predict/predict.done",
  wildcard_constraints:
    name="[^/]+",
  threads: workflow.cores * 0.9
  run:
    import yaml
    import itertools
    from multiprocess import Pool
    import pandas as pd
    with open(input.xconfig, 'r') as f:
      xconfig=yaml.load(f, yaml.Loader)
    xconfig=pd.DataFrame(xconfig)
    predictspcs=xconfig['species'][xconfig['classifier']=='predict'].tolist()
    pathspcs=xconfig['path'][xconfig['classifier']=='predict'].tolist()
    infiles=dict(zip(predictspcs, pathspcs))
    trainspcs=xconfig['species'][xconfig['classifier']=='train'].tolist()
    models=config['saturnh5adlatent2cntclassifier']['model']

    def cmdpredict(*args):
      predictspecies, trainspecies, model=args
      infile=infiles[predictspecies]
      trainname=f"{wildcards.name}_{trainspecies}_{model}"
      modelfile=f"{input.modeldir}/{trainname}_classifier.pbz2"
      predictname=f"{wildcards.name}_{predictspecies}_{trainspecies}_{model}"
      outdir=f"{output.outdir}"
      shell(
      """
      {saturnh5adlatent2cntclassifier_predict_cmd} -d "{outdir}" -b "{predictname}" -m "{modelfile}" -- "{infile}"
      """
      )

    with Pool(processes=threads) as p:
      p.starmap(cmdpredict, itertools.product(predictspcs, trainspcs, models))
    shell("touch {output.done}")

rule saturnh5adlatent2cntclassifier_train_predictproba:
  input:
    xconfig=get_file,
    modeldir="saturnh5adlatent2cntclassifier/{name}/train",
    done="saturnh5adlatent2cntclassifier/{name}/train/train.done",
  output:
    outdir=directory("saturnh5adlatent2cntclassifier/{name}/train_predictproba"),
    done="saturnh5adlatent2cntclassifier/{name}/train_predictproba/predict.done",
  wildcard_constraints:
    name="[^/]+",
  threads: workflow.cores * 0.9
  run:
    import yaml
    import itertools
    from multiprocess import Pool
    import pandas as pd
    with open(input.xconfig, 'r') as f:
      xconfig=yaml.load(f, yaml.Loader)
    xconfig=pd.DataFrame(xconfig)
    predictspcs=xconfig['species'][xconfig['classifier']=='predict'].tolist()
    pathspcs=xconfig['path'][xconfig['classifier']=='predict'].tolist()
    infiles=dict(zip(predictspcs, pathspcs))
    trainspcs=xconfig['species'][xconfig['classifier']=='train'].tolist()
    models=config['saturnh5adlatent2cntclassifier']['model']
    thresholds=config['saturnh5adlatent2cntclassifier']['threshold']

    def cmdpredict(*args):
      predictspecies, trainspecies, model, threshold=args
      infile=infiles[predictspecies]
      trainname=f"{wildcards.name}_{trainspecies}_{model}"
      modelfile=f"{input.modeldir}/{trainname}_classifier.pbz2"
      predictname=f"{wildcards.name}_{predictspecies}_{trainspecies}_{model}_{threshold}"
      outdir=f"{output.outdir}"
      shell(
      """
      {saturnh5adlatent2cntclassifier_predictproba_cmd} -d "{outdir}" -b "{predictname}" -m "{modelfile}" -r "{threshold}" -- "{infile}"
      """
      )

    with Pool(processes=threads) as p:
      p.starmap(cmdpredict, itertools.product(predictspcs, trainspcs, models, thresholds))
    shell("touch {output.done}")

rule tsvfileaddfromcolumn_train_predictproba:
  input:
    xconfig=get_file,
    indir="saturnh5adlatent2cntclassifier/{name}/train_predictproba",
    done="saturnh5adlatent2cntclassifier/{name}/train_predictproba/predict.done",
  output:
    outdir=directory("tsvfileaddfromcolumn/{name}/train_predictproba"),
    done="tsvfileaddfromcolumn/{name}/train_predictproba/concat.done",
  wildcard_constraints:
    name="[^/]+",
  threads: workflow.cores * 0.9
  run:
    import yaml
    import itertools
    from multiprocess import Pool
    import pandas as pd
    with open(input.xconfig, 'r') as f:
      xconfig=yaml.load(f, yaml.Loader)
    xconfig=pd.DataFrame(xconfig)
    predictspcs=xconfig['species'][xconfig['classifier']=='predict'].tolist()
    pathspcs=xconfig['metadata'][xconfig['classifier']=='predict'].tolist()
    infiles=dict(zip(predictspcs, pathspcs))
    trainspcs=xconfig['species'][xconfig['classifier']=='train'].tolist()
    models=config['saturnh5adlatent2cntclassifier']['model']
    thresholds=config['saturnh5adlatent2cntclassifier']['threshold']

    def cmdpredict(*args):
      predictspecies, trainspecies, model, threshold=args
      infile=infiles[predictspecies]
      predictname=f"{wildcards.name}_{predictspecies}_{trainspecies}_{model}_{threshold}"
      srcfile=f"{input.indir}/{predictname}.txt.gz"
      outdir=f"{output.outdir}"
      shell(
      """
      {tsvfileaddfromcolumn_cmd} -d "{outdir}" -b "{predictname}" -s "{srcfile}" -- "{infile}"
      """
      )

    with Pool(processes=threads) as p:
      p.starmap(cmdpredict, itertools.product(predictspcs, trainspcs, models, thresholds))
    shell("touch {output.done}")

rule saturncntclassifierpred2tab_train_predictproba:
  input:
    indir="tsvfileaddfromcolumn/{name}/train_predictproba",
    done="tsvfileaddfromcolumn/{name}/train_predictproba/concat.done",
  output:
    outdir=directory("tsvfileaddfromcolumn/{name}/train_predictproba_saturncntclassifierpred2tab"),
    done="tsvfileaddfromcolumn/{name}/train_predictproba_saturncntclassifierpred2tab/tab.done",
  wildcard_constraints:
    name="[^/]+",
  threads: workflow.cores * 0.9
  shell:
    """
    function cmd {{
    local infile=$1
    local bname=$(basename "$infile" .txt.gz)
    if [ -f $infile ]
    then
      {saturncntclassifierpred2tab_cmd} -d "{output.outdir}" -b "$bname" -- "$infile"
    fi
    }}
    source env_parallel.bash
    env_parallel -j {threads} cmd ::: {input.indir}/*.txt.gz
    touch {output.done}
    """

rule rtable2sankeydiagram_tab_train_predictproba:
  input:
    indir="tsvfileaddfromcolumn/{name}/train_predictproba_saturncntclassifierpred2tab",
    done="tsvfileaddfromcolumn/{name}/train_predictproba_saturncntclassifierpred2tab/tab.done",
  output:
    outdir=directory("tsvfileaddfromcolumn/{name}/train_predictproba_rtable2sankeydiagram"),
    done="tsvfileaddfromcolumn/{name}/train_predictproba_rtable2sankeydiagram/sankey.done",
  wildcard_constraints:
    name="[^/]+",
  threads: workflow.cores * 0.9
  shell:
    """
    function cmd {{
    local infile=$1
    local bname=$(basename "$infile" .txt.gz)
    if [ -f $infile ]
    then
      {rtable2sankeydiagram_cmd} -d "{output.outdir}" -b "$bname" -- "$infile"
    fi
    }}
    source env_parallel.bash
    env_parallel -j {threads} cmd ::: {input.indir}/*.txt.gz
    touch {output.done}
    """

rule tsvfileaddfromcolumn_train_predict:
  input:
    xconfig=get_file,
    indir="saturnh5adlatent2cntclassifier/{name}/train_predict",
    done="saturnh5adlatent2cntclassifier/{name}/train_predict/predict.done",
  output:
    outdir=directory("tsvfileaddfromcolumn/{name}/train_predict"),
    done="tsvfileaddfromcolumn/{name}/train_predict/concat.done",
  wildcard_constraints:
    name="[^/]+",
  threads: workflow.cores * 0.9
  run:
    import yaml
    import itertools
    from multiprocess import Pool
    import pandas as pd
    with open(input.xconfig, 'r') as f:
      xconfig=yaml.load(f, yaml.Loader)
    xconfig=pd.DataFrame(xconfig)
    predictspcs=xconfig['species'][xconfig['classifier']=='predict'].tolist()
    pathspcs=xconfig['metadata'][xconfig['classifier']=='predict'].tolist()
    infiles=dict(zip(predictspcs, pathspcs))
    trainspcs=xconfig['species'][xconfig['classifier']=='train'].tolist()
    models=config['saturnh5adlatent2cntclassifier']['model']

    def cmdpredict(*args):
      predictspecies, trainspecies, model=args
      infile=infiles[predictspecies]
      predictname=f"{wildcards.name}_{predictspecies}_{trainspecies}_{model}"
      srcfile=f"{input.indir}/{predictname}.txt.gz"
      outdir=f"{output.outdir}"
      shell(
      """
      {tsvfileaddfromcolumn_cmd} -d "{outdir}" -b "{predictname}" -s "{srcfile}" -- "{infile}"
      """
      )

    with Pool(processes=threads) as p:
      p.starmap(cmdpredict, itertools.product(predictspcs, trainspcs, models))
    shell("touch {output.done}")

rule saturncntclassifierpred2tab_train_predict:
  input:
    indir="tsvfileaddfromcolumn/{name}/train_predict",
    done="tsvfileaddfromcolumn/{name}/train_predict/concat.done",
  output:
    outdir=directory("tsvfileaddfromcolumn/{name}/train_predict_saturncntclassifierpred2tab"),
    done="tsvfileaddfromcolumn/{name}/train_predict_saturncntclassifierpred2tab/tab.done",
  wildcard_constraints:
    name="[^/]+",
  threads: workflow.cores * 0.9
  shell:
    """
    function cmd {{
    local infile=$1
    local bname=$(basename "$infile" .txt.gz)
    if [ -f $infile ]
    then
      {saturncntclassifierpred2tab_cmd} -d "{output.outdir}" -b "$bname" -- "$infile"
    fi
    }}
    source env_parallel.bash
    env_parallel -j {threads} cmd ::: {input.indir}/*.txt.gz
    touch {output.done}
    """

rule rtable2sankeydiagram_tab_train_predict:
  input:
    indir="tsvfileaddfromcolumn/{name}/train_predict_saturncntclassifierpred2tab",
    done="tsvfileaddfromcolumn/{name}/train_predict_saturncntclassifierpred2tab/tab.done",
  output:
    outdir=directory("tsvfileaddfromcolumn/{name}/train_predict_rtable2sankeydiagram"),
    done="tsvfileaddfromcolumn/{name}/train_predict_rtable2sankeydiagram/sankey.done",
  wildcard_constraints:
    name="[^/]+",
  threads: workflow.cores * 0.9
  shell:
    """
    function cmd {{
    local infile=$1
    local bname=$(basename "$infile" .txt.gz)
    if [ -f $infile ]
    then
      {rtable2sankeydiagram_cmd} -d "{output.outdir}" -b "$bname" -- "$infile"
    fi
    }}
    source env_parallel.bash
    env_parallel -j {threads} cmd ::: {input.indir}/*.txt.gz
    touch {output.done}
    """
