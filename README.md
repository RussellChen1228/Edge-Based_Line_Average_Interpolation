# Edge-Based Line Average Interpolation

The interlaced video comprises two types of fields in the sequence, one is the odd and another is the even field. 
The de-interlacing process is to convert the interlaced video into the non-interlaced form. 
The simplest method is intra-field interpolation, which use the existing pixels in the field to generate the empty lines. 
For instance, the empty lines can be filled via line doubling, which is quite easy to be implemented but the resulting image is not good enough in visual quality.
As the direction of edge is considered, the de-interlaced image has a better quality than merely doubling the existing lines.

## Application

將狀態分為4個種，分別為:req high、save data、read data、output data

  1.	req high state 將 req 設為 high，進入 save data state
  2.	save data state，一次從 grayscale image memory 讀取32筆資料，並直接將資料依序存在 Result image memory 的基數行
  3.	如果 grayscale image memory 還沒存完，回到 step1 繼續做，否則進入 read data state
  4.	從第32格開始計算 (只計算偶數行)
    	- 如果是最左邊欄位，得到 b、c、e、f 的值後，將 ready 設為1
    	- 從第二欄開始，a=b, d=e, b=c, e=f
    	- 接著取得c和f的值後 ready 設為1
  5.	如果 ready=1，進入 output data state
  6.	如果是最左邊或最右邊的欄位，data_wr = (b+e)/2，否則，計算 |a-f|、|b-e|、|c-d| 的最小值
    	- 若 |a-f| 最小，則 data_wr=(a+f)/2
    	- 若 |b-e| 最小，則 data_wr=(b+e)/2
    	- 否則 data_wr=(c+d)/2
  7.	如果偶數行皆計算完，done=1，否則回到step4繼續做
