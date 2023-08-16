# vim: set noexpandtab tabstop=2:

suppressPackageStartupMessages(library(jlutils))
x=read.txt(infile)
print('==> x')
str(x)

xx=x[, -seq_len(skipcol), drop=F]
xx=sweep(xx, 1, rowSums(xx), FUN='/') # proportion by row
print('==> xx')
str(xx)

anno_labels=names(xx)
annotation=apply(
	xx
	, 1
	, function(xr) {
		idx=(xr>=percent)
		pr=xr[idx]*100
		lr=anno_labels[idx]
		orderby=order(pr, decreasing=T)
		paste(
			sprintf('%.1f%%%s'
				, pr[orderby]
				, lr[orderby]
				)
			, collapse='+'
			)
	})
write.txt(cbind(x, annotation), file=sprintf('%s/%s.txt.gz', outdir, bname))
