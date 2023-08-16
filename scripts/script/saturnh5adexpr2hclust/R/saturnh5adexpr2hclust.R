# vim: set noexpandtab tabstop=2:

suppressPackageStartupMessages(library(Seurat))
suppressPackageStartupMessages(library(rhdf5))
suppressPackageStartupMessages(library(Matrix))
suppressPackageStartupMessages(library(RColorBrewer))
suppressPackageStartupMessages(library(dendextend))
suppressPackageStartupMessages(library(phylogram))

X=h5read(infile, 'X')
if (is.list(X)) { # sparse matrix
	X=sparseMatrix(
		i=X$indices
		, p=X$indptr
		, x=as.numeric(X$data)
		, repr='C'
		, index1=F
		)
} else if (!is.matrix(X)) { # not a matrix nor a sparse
	write(sprintf('Error: the format of x.X "%s" is unknown at %s.\n', class(X), infile), stderr())
	q(status=1)
}
obsindex=h5read(infile, '/obs/_index', drop=T)
varindex=h5read(infile, '/var/_index', drop=T)
colnames(X)=obsindex
rownames(X)=varindex
print('==> X')
str(X)

metadata=do.call(
	cbind
	, lapply(
		c(group, color)
		, function(g) {
			glabel=h5read(infile, sprintf('/obs/%s/categories', g), drop=T)
			gvalue=h5read(infile, sprintf('/obs/%s/codes', g), drop=T)
			setNames(
				data.frame(factor(gvalue, labels=glabel))
				, g
				)
		})
	)
rownames(metadata)=obsindex
print('==> metadata')
str(metadata)

# Seurat object
x=CreateSeuratObject(counts=X, meta.data=metadata)
Idents(x)=group # for Seurat::AverageExpression()
print('==> x')
str(x)

## Using BuildClusterTree source code
data.avg=AverageExpression(object=x, assays=DefaultAssay(object=x), features=rownames(x), slot='counts', verbose=T)[[1]]
data.dist=dist(x=t(x=data.avg))
data.tree=hclust(d=data.dist, method=method)
data.tree=as.dendrogram(data.tree, hang=uhang)
print('==> data.tree')
str(data.tree)

colorbase=c(
	brewer.pal(8, "Set2")
	, brewer.pal(12, "Set3")
	, brewer.pal(9, "Set1")
	)
tipcolor=colorbase[
	setNames(
		x@meta.data[, color]
		, x@meta.data[, group]
		)[labels(data.tree)]
	]
print('==> tipcolor')
str(tipcolor)

outfile=sprintf('%s/%s.pdf', outdir, bname)
if (endsWith(outfile, '.pdf')) {
	pdf(outfile, width=width, height=height)
	par(mai=c(0, 0, 0, 0.5*width), xpd=T)
	labels_colors(data.tree)=tipcolor
	plot(data.tree, horiz=T, ann=F, axes=F, main=NULL, xlab=NULL, ylab=NULL)
	legend("topright", title=color, legend=levels(x@meta.data[, color]), fill=colorbase[1:nlevels(x@meta.data[, color])], inset=c(-0.9, 0.1))
	dev.off()
} else if (endsWith(outfile, '.png')) {
	png(outfile, width=width, height=height, units='in', res=500)
	par(mai=c(0, 0, 0, 0.5*width), xpd=T)
	labels_colors(data.tree)=tipcolor
	plot(data.tree, horiz=T, ann=F, axes=F, main=NULL, xlab=NULL, ylab=NULL)
	legend("topright", title=color, legend=levels(x@meta.data[, color]), fill=colorbase[1:nlevels(x@meta.data[, color])], inset=c(-0.9, 0.1))
	dev.off()
}

outtree=sprintf('%s/%s.tree', outdir, bname)
write.dendrogram(data.tree, file=outtree, append=F, edge=T)
