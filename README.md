# RemoteOscilloScope_Sender

## 项目简介

本项目为基于FPGA（Cyclone IV E, EP4CE22E22C8）的简易远程示波器信号采集与发送端，实现了ADC数据采集、FIFO缓存、UART串口数据发送、频率测量、LED指示等主要功能。设计适用于信号实时采样、等效采样、FSK调制等场景，可作为数字示波器或信号实验平台的前端采集模块。

---

## 主要功能

1. **ADC数据采集**  
   - 通过并行接口读取10位ADC数据（in_ADC_data[9:0]），支持OE控制。
   - 可选择不同采样率：实时1kHz，等效10MHz/200MHz，采样率选择由 in_sample_rate_select 控制。

2. **FIFO缓存与数据管理**  
   - 使用 IP核 FIFO（fifo_addata）对采样数据进行缓存管理，确保串口发送时数据不丢失。

3. **UART串口通信**  
   - 支持115200/9600等波特率，通过 out_uart_txd 发送采集数据到PC端。
   - 支持帧格式数据发送、CRC校验，接收端（PC）可据此还原波形。

4. **频率测量**  
   - 使用 Drive_Freq 模块，借助门控计数法测量外部信号频率，结果通过 out_freq_uart_tx 串口输出。

5. **LED状态指示**  
   - 4个LED动态指示FPGA运行状态（led_bus[3:0]）。

6. **多种时钟管理**  
   - 通过PLL生成200MHz、10MHz、100kHz等多种采样与系统时钟。
   - 提供us、ms、20ms、s级分频时钟信号。

7. **触发与采样控制**  
   - 支持外部触发信号（in_trigger_n），实现信号边缘触发采样。
   - 采样请求和保持信号输出，便于系统级联和同步。

---

## 外部接口说明

| 信号名                  | 方向   | 位宽   | 描述                               |
|------------------------|--------|--------|------------------------------------|
| clk_50M                | input  | 1      | 主输入时钟 50MHz                   |
| rst                    | input  | 1      | 全局复位，低有效                   |
| in_key                 | input  | 1      | 采样请求按键（与in_request_n并用） |
| in_request_n           | input  | 1      | 采样请求信号，低有效               |
| in_sample_rate_select  | input  | 2      | 采样率选择 {1kHz, 10MHz, 200MHz}   |
| led_bus                | output | 4      | 4路LED指示灯                       |
| in_ADC_data            | input  | 10     | 并行ADC数据输入                    |
| out_OE_n               | output | 1      | ADC输出使能，低有效                |
| out_clk_ADC            | output | 1      | ADC采样时钟                        |
| out_uart_txd           | output | 1      | 采集数据串口发送                   |
| in_trigger_n           | input  | 1      | 外部触发信号，低有效               |
| out_measure_hold_sig   | output | 1      | 采样保持信号                       |
| out_freq_uart_tx       | output | 1      | 频率测量结果串口发送               |
| out_clk_100k           | output | 1      | 100kHz输出时钟                     |

---

## 主要实现模块

- **顶层（RemoteOscilloScope.v）：** 各功能模块集成、总线连接。
- **Drive_Clock.v**：多路分频时钟发生。
- **Drive_PLL.v**：PLL生成多路高速/低速时钟。
- **Drive_ADC.v**：ADC数据采集与OE控制，位序调整。
- **App_DataControl.v**：数据采集、FIFO缓存与UART发送控制。
- **fifo_addata.v**：IP核FIFO，数据缓冲。
- **uart_send/uart_recv/uart_top.v**：通用串口收发模块，参数可配置。
- **Drive_Freq.v**：信号频率测量，门控计数法。
- **App_Led.v**：LED流水灯状态机。
- **sample_control.v**：采样触发、采样保持控制。
- **fifo_control.v**：FIFO读写、采集时序控制。
- **App_FSK.v**：FSK调制功能（可选扩展）。

---

## 典型应用流程

1. 上电复位，等待请求（in_key或in_request_n）。
2. 由采样率选择开关设定采样模式。
3. 采集到触发信号，采集一帧ADC数据，写入FIFO。
4. FIFO数据经UART打包发送至PC。
5. 支持频率测量结果独立串口输出。
6. 运行状态由LED流水灯指示。

---

## 依赖及开发环境

- **FPGA:** Altera Cyclone IV E（EP4CE22E22C8）
- **开发软件:** Quartus Prime 18.0
- **仿真/验证:** ModelSim-Altera（推荐）
- **串口调试:** PC端串口助手/自定义上位机

