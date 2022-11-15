# Edge-Based Line Average Interpolation

The interlaced video comprises two types of fields in the sequence, one is the odd and another is the even field. 
The de-interlacing process is to convert the interlaced video into the non-interlaced form. 
The simplest method is intra-field interpolation, which use the existing pixels in the field to generate the empty lines. 
For instance, the empty lines can be filled via line doubling, which is quite easy to be implemented but the resulting image is not good enough in visual quality.
As the direction of edge is considered, the de-interlaced image has a better quality than merely doubling the existing lines.