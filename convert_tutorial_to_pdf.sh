mkdir -p ~/.pandoc/templates
cp eisvogel.latex ~/.pandoc/templates
pandoc CHM-tutorial.md -o CHM-tutorial.pdf --from markdown --template eisvogel --listings -V toc -V titlepage=true -V toc-own-page -V book -V title="CHM Tutorial"