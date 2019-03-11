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
開啟另一 Terminal 連線 `$ arm-none-eabi-gdb` ，再輸入 `target remote 127.0.0.1:1234` 連接，輸入兩次的 `info registers` 再輸入 `layout regs`, 輸入 `si` 執行單步除錯。

5. 從反組譯視窗中的`0x18   push {r0, r1, r2, r3}` 與 `0x2a push {r0, r1, r2, r3}` 
再對照原先我們寫入的指令`push {r0, r1, r2, r3}`與`push {r3, r2, r1, r0}`
可以發現就算刻意調整堆疊寫入順序`0x2a`從r0到r3在組譯之後也會被組譯器調整為從r3到r0，如下圖捷所示
同樣的pop指令也是如此
            
![](https://raw.githubusercontent.com/a93481425/ESEmbedded_HW02/master/HW2pic/Pic1.png)

在反組譯視窗中，我們移動到反組譯碼上方可以發現組譯器有給出`register range not in ascending order`的警告訊息
大意是說沒有暫存器按照升序排列，因此組譯器幫我們調成正確的形式，如下圖所示。

![](https://raw.githubusercontent.com/a93481425/ESEmbedded_HW02/master/HW2pic/pic2.png)

## 3. 結果與討論
1. 只要沒有按照升序排列，組譯器會幫你調整成正確的形式
2. 基於第一點，我們可以知道其實不管是升序還是降序組譯的結果還是一樣
3. 若要調整結果如預先設計的`push {r3, r2, r1, r0}`如此順序推入堆疊，則推入堆疊指令應該如下修改
不修改推入堆疊後 堆疊內的情況如下圖
![](https://raw.githubusercontent.com/a93481425/ESEmbedded_HW02/master/HW2pic/org%20stack.png)
直接pop回來的暫存器如下圖
![](https://raw.githubusercontent.com/a93481425/ESEmbedded_HW02/master/HW2pic/org%20reg.png)


修改成如下程式碼
```assembly
push {r0}
push {r1}
push {r2}
push {r3}
```
推入堆疊後堆疊內情況如下
![](https://raw.githubusercontent.com/a93481425/ESEmbedded_HW02/master/HW2pic/modify%20push.png)
pop回來後暫存器情況如下
![](https://raw.githubusercontent.com/a93481425/ESEmbedded_HW02/master/HW2pic/modify%20push%20pop%20reg.png)

可以看到第二次推堆疊後堆疊內容反過來了
再pop回來結果也相反，因此若要實現push反序排列 使用如上方式是相當好的
