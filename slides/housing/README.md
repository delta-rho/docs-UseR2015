## To generate slides

The generate the slides do this in R:
```
library(rmarkdown)
render("Tessera-overview-housing-demo.Rmd")
```

Then open the rendered HTML file in a text editor and insert the script in 
custom_footer.html at the end after the last script but before the `</body>` tag.
This is done because using the `after_body` option for ioslides (in the header)
inserts this script after the slide content but before the other ioslides scripts
are imported. In order for the custom footer to work, it needs to be the last 
script.

To generate a more readable set of html files, change the header of the 
.Rmd file, from `self_contained: true` to `self_contained: false`. This makes the 
generated HTML appear with a subdirectory of supporting files rather than copying
all necessary scripts and css to the html file. 
