
This container provides R with many tools needed for development. You can even use it to draw graphical plots.

Launch it with

  ./run.sh

Try this code for example:

````
    library(wesanderson)

    library(ggplot2)
    ggplot(iris, aes(Sepal.Length, Sepal.Width, color = Species)) + 
      geom_point(size = 3) + 
      scale_color_manual(values = wes_palette("Royal2")) + 
      theme_gray()
````
