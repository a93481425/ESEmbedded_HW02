HW02 
===
## 1. 實驗題目
觀察`push {r0,r1,r2}`與`push {r2,r1,r0}`兩指令之差異。
## 2. 實驗步驟
1. 設計測試程式 main.s ，從 `_start` 開始後先在`r0`,`r1`,`r2`,`r3`中分別填入0,1,2的測試值，
然後執行`push {r0, r1, r2, r3}`與`push {r3, r2, r1, r0}`來推入堆疊記憶體。
之後再執行`pop {r0, r1, r2, r3}`與`pop {r3, r2, r1, r0}`取出堆疊。

main.s:

```assembly
.syntax unified

.word 0x20000100
.word _start

.global _start
.type _start, %function
_start:
	//
	// mov
	//

        mov r0,#0
        mov r1,#1
        mov r2,#2

	//
	//push
	//
 
	push	{r0, r1, r2, r3}
        push	{r3, r2, r1, r0}

	//
	//pop
	//
 
	pop	{r0, r1, r2, r3}
        pop	{r3, r2, r1, r0}




	//
	//branch w/o link
	//
	b	label01

label01:
	nop

	//
	//branch w/ link
	//
	bl	sleep

sleep:
	nop
	b       sleep
```

4. 將 main.s 編譯並以 qemu 模擬， `$ make clean`, `$ make`, `$ make qemu`
開啟另一 Terminal 連線 `$ arm-none-eabi-gdb` ，再輸入 `target remote localhost:1234` 連接，輸入兩次的 `ctrl + x` 再輸入 `2`, 開啟 Register 以及指令，並且輸入 `si` 單步執行觀察。
當執行到 `0xa` 的 `b.n    0xc ` 時， `pc` 跳轉至 `0x0c` ，除了 branch 外並無變化。

![](https://github.com/vwxyzjimmy/ESEmbedded_HW02/blob/master/img-folder/0x0a.jpg)

當執行到 `0x0e` 的 `bl     0x12` 後，會發現 `lr`  更新為 `0x13`。

![](https://github.com/vwxyzjimmy/ESEmbedded_HW02/blob/master/img-folder/0x12.jpg)

## 3. 結果與討論
1. 使用 `bl` 時會儲存 `pc` 下一行指令的位置到 `lr` 中，通常用來進行副程式的呼叫，副程式結束要返回主程式時，可以執行 `bx lr`，返回進入副程式前下一行指令的位置。
2. 根據 [Cortex-M4-Arm Developer](https://developer.arm.com/products/processors/cortex-m/cortex-m4)，由於 Cortex-M4 只支援 Thumb/ Thumb-2 指令，使用 `bl` 時，linker 自動把 pc 下一行指令位置並且設定 LSB 寫入 `lr` ，未來使用 `bx lr` 等指令時，由於 `lr` 的 LSB 為 1 ，能確保是在 Thumb/ Thumb-2 指令下執行後續指令。
以上述程式為例， `bl     0x12` 下一行指令位置為  0x12 並設定 LSB 為 1 ，所以寫入 0x13 至 `lr` 。


 [Linker User Guide: --entry=location](http://www.keil.com/support/man/docs/armlink/armlink_pge1362075463332.htm)
```
Note
If the entry address of your image is in Thumb state, then the least significant bit of the address must be set to 1.
The linker does this automatically if you specify a symbol.
```
