# vim: set noexpandtab tabstop=2:

suppressPackageStartupMessages(library(jlutils))

x=h5ad2seurat(infile, catobs=c(group, split), obsm='X_umap')
str(x)

parallel::mclapply(
	c(group, split)
	, function(g) {
		seuratdimplotgroupby(x, reduct='umap', group=g, label=F, outfile=sprintf('%s/%s_umap_%s_wolabel.png', outdir, bname, g), width=width+legendwidth, height=height, nolegend=F, showtitle=showtitle)
		seuratdimplotgroupby(x, reduct='umap', group=g, label=T, outfile=sprintf('%s/%s_umap_%s_ondata.png', outdir, bname, g), width=width, height=height, nolegend=T, showtitle=showtitle)
	})

nsplit=nlevels(x@meta.data[[split]])
str(nsplit)
parallel::mclapply(
	group
	, function(g) {
		seuratdimplotsplitby(x, reduct='umap', group=g, split=split, label=F, outfile=sprintf('%s/%s_%s_%s_wolabel.png', outdir, bname, split, g), width=width*nsplit+legendwidth, height=height, nolegend=F, showtitle=showtitle)
		seuratdimplotsplitby(x, reduct='umap', group=g, split=split, label=T, outfile=sprintf('%s/%s_%s_%s_ondata.png', outdir, bname, split, g), width=width*nsplit, height=height, nolegend=T, showtitle=showtitle)
	})
