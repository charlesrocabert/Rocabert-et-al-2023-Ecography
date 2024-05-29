#!/bin/bash
# coding: utf-8

# Rscript scripts/minigif.R $(pwd)
cd minigif
# for i in {0..25}
# do
#     if [ $i -le 9 ]
#     then
#         convert -strip -interlace Plane -gaussian-blur 0.05 -quality 5% 0$i.jpg compressed/0$i\_compressed.jpg
#     else
#         convert -strip -interlace Plane -gaussian-blur 0.05 -quality 5% $i.jpg compressed/$i\_compressed.jpg
#     fi 
# done
# convert -delay 10 -loop 0 compressed/*\_compressed.jpg minigif_jpg.gif
# gifsicle -i minigif.gif -O3 --colors 128 --lossy=30 -o minigif_opt_jpg.gif
convert -delay 10 -loop 0 *.png minigif_png.gif
gifsicle -i minigif_png.gif -O3 --colors 256 --lossy=30 -o minigif_opt_png.gif
convert minigif_opt_png.gif \( +clone -set delay 200 \) +swap +delete minigif_opt_png_with_pause.gif
cd ..

