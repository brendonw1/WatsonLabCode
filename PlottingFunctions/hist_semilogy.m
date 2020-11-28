function hist_semilogy(data)

[elems,ctrs] = hist(data);
semilogx(ctrs,elems)