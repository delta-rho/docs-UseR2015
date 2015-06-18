## To generate slides

The generate the slides do this in R:
```
library(rmarkdown)
render("Tessera-overview-housing-demo.Rmd")
```

Then open Tessera-overview-housing-demo.html in a text editor and insert the script in 
custom_footer.html at the end after the last script but before the `</body>` tag.
This is done because using the `after_body` option for ioslides (in the header)
inserts this script after the slide content but before the other ioslides scripts
are imported. In order for the custom footer to work, it needs to be the last 
script.

At the top of the Tessera-overview-housing-demo.html file in the title slide insert 
the following line before the date: (search for 'title-slide' to find it)
```
    <p style="margin-top: 6px; margin-left: -2px;">useR! Conference</p>
```

To generate a more readable set of html files, change the header of the 
.Rmd file, from `self_contained: true` to `self_contained: false`. This makes the 
generated HTML appear with a subdirectory of supporting files rather than copying
all necessary scripts and css to the html file. 

To create a PDF file from the generated HTML, open Tessera-overview-housing-demo.html
in Firefox on a Windows machine. Open the Print dialog and choose Adobe PDF from the 
list of printers (requires Adobe Professional). Open the Properties dialog next to 
the printers drop-down list and in the Adobe PDF Settings tab, change these settings:

* Change default Settings to "High Quality Print"
* Uncheck "Add document information"
* Uncheck "Rely on system fonts only; do not use document fonts"