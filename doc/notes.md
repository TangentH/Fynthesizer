# Notes

## 关于PWM频率的计算

假设PWM的周期是$2^N$个系统时钟周期，则PWM的分辨率是Nbit，采样率是$1/(2^N\times clk\_period)$

后面感觉N=12也就是4096个时钟周期的PWM周期比较平衡，N=10的时候能够听到一些杂音，应该是分辨率不够导致的

另外，N太大的另一个问题是，PWM的频率变低，导致即便没有任何信号的时候，音箱中也能听到声音，还是设成N=10吧。

不行，后面试了N=8都不行，大概是板子上本来的噪声就很大了吧。

## 关于freq和phaseInc以及next_sample周期的关系

next_sample的周期是counter（用于降采样）长度*系统时钟周期

在当前实验的setup下，加入phaseInc=1,则$2^{18}$个next_sample会遍历完任何一种波形一个周期的采样（在oscillator.vhd的counter中）。所以$2^{18}\times next\_sample\_period=波形的周期$，因此
$$
freq=\frac{phaseInc}{2^{18}\times next\_sample\_period}=\frac{phaseInc}{2^{18}\times next\_sample\_counter\times 10^{-8}(s)}
$$
所以现在在固定next_sample_counter=$2^{10}$时，可以唯一确定phaseInc和freq的对应关系，至于next_sample_counter长度的选取，是计算20Hz和20kHz时phaseInc的范围是否落在16bit的表示范围内得到的。



标准音（440Hz）：phaseInc=1177.65 (0100 1001 1010)

## 关于ADSR延时的计算

ADSR延时计算
$$
A延时=A延时的系数\times maxCount(64)\times 126(最大值)\times next\_sample
\_counter \times10^{-8}(s)
$$
ADR虽然是这个数字是用来计时的，但是表示的是速度的概念，值越大，下降一个幅度单位的时间越长，速度越慢

## 关于Mixer选择的通道数

理论上，mixer通道数越多，为了防止溢出所需要的EXTRA_BIT就越多，但是最后输出的数据位数是固定的，所以通道数越多，每个通道的幅度就越小，所以通道数越多，音量就越小。不过，由于EXTRA_BIT和通道数的关系是log2的关系，所以其实即便多了12个通道，音量也不会小很多，至少从听觉上来说，是可以接受的，虽然可能仿真上看波形就小了一大截。

具体测试中，我发现，sustain的值之和只要不超过amplitude上限（mixer通道数*127），就不会有溢出的问题，溢出的听感上就是杂音（有点像低频方波）。

## Ref

https://github.com/Ianmurph91/uart_transceiver?tab=readme-ov-file

https://github.com/jakubcabal/uart-for-fpga
