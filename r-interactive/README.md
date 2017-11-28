
This container provides R with many tools needed for development. You can even use it to draw graphical plots.

Launch it with

  ./run.sh <work_dir>

Try this code for example:

````
    library(wesanderson)

    library(ggplot2)
    ggplot(iris, aes(Sepal.Length, Sepal.Width, color = Species)) +
      geom_point(size = 3) +
      scale_color_manual(values = wes_palette("Royal2")) +
      theme_gray()
````

You can use this R environment to develop R packages. Follow the instructions at http://r-pkgs.had.co.nz/intro.html but skip all installation steps as the libraries are already installed.

Inside the container, the work dir is located at /home/docker/data and any files you modify there will appear in your work dir (by default, the current directory).

Use the following command to change your working directory when you are working on a R package:

  devtools::wd("/home/docker/data")
