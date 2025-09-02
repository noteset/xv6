
kernel/kernel:     file format elf64-littleriscv


Disassembly of section .text:

0000000080000000 <_entry>:
_entry:
        # set up a stack for C.
        # stack0 is declared in start.c,
        # with a 4096-byte stack per CPU.
        # sp = stack0 + ((hartid + 1) * 4096)
        la sp, stack0
    80000000:	00008117          	auipc	sp,0x8
    80000004:	8d010113          	addi	sp,sp,-1840 # 800078d0 <stack0>
        li a0, 1024*4
    80000008:	6505                	lui	a0,0x1
        csrr a1, mhartid
    8000000a:	f14025f3          	csrr	a1,mhartid
        addi a1, a1, 1
    8000000e:	0585                	addi	a1,a1,1
        mul a0, a0, a1
    80000010:	02b50533          	mul	a0,a0,a1
        add sp, sp, a0
    80000014:	912a                	add	sp,sp,a0
        # jump to start() in start.c
        call start
    80000016:	04e000ef          	jal	80000064 <start>

000000008000001a <spin>:
spin:
        j spin
    8000001a:	a001                	j	8000001a <spin>

000000008000001c <timerinit>:
}

// ask each hart to generate timer interrupts.
void
timerinit()
{
    8000001c:	1141                	addi	sp,sp,-16
    8000001e:	e406                	sd	ra,8(sp)
    80000020:	e022                	sd	s0,0(sp)
    80000022:	0800                	addi	s0,sp,16
#define MIE_STIE (1L << 5)  // supervisor timer
static inline uint64
r_mie()
{
  uint64 x;
  asm volatile("csrr %0, mie" : "=r" (x) );
    80000024:	304027f3          	csrr	a5,mie
  // enable supervisor-mode timer interrupts.
  w_mie(r_mie() | MIE_STIE);
    80000028:	0207e793          	ori	a5,a5,32
}

static inline void 
w_mie(uint64 x)
{
  asm volatile("csrw mie, %0" : : "r" (x));
    8000002c:	30479073          	csrw	mie,a5
static inline uint64
r_menvcfg()
{
  uint64 x;
  // asm volatile("csrr %0, menvcfg" : "=r" (x) );
  asm volatile("csrr %0, 0x30a" : "=r" (x) );
    80000030:	30a027f3          	csrr	a5,0x30a
  
  // enable the sstc extension (i.e. stimecmp).
  w_menvcfg(r_menvcfg() | (1L << 63)); 
    80000034:	577d                	li	a4,-1
    80000036:	177e                	slli	a4,a4,0x3f
    80000038:	8fd9                	or	a5,a5,a4

static inline void 
w_menvcfg(uint64 x)
{
  // asm volatile("csrw menvcfg, %0" : : "r" (x));
  asm volatile("csrw 0x30a, %0" : : "r" (x));
    8000003a:	30a79073          	csrw	0x30a,a5

static inline uint64
r_mcounteren()
{
  uint64 x;
  asm volatile("csrr %0, mcounteren" : "=r" (x) );
    8000003e:	306027f3          	csrr	a5,mcounteren
  
  // allow supervisor to use stimecmp and time.
  w_mcounteren(r_mcounteren() | 2);
    80000042:	0027e793          	ori	a5,a5,2
  asm volatile("csrw mcounteren, %0" : : "r" (x));
    80000046:	30679073          	csrw	mcounteren,a5
// machine-mode cycle counter
static inline uint64
r_time()
{
  uint64 x;
  asm volatile("csrr %0, time" : "=r" (x) );
    8000004a:	c01027f3          	rdtime	a5
  
  // ask for the very first timer interrupt.
  w_stimecmp(r_time() + 1000000);
    8000004e:	000f4737          	lui	a4,0xf4
    80000052:	24070713          	addi	a4,a4,576 # f4240 <_entry-0x7ff0bdc0>
    80000056:	97ba                	add	a5,a5,a4
  asm volatile("csrw 0x14d, %0" : : "r" (x));
    80000058:	14d79073          	csrw	stimecmp,a5
}
    8000005c:	60a2                	ld	ra,8(sp)
    8000005e:	6402                	ld	s0,0(sp)
    80000060:	0141                	addi	sp,sp,16
    80000062:	8082                	ret

0000000080000064 <start>:
{
    80000064:	1141                	addi	sp,sp,-16
    80000066:	e406                	sd	ra,8(sp)
    80000068:	e022                	sd	s0,0(sp)
    8000006a:	0800                	addi	s0,sp,16
  asm volatile("csrr %0, mstatus" : "=r" (x) );
    8000006c:	300027f3          	csrr	a5,mstatus
  x &= ~MSTATUS_MPP_MASK;
    80000070:	7779                	lui	a4,0xffffe
    80000072:	7ff70713          	addi	a4,a4,2047 # ffffffffffffe7ff <end+0xffffffff7ffddc27>
    80000076:	8ff9                	and	a5,a5,a4
  x |= MSTATUS_MPP_S;
    80000078:	6705                	lui	a4,0x1
    8000007a:	80070713          	addi	a4,a4,-2048 # 800 <_entry-0x7ffff800>
    8000007e:	8fd9                	or	a5,a5,a4
  asm volatile("csrw mstatus, %0" : : "r" (x));
    80000080:	30079073          	csrw	mstatus,a5
  asm volatile("csrw mepc, %0" : : "r" (x));
    80000084:	00001797          	auipc	a5,0x1
    80000088:	dce78793          	addi	a5,a5,-562 # 80000e52 <main>
    8000008c:	34179073          	csrw	mepc,a5
  asm volatile("csrw satp, %0" : : "r" (x));
    80000090:	4781                	li	a5,0
    80000092:	18079073          	csrw	satp,a5
  asm volatile("csrw medeleg, %0" : : "r" (x));
    80000096:	67c1                	lui	a5,0x10
    80000098:	17fd                	addi	a5,a5,-1 # ffff <_entry-0x7fff0001>
    8000009a:	30279073          	csrw	medeleg,a5
  asm volatile("csrw mideleg, %0" : : "r" (x));
    8000009e:	30379073          	csrw	mideleg,a5
  asm volatile("csrr %0, sie" : "=r" (x) );
    800000a2:	104027f3          	csrr	a5,sie
  w_sie(r_sie() | SIE_SEIE | SIE_STIE);
    800000a6:	2207e793          	ori	a5,a5,544
  asm volatile("csrw sie, %0" : : "r" (x));
    800000aa:	10479073          	csrw	sie,a5
  asm volatile("csrw pmpaddr0, %0" : : "r" (x));
    800000ae:	57fd                	li	a5,-1
    800000b0:	83a9                	srli	a5,a5,0xa
    800000b2:	3b079073          	csrw	pmpaddr0,a5
  asm volatile("csrw pmpcfg0, %0" : : "r" (x));
    800000b6:	47bd                	li	a5,15
    800000b8:	3a079073          	csrw	pmpcfg0,a5
  timerinit();
    800000bc:	f61ff0ef          	jal	8000001c <timerinit>
  asm volatile("csrr %0, mhartid" : "=r" (x) );
    800000c0:	f14027f3          	csrr	a5,mhartid
  w_tp(id);
    800000c4:	2781                	sext.w	a5,a5
}

static inline void 
w_tp(uint64 x)
{
  asm volatile("mv tp, %0" : : "r" (x));
    800000c6:	823e                	mv	tp,a5
  asm volatile("mret");
    800000c8:	30200073          	mret
}
    800000cc:	60a2                	ld	ra,8(sp)
    800000ce:	6402                	ld	s0,0(sp)
    800000d0:	0141                	addi	sp,sp,16
    800000d2:	8082                	ret

00000000800000d4 <consolewrite>:
//
// user write()s to the console go here.
//
int
consolewrite(int user_src, uint64 src, int n)
{
    800000d4:	7119                	addi	sp,sp,-128
    800000d6:	fc86                	sd	ra,120(sp)
    800000d8:	f8a2                	sd	s0,112(sp)
    800000da:	f4a6                	sd	s1,104(sp)
    800000dc:	0100                	addi	s0,sp,128
  char buf[32];
  int i = 0;

  while(i < n){
    800000de:	06c05b63          	blez	a2,80000154 <consolewrite+0x80>
    800000e2:	f0ca                	sd	s2,96(sp)
    800000e4:	ecce                	sd	s3,88(sp)
    800000e6:	e8d2                	sd	s4,80(sp)
    800000e8:	e4d6                	sd	s5,72(sp)
    800000ea:	e0da                	sd	s6,64(sp)
    800000ec:	fc5e                	sd	s7,56(sp)
    800000ee:	f862                	sd	s8,48(sp)
    800000f0:	f466                	sd	s9,40(sp)
    800000f2:	f06a                	sd	s10,32(sp)
    800000f4:	8b2a                	mv	s6,a0
    800000f6:	8bae                	mv	s7,a1
    800000f8:	8a32                	mv	s4,a2
  int i = 0;
    800000fa:	4481                	li	s1,0
    int nn = sizeof(buf);
    if(nn > n - i)
    800000fc:	02000c93          	li	s9,32
    80000100:	02000d13          	li	s10,32
      nn = n - i;
    if(either_copyin(buf, user_src, src+i, nn) == -1)
    80000104:	f8040a93          	addi	s5,s0,-128
    80000108:	5c7d                	li	s8,-1
    8000010a:	a025                	j	80000132 <consolewrite+0x5e>
    if(nn > n - i)
    8000010c:	0009099b          	sext.w	s3,s2
    if(either_copyin(buf, user_src, src+i, nn) == -1)
    80000110:	86ce                	mv	a3,s3
    80000112:	01748633          	add	a2,s1,s7
    80000116:	85da                	mv	a1,s6
    80000118:	8556                	mv	a0,s5
    8000011a:	13c020ef          	jal	80002256 <either_copyin>
    8000011e:	03850d63          	beq	a0,s8,80000158 <consolewrite+0x84>
      break;
    uartwrite(buf, nn);
    80000122:	85ce                	mv	a1,s3
    80000124:	8556                	mv	a0,s5
    80000126:	76e000ef          	jal	80000894 <uartwrite>
    i += nn;
    8000012a:	009904bb          	addw	s1,s2,s1
  while(i < n){
    8000012e:	0144d963          	bge	s1,s4,80000140 <consolewrite+0x6c>
    if(nn > n - i)
    80000132:	409a07bb          	subw	a5,s4,s1
    80000136:	893e                	mv	s2,a5
    80000138:	fcfcdae3          	bge	s9,a5,8000010c <consolewrite+0x38>
    8000013c:	896a                	mv	s2,s10
    8000013e:	b7f9                	j	8000010c <consolewrite+0x38>
    80000140:	7906                	ld	s2,96(sp)
    80000142:	69e6                	ld	s3,88(sp)
    80000144:	6a46                	ld	s4,80(sp)
    80000146:	6aa6                	ld	s5,72(sp)
    80000148:	6b06                	ld	s6,64(sp)
    8000014a:	7be2                	ld	s7,56(sp)
    8000014c:	7c42                	ld	s8,48(sp)
    8000014e:	7ca2                	ld	s9,40(sp)
    80000150:	7d02                	ld	s10,32(sp)
    80000152:	a821                	j	8000016a <consolewrite+0x96>
  int i = 0;
    80000154:	4481                	li	s1,0
    80000156:	a811                	j	8000016a <consolewrite+0x96>
    80000158:	7906                	ld	s2,96(sp)
    8000015a:	69e6                	ld	s3,88(sp)
    8000015c:	6a46                	ld	s4,80(sp)
    8000015e:	6aa6                	ld	s5,72(sp)
    80000160:	6b06                	ld	s6,64(sp)
    80000162:	7be2                	ld	s7,56(sp)
    80000164:	7c42                	ld	s8,48(sp)
    80000166:	7ca2                	ld	s9,40(sp)
    80000168:	7d02                	ld	s10,32(sp)
  }

  return i;
}
    8000016a:	8526                	mv	a0,s1
    8000016c:	70e6                	ld	ra,120(sp)
    8000016e:	7446                	ld	s0,112(sp)
    80000170:	74a6                	ld	s1,104(sp)
    80000172:	6109                	addi	sp,sp,128
    80000174:	8082                	ret

0000000080000176 <consoleread>:
// user_dist indicates whether dst is a user
// or kernel address.
//
int
consoleread(int user_dst, uint64 dst, int n)
{
    80000176:	711d                	addi	sp,sp,-96
    80000178:	ec86                	sd	ra,88(sp)
    8000017a:	e8a2                	sd	s0,80(sp)
    8000017c:	e4a6                	sd	s1,72(sp)
    8000017e:	e0ca                	sd	s2,64(sp)
    80000180:	fc4e                	sd	s3,56(sp)
    80000182:	f852                	sd	s4,48(sp)
    80000184:	f456                	sd	s5,40(sp)
    80000186:	f05a                	sd	s6,32(sp)
    80000188:	1080                	addi	s0,sp,96
    8000018a:	8aaa                	mv	s5,a0
    8000018c:	8a2e                	mv	s4,a1
    8000018e:	89b2                	mv	s3,a2
  uint target;
  int c;
  char cbuf;

  target = n;
    80000190:	8b32                	mv	s6,a2
  acquire(&cons.lock);
    80000192:	0000f517          	auipc	a0,0xf
    80000196:	73e50513          	addi	a0,a0,1854 # 8000f8d0 <cons>
    8000019a:	233000ef          	jal	80000bcc <acquire>
  while(n > 0){
    // wait until interrupt handler has put some
    // input into cons.buffer.
    while(cons.r == cons.w){
    8000019e:	0000f497          	auipc	s1,0xf
    800001a2:	73248493          	addi	s1,s1,1842 # 8000f8d0 <cons>
      if(killed(myproc())){
        release(&cons.lock);
        return -1;
      }
      sleep(&cons.r, &cons.lock);
    800001a6:	0000f917          	auipc	s2,0xf
    800001aa:	7c290913          	addi	s2,s2,1986 # 8000f968 <cons+0x98>
  while(n > 0){
    800001ae:	0b305b63          	blez	s3,80000264 <consoleread+0xee>
    while(cons.r == cons.w){
    800001b2:	0984a783          	lw	a5,152(s1)
    800001b6:	09c4a703          	lw	a4,156(s1)
    800001ba:	0af71063          	bne	a4,a5,8000025a <consoleread+0xe4>
      if(killed(myproc())){
    800001be:	700010ef          	jal	800018be <myproc>
    800001c2:	72d010ef          	jal	800020ee <killed>
    800001c6:	e12d                	bnez	a0,80000228 <consoleread+0xb2>
      sleep(&cons.r, &cons.lock);
    800001c8:	85a6                	mv	a1,s1
    800001ca:	854a                	mv	a0,s2
    800001cc:	4eb010ef          	jal	80001eb6 <sleep>
    while(cons.r == cons.w){
    800001d0:	0984a783          	lw	a5,152(s1)
    800001d4:	09c4a703          	lw	a4,156(s1)
    800001d8:	fef703e3          	beq	a4,a5,800001be <consoleread+0x48>
    800001dc:	ec5e                	sd	s7,24(sp)
    }

    c = cons.buf[cons.r++ % INPUT_BUF_SIZE];
    800001de:	0000f717          	auipc	a4,0xf
    800001e2:	6f270713          	addi	a4,a4,1778 # 8000f8d0 <cons>
    800001e6:	0017869b          	addiw	a3,a5,1
    800001ea:	08d72c23          	sw	a3,152(a4)
    800001ee:	07f7f693          	andi	a3,a5,127
    800001f2:	9736                	add	a4,a4,a3
    800001f4:	01874703          	lbu	a4,24(a4)
    800001f8:	00070b9b          	sext.w	s7,a4

    if(c == C('D')){  // end-of-file
    800001fc:	4691                	li	a3,4
    800001fe:	04db8663          	beq	s7,a3,8000024a <consoleread+0xd4>
      }
      break;
    }

    // copy the input byte to the user-space buffer.
    cbuf = c;
    80000202:	fae407a3          	sb	a4,-81(s0)
    if(either_copyout(user_dst, dst, &cbuf, 1) == -1)
    80000206:	4685                	li	a3,1
    80000208:	faf40613          	addi	a2,s0,-81
    8000020c:	85d2                	mv	a1,s4
    8000020e:	8556                	mv	a0,s5
    80000210:	7fd010ef          	jal	8000220c <either_copyout>
    80000214:	57fd                	li	a5,-1
    80000216:	04f50663          	beq	a0,a5,80000262 <consoleread+0xec>
      break;

    dst++;
    8000021a:	0a05                	addi	s4,s4,1
    --n;
    8000021c:	39fd                	addiw	s3,s3,-1

    if(c == '\n'){
    8000021e:	47a9                	li	a5,10
    80000220:	04fb8b63          	beq	s7,a5,80000276 <consoleread+0x100>
    80000224:	6be2                	ld	s7,24(sp)
    80000226:	b761                	j	800001ae <consoleread+0x38>
        release(&cons.lock);
    80000228:	0000f517          	auipc	a0,0xf
    8000022c:	6a850513          	addi	a0,a0,1704 # 8000f8d0 <cons>
    80000230:	231000ef          	jal	80000c60 <release>
        return -1;
    80000234:	557d                	li	a0,-1
    }
  }
  release(&cons.lock);

  return target - n;
}
    80000236:	60e6                	ld	ra,88(sp)
    80000238:	6446                	ld	s0,80(sp)
    8000023a:	64a6                	ld	s1,72(sp)
    8000023c:	6906                	ld	s2,64(sp)
    8000023e:	79e2                	ld	s3,56(sp)
    80000240:	7a42                	ld	s4,48(sp)
    80000242:	7aa2                	ld	s5,40(sp)
    80000244:	7b02                	ld	s6,32(sp)
    80000246:	6125                	addi	sp,sp,96
    80000248:	8082                	ret
      if(n < target){
    8000024a:	0169fa63          	bgeu	s3,s6,8000025e <consoleread+0xe8>
        cons.r--;
    8000024e:	0000f717          	auipc	a4,0xf
    80000252:	70f72d23          	sw	a5,1818(a4) # 8000f968 <cons+0x98>
    80000256:	6be2                	ld	s7,24(sp)
    80000258:	a031                	j	80000264 <consoleread+0xee>
    8000025a:	ec5e                	sd	s7,24(sp)
    8000025c:	b749                	j	800001de <consoleread+0x68>
    8000025e:	6be2                	ld	s7,24(sp)
    80000260:	a011                	j	80000264 <consoleread+0xee>
    80000262:	6be2                	ld	s7,24(sp)
  release(&cons.lock);
    80000264:	0000f517          	auipc	a0,0xf
    80000268:	66c50513          	addi	a0,a0,1644 # 8000f8d0 <cons>
    8000026c:	1f5000ef          	jal	80000c60 <release>
  return target - n;
    80000270:	413b053b          	subw	a0,s6,s3
    80000274:	b7c9                	j	80000236 <consoleread+0xc0>
    80000276:	6be2                	ld	s7,24(sp)
    80000278:	b7f5                	j	80000264 <consoleread+0xee>

000000008000027a <consputc>:
{
    8000027a:	1141                	addi	sp,sp,-16
    8000027c:	e406                	sd	ra,8(sp)
    8000027e:	e022                	sd	s0,0(sp)
    80000280:	0800                	addi	s0,sp,16
  if(c == BACKSPACE){
    80000282:	10000793          	li	a5,256
    80000286:	00f50863          	beq	a0,a5,80000296 <consputc+0x1c>
    uartputc_sync(c);
    8000028a:	69e000ef          	jal	80000928 <uartputc_sync>
}
    8000028e:	60a2                	ld	ra,8(sp)
    80000290:	6402                	ld	s0,0(sp)
    80000292:	0141                	addi	sp,sp,16
    80000294:	8082                	ret
    uartputc_sync('\b'); uartputc_sync(' '); uartputc_sync('\b');
    80000296:	4521                	li	a0,8
    80000298:	690000ef          	jal	80000928 <uartputc_sync>
    8000029c:	02000513          	li	a0,32
    800002a0:	688000ef          	jal	80000928 <uartputc_sync>
    800002a4:	4521                	li	a0,8
    800002a6:	682000ef          	jal	80000928 <uartputc_sync>
    800002aa:	b7d5                	j	8000028e <consputc+0x14>

00000000800002ac <consoleintr>:
// do erase/kill processing, append to cons.buf,
// wake up consoleread() if a whole line has arrived.
//
void
consoleintr(int c)
{
    800002ac:	7179                	addi	sp,sp,-48
    800002ae:	f406                	sd	ra,40(sp)
    800002b0:	f022                	sd	s0,32(sp)
    800002b2:	ec26                	sd	s1,24(sp)
    800002b4:	1800                	addi	s0,sp,48
    800002b6:	84aa                	mv	s1,a0
  acquire(&cons.lock);
    800002b8:	0000f517          	auipc	a0,0xf
    800002bc:	61850513          	addi	a0,a0,1560 # 8000f8d0 <cons>
    800002c0:	10d000ef          	jal	80000bcc <acquire>

  switch(c){
    800002c4:	47d5                	li	a5,21
    800002c6:	08f48e63          	beq	s1,a5,80000362 <consoleintr+0xb6>
    800002ca:	0297c563          	blt	a5,s1,800002f4 <consoleintr+0x48>
    800002ce:	47a1                	li	a5,8
    800002d0:	0ef48863          	beq	s1,a5,800003c0 <consoleintr+0x114>
    800002d4:	47c1                	li	a5,16
    800002d6:	10f49963          	bne	s1,a5,800003e8 <consoleintr+0x13c>
  case C('P'):  // Print process list.
    procdump();
    800002da:	7c7010ef          	jal	800022a0 <procdump>
      }
    }
    break;
  }
  
  release(&cons.lock);
    800002de:	0000f517          	auipc	a0,0xf
    800002e2:	5f250513          	addi	a0,a0,1522 # 8000f8d0 <cons>
    800002e6:	17b000ef          	jal	80000c60 <release>
}
    800002ea:	70a2                	ld	ra,40(sp)
    800002ec:	7402                	ld	s0,32(sp)
    800002ee:	64e2                	ld	s1,24(sp)
    800002f0:	6145                	addi	sp,sp,48
    800002f2:	8082                	ret
  switch(c){
    800002f4:	07f00793          	li	a5,127
    800002f8:	0cf48463          	beq	s1,a5,800003c0 <consoleintr+0x114>
    if(c != 0 && cons.e-cons.r < INPUT_BUF_SIZE){
    800002fc:	0000f717          	auipc	a4,0xf
    80000300:	5d470713          	addi	a4,a4,1492 # 8000f8d0 <cons>
    80000304:	0a072783          	lw	a5,160(a4)
    80000308:	09872703          	lw	a4,152(a4)
    8000030c:	9f99                	subw	a5,a5,a4
    8000030e:	07f00713          	li	a4,127
    80000312:	fcf766e3          	bltu	a4,a5,800002de <consoleintr+0x32>
      c = (c == '\r') ? '\n' : c;
    80000316:	47b5                	li	a5,13
    80000318:	0cf48b63          	beq	s1,a5,800003ee <consoleintr+0x142>
      consputc(c);
    8000031c:	8526                	mv	a0,s1
    8000031e:	f5dff0ef          	jal	8000027a <consputc>
      cons.buf[cons.e++ % INPUT_BUF_SIZE] = c;
    80000322:	0000f797          	auipc	a5,0xf
    80000326:	5ae78793          	addi	a5,a5,1454 # 8000f8d0 <cons>
    8000032a:	0a07a683          	lw	a3,160(a5)
    8000032e:	0016871b          	addiw	a4,a3,1
    80000332:	863a                	mv	a2,a4
    80000334:	0ae7a023          	sw	a4,160(a5)
    80000338:	07f6f693          	andi	a3,a3,127
    8000033c:	97b6                	add	a5,a5,a3
    8000033e:	00978c23          	sb	s1,24(a5)
      if(c == '\n' || c == C('D') || cons.e-cons.r == INPUT_BUF_SIZE){
    80000342:	47a9                	li	a5,10
    80000344:	0cf48963          	beq	s1,a5,80000416 <consoleintr+0x16a>
    80000348:	4791                	li	a5,4
    8000034a:	0cf48663          	beq	s1,a5,80000416 <consoleintr+0x16a>
    8000034e:	0000f797          	auipc	a5,0xf
    80000352:	61a7a783          	lw	a5,1562(a5) # 8000f968 <cons+0x98>
    80000356:	9f1d                	subw	a4,a4,a5
    80000358:	08000793          	li	a5,128
    8000035c:	f8f711e3          	bne	a4,a5,800002de <consoleintr+0x32>
    80000360:	a85d                	j	80000416 <consoleintr+0x16a>
    80000362:	e84a                	sd	s2,16(sp)
    80000364:	e44e                	sd	s3,8(sp)
    while(cons.e != cons.w &&
    80000366:	0000f717          	auipc	a4,0xf
    8000036a:	56a70713          	addi	a4,a4,1386 # 8000f8d0 <cons>
    8000036e:	0a072783          	lw	a5,160(a4)
    80000372:	09c72703          	lw	a4,156(a4)
          cons.buf[(cons.e-1) % INPUT_BUF_SIZE] != '\n'){
    80000376:	0000f497          	auipc	s1,0xf
    8000037a:	55a48493          	addi	s1,s1,1370 # 8000f8d0 <cons>
    while(cons.e != cons.w &&
    8000037e:	4929                	li	s2,10
      consputc(BACKSPACE);
    80000380:	10000993          	li	s3,256
    while(cons.e != cons.w &&
    80000384:	02f70863          	beq	a4,a5,800003b4 <consoleintr+0x108>
          cons.buf[(cons.e-1) % INPUT_BUF_SIZE] != '\n'){
    80000388:	37fd                	addiw	a5,a5,-1
    8000038a:	07f7f713          	andi	a4,a5,127
    8000038e:	9726                	add	a4,a4,s1
    while(cons.e != cons.w &&
    80000390:	01874703          	lbu	a4,24(a4)
    80000394:	03270363          	beq	a4,s2,800003ba <consoleintr+0x10e>
      cons.e--;
    80000398:	0af4a023          	sw	a5,160(s1)
      consputc(BACKSPACE);
    8000039c:	854e                	mv	a0,s3
    8000039e:	eddff0ef          	jal	8000027a <consputc>
    while(cons.e != cons.w &&
    800003a2:	0a04a783          	lw	a5,160(s1)
    800003a6:	09c4a703          	lw	a4,156(s1)
    800003aa:	fcf71fe3          	bne	a4,a5,80000388 <consoleintr+0xdc>
    800003ae:	6942                	ld	s2,16(sp)
    800003b0:	69a2                	ld	s3,8(sp)
    800003b2:	b735                	j	800002de <consoleintr+0x32>
    800003b4:	6942                	ld	s2,16(sp)
    800003b6:	69a2                	ld	s3,8(sp)
    800003b8:	b71d                	j	800002de <consoleintr+0x32>
    800003ba:	6942                	ld	s2,16(sp)
    800003bc:	69a2                	ld	s3,8(sp)
    800003be:	b705                	j	800002de <consoleintr+0x32>
    if(cons.e != cons.w){
    800003c0:	0000f717          	auipc	a4,0xf
    800003c4:	51070713          	addi	a4,a4,1296 # 8000f8d0 <cons>
    800003c8:	0a072783          	lw	a5,160(a4)
    800003cc:	09c72703          	lw	a4,156(a4)
    800003d0:	f0f707e3          	beq	a4,a5,800002de <consoleintr+0x32>
      cons.e--;
    800003d4:	37fd                	addiw	a5,a5,-1
    800003d6:	0000f717          	auipc	a4,0xf
    800003da:	58f72d23          	sw	a5,1434(a4) # 8000f970 <cons+0xa0>
      consputc(BACKSPACE);
    800003de:	10000513          	li	a0,256
    800003e2:	e99ff0ef          	jal	8000027a <consputc>
    800003e6:	bde5                	j	800002de <consoleintr+0x32>
    if(c != 0 && cons.e-cons.r < INPUT_BUF_SIZE){
    800003e8:	ee048be3          	beqz	s1,800002de <consoleintr+0x32>
    800003ec:	bf01                	j	800002fc <consoleintr+0x50>
      consputc(c);
    800003ee:	4529                	li	a0,10
    800003f0:	e8bff0ef          	jal	8000027a <consputc>
      cons.buf[cons.e++ % INPUT_BUF_SIZE] = c;
    800003f4:	0000f797          	auipc	a5,0xf
    800003f8:	4dc78793          	addi	a5,a5,1244 # 8000f8d0 <cons>
    800003fc:	0a07a703          	lw	a4,160(a5)
    80000400:	0017069b          	addiw	a3,a4,1
    80000404:	8636                	mv	a2,a3
    80000406:	0ad7a023          	sw	a3,160(a5)
    8000040a:	07f77713          	andi	a4,a4,127
    8000040e:	97ba                	add	a5,a5,a4
    80000410:	4729                	li	a4,10
    80000412:	00e78c23          	sb	a4,24(a5)
        cons.w = cons.e;
    80000416:	0000f797          	auipc	a5,0xf
    8000041a:	54c7ab23          	sw	a2,1366(a5) # 8000f96c <cons+0x9c>
        wakeup(&cons.r);
    8000041e:	0000f517          	auipc	a0,0xf
    80000422:	54a50513          	addi	a0,a0,1354 # 8000f968 <cons+0x98>
    80000426:	2dd010ef          	jal	80001f02 <wakeup>
    8000042a:	bd55                	j	800002de <consoleintr+0x32>

000000008000042c <consoleinit>:

void
consoleinit(void)
{
    8000042c:	1141                	addi	sp,sp,-16
    8000042e:	e406                	sd	ra,8(sp)
    80000430:	e022                	sd	s0,0(sp)
    80000432:	0800                	addi	s0,sp,16
  initlock(&cons.lock, "cons");
    80000434:	00007597          	auipc	a1,0x7
    80000438:	bcc58593          	addi	a1,a1,-1076 # 80007000 <etext>
    8000043c:	0000f517          	auipc	a0,0xf
    80000440:	49450513          	addi	a0,a0,1172 # 8000f8d0 <cons>
    80000444:	704000ef          	jal	80000b48 <initlock>

  uartinit();
    80000448:	3f6000ef          	jal	8000083e <uartinit>

  // connect read and write system calls
  // to consoleread and consolewrite.
  devsw[CONSOLE].read = consoleread;
    8000044c:	0001f797          	auipc	a5,0x1f
    80000450:	5f478793          	addi	a5,a5,1524 # 8001fa40 <devsw>
    80000454:	00000717          	auipc	a4,0x0
    80000458:	d2270713          	addi	a4,a4,-734 # 80000176 <consoleread>
    8000045c:	eb98                	sd	a4,16(a5)
  devsw[CONSOLE].write = consolewrite;
    8000045e:	00000717          	auipc	a4,0x0
    80000462:	c7670713          	addi	a4,a4,-906 # 800000d4 <consolewrite>
    80000466:	ef98                	sd	a4,24(a5)
}
    80000468:	60a2                	ld	ra,8(sp)
    8000046a:	6402                	ld	s0,0(sp)
    8000046c:	0141                	addi	sp,sp,16
    8000046e:	8082                	ret

0000000080000470 <printint>:

static char digits[] = "0123456789abcdef";

static void
printint(long long xx, int base, int sign)
{
    80000470:	7139                	addi	sp,sp,-64
    80000472:	fc06                	sd	ra,56(sp)
    80000474:	f822                	sd	s0,48(sp)
    80000476:	f426                	sd	s1,40(sp)
    80000478:	f04a                	sd	s2,32(sp)
    8000047a:	0080                	addi	s0,sp,64
  char buf[20];
  int i;
  unsigned long long x;

  if(sign && (sign = (xx < 0)))
    8000047c:	c219                	beqz	a2,80000482 <printint+0x12>
    8000047e:	06054a63          	bltz	a0,800004f2 <printint+0x82>
    x = -xx;
  else
    x = xx;
    80000482:	4e01                	li	t3,0

  i = 0;
    80000484:	fc840313          	addi	t1,s0,-56
    x = xx;
    80000488:	869a                	mv	a3,t1
  i = 0;
    8000048a:	4781                	li	a5,0
  do {
    buf[i++] = digits[x % base];
    8000048c:	00007817          	auipc	a6,0x7
    80000490:	2cc80813          	addi	a6,a6,716 # 80007758 <digits>
    80000494:	88be                	mv	a7,a5
    80000496:	0017861b          	addiw	a2,a5,1
    8000049a:	87b2                	mv	a5,a2
    8000049c:	02b57733          	remu	a4,a0,a1
    800004a0:	9742                	add	a4,a4,a6
    800004a2:	00074703          	lbu	a4,0(a4)
    800004a6:	00e68023          	sb	a4,0(a3)
  } while((x /= base) != 0);
    800004aa:	872a                	mv	a4,a0
    800004ac:	02b55533          	divu	a0,a0,a1
    800004b0:	0685                	addi	a3,a3,1
    800004b2:	feb771e3          	bgeu	a4,a1,80000494 <printint+0x24>

  if(sign)
    800004b6:	000e0c63          	beqz	t3,800004ce <printint+0x5e>
    buf[i++] = '-';
    800004ba:	fe060793          	addi	a5,a2,-32
    800004be:	00878633          	add	a2,a5,s0
    800004c2:	02d00793          	li	a5,45
    800004c6:	fef60423          	sb	a5,-24(a2)
    800004ca:	0028879b          	addiw	a5,a7,2

  while(--i >= 0)
    800004ce:	fff7891b          	addiw	s2,a5,-1
    800004d2:	006784b3          	add	s1,a5,t1
    consputc(buf[i]);
    800004d6:	fff4c503          	lbu	a0,-1(s1)
    800004da:	da1ff0ef          	jal	8000027a <consputc>
  while(--i >= 0)
    800004de:	397d                	addiw	s2,s2,-1
    800004e0:	14fd                	addi	s1,s1,-1
    800004e2:	fe095ae3          	bgez	s2,800004d6 <printint+0x66>
}
    800004e6:	70e2                	ld	ra,56(sp)
    800004e8:	7442                	ld	s0,48(sp)
    800004ea:	74a2                	ld	s1,40(sp)
    800004ec:	7902                	ld	s2,32(sp)
    800004ee:	6121                	addi	sp,sp,64
    800004f0:	8082                	ret
    x = -xx;
    800004f2:	40a00533          	neg	a0,a0
  if(sign && (sign = (xx < 0)))
    800004f6:	4e05                	li	t3,1
    x = -xx;
    800004f8:	b771                	j	80000484 <printint+0x14>

00000000800004fa <printf>:
}

// Print to the console.
int
printf(char *fmt, ...)
{
    800004fa:	7131                	addi	sp,sp,-192
    800004fc:	fc86                	sd	ra,120(sp)
    800004fe:	f8a2                	sd	s0,112(sp)
    80000500:	e8d2                	sd	s4,80(sp)
    80000502:	0100                	addi	s0,sp,128
    80000504:	8a2a                	mv	s4,a0
    80000506:	e40c                	sd	a1,8(s0)
    80000508:	e810                	sd	a2,16(s0)
    8000050a:	ec14                	sd	a3,24(s0)
    8000050c:	f018                	sd	a4,32(s0)
    8000050e:	f41c                	sd	a5,40(s0)
    80000510:	03043823          	sd	a6,48(s0)
    80000514:	03143c23          	sd	a7,56(s0)
  va_list ap;
  int i, cx, c0, c1, c2;
  char *s;

  if(panicking == 0)
    80000518:	00007797          	auipc	a5,0x7
    8000051c:	38c7a783          	lw	a5,908(a5) # 800078a4 <panicking>
    80000520:	c3a1                	beqz	a5,80000560 <printf+0x66>
    acquire(&pr.lock);

  va_start(ap, fmt);
    80000522:	00840793          	addi	a5,s0,8
    80000526:	f8f43423          	sd	a5,-120(s0)
  for(i = 0; (cx = fmt[i] & 0xff) != 0; i++){
    8000052a:	000a4503          	lbu	a0,0(s4)
    8000052e:	28050663          	beqz	a0,800007ba <printf+0x2c0>
    80000532:	f4a6                	sd	s1,104(sp)
    80000534:	f0ca                	sd	s2,96(sp)
    80000536:	ecce                	sd	s3,88(sp)
    80000538:	e4d6                	sd	s5,72(sp)
    8000053a:	e0da                	sd	s6,64(sp)
    8000053c:	f862                	sd	s8,48(sp)
    8000053e:	f466                	sd	s9,40(sp)
    80000540:	f06a                	sd	s10,32(sp)
    80000542:	ec6e                	sd	s11,24(sp)
    80000544:	4901                	li	s2,0
    if(cx != '%'){
    80000546:	02500a93          	li	s5,37
    i++;
    c0 = fmt[i+0] & 0xff;
    c1 = c2 = 0;
    if(c0) c1 = fmt[i+1] & 0xff;
    if(c1) c2 = fmt[i+2] & 0xff;
    if(c0 == 'd'){
    8000054a:	06400b13          	li	s6,100
      printint(va_arg(ap, int), 10, 1);
    } else if(c0 == 'l' && c1 == 'd'){
    8000054e:	06c00c13          	li	s8,108
      printint(va_arg(ap, uint64), 10, 1);
      i += 1;
    } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
      printint(va_arg(ap, uint64), 10, 1);
      i += 2;
    } else if(c0 == 'u'){
    80000552:	07500c93          	li	s9,117
      printint(va_arg(ap, uint64), 10, 0);
      i += 1;
    } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
      printint(va_arg(ap, uint64), 10, 0);
      i += 2;
    } else if(c0 == 'x'){
    80000556:	07800d13          	li	s10,120
      printint(va_arg(ap, uint64), 16, 0);
      i += 1;
    } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
      printint(va_arg(ap, uint64), 16, 0);
      i += 2;
    } else if(c0 == 'p'){
    8000055a:	07000d93          	li	s11,112
    8000055e:	a015                	j	80000582 <printf+0x88>
    acquire(&pr.lock);
    80000560:	0000f517          	auipc	a0,0xf
    80000564:	41850513          	addi	a0,a0,1048 # 8000f978 <pr>
    80000568:	664000ef          	jal	80000bcc <acquire>
    8000056c:	bf5d                	j	80000522 <printf+0x28>
      consputc(cx);
    8000056e:	d0dff0ef          	jal	8000027a <consputc>
      continue;
    80000572:	84ca                	mv	s1,s2
  for(i = 0; (cx = fmt[i] & 0xff) != 0; i++){
    80000574:	2485                	addiw	s1,s1,1
    80000576:	8926                	mv	s2,s1
    80000578:	94d2                	add	s1,s1,s4
    8000057a:	0004c503          	lbu	a0,0(s1)
    8000057e:	20050b63          	beqz	a0,80000794 <printf+0x29a>
    if(cx != '%'){
    80000582:	ff5516e3          	bne	a0,s5,8000056e <printf+0x74>
    i++;
    80000586:	0019079b          	addiw	a5,s2,1
    8000058a:	84be                	mv	s1,a5
    c0 = fmt[i+0] & 0xff;
    8000058c:	00fa0733          	add	a4,s4,a5
    80000590:	00074983          	lbu	s3,0(a4)
    if(c0) c1 = fmt[i+1] & 0xff;
    80000594:	20098a63          	beqz	s3,800007a8 <printf+0x2ae>
    80000598:	00174703          	lbu	a4,1(a4)
    c1 = c2 = 0;
    8000059c:	86ba                	mv	a3,a4
    if(c1) c2 = fmt[i+2] & 0xff;
    8000059e:	c701                	beqz	a4,800005a6 <printf+0xac>
    800005a0:	97d2                	add	a5,a5,s4
    800005a2:	0027c683          	lbu	a3,2(a5)
    if(c0 == 'd'){
    800005a6:	03698963          	beq	s3,s6,800005d8 <printf+0xde>
    } else if(c0 == 'l' && c1 == 'd'){
    800005aa:	05898363          	beq	s3,s8,800005f0 <printf+0xf6>
    } else if(c0 == 'u'){
    800005ae:	0d998663          	beq	s3,s9,8000067a <printf+0x180>
    } else if(c0 == 'x'){
    800005b2:	11a98d63          	beq	s3,s10,800006cc <printf+0x1d2>
    } else if(c0 == 'p'){
    800005b6:	15b98663          	beq	s3,s11,80000702 <printf+0x208>
      printptr(va_arg(ap, uint64));
    } else if(c0 == 'c'){
    800005ba:	06300793          	li	a5,99
    800005be:	18f98563          	beq	s3,a5,80000748 <printf+0x24e>
      consputc(va_arg(ap, uint));
    } else if(c0 == 's'){
    800005c2:	07300793          	li	a5,115
    800005c6:	18f98b63          	beq	s3,a5,8000075c <printf+0x262>
      if((s = va_arg(ap, char*)) == 0)
        s = "(null)";
      for(; *s; s++)
        consputc(*s);
    } else if(c0 == '%'){
    800005ca:	03599b63          	bne	s3,s5,80000600 <printf+0x106>
      consputc('%');
    800005ce:	02500513          	li	a0,37
    800005d2:	ca9ff0ef          	jal	8000027a <consputc>
    800005d6:	bf79                	j	80000574 <printf+0x7a>
      printint(va_arg(ap, int), 10, 1);
    800005d8:	f8843783          	ld	a5,-120(s0)
    800005dc:	00878713          	addi	a4,a5,8
    800005e0:	f8e43423          	sd	a4,-120(s0)
    800005e4:	4605                	li	a2,1
    800005e6:	45a9                	li	a1,10
    800005e8:	4388                	lw	a0,0(a5)
    800005ea:	e87ff0ef          	jal	80000470 <printint>
    800005ee:	b759                	j	80000574 <printf+0x7a>
    } else if(c0 == 'l' && c1 == 'd'){
    800005f0:	01670f63          	beq	a4,s6,8000060e <printf+0x114>
    } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
    800005f4:	03870b63          	beq	a4,s8,8000062a <printf+0x130>
    } else if(c0 == 'l' && c1 == 'u'){
    800005f8:	09970e63          	beq	a4,s9,80000694 <printf+0x19a>
    } else if(c0 == 'l' && c1 == 'x'){
    800005fc:	0fa70563          	beq	a4,s10,800006e6 <printf+0x1ec>
    } else if(c0 == 0){
      break;
    } else {
      // Print unknown % sequence to draw attention.
      consputc('%');
    80000600:	8556                	mv	a0,s5
    80000602:	c79ff0ef          	jal	8000027a <consputc>
      consputc(c0);
    80000606:	854e                	mv	a0,s3
    80000608:	c73ff0ef          	jal	8000027a <consputc>
    8000060c:	b7a5                	j	80000574 <printf+0x7a>
      printint(va_arg(ap, uint64), 10, 1);
    8000060e:	f8843783          	ld	a5,-120(s0)
    80000612:	00878713          	addi	a4,a5,8
    80000616:	f8e43423          	sd	a4,-120(s0)
    8000061a:	4605                	li	a2,1
    8000061c:	45a9                	li	a1,10
    8000061e:	6388                	ld	a0,0(a5)
    80000620:	e51ff0ef          	jal	80000470 <printint>
      i += 1;
    80000624:	0029049b          	addiw	s1,s2,2
    80000628:	b7b1                	j	80000574 <printf+0x7a>
    } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
    8000062a:	06400793          	li	a5,100
    8000062e:	02f68863          	beq	a3,a5,8000065e <printf+0x164>
    } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
    80000632:	07500793          	li	a5,117
    80000636:	06f68d63          	beq	a3,a5,800006b0 <printf+0x1b6>
    } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
    8000063a:	07800793          	li	a5,120
    8000063e:	fcf691e3          	bne	a3,a5,80000600 <printf+0x106>
      printint(va_arg(ap, uint64), 16, 0);
    80000642:	f8843783          	ld	a5,-120(s0)
    80000646:	00878713          	addi	a4,a5,8
    8000064a:	f8e43423          	sd	a4,-120(s0)
    8000064e:	4601                	li	a2,0
    80000650:	45c1                	li	a1,16
    80000652:	6388                	ld	a0,0(a5)
    80000654:	e1dff0ef          	jal	80000470 <printint>
      i += 2;
    80000658:	0039049b          	addiw	s1,s2,3
    8000065c:	bf21                	j	80000574 <printf+0x7a>
      printint(va_arg(ap, uint64), 10, 1);
    8000065e:	f8843783          	ld	a5,-120(s0)
    80000662:	00878713          	addi	a4,a5,8
    80000666:	f8e43423          	sd	a4,-120(s0)
    8000066a:	4605                	li	a2,1
    8000066c:	45a9                	li	a1,10
    8000066e:	6388                	ld	a0,0(a5)
    80000670:	e01ff0ef          	jal	80000470 <printint>
      i += 2;
    80000674:	0039049b          	addiw	s1,s2,3
    80000678:	bdf5                	j	80000574 <printf+0x7a>
      printint(va_arg(ap, uint32), 10, 0);
    8000067a:	f8843783          	ld	a5,-120(s0)
    8000067e:	00878713          	addi	a4,a5,8
    80000682:	f8e43423          	sd	a4,-120(s0)
    80000686:	4601                	li	a2,0
    80000688:	45a9                	li	a1,10
    8000068a:	0007e503          	lwu	a0,0(a5)
    8000068e:	de3ff0ef          	jal	80000470 <printint>
    80000692:	b5cd                	j	80000574 <printf+0x7a>
      printint(va_arg(ap, uint64), 10, 0);
    80000694:	f8843783          	ld	a5,-120(s0)
    80000698:	00878713          	addi	a4,a5,8
    8000069c:	f8e43423          	sd	a4,-120(s0)
    800006a0:	4601                	li	a2,0
    800006a2:	45a9                	li	a1,10
    800006a4:	6388                	ld	a0,0(a5)
    800006a6:	dcbff0ef          	jal	80000470 <printint>
      i += 1;
    800006aa:	0029049b          	addiw	s1,s2,2
    800006ae:	b5d9                	j	80000574 <printf+0x7a>
      printint(va_arg(ap, uint64), 10, 0);
    800006b0:	f8843783          	ld	a5,-120(s0)
    800006b4:	00878713          	addi	a4,a5,8
    800006b8:	f8e43423          	sd	a4,-120(s0)
    800006bc:	4601                	li	a2,0
    800006be:	45a9                	li	a1,10
    800006c0:	6388                	ld	a0,0(a5)
    800006c2:	dafff0ef          	jal	80000470 <printint>
      i += 2;
    800006c6:	0039049b          	addiw	s1,s2,3
    800006ca:	b56d                	j	80000574 <printf+0x7a>
      printint(va_arg(ap, uint32), 16, 0);
    800006cc:	f8843783          	ld	a5,-120(s0)
    800006d0:	00878713          	addi	a4,a5,8
    800006d4:	f8e43423          	sd	a4,-120(s0)
    800006d8:	4601                	li	a2,0
    800006da:	45c1                	li	a1,16
    800006dc:	0007e503          	lwu	a0,0(a5)
    800006e0:	d91ff0ef          	jal	80000470 <printint>
    800006e4:	bd41                	j	80000574 <printf+0x7a>
      printint(va_arg(ap, uint64), 16, 0);
    800006e6:	f8843783          	ld	a5,-120(s0)
    800006ea:	00878713          	addi	a4,a5,8
    800006ee:	f8e43423          	sd	a4,-120(s0)
    800006f2:	4601                	li	a2,0
    800006f4:	45c1                	li	a1,16
    800006f6:	6388                	ld	a0,0(a5)
    800006f8:	d79ff0ef          	jal	80000470 <printint>
      i += 1;
    800006fc:	0029049b          	addiw	s1,s2,2
    80000700:	bd95                	j	80000574 <printf+0x7a>
    80000702:	fc5e                	sd	s7,56(sp)
      printptr(va_arg(ap, uint64));
    80000704:	f8843783          	ld	a5,-120(s0)
    80000708:	00878713          	addi	a4,a5,8
    8000070c:	f8e43423          	sd	a4,-120(s0)
    80000710:	0007b983          	ld	s3,0(a5)
  consputc('0');
    80000714:	03000513          	li	a0,48
    80000718:	b63ff0ef          	jal	8000027a <consputc>
  consputc('x');
    8000071c:	07800513          	li	a0,120
    80000720:	b5bff0ef          	jal	8000027a <consputc>
    80000724:	4941                	li	s2,16
    consputc(digits[x >> (sizeof(uint64) * 8 - 4)]);
    80000726:	00007b97          	auipc	s7,0x7
    8000072a:	032b8b93          	addi	s7,s7,50 # 80007758 <digits>
    8000072e:	03c9d793          	srli	a5,s3,0x3c
    80000732:	97de                	add	a5,a5,s7
    80000734:	0007c503          	lbu	a0,0(a5)
    80000738:	b43ff0ef          	jal	8000027a <consputc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
    8000073c:	0992                	slli	s3,s3,0x4
    8000073e:	397d                	addiw	s2,s2,-1
    80000740:	fe0917e3          	bnez	s2,8000072e <printf+0x234>
    80000744:	7be2                	ld	s7,56(sp)
    80000746:	b53d                	j	80000574 <printf+0x7a>
      consputc(va_arg(ap, uint));
    80000748:	f8843783          	ld	a5,-120(s0)
    8000074c:	00878713          	addi	a4,a5,8
    80000750:	f8e43423          	sd	a4,-120(s0)
    80000754:	4388                	lw	a0,0(a5)
    80000756:	b25ff0ef          	jal	8000027a <consputc>
    8000075a:	bd29                	j	80000574 <printf+0x7a>
      if((s = va_arg(ap, char*)) == 0)
    8000075c:	f8843783          	ld	a5,-120(s0)
    80000760:	00878713          	addi	a4,a5,8
    80000764:	f8e43423          	sd	a4,-120(s0)
    80000768:	0007b903          	ld	s2,0(a5)
    8000076c:	00090d63          	beqz	s2,80000786 <printf+0x28c>
      for(; *s; s++)
    80000770:	00094503          	lbu	a0,0(s2)
    80000774:	e00500e3          	beqz	a0,80000574 <printf+0x7a>
        consputc(*s);
    80000778:	b03ff0ef          	jal	8000027a <consputc>
      for(; *s; s++)
    8000077c:	0905                	addi	s2,s2,1
    8000077e:	00094503          	lbu	a0,0(s2)
    80000782:	f97d                	bnez	a0,80000778 <printf+0x27e>
    80000784:	bbc5                	j	80000574 <printf+0x7a>
        s = "(null)";
    80000786:	00007917          	auipc	s2,0x7
    8000078a:	88290913          	addi	s2,s2,-1918 # 80007008 <etext+0x8>
      for(; *s; s++)
    8000078e:	02800513          	li	a0,40
    80000792:	b7dd                	j	80000778 <printf+0x27e>
    80000794:	74a6                	ld	s1,104(sp)
    80000796:	7906                	ld	s2,96(sp)
    80000798:	69e6                	ld	s3,88(sp)
    8000079a:	6aa6                	ld	s5,72(sp)
    8000079c:	6b06                	ld	s6,64(sp)
    8000079e:	7c42                	ld	s8,48(sp)
    800007a0:	7ca2                	ld	s9,40(sp)
    800007a2:	7d02                	ld	s10,32(sp)
    800007a4:	6de2                	ld	s11,24(sp)
    800007a6:	a811                	j	800007ba <printf+0x2c0>
    800007a8:	74a6                	ld	s1,104(sp)
    800007aa:	7906                	ld	s2,96(sp)
    800007ac:	69e6                	ld	s3,88(sp)
    800007ae:	6aa6                	ld	s5,72(sp)
    800007b0:	6b06                	ld	s6,64(sp)
    800007b2:	7c42                	ld	s8,48(sp)
    800007b4:	7ca2                	ld	s9,40(sp)
    800007b6:	7d02                	ld	s10,32(sp)
    800007b8:	6de2                	ld	s11,24(sp)
    }

  }
  va_end(ap);

  if(panicking == 0)
    800007ba:	00007797          	auipc	a5,0x7
    800007be:	0ea7a783          	lw	a5,234(a5) # 800078a4 <panicking>
    800007c2:	c799                	beqz	a5,800007d0 <printf+0x2d6>
    release(&pr.lock);

  return 0;
}
    800007c4:	4501                	li	a0,0
    800007c6:	70e6                	ld	ra,120(sp)
    800007c8:	7446                	ld	s0,112(sp)
    800007ca:	6a46                	ld	s4,80(sp)
    800007cc:	6129                	addi	sp,sp,192
    800007ce:	8082                	ret
    release(&pr.lock);
    800007d0:	0000f517          	auipc	a0,0xf
    800007d4:	1a850513          	addi	a0,a0,424 # 8000f978 <pr>
    800007d8:	488000ef          	jal	80000c60 <release>
  return 0;
    800007dc:	b7e5                	j	800007c4 <printf+0x2ca>

00000000800007de <panic>:

void
panic(char *s)
{
    800007de:	1101                	addi	sp,sp,-32
    800007e0:	ec06                	sd	ra,24(sp)
    800007e2:	e822                	sd	s0,16(sp)
    800007e4:	e426                	sd	s1,8(sp)
    800007e6:	e04a                	sd	s2,0(sp)
    800007e8:	1000                	addi	s0,sp,32
    800007ea:	84aa                	mv	s1,a0
  panicking = 1;
    800007ec:	4905                	li	s2,1
    800007ee:	00007797          	auipc	a5,0x7
    800007f2:	0b27ab23          	sw	s2,182(a5) # 800078a4 <panicking>
  printf("panic: ");
    800007f6:	00007517          	auipc	a0,0x7
    800007fa:	82250513          	addi	a0,a0,-2014 # 80007018 <etext+0x18>
    800007fe:	cfdff0ef          	jal	800004fa <printf>
  printf("%s\n", s);
    80000802:	85a6                	mv	a1,s1
    80000804:	00007517          	auipc	a0,0x7
    80000808:	81c50513          	addi	a0,a0,-2020 # 80007020 <etext+0x20>
    8000080c:	cefff0ef          	jal	800004fa <printf>
  panicked = 1; // freeze uart output from other CPUs
    80000810:	00007797          	auipc	a5,0x7
    80000814:	0927a823          	sw	s2,144(a5) # 800078a0 <panicked>
  for(;;)
    80000818:	a001                	j	80000818 <panic+0x3a>

000000008000081a <printfinit>:
    ;
}

void
printfinit(void)
{
    8000081a:	1141                	addi	sp,sp,-16
    8000081c:	e406                	sd	ra,8(sp)
    8000081e:	e022                	sd	s0,0(sp)
    80000820:	0800                	addi	s0,sp,16
  initlock(&pr.lock, "pr");
    80000822:	00007597          	auipc	a1,0x7
    80000826:	80658593          	addi	a1,a1,-2042 # 80007028 <etext+0x28>
    8000082a:	0000f517          	auipc	a0,0xf
    8000082e:	14e50513          	addi	a0,a0,334 # 8000f978 <pr>
    80000832:	316000ef          	jal	80000b48 <initlock>
}
    80000836:	60a2                	ld	ra,8(sp)
    80000838:	6402                	ld	s0,0(sp)
    8000083a:	0141                	addi	sp,sp,16
    8000083c:	8082                	ret

000000008000083e <uartinit>:
extern volatile int panicking; // from printf.c
extern volatile int panicked; // from printf.c

void
uartinit(void)
{
    8000083e:	1141                	addi	sp,sp,-16
    80000840:	e406                	sd	ra,8(sp)
    80000842:	e022                	sd	s0,0(sp)
    80000844:	0800                	addi	s0,sp,16
  // disable interrupts.
  WriteReg(IER, 0x00);
    80000846:	100007b7          	lui	a5,0x10000
    8000084a:	000780a3          	sb	zero,1(a5) # 10000001 <_entry-0x6fffffff>

  // special mode to set baud rate.
  WriteReg(LCR, LCR_BAUD_LATCH);
    8000084e:	10000737          	lui	a4,0x10000
    80000852:	f8000693          	li	a3,-128
    80000856:	00d701a3          	sb	a3,3(a4) # 10000003 <_entry-0x6ffffffd>

  // LSB for baud rate of 38.4K.
  WriteReg(0, 0x03);
    8000085a:	468d                	li	a3,3
    8000085c:	10000637          	lui	a2,0x10000
    80000860:	00d60023          	sb	a3,0(a2) # 10000000 <_entry-0x70000000>

  // MSB for baud rate of 38.4K.
  WriteReg(1, 0x00);
    80000864:	000780a3          	sb	zero,1(a5)

  // leave set-baud mode,
  // and set word length to 8 bits, no parity.
  WriteReg(LCR, LCR_EIGHT_BITS);
    80000868:	00d701a3          	sb	a3,3(a4)

  // reset and enable FIFOs.
  WriteReg(FCR, FCR_FIFO_ENABLE | FCR_FIFO_CLEAR);
    8000086c:	8732                	mv	a4,a2
    8000086e:	461d                	li	a2,7
    80000870:	00c70123          	sb	a2,2(a4)

  // enable transmit and receive interrupts.
  WriteReg(IER, IER_TX_ENABLE | IER_RX_ENABLE);
    80000874:	00d780a3          	sb	a3,1(a5)

  initlock(&tx_lock, "uart");
    80000878:	00006597          	auipc	a1,0x6
    8000087c:	7b858593          	addi	a1,a1,1976 # 80007030 <etext+0x30>
    80000880:	0000f517          	auipc	a0,0xf
    80000884:	11050513          	addi	a0,a0,272 # 8000f990 <tx_lock>
    80000888:	2c0000ef          	jal	80000b48 <initlock>
}
    8000088c:	60a2                	ld	ra,8(sp)
    8000088e:	6402                	ld	s0,0(sp)
    80000890:	0141                	addi	sp,sp,16
    80000892:	8082                	ret

0000000080000894 <uartwrite>:
// transmit buf[] to the uart. it blocks if the
// uart is busy, so it cannot be called from
// interrupts, only from write() system calls.
void
uartwrite(char buf[], int n)
{
    80000894:	715d                	addi	sp,sp,-80
    80000896:	e486                	sd	ra,72(sp)
    80000898:	e0a2                	sd	s0,64(sp)
    8000089a:	fc26                	sd	s1,56(sp)
    8000089c:	ec56                	sd	s5,24(sp)
    8000089e:	0880                	addi	s0,sp,80
    800008a0:	8aaa                	mv	s5,a0
    800008a2:	84ae                	mv	s1,a1
  acquire(&tx_lock);
    800008a4:	0000f517          	auipc	a0,0xf
    800008a8:	0ec50513          	addi	a0,a0,236 # 8000f990 <tx_lock>
    800008ac:	320000ef          	jal	80000bcc <acquire>

  int i = 0;
  while(i < n){ 
    800008b0:	06905063          	blez	s1,80000910 <uartwrite+0x7c>
    800008b4:	f84a                	sd	s2,48(sp)
    800008b6:	f44e                	sd	s3,40(sp)
    800008b8:	f052                	sd	s4,32(sp)
    800008ba:	e85a                	sd	s6,16(sp)
    800008bc:	e45e                	sd	s7,8(sp)
    800008be:	8a56                	mv	s4,s5
    800008c0:	9aa6                	add	s5,s5,s1
    while(tx_busy != 0){
    800008c2:	00007497          	auipc	s1,0x7
    800008c6:	fea48493          	addi	s1,s1,-22 # 800078ac <tx_busy>
      // wait for a UART transmit-complete interrupt
      // to set tx_busy to 0.
      sleep(&tx_chan, &tx_lock);
    800008ca:	0000f997          	auipc	s3,0xf
    800008ce:	0c698993          	addi	s3,s3,198 # 8000f990 <tx_lock>
    800008d2:	00007917          	auipc	s2,0x7
    800008d6:	fd690913          	addi	s2,s2,-42 # 800078a8 <tx_chan>
    }   
      
    WriteReg(THR, buf[i]);
    800008da:	10000bb7          	lui	s7,0x10000
    i += 1;
    tx_busy = 1;
    800008de:	4b05                	li	s6,1
    800008e0:	a005                	j	80000900 <uartwrite+0x6c>
      sleep(&tx_chan, &tx_lock);
    800008e2:	85ce                	mv	a1,s3
    800008e4:	854a                	mv	a0,s2
    800008e6:	5d0010ef          	jal	80001eb6 <sleep>
    while(tx_busy != 0){
    800008ea:	409c                	lw	a5,0(s1)
    800008ec:	fbfd                	bnez	a5,800008e2 <uartwrite+0x4e>
    WriteReg(THR, buf[i]);
    800008ee:	000a4783          	lbu	a5,0(s4)
    800008f2:	00fb8023          	sb	a5,0(s7) # 10000000 <_entry-0x70000000>
    tx_busy = 1;
    800008f6:	0164a023          	sw	s6,0(s1)
  while(i < n){ 
    800008fa:	0a05                	addi	s4,s4,1
    800008fc:	015a0563          	beq	s4,s5,80000906 <uartwrite+0x72>
    while(tx_busy != 0){
    80000900:	409c                	lw	a5,0(s1)
    80000902:	f3e5                	bnez	a5,800008e2 <uartwrite+0x4e>
    80000904:	b7ed                	j	800008ee <uartwrite+0x5a>
    80000906:	7942                	ld	s2,48(sp)
    80000908:	79a2                	ld	s3,40(sp)
    8000090a:	7a02                	ld	s4,32(sp)
    8000090c:	6b42                	ld	s6,16(sp)
    8000090e:	6ba2                	ld	s7,8(sp)
  }

  release(&tx_lock);
    80000910:	0000f517          	auipc	a0,0xf
    80000914:	08050513          	addi	a0,a0,128 # 8000f990 <tx_lock>
    80000918:	348000ef          	jal	80000c60 <release>
}
    8000091c:	60a6                	ld	ra,72(sp)
    8000091e:	6406                	ld	s0,64(sp)
    80000920:	74e2                	ld	s1,56(sp)
    80000922:	6ae2                	ld	s5,24(sp)
    80000924:	6161                	addi	sp,sp,80
    80000926:	8082                	ret

0000000080000928 <uartputc_sync>:
// interrupts, for use by kernel printf() and
// to echo characters. it spins waiting for the uart's
// output register to be empty.
void
uartputc_sync(int c)
{
    80000928:	1101                	addi	sp,sp,-32
    8000092a:	ec06                	sd	ra,24(sp)
    8000092c:	e822                	sd	s0,16(sp)
    8000092e:	e426                	sd	s1,8(sp)
    80000930:	1000                	addi	s0,sp,32
    80000932:	84aa                	mv	s1,a0
  if(panicking == 0)
    80000934:	00007797          	auipc	a5,0x7
    80000938:	f707a783          	lw	a5,-144(a5) # 800078a4 <panicking>
    8000093c:	cf95                	beqz	a5,80000978 <uartputc_sync+0x50>
    push_off();

  if(panicked){
    8000093e:	00007797          	auipc	a5,0x7
    80000942:	f627a783          	lw	a5,-158(a5) # 800078a0 <panicked>
    80000946:	ef85                	bnez	a5,8000097e <uartputc_sync+0x56>
    for(;;)
      ;
  }

  // wait for Transmit Holding Empty to be set in LSR.
  while((ReadReg(LSR) & LSR_TX_IDLE) == 0)
    80000948:	10000737          	lui	a4,0x10000
    8000094c:	0715                	addi	a4,a4,5 # 10000005 <_entry-0x6ffffffb>
    8000094e:	00074783          	lbu	a5,0(a4)
    80000952:	0207f793          	andi	a5,a5,32
    80000956:	dfe5                	beqz	a5,8000094e <uartputc_sync+0x26>
    ;
  WriteReg(THR, c);
    80000958:	0ff4f513          	zext.b	a0,s1
    8000095c:	100007b7          	lui	a5,0x10000
    80000960:	00a78023          	sb	a0,0(a5) # 10000000 <_entry-0x70000000>

  if(panicking == 0)
    80000964:	00007797          	auipc	a5,0x7
    80000968:	f407a783          	lw	a5,-192(a5) # 800078a4 <panicking>
    8000096c:	cb91                	beqz	a5,80000980 <uartputc_sync+0x58>
    pop_off();
}
    8000096e:	60e2                	ld	ra,24(sp)
    80000970:	6442                	ld	s0,16(sp)
    80000972:	64a2                	ld	s1,8(sp)
    80000974:	6105                	addi	sp,sp,32
    80000976:	8082                	ret
    push_off();
    80000978:	214000ef          	jal	80000b8c <push_off>
    8000097c:	b7c9                	j	8000093e <uartputc_sync+0x16>
    for(;;)
    8000097e:	a001                	j	8000097e <uartputc_sync+0x56>
    pop_off();
    80000980:	290000ef          	jal	80000c10 <pop_off>
}
    80000984:	b7ed                	j	8000096e <uartputc_sync+0x46>

0000000080000986 <uartgetc>:

// read one input character from the UART.
// return -1 if none is waiting.
int
uartgetc(void)
{
    80000986:	1141                	addi	sp,sp,-16
    80000988:	e406                	sd	ra,8(sp)
    8000098a:	e022                	sd	s0,0(sp)
    8000098c:	0800                	addi	s0,sp,16
  if(ReadReg(LSR) & LSR_RX_READY){
    8000098e:	100007b7          	lui	a5,0x10000
    80000992:	0057c783          	lbu	a5,5(a5) # 10000005 <_entry-0x6ffffffb>
    80000996:	8b85                	andi	a5,a5,1
    80000998:	cb89                	beqz	a5,800009aa <uartgetc+0x24>
    // input data is ready.
    return ReadReg(RHR);
    8000099a:	100007b7          	lui	a5,0x10000
    8000099e:	0007c503          	lbu	a0,0(a5) # 10000000 <_entry-0x70000000>
  } else {
    return -1;
  }
}
    800009a2:	60a2                	ld	ra,8(sp)
    800009a4:	6402                	ld	s0,0(sp)
    800009a6:	0141                	addi	sp,sp,16
    800009a8:	8082                	ret
    return -1;
    800009aa:	557d                	li	a0,-1
    800009ac:	bfdd                	j	800009a2 <uartgetc+0x1c>

00000000800009ae <uartintr>:
// handle a uart interrupt, raised because input has
// arrived, or the uart is ready for more output, or
// both. called from devintr().
void
uartintr(void)
{
    800009ae:	1101                	addi	sp,sp,-32
    800009b0:	ec06                	sd	ra,24(sp)
    800009b2:	e822                	sd	s0,16(sp)
    800009b4:	e426                	sd	s1,8(sp)
    800009b6:	1000                	addi	s0,sp,32
  ReadReg(ISR); // acknowledge the interrupt
    800009b8:	100007b7          	lui	a5,0x10000
    800009bc:	0027c783          	lbu	a5,2(a5) # 10000002 <_entry-0x6ffffffe>

  acquire(&tx_lock);
    800009c0:	0000f517          	auipc	a0,0xf
    800009c4:	fd050513          	addi	a0,a0,-48 # 8000f990 <tx_lock>
    800009c8:	204000ef          	jal	80000bcc <acquire>
  if(ReadReg(LSR) & LSR_TX_IDLE){
    800009cc:	100007b7          	lui	a5,0x10000
    800009d0:	0057c783          	lbu	a5,5(a5) # 10000005 <_entry-0x6ffffffb>
    800009d4:	0207f793          	andi	a5,a5,32
    800009d8:	ef99                	bnez	a5,800009f6 <uartintr+0x48>
    // UART finished transmitting; wake up sending thread.
    tx_busy = 0;
    wakeup(&tx_chan);
  }
  release(&tx_lock);
    800009da:	0000f517          	auipc	a0,0xf
    800009de:	fb650513          	addi	a0,a0,-74 # 8000f990 <tx_lock>
    800009e2:	27e000ef          	jal	80000c60 <release>

  // read and process incoming characters.
  while(1){
    int c = uartgetc();
    if(c == -1)
    800009e6:	54fd                	li	s1,-1
    int c = uartgetc();
    800009e8:	f9fff0ef          	jal	80000986 <uartgetc>
    if(c == -1)
    800009ec:	02950063          	beq	a0,s1,80000a0c <uartintr+0x5e>
      break;
    consoleintr(c);
    800009f0:	8bdff0ef          	jal	800002ac <consoleintr>
  while(1){
    800009f4:	bfd5                	j	800009e8 <uartintr+0x3a>
    tx_busy = 0;
    800009f6:	00007797          	auipc	a5,0x7
    800009fa:	ea07ab23          	sw	zero,-330(a5) # 800078ac <tx_busy>
    wakeup(&tx_chan);
    800009fe:	00007517          	auipc	a0,0x7
    80000a02:	eaa50513          	addi	a0,a0,-342 # 800078a8 <tx_chan>
    80000a06:	4fc010ef          	jal	80001f02 <wakeup>
    80000a0a:	bfc1                	j	800009da <uartintr+0x2c>
  }
}
    80000a0c:	60e2                	ld	ra,24(sp)
    80000a0e:	6442                	ld	s0,16(sp)
    80000a10:	64a2                	ld	s1,8(sp)
    80000a12:	6105                	addi	sp,sp,32
    80000a14:	8082                	ret

0000000080000a16 <kfree>:
// which normally should have been returned by a
// call to kalloc().  (The exception is when
// initializing the allocator; see kinit above.)
void
kfree(void *pa)
{
    80000a16:	1101                	addi	sp,sp,-32
    80000a18:	ec06                	sd	ra,24(sp)
    80000a1a:	e822                	sd	s0,16(sp)
    80000a1c:	e426                	sd	s1,8(sp)
    80000a1e:	e04a                	sd	s2,0(sp)
    80000a20:	1000                	addi	s0,sp,32
  struct run *r;

  if(((uint64)pa % PGSIZE) != 0 || (char*)pa < end || (uint64)pa >= PHYSTOP)
    80000a22:	03451793          	slli	a5,a0,0x34
    80000a26:	e7a9                	bnez	a5,80000a70 <kfree+0x5a>
    80000a28:	84aa                	mv	s1,a0
    80000a2a:	00020797          	auipc	a5,0x20
    80000a2e:	1ae78793          	addi	a5,a5,430 # 80020bd8 <end>
    80000a32:	02f56f63          	bltu	a0,a5,80000a70 <kfree+0x5a>
    80000a36:	47c5                	li	a5,17
    80000a38:	07ee                	slli	a5,a5,0x1b
    80000a3a:	02f57b63          	bgeu	a0,a5,80000a70 <kfree+0x5a>
    panic("kfree");

  // Fill with junk to catch dangling refs.
  memset(pa, 1, PGSIZE);
    80000a3e:	6605                	lui	a2,0x1
    80000a40:	4585                	li	a1,1
    80000a42:	25a000ef          	jal	80000c9c <memset>

  r = (struct run*)pa;

  acquire(&kmem.lock);
    80000a46:	0000f917          	auipc	s2,0xf
    80000a4a:	f6290913          	addi	s2,s2,-158 # 8000f9a8 <kmem>
    80000a4e:	854a                	mv	a0,s2
    80000a50:	17c000ef          	jal	80000bcc <acquire>
  r->next = kmem.freelist;
    80000a54:	01893783          	ld	a5,24(s2)
    80000a58:	e09c                	sd	a5,0(s1)
  kmem.freelist = r;
    80000a5a:	00993c23          	sd	s1,24(s2)
  release(&kmem.lock);
    80000a5e:	854a                	mv	a0,s2
    80000a60:	200000ef          	jal	80000c60 <release>
}
    80000a64:	60e2                	ld	ra,24(sp)
    80000a66:	6442                	ld	s0,16(sp)
    80000a68:	64a2                	ld	s1,8(sp)
    80000a6a:	6902                	ld	s2,0(sp)
    80000a6c:	6105                	addi	sp,sp,32
    80000a6e:	8082                	ret
    panic("kfree");
    80000a70:	00006517          	auipc	a0,0x6
    80000a74:	5c850513          	addi	a0,a0,1480 # 80007038 <etext+0x38>
    80000a78:	d67ff0ef          	jal	800007de <panic>

0000000080000a7c <freerange>:
{
    80000a7c:	7179                	addi	sp,sp,-48
    80000a7e:	f406                	sd	ra,40(sp)
    80000a80:	f022                	sd	s0,32(sp)
    80000a82:	ec26                	sd	s1,24(sp)
    80000a84:	1800                	addi	s0,sp,48
  p = (char*)PGROUNDUP((uint64)pa_start);
    80000a86:	6785                	lui	a5,0x1
    80000a88:	fff78713          	addi	a4,a5,-1 # fff <_entry-0x7ffff001>
    80000a8c:	00e504b3          	add	s1,a0,a4
    80000a90:	777d                	lui	a4,0xfffff
    80000a92:	8cf9                	and	s1,s1,a4
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    80000a94:	94be                	add	s1,s1,a5
    80000a96:	0295e263          	bltu	a1,s1,80000aba <freerange+0x3e>
    80000a9a:	e84a                	sd	s2,16(sp)
    80000a9c:	e44e                	sd	s3,8(sp)
    80000a9e:	e052                	sd	s4,0(sp)
    80000aa0:	892e                	mv	s2,a1
    kfree(p);
    80000aa2:	8a3a                	mv	s4,a4
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    80000aa4:	89be                	mv	s3,a5
    kfree(p);
    80000aa6:	01448533          	add	a0,s1,s4
    80000aaa:	f6dff0ef          	jal	80000a16 <kfree>
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    80000aae:	94ce                	add	s1,s1,s3
    80000ab0:	fe997be3          	bgeu	s2,s1,80000aa6 <freerange+0x2a>
    80000ab4:	6942                	ld	s2,16(sp)
    80000ab6:	69a2                	ld	s3,8(sp)
    80000ab8:	6a02                	ld	s4,0(sp)
}
    80000aba:	70a2                	ld	ra,40(sp)
    80000abc:	7402                	ld	s0,32(sp)
    80000abe:	64e2                	ld	s1,24(sp)
    80000ac0:	6145                	addi	sp,sp,48
    80000ac2:	8082                	ret

0000000080000ac4 <kinit>:
{
    80000ac4:	1141                	addi	sp,sp,-16
    80000ac6:	e406                	sd	ra,8(sp)
    80000ac8:	e022                	sd	s0,0(sp)
    80000aca:	0800                	addi	s0,sp,16
  initlock(&kmem.lock, "kmem");
    80000acc:	00006597          	auipc	a1,0x6
    80000ad0:	57458593          	addi	a1,a1,1396 # 80007040 <etext+0x40>
    80000ad4:	0000f517          	auipc	a0,0xf
    80000ad8:	ed450513          	addi	a0,a0,-300 # 8000f9a8 <kmem>
    80000adc:	06c000ef          	jal	80000b48 <initlock>
  freerange(end, (void*)PHYSTOP);
    80000ae0:	45c5                	li	a1,17
    80000ae2:	05ee                	slli	a1,a1,0x1b
    80000ae4:	00020517          	auipc	a0,0x20
    80000ae8:	0f450513          	addi	a0,a0,244 # 80020bd8 <end>
    80000aec:	f91ff0ef          	jal	80000a7c <freerange>
}
    80000af0:	60a2                	ld	ra,8(sp)
    80000af2:	6402                	ld	s0,0(sp)
    80000af4:	0141                	addi	sp,sp,16
    80000af6:	8082                	ret

0000000080000af8 <kalloc>:
// Allocate one 4096-byte page of physical memory.
// Returns a pointer that the kernel can use.
// Returns 0 if the memory cannot be allocated.
void *
kalloc(void)
{
    80000af8:	1101                	addi	sp,sp,-32
    80000afa:	ec06                	sd	ra,24(sp)
    80000afc:	e822                	sd	s0,16(sp)
    80000afe:	e426                	sd	s1,8(sp)
    80000b00:	1000                	addi	s0,sp,32
  struct run *r;

  acquire(&kmem.lock);
    80000b02:	0000f497          	auipc	s1,0xf
    80000b06:	ea648493          	addi	s1,s1,-346 # 8000f9a8 <kmem>
    80000b0a:	8526                	mv	a0,s1
    80000b0c:	0c0000ef          	jal	80000bcc <acquire>
  r = kmem.freelist;
    80000b10:	6c84                	ld	s1,24(s1)
  if(r)
    80000b12:	c485                	beqz	s1,80000b3a <kalloc+0x42>
    kmem.freelist = r->next;
    80000b14:	609c                	ld	a5,0(s1)
    80000b16:	0000f517          	auipc	a0,0xf
    80000b1a:	e9250513          	addi	a0,a0,-366 # 8000f9a8 <kmem>
    80000b1e:	ed1c                	sd	a5,24(a0)
  release(&kmem.lock);
    80000b20:	140000ef          	jal	80000c60 <release>

  if(r)
    memset((char*)r, 5, PGSIZE); // fill with junk
    80000b24:	6605                	lui	a2,0x1
    80000b26:	4595                	li	a1,5
    80000b28:	8526                	mv	a0,s1
    80000b2a:	172000ef          	jal	80000c9c <memset>
  return (void*)r;
}
    80000b2e:	8526                	mv	a0,s1
    80000b30:	60e2                	ld	ra,24(sp)
    80000b32:	6442                	ld	s0,16(sp)
    80000b34:	64a2                	ld	s1,8(sp)
    80000b36:	6105                	addi	sp,sp,32
    80000b38:	8082                	ret
  release(&kmem.lock);
    80000b3a:	0000f517          	auipc	a0,0xf
    80000b3e:	e6e50513          	addi	a0,a0,-402 # 8000f9a8 <kmem>
    80000b42:	11e000ef          	jal	80000c60 <release>
  if(r)
    80000b46:	b7e5                	j	80000b2e <kalloc+0x36>

0000000080000b48 <initlock>:
#include "proc.h"
#include "defs.h"

void
initlock(struct spinlock *lk, char *name)
{
    80000b48:	1141                	addi	sp,sp,-16
    80000b4a:	e406                	sd	ra,8(sp)
    80000b4c:	e022                	sd	s0,0(sp)
    80000b4e:	0800                	addi	s0,sp,16
  lk->name = name;
    80000b50:	e50c                	sd	a1,8(a0)
  lk->locked = 0;
    80000b52:	00052023          	sw	zero,0(a0)
  lk->cpu = 0;
    80000b56:	00053823          	sd	zero,16(a0)
}
    80000b5a:	60a2                	ld	ra,8(sp)
    80000b5c:	6402                	ld	s0,0(sp)
    80000b5e:	0141                	addi	sp,sp,16
    80000b60:	8082                	ret

0000000080000b62 <holding>:
// Interrupts must be off.
int
holding(struct spinlock *lk)
{
  int r;
  r = (lk->locked && lk->cpu == mycpu());
    80000b62:	411c                	lw	a5,0(a0)
    80000b64:	e399                	bnez	a5,80000b6a <holding+0x8>
    80000b66:	4501                	li	a0,0
  return r;
}
    80000b68:	8082                	ret
{
    80000b6a:	1101                	addi	sp,sp,-32
    80000b6c:	ec06                	sd	ra,24(sp)
    80000b6e:	e822                	sd	s0,16(sp)
    80000b70:	e426                	sd	s1,8(sp)
    80000b72:	1000                	addi	s0,sp,32
  r = (lk->locked && lk->cpu == mycpu());
    80000b74:	6904                	ld	s1,16(a0)
    80000b76:	529000ef          	jal	8000189e <mycpu>
    80000b7a:	40a48533          	sub	a0,s1,a0
    80000b7e:	00153513          	seqz	a0,a0
}
    80000b82:	60e2                	ld	ra,24(sp)
    80000b84:	6442                	ld	s0,16(sp)
    80000b86:	64a2                	ld	s1,8(sp)
    80000b88:	6105                	addi	sp,sp,32
    80000b8a:	8082                	ret

0000000080000b8c <push_off>:
// it takes two pop_off()s to undo two push_off()s.  Also, if interrupts
// are initially off, then push_off, pop_off leaves them off.

void
push_off(void)
{
    80000b8c:	1101                	addi	sp,sp,-32
    80000b8e:	ec06                	sd	ra,24(sp)
    80000b90:	e822                	sd	s0,16(sp)
    80000b92:	e426                	sd	s1,8(sp)
    80000b94:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000b96:	100024f3          	csrr	s1,sstatus
    80000b9a:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    80000b9e:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80000ba0:	10079073          	csrw	sstatus,a5

  // disable interrupts to prevent an involuntary context
  // switch while using mycpu().
  intr_off();

  if(mycpu()->noff == 0)
    80000ba4:	4fb000ef          	jal	8000189e <mycpu>
    80000ba8:	5d3c                	lw	a5,120(a0)
    80000baa:	cb99                	beqz	a5,80000bc0 <push_off+0x34>
    mycpu()->intena = old;
  mycpu()->noff += 1;
    80000bac:	4f3000ef          	jal	8000189e <mycpu>
    80000bb0:	5d3c                	lw	a5,120(a0)
    80000bb2:	2785                	addiw	a5,a5,1
    80000bb4:	dd3c                	sw	a5,120(a0)
}
    80000bb6:	60e2                	ld	ra,24(sp)
    80000bb8:	6442                	ld	s0,16(sp)
    80000bba:	64a2                	ld	s1,8(sp)
    80000bbc:	6105                	addi	sp,sp,32
    80000bbe:	8082                	ret
    mycpu()->intena = old;
    80000bc0:	4df000ef          	jal	8000189e <mycpu>
  return (x & SSTATUS_SIE) != 0;
    80000bc4:	8085                	srli	s1,s1,0x1
    80000bc6:	8885                	andi	s1,s1,1
    80000bc8:	dd64                	sw	s1,124(a0)
    80000bca:	b7cd                	j	80000bac <push_off+0x20>

0000000080000bcc <acquire>:
{
    80000bcc:	1101                	addi	sp,sp,-32
    80000bce:	ec06                	sd	ra,24(sp)
    80000bd0:	e822                	sd	s0,16(sp)
    80000bd2:	e426                	sd	s1,8(sp)
    80000bd4:	1000                	addi	s0,sp,32
    80000bd6:	84aa                	mv	s1,a0
  push_off(); // disable interrupts to avoid deadlock.
    80000bd8:	fb5ff0ef          	jal	80000b8c <push_off>
  if(holding(lk))
    80000bdc:	8526                	mv	a0,s1
    80000bde:	f85ff0ef          	jal	80000b62 <holding>
  while(__sync_lock_test_and_set(&lk->locked, 1) != 0)
    80000be2:	4705                	li	a4,1
  if(holding(lk))
    80000be4:	e105                	bnez	a0,80000c04 <acquire+0x38>
  while(__sync_lock_test_and_set(&lk->locked, 1) != 0)
    80000be6:	87ba                	mv	a5,a4
    80000be8:	0cf4a7af          	amoswap.w.aq	a5,a5,(s1)
    80000bec:	2781                	sext.w	a5,a5
    80000bee:	ffe5                	bnez	a5,80000be6 <acquire+0x1a>
  __sync_synchronize();
    80000bf0:	0330000f          	fence	rw,rw
  lk->cpu = mycpu();
    80000bf4:	4ab000ef          	jal	8000189e <mycpu>
    80000bf8:	e888                	sd	a0,16(s1)
}
    80000bfa:	60e2                	ld	ra,24(sp)
    80000bfc:	6442                	ld	s0,16(sp)
    80000bfe:	64a2                	ld	s1,8(sp)
    80000c00:	6105                	addi	sp,sp,32
    80000c02:	8082                	ret
    panic("acquire");
    80000c04:	00006517          	auipc	a0,0x6
    80000c08:	44450513          	addi	a0,a0,1092 # 80007048 <etext+0x48>
    80000c0c:	bd3ff0ef          	jal	800007de <panic>

0000000080000c10 <pop_off>:

void
pop_off(void)
{
    80000c10:	1141                	addi	sp,sp,-16
    80000c12:	e406                	sd	ra,8(sp)
    80000c14:	e022                	sd	s0,0(sp)
    80000c16:	0800                	addi	s0,sp,16
  struct cpu *c = mycpu();
    80000c18:	487000ef          	jal	8000189e <mycpu>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000c1c:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80000c20:	8b89                	andi	a5,a5,2
  if(intr_get())
    80000c22:	e39d                	bnez	a5,80000c48 <pop_off+0x38>
    panic("pop_off - interruptible");
  if(c->noff < 1)
    80000c24:	5d3c                	lw	a5,120(a0)
    80000c26:	02f05763          	blez	a5,80000c54 <pop_off+0x44>
    panic("pop_off");
  c->noff -= 1;
    80000c2a:	37fd                	addiw	a5,a5,-1
    80000c2c:	dd3c                	sw	a5,120(a0)
  if(c->noff == 0 && c->intena)
    80000c2e:	eb89                	bnez	a5,80000c40 <pop_off+0x30>
    80000c30:	5d7c                	lw	a5,124(a0)
    80000c32:	c799                	beqz	a5,80000c40 <pop_off+0x30>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000c34:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80000c38:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80000c3c:	10079073          	csrw	sstatus,a5
    intr_on();
}
    80000c40:	60a2                	ld	ra,8(sp)
    80000c42:	6402                	ld	s0,0(sp)
    80000c44:	0141                	addi	sp,sp,16
    80000c46:	8082                	ret
    panic("pop_off - interruptible");
    80000c48:	00006517          	auipc	a0,0x6
    80000c4c:	40850513          	addi	a0,a0,1032 # 80007050 <etext+0x50>
    80000c50:	b8fff0ef          	jal	800007de <panic>
    panic("pop_off");
    80000c54:	00006517          	auipc	a0,0x6
    80000c58:	41450513          	addi	a0,a0,1044 # 80007068 <etext+0x68>
    80000c5c:	b83ff0ef          	jal	800007de <panic>

0000000080000c60 <release>:
{
    80000c60:	1101                	addi	sp,sp,-32
    80000c62:	ec06                	sd	ra,24(sp)
    80000c64:	e822                	sd	s0,16(sp)
    80000c66:	e426                	sd	s1,8(sp)
    80000c68:	1000                	addi	s0,sp,32
    80000c6a:	84aa                	mv	s1,a0
  if(!holding(lk))
    80000c6c:	ef7ff0ef          	jal	80000b62 <holding>
    80000c70:	c105                	beqz	a0,80000c90 <release+0x30>
  lk->cpu = 0;
    80000c72:	0004b823          	sd	zero,16(s1)
  __sync_synchronize();
    80000c76:	0330000f          	fence	rw,rw
  __sync_lock_release(&lk->locked);
    80000c7a:	0310000f          	fence	rw,w
    80000c7e:	0004a023          	sw	zero,0(s1)
  pop_off();
    80000c82:	f8fff0ef          	jal	80000c10 <pop_off>
}
    80000c86:	60e2                	ld	ra,24(sp)
    80000c88:	6442                	ld	s0,16(sp)
    80000c8a:	64a2                	ld	s1,8(sp)
    80000c8c:	6105                	addi	sp,sp,32
    80000c8e:	8082                	ret
    panic("release");
    80000c90:	00006517          	auipc	a0,0x6
    80000c94:	3e050513          	addi	a0,a0,992 # 80007070 <etext+0x70>
    80000c98:	b47ff0ef          	jal	800007de <panic>

0000000080000c9c <memset>:
#include "types.h"

void*
memset(void *dst, int c, uint n)
{
    80000c9c:	1141                	addi	sp,sp,-16
    80000c9e:	e406                	sd	ra,8(sp)
    80000ca0:	e022                	sd	s0,0(sp)
    80000ca2:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
    80000ca4:	ca19                	beqz	a2,80000cba <memset+0x1e>
    80000ca6:	87aa                	mv	a5,a0
    80000ca8:	1602                	slli	a2,a2,0x20
    80000caa:	9201                	srli	a2,a2,0x20
    80000cac:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
    80000cb0:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
    80000cb4:	0785                	addi	a5,a5,1
    80000cb6:	fee79de3          	bne	a5,a4,80000cb0 <memset+0x14>
  }
  return dst;
}
    80000cba:	60a2                	ld	ra,8(sp)
    80000cbc:	6402                	ld	s0,0(sp)
    80000cbe:	0141                	addi	sp,sp,16
    80000cc0:	8082                	ret

0000000080000cc2 <memcmp>:

int
memcmp(const void *v1, const void *v2, uint n)
{
    80000cc2:	1141                	addi	sp,sp,-16
    80000cc4:	e406                	sd	ra,8(sp)
    80000cc6:	e022                	sd	s0,0(sp)
    80000cc8:	0800                	addi	s0,sp,16
  const uchar *s1, *s2;

  s1 = v1;
  s2 = v2;
  while(n-- > 0){
    80000cca:	ca0d                	beqz	a2,80000cfc <memcmp+0x3a>
    80000ccc:	fff6069b          	addiw	a3,a2,-1 # fff <_entry-0x7ffff001>
    80000cd0:	1682                	slli	a3,a3,0x20
    80000cd2:	9281                	srli	a3,a3,0x20
    80000cd4:	0685                	addi	a3,a3,1
    80000cd6:	96aa                	add	a3,a3,a0
    if(*s1 != *s2)
    80000cd8:	00054783          	lbu	a5,0(a0)
    80000cdc:	0005c703          	lbu	a4,0(a1)
    80000ce0:	00e79863          	bne	a5,a4,80000cf0 <memcmp+0x2e>
      return *s1 - *s2;
    s1++, s2++;
    80000ce4:	0505                	addi	a0,a0,1
    80000ce6:	0585                	addi	a1,a1,1
  while(n-- > 0){
    80000ce8:	fed518e3          	bne	a0,a3,80000cd8 <memcmp+0x16>
  }

  return 0;
    80000cec:	4501                	li	a0,0
    80000cee:	a019                	j	80000cf4 <memcmp+0x32>
      return *s1 - *s2;
    80000cf0:	40e7853b          	subw	a0,a5,a4
}
    80000cf4:	60a2                	ld	ra,8(sp)
    80000cf6:	6402                	ld	s0,0(sp)
    80000cf8:	0141                	addi	sp,sp,16
    80000cfa:	8082                	ret
  return 0;
    80000cfc:	4501                	li	a0,0
    80000cfe:	bfdd                	j	80000cf4 <memcmp+0x32>

0000000080000d00 <memmove>:

void*
memmove(void *dst, const void *src, uint n)
{
    80000d00:	1141                	addi	sp,sp,-16
    80000d02:	e406                	sd	ra,8(sp)
    80000d04:	e022                	sd	s0,0(sp)
    80000d06:	0800                	addi	s0,sp,16
  const char *s;
  char *d;

  if(n == 0)
    80000d08:	c205                	beqz	a2,80000d28 <memmove+0x28>
    return dst;
  
  s = src;
  d = dst;
  if(s < d && s + n > d){
    80000d0a:	02a5e363          	bltu	a1,a0,80000d30 <memmove+0x30>
    s += n;
    d += n;
    while(n-- > 0)
      *--d = *--s;
  } else
    while(n-- > 0)
    80000d0e:	1602                	slli	a2,a2,0x20
    80000d10:	9201                	srli	a2,a2,0x20
    80000d12:	00c587b3          	add	a5,a1,a2
{
    80000d16:	872a                	mv	a4,a0
      *d++ = *s++;
    80000d18:	0585                	addi	a1,a1,1
    80000d1a:	0705                	addi	a4,a4,1 # fffffffffffff001 <end+0xffffffff7ffde429>
    80000d1c:	fff5c683          	lbu	a3,-1(a1)
    80000d20:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
    80000d24:	feb79ae3          	bne	a5,a1,80000d18 <memmove+0x18>

  return dst;
}
    80000d28:	60a2                	ld	ra,8(sp)
    80000d2a:	6402                	ld	s0,0(sp)
    80000d2c:	0141                	addi	sp,sp,16
    80000d2e:	8082                	ret
  if(s < d && s + n > d){
    80000d30:	02061693          	slli	a3,a2,0x20
    80000d34:	9281                	srli	a3,a3,0x20
    80000d36:	00d58733          	add	a4,a1,a3
    80000d3a:	fce57ae3          	bgeu	a0,a4,80000d0e <memmove+0xe>
    d += n;
    80000d3e:	96aa                	add	a3,a3,a0
    while(n-- > 0)
    80000d40:	fff6079b          	addiw	a5,a2,-1
    80000d44:	1782                	slli	a5,a5,0x20
    80000d46:	9381                	srli	a5,a5,0x20
    80000d48:	fff7c793          	not	a5,a5
    80000d4c:	97ba                	add	a5,a5,a4
      *--d = *--s;
    80000d4e:	177d                	addi	a4,a4,-1
    80000d50:	16fd                	addi	a3,a3,-1
    80000d52:	00074603          	lbu	a2,0(a4)
    80000d56:	00c68023          	sb	a2,0(a3)
    while(n-- > 0)
    80000d5a:	fee79ae3          	bne	a5,a4,80000d4e <memmove+0x4e>
    80000d5e:	b7e9                	j	80000d28 <memmove+0x28>

0000000080000d60 <memcpy>:

// memcpy exists to placate GCC.  Use memmove.
void*
memcpy(void *dst, const void *src, uint n)
{
    80000d60:	1141                	addi	sp,sp,-16
    80000d62:	e406                	sd	ra,8(sp)
    80000d64:	e022                	sd	s0,0(sp)
    80000d66:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
    80000d68:	f99ff0ef          	jal	80000d00 <memmove>
}
    80000d6c:	60a2                	ld	ra,8(sp)
    80000d6e:	6402                	ld	s0,0(sp)
    80000d70:	0141                	addi	sp,sp,16
    80000d72:	8082                	ret

0000000080000d74 <strncmp>:

int
strncmp(const char *p, const char *q, uint n)
{
    80000d74:	1141                	addi	sp,sp,-16
    80000d76:	e406                	sd	ra,8(sp)
    80000d78:	e022                	sd	s0,0(sp)
    80000d7a:	0800                	addi	s0,sp,16
  while(n > 0 && *p && *p == *q)
    80000d7c:	ce11                	beqz	a2,80000d98 <strncmp+0x24>
    80000d7e:	00054783          	lbu	a5,0(a0)
    80000d82:	cf89                	beqz	a5,80000d9c <strncmp+0x28>
    80000d84:	0005c703          	lbu	a4,0(a1)
    80000d88:	00f71a63          	bne	a4,a5,80000d9c <strncmp+0x28>
    n--, p++, q++;
    80000d8c:	367d                	addiw	a2,a2,-1
    80000d8e:	0505                	addi	a0,a0,1
    80000d90:	0585                	addi	a1,a1,1
  while(n > 0 && *p && *p == *q)
    80000d92:	f675                	bnez	a2,80000d7e <strncmp+0xa>
  if(n == 0)
    return 0;
    80000d94:	4501                	li	a0,0
    80000d96:	a801                	j	80000da6 <strncmp+0x32>
    80000d98:	4501                	li	a0,0
    80000d9a:	a031                	j	80000da6 <strncmp+0x32>
  return (uchar)*p - (uchar)*q;
    80000d9c:	00054503          	lbu	a0,0(a0)
    80000da0:	0005c783          	lbu	a5,0(a1)
    80000da4:	9d1d                	subw	a0,a0,a5
}
    80000da6:	60a2                	ld	ra,8(sp)
    80000da8:	6402                	ld	s0,0(sp)
    80000daa:	0141                	addi	sp,sp,16
    80000dac:	8082                	ret

0000000080000dae <strncpy>:

char*
strncpy(char *s, const char *t, int n)
{
    80000dae:	1141                	addi	sp,sp,-16
    80000db0:	e406                	sd	ra,8(sp)
    80000db2:	e022                	sd	s0,0(sp)
    80000db4:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while(n-- > 0 && (*s++ = *t++) != 0)
    80000db6:	87aa                	mv	a5,a0
    80000db8:	86b2                	mv	a3,a2
    80000dba:	367d                	addiw	a2,a2,-1
    80000dbc:	02d05563          	blez	a3,80000de6 <strncpy+0x38>
    80000dc0:	0785                	addi	a5,a5,1
    80000dc2:	0005c703          	lbu	a4,0(a1)
    80000dc6:	fee78fa3          	sb	a4,-1(a5)
    80000dca:	0585                	addi	a1,a1,1
    80000dcc:	f775                	bnez	a4,80000db8 <strncpy+0xa>
    ;
  while(n-- > 0)
    80000dce:	873e                	mv	a4,a5
    80000dd0:	00c05b63          	blez	a2,80000de6 <strncpy+0x38>
    80000dd4:	9fb5                	addw	a5,a5,a3
    80000dd6:	37fd                	addiw	a5,a5,-1
    *s++ = 0;
    80000dd8:	0705                	addi	a4,a4,1
    80000dda:	fe070fa3          	sb	zero,-1(a4)
  while(n-- > 0)
    80000dde:	40e786bb          	subw	a3,a5,a4
    80000de2:	fed04be3          	bgtz	a3,80000dd8 <strncpy+0x2a>
  return os;
}
    80000de6:	60a2                	ld	ra,8(sp)
    80000de8:	6402                	ld	s0,0(sp)
    80000dea:	0141                	addi	sp,sp,16
    80000dec:	8082                	ret

0000000080000dee <safestrcpy>:

// Like strncpy but guaranteed to NUL-terminate.
char*
safestrcpy(char *s, const char *t, int n)
{
    80000dee:	1141                	addi	sp,sp,-16
    80000df0:	e406                	sd	ra,8(sp)
    80000df2:	e022                	sd	s0,0(sp)
    80000df4:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  if(n <= 0)
    80000df6:	02c05363          	blez	a2,80000e1c <safestrcpy+0x2e>
    80000dfa:	fff6069b          	addiw	a3,a2,-1
    80000dfe:	1682                	slli	a3,a3,0x20
    80000e00:	9281                	srli	a3,a3,0x20
    80000e02:	96ae                	add	a3,a3,a1
    80000e04:	87aa                	mv	a5,a0
    return os;
  while(--n > 0 && (*s++ = *t++) != 0)
    80000e06:	00d58963          	beq	a1,a3,80000e18 <safestrcpy+0x2a>
    80000e0a:	0585                	addi	a1,a1,1
    80000e0c:	0785                	addi	a5,a5,1
    80000e0e:	fff5c703          	lbu	a4,-1(a1)
    80000e12:	fee78fa3          	sb	a4,-1(a5)
    80000e16:	fb65                	bnez	a4,80000e06 <safestrcpy+0x18>
    ;
  *s = 0;
    80000e18:	00078023          	sb	zero,0(a5)
  return os;
}
    80000e1c:	60a2                	ld	ra,8(sp)
    80000e1e:	6402                	ld	s0,0(sp)
    80000e20:	0141                	addi	sp,sp,16
    80000e22:	8082                	ret

0000000080000e24 <strlen>:

int
strlen(const char *s)
{
    80000e24:	1141                	addi	sp,sp,-16
    80000e26:	e406                	sd	ra,8(sp)
    80000e28:	e022                	sd	s0,0(sp)
    80000e2a:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
    80000e2c:	00054783          	lbu	a5,0(a0)
    80000e30:	cf99                	beqz	a5,80000e4e <strlen+0x2a>
    80000e32:	0505                	addi	a0,a0,1
    80000e34:	87aa                	mv	a5,a0
    80000e36:	86be                	mv	a3,a5
    80000e38:	0785                	addi	a5,a5,1
    80000e3a:	fff7c703          	lbu	a4,-1(a5)
    80000e3e:	ff65                	bnez	a4,80000e36 <strlen+0x12>
    80000e40:	40a6853b          	subw	a0,a3,a0
    80000e44:	2505                	addiw	a0,a0,1
    ;
  return n;
}
    80000e46:	60a2                	ld	ra,8(sp)
    80000e48:	6402                	ld	s0,0(sp)
    80000e4a:	0141                	addi	sp,sp,16
    80000e4c:	8082                	ret
  for(n = 0; s[n]; n++)
    80000e4e:	4501                	li	a0,0
    80000e50:	bfdd                	j	80000e46 <strlen+0x22>

0000000080000e52 <main>:
volatile static int started = 0;

// start() jumps here in supervisor mode on all CPUs.
void
main()
{
    80000e52:	1141                	addi	sp,sp,-16
    80000e54:	e406                	sd	ra,8(sp)
    80000e56:	e022                	sd	s0,0(sp)
    80000e58:	0800                	addi	s0,sp,16
  if(cpuid() == 0){
    80000e5a:	231000ef          	jal	8000188a <cpuid>
    virtio_disk_init(); // emulated hard disk
    userinit();      // first user process
    __sync_synchronize();
    started = 1;
  } else {
    while(started == 0)
    80000e5e:	00007717          	auipc	a4,0x7
    80000e62:	a5270713          	addi	a4,a4,-1454 # 800078b0 <started>
  if(cpuid() == 0){
    80000e66:	c51d                	beqz	a0,80000e94 <main+0x42>
    while(started == 0)
    80000e68:	431c                	lw	a5,0(a4)
    80000e6a:	2781                	sext.w	a5,a5
    80000e6c:	dff5                	beqz	a5,80000e68 <main+0x16>
      ;
    __sync_synchronize();
    80000e6e:	0330000f          	fence	rw,rw
    printf("hart %d starting\n", cpuid());
    80000e72:	219000ef          	jal	8000188a <cpuid>
    80000e76:	85aa                	mv	a1,a0
    80000e78:	00006517          	auipc	a0,0x6
    80000e7c:	22050513          	addi	a0,a0,544 # 80007098 <etext+0x98>
    80000e80:	e7aff0ef          	jal	800004fa <printf>
    kvminithart();    // turn on paging
    80000e84:	080000ef          	jal	80000f04 <kvminithart>
    trapinithart();   // install kernel trap vector
    80000e88:	628010ef          	jal	800024b0 <trapinithart>
    plicinithart();   // ask PLIC for device interrupts
    80000e8c:	65c040ef          	jal	800054e8 <plicinithart>
  }

  scheduler();        
    80000e90:	68f000ef          	jal	80001d1e <scheduler>
    consoleinit();
    80000e94:	d98ff0ef          	jal	8000042c <consoleinit>
    printfinit();
    80000e98:	983ff0ef          	jal	8000081a <printfinit>
    printf("\n");
    80000e9c:	00006517          	auipc	a0,0x6
    80000ea0:	1dc50513          	addi	a0,a0,476 # 80007078 <etext+0x78>
    80000ea4:	e56ff0ef          	jal	800004fa <printf>
    printf("xv6 kernel is booting\n");
    80000ea8:	00006517          	auipc	a0,0x6
    80000eac:	1d850513          	addi	a0,a0,472 # 80007080 <etext+0x80>
    80000eb0:	e4aff0ef          	jal	800004fa <printf>
    printf("\n");
    80000eb4:	00006517          	auipc	a0,0x6
    80000eb8:	1c450513          	addi	a0,a0,452 # 80007078 <etext+0x78>
    80000ebc:	e3eff0ef          	jal	800004fa <printf>
    kinit();         // physical page allocator
    80000ec0:	c05ff0ef          	jal	80000ac4 <kinit>
    kvminit();       // create kernel page table
    80000ec4:	2ce000ef          	jal	80001192 <kvminit>
    kvminithart();   // turn on paging
    80000ec8:	03c000ef          	jal	80000f04 <kvminithart>
    procinit();      // process table
    80000ecc:	10f000ef          	jal	800017da <procinit>
    trapinit();      // trap vectors
    80000ed0:	5bc010ef          	jal	8000248c <trapinit>
    trapinithart();  // install kernel trap vector
    80000ed4:	5dc010ef          	jal	800024b0 <trapinithart>
    plicinit();      // set up interrupt controller
    80000ed8:	5f6040ef          	jal	800054ce <plicinit>
    plicinithart();  // ask PLIC for device interrupts
    80000edc:	60c040ef          	jal	800054e8 <plicinithart>
    binit();         // buffer cache
    80000ee0:	4a3010ef          	jal	80002b82 <binit>
    iinit();         // inode table
    80000ee4:	202020ef          	jal	800030e6 <iinit>
    fileinit();      // file table
    80000ee8:	114030ef          	jal	80003ffc <fileinit>
    virtio_disk_init(); // emulated hard disk
    80000eec:	6ec040ef          	jal	800055d8 <virtio_disk_init>
    userinit();      // first user process
    80000ef0:	495000ef          	jal	80001b84 <userinit>
    __sync_synchronize();
    80000ef4:	0330000f          	fence	rw,rw
    started = 1;
    80000ef8:	4785                	li	a5,1
    80000efa:	00007717          	auipc	a4,0x7
    80000efe:	9af72b23          	sw	a5,-1610(a4) # 800078b0 <started>
    80000f02:	b779                	j	80000e90 <main+0x3e>

0000000080000f04 <kvminithart>:

// Switch the current CPU's h/w page table register to
// the kernel's page table, and enable paging.
void
kvminithart()
{
    80000f04:	1141                	addi	sp,sp,-16
    80000f06:	e406                	sd	ra,8(sp)
    80000f08:	e022                	sd	s0,0(sp)
    80000f0a:	0800                	addi	s0,sp,16
// flush the TLB.
static inline void
sfence_vma()
{
  // the zero, zero means flush all TLB entries.
  asm volatile("sfence.vma zero, zero");
    80000f0c:	12000073          	sfence.vma
  // wait for any previous writes to the page table memory to finish.
  sfence_vma();

  w_satp(MAKE_SATP(kernel_pagetable));
    80000f10:	00007797          	auipc	a5,0x7
    80000f14:	9a87b783          	ld	a5,-1624(a5) # 800078b8 <kernel_pagetable>
    80000f18:	83b1                	srli	a5,a5,0xc
    80000f1a:	577d                	li	a4,-1
    80000f1c:	177e                	slli	a4,a4,0x3f
    80000f1e:	8fd9                	or	a5,a5,a4
  asm volatile("csrw satp, %0" : : "r" (x));
    80000f20:	18079073          	csrw	satp,a5
  asm volatile("sfence.vma zero, zero");
    80000f24:	12000073          	sfence.vma

  // flush stale entries from the TLB.
  sfence_vma();
}
    80000f28:	60a2                	ld	ra,8(sp)
    80000f2a:	6402                	ld	s0,0(sp)
    80000f2c:	0141                	addi	sp,sp,16
    80000f2e:	8082                	ret

0000000080000f30 <walk>:
//   21..29 -- 9 bits of level-1 index.
//   12..20 -- 9 bits of level-0 index.
//    0..11 -- 12 bits of byte offset within the page.
pte_t *
walk(pagetable_t pagetable, uint64 va, int alloc)
{
    80000f30:	7139                	addi	sp,sp,-64
    80000f32:	fc06                	sd	ra,56(sp)
    80000f34:	f822                	sd	s0,48(sp)
    80000f36:	f426                	sd	s1,40(sp)
    80000f38:	f04a                	sd	s2,32(sp)
    80000f3a:	ec4e                	sd	s3,24(sp)
    80000f3c:	e852                	sd	s4,16(sp)
    80000f3e:	e456                	sd	s5,8(sp)
    80000f40:	e05a                	sd	s6,0(sp)
    80000f42:	0080                	addi	s0,sp,64
    80000f44:	84aa                	mv	s1,a0
    80000f46:	89ae                	mv	s3,a1
    80000f48:	8ab2                	mv	s5,a2
  if(va >= MAXVA)
    80000f4a:	57fd                	li	a5,-1
    80000f4c:	83e9                	srli	a5,a5,0x1a
    80000f4e:	4a79                	li	s4,30
    panic("walk");

  for(int level = 2; level > 0; level--) {
    80000f50:	4b31                	li	s6,12
  if(va >= MAXVA)
    80000f52:	04b7e263          	bltu	a5,a1,80000f96 <walk+0x66>
    pte_t *pte = &pagetable[PX(level, va)];
    80000f56:	0149d933          	srl	s2,s3,s4
    80000f5a:	1ff97913          	andi	s2,s2,511
    80000f5e:	090e                	slli	s2,s2,0x3
    80000f60:	9926                	add	s2,s2,s1
    if(*pte & PTE_V) {
    80000f62:	00093483          	ld	s1,0(s2)
    80000f66:	0014f793          	andi	a5,s1,1
    80000f6a:	cf85                	beqz	a5,80000fa2 <walk+0x72>
      pagetable = (pagetable_t)PTE2PA(*pte);
    80000f6c:	80a9                	srli	s1,s1,0xa
    80000f6e:	04b2                	slli	s1,s1,0xc
  for(int level = 2; level > 0; level--) {
    80000f70:	3a5d                	addiw	s4,s4,-9
    80000f72:	ff6a12e3          	bne	s4,s6,80000f56 <walk+0x26>
        return 0;
      memset(pagetable, 0, PGSIZE);
      *pte = PA2PTE(pagetable) | PTE_V;
    }
  }
  return &pagetable[PX(0, va)];
    80000f76:	00c9d513          	srli	a0,s3,0xc
    80000f7a:	1ff57513          	andi	a0,a0,511
    80000f7e:	050e                	slli	a0,a0,0x3
    80000f80:	9526                	add	a0,a0,s1
}
    80000f82:	70e2                	ld	ra,56(sp)
    80000f84:	7442                	ld	s0,48(sp)
    80000f86:	74a2                	ld	s1,40(sp)
    80000f88:	7902                	ld	s2,32(sp)
    80000f8a:	69e2                	ld	s3,24(sp)
    80000f8c:	6a42                	ld	s4,16(sp)
    80000f8e:	6aa2                	ld	s5,8(sp)
    80000f90:	6b02                	ld	s6,0(sp)
    80000f92:	6121                	addi	sp,sp,64
    80000f94:	8082                	ret
    panic("walk");
    80000f96:	00006517          	auipc	a0,0x6
    80000f9a:	11a50513          	addi	a0,a0,282 # 800070b0 <etext+0xb0>
    80000f9e:	841ff0ef          	jal	800007de <panic>
      if(!alloc || (pagetable = (pde_t*)kalloc()) == 0)
    80000fa2:	020a8263          	beqz	s5,80000fc6 <walk+0x96>
    80000fa6:	b53ff0ef          	jal	80000af8 <kalloc>
    80000faa:	84aa                	mv	s1,a0
    80000fac:	d979                	beqz	a0,80000f82 <walk+0x52>
      memset(pagetable, 0, PGSIZE);
    80000fae:	6605                	lui	a2,0x1
    80000fb0:	4581                	li	a1,0
    80000fb2:	cebff0ef          	jal	80000c9c <memset>
      *pte = PA2PTE(pagetable) | PTE_V;
    80000fb6:	00c4d793          	srli	a5,s1,0xc
    80000fba:	07aa                	slli	a5,a5,0xa
    80000fbc:	0017e793          	ori	a5,a5,1
    80000fc0:	00f93023          	sd	a5,0(s2)
    80000fc4:	b775                	j	80000f70 <walk+0x40>
        return 0;
    80000fc6:	4501                	li	a0,0
    80000fc8:	bf6d                	j	80000f82 <walk+0x52>

0000000080000fca <walkaddr>:
walkaddr(pagetable_t pagetable, uint64 va)
{
  pte_t *pte;
  uint64 pa;

  if(va >= MAXVA)
    80000fca:	57fd                	li	a5,-1
    80000fcc:	83e9                	srli	a5,a5,0x1a
    80000fce:	00b7f463          	bgeu	a5,a1,80000fd6 <walkaddr+0xc>
    return 0;
    80000fd2:	4501                	li	a0,0
    return 0;
  if((*pte & PTE_U) == 0)
    return 0;
  pa = PTE2PA(*pte);
  return pa;
}
    80000fd4:	8082                	ret
{
    80000fd6:	1141                	addi	sp,sp,-16
    80000fd8:	e406                	sd	ra,8(sp)
    80000fda:	e022                	sd	s0,0(sp)
    80000fdc:	0800                	addi	s0,sp,16
  pte = walk(pagetable, va, 0);
    80000fde:	4601                	li	a2,0
    80000fe0:	f51ff0ef          	jal	80000f30 <walk>
  if(pte == 0)
    80000fe4:	c105                	beqz	a0,80001004 <walkaddr+0x3a>
  if((*pte & PTE_V) == 0)
    80000fe6:	611c                	ld	a5,0(a0)
  if((*pte & PTE_U) == 0)
    80000fe8:	0117f693          	andi	a3,a5,17
    80000fec:	4745                	li	a4,17
    return 0;
    80000fee:	4501                	li	a0,0
  if((*pte & PTE_U) == 0)
    80000ff0:	00e68663          	beq	a3,a4,80000ffc <walkaddr+0x32>
}
    80000ff4:	60a2                	ld	ra,8(sp)
    80000ff6:	6402                	ld	s0,0(sp)
    80000ff8:	0141                	addi	sp,sp,16
    80000ffa:	8082                	ret
  pa = PTE2PA(*pte);
    80000ffc:	83a9                	srli	a5,a5,0xa
    80000ffe:	00c79513          	slli	a0,a5,0xc
  return pa;
    80001002:	bfcd                	j	80000ff4 <walkaddr+0x2a>
    return 0;
    80001004:	4501                	li	a0,0
    80001006:	b7fd                	j	80000ff4 <walkaddr+0x2a>

0000000080001008 <mappages>:
// va and size MUST be page-aligned.
// Returns 0 on success, -1 if walk() couldn't
// allocate a needed page-table page.
int
mappages(pagetable_t pagetable, uint64 va, uint64 size, uint64 pa, int perm)
{
    80001008:	715d                	addi	sp,sp,-80
    8000100a:	e486                	sd	ra,72(sp)
    8000100c:	e0a2                	sd	s0,64(sp)
    8000100e:	fc26                	sd	s1,56(sp)
    80001010:	f84a                	sd	s2,48(sp)
    80001012:	f44e                	sd	s3,40(sp)
    80001014:	f052                	sd	s4,32(sp)
    80001016:	ec56                	sd	s5,24(sp)
    80001018:	e85a                	sd	s6,16(sp)
    8000101a:	e45e                	sd	s7,8(sp)
    8000101c:	e062                	sd	s8,0(sp)
    8000101e:	0880                	addi	s0,sp,80
  uint64 a, last;
  pte_t *pte;

  if((va % PGSIZE) != 0)
    80001020:	03459793          	slli	a5,a1,0x34
    80001024:	e7b1                	bnez	a5,80001070 <mappages+0x68>
    80001026:	8aaa                	mv	s5,a0
    80001028:	8b3a                	mv	s6,a4
    panic("mappages: va not aligned");

  if((size % PGSIZE) != 0)
    8000102a:	03461793          	slli	a5,a2,0x34
    8000102e:	e7b9                	bnez	a5,8000107c <mappages+0x74>
    panic("mappages: size not aligned");

  if(size == 0)
    80001030:	ce21                	beqz	a2,80001088 <mappages+0x80>
    panic("mappages: size");
  
  a = va;
  last = va + size - PGSIZE;
    80001032:	77fd                	lui	a5,0xfffff
    80001034:	963e                	add	a2,a2,a5
    80001036:	00b609b3          	add	s3,a2,a1
  a = va;
    8000103a:	892e                	mv	s2,a1
    8000103c:	40b68a33          	sub	s4,a3,a1
  for(;;){
    if((pte = walk(pagetable, a, 1)) == 0)
    80001040:	4b85                	li	s7,1
    if(*pte & PTE_V)
      panic("mappages: remap");
    *pte = PA2PTE(pa) | perm | PTE_V;
    if(a == last)
      break;
    a += PGSIZE;
    80001042:	6c05                	lui	s8,0x1
    80001044:	014904b3          	add	s1,s2,s4
    if((pte = walk(pagetable, a, 1)) == 0)
    80001048:	865e                	mv	a2,s7
    8000104a:	85ca                	mv	a1,s2
    8000104c:	8556                	mv	a0,s5
    8000104e:	ee3ff0ef          	jal	80000f30 <walk>
    80001052:	c539                	beqz	a0,800010a0 <mappages+0x98>
    if(*pte & PTE_V)
    80001054:	611c                	ld	a5,0(a0)
    80001056:	8b85                	andi	a5,a5,1
    80001058:	ef95                	bnez	a5,80001094 <mappages+0x8c>
    *pte = PA2PTE(pa) | perm | PTE_V;
    8000105a:	80b1                	srli	s1,s1,0xc
    8000105c:	04aa                	slli	s1,s1,0xa
    8000105e:	0164e4b3          	or	s1,s1,s6
    80001062:	0014e493          	ori	s1,s1,1
    80001066:	e104                	sd	s1,0(a0)
    if(a == last)
    80001068:	05390963          	beq	s2,s3,800010ba <mappages+0xb2>
    a += PGSIZE;
    8000106c:	9962                	add	s2,s2,s8
    if((pte = walk(pagetable, a, 1)) == 0)
    8000106e:	bfd9                	j	80001044 <mappages+0x3c>
    panic("mappages: va not aligned");
    80001070:	00006517          	auipc	a0,0x6
    80001074:	04850513          	addi	a0,a0,72 # 800070b8 <etext+0xb8>
    80001078:	f66ff0ef          	jal	800007de <panic>
    panic("mappages: size not aligned");
    8000107c:	00006517          	auipc	a0,0x6
    80001080:	05c50513          	addi	a0,a0,92 # 800070d8 <etext+0xd8>
    80001084:	f5aff0ef          	jal	800007de <panic>
    panic("mappages: size");
    80001088:	00006517          	auipc	a0,0x6
    8000108c:	07050513          	addi	a0,a0,112 # 800070f8 <etext+0xf8>
    80001090:	f4eff0ef          	jal	800007de <panic>
      panic("mappages: remap");
    80001094:	00006517          	auipc	a0,0x6
    80001098:	07450513          	addi	a0,a0,116 # 80007108 <etext+0x108>
    8000109c:	f42ff0ef          	jal	800007de <panic>
      return -1;
    800010a0:	557d                	li	a0,-1
    pa += PGSIZE;
  }
  return 0;
}
    800010a2:	60a6                	ld	ra,72(sp)
    800010a4:	6406                	ld	s0,64(sp)
    800010a6:	74e2                	ld	s1,56(sp)
    800010a8:	7942                	ld	s2,48(sp)
    800010aa:	79a2                	ld	s3,40(sp)
    800010ac:	7a02                	ld	s4,32(sp)
    800010ae:	6ae2                	ld	s5,24(sp)
    800010b0:	6b42                	ld	s6,16(sp)
    800010b2:	6ba2                	ld	s7,8(sp)
    800010b4:	6c02                	ld	s8,0(sp)
    800010b6:	6161                	addi	sp,sp,80
    800010b8:	8082                	ret
  return 0;
    800010ba:	4501                	li	a0,0
    800010bc:	b7dd                	j	800010a2 <mappages+0x9a>

00000000800010be <kvmmap>:
{
    800010be:	1141                	addi	sp,sp,-16
    800010c0:	e406                	sd	ra,8(sp)
    800010c2:	e022                	sd	s0,0(sp)
    800010c4:	0800                	addi	s0,sp,16
    800010c6:	87b6                	mv	a5,a3
  if(mappages(kpgtbl, va, sz, pa, perm) != 0)
    800010c8:	86b2                	mv	a3,a2
    800010ca:	863e                	mv	a2,a5
    800010cc:	f3dff0ef          	jal	80001008 <mappages>
    800010d0:	e509                	bnez	a0,800010da <kvmmap+0x1c>
}
    800010d2:	60a2                	ld	ra,8(sp)
    800010d4:	6402                	ld	s0,0(sp)
    800010d6:	0141                	addi	sp,sp,16
    800010d8:	8082                	ret
    panic("kvmmap");
    800010da:	00006517          	auipc	a0,0x6
    800010de:	03e50513          	addi	a0,a0,62 # 80007118 <etext+0x118>
    800010e2:	efcff0ef          	jal	800007de <panic>

00000000800010e6 <kvmmake>:
{
    800010e6:	1101                	addi	sp,sp,-32
    800010e8:	ec06                	sd	ra,24(sp)
    800010ea:	e822                	sd	s0,16(sp)
    800010ec:	e426                	sd	s1,8(sp)
    800010ee:	e04a                	sd	s2,0(sp)
    800010f0:	1000                	addi	s0,sp,32
  kpgtbl = (pagetable_t) kalloc();
    800010f2:	a07ff0ef          	jal	80000af8 <kalloc>
    800010f6:	84aa                	mv	s1,a0
  memset(kpgtbl, 0, PGSIZE);
    800010f8:	6605                	lui	a2,0x1
    800010fa:	4581                	li	a1,0
    800010fc:	ba1ff0ef          	jal	80000c9c <memset>
  kvmmap(kpgtbl, UART0, UART0, PGSIZE, PTE_R | PTE_W);
    80001100:	4719                	li	a4,6
    80001102:	6685                	lui	a3,0x1
    80001104:	10000637          	lui	a2,0x10000
    80001108:	85b2                	mv	a1,a2
    8000110a:	8526                	mv	a0,s1
    8000110c:	fb3ff0ef          	jal	800010be <kvmmap>
  kvmmap(kpgtbl, VIRTIO0, VIRTIO0, PGSIZE, PTE_R | PTE_W);
    80001110:	4719                	li	a4,6
    80001112:	6685                	lui	a3,0x1
    80001114:	10001637          	lui	a2,0x10001
    80001118:	85b2                	mv	a1,a2
    8000111a:	8526                	mv	a0,s1
    8000111c:	fa3ff0ef          	jal	800010be <kvmmap>
  kvmmap(kpgtbl, PLIC, PLIC, 0x4000000, PTE_R | PTE_W);
    80001120:	4719                	li	a4,6
    80001122:	040006b7          	lui	a3,0x4000
    80001126:	0c000637          	lui	a2,0xc000
    8000112a:	85b2                	mv	a1,a2
    8000112c:	8526                	mv	a0,s1
    8000112e:	f91ff0ef          	jal	800010be <kvmmap>
  kvmmap(kpgtbl, KERNBASE, KERNBASE, (uint64)etext-KERNBASE, PTE_R | PTE_X);
    80001132:	00006917          	auipc	s2,0x6
    80001136:	ece90913          	addi	s2,s2,-306 # 80007000 <etext>
    8000113a:	4729                	li	a4,10
    8000113c:	80006697          	auipc	a3,0x80006
    80001140:	ec468693          	addi	a3,a3,-316 # 7000 <_entry-0x7fff9000>
    80001144:	4605                	li	a2,1
    80001146:	067e                	slli	a2,a2,0x1f
    80001148:	85b2                	mv	a1,a2
    8000114a:	8526                	mv	a0,s1
    8000114c:	f73ff0ef          	jal	800010be <kvmmap>
  kvmmap(kpgtbl, (uint64)etext, (uint64)etext, PHYSTOP-(uint64)etext, PTE_R | PTE_W);
    80001150:	4719                	li	a4,6
    80001152:	46c5                	li	a3,17
    80001154:	06ee                	slli	a3,a3,0x1b
    80001156:	412686b3          	sub	a3,a3,s2
    8000115a:	864a                	mv	a2,s2
    8000115c:	85ca                	mv	a1,s2
    8000115e:	8526                	mv	a0,s1
    80001160:	f5fff0ef          	jal	800010be <kvmmap>
  kvmmap(kpgtbl, TRAMPOLINE, (uint64)trampoline, PGSIZE, PTE_R | PTE_X);
    80001164:	4729                	li	a4,10
    80001166:	6685                	lui	a3,0x1
    80001168:	00005617          	auipc	a2,0x5
    8000116c:	e9860613          	addi	a2,a2,-360 # 80006000 <_trampoline>
    80001170:	040005b7          	lui	a1,0x4000
    80001174:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80001176:	05b2                	slli	a1,a1,0xc
    80001178:	8526                	mv	a0,s1
    8000117a:	f45ff0ef          	jal	800010be <kvmmap>
  proc_mapstacks(kpgtbl);
    8000117e:	8526                	mv	a0,s1
    80001180:	5bc000ef          	jal	8000173c <proc_mapstacks>
}
    80001184:	8526                	mv	a0,s1
    80001186:	60e2                	ld	ra,24(sp)
    80001188:	6442                	ld	s0,16(sp)
    8000118a:	64a2                	ld	s1,8(sp)
    8000118c:	6902                	ld	s2,0(sp)
    8000118e:	6105                	addi	sp,sp,32
    80001190:	8082                	ret

0000000080001192 <kvminit>:
{
    80001192:	1141                	addi	sp,sp,-16
    80001194:	e406                	sd	ra,8(sp)
    80001196:	e022                	sd	s0,0(sp)
    80001198:	0800                	addi	s0,sp,16
  kernel_pagetable = kvmmake();
    8000119a:	f4dff0ef          	jal	800010e6 <kvmmake>
    8000119e:	00006797          	auipc	a5,0x6
    800011a2:	70a7bd23          	sd	a0,1818(a5) # 800078b8 <kernel_pagetable>
}
    800011a6:	60a2                	ld	ra,8(sp)
    800011a8:	6402                	ld	s0,0(sp)
    800011aa:	0141                	addi	sp,sp,16
    800011ac:	8082                	ret

00000000800011ae <uvmcreate>:

// create an empty user page table.
// returns 0 if out of memory.
pagetable_t
uvmcreate()
{
    800011ae:	1101                	addi	sp,sp,-32
    800011b0:	ec06                	sd	ra,24(sp)
    800011b2:	e822                	sd	s0,16(sp)
    800011b4:	e426                	sd	s1,8(sp)
    800011b6:	1000                	addi	s0,sp,32
  pagetable_t pagetable;
  pagetable = (pagetable_t) kalloc();
    800011b8:	941ff0ef          	jal	80000af8 <kalloc>
    800011bc:	84aa                	mv	s1,a0
  if(pagetable == 0)
    800011be:	c509                	beqz	a0,800011c8 <uvmcreate+0x1a>
    return 0;
  memset(pagetable, 0, PGSIZE);
    800011c0:	6605                	lui	a2,0x1
    800011c2:	4581                	li	a1,0
    800011c4:	ad9ff0ef          	jal	80000c9c <memset>
  return pagetable;
}
    800011c8:	8526                	mv	a0,s1
    800011ca:	60e2                	ld	ra,24(sp)
    800011cc:	6442                	ld	s0,16(sp)
    800011ce:	64a2                	ld	s1,8(sp)
    800011d0:	6105                	addi	sp,sp,32
    800011d2:	8082                	ret

00000000800011d4 <uvmunmap>:
// Remove npages of mappings starting from va. va must be
// page-aligned. It's OK if the mappings don't exist.
// Optionally free the physical memory.
void
uvmunmap(pagetable_t pagetable, uint64 va, uint64 npages, int do_free)
{
    800011d4:	7139                	addi	sp,sp,-64
    800011d6:	fc06                	sd	ra,56(sp)
    800011d8:	f822                	sd	s0,48(sp)
    800011da:	0080                	addi	s0,sp,64
  uint64 a;
  pte_t *pte;

  if((va % PGSIZE) != 0)
    800011dc:	03459793          	slli	a5,a1,0x34
    800011e0:	e38d                	bnez	a5,80001202 <uvmunmap+0x2e>
    800011e2:	f04a                	sd	s2,32(sp)
    800011e4:	ec4e                	sd	s3,24(sp)
    800011e6:	e852                	sd	s4,16(sp)
    800011e8:	e456                	sd	s5,8(sp)
    800011ea:	e05a                	sd	s6,0(sp)
    800011ec:	8a2a                	mv	s4,a0
    800011ee:	892e                	mv	s2,a1
    800011f0:	8ab6                	mv	s5,a3
    panic("uvmunmap: not aligned");

  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    800011f2:	0632                	slli	a2,a2,0xc
    800011f4:	00b609b3          	add	s3,a2,a1
    800011f8:	6b05                	lui	s6,0x1
    800011fa:	0535f963          	bgeu	a1,s3,8000124c <uvmunmap+0x78>
    800011fe:	f426                	sd	s1,40(sp)
    80001200:	a015                	j	80001224 <uvmunmap+0x50>
    80001202:	f426                	sd	s1,40(sp)
    80001204:	f04a                	sd	s2,32(sp)
    80001206:	ec4e                	sd	s3,24(sp)
    80001208:	e852                	sd	s4,16(sp)
    8000120a:	e456                	sd	s5,8(sp)
    8000120c:	e05a                	sd	s6,0(sp)
    panic("uvmunmap: not aligned");
    8000120e:	00006517          	auipc	a0,0x6
    80001212:	f1250513          	addi	a0,a0,-238 # 80007120 <etext+0x120>
    80001216:	dc8ff0ef          	jal	800007de <panic>
      continue;
    if(do_free){
      uint64 pa = PTE2PA(*pte);
      kfree((void*)pa);
    }
    *pte = 0;
    8000121a:	0004b023          	sd	zero,0(s1)
  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    8000121e:	995a                	add	s2,s2,s6
    80001220:	03397563          	bgeu	s2,s3,8000124a <uvmunmap+0x76>
    if((pte = walk(pagetable, a, 0)) == 0) // leaf page table entry allocated?
    80001224:	4601                	li	a2,0
    80001226:	85ca                	mv	a1,s2
    80001228:	8552                	mv	a0,s4
    8000122a:	d07ff0ef          	jal	80000f30 <walk>
    8000122e:	84aa                	mv	s1,a0
    80001230:	d57d                	beqz	a0,8000121e <uvmunmap+0x4a>
    if((*pte & PTE_V) == 0)  // has physical page been allocated?
    80001232:	611c                	ld	a5,0(a0)
    80001234:	0017f713          	andi	a4,a5,1
    80001238:	d37d                	beqz	a4,8000121e <uvmunmap+0x4a>
    if(do_free){
    8000123a:	fe0a80e3          	beqz	s5,8000121a <uvmunmap+0x46>
      uint64 pa = PTE2PA(*pte);
    8000123e:	83a9                	srli	a5,a5,0xa
      kfree((void*)pa);
    80001240:	00c79513          	slli	a0,a5,0xc
    80001244:	fd2ff0ef          	jal	80000a16 <kfree>
    80001248:	bfc9                	j	8000121a <uvmunmap+0x46>
    8000124a:	74a2                	ld	s1,40(sp)
    8000124c:	7902                	ld	s2,32(sp)
    8000124e:	69e2                	ld	s3,24(sp)
    80001250:	6a42                	ld	s4,16(sp)
    80001252:	6aa2                	ld	s5,8(sp)
    80001254:	6b02                	ld	s6,0(sp)
  }
}
    80001256:	70e2                	ld	ra,56(sp)
    80001258:	7442                	ld	s0,48(sp)
    8000125a:	6121                	addi	sp,sp,64
    8000125c:	8082                	ret

000000008000125e <uvmdealloc>:
// newsz.  oldsz and newsz need not be page-aligned, nor does newsz
// need to be less than oldsz.  oldsz can be larger than the actual
// process size.  Returns the new process size.
uint64
uvmdealloc(pagetable_t pagetable, uint64 oldsz, uint64 newsz)
{
    8000125e:	1101                	addi	sp,sp,-32
    80001260:	ec06                	sd	ra,24(sp)
    80001262:	e822                	sd	s0,16(sp)
    80001264:	e426                	sd	s1,8(sp)
    80001266:	1000                	addi	s0,sp,32
  if(newsz >= oldsz)
    return oldsz;
    80001268:	84ae                	mv	s1,a1
  if(newsz >= oldsz)
    8000126a:	00b67d63          	bgeu	a2,a1,80001284 <uvmdealloc+0x26>
    8000126e:	84b2                	mv	s1,a2

  if(PGROUNDUP(newsz) < PGROUNDUP(oldsz)){
    80001270:	6785                	lui	a5,0x1
    80001272:	17fd                	addi	a5,a5,-1 # fff <_entry-0x7ffff001>
    80001274:	00f60733          	add	a4,a2,a5
    80001278:	76fd                	lui	a3,0xfffff
    8000127a:	8f75                	and	a4,a4,a3
    8000127c:	97ae                	add	a5,a5,a1
    8000127e:	8ff5                	and	a5,a5,a3
    80001280:	00f76863          	bltu	a4,a5,80001290 <uvmdealloc+0x32>
    int npages = (PGROUNDUP(oldsz) - PGROUNDUP(newsz)) / PGSIZE;
    uvmunmap(pagetable, PGROUNDUP(newsz), npages, 1);
  }

  return newsz;
}
    80001284:	8526                	mv	a0,s1
    80001286:	60e2                	ld	ra,24(sp)
    80001288:	6442                	ld	s0,16(sp)
    8000128a:	64a2                	ld	s1,8(sp)
    8000128c:	6105                	addi	sp,sp,32
    8000128e:	8082                	ret
    int npages = (PGROUNDUP(oldsz) - PGROUNDUP(newsz)) / PGSIZE;
    80001290:	8f99                	sub	a5,a5,a4
    80001292:	83b1                	srli	a5,a5,0xc
    uvmunmap(pagetable, PGROUNDUP(newsz), npages, 1);
    80001294:	4685                	li	a3,1
    80001296:	0007861b          	sext.w	a2,a5
    8000129a:	85ba                	mv	a1,a4
    8000129c:	f39ff0ef          	jal	800011d4 <uvmunmap>
    800012a0:	b7d5                	j	80001284 <uvmdealloc+0x26>

00000000800012a2 <uvmalloc>:
  if(newsz < oldsz)
    800012a2:	0ab66363          	bltu	a2,a1,80001348 <uvmalloc+0xa6>
{
    800012a6:	715d                	addi	sp,sp,-80
    800012a8:	e486                	sd	ra,72(sp)
    800012aa:	e0a2                	sd	s0,64(sp)
    800012ac:	f052                	sd	s4,32(sp)
    800012ae:	ec56                	sd	s5,24(sp)
    800012b0:	e85a                	sd	s6,16(sp)
    800012b2:	0880                	addi	s0,sp,80
    800012b4:	8b2a                	mv	s6,a0
    800012b6:	8ab2                	mv	s5,a2
  oldsz = PGROUNDUP(oldsz);
    800012b8:	6785                	lui	a5,0x1
    800012ba:	17fd                	addi	a5,a5,-1 # fff <_entry-0x7ffff001>
    800012bc:	95be                	add	a1,a1,a5
    800012be:	77fd                	lui	a5,0xfffff
    800012c0:	00f5fa33          	and	s4,a1,a5
  for(a = oldsz; a < newsz; a += PGSIZE){
    800012c4:	08ca7463          	bgeu	s4,a2,8000134c <uvmalloc+0xaa>
    800012c8:	fc26                	sd	s1,56(sp)
    800012ca:	f84a                	sd	s2,48(sp)
    800012cc:	f44e                	sd	s3,40(sp)
    800012ce:	e45e                	sd	s7,8(sp)
    800012d0:	8952                	mv	s2,s4
    memset(mem, 0, PGSIZE);
    800012d2:	6985                	lui	s3,0x1
    if(mappages(pagetable, a, PGSIZE, (uint64)mem, PTE_R|PTE_U|xperm) != 0){
    800012d4:	0126eb93          	ori	s7,a3,18
    mem = kalloc();
    800012d8:	821ff0ef          	jal	80000af8 <kalloc>
    800012dc:	84aa                	mv	s1,a0
    if(mem == 0){
    800012de:	c515                	beqz	a0,8000130a <uvmalloc+0x68>
    memset(mem, 0, PGSIZE);
    800012e0:	864e                	mv	a2,s3
    800012e2:	4581                	li	a1,0
    800012e4:	9b9ff0ef          	jal	80000c9c <memset>
    if(mappages(pagetable, a, PGSIZE, (uint64)mem, PTE_R|PTE_U|xperm) != 0){
    800012e8:	875e                	mv	a4,s7
    800012ea:	86a6                	mv	a3,s1
    800012ec:	864e                	mv	a2,s3
    800012ee:	85ca                	mv	a1,s2
    800012f0:	855a                	mv	a0,s6
    800012f2:	d17ff0ef          	jal	80001008 <mappages>
    800012f6:	e91d                	bnez	a0,8000132c <uvmalloc+0x8a>
  for(a = oldsz; a < newsz; a += PGSIZE){
    800012f8:	994e                	add	s2,s2,s3
    800012fa:	fd596fe3          	bltu	s2,s5,800012d8 <uvmalloc+0x36>
  return newsz;
    800012fe:	8556                	mv	a0,s5
    80001300:	74e2                	ld	s1,56(sp)
    80001302:	7942                	ld	s2,48(sp)
    80001304:	79a2                	ld	s3,40(sp)
    80001306:	6ba2                	ld	s7,8(sp)
    80001308:	a819                	j	8000131e <uvmalloc+0x7c>
      uvmdealloc(pagetable, a, oldsz);
    8000130a:	8652                	mv	a2,s4
    8000130c:	85ca                	mv	a1,s2
    8000130e:	855a                	mv	a0,s6
    80001310:	f4fff0ef          	jal	8000125e <uvmdealloc>
      return 0;
    80001314:	4501                	li	a0,0
    80001316:	74e2                	ld	s1,56(sp)
    80001318:	7942                	ld	s2,48(sp)
    8000131a:	79a2                	ld	s3,40(sp)
    8000131c:	6ba2                	ld	s7,8(sp)
}
    8000131e:	60a6                	ld	ra,72(sp)
    80001320:	6406                	ld	s0,64(sp)
    80001322:	7a02                	ld	s4,32(sp)
    80001324:	6ae2                	ld	s5,24(sp)
    80001326:	6b42                	ld	s6,16(sp)
    80001328:	6161                	addi	sp,sp,80
    8000132a:	8082                	ret
      kfree(mem);
    8000132c:	8526                	mv	a0,s1
    8000132e:	ee8ff0ef          	jal	80000a16 <kfree>
      uvmdealloc(pagetable, a, oldsz);
    80001332:	8652                	mv	a2,s4
    80001334:	85ca                	mv	a1,s2
    80001336:	855a                	mv	a0,s6
    80001338:	f27ff0ef          	jal	8000125e <uvmdealloc>
      return 0;
    8000133c:	4501                	li	a0,0
    8000133e:	74e2                	ld	s1,56(sp)
    80001340:	7942                	ld	s2,48(sp)
    80001342:	79a2                	ld	s3,40(sp)
    80001344:	6ba2                	ld	s7,8(sp)
    80001346:	bfe1                	j	8000131e <uvmalloc+0x7c>
    return oldsz;
    80001348:	852e                	mv	a0,a1
}
    8000134a:	8082                	ret
  return newsz;
    8000134c:	8532                	mv	a0,a2
    8000134e:	bfc1                	j	8000131e <uvmalloc+0x7c>

0000000080001350 <freewalk>:

// Recursively free page-table pages.
// All leaf mappings must already have been removed.
void
freewalk(pagetable_t pagetable)
{
    80001350:	7179                	addi	sp,sp,-48
    80001352:	f406                	sd	ra,40(sp)
    80001354:	f022                	sd	s0,32(sp)
    80001356:	ec26                	sd	s1,24(sp)
    80001358:	e84a                	sd	s2,16(sp)
    8000135a:	e44e                	sd	s3,8(sp)
    8000135c:	e052                	sd	s4,0(sp)
    8000135e:	1800                	addi	s0,sp,48
    80001360:	8a2a                	mv	s4,a0
  // there are 2^9 = 512 PTEs in a page table.
  for(int i = 0; i < 512; i++){
    80001362:	84aa                	mv	s1,a0
    80001364:	6905                	lui	s2,0x1
    80001366:	992a                	add	s2,s2,a0
    pte_t pte = pagetable[i];
    if((pte & PTE_V) && (pte & (PTE_R|PTE_W|PTE_X)) == 0){
    80001368:	4985                	li	s3,1
    8000136a:	a819                	j	80001380 <freewalk+0x30>
      // this PTE points to a lower-level page table.
      uint64 child = PTE2PA(pte);
    8000136c:	83a9                	srli	a5,a5,0xa
      freewalk((pagetable_t)child);
    8000136e:	00c79513          	slli	a0,a5,0xc
    80001372:	fdfff0ef          	jal	80001350 <freewalk>
      pagetable[i] = 0;
    80001376:	0004b023          	sd	zero,0(s1)
  for(int i = 0; i < 512; i++){
    8000137a:	04a1                	addi	s1,s1,8
    8000137c:	01248f63          	beq	s1,s2,8000139a <freewalk+0x4a>
    pte_t pte = pagetable[i];
    80001380:	609c                	ld	a5,0(s1)
    if((pte & PTE_V) && (pte & (PTE_R|PTE_W|PTE_X)) == 0){
    80001382:	00f7f713          	andi	a4,a5,15
    80001386:	ff3703e3          	beq	a4,s3,8000136c <freewalk+0x1c>
    } else if(pte & PTE_V){
    8000138a:	8b85                	andi	a5,a5,1
    8000138c:	d7fd                	beqz	a5,8000137a <freewalk+0x2a>
      panic("freewalk: leaf");
    8000138e:	00006517          	auipc	a0,0x6
    80001392:	daa50513          	addi	a0,a0,-598 # 80007138 <etext+0x138>
    80001396:	c48ff0ef          	jal	800007de <panic>
    }
  }
  kfree((void*)pagetable);
    8000139a:	8552                	mv	a0,s4
    8000139c:	e7aff0ef          	jal	80000a16 <kfree>
}
    800013a0:	70a2                	ld	ra,40(sp)
    800013a2:	7402                	ld	s0,32(sp)
    800013a4:	64e2                	ld	s1,24(sp)
    800013a6:	6942                	ld	s2,16(sp)
    800013a8:	69a2                	ld	s3,8(sp)
    800013aa:	6a02                	ld	s4,0(sp)
    800013ac:	6145                	addi	sp,sp,48
    800013ae:	8082                	ret

00000000800013b0 <uvmfree>:

// Free user memory pages,
// then free page-table pages.
void
uvmfree(pagetable_t pagetable, uint64 sz)
{
    800013b0:	1101                	addi	sp,sp,-32
    800013b2:	ec06                	sd	ra,24(sp)
    800013b4:	e822                	sd	s0,16(sp)
    800013b6:	e426                	sd	s1,8(sp)
    800013b8:	1000                	addi	s0,sp,32
    800013ba:	84aa                	mv	s1,a0
  if(sz > 0)
    800013bc:	e989                	bnez	a1,800013ce <uvmfree+0x1e>
    uvmunmap(pagetable, 0, PGROUNDUP(sz)/PGSIZE, 1);
  freewalk(pagetable);
    800013be:	8526                	mv	a0,s1
    800013c0:	f91ff0ef          	jal	80001350 <freewalk>
}
    800013c4:	60e2                	ld	ra,24(sp)
    800013c6:	6442                	ld	s0,16(sp)
    800013c8:	64a2                	ld	s1,8(sp)
    800013ca:	6105                	addi	sp,sp,32
    800013cc:	8082                	ret
    uvmunmap(pagetable, 0, PGROUNDUP(sz)/PGSIZE, 1);
    800013ce:	6785                	lui	a5,0x1
    800013d0:	17fd                	addi	a5,a5,-1 # fff <_entry-0x7ffff001>
    800013d2:	95be                	add	a1,a1,a5
    800013d4:	4685                	li	a3,1
    800013d6:	00c5d613          	srli	a2,a1,0xc
    800013da:	4581                	li	a1,0
    800013dc:	df9ff0ef          	jal	800011d4 <uvmunmap>
    800013e0:	bff9                	j	800013be <uvmfree+0xe>

00000000800013e2 <uvmcopy>:
  pte_t *pte;
  uint64 pa, i;
  uint flags;
  char *mem;

  for(i = 0; i < sz; i += PGSIZE){
    800013e2:	ce59                	beqz	a2,80001480 <uvmcopy+0x9e>
{
    800013e4:	715d                	addi	sp,sp,-80
    800013e6:	e486                	sd	ra,72(sp)
    800013e8:	e0a2                	sd	s0,64(sp)
    800013ea:	fc26                	sd	s1,56(sp)
    800013ec:	f84a                	sd	s2,48(sp)
    800013ee:	f44e                	sd	s3,40(sp)
    800013f0:	f052                	sd	s4,32(sp)
    800013f2:	ec56                	sd	s5,24(sp)
    800013f4:	e85a                	sd	s6,16(sp)
    800013f6:	e45e                	sd	s7,8(sp)
    800013f8:	e062                	sd	s8,0(sp)
    800013fa:	0880                	addi	s0,sp,80
    800013fc:	8b2a                	mv	s6,a0
    800013fe:	8bae                	mv	s7,a1
    80001400:	8ab2                	mv	s5,a2
  for(i = 0; i < sz; i += PGSIZE){
    80001402:	4481                	li	s1,0
      continue;   // physical page hasn't been allocated
    pa = PTE2PA(*pte);
    flags = PTE_FLAGS(*pte);
    if((mem = kalloc()) == 0)
      goto err;
    memmove(mem, (char*)pa, PGSIZE);
    80001404:	6a05                	lui	s4,0x1
    80001406:	a021                	j	8000140e <uvmcopy+0x2c>
  for(i = 0; i < sz; i += PGSIZE){
    80001408:	94d2                	add	s1,s1,s4
    8000140a:	0554fe63          	bgeu	s1,s5,80001466 <uvmcopy+0x84>
    if((pte = walk(old, i, 0)) == 0)
    8000140e:	4601                	li	a2,0
    80001410:	85a6                	mv	a1,s1
    80001412:	855a                	mv	a0,s6
    80001414:	b1dff0ef          	jal	80000f30 <walk>
    80001418:	d965                	beqz	a0,80001408 <uvmcopy+0x26>
    if((*pte & PTE_V) == 0)
    8000141a:	6118                	ld	a4,0(a0)
    8000141c:	00177793          	andi	a5,a4,1
    80001420:	d7e5                	beqz	a5,80001408 <uvmcopy+0x26>
    pa = PTE2PA(*pte);
    80001422:	00a75593          	srli	a1,a4,0xa
    80001426:	00c59c13          	slli	s8,a1,0xc
    flags = PTE_FLAGS(*pte);
    8000142a:	3ff77913          	andi	s2,a4,1023
    if((mem = kalloc()) == 0)
    8000142e:	ecaff0ef          	jal	80000af8 <kalloc>
    80001432:	89aa                	mv	s3,a0
    80001434:	c105                	beqz	a0,80001454 <uvmcopy+0x72>
    memmove(mem, (char*)pa, PGSIZE);
    80001436:	8652                	mv	a2,s4
    80001438:	85e2                	mv	a1,s8
    8000143a:	8c7ff0ef          	jal	80000d00 <memmove>
    if(mappages(new, i, PGSIZE, (uint64)mem, flags) != 0){
    8000143e:	874a                	mv	a4,s2
    80001440:	86ce                	mv	a3,s3
    80001442:	8652                	mv	a2,s4
    80001444:	85a6                	mv	a1,s1
    80001446:	855e                	mv	a0,s7
    80001448:	bc1ff0ef          	jal	80001008 <mappages>
    8000144c:	dd55                	beqz	a0,80001408 <uvmcopy+0x26>
      kfree(mem);
    8000144e:	854e                	mv	a0,s3
    80001450:	dc6ff0ef          	jal	80000a16 <kfree>
    }
  }
  return 0;

 err:
  uvmunmap(new, 0, i / PGSIZE, 1);
    80001454:	4685                	li	a3,1
    80001456:	00c4d613          	srli	a2,s1,0xc
    8000145a:	4581                	li	a1,0
    8000145c:	855e                	mv	a0,s7
    8000145e:	d77ff0ef          	jal	800011d4 <uvmunmap>
  return -1;
    80001462:	557d                	li	a0,-1
    80001464:	a011                	j	80001468 <uvmcopy+0x86>
  return 0;
    80001466:	4501                	li	a0,0
}
    80001468:	60a6                	ld	ra,72(sp)
    8000146a:	6406                	ld	s0,64(sp)
    8000146c:	74e2                	ld	s1,56(sp)
    8000146e:	7942                	ld	s2,48(sp)
    80001470:	79a2                	ld	s3,40(sp)
    80001472:	7a02                	ld	s4,32(sp)
    80001474:	6ae2                	ld	s5,24(sp)
    80001476:	6b42                	ld	s6,16(sp)
    80001478:	6ba2                	ld	s7,8(sp)
    8000147a:	6c02                	ld	s8,0(sp)
    8000147c:	6161                	addi	sp,sp,80
    8000147e:	8082                	ret
  return 0;
    80001480:	4501                	li	a0,0
}
    80001482:	8082                	ret

0000000080001484 <uvmclear>:

// mark a PTE invalid for user access.
// used by exec for the user stack guard page.
void
uvmclear(pagetable_t pagetable, uint64 va)
{
    80001484:	1141                	addi	sp,sp,-16
    80001486:	e406                	sd	ra,8(sp)
    80001488:	e022                	sd	s0,0(sp)
    8000148a:	0800                	addi	s0,sp,16
  pte_t *pte;
  
  pte = walk(pagetable, va, 0);
    8000148c:	4601                	li	a2,0
    8000148e:	aa3ff0ef          	jal	80000f30 <walk>
  if(pte == 0)
    80001492:	c901                	beqz	a0,800014a2 <uvmclear+0x1e>
    panic("uvmclear");
  *pte &= ~PTE_U;
    80001494:	611c                	ld	a5,0(a0)
    80001496:	9bbd                	andi	a5,a5,-17
    80001498:	e11c                	sd	a5,0(a0)
}
    8000149a:	60a2                	ld	ra,8(sp)
    8000149c:	6402                	ld	s0,0(sp)
    8000149e:	0141                	addi	sp,sp,16
    800014a0:	8082                	ret
    panic("uvmclear");
    800014a2:	00006517          	auipc	a0,0x6
    800014a6:	ca650513          	addi	a0,a0,-858 # 80007148 <etext+0x148>
    800014aa:	b34ff0ef          	jal	800007de <panic>

00000000800014ae <copyinstr>:
// Copy bytes to dst from virtual address srcva in a given page table,
// until a '\0', or max.
// Return 0 on success, -1 on error.
int
copyinstr(pagetable_t pagetable, char *dst, uint64 srcva, uint64 max)
{
    800014ae:	715d                	addi	sp,sp,-80
    800014b0:	e486                	sd	ra,72(sp)
    800014b2:	e0a2                	sd	s0,64(sp)
    800014b4:	fc26                	sd	s1,56(sp)
    800014b6:	f84a                	sd	s2,48(sp)
    800014b8:	f44e                	sd	s3,40(sp)
    800014ba:	f052                	sd	s4,32(sp)
    800014bc:	ec56                	sd	s5,24(sp)
    800014be:	e85a                	sd	s6,16(sp)
    800014c0:	e45e                	sd	s7,8(sp)
    800014c2:	0880                	addi	s0,sp,80
    800014c4:	8aaa                	mv	s5,a0
    800014c6:	89ae                	mv	s3,a1
    800014c8:	8bb2                	mv	s7,a2
    800014ca:	84b6                	mv	s1,a3
  uint64 n, va0, pa0;
  int got_null = 0;

  while(got_null == 0 && max > 0){
    va0 = PGROUNDDOWN(srcva);
    800014cc:	7b7d                	lui	s6,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (srcva - va0);
    800014ce:	6a05                	lui	s4,0x1
    800014d0:	a02d                	j	800014fa <copyinstr+0x4c>
      n = max;

    char *p = (char *) (pa0 + (srcva - va0));
    while(n > 0){
      if(*p == '\0'){
        *dst = '\0';
    800014d2:	00078023          	sb	zero,0(a5)
    800014d6:	4785                	li	a5,1
      dst++;
    }

    srcva = va0 + PGSIZE;
  }
  if(got_null){
    800014d8:	0017c793          	xori	a5,a5,1
    800014dc:	40f0053b          	negw	a0,a5
    return 0;
  } else {
    return -1;
  }
}
    800014e0:	60a6                	ld	ra,72(sp)
    800014e2:	6406                	ld	s0,64(sp)
    800014e4:	74e2                	ld	s1,56(sp)
    800014e6:	7942                	ld	s2,48(sp)
    800014e8:	79a2                	ld	s3,40(sp)
    800014ea:	7a02                	ld	s4,32(sp)
    800014ec:	6ae2                	ld	s5,24(sp)
    800014ee:	6b42                	ld	s6,16(sp)
    800014f0:	6ba2                	ld	s7,8(sp)
    800014f2:	6161                	addi	sp,sp,80
    800014f4:	8082                	ret
    srcva = va0 + PGSIZE;
    800014f6:	01490bb3          	add	s7,s2,s4
  while(got_null == 0 && max > 0){
    800014fa:	c4b1                	beqz	s1,80001546 <copyinstr+0x98>
    va0 = PGROUNDDOWN(srcva);
    800014fc:	016bf933          	and	s2,s7,s6
    pa0 = walkaddr(pagetable, va0);
    80001500:	85ca                	mv	a1,s2
    80001502:	8556                	mv	a0,s5
    80001504:	ac7ff0ef          	jal	80000fca <walkaddr>
    if(pa0 == 0)
    80001508:	c129                	beqz	a0,8000154a <copyinstr+0x9c>
    n = PGSIZE - (srcva - va0);
    8000150a:	41790633          	sub	a2,s2,s7
    8000150e:	9652                	add	a2,a2,s4
    if(n > max)
    80001510:	00c4f363          	bgeu	s1,a2,80001516 <copyinstr+0x68>
    80001514:	8626                	mv	a2,s1
    char *p = (char *) (pa0 + (srcva - va0));
    80001516:	412b8bb3          	sub	s7,s7,s2
    8000151a:	9baa                	add	s7,s7,a0
    while(n > 0){
    8000151c:	de69                	beqz	a2,800014f6 <copyinstr+0x48>
    8000151e:	87ce                	mv	a5,s3
      if(*p == '\0'){
    80001520:	413b86b3          	sub	a3,s7,s3
    while(n > 0){
    80001524:	964e                	add	a2,a2,s3
    80001526:	85be                	mv	a1,a5
      if(*p == '\0'){
    80001528:	00f68733          	add	a4,a3,a5
    8000152c:	00074703          	lbu	a4,0(a4)
    80001530:	d34d                	beqz	a4,800014d2 <copyinstr+0x24>
        *dst = *p;
    80001532:	00e78023          	sb	a4,0(a5)
      dst++;
    80001536:	0785                	addi	a5,a5,1
    while(n > 0){
    80001538:	fec797e3          	bne	a5,a2,80001526 <copyinstr+0x78>
    8000153c:	14fd                	addi	s1,s1,-1
    8000153e:	94ce                	add	s1,s1,s3
      --max;
    80001540:	8c8d                	sub	s1,s1,a1
    80001542:	89be                	mv	s3,a5
    80001544:	bf4d                	j	800014f6 <copyinstr+0x48>
    80001546:	4781                	li	a5,0
    80001548:	bf41                	j	800014d8 <copyinstr+0x2a>
      return -1;
    8000154a:	557d                	li	a0,-1
    8000154c:	bf51                	j	800014e0 <copyinstr+0x32>

000000008000154e <ismapped>:
  return mem;
}

int
ismapped(pagetable_t pagetable, uint64 va)
{
    8000154e:	1141                	addi	sp,sp,-16
    80001550:	e406                	sd	ra,8(sp)
    80001552:	e022                	sd	s0,0(sp)
    80001554:	0800                	addi	s0,sp,16
  pte_t *pte = walk(pagetable, va, 0);
    80001556:	4601                	li	a2,0
    80001558:	9d9ff0ef          	jal	80000f30 <walk>
  if (pte == 0) {
    8000155c:	c519                	beqz	a0,8000156a <ismapped+0x1c>
    return 0;
  }
  if (*pte & PTE_V){
    8000155e:	6108                	ld	a0,0(a0)
    80001560:	8905                	andi	a0,a0,1
    return 1;
  }
  return 0;
}
    80001562:	60a2                	ld	ra,8(sp)
    80001564:	6402                	ld	s0,0(sp)
    80001566:	0141                	addi	sp,sp,16
    80001568:	8082                	ret
    return 0;
    8000156a:	4501                	li	a0,0
    8000156c:	bfdd                	j	80001562 <ismapped+0x14>

000000008000156e <vmfault>:
{
    8000156e:	7179                	addi	sp,sp,-48
    80001570:	f406                	sd	ra,40(sp)
    80001572:	f022                	sd	s0,32(sp)
    80001574:	ec26                	sd	s1,24(sp)
    80001576:	e44e                	sd	s3,8(sp)
    80001578:	1800                	addi	s0,sp,48
    8000157a:	89aa                	mv	s3,a0
    8000157c:	84ae                	mv	s1,a1
  struct proc *p = myproc();
    8000157e:	340000ef          	jal	800018be <myproc>
  if (va >= p->sz)
    80001582:	653c                	ld	a5,72(a0)
    80001584:	00f4ea63          	bltu	s1,a5,80001598 <vmfault+0x2a>
    return 0;
    80001588:	4981                	li	s3,0
}
    8000158a:	854e                	mv	a0,s3
    8000158c:	70a2                	ld	ra,40(sp)
    8000158e:	7402                	ld	s0,32(sp)
    80001590:	64e2                	ld	s1,24(sp)
    80001592:	69a2                	ld	s3,8(sp)
    80001594:	6145                	addi	sp,sp,48
    80001596:	8082                	ret
    80001598:	e84a                	sd	s2,16(sp)
    8000159a:	892a                	mv	s2,a0
  va = PGROUNDDOWN(va);
    8000159c:	77fd                	lui	a5,0xfffff
    8000159e:	8cfd                	and	s1,s1,a5
  if(ismapped(pagetable, va)) {
    800015a0:	85a6                	mv	a1,s1
    800015a2:	854e                	mv	a0,s3
    800015a4:	fabff0ef          	jal	8000154e <ismapped>
    return 0;
    800015a8:	4981                	li	s3,0
  if(ismapped(pagetable, va)) {
    800015aa:	c119                	beqz	a0,800015b0 <vmfault+0x42>
    800015ac:	6942                	ld	s2,16(sp)
    800015ae:	bff1                	j	8000158a <vmfault+0x1c>
    800015b0:	e052                	sd	s4,0(sp)
  mem = (uint64) kalloc();
    800015b2:	d46ff0ef          	jal	80000af8 <kalloc>
    800015b6:	8a2a                	mv	s4,a0
  if(mem == 0)
    800015b8:	c90d                	beqz	a0,800015ea <vmfault+0x7c>
  mem = (uint64) kalloc();
    800015ba:	89aa                	mv	s3,a0
  memset((void *) mem, 0, PGSIZE);
    800015bc:	6605                	lui	a2,0x1
    800015be:	4581                	li	a1,0
    800015c0:	edcff0ef          	jal	80000c9c <memset>
  if (mappages(p->pagetable, va, PGSIZE, mem, PTE_W|PTE_U|PTE_R) != 0) {
    800015c4:	4759                	li	a4,22
    800015c6:	86d2                	mv	a3,s4
    800015c8:	6605                	lui	a2,0x1
    800015ca:	85a6                	mv	a1,s1
    800015cc:	05093503          	ld	a0,80(s2) # 1050 <_entry-0x7fffefb0>
    800015d0:	a39ff0ef          	jal	80001008 <mappages>
    800015d4:	e501                	bnez	a0,800015dc <vmfault+0x6e>
    800015d6:	6942                	ld	s2,16(sp)
    800015d8:	6a02                	ld	s4,0(sp)
    800015da:	bf45                	j	8000158a <vmfault+0x1c>
    kfree((void *)mem);
    800015dc:	8552                	mv	a0,s4
    800015de:	c38ff0ef          	jal	80000a16 <kfree>
    return 0;
    800015e2:	4981                	li	s3,0
    800015e4:	6942                	ld	s2,16(sp)
    800015e6:	6a02                	ld	s4,0(sp)
    800015e8:	b74d                	j	8000158a <vmfault+0x1c>
    800015ea:	6942                	ld	s2,16(sp)
    800015ec:	6a02                	ld	s4,0(sp)
    800015ee:	bf71                	j	8000158a <vmfault+0x1c>

00000000800015f0 <copyout>:
  while(len > 0){
    800015f0:	cad1                	beqz	a3,80001684 <copyout+0x94>
{
    800015f2:	711d                	addi	sp,sp,-96
    800015f4:	ec86                	sd	ra,88(sp)
    800015f6:	e8a2                	sd	s0,80(sp)
    800015f8:	e4a6                	sd	s1,72(sp)
    800015fa:	e0ca                	sd	s2,64(sp)
    800015fc:	fc4e                	sd	s3,56(sp)
    800015fe:	f852                	sd	s4,48(sp)
    80001600:	f456                	sd	s5,40(sp)
    80001602:	f05a                	sd	s6,32(sp)
    80001604:	ec5e                	sd	s7,24(sp)
    80001606:	e862                	sd	s8,16(sp)
    80001608:	e466                	sd	s9,8(sp)
    8000160a:	e06a                	sd	s10,0(sp)
    8000160c:	1080                	addi	s0,sp,96
    8000160e:	8baa                	mv	s7,a0
    80001610:	8a2e                	mv	s4,a1
    80001612:	8b32                	mv	s6,a2
    80001614:	8ab6                	mv	s5,a3
    va0 = PGROUNDDOWN(dstva);
    80001616:	7d7d                	lui	s10,0xfffff
    if(va0 >= MAXVA)
    80001618:	5cfd                	li	s9,-1
    8000161a:	01acdc93          	srli	s9,s9,0x1a
    n = PGSIZE - (dstva - va0);
    8000161e:	6c05                	lui	s8,0x1
    80001620:	a005                	j	80001640 <copyout+0x50>
    memmove((void *)(pa0 + (dstva - va0)), src, n);
    80001622:	409a0533          	sub	a0,s4,s1
    80001626:	0009061b          	sext.w	a2,s2
    8000162a:	85da                	mv	a1,s6
    8000162c:	954e                	add	a0,a0,s3
    8000162e:	ed2ff0ef          	jal	80000d00 <memmove>
    len -= n;
    80001632:	412a8ab3          	sub	s5,s5,s2
    src += n;
    80001636:	9b4a                	add	s6,s6,s2
    dstva = va0 + PGSIZE;
    80001638:	01848a33          	add	s4,s1,s8
  while(len > 0){
    8000163c:	040a8263          	beqz	s5,80001680 <copyout+0x90>
    va0 = PGROUNDDOWN(dstva);
    80001640:	01aa74b3          	and	s1,s4,s10
    if(va0 >= MAXVA)
    80001644:	049ce263          	bltu	s9,s1,80001688 <copyout+0x98>
    pa0 = walkaddr(pagetable, va0);
    80001648:	85a6                	mv	a1,s1
    8000164a:	855e                	mv	a0,s7
    8000164c:	97fff0ef          	jal	80000fca <walkaddr>
    80001650:	89aa                	mv	s3,a0
    if(pa0 == 0) {
    80001652:	e901                	bnez	a0,80001662 <copyout+0x72>
      if((pa0 = vmfault(pagetable, va0, 0)) == 0) {
    80001654:	4601                	li	a2,0
    80001656:	85a6                	mv	a1,s1
    80001658:	855e                	mv	a0,s7
    8000165a:	f15ff0ef          	jal	8000156e <vmfault>
    8000165e:	89aa                	mv	s3,a0
    80001660:	c139                	beqz	a0,800016a6 <copyout+0xb6>
    pte = walk(pagetable, va0, 0);
    80001662:	4601                	li	a2,0
    80001664:	85a6                	mv	a1,s1
    80001666:	855e                	mv	a0,s7
    80001668:	8c9ff0ef          	jal	80000f30 <walk>
    if((*pte & PTE_W) == 0)
    8000166c:	611c                	ld	a5,0(a0)
    8000166e:	8b91                	andi	a5,a5,4
    80001670:	cf8d                	beqz	a5,800016aa <copyout+0xba>
    n = PGSIZE - (dstva - va0);
    80001672:	41448933          	sub	s2,s1,s4
    80001676:	9962                	add	s2,s2,s8
    if(n > len)
    80001678:	fb2af5e3          	bgeu	s5,s2,80001622 <copyout+0x32>
    8000167c:	8956                	mv	s2,s5
    8000167e:	b755                	j	80001622 <copyout+0x32>
  return 0;
    80001680:	4501                	li	a0,0
    80001682:	a021                	j	8000168a <copyout+0x9a>
    80001684:	4501                	li	a0,0
}
    80001686:	8082                	ret
      return -1;
    80001688:	557d                	li	a0,-1
}
    8000168a:	60e6                	ld	ra,88(sp)
    8000168c:	6446                	ld	s0,80(sp)
    8000168e:	64a6                	ld	s1,72(sp)
    80001690:	6906                	ld	s2,64(sp)
    80001692:	79e2                	ld	s3,56(sp)
    80001694:	7a42                	ld	s4,48(sp)
    80001696:	7aa2                	ld	s5,40(sp)
    80001698:	7b02                	ld	s6,32(sp)
    8000169a:	6be2                	ld	s7,24(sp)
    8000169c:	6c42                	ld	s8,16(sp)
    8000169e:	6ca2                	ld	s9,8(sp)
    800016a0:	6d02                	ld	s10,0(sp)
    800016a2:	6125                	addi	sp,sp,96
    800016a4:	8082                	ret
        return -1;
    800016a6:	557d                	li	a0,-1
    800016a8:	b7cd                	j	8000168a <copyout+0x9a>
      return -1;
    800016aa:	557d                	li	a0,-1
    800016ac:	bff9                	j	8000168a <copyout+0x9a>

00000000800016ae <copyin>:
  while(len > 0){
    800016ae:	c6c9                	beqz	a3,80001738 <copyin+0x8a>
{
    800016b0:	715d                	addi	sp,sp,-80
    800016b2:	e486                	sd	ra,72(sp)
    800016b4:	e0a2                	sd	s0,64(sp)
    800016b6:	fc26                	sd	s1,56(sp)
    800016b8:	f84a                	sd	s2,48(sp)
    800016ba:	f44e                	sd	s3,40(sp)
    800016bc:	f052                	sd	s4,32(sp)
    800016be:	ec56                	sd	s5,24(sp)
    800016c0:	e85a                	sd	s6,16(sp)
    800016c2:	e45e                	sd	s7,8(sp)
    800016c4:	e062                	sd	s8,0(sp)
    800016c6:	0880                	addi	s0,sp,80
    800016c8:	8baa                	mv	s7,a0
    800016ca:	8aae                	mv	s5,a1
    800016cc:	8932                	mv	s2,a2
    800016ce:	8a36                	mv	s4,a3
    va0 = PGROUNDDOWN(srcva);
    800016d0:	7c7d                	lui	s8,0xfffff
    n = PGSIZE - (srcva - va0);
    800016d2:	6b05                	lui	s6,0x1
    800016d4:	a035                	j	80001700 <copyin+0x52>
    800016d6:	412984b3          	sub	s1,s3,s2
    800016da:	94da                	add	s1,s1,s6
    if(n > len)
    800016dc:	009a7363          	bgeu	s4,s1,800016e2 <copyin+0x34>
    800016e0:	84d2                	mv	s1,s4
    memmove(dst, (void *)(pa0 + (srcva - va0)), n);
    800016e2:	413905b3          	sub	a1,s2,s3
    800016e6:	0004861b          	sext.w	a2,s1
    800016ea:	95aa                	add	a1,a1,a0
    800016ec:	8556                	mv	a0,s5
    800016ee:	e12ff0ef          	jal	80000d00 <memmove>
    len -= n;
    800016f2:	409a0a33          	sub	s4,s4,s1
    dst += n;
    800016f6:	9aa6                	add	s5,s5,s1
    srcva = va0 + PGSIZE;
    800016f8:	01698933          	add	s2,s3,s6
  while(len > 0){
    800016fc:	020a0163          	beqz	s4,8000171e <copyin+0x70>
    va0 = PGROUNDDOWN(srcva);
    80001700:	018979b3          	and	s3,s2,s8
    pa0 = walkaddr(pagetable, va0);
    80001704:	85ce                	mv	a1,s3
    80001706:	855e                	mv	a0,s7
    80001708:	8c3ff0ef          	jal	80000fca <walkaddr>
    if(pa0 == 0) {
    8000170c:	f569                	bnez	a0,800016d6 <copyin+0x28>
      if((pa0 = vmfault(pagetable, va0, 0)) == 0) {
    8000170e:	4601                	li	a2,0
    80001710:	85ce                	mv	a1,s3
    80001712:	855e                	mv	a0,s7
    80001714:	e5bff0ef          	jal	8000156e <vmfault>
    80001718:	fd5d                	bnez	a0,800016d6 <copyin+0x28>
        return -1;
    8000171a:	557d                	li	a0,-1
    8000171c:	a011                	j	80001720 <copyin+0x72>
  return 0;
    8000171e:	4501                	li	a0,0
}
    80001720:	60a6                	ld	ra,72(sp)
    80001722:	6406                	ld	s0,64(sp)
    80001724:	74e2                	ld	s1,56(sp)
    80001726:	7942                	ld	s2,48(sp)
    80001728:	79a2                	ld	s3,40(sp)
    8000172a:	7a02                	ld	s4,32(sp)
    8000172c:	6ae2                	ld	s5,24(sp)
    8000172e:	6b42                	ld	s6,16(sp)
    80001730:	6ba2                	ld	s7,8(sp)
    80001732:	6c02                	ld	s8,0(sp)
    80001734:	6161                	addi	sp,sp,80
    80001736:	8082                	ret
  return 0;
    80001738:	4501                	li	a0,0
}
    8000173a:	8082                	ret

000000008000173c <proc_mapstacks>:
// Allocate a page for each process's kernel stack.
// Map it high in memory, followed by an invalid
// guard page.
void
proc_mapstacks(pagetable_t kpgtbl)
{
    8000173c:	715d                	addi	sp,sp,-80
    8000173e:	e486                	sd	ra,72(sp)
    80001740:	e0a2                	sd	s0,64(sp)
    80001742:	fc26                	sd	s1,56(sp)
    80001744:	f84a                	sd	s2,48(sp)
    80001746:	f44e                	sd	s3,40(sp)
    80001748:	f052                	sd	s4,32(sp)
    8000174a:	ec56                	sd	s5,24(sp)
    8000174c:	e85a                	sd	s6,16(sp)
    8000174e:	e45e                	sd	s7,8(sp)
    80001750:	e062                	sd	s8,0(sp)
    80001752:	0880                	addi	s0,sp,80
    80001754:	8a2a                	mv	s4,a0
  struct proc *p;
  
  for(p = proc; p < &proc[NPROC]; p++) {
    80001756:	0000e497          	auipc	s1,0xe
    8000175a:	6a248493          	addi	s1,s1,1698 # 8000fdf8 <proc>
    char *pa = kalloc();
    if(pa == 0)
      panic("kalloc");
    uint64 va = KSTACK((int) (p - proc));
    8000175e:	8c26                	mv	s8,s1
    80001760:	a4fa57b7          	lui	a5,0xa4fa5
    80001764:	fa578793          	addi	a5,a5,-91 # ffffffffa4fa4fa5 <end+0xffffffff24f843cd>
    80001768:	4fa50937          	lui	s2,0x4fa50
    8000176c:	a5090913          	addi	s2,s2,-1456 # 4fa4fa50 <_entry-0x305b05b0>
    80001770:	1902                	slli	s2,s2,0x20
    80001772:	993e                	add	s2,s2,a5
    80001774:	040009b7          	lui	s3,0x4000
    80001778:	19fd                	addi	s3,s3,-1 # 3ffffff <_entry-0x7c000001>
    8000177a:	09b2                	slli	s3,s3,0xc
    kvmmap(kpgtbl, va, (uint64)pa, PGSIZE, PTE_R | PTE_W);
    8000177c:	4b99                	li	s7,6
    8000177e:	6b05                	lui	s6,0x1
  for(p = proc; p < &proc[NPROC]; p++) {
    80001780:	00014a97          	auipc	s5,0x14
    80001784:	078a8a93          	addi	s5,s5,120 # 800157f8 <tickslock>
    char *pa = kalloc();
    80001788:	b70ff0ef          	jal	80000af8 <kalloc>
    8000178c:	862a                	mv	a2,a0
    if(pa == 0)
    8000178e:	c121                	beqz	a0,800017ce <proc_mapstacks+0x92>
    uint64 va = KSTACK((int) (p - proc));
    80001790:	418485b3          	sub	a1,s1,s8
    80001794:	858d                	srai	a1,a1,0x3
    80001796:	032585b3          	mul	a1,a1,s2
    8000179a:	2585                	addiw	a1,a1,1
    8000179c:	00d5959b          	slliw	a1,a1,0xd
    kvmmap(kpgtbl, va, (uint64)pa, PGSIZE, PTE_R | PTE_W);
    800017a0:	875e                	mv	a4,s7
    800017a2:	86da                	mv	a3,s6
    800017a4:	40b985b3          	sub	a1,s3,a1
    800017a8:	8552                	mv	a0,s4
    800017aa:	915ff0ef          	jal	800010be <kvmmap>
  for(p = proc; p < &proc[NPROC]; p++) {
    800017ae:	16848493          	addi	s1,s1,360
    800017b2:	fd549be3          	bne	s1,s5,80001788 <proc_mapstacks+0x4c>
  }
}
    800017b6:	60a6                	ld	ra,72(sp)
    800017b8:	6406                	ld	s0,64(sp)
    800017ba:	74e2                	ld	s1,56(sp)
    800017bc:	7942                	ld	s2,48(sp)
    800017be:	79a2                	ld	s3,40(sp)
    800017c0:	7a02                	ld	s4,32(sp)
    800017c2:	6ae2                	ld	s5,24(sp)
    800017c4:	6b42                	ld	s6,16(sp)
    800017c6:	6ba2                	ld	s7,8(sp)
    800017c8:	6c02                	ld	s8,0(sp)
    800017ca:	6161                	addi	sp,sp,80
    800017cc:	8082                	ret
      panic("kalloc");
    800017ce:	00006517          	auipc	a0,0x6
    800017d2:	98a50513          	addi	a0,a0,-1654 # 80007158 <etext+0x158>
    800017d6:	808ff0ef          	jal	800007de <panic>

00000000800017da <procinit>:

// initialize the proc table.
void
procinit(void)
{
    800017da:	7139                	addi	sp,sp,-64
    800017dc:	fc06                	sd	ra,56(sp)
    800017de:	f822                	sd	s0,48(sp)
    800017e0:	f426                	sd	s1,40(sp)
    800017e2:	f04a                	sd	s2,32(sp)
    800017e4:	ec4e                	sd	s3,24(sp)
    800017e6:	e852                	sd	s4,16(sp)
    800017e8:	e456                	sd	s5,8(sp)
    800017ea:	e05a                	sd	s6,0(sp)
    800017ec:	0080                	addi	s0,sp,64
  struct proc *p;
  
  initlock(&pid_lock, "nextpid");
    800017ee:	00006597          	auipc	a1,0x6
    800017f2:	97258593          	addi	a1,a1,-1678 # 80007160 <etext+0x160>
    800017f6:	0000e517          	auipc	a0,0xe
    800017fa:	1d250513          	addi	a0,a0,466 # 8000f9c8 <pid_lock>
    800017fe:	b4aff0ef          	jal	80000b48 <initlock>
  initlock(&wait_lock, "wait_lock");
    80001802:	00006597          	auipc	a1,0x6
    80001806:	96658593          	addi	a1,a1,-1690 # 80007168 <etext+0x168>
    8000180a:	0000e517          	auipc	a0,0xe
    8000180e:	1d650513          	addi	a0,a0,470 # 8000f9e0 <wait_lock>
    80001812:	b36ff0ef          	jal	80000b48 <initlock>
  for(p = proc; p < &proc[NPROC]; p++) {
    80001816:	0000e497          	auipc	s1,0xe
    8000181a:	5e248493          	addi	s1,s1,1506 # 8000fdf8 <proc>
      initlock(&p->lock, "proc");
    8000181e:	00006b17          	auipc	s6,0x6
    80001822:	95ab0b13          	addi	s6,s6,-1702 # 80007178 <etext+0x178>
      p->state = UNUSED;
      p->kstack = KSTACK((int) (p - proc));
    80001826:	8aa6                	mv	s5,s1
    80001828:	a4fa57b7          	lui	a5,0xa4fa5
    8000182c:	fa578793          	addi	a5,a5,-91 # ffffffffa4fa4fa5 <end+0xffffffff24f843cd>
    80001830:	4fa50937          	lui	s2,0x4fa50
    80001834:	a5090913          	addi	s2,s2,-1456 # 4fa4fa50 <_entry-0x305b05b0>
    80001838:	1902                	slli	s2,s2,0x20
    8000183a:	993e                	add	s2,s2,a5
    8000183c:	040009b7          	lui	s3,0x4000
    80001840:	19fd                	addi	s3,s3,-1 # 3ffffff <_entry-0x7c000001>
    80001842:	09b2                	slli	s3,s3,0xc
  for(p = proc; p < &proc[NPROC]; p++) {
    80001844:	00014a17          	auipc	s4,0x14
    80001848:	fb4a0a13          	addi	s4,s4,-76 # 800157f8 <tickslock>
      initlock(&p->lock, "proc");
    8000184c:	85da                	mv	a1,s6
    8000184e:	8526                	mv	a0,s1
    80001850:	af8ff0ef          	jal	80000b48 <initlock>
      p->state = UNUSED;
    80001854:	0004ac23          	sw	zero,24(s1)
      p->kstack = KSTACK((int) (p - proc));
    80001858:	415487b3          	sub	a5,s1,s5
    8000185c:	878d                	srai	a5,a5,0x3
    8000185e:	032787b3          	mul	a5,a5,s2
    80001862:	2785                	addiw	a5,a5,1
    80001864:	00d7979b          	slliw	a5,a5,0xd
    80001868:	40f987b3          	sub	a5,s3,a5
    8000186c:	e0bc                	sd	a5,64(s1)
  for(p = proc; p < &proc[NPROC]; p++) {
    8000186e:	16848493          	addi	s1,s1,360
    80001872:	fd449de3          	bne	s1,s4,8000184c <procinit+0x72>
  }
}
    80001876:	70e2                	ld	ra,56(sp)
    80001878:	7442                	ld	s0,48(sp)
    8000187a:	74a2                	ld	s1,40(sp)
    8000187c:	7902                	ld	s2,32(sp)
    8000187e:	69e2                	ld	s3,24(sp)
    80001880:	6a42                	ld	s4,16(sp)
    80001882:	6aa2                	ld	s5,8(sp)
    80001884:	6b02                	ld	s6,0(sp)
    80001886:	6121                	addi	sp,sp,64
    80001888:	8082                	ret

000000008000188a <cpuid>:
// Must be called with interrupts disabled,
// to prevent race with process being moved
// to a different CPU.
int
cpuid()
{
    8000188a:	1141                	addi	sp,sp,-16
    8000188c:	e406                	sd	ra,8(sp)
    8000188e:	e022                	sd	s0,0(sp)
    80001890:	0800                	addi	s0,sp,16
  asm volatile("mv %0, tp" : "=r" (x) );
    80001892:	8512                	mv	a0,tp
  int id = r_tp();
  return id;
}
    80001894:	2501                	sext.w	a0,a0
    80001896:	60a2                	ld	ra,8(sp)
    80001898:	6402                	ld	s0,0(sp)
    8000189a:	0141                	addi	sp,sp,16
    8000189c:	8082                	ret

000000008000189e <mycpu>:

// Return this CPU's cpu struct.
// Interrupts must be disabled.
struct cpu*
mycpu(void)
{
    8000189e:	1141                	addi	sp,sp,-16
    800018a0:	e406                	sd	ra,8(sp)
    800018a2:	e022                	sd	s0,0(sp)
    800018a4:	0800                	addi	s0,sp,16
    800018a6:	8792                	mv	a5,tp
  int id = cpuid();
  struct cpu *c = &cpus[id];
    800018a8:	2781                	sext.w	a5,a5
    800018aa:	079e                	slli	a5,a5,0x7
  return c;
}
    800018ac:	0000e517          	auipc	a0,0xe
    800018b0:	14c50513          	addi	a0,a0,332 # 8000f9f8 <cpus>
    800018b4:	953e                	add	a0,a0,a5
    800018b6:	60a2                	ld	ra,8(sp)
    800018b8:	6402                	ld	s0,0(sp)
    800018ba:	0141                	addi	sp,sp,16
    800018bc:	8082                	ret

00000000800018be <myproc>:

// Return the current struct proc *, or zero if none.
struct proc*
myproc(void)
{
    800018be:	1101                	addi	sp,sp,-32
    800018c0:	ec06                	sd	ra,24(sp)
    800018c2:	e822                	sd	s0,16(sp)
    800018c4:	e426                	sd	s1,8(sp)
    800018c6:	1000                	addi	s0,sp,32
  push_off();
    800018c8:	ac4ff0ef          	jal	80000b8c <push_off>
    800018cc:	8792                	mv	a5,tp
  struct cpu *c = mycpu();
  struct proc *p = c->proc;
    800018ce:	2781                	sext.w	a5,a5
    800018d0:	079e                	slli	a5,a5,0x7
    800018d2:	0000e717          	auipc	a4,0xe
    800018d6:	0f670713          	addi	a4,a4,246 # 8000f9c8 <pid_lock>
    800018da:	97ba                	add	a5,a5,a4
    800018dc:	7b84                	ld	s1,48(a5)
  pop_off();
    800018de:	b32ff0ef          	jal	80000c10 <pop_off>
  return p;
}
    800018e2:	8526                	mv	a0,s1
    800018e4:	60e2                	ld	ra,24(sp)
    800018e6:	6442                	ld	s0,16(sp)
    800018e8:	64a2                	ld	s1,8(sp)
    800018ea:	6105                	addi	sp,sp,32
    800018ec:	8082                	ret

00000000800018ee <forkret>:

// A fork child's very first scheduling by scheduler()
// will swtch to forkret.
void
forkret(void)
{
    800018ee:	7179                	addi	sp,sp,-48
    800018f0:	f406                	sd	ra,40(sp)
    800018f2:	f022                	sd	s0,32(sp)
    800018f4:	ec26                	sd	s1,24(sp)
    800018f6:	1800                	addi	s0,sp,48
  extern char userret[];
  static int first = 1;
  struct proc *p = myproc();
    800018f8:	fc7ff0ef          	jal	800018be <myproc>
    800018fc:	84aa                	mv	s1,a0

  // Still holding p->lock from scheduler.
  release(&p->lock);
    800018fe:	b62ff0ef          	jal	80000c60 <release>

  if (first) {
    80001902:	00006797          	auipc	a5,0x6
    80001906:	f8e7a783          	lw	a5,-114(a5) # 80007890 <first.1>
    8000190a:	cf8d                	beqz	a5,80001944 <forkret+0x56>
    // File system initialization must be run in the context of a
    // regular process (e.g., because it calls sleep), and thus cannot
    // be run from main().
    fsinit(ROOTDEV);
    8000190c:	4505                	li	a0,1
    8000190e:	493010ef          	jal	800035a0 <fsinit>

    first = 0;
    80001912:	00006797          	auipc	a5,0x6
    80001916:	f607af23          	sw	zero,-130(a5) # 80007890 <first.1>
    // ensure other cores see first=0.
    __sync_synchronize();
    8000191a:	0330000f          	fence	rw,rw

    // We can invoke kexec() now that file system is initialized.
    // Put the return value (argc) of kexec into a0.
    p->trapframe->a0 = kexec("/init", (char *[]){ "/init", 0 });
    8000191e:	00006517          	auipc	a0,0x6
    80001922:	86250513          	addi	a0,a0,-1950 # 80007180 <etext+0x180>
    80001926:	fca43823          	sd	a0,-48(s0)
    8000192a:	fc043c23          	sd	zero,-40(s0)
    8000192e:	fd040593          	addi	a1,s0,-48
    80001932:	5c5020ef          	jal	800046f6 <kexec>
    80001936:	6cbc                	ld	a5,88(s1)
    80001938:	fba8                	sd	a0,112(a5)
    if (p->trapframe->a0 == -1) {
    8000193a:	6cbc                	ld	a5,88(s1)
    8000193c:	7bb8                	ld	a4,112(a5)
    8000193e:	57fd                	li	a5,-1
    80001940:	02f70d63          	beq	a4,a5,8000197a <forkret+0x8c>
      panic("exec");
    }
  }

  // return to user space, mimicing usertrap()'s return.
  prepare_return();
    80001944:	389000ef          	jal	800024cc <prepare_return>
  uint64 satp = MAKE_SATP(p->pagetable);
    80001948:	68a8                	ld	a0,80(s1)
    8000194a:	8131                	srli	a0,a0,0xc
  uint64 trampoline_userret = TRAMPOLINE + (userret - trampoline);
    8000194c:	04000737          	lui	a4,0x4000
    80001950:	177d                	addi	a4,a4,-1 # 3ffffff <_entry-0x7c000001>
    80001952:	0732                	slli	a4,a4,0xc
    80001954:	00004797          	auipc	a5,0x4
    80001958:	74878793          	addi	a5,a5,1864 # 8000609c <userret>
    8000195c:	00004697          	auipc	a3,0x4
    80001960:	6a468693          	addi	a3,a3,1700 # 80006000 <_trampoline>
    80001964:	8f95                	sub	a5,a5,a3
    80001966:	97ba                	add	a5,a5,a4
  ((void (*)(uint64))trampoline_userret)(satp);
    80001968:	577d                	li	a4,-1
    8000196a:	177e                	slli	a4,a4,0x3f
    8000196c:	8d59                	or	a0,a0,a4
    8000196e:	9782                	jalr	a5
}
    80001970:	70a2                	ld	ra,40(sp)
    80001972:	7402                	ld	s0,32(sp)
    80001974:	64e2                	ld	s1,24(sp)
    80001976:	6145                	addi	sp,sp,48
    80001978:	8082                	ret
      panic("exec");
    8000197a:	00006517          	auipc	a0,0x6
    8000197e:	80e50513          	addi	a0,a0,-2034 # 80007188 <etext+0x188>
    80001982:	e5dfe0ef          	jal	800007de <panic>

0000000080001986 <allocpid>:
{
    80001986:	1101                	addi	sp,sp,-32
    80001988:	ec06                	sd	ra,24(sp)
    8000198a:	e822                	sd	s0,16(sp)
    8000198c:	e426                	sd	s1,8(sp)
    8000198e:	e04a                	sd	s2,0(sp)
    80001990:	1000                	addi	s0,sp,32
  acquire(&pid_lock);
    80001992:	0000e917          	auipc	s2,0xe
    80001996:	03690913          	addi	s2,s2,54 # 8000f9c8 <pid_lock>
    8000199a:	854a                	mv	a0,s2
    8000199c:	a30ff0ef          	jal	80000bcc <acquire>
  pid = nextpid;
    800019a0:	00006797          	auipc	a5,0x6
    800019a4:	ef478793          	addi	a5,a5,-268 # 80007894 <nextpid>
    800019a8:	4384                	lw	s1,0(a5)
  nextpid = nextpid + 1;
    800019aa:	0014871b          	addiw	a4,s1,1
    800019ae:	c398                	sw	a4,0(a5)
  release(&pid_lock);
    800019b0:	854a                	mv	a0,s2
    800019b2:	aaeff0ef          	jal	80000c60 <release>
}
    800019b6:	8526                	mv	a0,s1
    800019b8:	60e2                	ld	ra,24(sp)
    800019ba:	6442                	ld	s0,16(sp)
    800019bc:	64a2                	ld	s1,8(sp)
    800019be:	6902                	ld	s2,0(sp)
    800019c0:	6105                	addi	sp,sp,32
    800019c2:	8082                	ret

00000000800019c4 <proc_pagetable>:
{
    800019c4:	1101                	addi	sp,sp,-32
    800019c6:	ec06                	sd	ra,24(sp)
    800019c8:	e822                	sd	s0,16(sp)
    800019ca:	e426                	sd	s1,8(sp)
    800019cc:	e04a                	sd	s2,0(sp)
    800019ce:	1000                	addi	s0,sp,32
    800019d0:	892a                	mv	s2,a0
  pagetable = uvmcreate();
    800019d2:	fdcff0ef          	jal	800011ae <uvmcreate>
    800019d6:	84aa                	mv	s1,a0
  if(pagetable == 0)
    800019d8:	cd05                	beqz	a0,80001a10 <proc_pagetable+0x4c>
  if(mappages(pagetable, TRAMPOLINE, PGSIZE,
    800019da:	4729                	li	a4,10
    800019dc:	00004697          	auipc	a3,0x4
    800019e0:	62468693          	addi	a3,a3,1572 # 80006000 <_trampoline>
    800019e4:	6605                	lui	a2,0x1
    800019e6:	040005b7          	lui	a1,0x4000
    800019ea:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    800019ec:	05b2                	slli	a1,a1,0xc
    800019ee:	e1aff0ef          	jal	80001008 <mappages>
    800019f2:	02054663          	bltz	a0,80001a1e <proc_pagetable+0x5a>
  if(mappages(pagetable, TRAPFRAME, PGSIZE,
    800019f6:	4719                	li	a4,6
    800019f8:	05893683          	ld	a3,88(s2)
    800019fc:	6605                	lui	a2,0x1
    800019fe:	020005b7          	lui	a1,0x2000
    80001a02:	15fd                	addi	a1,a1,-1 # 1ffffff <_entry-0x7e000001>
    80001a04:	05b6                	slli	a1,a1,0xd
    80001a06:	8526                	mv	a0,s1
    80001a08:	e00ff0ef          	jal	80001008 <mappages>
    80001a0c:	00054f63          	bltz	a0,80001a2a <proc_pagetable+0x66>
}
    80001a10:	8526                	mv	a0,s1
    80001a12:	60e2                	ld	ra,24(sp)
    80001a14:	6442                	ld	s0,16(sp)
    80001a16:	64a2                	ld	s1,8(sp)
    80001a18:	6902                	ld	s2,0(sp)
    80001a1a:	6105                	addi	sp,sp,32
    80001a1c:	8082                	ret
    uvmfree(pagetable, 0);
    80001a1e:	4581                	li	a1,0
    80001a20:	8526                	mv	a0,s1
    80001a22:	98fff0ef          	jal	800013b0 <uvmfree>
    return 0;
    80001a26:	4481                	li	s1,0
    80001a28:	b7e5                	j	80001a10 <proc_pagetable+0x4c>
    uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80001a2a:	4681                	li	a3,0
    80001a2c:	4605                	li	a2,1
    80001a2e:	040005b7          	lui	a1,0x4000
    80001a32:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80001a34:	05b2                	slli	a1,a1,0xc
    80001a36:	8526                	mv	a0,s1
    80001a38:	f9cff0ef          	jal	800011d4 <uvmunmap>
    uvmfree(pagetable, 0);
    80001a3c:	4581                	li	a1,0
    80001a3e:	8526                	mv	a0,s1
    80001a40:	971ff0ef          	jal	800013b0 <uvmfree>
    return 0;
    80001a44:	4481                	li	s1,0
    80001a46:	b7e9                	j	80001a10 <proc_pagetable+0x4c>

0000000080001a48 <proc_freepagetable>:
{
    80001a48:	1101                	addi	sp,sp,-32
    80001a4a:	ec06                	sd	ra,24(sp)
    80001a4c:	e822                	sd	s0,16(sp)
    80001a4e:	e426                	sd	s1,8(sp)
    80001a50:	e04a                	sd	s2,0(sp)
    80001a52:	1000                	addi	s0,sp,32
    80001a54:	84aa                	mv	s1,a0
    80001a56:	892e                	mv	s2,a1
  uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80001a58:	4681                	li	a3,0
    80001a5a:	4605                	li	a2,1
    80001a5c:	040005b7          	lui	a1,0x4000
    80001a60:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80001a62:	05b2                	slli	a1,a1,0xc
    80001a64:	f70ff0ef          	jal	800011d4 <uvmunmap>
  uvmunmap(pagetable, TRAPFRAME, 1, 0);
    80001a68:	4681                	li	a3,0
    80001a6a:	4605                	li	a2,1
    80001a6c:	020005b7          	lui	a1,0x2000
    80001a70:	15fd                	addi	a1,a1,-1 # 1ffffff <_entry-0x7e000001>
    80001a72:	05b6                	slli	a1,a1,0xd
    80001a74:	8526                	mv	a0,s1
    80001a76:	f5eff0ef          	jal	800011d4 <uvmunmap>
  uvmfree(pagetable, sz);
    80001a7a:	85ca                	mv	a1,s2
    80001a7c:	8526                	mv	a0,s1
    80001a7e:	933ff0ef          	jal	800013b0 <uvmfree>
}
    80001a82:	60e2                	ld	ra,24(sp)
    80001a84:	6442                	ld	s0,16(sp)
    80001a86:	64a2                	ld	s1,8(sp)
    80001a88:	6902                	ld	s2,0(sp)
    80001a8a:	6105                	addi	sp,sp,32
    80001a8c:	8082                	ret

0000000080001a8e <freeproc>:
{
    80001a8e:	1101                	addi	sp,sp,-32
    80001a90:	ec06                	sd	ra,24(sp)
    80001a92:	e822                	sd	s0,16(sp)
    80001a94:	e426                	sd	s1,8(sp)
    80001a96:	1000                	addi	s0,sp,32
    80001a98:	84aa                	mv	s1,a0
  if(p->trapframe)
    80001a9a:	6d28                	ld	a0,88(a0)
    80001a9c:	c119                	beqz	a0,80001aa2 <freeproc+0x14>
    kfree((void*)p->trapframe);
    80001a9e:	f79fe0ef          	jal	80000a16 <kfree>
  p->trapframe = 0;
    80001aa2:	0404bc23          	sd	zero,88(s1)
  if(p->pagetable)
    80001aa6:	68a8                	ld	a0,80(s1)
    80001aa8:	c501                	beqz	a0,80001ab0 <freeproc+0x22>
    proc_freepagetable(p->pagetable, p->sz);
    80001aaa:	64ac                	ld	a1,72(s1)
    80001aac:	f9dff0ef          	jal	80001a48 <proc_freepagetable>
  p->pagetable = 0;
    80001ab0:	0404b823          	sd	zero,80(s1)
  p->sz = 0;
    80001ab4:	0404b423          	sd	zero,72(s1)
  p->pid = 0;
    80001ab8:	0204a823          	sw	zero,48(s1)
  p->parent = 0;
    80001abc:	0204bc23          	sd	zero,56(s1)
  p->name[0] = 0;
    80001ac0:	14048c23          	sb	zero,344(s1)
  p->chan = 0;
    80001ac4:	0204b023          	sd	zero,32(s1)
  p->killed = 0;
    80001ac8:	0204a423          	sw	zero,40(s1)
  p->xstate = 0;
    80001acc:	0204a623          	sw	zero,44(s1)
  p->state = UNUSED;
    80001ad0:	0004ac23          	sw	zero,24(s1)
}
    80001ad4:	60e2                	ld	ra,24(sp)
    80001ad6:	6442                	ld	s0,16(sp)
    80001ad8:	64a2                	ld	s1,8(sp)
    80001ada:	6105                	addi	sp,sp,32
    80001adc:	8082                	ret

0000000080001ade <allocproc>:
{
    80001ade:	1101                	addi	sp,sp,-32
    80001ae0:	ec06                	sd	ra,24(sp)
    80001ae2:	e822                	sd	s0,16(sp)
    80001ae4:	e426                	sd	s1,8(sp)
    80001ae6:	e04a                	sd	s2,0(sp)
    80001ae8:	1000                	addi	s0,sp,32
  for(p = proc; p < &proc[NPROC]; p++) {
    80001aea:	0000e497          	auipc	s1,0xe
    80001aee:	30e48493          	addi	s1,s1,782 # 8000fdf8 <proc>
    80001af2:	00014917          	auipc	s2,0x14
    80001af6:	d0690913          	addi	s2,s2,-762 # 800157f8 <tickslock>
    acquire(&p->lock);
    80001afa:	8526                	mv	a0,s1
    80001afc:	8d0ff0ef          	jal	80000bcc <acquire>
    if(p->state == UNUSED) {
    80001b00:	4c9c                	lw	a5,24(s1)
    80001b02:	cb91                	beqz	a5,80001b16 <allocproc+0x38>
      release(&p->lock);
    80001b04:	8526                	mv	a0,s1
    80001b06:	95aff0ef          	jal	80000c60 <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    80001b0a:	16848493          	addi	s1,s1,360
    80001b0e:	ff2496e3          	bne	s1,s2,80001afa <allocproc+0x1c>
  return 0;
    80001b12:	4481                	li	s1,0
    80001b14:	a089                	j	80001b56 <allocproc+0x78>
  p->pid = allocpid();
    80001b16:	e71ff0ef          	jal	80001986 <allocpid>
    80001b1a:	d888                	sw	a0,48(s1)
  p->state = USED;
    80001b1c:	4785                	li	a5,1
    80001b1e:	cc9c                	sw	a5,24(s1)
  if((p->trapframe = (struct trapframe *)kalloc()) == 0){
    80001b20:	fd9fe0ef          	jal	80000af8 <kalloc>
    80001b24:	892a                	mv	s2,a0
    80001b26:	eca8                	sd	a0,88(s1)
    80001b28:	cd15                	beqz	a0,80001b64 <allocproc+0x86>
  p->pagetable = proc_pagetable(p);
    80001b2a:	8526                	mv	a0,s1
    80001b2c:	e99ff0ef          	jal	800019c4 <proc_pagetable>
    80001b30:	892a                	mv	s2,a0
    80001b32:	e8a8                	sd	a0,80(s1)
  if(p->pagetable == 0){
    80001b34:	c121                	beqz	a0,80001b74 <allocproc+0x96>
  memset(&p->context, 0, sizeof(p->context));
    80001b36:	07000613          	li	a2,112
    80001b3a:	4581                	li	a1,0
    80001b3c:	06048513          	addi	a0,s1,96
    80001b40:	95cff0ef          	jal	80000c9c <memset>
  p->context.ra = (uint64)forkret;
    80001b44:	00000797          	auipc	a5,0x0
    80001b48:	daa78793          	addi	a5,a5,-598 # 800018ee <forkret>
    80001b4c:	f0bc                	sd	a5,96(s1)
  p->context.sp = p->kstack + PGSIZE;
    80001b4e:	60bc                	ld	a5,64(s1)
    80001b50:	6705                	lui	a4,0x1
    80001b52:	97ba                	add	a5,a5,a4
    80001b54:	f4bc                	sd	a5,104(s1)
}
    80001b56:	8526                	mv	a0,s1
    80001b58:	60e2                	ld	ra,24(sp)
    80001b5a:	6442                	ld	s0,16(sp)
    80001b5c:	64a2                	ld	s1,8(sp)
    80001b5e:	6902                	ld	s2,0(sp)
    80001b60:	6105                	addi	sp,sp,32
    80001b62:	8082                	ret
    freeproc(p);
    80001b64:	8526                	mv	a0,s1
    80001b66:	f29ff0ef          	jal	80001a8e <freeproc>
    release(&p->lock);
    80001b6a:	8526                	mv	a0,s1
    80001b6c:	8f4ff0ef          	jal	80000c60 <release>
    return 0;
    80001b70:	84ca                	mv	s1,s2
    80001b72:	b7d5                	j	80001b56 <allocproc+0x78>
    freeproc(p);
    80001b74:	8526                	mv	a0,s1
    80001b76:	f19ff0ef          	jal	80001a8e <freeproc>
    release(&p->lock);
    80001b7a:	8526                	mv	a0,s1
    80001b7c:	8e4ff0ef          	jal	80000c60 <release>
    return 0;
    80001b80:	84ca                	mv	s1,s2
    80001b82:	bfd1                	j	80001b56 <allocproc+0x78>

0000000080001b84 <userinit>:
{
    80001b84:	1101                	addi	sp,sp,-32
    80001b86:	ec06                	sd	ra,24(sp)
    80001b88:	e822                	sd	s0,16(sp)
    80001b8a:	e426                	sd	s1,8(sp)
    80001b8c:	1000                	addi	s0,sp,32
  p = allocproc();
    80001b8e:	f51ff0ef          	jal	80001ade <allocproc>
    80001b92:	84aa                	mv	s1,a0
  initproc = p;
    80001b94:	00006797          	auipc	a5,0x6
    80001b98:	d2a7b623          	sd	a0,-724(a5) # 800078c0 <initproc>
  p->cwd = namei("/");
    80001b9c:	00005517          	auipc	a0,0x5
    80001ba0:	5f450513          	addi	a0,a0,1524 # 80007190 <etext+0x190>
    80001ba4:	735010ef          	jal	80003ad8 <namei>
    80001ba8:	14a4b823          	sd	a0,336(s1)
  p->state = RUNNABLE;
    80001bac:	478d                	li	a5,3
    80001bae:	cc9c                	sw	a5,24(s1)
  release(&p->lock);
    80001bb0:	8526                	mv	a0,s1
    80001bb2:	8aeff0ef          	jal	80000c60 <release>
}
    80001bb6:	60e2                	ld	ra,24(sp)
    80001bb8:	6442                	ld	s0,16(sp)
    80001bba:	64a2                	ld	s1,8(sp)
    80001bbc:	6105                	addi	sp,sp,32
    80001bbe:	8082                	ret

0000000080001bc0 <growproc>:
{
    80001bc0:	1101                	addi	sp,sp,-32
    80001bc2:	ec06                	sd	ra,24(sp)
    80001bc4:	e822                	sd	s0,16(sp)
    80001bc6:	e426                	sd	s1,8(sp)
    80001bc8:	e04a                	sd	s2,0(sp)
    80001bca:	1000                	addi	s0,sp,32
    80001bcc:	892a                	mv	s2,a0
  struct proc *p = myproc();
    80001bce:	cf1ff0ef          	jal	800018be <myproc>
    80001bd2:	84aa                	mv	s1,a0
  sz = p->sz;
    80001bd4:	652c                	ld	a1,72(a0)
  if(n > 0){
    80001bd6:	01204c63          	bgtz	s2,80001bee <growproc+0x2e>
  } else if(n < 0){
    80001bda:	02094463          	bltz	s2,80001c02 <growproc+0x42>
  p->sz = sz;
    80001bde:	e4ac                	sd	a1,72(s1)
  return 0;
    80001be0:	4501                	li	a0,0
}
    80001be2:	60e2                	ld	ra,24(sp)
    80001be4:	6442                	ld	s0,16(sp)
    80001be6:	64a2                	ld	s1,8(sp)
    80001be8:	6902                	ld	s2,0(sp)
    80001bea:	6105                	addi	sp,sp,32
    80001bec:	8082                	ret
    if((sz = uvmalloc(p->pagetable, sz, sz + n, PTE_W)) == 0) {
    80001bee:	4691                	li	a3,4
    80001bf0:	00b90633          	add	a2,s2,a1
    80001bf4:	6928                	ld	a0,80(a0)
    80001bf6:	eacff0ef          	jal	800012a2 <uvmalloc>
    80001bfa:	85aa                	mv	a1,a0
    80001bfc:	f16d                	bnez	a0,80001bde <growproc+0x1e>
      return -1;
    80001bfe:	557d                	li	a0,-1
    80001c00:	b7cd                	j	80001be2 <growproc+0x22>
    sz = uvmdealloc(p->pagetable, sz, sz + n);
    80001c02:	00b90633          	add	a2,s2,a1
    80001c06:	6928                	ld	a0,80(a0)
    80001c08:	e56ff0ef          	jal	8000125e <uvmdealloc>
    80001c0c:	85aa                	mv	a1,a0
    80001c0e:	bfc1                	j	80001bde <growproc+0x1e>

0000000080001c10 <kfork>:
{
    80001c10:	7139                	addi	sp,sp,-64
    80001c12:	fc06                	sd	ra,56(sp)
    80001c14:	f822                	sd	s0,48(sp)
    80001c16:	f04a                	sd	s2,32(sp)
    80001c18:	e456                	sd	s5,8(sp)
    80001c1a:	0080                	addi	s0,sp,64
  struct proc *p = myproc();
    80001c1c:	ca3ff0ef          	jal	800018be <myproc>
    80001c20:	8aaa                	mv	s5,a0
  if((np = allocproc()) == 0){
    80001c22:	ebdff0ef          	jal	80001ade <allocproc>
    80001c26:	0e050a63          	beqz	a0,80001d1a <kfork+0x10a>
    80001c2a:	e852                	sd	s4,16(sp)
    80001c2c:	8a2a                	mv	s4,a0
  if(uvmcopy(p->pagetable, np->pagetable, p->sz) < 0){
    80001c2e:	048ab603          	ld	a2,72(s5)
    80001c32:	692c                	ld	a1,80(a0)
    80001c34:	050ab503          	ld	a0,80(s5)
    80001c38:	faaff0ef          	jal	800013e2 <uvmcopy>
    80001c3c:	04054a63          	bltz	a0,80001c90 <kfork+0x80>
    80001c40:	f426                	sd	s1,40(sp)
    80001c42:	ec4e                	sd	s3,24(sp)
  np->sz = p->sz;
    80001c44:	048ab783          	ld	a5,72(s5)
    80001c48:	04fa3423          	sd	a5,72(s4)
  *(np->trapframe) = *(p->trapframe);
    80001c4c:	058ab683          	ld	a3,88(s5)
    80001c50:	87b6                	mv	a5,a3
    80001c52:	058a3703          	ld	a4,88(s4)
    80001c56:	12068693          	addi	a3,a3,288
    80001c5a:	0007b803          	ld	a6,0(a5)
    80001c5e:	6788                	ld	a0,8(a5)
    80001c60:	6b8c                	ld	a1,16(a5)
    80001c62:	6f90                	ld	a2,24(a5)
    80001c64:	01073023          	sd	a6,0(a4) # 1000 <_entry-0x7ffff000>
    80001c68:	e708                	sd	a0,8(a4)
    80001c6a:	eb0c                	sd	a1,16(a4)
    80001c6c:	ef10                	sd	a2,24(a4)
    80001c6e:	02078793          	addi	a5,a5,32
    80001c72:	02070713          	addi	a4,a4,32
    80001c76:	fed792e3          	bne	a5,a3,80001c5a <kfork+0x4a>
  np->trapframe->a0 = 0;
    80001c7a:	058a3783          	ld	a5,88(s4)
    80001c7e:	0607b823          	sd	zero,112(a5)
  for(i = 0; i < NOFILE; i++)
    80001c82:	0d0a8493          	addi	s1,s5,208
    80001c86:	0d0a0913          	addi	s2,s4,208
    80001c8a:	150a8993          	addi	s3,s5,336
    80001c8e:	a831                	j	80001caa <kfork+0x9a>
    freeproc(np);
    80001c90:	8552                	mv	a0,s4
    80001c92:	dfdff0ef          	jal	80001a8e <freeproc>
    release(&np->lock);
    80001c96:	8552                	mv	a0,s4
    80001c98:	fc9fe0ef          	jal	80000c60 <release>
    return -1;
    80001c9c:	597d                	li	s2,-1
    80001c9e:	6a42                	ld	s4,16(sp)
    80001ca0:	a0b5                	j	80001d0c <kfork+0xfc>
  for(i = 0; i < NOFILE; i++)
    80001ca2:	04a1                	addi	s1,s1,8
    80001ca4:	0921                	addi	s2,s2,8
    80001ca6:	01348963          	beq	s1,s3,80001cb8 <kfork+0xa8>
    if(p->ofile[i])
    80001caa:	6088                	ld	a0,0(s1)
    80001cac:	d97d                	beqz	a0,80001ca2 <kfork+0x92>
      np->ofile[i] = filedup(p->ofile[i]);
    80001cae:	3d0020ef          	jal	8000407e <filedup>
    80001cb2:	00a93023          	sd	a0,0(s2)
    80001cb6:	b7f5                	j	80001ca2 <kfork+0x92>
  np->cwd = idup(p->cwd);
    80001cb8:	150ab503          	ld	a0,336(s5)
    80001cbc:	5bc010ef          	jal	80003278 <idup>
    80001cc0:	14aa3823          	sd	a0,336(s4)
  safestrcpy(np->name, p->name, sizeof(p->name));
    80001cc4:	4641                	li	a2,16
    80001cc6:	158a8593          	addi	a1,s5,344
    80001cca:	158a0513          	addi	a0,s4,344
    80001cce:	920ff0ef          	jal	80000dee <safestrcpy>
  pid = np->pid;
    80001cd2:	030a2903          	lw	s2,48(s4)
  release(&np->lock);
    80001cd6:	8552                	mv	a0,s4
    80001cd8:	f89fe0ef          	jal	80000c60 <release>
  acquire(&wait_lock);
    80001cdc:	0000e497          	auipc	s1,0xe
    80001ce0:	d0448493          	addi	s1,s1,-764 # 8000f9e0 <wait_lock>
    80001ce4:	8526                	mv	a0,s1
    80001ce6:	ee7fe0ef          	jal	80000bcc <acquire>
  np->parent = p;
    80001cea:	035a3c23          	sd	s5,56(s4)
  release(&wait_lock);
    80001cee:	8526                	mv	a0,s1
    80001cf0:	f71fe0ef          	jal	80000c60 <release>
  acquire(&np->lock);
    80001cf4:	8552                	mv	a0,s4
    80001cf6:	ed7fe0ef          	jal	80000bcc <acquire>
  np->state = RUNNABLE;
    80001cfa:	478d                	li	a5,3
    80001cfc:	00fa2c23          	sw	a5,24(s4)
  release(&np->lock);
    80001d00:	8552                	mv	a0,s4
    80001d02:	f5ffe0ef          	jal	80000c60 <release>
  return pid;
    80001d06:	74a2                	ld	s1,40(sp)
    80001d08:	69e2                	ld	s3,24(sp)
    80001d0a:	6a42                	ld	s4,16(sp)
}
    80001d0c:	854a                	mv	a0,s2
    80001d0e:	70e2                	ld	ra,56(sp)
    80001d10:	7442                	ld	s0,48(sp)
    80001d12:	7902                	ld	s2,32(sp)
    80001d14:	6aa2                	ld	s5,8(sp)
    80001d16:	6121                	addi	sp,sp,64
    80001d18:	8082                	ret
    return -1;
    80001d1a:	597d                	li	s2,-1
    80001d1c:	bfc5                	j	80001d0c <kfork+0xfc>

0000000080001d1e <scheduler>:
{
    80001d1e:	715d                	addi	sp,sp,-80
    80001d20:	e486                	sd	ra,72(sp)
    80001d22:	e0a2                	sd	s0,64(sp)
    80001d24:	fc26                	sd	s1,56(sp)
    80001d26:	f84a                	sd	s2,48(sp)
    80001d28:	f44e                	sd	s3,40(sp)
    80001d2a:	f052                	sd	s4,32(sp)
    80001d2c:	ec56                	sd	s5,24(sp)
    80001d2e:	e85a                	sd	s6,16(sp)
    80001d30:	e45e                	sd	s7,8(sp)
    80001d32:	e062                	sd	s8,0(sp)
    80001d34:	0880                	addi	s0,sp,80
    80001d36:	8792                	mv	a5,tp
  int id = r_tp();
    80001d38:	2781                	sext.w	a5,a5
  c->proc = 0;
    80001d3a:	00779b13          	slli	s6,a5,0x7
    80001d3e:	0000e717          	auipc	a4,0xe
    80001d42:	c8a70713          	addi	a4,a4,-886 # 8000f9c8 <pid_lock>
    80001d46:	975a                	add	a4,a4,s6
    80001d48:	02073823          	sd	zero,48(a4)
        swtch(&c->context, &p->context);
    80001d4c:	0000e717          	auipc	a4,0xe
    80001d50:	cb470713          	addi	a4,a4,-844 # 8000fa00 <cpus+0x8>
    80001d54:	9b3a                	add	s6,s6,a4
        p->state = RUNNING;
    80001d56:	4c11                	li	s8,4
        c->proc = p;
    80001d58:	079e                	slli	a5,a5,0x7
    80001d5a:	0000ea17          	auipc	s4,0xe
    80001d5e:	c6ea0a13          	addi	s4,s4,-914 # 8000f9c8 <pid_lock>
    80001d62:	9a3e                	add	s4,s4,a5
        found = 1;
    80001d64:	4b85                	li	s7,1
    80001d66:	a83d                	j	80001da4 <scheduler+0x86>
      release(&p->lock);
    80001d68:	8526                	mv	a0,s1
    80001d6a:	ef7fe0ef          	jal	80000c60 <release>
    for(p = proc; p < &proc[NPROC]; p++) {
    80001d6e:	16848493          	addi	s1,s1,360
    80001d72:	03248563          	beq	s1,s2,80001d9c <scheduler+0x7e>
      acquire(&p->lock);
    80001d76:	8526                	mv	a0,s1
    80001d78:	e55fe0ef          	jal	80000bcc <acquire>
      if(p->state == RUNNABLE) {
    80001d7c:	4c9c                	lw	a5,24(s1)
    80001d7e:	ff3795e3          	bne	a5,s3,80001d68 <scheduler+0x4a>
        p->state = RUNNING;
    80001d82:	0184ac23          	sw	s8,24(s1)
        c->proc = p;
    80001d86:	029a3823          	sd	s1,48(s4)
        swtch(&c->context, &p->context);
    80001d8a:	06048593          	addi	a1,s1,96
    80001d8e:	855a                	mv	a0,s6
    80001d90:	692000ef          	jal	80002422 <swtch>
        c->proc = 0;
    80001d94:	020a3823          	sd	zero,48(s4)
        found = 1;
    80001d98:	8ade                	mv	s5,s7
    80001d9a:	b7f9                	j	80001d68 <scheduler+0x4a>
    if(found == 0) {
    80001d9c:	000a9463          	bnez	s5,80001da4 <scheduler+0x86>
      asm volatile("wfi");
    80001da0:	10500073          	wfi
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80001da4:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80001da8:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80001dac:	10079073          	csrw	sstatus,a5
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80001db0:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    80001db4:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80001db6:	10079073          	csrw	sstatus,a5
    int found = 0;
    80001dba:	4a81                	li	s5,0
    for(p = proc; p < &proc[NPROC]; p++) {
    80001dbc:	0000e497          	auipc	s1,0xe
    80001dc0:	03c48493          	addi	s1,s1,60 # 8000fdf8 <proc>
      if(p->state == RUNNABLE) {
    80001dc4:	498d                	li	s3,3
    for(p = proc; p < &proc[NPROC]; p++) {
    80001dc6:	00014917          	auipc	s2,0x14
    80001dca:	a3290913          	addi	s2,s2,-1486 # 800157f8 <tickslock>
    80001dce:	b765                	j	80001d76 <scheduler+0x58>

0000000080001dd0 <sched>:
{
    80001dd0:	7179                	addi	sp,sp,-48
    80001dd2:	f406                	sd	ra,40(sp)
    80001dd4:	f022                	sd	s0,32(sp)
    80001dd6:	ec26                	sd	s1,24(sp)
    80001dd8:	e84a                	sd	s2,16(sp)
    80001dda:	e44e                	sd	s3,8(sp)
    80001ddc:	1800                	addi	s0,sp,48
  struct proc *p = myproc();
    80001dde:	ae1ff0ef          	jal	800018be <myproc>
    80001de2:	84aa                	mv	s1,a0
  if(!holding(&p->lock))
    80001de4:	d7ffe0ef          	jal	80000b62 <holding>
    80001de8:	c92d                	beqz	a0,80001e5a <sched+0x8a>
  asm volatile("mv %0, tp" : "=r" (x) );
    80001dea:	8792                	mv	a5,tp
  if(mycpu()->noff != 1)
    80001dec:	2781                	sext.w	a5,a5
    80001dee:	079e                	slli	a5,a5,0x7
    80001df0:	0000e717          	auipc	a4,0xe
    80001df4:	bd870713          	addi	a4,a4,-1064 # 8000f9c8 <pid_lock>
    80001df8:	97ba                	add	a5,a5,a4
    80001dfa:	0a87a703          	lw	a4,168(a5)
    80001dfe:	4785                	li	a5,1
    80001e00:	06f71363          	bne	a4,a5,80001e66 <sched+0x96>
  if(p->state == RUNNING)
    80001e04:	4c98                	lw	a4,24(s1)
    80001e06:	4791                	li	a5,4
    80001e08:	06f70563          	beq	a4,a5,80001e72 <sched+0xa2>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80001e0c:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80001e10:	8b89                	andi	a5,a5,2
  if(intr_get())
    80001e12:	e7b5                	bnez	a5,80001e7e <sched+0xae>
  asm volatile("mv %0, tp" : "=r" (x) );
    80001e14:	8792                	mv	a5,tp
  intena = mycpu()->intena;
    80001e16:	0000e917          	auipc	s2,0xe
    80001e1a:	bb290913          	addi	s2,s2,-1102 # 8000f9c8 <pid_lock>
    80001e1e:	2781                	sext.w	a5,a5
    80001e20:	079e                	slli	a5,a5,0x7
    80001e22:	97ca                	add	a5,a5,s2
    80001e24:	0ac7a983          	lw	s3,172(a5)
    80001e28:	8792                	mv	a5,tp
  swtch(&p->context, &mycpu()->context);
    80001e2a:	2781                	sext.w	a5,a5
    80001e2c:	079e                	slli	a5,a5,0x7
    80001e2e:	0000e597          	auipc	a1,0xe
    80001e32:	bd258593          	addi	a1,a1,-1070 # 8000fa00 <cpus+0x8>
    80001e36:	95be                	add	a1,a1,a5
    80001e38:	06048513          	addi	a0,s1,96
    80001e3c:	5e6000ef          	jal	80002422 <swtch>
    80001e40:	8792                	mv	a5,tp
  mycpu()->intena = intena;
    80001e42:	2781                	sext.w	a5,a5
    80001e44:	079e                	slli	a5,a5,0x7
    80001e46:	993e                	add	s2,s2,a5
    80001e48:	0b392623          	sw	s3,172(s2)
}
    80001e4c:	70a2                	ld	ra,40(sp)
    80001e4e:	7402                	ld	s0,32(sp)
    80001e50:	64e2                	ld	s1,24(sp)
    80001e52:	6942                	ld	s2,16(sp)
    80001e54:	69a2                	ld	s3,8(sp)
    80001e56:	6145                	addi	sp,sp,48
    80001e58:	8082                	ret
    panic("sched p->lock");
    80001e5a:	00005517          	auipc	a0,0x5
    80001e5e:	33e50513          	addi	a0,a0,830 # 80007198 <etext+0x198>
    80001e62:	97dfe0ef          	jal	800007de <panic>
    panic("sched locks");
    80001e66:	00005517          	auipc	a0,0x5
    80001e6a:	34250513          	addi	a0,a0,834 # 800071a8 <etext+0x1a8>
    80001e6e:	971fe0ef          	jal	800007de <panic>
    panic("sched RUNNING");
    80001e72:	00005517          	auipc	a0,0x5
    80001e76:	34650513          	addi	a0,a0,838 # 800071b8 <etext+0x1b8>
    80001e7a:	965fe0ef          	jal	800007de <panic>
    panic("sched interruptible");
    80001e7e:	00005517          	auipc	a0,0x5
    80001e82:	34a50513          	addi	a0,a0,842 # 800071c8 <etext+0x1c8>
    80001e86:	959fe0ef          	jal	800007de <panic>

0000000080001e8a <yield>:
{
    80001e8a:	1101                	addi	sp,sp,-32
    80001e8c:	ec06                	sd	ra,24(sp)
    80001e8e:	e822                	sd	s0,16(sp)
    80001e90:	e426                	sd	s1,8(sp)
    80001e92:	1000                	addi	s0,sp,32
  struct proc *p = myproc();
    80001e94:	a2bff0ef          	jal	800018be <myproc>
    80001e98:	84aa                	mv	s1,a0
  acquire(&p->lock);
    80001e9a:	d33fe0ef          	jal	80000bcc <acquire>
  p->state = RUNNABLE;
    80001e9e:	478d                	li	a5,3
    80001ea0:	cc9c                	sw	a5,24(s1)
  sched();
    80001ea2:	f2fff0ef          	jal	80001dd0 <sched>
  release(&p->lock);
    80001ea6:	8526                	mv	a0,s1
    80001ea8:	db9fe0ef          	jal	80000c60 <release>
}
    80001eac:	60e2                	ld	ra,24(sp)
    80001eae:	6442                	ld	s0,16(sp)
    80001eb0:	64a2                	ld	s1,8(sp)
    80001eb2:	6105                	addi	sp,sp,32
    80001eb4:	8082                	ret

0000000080001eb6 <sleep>:

// Sleep on channel chan, releasing condition lock lk.
// Re-acquires lk when awakened.
void
sleep(void *chan, struct spinlock *lk)
{
    80001eb6:	7179                	addi	sp,sp,-48
    80001eb8:	f406                	sd	ra,40(sp)
    80001eba:	f022                	sd	s0,32(sp)
    80001ebc:	ec26                	sd	s1,24(sp)
    80001ebe:	e84a                	sd	s2,16(sp)
    80001ec0:	e44e                	sd	s3,8(sp)
    80001ec2:	1800                	addi	s0,sp,48
    80001ec4:	89aa                	mv	s3,a0
    80001ec6:	892e                	mv	s2,a1
  struct proc *p = myproc();
    80001ec8:	9f7ff0ef          	jal	800018be <myproc>
    80001ecc:	84aa                	mv	s1,a0
  // Once we hold p->lock, we can be
  // guaranteed that we won't miss any wakeup
  // (wakeup locks p->lock),
  // so it's okay to release lk.

  acquire(&p->lock);  //DOC: sleeplock1
    80001ece:	cfffe0ef          	jal	80000bcc <acquire>
  release(lk);
    80001ed2:	854a                	mv	a0,s2
    80001ed4:	d8dfe0ef          	jal	80000c60 <release>

  // Go to sleep.
  p->chan = chan;
    80001ed8:	0334b023          	sd	s3,32(s1)
  p->state = SLEEPING;
    80001edc:	4789                	li	a5,2
    80001ede:	cc9c                	sw	a5,24(s1)

  sched();
    80001ee0:	ef1ff0ef          	jal	80001dd0 <sched>

  // Tidy up.
  p->chan = 0;
    80001ee4:	0204b023          	sd	zero,32(s1)

  // Reacquire original lock.
  release(&p->lock);
    80001ee8:	8526                	mv	a0,s1
    80001eea:	d77fe0ef          	jal	80000c60 <release>
  acquire(lk);
    80001eee:	854a                	mv	a0,s2
    80001ef0:	cddfe0ef          	jal	80000bcc <acquire>
}
    80001ef4:	70a2                	ld	ra,40(sp)
    80001ef6:	7402                	ld	s0,32(sp)
    80001ef8:	64e2                	ld	s1,24(sp)
    80001efa:	6942                	ld	s2,16(sp)
    80001efc:	69a2                	ld	s3,8(sp)
    80001efe:	6145                	addi	sp,sp,48
    80001f00:	8082                	ret

0000000080001f02 <wakeup>:

// Wake up all processes sleeping on channel chan.
// Caller should hold the condition lock.
void
wakeup(void *chan)
{
    80001f02:	7139                	addi	sp,sp,-64
    80001f04:	fc06                	sd	ra,56(sp)
    80001f06:	f822                	sd	s0,48(sp)
    80001f08:	f426                	sd	s1,40(sp)
    80001f0a:	f04a                	sd	s2,32(sp)
    80001f0c:	ec4e                	sd	s3,24(sp)
    80001f0e:	e852                	sd	s4,16(sp)
    80001f10:	e456                	sd	s5,8(sp)
    80001f12:	0080                	addi	s0,sp,64
    80001f14:	8a2a                	mv	s4,a0
  struct proc *p;

  for(p = proc; p < &proc[NPROC]; p++) {
    80001f16:	0000e497          	auipc	s1,0xe
    80001f1a:	ee248493          	addi	s1,s1,-286 # 8000fdf8 <proc>
    if(p != myproc()){
      acquire(&p->lock);
      if(p->state == SLEEPING && p->chan == chan) {
    80001f1e:	4989                	li	s3,2
        p->state = RUNNABLE;
    80001f20:	4a8d                	li	s5,3
  for(p = proc; p < &proc[NPROC]; p++) {
    80001f22:	00014917          	auipc	s2,0x14
    80001f26:	8d690913          	addi	s2,s2,-1834 # 800157f8 <tickslock>
    80001f2a:	a801                	j	80001f3a <wakeup+0x38>
      }
      release(&p->lock);
    80001f2c:	8526                	mv	a0,s1
    80001f2e:	d33fe0ef          	jal	80000c60 <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    80001f32:	16848493          	addi	s1,s1,360
    80001f36:	03248263          	beq	s1,s2,80001f5a <wakeup+0x58>
    if(p != myproc()){
    80001f3a:	985ff0ef          	jal	800018be <myproc>
    80001f3e:	fea48ae3          	beq	s1,a0,80001f32 <wakeup+0x30>
      acquire(&p->lock);
    80001f42:	8526                	mv	a0,s1
    80001f44:	c89fe0ef          	jal	80000bcc <acquire>
      if(p->state == SLEEPING && p->chan == chan) {
    80001f48:	4c9c                	lw	a5,24(s1)
    80001f4a:	ff3791e3          	bne	a5,s3,80001f2c <wakeup+0x2a>
    80001f4e:	709c                	ld	a5,32(s1)
    80001f50:	fd479ee3          	bne	a5,s4,80001f2c <wakeup+0x2a>
        p->state = RUNNABLE;
    80001f54:	0154ac23          	sw	s5,24(s1)
    80001f58:	bfd1                	j	80001f2c <wakeup+0x2a>
    }
  }
}
    80001f5a:	70e2                	ld	ra,56(sp)
    80001f5c:	7442                	ld	s0,48(sp)
    80001f5e:	74a2                	ld	s1,40(sp)
    80001f60:	7902                	ld	s2,32(sp)
    80001f62:	69e2                	ld	s3,24(sp)
    80001f64:	6a42                	ld	s4,16(sp)
    80001f66:	6aa2                	ld	s5,8(sp)
    80001f68:	6121                	addi	sp,sp,64
    80001f6a:	8082                	ret

0000000080001f6c <reparent>:
{
    80001f6c:	7179                	addi	sp,sp,-48
    80001f6e:	f406                	sd	ra,40(sp)
    80001f70:	f022                	sd	s0,32(sp)
    80001f72:	ec26                	sd	s1,24(sp)
    80001f74:	e84a                	sd	s2,16(sp)
    80001f76:	e44e                	sd	s3,8(sp)
    80001f78:	e052                	sd	s4,0(sp)
    80001f7a:	1800                	addi	s0,sp,48
    80001f7c:	892a                	mv	s2,a0
  for(pp = proc; pp < &proc[NPROC]; pp++){
    80001f7e:	0000e497          	auipc	s1,0xe
    80001f82:	e7a48493          	addi	s1,s1,-390 # 8000fdf8 <proc>
      pp->parent = initproc;
    80001f86:	00006a17          	auipc	s4,0x6
    80001f8a:	93aa0a13          	addi	s4,s4,-1734 # 800078c0 <initproc>
  for(pp = proc; pp < &proc[NPROC]; pp++){
    80001f8e:	00014997          	auipc	s3,0x14
    80001f92:	86a98993          	addi	s3,s3,-1942 # 800157f8 <tickslock>
    80001f96:	a029                	j	80001fa0 <reparent+0x34>
    80001f98:	16848493          	addi	s1,s1,360
    80001f9c:	01348b63          	beq	s1,s3,80001fb2 <reparent+0x46>
    if(pp->parent == p){
    80001fa0:	7c9c                	ld	a5,56(s1)
    80001fa2:	ff279be3          	bne	a5,s2,80001f98 <reparent+0x2c>
      pp->parent = initproc;
    80001fa6:	000a3503          	ld	a0,0(s4)
    80001faa:	fc88                	sd	a0,56(s1)
      wakeup(initproc);
    80001fac:	f57ff0ef          	jal	80001f02 <wakeup>
    80001fb0:	b7e5                	j	80001f98 <reparent+0x2c>
}
    80001fb2:	70a2                	ld	ra,40(sp)
    80001fb4:	7402                	ld	s0,32(sp)
    80001fb6:	64e2                	ld	s1,24(sp)
    80001fb8:	6942                	ld	s2,16(sp)
    80001fba:	69a2                	ld	s3,8(sp)
    80001fbc:	6a02                	ld	s4,0(sp)
    80001fbe:	6145                	addi	sp,sp,48
    80001fc0:	8082                	ret

0000000080001fc2 <kexit>:
{
    80001fc2:	7179                	addi	sp,sp,-48
    80001fc4:	f406                	sd	ra,40(sp)
    80001fc6:	f022                	sd	s0,32(sp)
    80001fc8:	ec26                	sd	s1,24(sp)
    80001fca:	e84a                	sd	s2,16(sp)
    80001fcc:	e44e                	sd	s3,8(sp)
    80001fce:	e052                	sd	s4,0(sp)
    80001fd0:	1800                	addi	s0,sp,48
    80001fd2:	8a2a                	mv	s4,a0
  struct proc *p = myproc();
    80001fd4:	8ebff0ef          	jal	800018be <myproc>
    80001fd8:	89aa                	mv	s3,a0
  if(p == initproc)
    80001fda:	00006797          	auipc	a5,0x6
    80001fde:	8e67b783          	ld	a5,-1818(a5) # 800078c0 <initproc>
    80001fe2:	0d050493          	addi	s1,a0,208
    80001fe6:	15050913          	addi	s2,a0,336
    80001fea:	00a79b63          	bne	a5,a0,80002000 <kexit+0x3e>
    panic("init exiting");
    80001fee:	00005517          	auipc	a0,0x5
    80001ff2:	1f250513          	addi	a0,a0,498 # 800071e0 <etext+0x1e0>
    80001ff6:	fe8fe0ef          	jal	800007de <panic>
  for(int fd = 0; fd < NOFILE; fd++){
    80001ffa:	04a1                	addi	s1,s1,8
    80001ffc:	01248963          	beq	s1,s2,8000200e <kexit+0x4c>
    if(p->ofile[fd]){
    80002000:	6088                	ld	a0,0(s1)
    80002002:	dd65                	beqz	a0,80001ffa <kexit+0x38>
      fileclose(f);
    80002004:	0c0020ef          	jal	800040c4 <fileclose>
      p->ofile[fd] = 0;
    80002008:	0004b023          	sd	zero,0(s1)
    8000200c:	b7fd                	j	80001ffa <kexit+0x38>
  begin_op();
    8000200e:	4a5010ef          	jal	80003cb2 <begin_op>
  iput(p->cwd);
    80002012:	1509b503          	ld	a0,336(s3)
    80002016:	41a010ef          	jal	80003430 <iput>
  end_op();
    8000201a:	503010ef          	jal	80003d1c <end_op>
  p->cwd = 0;
    8000201e:	1409b823          	sd	zero,336(s3)
  acquire(&wait_lock);
    80002022:	0000e497          	auipc	s1,0xe
    80002026:	9be48493          	addi	s1,s1,-1602 # 8000f9e0 <wait_lock>
    8000202a:	8526                	mv	a0,s1
    8000202c:	ba1fe0ef          	jal	80000bcc <acquire>
  reparent(p);
    80002030:	854e                	mv	a0,s3
    80002032:	f3bff0ef          	jal	80001f6c <reparent>
  wakeup(p->parent);
    80002036:	0389b503          	ld	a0,56(s3)
    8000203a:	ec9ff0ef          	jal	80001f02 <wakeup>
  acquire(&p->lock);
    8000203e:	854e                	mv	a0,s3
    80002040:	b8dfe0ef          	jal	80000bcc <acquire>
  p->xstate = status;
    80002044:	0349a623          	sw	s4,44(s3)
  p->state = ZOMBIE;
    80002048:	4795                	li	a5,5
    8000204a:	00f9ac23          	sw	a5,24(s3)
  release(&wait_lock);
    8000204e:	8526                	mv	a0,s1
    80002050:	c11fe0ef          	jal	80000c60 <release>
  sched();
    80002054:	d7dff0ef          	jal	80001dd0 <sched>
  panic("zombie exit");
    80002058:	00005517          	auipc	a0,0x5
    8000205c:	19850513          	addi	a0,a0,408 # 800071f0 <etext+0x1f0>
    80002060:	f7efe0ef          	jal	800007de <panic>

0000000080002064 <kkill>:
// Kill the process with the given pid.
// The victim won't exit until it tries to return
// to user space (see usertrap() in trap.c).
int
kkill(int pid)
{
    80002064:	7179                	addi	sp,sp,-48
    80002066:	f406                	sd	ra,40(sp)
    80002068:	f022                	sd	s0,32(sp)
    8000206a:	ec26                	sd	s1,24(sp)
    8000206c:	e84a                	sd	s2,16(sp)
    8000206e:	e44e                	sd	s3,8(sp)
    80002070:	1800                	addi	s0,sp,48
    80002072:	892a                	mv	s2,a0
  struct proc *p;

  for(p = proc; p < &proc[NPROC]; p++){
    80002074:	0000e497          	auipc	s1,0xe
    80002078:	d8448493          	addi	s1,s1,-636 # 8000fdf8 <proc>
    8000207c:	00013997          	auipc	s3,0x13
    80002080:	77c98993          	addi	s3,s3,1916 # 800157f8 <tickslock>
    acquire(&p->lock);
    80002084:	8526                	mv	a0,s1
    80002086:	b47fe0ef          	jal	80000bcc <acquire>
    if(p->pid == pid){
    8000208a:	589c                	lw	a5,48(s1)
    8000208c:	01278b63          	beq	a5,s2,800020a2 <kkill+0x3e>
        p->state = RUNNABLE;
      }
      release(&p->lock);
      return 0;
    }
    release(&p->lock);
    80002090:	8526                	mv	a0,s1
    80002092:	bcffe0ef          	jal	80000c60 <release>
  for(p = proc; p < &proc[NPROC]; p++){
    80002096:	16848493          	addi	s1,s1,360
    8000209a:	ff3495e3          	bne	s1,s3,80002084 <kkill+0x20>
  }
  return -1;
    8000209e:	557d                	li	a0,-1
    800020a0:	a819                	j	800020b6 <kkill+0x52>
      p->killed = 1;
    800020a2:	4785                	li	a5,1
    800020a4:	d49c                	sw	a5,40(s1)
      if(p->state == SLEEPING){
    800020a6:	4c98                	lw	a4,24(s1)
    800020a8:	4789                	li	a5,2
    800020aa:	00f70d63          	beq	a4,a5,800020c4 <kkill+0x60>
      release(&p->lock);
    800020ae:	8526                	mv	a0,s1
    800020b0:	bb1fe0ef          	jal	80000c60 <release>
      return 0;
    800020b4:	4501                	li	a0,0
}
    800020b6:	70a2                	ld	ra,40(sp)
    800020b8:	7402                	ld	s0,32(sp)
    800020ba:	64e2                	ld	s1,24(sp)
    800020bc:	6942                	ld	s2,16(sp)
    800020be:	69a2                	ld	s3,8(sp)
    800020c0:	6145                	addi	sp,sp,48
    800020c2:	8082                	ret
        p->state = RUNNABLE;
    800020c4:	478d                	li	a5,3
    800020c6:	cc9c                	sw	a5,24(s1)
    800020c8:	b7dd                	j	800020ae <kkill+0x4a>

00000000800020ca <setkilled>:

void
setkilled(struct proc *p)
{
    800020ca:	1101                	addi	sp,sp,-32
    800020cc:	ec06                	sd	ra,24(sp)
    800020ce:	e822                	sd	s0,16(sp)
    800020d0:	e426                	sd	s1,8(sp)
    800020d2:	1000                	addi	s0,sp,32
    800020d4:	84aa                	mv	s1,a0
  acquire(&p->lock);
    800020d6:	af7fe0ef          	jal	80000bcc <acquire>
  p->killed = 1;
    800020da:	4785                	li	a5,1
    800020dc:	d49c                	sw	a5,40(s1)
  release(&p->lock);
    800020de:	8526                	mv	a0,s1
    800020e0:	b81fe0ef          	jal	80000c60 <release>
}
    800020e4:	60e2                	ld	ra,24(sp)
    800020e6:	6442                	ld	s0,16(sp)
    800020e8:	64a2                	ld	s1,8(sp)
    800020ea:	6105                	addi	sp,sp,32
    800020ec:	8082                	ret

00000000800020ee <killed>:

int
killed(struct proc *p)
{
    800020ee:	1101                	addi	sp,sp,-32
    800020f0:	ec06                	sd	ra,24(sp)
    800020f2:	e822                	sd	s0,16(sp)
    800020f4:	e426                	sd	s1,8(sp)
    800020f6:	e04a                	sd	s2,0(sp)
    800020f8:	1000                	addi	s0,sp,32
    800020fa:	84aa                	mv	s1,a0
  int k;
  
  acquire(&p->lock);
    800020fc:	ad1fe0ef          	jal	80000bcc <acquire>
  k = p->killed;
    80002100:	0284a903          	lw	s2,40(s1)
  release(&p->lock);
    80002104:	8526                	mv	a0,s1
    80002106:	b5bfe0ef          	jal	80000c60 <release>
  return k;
}
    8000210a:	854a                	mv	a0,s2
    8000210c:	60e2                	ld	ra,24(sp)
    8000210e:	6442                	ld	s0,16(sp)
    80002110:	64a2                	ld	s1,8(sp)
    80002112:	6902                	ld	s2,0(sp)
    80002114:	6105                	addi	sp,sp,32
    80002116:	8082                	ret

0000000080002118 <kwait>:
{
    80002118:	715d                	addi	sp,sp,-80
    8000211a:	e486                	sd	ra,72(sp)
    8000211c:	e0a2                	sd	s0,64(sp)
    8000211e:	fc26                	sd	s1,56(sp)
    80002120:	f84a                	sd	s2,48(sp)
    80002122:	f44e                	sd	s3,40(sp)
    80002124:	f052                	sd	s4,32(sp)
    80002126:	ec56                	sd	s5,24(sp)
    80002128:	e85a                	sd	s6,16(sp)
    8000212a:	e45e                	sd	s7,8(sp)
    8000212c:	0880                	addi	s0,sp,80
    8000212e:	8b2a                	mv	s6,a0
  struct proc *p = myproc();
    80002130:	f8eff0ef          	jal	800018be <myproc>
    80002134:	892a                	mv	s2,a0
  acquire(&wait_lock);
    80002136:	0000e517          	auipc	a0,0xe
    8000213a:	8aa50513          	addi	a0,a0,-1878 # 8000f9e0 <wait_lock>
    8000213e:	a8ffe0ef          	jal	80000bcc <acquire>
        if(pp->state == ZOMBIE){
    80002142:	4a15                	li	s4,5
        havekids = 1;
    80002144:	4a85                	li	s5,1
    for(pp = proc; pp < &proc[NPROC]; pp++){
    80002146:	00013997          	auipc	s3,0x13
    8000214a:	6b298993          	addi	s3,s3,1714 # 800157f8 <tickslock>
    sleep(p, &wait_lock);  //DOC: wait-sleep
    8000214e:	0000eb97          	auipc	s7,0xe
    80002152:	892b8b93          	addi	s7,s7,-1902 # 8000f9e0 <wait_lock>
    80002156:	a869                	j	800021f0 <kwait+0xd8>
          pid = pp->pid;
    80002158:	0304a983          	lw	s3,48(s1)
          if(addr != 0 && copyout(p->pagetable, addr, (char *)&pp->xstate,
    8000215c:	000b0c63          	beqz	s6,80002174 <kwait+0x5c>
    80002160:	4691                	li	a3,4
    80002162:	02c48613          	addi	a2,s1,44
    80002166:	85da                	mv	a1,s6
    80002168:	05093503          	ld	a0,80(s2)
    8000216c:	c84ff0ef          	jal	800015f0 <copyout>
    80002170:	02054a63          	bltz	a0,800021a4 <kwait+0x8c>
          freeproc(pp);
    80002174:	8526                	mv	a0,s1
    80002176:	919ff0ef          	jal	80001a8e <freeproc>
          release(&pp->lock);
    8000217a:	8526                	mv	a0,s1
    8000217c:	ae5fe0ef          	jal	80000c60 <release>
          release(&wait_lock);
    80002180:	0000e517          	auipc	a0,0xe
    80002184:	86050513          	addi	a0,a0,-1952 # 8000f9e0 <wait_lock>
    80002188:	ad9fe0ef          	jal	80000c60 <release>
}
    8000218c:	854e                	mv	a0,s3
    8000218e:	60a6                	ld	ra,72(sp)
    80002190:	6406                	ld	s0,64(sp)
    80002192:	74e2                	ld	s1,56(sp)
    80002194:	7942                	ld	s2,48(sp)
    80002196:	79a2                	ld	s3,40(sp)
    80002198:	7a02                	ld	s4,32(sp)
    8000219a:	6ae2                	ld	s5,24(sp)
    8000219c:	6b42                	ld	s6,16(sp)
    8000219e:	6ba2                	ld	s7,8(sp)
    800021a0:	6161                	addi	sp,sp,80
    800021a2:	8082                	ret
            release(&pp->lock);
    800021a4:	8526                	mv	a0,s1
    800021a6:	abbfe0ef          	jal	80000c60 <release>
            release(&wait_lock);
    800021aa:	0000e517          	auipc	a0,0xe
    800021ae:	83650513          	addi	a0,a0,-1994 # 8000f9e0 <wait_lock>
    800021b2:	aaffe0ef          	jal	80000c60 <release>
            return -1;
    800021b6:	59fd                	li	s3,-1
    800021b8:	bfd1                	j	8000218c <kwait+0x74>
    for(pp = proc; pp < &proc[NPROC]; pp++){
    800021ba:	16848493          	addi	s1,s1,360
    800021be:	03348063          	beq	s1,s3,800021de <kwait+0xc6>
      if(pp->parent == p){
    800021c2:	7c9c                	ld	a5,56(s1)
    800021c4:	ff279be3          	bne	a5,s2,800021ba <kwait+0xa2>
        acquire(&pp->lock);
    800021c8:	8526                	mv	a0,s1
    800021ca:	a03fe0ef          	jal	80000bcc <acquire>
        if(pp->state == ZOMBIE){
    800021ce:	4c9c                	lw	a5,24(s1)
    800021d0:	f94784e3          	beq	a5,s4,80002158 <kwait+0x40>
        release(&pp->lock);
    800021d4:	8526                	mv	a0,s1
    800021d6:	a8bfe0ef          	jal	80000c60 <release>
        havekids = 1;
    800021da:	8756                	mv	a4,s5
    800021dc:	bff9                	j	800021ba <kwait+0xa2>
    if(!havekids || killed(p)){
    800021de:	cf19                	beqz	a4,800021fc <kwait+0xe4>
    800021e0:	854a                	mv	a0,s2
    800021e2:	f0dff0ef          	jal	800020ee <killed>
    800021e6:	e919                	bnez	a0,800021fc <kwait+0xe4>
    sleep(p, &wait_lock);  //DOC: wait-sleep
    800021e8:	85de                	mv	a1,s7
    800021ea:	854a                	mv	a0,s2
    800021ec:	ccbff0ef          	jal	80001eb6 <sleep>
    havekids = 0;
    800021f0:	4701                	li	a4,0
    for(pp = proc; pp < &proc[NPROC]; pp++){
    800021f2:	0000e497          	auipc	s1,0xe
    800021f6:	c0648493          	addi	s1,s1,-1018 # 8000fdf8 <proc>
    800021fa:	b7e1                	j	800021c2 <kwait+0xaa>
      release(&wait_lock);
    800021fc:	0000d517          	auipc	a0,0xd
    80002200:	7e450513          	addi	a0,a0,2020 # 8000f9e0 <wait_lock>
    80002204:	a5dfe0ef          	jal	80000c60 <release>
      return -1;
    80002208:	59fd                	li	s3,-1
    8000220a:	b749                	j	8000218c <kwait+0x74>

000000008000220c <either_copyout>:
// Copy to either a user address, or kernel address,
// depending on usr_dst.
// Returns 0 on success, -1 on error.
int
either_copyout(int user_dst, uint64 dst, void *src, uint64 len)
{
    8000220c:	7179                	addi	sp,sp,-48
    8000220e:	f406                	sd	ra,40(sp)
    80002210:	f022                	sd	s0,32(sp)
    80002212:	ec26                	sd	s1,24(sp)
    80002214:	e84a                	sd	s2,16(sp)
    80002216:	e44e                	sd	s3,8(sp)
    80002218:	e052                	sd	s4,0(sp)
    8000221a:	1800                	addi	s0,sp,48
    8000221c:	84aa                	mv	s1,a0
    8000221e:	892e                	mv	s2,a1
    80002220:	89b2                	mv	s3,a2
    80002222:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    80002224:	e9aff0ef          	jal	800018be <myproc>
  if(user_dst){
    80002228:	cc99                	beqz	s1,80002246 <either_copyout+0x3a>
    return copyout(p->pagetable, dst, src, len);
    8000222a:	86d2                	mv	a3,s4
    8000222c:	864e                	mv	a2,s3
    8000222e:	85ca                	mv	a1,s2
    80002230:	6928                	ld	a0,80(a0)
    80002232:	bbeff0ef          	jal	800015f0 <copyout>
  } else {
    memmove((char *)dst, src, len);
    return 0;
  }
}
    80002236:	70a2                	ld	ra,40(sp)
    80002238:	7402                	ld	s0,32(sp)
    8000223a:	64e2                	ld	s1,24(sp)
    8000223c:	6942                	ld	s2,16(sp)
    8000223e:	69a2                	ld	s3,8(sp)
    80002240:	6a02                	ld	s4,0(sp)
    80002242:	6145                	addi	sp,sp,48
    80002244:	8082                	ret
    memmove((char *)dst, src, len);
    80002246:	000a061b          	sext.w	a2,s4
    8000224a:	85ce                	mv	a1,s3
    8000224c:	854a                	mv	a0,s2
    8000224e:	ab3fe0ef          	jal	80000d00 <memmove>
    return 0;
    80002252:	8526                	mv	a0,s1
    80002254:	b7cd                	j	80002236 <either_copyout+0x2a>

0000000080002256 <either_copyin>:
// Copy from either a user address, or kernel address,
// depending on usr_src.
// Returns 0 on success, -1 on error.
int
either_copyin(void *dst, int user_src, uint64 src, uint64 len)
{
    80002256:	7179                	addi	sp,sp,-48
    80002258:	f406                	sd	ra,40(sp)
    8000225a:	f022                	sd	s0,32(sp)
    8000225c:	ec26                	sd	s1,24(sp)
    8000225e:	e84a                	sd	s2,16(sp)
    80002260:	e44e                	sd	s3,8(sp)
    80002262:	e052                	sd	s4,0(sp)
    80002264:	1800                	addi	s0,sp,48
    80002266:	892a                	mv	s2,a0
    80002268:	84ae                	mv	s1,a1
    8000226a:	89b2                	mv	s3,a2
    8000226c:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    8000226e:	e50ff0ef          	jal	800018be <myproc>
  if(user_src){
    80002272:	cc99                	beqz	s1,80002290 <either_copyin+0x3a>
    return copyin(p->pagetable, dst, src, len);
    80002274:	86d2                	mv	a3,s4
    80002276:	864e                	mv	a2,s3
    80002278:	85ca                	mv	a1,s2
    8000227a:	6928                	ld	a0,80(a0)
    8000227c:	c32ff0ef          	jal	800016ae <copyin>
  } else {
    memmove(dst, (char*)src, len);
    return 0;
  }
}
    80002280:	70a2                	ld	ra,40(sp)
    80002282:	7402                	ld	s0,32(sp)
    80002284:	64e2                	ld	s1,24(sp)
    80002286:	6942                	ld	s2,16(sp)
    80002288:	69a2                	ld	s3,8(sp)
    8000228a:	6a02                	ld	s4,0(sp)
    8000228c:	6145                	addi	sp,sp,48
    8000228e:	8082                	ret
    memmove(dst, (char*)src, len);
    80002290:	000a061b          	sext.w	a2,s4
    80002294:	85ce                	mv	a1,s3
    80002296:	854a                	mv	a0,s2
    80002298:	a69fe0ef          	jal	80000d00 <memmove>
    return 0;
    8000229c:	8526                	mv	a0,s1
    8000229e:	b7cd                	j	80002280 <either_copyin+0x2a>

00000000800022a0 <procdump>:
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
    800022a0:	715d                	addi	sp,sp,-80
    800022a2:	e486                	sd	ra,72(sp)
    800022a4:	e0a2                	sd	s0,64(sp)
    800022a6:	fc26                	sd	s1,56(sp)
    800022a8:	f84a                	sd	s2,48(sp)
    800022aa:	f44e                	sd	s3,40(sp)
    800022ac:	f052                	sd	s4,32(sp)
    800022ae:	ec56                	sd	s5,24(sp)
    800022b0:	e85a                	sd	s6,16(sp)
    800022b2:	e45e                	sd	s7,8(sp)
    800022b4:	0880                	addi	s0,sp,80
  [ZOMBIE]    "zombie"
  };
  struct proc *p;
  char *state;

  printf("\n");
    800022b6:	00005517          	auipc	a0,0x5
    800022ba:	dc250513          	addi	a0,a0,-574 # 80007078 <etext+0x78>
    800022be:	a3cfe0ef          	jal	800004fa <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    800022c2:	0000e497          	auipc	s1,0xe
    800022c6:	c8e48493          	addi	s1,s1,-882 # 8000ff50 <proc+0x158>
    800022ca:	00013917          	auipc	s2,0x13
    800022ce:	68690913          	addi	s2,s2,1670 # 80015950 <bcache+0x140>
    if(p->state == UNUSED)
      continue;
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    800022d2:	4b15                	li	s6,5
      state = states[p->state];
    else
      state = "???";
    800022d4:	00005997          	auipc	s3,0x5
    800022d8:	f2c98993          	addi	s3,s3,-212 # 80007200 <etext+0x200>
    printf("%d %s %s", p->pid, state, p->name);
    800022dc:	00005a97          	auipc	s5,0x5
    800022e0:	f2ca8a93          	addi	s5,s5,-212 # 80007208 <etext+0x208>
    printf("\n");
    800022e4:	00005a17          	auipc	s4,0x5
    800022e8:	d94a0a13          	addi	s4,s4,-620 # 80007078 <etext+0x78>
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    800022ec:	00005b97          	auipc	s7,0x5
    800022f0:	49cb8b93          	addi	s7,s7,1180 # 80007788 <states.0>
    800022f4:	a829                	j	8000230e <procdump+0x6e>
    printf("%d %s %s", p->pid, state, p->name);
    800022f6:	ed86a583          	lw	a1,-296(a3)
    800022fa:	8556                	mv	a0,s5
    800022fc:	9fefe0ef          	jal	800004fa <printf>
    printf("\n");
    80002300:	8552                	mv	a0,s4
    80002302:	9f8fe0ef          	jal	800004fa <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    80002306:	16848493          	addi	s1,s1,360
    8000230a:	03248263          	beq	s1,s2,8000232e <procdump+0x8e>
    if(p->state == UNUSED)
    8000230e:	86a6                	mv	a3,s1
    80002310:	ec04a783          	lw	a5,-320(s1)
    80002314:	dbed                	beqz	a5,80002306 <procdump+0x66>
      state = "???";
    80002316:	864e                	mv	a2,s3
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80002318:	fcfb6fe3          	bltu	s6,a5,800022f6 <procdump+0x56>
    8000231c:	02079713          	slli	a4,a5,0x20
    80002320:	01d75793          	srli	a5,a4,0x1d
    80002324:	97de                	add	a5,a5,s7
    80002326:	6390                	ld	a2,0(a5)
    80002328:	f679                	bnez	a2,800022f6 <procdump+0x56>
      state = "???";
    8000232a:	864e                	mv	a2,s3
    8000232c:	b7e9                	j	800022f6 <procdump+0x56>
  }
}
    8000232e:	60a6                	ld	ra,72(sp)
    80002330:	6406                	ld	s0,64(sp)
    80002332:	74e2                	ld	s1,56(sp)
    80002334:	7942                	ld	s2,48(sp)
    80002336:	79a2                	ld	s3,40(sp)
    80002338:	7a02                	ld	s4,32(sp)
    8000233a:	6ae2                	ld	s5,24(sp)
    8000233c:	6b42                	ld	s6,16(sp)
    8000233e:	6ba2                	ld	s7,8(sp)
    80002340:	6161                	addi	sp,sp,80
    80002342:	8082                	ret

0000000080002344 <get_proc_info>:

int get_proc_info(int pid, struct proc_info *info) {
    80002344:	7179                	addi	sp,sp,-48
    80002346:	f406                	sd	ra,40(sp)
    80002348:	f022                	sd	s0,32(sp)
    8000234a:	ec26                	sd	s1,24(sp)
    8000234c:	e84a                	sd	s2,16(sp)
    8000234e:	e44e                	sd	s3,8(sp)
    80002350:	e052                	sd	s4,0(sp)
    80002352:	1800                	addi	s0,sp,48
    80002354:	892a                	mv	s2,a0
    80002356:	8a2e                	mv	s4,a1
    struct proc *p;

    for(p = proc; p < &proc[NPROC]; p++){
    80002358:	0000e497          	auipc	s1,0xe
    8000235c:	aa048493          	addi	s1,s1,-1376 # 8000fdf8 <proc>
    80002360:	00013997          	auipc	s3,0x13
    80002364:	49898993          	addi	s3,s3,1176 # 800157f8 <tickslock>
        acquire(&p->lock);
    80002368:	8526                	mv	a0,s1
    8000236a:	863fe0ef          	jal	80000bcc <acquire>
        if(p->pid == pid){
    8000236e:	589c                	lw	a5,48(s1)
    80002370:	01278b63          	beq	a5,s2,80002386 <get_proc_info+0x42>
            info->sz = p->sz;

            release(&p->lock);
            return 0;
        }
        release(&p->lock);
    80002374:	8526                	mv	a0,s1
    80002376:	8ebfe0ef          	jal	80000c60 <release>
    for(p = proc; p < &proc[NPROC]; p++){
    8000237a:	16848493          	addi	s1,s1,360
    8000237e:	ff3495e3          	bne	s1,s3,80002368 <get_proc_info+0x24>
    }
    return -1; // Not found
    80002382:	557d                	li	a0,-1
    80002384:	a079                	j	80002412 <get_proc_info+0xce>
            info->pid = p->pid;
    80002386:	00fa2023          	sw	a5,0(s4)
            safestrcpy(info->name, p->name, sizeof(info->name));
    8000238a:	4641                	li	a2,16
    8000238c:	15848593          	addi	a1,s1,344
    80002390:	004a0513          	addi	a0,s4,4
    80002394:	a5bfe0ef          	jal	80000dee <safestrcpy>
            switch(p->state){
    80002398:	4c98                	lw	a4,24(s1)
    8000239a:	4795                	li	a5,5
    8000239c:	00e7ed63          	bltu	a5,a4,800023b6 <get_proc_info+0x72>
    800023a0:	0184e783          	lwu	a5,24(s1)
    800023a4:	078a                	slli	a5,a5,0x2
    800023a6:	00005717          	auipc	a4,0x5
    800023aa:	3ca70713          	addi	a4,a4,970 # 80007770 <digits+0x18>
    800023ae:	97ba                	add	a5,a5,a4
    800023b0:	439c                	lw	a5,0(a5)
    800023b2:	97ba                	add	a5,a5,a4
    800023b4:	8782                	jr	a5
            char *st = "UNKNOWN";
    800023b6:	00005597          	auipc	a1,0x5
    800023ba:	e6258593          	addi	a1,a1,-414 # 80007218 <etext+0x218>
    800023be:	a835                	j	800023fa <get_proc_info+0xb6>
                case USED:     st = "USED"; break;
    800023c0:	00005597          	auipc	a1,0x5
    800023c4:	e6858593          	addi	a1,a1,-408 # 80007228 <etext+0x228>
    800023c8:	a80d                	j	800023fa <get_proc_info+0xb6>
                case SLEEPING: st = "SLEEPING"; break;
    800023ca:	00005597          	auipc	a1,0x5
    800023ce:	e6658593          	addi	a1,a1,-410 # 80007230 <etext+0x230>
    800023d2:	a025                	j	800023fa <get_proc_info+0xb6>
                case RUNNABLE: st = "RUNNABLE"; break;
    800023d4:	00005597          	auipc	a1,0x5
    800023d8:	e6c58593          	addi	a1,a1,-404 # 80007240 <etext+0x240>
    800023dc:	a839                	j	800023fa <get_proc_info+0xb6>
                case RUNNING:  st = "RUNNING"; break;
    800023de:	00005597          	auipc	a1,0x5
    800023e2:	e7258593          	addi	a1,a1,-398 # 80007250 <etext+0x250>
    800023e6:	a811                	j	800023fa <get_proc_info+0xb6>
                case ZOMBIE:   st = "ZOMBIE"; break;
    800023e8:	00005597          	auipc	a1,0x5
    800023ec:	e7058593          	addi	a1,a1,-400 # 80007258 <etext+0x258>
    800023f0:	a029                	j	800023fa <get_proc_info+0xb6>
            switch(p->state){
    800023f2:	00005597          	auipc	a1,0x5
    800023f6:	e2e58593          	addi	a1,a1,-466 # 80007220 <etext+0x220>
            safestrcpy(info->state, st, sizeof(info->state));
    800023fa:	4641                	li	a2,16
    800023fc:	014a0513          	addi	a0,s4,20
    80002400:	9effe0ef          	jal	80000dee <safestrcpy>
            info->sz = p->sz;
    80002404:	64bc                	ld	a5,72(s1)
    80002406:	02fa3423          	sd	a5,40(s4)
            release(&p->lock);
    8000240a:	8526                	mv	a0,s1
    8000240c:	855fe0ef          	jal	80000c60 <release>
            return 0;
    80002410:	4501                	li	a0,0
}
    80002412:	70a2                	ld	ra,40(sp)
    80002414:	7402                	ld	s0,32(sp)
    80002416:	64e2                	ld	s1,24(sp)
    80002418:	6942                	ld	s2,16(sp)
    8000241a:	69a2                	ld	s3,8(sp)
    8000241c:	6a02                	ld	s4,0(sp)
    8000241e:	6145                	addi	sp,sp,48
    80002420:	8082                	ret

0000000080002422 <swtch>:
# Save current registers in old. Load from new.	


.globl swtch
swtch:
        sd ra, 0(a0)
    80002422:	00153023          	sd	ra,0(a0)
        sd sp, 8(a0)
    80002426:	00253423          	sd	sp,8(a0)
        sd s0, 16(a0)
    8000242a:	e900                	sd	s0,16(a0)
        sd s1, 24(a0)
    8000242c:	ed04                	sd	s1,24(a0)
        sd s2, 32(a0)
    8000242e:	03253023          	sd	s2,32(a0)
        sd s3, 40(a0)
    80002432:	03353423          	sd	s3,40(a0)
        sd s4, 48(a0)
    80002436:	03453823          	sd	s4,48(a0)
        sd s5, 56(a0)
    8000243a:	03553c23          	sd	s5,56(a0)
        sd s6, 64(a0)
    8000243e:	05653023          	sd	s6,64(a0)
        sd s7, 72(a0)
    80002442:	05753423          	sd	s7,72(a0)
        sd s8, 80(a0)
    80002446:	05853823          	sd	s8,80(a0)
        sd s9, 88(a0)
    8000244a:	05953c23          	sd	s9,88(a0)
        sd s10, 96(a0)
    8000244e:	07a53023          	sd	s10,96(a0)
        sd s11, 104(a0)
    80002452:	07b53423          	sd	s11,104(a0)

        ld ra, 0(a1)
    80002456:	0005b083          	ld	ra,0(a1)
        ld sp, 8(a1)
    8000245a:	0085b103          	ld	sp,8(a1)
        ld s0, 16(a1)
    8000245e:	6980                	ld	s0,16(a1)
        ld s1, 24(a1)
    80002460:	6d84                	ld	s1,24(a1)
        ld s2, 32(a1)
    80002462:	0205b903          	ld	s2,32(a1)
        ld s3, 40(a1)
    80002466:	0285b983          	ld	s3,40(a1)
        ld s4, 48(a1)
    8000246a:	0305ba03          	ld	s4,48(a1)
        ld s5, 56(a1)
    8000246e:	0385ba83          	ld	s5,56(a1)
        ld s6, 64(a1)
    80002472:	0405bb03          	ld	s6,64(a1)
        ld s7, 72(a1)
    80002476:	0485bb83          	ld	s7,72(a1)
        ld s8, 80(a1)
    8000247a:	0505bc03          	ld	s8,80(a1)
        ld s9, 88(a1)
    8000247e:	0585bc83          	ld	s9,88(a1)
        ld s10, 96(a1)
    80002482:	0605bd03          	ld	s10,96(a1)
        ld s11, 104(a1)
    80002486:	0685bd83          	ld	s11,104(a1)
        
        ret
    8000248a:	8082                	ret

000000008000248c <trapinit>:

extern int devintr();

void
trapinit(void)
{
    8000248c:	1141                	addi	sp,sp,-16
    8000248e:	e406                	sd	ra,8(sp)
    80002490:	e022                	sd	s0,0(sp)
    80002492:	0800                	addi	s0,sp,16
  initlock(&tickslock, "time");
    80002494:	00005597          	auipc	a1,0x5
    80002498:	dfc58593          	addi	a1,a1,-516 # 80007290 <etext+0x290>
    8000249c:	00013517          	auipc	a0,0x13
    800024a0:	35c50513          	addi	a0,a0,860 # 800157f8 <tickslock>
    800024a4:	ea4fe0ef          	jal	80000b48 <initlock>
}
    800024a8:	60a2                	ld	ra,8(sp)
    800024aa:	6402                	ld	s0,0(sp)
    800024ac:	0141                	addi	sp,sp,16
    800024ae:	8082                	ret

00000000800024b0 <trapinithart>:

// set up to take exceptions and traps while in the kernel.
void
trapinithart(void)
{
    800024b0:	1141                	addi	sp,sp,-16
    800024b2:	e406                	sd	ra,8(sp)
    800024b4:	e022                	sd	s0,0(sp)
    800024b6:	0800                	addi	s0,sp,16
  asm volatile("csrw stvec, %0" : : "r" (x));
    800024b8:	00003797          	auipc	a5,0x3
    800024bc:	fb878793          	addi	a5,a5,-72 # 80005470 <kernelvec>
    800024c0:	10579073          	csrw	stvec,a5
  w_stvec((uint64)kernelvec);
}
    800024c4:	60a2                	ld	ra,8(sp)
    800024c6:	6402                	ld	s0,0(sp)
    800024c8:	0141                	addi	sp,sp,16
    800024ca:	8082                	ret

00000000800024cc <prepare_return>:
//
// set up trapframe and control registers for a return to user space
//
void
prepare_return(void)
{
    800024cc:	1141                	addi	sp,sp,-16
    800024ce:	e406                	sd	ra,8(sp)
    800024d0:	e022                	sd	s0,0(sp)
    800024d2:	0800                	addi	s0,sp,16
  struct proc *p = myproc();
    800024d4:	beaff0ef          	jal	800018be <myproc>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800024d8:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    800024dc:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    800024de:	10079073          	csrw	sstatus,a5
  // kerneltrap() to usertrap(). because a trap from kernel
  // code to usertrap would be a disaster, turn off interrupts.
  intr_off();

  // send syscalls, interrupts, and exceptions to uservec in trampoline.S
  uint64 trampoline_uservec = TRAMPOLINE + (uservec - trampoline);
    800024e2:	04000737          	lui	a4,0x4000
    800024e6:	177d                	addi	a4,a4,-1 # 3ffffff <_entry-0x7c000001>
    800024e8:	0732                	slli	a4,a4,0xc
    800024ea:	00004797          	auipc	a5,0x4
    800024ee:	b1678793          	addi	a5,a5,-1258 # 80006000 <_trampoline>
    800024f2:	00004697          	auipc	a3,0x4
    800024f6:	b0e68693          	addi	a3,a3,-1266 # 80006000 <_trampoline>
    800024fa:	8f95                	sub	a5,a5,a3
    800024fc:	97ba                	add	a5,a5,a4
  asm volatile("csrw stvec, %0" : : "r" (x));
    800024fe:	10579073          	csrw	stvec,a5
  w_stvec(trampoline_uservec);

  // set up trapframe values that uservec will need when
  // the process next traps into the kernel.
  p->trapframe->kernel_satp = r_satp();         // kernel page table
    80002502:	6d3c                	ld	a5,88(a0)
  asm volatile("csrr %0, satp" : "=r" (x) );
    80002504:	18002773          	csrr	a4,satp
    80002508:	e398                	sd	a4,0(a5)
  p->trapframe->kernel_sp = p->kstack + PGSIZE; // process's kernel stack
    8000250a:	6d38                	ld	a4,88(a0)
    8000250c:	613c                	ld	a5,64(a0)
    8000250e:	6685                	lui	a3,0x1
    80002510:	97b6                	add	a5,a5,a3
    80002512:	e71c                	sd	a5,8(a4)
  p->trapframe->kernel_trap = (uint64)usertrap;
    80002514:	6d3c                	ld	a5,88(a0)
    80002516:	00000717          	auipc	a4,0x0
    8000251a:	0f870713          	addi	a4,a4,248 # 8000260e <usertrap>
    8000251e:	eb98                	sd	a4,16(a5)
  p->trapframe->kernel_hartid = r_tp();         // hartid for cpuid()
    80002520:	6d3c                	ld	a5,88(a0)
  asm volatile("mv %0, tp" : "=r" (x) );
    80002522:	8712                	mv	a4,tp
    80002524:	f398                	sd	a4,32(a5)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002526:	100027f3          	csrr	a5,sstatus
  // set up the registers that trampoline.S's sret will use
  // to get to user space.
  
  // set S Previous Privilege mode to User.
  unsigned long x = r_sstatus();
  x &= ~SSTATUS_SPP; // clear SPP to 0 for user mode
    8000252a:	eff7f793          	andi	a5,a5,-257
  x |= SSTATUS_SPIE; // enable interrupts in user mode
    8000252e:	0207e793          	ori	a5,a5,32
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002532:	10079073          	csrw	sstatus,a5
  w_sstatus(x);

  // set S Exception Program Counter to the saved user pc.
  w_sepc(p->trapframe->epc);
    80002536:	6d3c                	ld	a5,88(a0)
  asm volatile("csrw sepc, %0" : : "r" (x));
    80002538:	6f9c                	ld	a5,24(a5)
    8000253a:	14179073          	csrw	sepc,a5
}
    8000253e:	60a2                	ld	ra,8(sp)
    80002540:	6402                	ld	s0,0(sp)
    80002542:	0141                	addi	sp,sp,16
    80002544:	8082                	ret

0000000080002546 <clockintr>:
  w_sstatus(sstatus);
}

void
clockintr()
{
    80002546:	1101                	addi	sp,sp,-32
    80002548:	ec06                	sd	ra,24(sp)
    8000254a:	e822                	sd	s0,16(sp)
    8000254c:	1000                	addi	s0,sp,32
  if(cpuid() == 0){
    8000254e:	b3cff0ef          	jal	8000188a <cpuid>
    80002552:	cd11                	beqz	a0,8000256e <clockintr+0x28>
  asm volatile("csrr %0, time" : "=r" (x) );
    80002554:	c01027f3          	rdtime	a5
  }

  // ask for the next timer interrupt. this also clears
  // the interrupt request. 1000000 is about a tenth
  // of a second.
  w_stimecmp(r_time() + 1000000);
    80002558:	000f4737          	lui	a4,0xf4
    8000255c:	24070713          	addi	a4,a4,576 # f4240 <_entry-0x7ff0bdc0>
    80002560:	97ba                	add	a5,a5,a4
  asm volatile("csrw 0x14d, %0" : : "r" (x));
    80002562:	14d79073          	csrw	stimecmp,a5
}
    80002566:	60e2                	ld	ra,24(sp)
    80002568:	6442                	ld	s0,16(sp)
    8000256a:	6105                	addi	sp,sp,32
    8000256c:	8082                	ret
    8000256e:	e426                	sd	s1,8(sp)
    acquire(&tickslock);
    80002570:	00013497          	auipc	s1,0x13
    80002574:	28848493          	addi	s1,s1,648 # 800157f8 <tickslock>
    80002578:	8526                	mv	a0,s1
    8000257a:	e52fe0ef          	jal	80000bcc <acquire>
    ticks++;
    8000257e:	00005517          	auipc	a0,0x5
    80002582:	34a50513          	addi	a0,a0,842 # 800078c8 <ticks>
    80002586:	411c                	lw	a5,0(a0)
    80002588:	2785                	addiw	a5,a5,1
    8000258a:	c11c                	sw	a5,0(a0)
    wakeup(&ticks);
    8000258c:	977ff0ef          	jal	80001f02 <wakeup>
    release(&tickslock);
    80002590:	8526                	mv	a0,s1
    80002592:	ecefe0ef          	jal	80000c60 <release>
    80002596:	64a2                	ld	s1,8(sp)
    80002598:	bf75                	j	80002554 <clockintr+0xe>

000000008000259a <devintr>:
// returns 2 if timer interrupt,
// 1 if other device,
// 0 if not recognized.
int
devintr()
{
    8000259a:	1101                	addi	sp,sp,-32
    8000259c:	ec06                	sd	ra,24(sp)
    8000259e:	e822                	sd	s0,16(sp)
    800025a0:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, scause" : "=r" (x) );
    800025a2:	14202773          	csrr	a4,scause
  uint64 scause = r_scause();

  if(scause == 0x8000000000000009L){
    800025a6:	57fd                	li	a5,-1
    800025a8:	17fe                	slli	a5,a5,0x3f
    800025aa:	07a5                	addi	a5,a5,9
    800025ac:	00f70c63          	beq	a4,a5,800025c4 <devintr+0x2a>
    // now allowed to interrupt again.
    if(irq)
      plic_complete(irq);

    return 1;
  } else if(scause == 0x8000000000000005L){
    800025b0:	57fd                	li	a5,-1
    800025b2:	17fe                	slli	a5,a5,0x3f
    800025b4:	0795                	addi	a5,a5,5
    // timer interrupt.
    clockintr();
    return 2;
  } else {
    return 0;
    800025b6:	4501                	li	a0,0
  } else if(scause == 0x8000000000000005L){
    800025b8:	04f70763          	beq	a4,a5,80002606 <devintr+0x6c>
  }
}
    800025bc:	60e2                	ld	ra,24(sp)
    800025be:	6442                	ld	s0,16(sp)
    800025c0:	6105                	addi	sp,sp,32
    800025c2:	8082                	ret
    800025c4:	e426                	sd	s1,8(sp)
    int irq = plic_claim();
    800025c6:	757020ef          	jal	8000551c <plic_claim>
    800025ca:	84aa                	mv	s1,a0
    if(irq == UART0_IRQ){
    800025cc:	47a9                	li	a5,10
    800025ce:	00f50963          	beq	a0,a5,800025e0 <devintr+0x46>
    } else if(irq == VIRTIO0_IRQ){
    800025d2:	4785                	li	a5,1
    800025d4:	00f50963          	beq	a0,a5,800025e6 <devintr+0x4c>
    return 1;
    800025d8:	4505                	li	a0,1
    } else if(irq){
    800025da:	e889                	bnez	s1,800025ec <devintr+0x52>
    800025dc:	64a2                	ld	s1,8(sp)
    800025de:	bff9                	j	800025bc <devintr+0x22>
      uartintr();
    800025e0:	bcefe0ef          	jal	800009ae <uartintr>
    if(irq)
    800025e4:	a819                	j	800025fa <devintr+0x60>
      virtio_disk_intr();
    800025e6:	3c6030ef          	jal	800059ac <virtio_disk_intr>
    if(irq)
    800025ea:	a801                	j	800025fa <devintr+0x60>
      printf("unexpected interrupt irq=%d\n", irq);
    800025ec:	85a6                	mv	a1,s1
    800025ee:	00005517          	auipc	a0,0x5
    800025f2:	caa50513          	addi	a0,a0,-854 # 80007298 <etext+0x298>
    800025f6:	f05fd0ef          	jal	800004fa <printf>
      plic_complete(irq);
    800025fa:	8526                	mv	a0,s1
    800025fc:	741020ef          	jal	8000553c <plic_complete>
    return 1;
    80002600:	4505                	li	a0,1
    80002602:	64a2                	ld	s1,8(sp)
    80002604:	bf65                	j	800025bc <devintr+0x22>
    clockintr();
    80002606:	f41ff0ef          	jal	80002546 <clockintr>
    return 2;
    8000260a:	4509                	li	a0,2
    8000260c:	bf45                	j	800025bc <devintr+0x22>

000000008000260e <usertrap>:
{
    8000260e:	1101                	addi	sp,sp,-32
    80002610:	ec06                	sd	ra,24(sp)
    80002612:	e822                	sd	s0,16(sp)
    80002614:	e426                	sd	s1,8(sp)
    80002616:	e04a                	sd	s2,0(sp)
    80002618:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    8000261a:	100027f3          	csrr	a5,sstatus
  if((r_sstatus() & SSTATUS_SPP) != 0)
    8000261e:	1007f793          	andi	a5,a5,256
    80002622:	eba5                	bnez	a5,80002692 <usertrap+0x84>
  asm volatile("csrw stvec, %0" : : "r" (x));
    80002624:	00003797          	auipc	a5,0x3
    80002628:	e4c78793          	addi	a5,a5,-436 # 80005470 <kernelvec>
    8000262c:	10579073          	csrw	stvec,a5
  struct proc *p = myproc();
    80002630:	a8eff0ef          	jal	800018be <myproc>
    80002634:	84aa                	mv	s1,a0
  p->trapframe->epc = r_sepc();
    80002636:	6d3c                	ld	a5,88(a0)
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002638:	14102773          	csrr	a4,sepc
    8000263c:	ef98                	sd	a4,24(a5)
  asm volatile("csrr %0, scause" : "=r" (x) );
    8000263e:	14202773          	csrr	a4,scause
  if(r_scause() == 8){
    80002642:	47a1                	li	a5,8
    80002644:	04f70d63          	beq	a4,a5,8000269e <usertrap+0x90>
  } else if((which_dev = devintr()) != 0){
    80002648:	f53ff0ef          	jal	8000259a <devintr>
    8000264c:	892a                	mv	s2,a0
    8000264e:	e945                	bnez	a0,800026fe <usertrap+0xf0>
    80002650:	14202773          	csrr	a4,scause
  } else if((r_scause() == 15 || r_scause() == 13) &&
    80002654:	47bd                	li	a5,15
    80002656:	08f70863          	beq	a4,a5,800026e6 <usertrap+0xd8>
    8000265a:	14202773          	csrr	a4,scause
    8000265e:	47b5                	li	a5,13
    80002660:	08f70363          	beq	a4,a5,800026e6 <usertrap+0xd8>
    80002664:	142025f3          	csrr	a1,scause
    printf("usertrap(): unexpected scause 0x%lx pid=%d\n", r_scause(), p->pid);
    80002668:	5890                	lw	a2,48(s1)
    8000266a:	00005517          	auipc	a0,0x5
    8000266e:	c6e50513          	addi	a0,a0,-914 # 800072d8 <etext+0x2d8>
    80002672:	e89fd0ef          	jal	800004fa <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002676:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    8000267a:	14302673          	csrr	a2,stval
    printf("            sepc=0x%lx stval=0x%lx\n", r_sepc(), r_stval());
    8000267e:	00005517          	auipc	a0,0x5
    80002682:	c8a50513          	addi	a0,a0,-886 # 80007308 <etext+0x308>
    80002686:	e75fd0ef          	jal	800004fa <printf>
    setkilled(p);
    8000268a:	8526                	mv	a0,s1
    8000268c:	a3fff0ef          	jal	800020ca <setkilled>
    80002690:	a035                	j	800026bc <usertrap+0xae>
    panic("usertrap: not from user mode");
    80002692:	00005517          	auipc	a0,0x5
    80002696:	c2650513          	addi	a0,a0,-986 # 800072b8 <etext+0x2b8>
    8000269a:	944fe0ef          	jal	800007de <panic>
    if(killed(p))
    8000269e:	a51ff0ef          	jal	800020ee <killed>
    800026a2:	ed15                	bnez	a0,800026de <usertrap+0xd0>
    p->trapframe->epc += 4;
    800026a4:	6cb8                	ld	a4,88(s1)
    800026a6:	6f1c                	ld	a5,24(a4)
    800026a8:	0791                	addi	a5,a5,4
    800026aa:	ef1c                	sd	a5,24(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800026ac:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    800026b0:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    800026b4:	10079073          	csrw	sstatus,a5
    syscall();
    800026b8:	23e000ef          	jal	800028f6 <syscall>
  if(killed(p))
    800026bc:	8526                	mv	a0,s1
    800026be:	a31ff0ef          	jal	800020ee <killed>
    800026c2:	e139                	bnez	a0,80002708 <usertrap+0xfa>
  prepare_return();
    800026c4:	e09ff0ef          	jal	800024cc <prepare_return>
  uint64 satp = MAKE_SATP(p->pagetable);
    800026c8:	68a8                	ld	a0,80(s1)
    800026ca:	8131                	srli	a0,a0,0xc
    800026cc:	57fd                	li	a5,-1
    800026ce:	17fe                	slli	a5,a5,0x3f
    800026d0:	8d5d                	or	a0,a0,a5
}
    800026d2:	60e2                	ld	ra,24(sp)
    800026d4:	6442                	ld	s0,16(sp)
    800026d6:	64a2                	ld	s1,8(sp)
    800026d8:	6902                	ld	s2,0(sp)
    800026da:	6105                	addi	sp,sp,32
    800026dc:	8082                	ret
      kexit(-1);
    800026de:	557d                	li	a0,-1
    800026e0:	8e3ff0ef          	jal	80001fc2 <kexit>
    800026e4:	b7c1                	j	800026a4 <usertrap+0x96>
  asm volatile("csrr %0, stval" : "=r" (x) );
    800026e6:	143025f3          	csrr	a1,stval
  asm volatile("csrr %0, scause" : "=r" (x) );
    800026ea:	14202673          	csrr	a2,scause
            vmfault(p->pagetable, r_stval(), (r_scause() == 13)? 1 : 0) != 0) {
    800026ee:	164d                	addi	a2,a2,-13 # ff3 <_entry-0x7ffff00d>
    800026f0:	00163613          	seqz	a2,a2
    800026f4:	68a8                	ld	a0,80(s1)
    800026f6:	e79fe0ef          	jal	8000156e <vmfault>
  } else if((r_scause() == 15 || r_scause() == 13) &&
    800026fa:	f169                	bnez	a0,800026bc <usertrap+0xae>
    800026fc:	b7a5                	j	80002664 <usertrap+0x56>
  if(killed(p))
    800026fe:	8526                	mv	a0,s1
    80002700:	9efff0ef          	jal	800020ee <killed>
    80002704:	c511                	beqz	a0,80002710 <usertrap+0x102>
    80002706:	a011                	j	8000270a <usertrap+0xfc>
    80002708:	4901                	li	s2,0
    kexit(-1);
    8000270a:	557d                	li	a0,-1
    8000270c:	8b7ff0ef          	jal	80001fc2 <kexit>
  if(which_dev == 2)
    80002710:	4789                	li	a5,2
    80002712:	faf919e3          	bne	s2,a5,800026c4 <usertrap+0xb6>
    yield();
    80002716:	f74ff0ef          	jal	80001e8a <yield>
    8000271a:	b76d                	j	800026c4 <usertrap+0xb6>

000000008000271c <kerneltrap>:
{
    8000271c:	7179                	addi	sp,sp,-48
    8000271e:	f406                	sd	ra,40(sp)
    80002720:	f022                	sd	s0,32(sp)
    80002722:	ec26                	sd	s1,24(sp)
    80002724:	e84a                	sd	s2,16(sp)
    80002726:	e44e                	sd	s3,8(sp)
    80002728:	1800                	addi	s0,sp,48
  asm volatile("csrr %0, sepc" : "=r" (x) );
    8000272a:	14102973          	csrr	s2,sepc
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    8000272e:	100024f3          	csrr	s1,sstatus
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002732:	142029f3          	csrr	s3,scause
  if((sstatus & SSTATUS_SPP) == 0)
    80002736:	1004f793          	andi	a5,s1,256
    8000273a:	c795                	beqz	a5,80002766 <kerneltrap+0x4a>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    8000273c:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80002740:	8b89                	andi	a5,a5,2
  if(intr_get() != 0)
    80002742:	eb85                	bnez	a5,80002772 <kerneltrap+0x56>
  if((which_dev = devintr()) == 0){
    80002744:	e57ff0ef          	jal	8000259a <devintr>
    80002748:	c91d                	beqz	a0,8000277e <kerneltrap+0x62>
  if(which_dev == 2 && myproc() != 0)
    8000274a:	4789                	li	a5,2
    8000274c:	04f50a63          	beq	a0,a5,800027a0 <kerneltrap+0x84>
  asm volatile("csrw sepc, %0" : : "r" (x));
    80002750:	14191073          	csrw	sepc,s2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002754:	10049073          	csrw	sstatus,s1
}
    80002758:	70a2                	ld	ra,40(sp)
    8000275a:	7402                	ld	s0,32(sp)
    8000275c:	64e2                	ld	s1,24(sp)
    8000275e:	6942                	ld	s2,16(sp)
    80002760:	69a2                	ld	s3,8(sp)
    80002762:	6145                	addi	sp,sp,48
    80002764:	8082                	ret
    panic("kerneltrap: not from supervisor mode");
    80002766:	00005517          	auipc	a0,0x5
    8000276a:	bca50513          	addi	a0,a0,-1078 # 80007330 <etext+0x330>
    8000276e:	870fe0ef          	jal	800007de <panic>
    panic("kerneltrap: interrupts enabled");
    80002772:	00005517          	auipc	a0,0x5
    80002776:	be650513          	addi	a0,a0,-1050 # 80007358 <etext+0x358>
    8000277a:	864fe0ef          	jal	800007de <panic>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    8000277e:	14102673          	csrr	a2,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    80002782:	143026f3          	csrr	a3,stval
    printf("scause=0x%lx sepc=0x%lx stval=0x%lx\n", scause, r_sepc(), r_stval());
    80002786:	85ce                	mv	a1,s3
    80002788:	00005517          	auipc	a0,0x5
    8000278c:	bf050513          	addi	a0,a0,-1040 # 80007378 <etext+0x378>
    80002790:	d6bfd0ef          	jal	800004fa <printf>
    panic("kerneltrap");
    80002794:	00005517          	auipc	a0,0x5
    80002798:	c0c50513          	addi	a0,a0,-1012 # 800073a0 <etext+0x3a0>
    8000279c:	842fe0ef          	jal	800007de <panic>
  if(which_dev == 2 && myproc() != 0)
    800027a0:	91eff0ef          	jal	800018be <myproc>
    800027a4:	d555                	beqz	a0,80002750 <kerneltrap+0x34>
    yield();
    800027a6:	ee4ff0ef          	jal	80001e8a <yield>
    800027aa:	b75d                	j	80002750 <kerneltrap+0x34>

00000000800027ac <argraw>:
  return strlen(buf);
}

static uint64
argraw(int n)
{
    800027ac:	1101                	addi	sp,sp,-32
    800027ae:	ec06                	sd	ra,24(sp)
    800027b0:	e822                	sd	s0,16(sp)
    800027b2:	e426                	sd	s1,8(sp)
    800027b4:	1000                	addi	s0,sp,32
    800027b6:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    800027b8:	906ff0ef          	jal	800018be <myproc>
  switch (n) {
    800027bc:	4795                	li	a5,5
    800027be:	0497e163          	bltu	a5,s1,80002800 <argraw+0x54>
    800027c2:	048a                	slli	s1,s1,0x2
    800027c4:	00005717          	auipc	a4,0x5
    800027c8:	ff470713          	addi	a4,a4,-12 # 800077b8 <states.0+0x30>
    800027cc:	94ba                	add	s1,s1,a4
    800027ce:	409c                	lw	a5,0(s1)
    800027d0:	97ba                	add	a5,a5,a4
    800027d2:	8782                	jr	a5
  case 0:
    return p->trapframe->a0;
    800027d4:	6d3c                	ld	a5,88(a0)
    800027d6:	7ba8                	ld	a0,112(a5)
  case 5:
    return p->trapframe->a5;
  }
  panic("argraw");
  return -1;
}
    800027d8:	60e2                	ld	ra,24(sp)
    800027da:	6442                	ld	s0,16(sp)
    800027dc:	64a2                	ld	s1,8(sp)
    800027de:	6105                	addi	sp,sp,32
    800027e0:	8082                	ret
    return p->trapframe->a1;
    800027e2:	6d3c                	ld	a5,88(a0)
    800027e4:	7fa8                	ld	a0,120(a5)
    800027e6:	bfcd                	j	800027d8 <argraw+0x2c>
    return p->trapframe->a2;
    800027e8:	6d3c                	ld	a5,88(a0)
    800027ea:	63c8                	ld	a0,128(a5)
    800027ec:	b7f5                	j	800027d8 <argraw+0x2c>
    return p->trapframe->a3;
    800027ee:	6d3c                	ld	a5,88(a0)
    800027f0:	67c8                	ld	a0,136(a5)
    800027f2:	b7dd                	j	800027d8 <argraw+0x2c>
    return p->trapframe->a4;
    800027f4:	6d3c                	ld	a5,88(a0)
    800027f6:	6bc8                	ld	a0,144(a5)
    800027f8:	b7c5                	j	800027d8 <argraw+0x2c>
    return p->trapframe->a5;
    800027fa:	6d3c                	ld	a5,88(a0)
    800027fc:	6fc8                	ld	a0,152(a5)
    800027fe:	bfe9                	j	800027d8 <argraw+0x2c>
  panic("argraw");
    80002800:	00005517          	auipc	a0,0x5
    80002804:	bb050513          	addi	a0,a0,-1104 # 800073b0 <etext+0x3b0>
    80002808:	fd7fd0ef          	jal	800007de <panic>

000000008000280c <fetchaddr>:
{
    8000280c:	1101                	addi	sp,sp,-32
    8000280e:	ec06                	sd	ra,24(sp)
    80002810:	e822                	sd	s0,16(sp)
    80002812:	e426                	sd	s1,8(sp)
    80002814:	e04a                	sd	s2,0(sp)
    80002816:	1000                	addi	s0,sp,32
    80002818:	84aa                	mv	s1,a0
    8000281a:	892e                	mv	s2,a1
  struct proc *p = myproc();
    8000281c:	8a2ff0ef          	jal	800018be <myproc>
  if(addr >= p->sz || addr+sizeof(uint64) > p->sz) // both tests needed, in case of overflow
    80002820:	653c                	ld	a5,72(a0)
    80002822:	02f4f663          	bgeu	s1,a5,8000284e <fetchaddr+0x42>
    80002826:	00848713          	addi	a4,s1,8
    8000282a:	02e7e463          	bltu	a5,a4,80002852 <fetchaddr+0x46>
  if(copyin(p->pagetable, (char *)ip, addr, sizeof(*ip)) != 0)
    8000282e:	46a1                	li	a3,8
    80002830:	8626                	mv	a2,s1
    80002832:	85ca                	mv	a1,s2
    80002834:	6928                	ld	a0,80(a0)
    80002836:	e79fe0ef          	jal	800016ae <copyin>
    8000283a:	00a03533          	snez	a0,a0
    8000283e:	40a0053b          	negw	a0,a0
}
    80002842:	60e2                	ld	ra,24(sp)
    80002844:	6442                	ld	s0,16(sp)
    80002846:	64a2                	ld	s1,8(sp)
    80002848:	6902                	ld	s2,0(sp)
    8000284a:	6105                	addi	sp,sp,32
    8000284c:	8082                	ret
    return -1;
    8000284e:	557d                	li	a0,-1
    80002850:	bfcd                	j	80002842 <fetchaddr+0x36>
    80002852:	557d                	li	a0,-1
    80002854:	b7fd                	j	80002842 <fetchaddr+0x36>

0000000080002856 <fetchstr>:
{
    80002856:	7179                	addi	sp,sp,-48
    80002858:	f406                	sd	ra,40(sp)
    8000285a:	f022                	sd	s0,32(sp)
    8000285c:	ec26                	sd	s1,24(sp)
    8000285e:	e84a                	sd	s2,16(sp)
    80002860:	e44e                	sd	s3,8(sp)
    80002862:	1800                	addi	s0,sp,48
    80002864:	892a                	mv	s2,a0
    80002866:	84ae                	mv	s1,a1
    80002868:	89b2                	mv	s3,a2
  struct proc *p = myproc();
    8000286a:	854ff0ef          	jal	800018be <myproc>
  if(copyinstr(p->pagetable, buf, addr, max) < 0)
    8000286e:	86ce                	mv	a3,s3
    80002870:	864a                	mv	a2,s2
    80002872:	85a6                	mv	a1,s1
    80002874:	6928                	ld	a0,80(a0)
    80002876:	c39fe0ef          	jal	800014ae <copyinstr>
    8000287a:	00054c63          	bltz	a0,80002892 <fetchstr+0x3c>
  return strlen(buf);
    8000287e:	8526                	mv	a0,s1
    80002880:	da4fe0ef          	jal	80000e24 <strlen>
}
    80002884:	70a2                	ld	ra,40(sp)
    80002886:	7402                	ld	s0,32(sp)
    80002888:	64e2                	ld	s1,24(sp)
    8000288a:	6942                	ld	s2,16(sp)
    8000288c:	69a2                	ld	s3,8(sp)
    8000288e:	6145                	addi	sp,sp,48
    80002890:	8082                	ret
    return -1;
    80002892:	557d                	li	a0,-1
    80002894:	bfc5                	j	80002884 <fetchstr+0x2e>

0000000080002896 <argint>:

// Fetch the nth 32-bit system call argument.
void
argint(int n, int *ip)
{
    80002896:	1101                	addi	sp,sp,-32
    80002898:	ec06                	sd	ra,24(sp)
    8000289a:	e822                	sd	s0,16(sp)
    8000289c:	e426                	sd	s1,8(sp)
    8000289e:	1000                	addi	s0,sp,32
    800028a0:	84ae                	mv	s1,a1
  *ip = argraw(n);
    800028a2:	f0bff0ef          	jal	800027ac <argraw>
    800028a6:	c088                	sw	a0,0(s1)
}
    800028a8:	60e2                	ld	ra,24(sp)
    800028aa:	6442                	ld	s0,16(sp)
    800028ac:	64a2                	ld	s1,8(sp)
    800028ae:	6105                	addi	sp,sp,32
    800028b0:	8082                	ret

00000000800028b2 <argaddr>:
// Retrieve an argument as a pointer.
// Doesn't check for legality, since
// copyin/copyout will do that.
void
argaddr(int n, uint64 *ip)
{
    800028b2:	1101                	addi	sp,sp,-32
    800028b4:	ec06                	sd	ra,24(sp)
    800028b6:	e822                	sd	s0,16(sp)
    800028b8:	e426                	sd	s1,8(sp)
    800028ba:	1000                	addi	s0,sp,32
    800028bc:	84ae                	mv	s1,a1
  *ip = argraw(n);
    800028be:	eefff0ef          	jal	800027ac <argraw>
    800028c2:	e088                	sd	a0,0(s1)
}
    800028c4:	60e2                	ld	ra,24(sp)
    800028c6:	6442                	ld	s0,16(sp)
    800028c8:	64a2                	ld	s1,8(sp)
    800028ca:	6105                	addi	sp,sp,32
    800028cc:	8082                	ret

00000000800028ce <argstr>:
// Fetch the nth word-sized system call argument as a null-terminated string.
// Copies into buf, at most max.
// Returns string length if OK (including nul), -1 if error.
int
argstr(int n, char *buf, int max)
{
    800028ce:	1101                	addi	sp,sp,-32
    800028d0:	ec06                	sd	ra,24(sp)
    800028d2:	e822                	sd	s0,16(sp)
    800028d4:	e426                	sd	s1,8(sp)
    800028d6:	e04a                	sd	s2,0(sp)
    800028d8:	1000                	addi	s0,sp,32
    800028da:	84ae                	mv	s1,a1
    800028dc:	8932                	mv	s2,a2
  *ip = argraw(n);
    800028de:	ecfff0ef          	jal	800027ac <argraw>
  uint64 addr;
  argaddr(n, &addr);
  return fetchstr(addr, buf, max);
    800028e2:	864a                	mv	a2,s2
    800028e4:	85a6                	mv	a1,s1
    800028e6:	f71ff0ef          	jal	80002856 <fetchstr>
}
    800028ea:	60e2                	ld	ra,24(sp)
    800028ec:	6442                	ld	s0,16(sp)
    800028ee:	64a2                	ld	s1,8(sp)
    800028f0:	6902                	ld	s2,0(sp)
    800028f2:	6105                	addi	sp,sp,32
    800028f4:	8082                	ret

00000000800028f6 <syscall>:
[SYS_pinfo]   sys_pinfo,
};

void
syscall(void)
{
    800028f6:	1101                	addi	sp,sp,-32
    800028f8:	ec06                	sd	ra,24(sp)
    800028fa:	e822                	sd	s0,16(sp)
    800028fc:	e426                	sd	s1,8(sp)
    800028fe:	e04a                	sd	s2,0(sp)
    80002900:	1000                	addi	s0,sp,32
  int num;
  struct proc *p = myproc();
    80002902:	fbdfe0ef          	jal	800018be <myproc>
    80002906:	84aa                	mv	s1,a0

  num = p->trapframe->a7;
    80002908:	05853903          	ld	s2,88(a0)
    8000290c:	0a893783          	ld	a5,168(s2)
    80002910:	0007869b          	sext.w	a3,a5
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
    80002914:	37fd                	addiw	a5,a5,-1
    80002916:	4755                	li	a4,21
    80002918:	00f76f63          	bltu	a4,a5,80002936 <syscall+0x40>
    8000291c:	00369713          	slli	a4,a3,0x3
    80002920:	00005797          	auipc	a5,0x5
    80002924:	eb078793          	addi	a5,a5,-336 # 800077d0 <syscalls>
    80002928:	97ba                	add	a5,a5,a4
    8000292a:	639c                	ld	a5,0(a5)
    8000292c:	c789                	beqz	a5,80002936 <syscall+0x40>
    // Use num to lookup the system call function for num, call it,
    // and store its return value in p->trapframe->a0
    p->trapframe->a0 = syscalls[num]();
    8000292e:	9782                	jalr	a5
    80002930:	06a93823          	sd	a0,112(s2)
    80002934:	a829                	j	8000294e <syscall+0x58>
  } else {
    printf("%d %s: unknown sys call %d\n",
    80002936:	15848613          	addi	a2,s1,344
    8000293a:	588c                	lw	a1,48(s1)
    8000293c:	00005517          	auipc	a0,0x5
    80002940:	a7c50513          	addi	a0,a0,-1412 # 800073b8 <etext+0x3b8>
    80002944:	bb7fd0ef          	jal	800004fa <printf>
            p->pid, p->name, num);
    p->trapframe->a0 = -1;
    80002948:	6cbc                	ld	a5,88(s1)
    8000294a:	577d                	li	a4,-1
    8000294c:	fbb8                	sd	a4,112(a5)
  }
}
    8000294e:	60e2                	ld	ra,24(sp)
    80002950:	6442                	ld	s0,16(sp)
    80002952:	64a2                	ld	s1,8(sp)
    80002954:	6902                	ld	s2,0(sp)
    80002956:	6105                	addi	sp,sp,32
    80002958:	8082                	ret

000000008000295a <sys_exit>:
#include "vm.h"
#include "procinfo.h"

uint64
sys_exit(void)
{
    8000295a:	1101                	addi	sp,sp,-32
    8000295c:	ec06                	sd	ra,24(sp)
    8000295e:	e822                	sd	s0,16(sp)
    80002960:	1000                	addi	s0,sp,32
  int n;
  argint(0, &n);
    80002962:	fec40593          	addi	a1,s0,-20
    80002966:	4501                	li	a0,0
    80002968:	f2fff0ef          	jal	80002896 <argint>
  kexit(n);
    8000296c:	fec42503          	lw	a0,-20(s0)
    80002970:	e52ff0ef          	jal	80001fc2 <kexit>
  return 0;  // not reached
}
    80002974:	4501                	li	a0,0
    80002976:	60e2                	ld	ra,24(sp)
    80002978:	6442                	ld	s0,16(sp)
    8000297a:	6105                	addi	sp,sp,32
    8000297c:	8082                	ret

000000008000297e <sys_getpid>:

uint64
sys_getpid(void)
{
    8000297e:	1141                	addi	sp,sp,-16
    80002980:	e406                	sd	ra,8(sp)
    80002982:	e022                	sd	s0,0(sp)
    80002984:	0800                	addi	s0,sp,16
  return myproc()->pid;
    80002986:	f39fe0ef          	jal	800018be <myproc>
}
    8000298a:	5908                	lw	a0,48(a0)
    8000298c:	60a2                	ld	ra,8(sp)
    8000298e:	6402                	ld	s0,0(sp)
    80002990:	0141                	addi	sp,sp,16
    80002992:	8082                	ret

0000000080002994 <sys_fork>:

uint64
sys_fork(void)
{
    80002994:	1141                	addi	sp,sp,-16
    80002996:	e406                	sd	ra,8(sp)
    80002998:	e022                	sd	s0,0(sp)
    8000299a:	0800                	addi	s0,sp,16
  return kfork();
    8000299c:	a74ff0ef          	jal	80001c10 <kfork>
}
    800029a0:	60a2                	ld	ra,8(sp)
    800029a2:	6402                	ld	s0,0(sp)
    800029a4:	0141                	addi	sp,sp,16
    800029a6:	8082                	ret

00000000800029a8 <sys_wait>:

uint64
sys_wait(void)
{
    800029a8:	1101                	addi	sp,sp,-32
    800029aa:	ec06                	sd	ra,24(sp)
    800029ac:	e822                	sd	s0,16(sp)
    800029ae:	1000                	addi	s0,sp,32
  uint64 p;
  argaddr(0, &p);
    800029b0:	fe840593          	addi	a1,s0,-24
    800029b4:	4501                	li	a0,0
    800029b6:	efdff0ef          	jal	800028b2 <argaddr>
  return kwait(p);
    800029ba:	fe843503          	ld	a0,-24(s0)
    800029be:	f5aff0ef          	jal	80002118 <kwait>
}
    800029c2:	60e2                	ld	ra,24(sp)
    800029c4:	6442                	ld	s0,16(sp)
    800029c6:	6105                	addi	sp,sp,32
    800029c8:	8082                	ret

00000000800029ca <sys_sbrk>:

uint64
sys_sbrk(void)
{
    800029ca:	7179                	addi	sp,sp,-48
    800029cc:	f406                	sd	ra,40(sp)
    800029ce:	f022                	sd	s0,32(sp)
    800029d0:	ec26                	sd	s1,24(sp)
    800029d2:	1800                	addi	s0,sp,48
  uint64 addr;
  int t;
  int n;

  argint(0, &n);
    800029d4:	fd840593          	addi	a1,s0,-40
    800029d8:	4501                	li	a0,0
    800029da:	ebdff0ef          	jal	80002896 <argint>
  argint(1, &t);
    800029de:	fdc40593          	addi	a1,s0,-36
    800029e2:	4505                	li	a0,1
    800029e4:	eb3ff0ef          	jal	80002896 <argint>
  addr = myproc()->sz;
    800029e8:	ed7fe0ef          	jal	800018be <myproc>
    800029ec:	6524                	ld	s1,72(a0)

  if(t == SBRK_EAGER || n < 0) {
    800029ee:	fdc42703          	lw	a4,-36(s0)
    800029f2:	4785                	li	a5,1
    800029f4:	02f70163          	beq	a4,a5,80002a16 <sys_sbrk+0x4c>
    800029f8:	fd842783          	lw	a5,-40(s0)
    800029fc:	0007cd63          	bltz	a5,80002a16 <sys_sbrk+0x4c>
    }
  } else {
    // Lazily allocate memory for this process: increase its memory
    // size but don't allocate memory. If the processes uses the
    // memory, vmfault() will allocate it.
    if(addr + n < addr)
    80002a00:	97a6                	add	a5,a5,s1
    80002a02:	0297e863          	bltu	a5,s1,80002a32 <sys_sbrk+0x68>
      return -1;
    myproc()->sz += n;
    80002a06:	eb9fe0ef          	jal	800018be <myproc>
    80002a0a:	fd842703          	lw	a4,-40(s0)
    80002a0e:	653c                	ld	a5,72(a0)
    80002a10:	97ba                	add	a5,a5,a4
    80002a12:	e53c                	sd	a5,72(a0)
    80002a14:	a039                	j	80002a22 <sys_sbrk+0x58>
    if(growproc(n) < 0) {
    80002a16:	fd842503          	lw	a0,-40(s0)
    80002a1a:	9a6ff0ef          	jal	80001bc0 <growproc>
    80002a1e:	00054863          	bltz	a0,80002a2e <sys_sbrk+0x64>
  }
  return addr;
}
    80002a22:	8526                	mv	a0,s1
    80002a24:	70a2                	ld	ra,40(sp)
    80002a26:	7402                	ld	s0,32(sp)
    80002a28:	64e2                	ld	s1,24(sp)
    80002a2a:	6145                	addi	sp,sp,48
    80002a2c:	8082                	ret
      return -1;
    80002a2e:	54fd                	li	s1,-1
    80002a30:	bfcd                	j	80002a22 <sys_sbrk+0x58>
      return -1;
    80002a32:	54fd                	li	s1,-1
    80002a34:	b7fd                	j	80002a22 <sys_sbrk+0x58>

0000000080002a36 <sys_pause>:

uint64
sys_pause(void)
{
    80002a36:	7139                	addi	sp,sp,-64
    80002a38:	fc06                	sd	ra,56(sp)
    80002a3a:	f822                	sd	s0,48(sp)
    80002a3c:	f04a                	sd	s2,32(sp)
    80002a3e:	0080                	addi	s0,sp,64
  int n;
  uint ticks0;

  argint(0, &n);
    80002a40:	fcc40593          	addi	a1,s0,-52
    80002a44:	4501                	li	a0,0
    80002a46:	e51ff0ef          	jal	80002896 <argint>
  if(n < 0)
    80002a4a:	fcc42783          	lw	a5,-52(s0)
    80002a4e:	0607c763          	bltz	a5,80002abc <sys_pause+0x86>
    n = 0;
  acquire(&tickslock);
    80002a52:	00013517          	auipc	a0,0x13
    80002a56:	da650513          	addi	a0,a0,-602 # 800157f8 <tickslock>
    80002a5a:	972fe0ef          	jal	80000bcc <acquire>
  ticks0 = ticks;
    80002a5e:	00005917          	auipc	s2,0x5
    80002a62:	e6a92903          	lw	s2,-406(s2) # 800078c8 <ticks>
  while(ticks - ticks0 < n){
    80002a66:	fcc42783          	lw	a5,-52(s0)
    80002a6a:	cf8d                	beqz	a5,80002aa4 <sys_pause+0x6e>
    80002a6c:	f426                	sd	s1,40(sp)
    80002a6e:	ec4e                	sd	s3,24(sp)
    if(killed(myproc())){
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
    80002a70:	00013997          	auipc	s3,0x13
    80002a74:	d8898993          	addi	s3,s3,-632 # 800157f8 <tickslock>
    80002a78:	00005497          	auipc	s1,0x5
    80002a7c:	e5048493          	addi	s1,s1,-432 # 800078c8 <ticks>
    if(killed(myproc())){
    80002a80:	e3ffe0ef          	jal	800018be <myproc>
    80002a84:	e6aff0ef          	jal	800020ee <killed>
    80002a88:	ed0d                	bnez	a0,80002ac2 <sys_pause+0x8c>
    sleep(&ticks, &tickslock);
    80002a8a:	85ce                	mv	a1,s3
    80002a8c:	8526                	mv	a0,s1
    80002a8e:	c28ff0ef          	jal	80001eb6 <sleep>
  while(ticks - ticks0 < n){
    80002a92:	409c                	lw	a5,0(s1)
    80002a94:	412787bb          	subw	a5,a5,s2
    80002a98:	fcc42703          	lw	a4,-52(s0)
    80002a9c:	fee7e2e3          	bltu	a5,a4,80002a80 <sys_pause+0x4a>
    80002aa0:	74a2                	ld	s1,40(sp)
    80002aa2:	69e2                	ld	s3,24(sp)
  }
  release(&tickslock);
    80002aa4:	00013517          	auipc	a0,0x13
    80002aa8:	d5450513          	addi	a0,a0,-684 # 800157f8 <tickslock>
    80002aac:	9b4fe0ef          	jal	80000c60 <release>
  return 0;
    80002ab0:	4501                	li	a0,0
}
    80002ab2:	70e2                	ld	ra,56(sp)
    80002ab4:	7442                	ld	s0,48(sp)
    80002ab6:	7902                	ld	s2,32(sp)
    80002ab8:	6121                	addi	sp,sp,64
    80002aba:	8082                	ret
    n = 0;
    80002abc:	fc042623          	sw	zero,-52(s0)
    80002ac0:	bf49                	j	80002a52 <sys_pause+0x1c>
      release(&tickslock);
    80002ac2:	00013517          	auipc	a0,0x13
    80002ac6:	d3650513          	addi	a0,a0,-714 # 800157f8 <tickslock>
    80002aca:	996fe0ef          	jal	80000c60 <release>
      return -1;
    80002ace:	557d                	li	a0,-1
    80002ad0:	74a2                	ld	s1,40(sp)
    80002ad2:	69e2                	ld	s3,24(sp)
    80002ad4:	bff9                	j	80002ab2 <sys_pause+0x7c>

0000000080002ad6 <sys_kill>:

uint64
sys_kill(void)
{
    80002ad6:	1101                	addi	sp,sp,-32
    80002ad8:	ec06                	sd	ra,24(sp)
    80002ada:	e822                	sd	s0,16(sp)
    80002adc:	1000                	addi	s0,sp,32
  int pid;

  argint(0, &pid);
    80002ade:	fec40593          	addi	a1,s0,-20
    80002ae2:	4501                	li	a0,0
    80002ae4:	db3ff0ef          	jal	80002896 <argint>
  return kkill(pid);
    80002ae8:	fec42503          	lw	a0,-20(s0)
    80002aec:	d78ff0ef          	jal	80002064 <kkill>
}
    80002af0:	60e2                	ld	ra,24(sp)
    80002af2:	6442                	ld	s0,16(sp)
    80002af4:	6105                	addi	sp,sp,32
    80002af6:	8082                	ret

0000000080002af8 <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
uint64
sys_uptime(void)
{
    80002af8:	1101                	addi	sp,sp,-32
    80002afa:	ec06                	sd	ra,24(sp)
    80002afc:	e822                	sd	s0,16(sp)
    80002afe:	e426                	sd	s1,8(sp)
    80002b00:	1000                	addi	s0,sp,32
  uint xticks;

  acquire(&tickslock);
    80002b02:	00013517          	auipc	a0,0x13
    80002b06:	cf650513          	addi	a0,a0,-778 # 800157f8 <tickslock>
    80002b0a:	8c2fe0ef          	jal	80000bcc <acquire>
  xticks = ticks;
    80002b0e:	00005497          	auipc	s1,0x5
    80002b12:	dba4a483          	lw	s1,-582(s1) # 800078c8 <ticks>
  release(&tickslock);
    80002b16:	00013517          	auipc	a0,0x13
    80002b1a:	ce250513          	addi	a0,a0,-798 # 800157f8 <tickslock>
    80002b1e:	942fe0ef          	jal	80000c60 <release>
  return xticks;
}
    80002b22:	02049513          	slli	a0,s1,0x20
    80002b26:	9101                	srli	a0,a0,0x20
    80002b28:	60e2                	ld	ra,24(sp)
    80002b2a:	6442                	ld	s0,16(sp)
    80002b2c:	64a2                	ld	s1,8(sp)
    80002b2e:	6105                	addi	sp,sp,32
    80002b30:	8082                	ret

0000000080002b32 <sys_pinfo>:

uint64 
sys_pinfo(void) {
    80002b32:	715d                	addi	sp,sp,-80
    80002b34:	e486                	sd	ra,72(sp)
    80002b36:	e0a2                	sd	s0,64(sp)
    80002b38:	0880                	addi	s0,sp,80
    int pid;
    uint64 uaddr;
    struct proc_info info;

    argint(0, &pid);
    80002b3a:	fec40593          	addi	a1,s0,-20
    80002b3e:	4501                	li	a0,0
    80002b40:	d57ff0ef          	jal	80002896 <argint>
    argaddr(1, &uaddr);
    80002b44:	fe040593          	addi	a1,s0,-32
    80002b48:	4505                	li	a0,1
    80002b4a:	d69ff0ef          	jal	800028b2 <argaddr>

    if(get_proc_info(pid, &info) < 0)
    80002b4e:	fb040593          	addi	a1,s0,-80
    80002b52:	fec42503          	lw	a0,-20(s0)
    80002b56:	feeff0ef          	jal	80002344 <get_proc_info>
    80002b5a:	87aa                	mv	a5,a0
        return -1;
    80002b5c:	557d                	li	a0,-1
    if(get_proc_info(pid, &info) < 0)
    80002b5e:	0007ce63          	bltz	a5,80002b7a <sys_pinfo+0x48>

    if(copyout(myproc()->pagetable, uaddr, (char *)&info, sizeof(info)) < 0)
    80002b62:	d5dfe0ef          	jal	800018be <myproc>
    80002b66:	03000693          	li	a3,48
    80002b6a:	fb040613          	addi	a2,s0,-80
    80002b6e:	fe043583          	ld	a1,-32(s0)
    80002b72:	6928                	ld	a0,80(a0)
    80002b74:	a7dfe0ef          	jal	800015f0 <copyout>
    80002b78:	957d                	srai	a0,a0,0x3f
        return -1;

    return 0;
}
    80002b7a:	60a6                	ld	ra,72(sp)
    80002b7c:	6406                	ld	s0,64(sp)
    80002b7e:	6161                	addi	sp,sp,80
    80002b80:	8082                	ret

0000000080002b82 <binit>:
  struct buf head;
} bcache;

void
binit(void)
{
    80002b82:	7179                	addi	sp,sp,-48
    80002b84:	f406                	sd	ra,40(sp)
    80002b86:	f022                	sd	s0,32(sp)
    80002b88:	ec26                	sd	s1,24(sp)
    80002b8a:	e84a                	sd	s2,16(sp)
    80002b8c:	e44e                	sd	s3,8(sp)
    80002b8e:	e052                	sd	s4,0(sp)
    80002b90:	1800                	addi	s0,sp,48
  struct buf *b;

  initlock(&bcache.lock, "bcache");
    80002b92:	00005597          	auipc	a1,0x5
    80002b96:	84658593          	addi	a1,a1,-1978 # 800073d8 <etext+0x3d8>
    80002b9a:	00013517          	auipc	a0,0x13
    80002b9e:	c7650513          	addi	a0,a0,-906 # 80015810 <bcache>
    80002ba2:	fa7fd0ef          	jal	80000b48 <initlock>

  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
    80002ba6:	0001b797          	auipc	a5,0x1b
    80002baa:	c6a78793          	addi	a5,a5,-918 # 8001d810 <bcache+0x8000>
    80002bae:	0001b717          	auipc	a4,0x1b
    80002bb2:	eca70713          	addi	a4,a4,-310 # 8001da78 <bcache+0x8268>
    80002bb6:	2ae7b823          	sd	a4,688(a5)
  bcache.head.next = &bcache.head;
    80002bba:	2ae7bc23          	sd	a4,696(a5)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    80002bbe:	00013497          	auipc	s1,0x13
    80002bc2:	c6a48493          	addi	s1,s1,-918 # 80015828 <bcache+0x18>
    b->next = bcache.head.next;
    80002bc6:	893e                	mv	s2,a5
    b->prev = &bcache.head;
    80002bc8:	89ba                	mv	s3,a4
    initsleeplock(&b->lock, "buffer");
    80002bca:	00005a17          	auipc	s4,0x5
    80002bce:	816a0a13          	addi	s4,s4,-2026 # 800073e0 <etext+0x3e0>
    b->next = bcache.head.next;
    80002bd2:	2b893783          	ld	a5,696(s2)
    80002bd6:	e8bc                	sd	a5,80(s1)
    b->prev = &bcache.head;
    80002bd8:	0534b423          	sd	s3,72(s1)
    initsleeplock(&b->lock, "buffer");
    80002bdc:	85d2                	mv	a1,s4
    80002bde:	01048513          	addi	a0,s1,16
    80002be2:	31c010ef          	jal	80003efe <initsleeplock>
    bcache.head.next->prev = b;
    80002be6:	2b893783          	ld	a5,696(s2)
    80002bea:	e7a4                	sd	s1,72(a5)
    bcache.head.next = b;
    80002bec:	2a993c23          	sd	s1,696(s2)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    80002bf0:	45848493          	addi	s1,s1,1112
    80002bf4:	fd349fe3          	bne	s1,s3,80002bd2 <binit+0x50>
  }
}
    80002bf8:	70a2                	ld	ra,40(sp)
    80002bfa:	7402                	ld	s0,32(sp)
    80002bfc:	64e2                	ld	s1,24(sp)
    80002bfe:	6942                	ld	s2,16(sp)
    80002c00:	69a2                	ld	s3,8(sp)
    80002c02:	6a02                	ld	s4,0(sp)
    80002c04:	6145                	addi	sp,sp,48
    80002c06:	8082                	ret

0000000080002c08 <bread>:
}

// Return a locked buf with the contents of the indicated block.
struct buf*
bread(uint dev, uint blockno)
{
    80002c08:	7179                	addi	sp,sp,-48
    80002c0a:	f406                	sd	ra,40(sp)
    80002c0c:	f022                	sd	s0,32(sp)
    80002c0e:	ec26                	sd	s1,24(sp)
    80002c10:	e84a                	sd	s2,16(sp)
    80002c12:	e44e                	sd	s3,8(sp)
    80002c14:	1800                	addi	s0,sp,48
    80002c16:	892a                	mv	s2,a0
    80002c18:	89ae                	mv	s3,a1
  acquire(&bcache.lock);
    80002c1a:	00013517          	auipc	a0,0x13
    80002c1e:	bf650513          	addi	a0,a0,-1034 # 80015810 <bcache>
    80002c22:	fabfd0ef          	jal	80000bcc <acquire>
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
    80002c26:	0001b497          	auipc	s1,0x1b
    80002c2a:	ea24b483          	ld	s1,-350(s1) # 8001dac8 <bcache+0x82b8>
    80002c2e:	0001b797          	auipc	a5,0x1b
    80002c32:	e4a78793          	addi	a5,a5,-438 # 8001da78 <bcache+0x8268>
    80002c36:	02f48b63          	beq	s1,a5,80002c6c <bread+0x64>
    80002c3a:	873e                	mv	a4,a5
    80002c3c:	a021                	j	80002c44 <bread+0x3c>
    80002c3e:	68a4                	ld	s1,80(s1)
    80002c40:	02e48663          	beq	s1,a4,80002c6c <bread+0x64>
    if(b->dev == dev && b->blockno == blockno){
    80002c44:	449c                	lw	a5,8(s1)
    80002c46:	ff279ce3          	bne	a5,s2,80002c3e <bread+0x36>
    80002c4a:	44dc                	lw	a5,12(s1)
    80002c4c:	ff3799e3          	bne	a5,s3,80002c3e <bread+0x36>
      b->refcnt++;
    80002c50:	40bc                	lw	a5,64(s1)
    80002c52:	2785                	addiw	a5,a5,1
    80002c54:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    80002c56:	00013517          	auipc	a0,0x13
    80002c5a:	bba50513          	addi	a0,a0,-1094 # 80015810 <bcache>
    80002c5e:	802fe0ef          	jal	80000c60 <release>
      acquiresleep(&b->lock);
    80002c62:	01048513          	addi	a0,s1,16
    80002c66:	2ce010ef          	jal	80003f34 <acquiresleep>
      return b;
    80002c6a:	a889                	j	80002cbc <bread+0xb4>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    80002c6c:	0001b497          	auipc	s1,0x1b
    80002c70:	e544b483          	ld	s1,-428(s1) # 8001dac0 <bcache+0x82b0>
    80002c74:	0001b797          	auipc	a5,0x1b
    80002c78:	e0478793          	addi	a5,a5,-508 # 8001da78 <bcache+0x8268>
    80002c7c:	00f48863          	beq	s1,a5,80002c8c <bread+0x84>
    80002c80:	873e                	mv	a4,a5
    if(b->refcnt == 0) {
    80002c82:	40bc                	lw	a5,64(s1)
    80002c84:	cb91                	beqz	a5,80002c98 <bread+0x90>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    80002c86:	64a4                	ld	s1,72(s1)
    80002c88:	fee49de3          	bne	s1,a4,80002c82 <bread+0x7a>
  panic("bget: no buffers");
    80002c8c:	00004517          	auipc	a0,0x4
    80002c90:	75c50513          	addi	a0,a0,1884 # 800073e8 <etext+0x3e8>
    80002c94:	b4bfd0ef          	jal	800007de <panic>
      b->dev = dev;
    80002c98:	0124a423          	sw	s2,8(s1)
      b->blockno = blockno;
    80002c9c:	0134a623          	sw	s3,12(s1)
      b->valid = 0;
    80002ca0:	0004a023          	sw	zero,0(s1)
      b->refcnt = 1;
    80002ca4:	4785                	li	a5,1
    80002ca6:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    80002ca8:	00013517          	auipc	a0,0x13
    80002cac:	b6850513          	addi	a0,a0,-1176 # 80015810 <bcache>
    80002cb0:	fb1fd0ef          	jal	80000c60 <release>
      acquiresleep(&b->lock);
    80002cb4:	01048513          	addi	a0,s1,16
    80002cb8:	27c010ef          	jal	80003f34 <acquiresleep>
  struct buf *b;

  b = bget(dev, blockno);
  if(!b->valid) {
    80002cbc:	409c                	lw	a5,0(s1)
    80002cbe:	cb89                	beqz	a5,80002cd0 <bread+0xc8>
    virtio_disk_rw(b, 0);
    b->valid = 1;
  }
  return b;
}
    80002cc0:	8526                	mv	a0,s1
    80002cc2:	70a2                	ld	ra,40(sp)
    80002cc4:	7402                	ld	s0,32(sp)
    80002cc6:	64e2                	ld	s1,24(sp)
    80002cc8:	6942                	ld	s2,16(sp)
    80002cca:	69a2                	ld	s3,8(sp)
    80002ccc:	6145                	addi	sp,sp,48
    80002cce:	8082                	ret
    virtio_disk_rw(b, 0);
    80002cd0:	4581                	li	a1,0
    80002cd2:	8526                	mv	a0,s1
    80002cd4:	2cd020ef          	jal	800057a0 <virtio_disk_rw>
    b->valid = 1;
    80002cd8:	4785                	li	a5,1
    80002cda:	c09c                	sw	a5,0(s1)
  return b;
    80002cdc:	b7d5                	j	80002cc0 <bread+0xb8>

0000000080002cde <bwrite>:

// Write b's contents to disk.  Must be locked.
void
bwrite(struct buf *b)
{
    80002cde:	1101                	addi	sp,sp,-32
    80002ce0:	ec06                	sd	ra,24(sp)
    80002ce2:	e822                	sd	s0,16(sp)
    80002ce4:	e426                	sd	s1,8(sp)
    80002ce6:	1000                	addi	s0,sp,32
    80002ce8:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    80002cea:	0541                	addi	a0,a0,16
    80002cec:	2c6010ef          	jal	80003fb2 <holdingsleep>
    80002cf0:	c911                	beqz	a0,80002d04 <bwrite+0x26>
    panic("bwrite");
  virtio_disk_rw(b, 1);
    80002cf2:	4585                	li	a1,1
    80002cf4:	8526                	mv	a0,s1
    80002cf6:	2ab020ef          	jal	800057a0 <virtio_disk_rw>
}
    80002cfa:	60e2                	ld	ra,24(sp)
    80002cfc:	6442                	ld	s0,16(sp)
    80002cfe:	64a2                	ld	s1,8(sp)
    80002d00:	6105                	addi	sp,sp,32
    80002d02:	8082                	ret
    panic("bwrite");
    80002d04:	00004517          	auipc	a0,0x4
    80002d08:	6fc50513          	addi	a0,a0,1788 # 80007400 <etext+0x400>
    80002d0c:	ad3fd0ef          	jal	800007de <panic>

0000000080002d10 <brelse>:

// Release a locked buffer.
// Move to the head of the most-recently-used list.
void
brelse(struct buf *b)
{
    80002d10:	1101                	addi	sp,sp,-32
    80002d12:	ec06                	sd	ra,24(sp)
    80002d14:	e822                	sd	s0,16(sp)
    80002d16:	e426                	sd	s1,8(sp)
    80002d18:	e04a                	sd	s2,0(sp)
    80002d1a:	1000                	addi	s0,sp,32
    80002d1c:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    80002d1e:	01050913          	addi	s2,a0,16
    80002d22:	854a                	mv	a0,s2
    80002d24:	28e010ef          	jal	80003fb2 <holdingsleep>
    80002d28:	c125                	beqz	a0,80002d88 <brelse+0x78>
    panic("brelse");

  releasesleep(&b->lock);
    80002d2a:	854a                	mv	a0,s2
    80002d2c:	24e010ef          	jal	80003f7a <releasesleep>

  acquire(&bcache.lock);
    80002d30:	00013517          	auipc	a0,0x13
    80002d34:	ae050513          	addi	a0,a0,-1312 # 80015810 <bcache>
    80002d38:	e95fd0ef          	jal	80000bcc <acquire>
  b->refcnt--;
    80002d3c:	40bc                	lw	a5,64(s1)
    80002d3e:	37fd                	addiw	a5,a5,-1
    80002d40:	c0bc                	sw	a5,64(s1)
  if (b->refcnt == 0) {
    80002d42:	e79d                	bnez	a5,80002d70 <brelse+0x60>
    // no one is waiting for it.
    b->next->prev = b->prev;
    80002d44:	68b8                	ld	a4,80(s1)
    80002d46:	64bc                	ld	a5,72(s1)
    80002d48:	e73c                	sd	a5,72(a4)
    b->prev->next = b->next;
    80002d4a:	68b8                	ld	a4,80(s1)
    80002d4c:	ebb8                	sd	a4,80(a5)
    b->next = bcache.head.next;
    80002d4e:	0001b797          	auipc	a5,0x1b
    80002d52:	ac278793          	addi	a5,a5,-1342 # 8001d810 <bcache+0x8000>
    80002d56:	2b87b703          	ld	a4,696(a5)
    80002d5a:	e8b8                	sd	a4,80(s1)
    b->prev = &bcache.head;
    80002d5c:	0001b717          	auipc	a4,0x1b
    80002d60:	d1c70713          	addi	a4,a4,-740 # 8001da78 <bcache+0x8268>
    80002d64:	e4b8                	sd	a4,72(s1)
    bcache.head.next->prev = b;
    80002d66:	2b87b703          	ld	a4,696(a5)
    80002d6a:	e724                	sd	s1,72(a4)
    bcache.head.next = b;
    80002d6c:	2a97bc23          	sd	s1,696(a5)
  }
  
  release(&bcache.lock);
    80002d70:	00013517          	auipc	a0,0x13
    80002d74:	aa050513          	addi	a0,a0,-1376 # 80015810 <bcache>
    80002d78:	ee9fd0ef          	jal	80000c60 <release>
}
    80002d7c:	60e2                	ld	ra,24(sp)
    80002d7e:	6442                	ld	s0,16(sp)
    80002d80:	64a2                	ld	s1,8(sp)
    80002d82:	6902                	ld	s2,0(sp)
    80002d84:	6105                	addi	sp,sp,32
    80002d86:	8082                	ret
    panic("brelse");
    80002d88:	00004517          	auipc	a0,0x4
    80002d8c:	68050513          	addi	a0,a0,1664 # 80007408 <etext+0x408>
    80002d90:	a4ffd0ef          	jal	800007de <panic>

0000000080002d94 <bpin>:

void
bpin(struct buf *b) {
    80002d94:	1101                	addi	sp,sp,-32
    80002d96:	ec06                	sd	ra,24(sp)
    80002d98:	e822                	sd	s0,16(sp)
    80002d9a:	e426                	sd	s1,8(sp)
    80002d9c:	1000                	addi	s0,sp,32
    80002d9e:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    80002da0:	00013517          	auipc	a0,0x13
    80002da4:	a7050513          	addi	a0,a0,-1424 # 80015810 <bcache>
    80002da8:	e25fd0ef          	jal	80000bcc <acquire>
  b->refcnt++;
    80002dac:	40bc                	lw	a5,64(s1)
    80002dae:	2785                	addiw	a5,a5,1
    80002db0:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    80002db2:	00013517          	auipc	a0,0x13
    80002db6:	a5e50513          	addi	a0,a0,-1442 # 80015810 <bcache>
    80002dba:	ea7fd0ef          	jal	80000c60 <release>
}
    80002dbe:	60e2                	ld	ra,24(sp)
    80002dc0:	6442                	ld	s0,16(sp)
    80002dc2:	64a2                	ld	s1,8(sp)
    80002dc4:	6105                	addi	sp,sp,32
    80002dc6:	8082                	ret

0000000080002dc8 <bunpin>:

void
bunpin(struct buf *b) {
    80002dc8:	1101                	addi	sp,sp,-32
    80002dca:	ec06                	sd	ra,24(sp)
    80002dcc:	e822                	sd	s0,16(sp)
    80002dce:	e426                	sd	s1,8(sp)
    80002dd0:	1000                	addi	s0,sp,32
    80002dd2:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    80002dd4:	00013517          	auipc	a0,0x13
    80002dd8:	a3c50513          	addi	a0,a0,-1476 # 80015810 <bcache>
    80002ddc:	df1fd0ef          	jal	80000bcc <acquire>
  b->refcnt--;
    80002de0:	40bc                	lw	a5,64(s1)
    80002de2:	37fd                	addiw	a5,a5,-1
    80002de4:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    80002de6:	00013517          	auipc	a0,0x13
    80002dea:	a2a50513          	addi	a0,a0,-1494 # 80015810 <bcache>
    80002dee:	e73fd0ef          	jal	80000c60 <release>
}
    80002df2:	60e2                	ld	ra,24(sp)
    80002df4:	6442                	ld	s0,16(sp)
    80002df6:	64a2                	ld	s1,8(sp)
    80002df8:	6105                	addi	sp,sp,32
    80002dfa:	8082                	ret

0000000080002dfc <bfree>:
}

// Free a disk block.
static void
bfree(int dev, uint b)
{
    80002dfc:	1101                	addi	sp,sp,-32
    80002dfe:	ec06                	sd	ra,24(sp)
    80002e00:	e822                	sd	s0,16(sp)
    80002e02:	e426                	sd	s1,8(sp)
    80002e04:	e04a                	sd	s2,0(sp)
    80002e06:	1000                	addi	s0,sp,32
    80002e08:	84ae                	mv	s1,a1
  struct buf *bp;
  int bi, m;

  bp = bread(dev, BBLOCK(b, sb));
    80002e0a:	00d5d79b          	srliw	a5,a1,0xd
    80002e0e:	0001b597          	auipc	a1,0x1b
    80002e12:	0de5a583          	lw	a1,222(a1) # 8001deec <sb+0x1c>
    80002e16:	9dbd                	addw	a1,a1,a5
    80002e18:	df1ff0ef          	jal	80002c08 <bread>
  bi = b % BPB;
  m = 1 << (bi % 8);
    80002e1c:	0074f713          	andi	a4,s1,7
    80002e20:	4785                	li	a5,1
    80002e22:	00e797bb          	sllw	a5,a5,a4
  bi = b % BPB;
    80002e26:	14ce                	slli	s1,s1,0x33
  if((bp->data[bi/8] & m) == 0)
    80002e28:	90d9                	srli	s1,s1,0x36
    80002e2a:	00950733          	add	a4,a0,s1
    80002e2e:	05874703          	lbu	a4,88(a4)
    80002e32:	00e7f6b3          	and	a3,a5,a4
    80002e36:	c29d                	beqz	a3,80002e5c <bfree+0x60>
    80002e38:	892a                	mv	s2,a0
    panic("freeing free block");
  bp->data[bi/8] &= ~m;
    80002e3a:	94aa                	add	s1,s1,a0
    80002e3c:	fff7c793          	not	a5,a5
    80002e40:	8f7d                	and	a4,a4,a5
    80002e42:	04e48c23          	sb	a4,88(s1)
  log_write(bp);
    80002e46:	7f7000ef          	jal	80003e3c <log_write>
  brelse(bp);
    80002e4a:	854a                	mv	a0,s2
    80002e4c:	ec5ff0ef          	jal	80002d10 <brelse>
}
    80002e50:	60e2                	ld	ra,24(sp)
    80002e52:	6442                	ld	s0,16(sp)
    80002e54:	64a2                	ld	s1,8(sp)
    80002e56:	6902                	ld	s2,0(sp)
    80002e58:	6105                	addi	sp,sp,32
    80002e5a:	8082                	ret
    panic("freeing free block");
    80002e5c:	00004517          	auipc	a0,0x4
    80002e60:	5b450513          	addi	a0,a0,1460 # 80007410 <etext+0x410>
    80002e64:	97bfd0ef          	jal	800007de <panic>

0000000080002e68 <balloc>:
{
    80002e68:	715d                	addi	sp,sp,-80
    80002e6a:	e486                	sd	ra,72(sp)
    80002e6c:	e0a2                	sd	s0,64(sp)
    80002e6e:	fc26                	sd	s1,56(sp)
    80002e70:	0880                	addi	s0,sp,80
  for(b = 0; b < sb.size; b += BPB){
    80002e72:	0001b797          	auipc	a5,0x1b
    80002e76:	0627a783          	lw	a5,98(a5) # 8001ded4 <sb+0x4>
    80002e7a:	0e078863          	beqz	a5,80002f6a <balloc+0x102>
    80002e7e:	f84a                	sd	s2,48(sp)
    80002e80:	f44e                	sd	s3,40(sp)
    80002e82:	f052                	sd	s4,32(sp)
    80002e84:	ec56                	sd	s5,24(sp)
    80002e86:	e85a                	sd	s6,16(sp)
    80002e88:	e45e                	sd	s7,8(sp)
    80002e8a:	e062                	sd	s8,0(sp)
    80002e8c:	8baa                	mv	s7,a0
    80002e8e:	4a81                	li	s5,0
    bp = bread(dev, BBLOCK(b, sb));
    80002e90:	0001bb17          	auipc	s6,0x1b
    80002e94:	040b0b13          	addi	s6,s6,64 # 8001ded0 <sb>
      m = 1 << (bi % 8);
    80002e98:	4985                	li	s3,1
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80002e9a:	6a09                	lui	s4,0x2
  for(b = 0; b < sb.size; b += BPB){
    80002e9c:	6c09                	lui	s8,0x2
    80002e9e:	a09d                	j	80002f04 <balloc+0x9c>
        bp->data[bi/8] |= m;  // Mark block in use.
    80002ea0:	97ca                	add	a5,a5,s2
    80002ea2:	8e55                	or	a2,a2,a3
    80002ea4:	04c78c23          	sb	a2,88(a5)
        log_write(bp);
    80002ea8:	854a                	mv	a0,s2
    80002eaa:	793000ef          	jal	80003e3c <log_write>
        brelse(bp);
    80002eae:	854a                	mv	a0,s2
    80002eb0:	e61ff0ef          	jal	80002d10 <brelse>
  bp = bread(dev, bno);
    80002eb4:	85a6                	mv	a1,s1
    80002eb6:	855e                	mv	a0,s7
    80002eb8:	d51ff0ef          	jal	80002c08 <bread>
    80002ebc:	892a                	mv	s2,a0
  memset(bp->data, 0, BSIZE);
    80002ebe:	40000613          	li	a2,1024
    80002ec2:	4581                	li	a1,0
    80002ec4:	05850513          	addi	a0,a0,88
    80002ec8:	dd5fd0ef          	jal	80000c9c <memset>
  log_write(bp);
    80002ecc:	854a                	mv	a0,s2
    80002ece:	76f000ef          	jal	80003e3c <log_write>
  brelse(bp);
    80002ed2:	854a                	mv	a0,s2
    80002ed4:	e3dff0ef          	jal	80002d10 <brelse>
}
    80002ed8:	7942                	ld	s2,48(sp)
    80002eda:	79a2                	ld	s3,40(sp)
    80002edc:	7a02                	ld	s4,32(sp)
    80002ede:	6ae2                	ld	s5,24(sp)
    80002ee0:	6b42                	ld	s6,16(sp)
    80002ee2:	6ba2                	ld	s7,8(sp)
    80002ee4:	6c02                	ld	s8,0(sp)
}
    80002ee6:	8526                	mv	a0,s1
    80002ee8:	60a6                	ld	ra,72(sp)
    80002eea:	6406                	ld	s0,64(sp)
    80002eec:	74e2                	ld	s1,56(sp)
    80002eee:	6161                	addi	sp,sp,80
    80002ef0:	8082                	ret
    brelse(bp);
    80002ef2:	854a                	mv	a0,s2
    80002ef4:	e1dff0ef          	jal	80002d10 <brelse>
  for(b = 0; b < sb.size; b += BPB){
    80002ef8:	015c0abb          	addw	s5,s8,s5
    80002efc:	004b2783          	lw	a5,4(s6)
    80002f00:	04fafe63          	bgeu	s5,a5,80002f5c <balloc+0xf4>
    bp = bread(dev, BBLOCK(b, sb));
    80002f04:	41fad79b          	sraiw	a5,s5,0x1f
    80002f08:	0137d79b          	srliw	a5,a5,0x13
    80002f0c:	015787bb          	addw	a5,a5,s5
    80002f10:	40d7d79b          	sraiw	a5,a5,0xd
    80002f14:	01cb2583          	lw	a1,28(s6)
    80002f18:	9dbd                	addw	a1,a1,a5
    80002f1a:	855e                	mv	a0,s7
    80002f1c:	cedff0ef          	jal	80002c08 <bread>
    80002f20:	892a                	mv	s2,a0
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80002f22:	004b2503          	lw	a0,4(s6)
    80002f26:	84d6                	mv	s1,s5
    80002f28:	4701                	li	a4,0
    80002f2a:	fca4f4e3          	bgeu	s1,a0,80002ef2 <balloc+0x8a>
      m = 1 << (bi % 8);
    80002f2e:	00777693          	andi	a3,a4,7
    80002f32:	00d996bb          	sllw	a3,s3,a3
      if((bp->data[bi/8] & m) == 0){  // Is block free?
    80002f36:	41f7579b          	sraiw	a5,a4,0x1f
    80002f3a:	01d7d79b          	srliw	a5,a5,0x1d
    80002f3e:	9fb9                	addw	a5,a5,a4
    80002f40:	4037d79b          	sraiw	a5,a5,0x3
    80002f44:	00f90633          	add	a2,s2,a5
    80002f48:	05864603          	lbu	a2,88(a2)
    80002f4c:	00c6f5b3          	and	a1,a3,a2
    80002f50:	d9a1                	beqz	a1,80002ea0 <balloc+0x38>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80002f52:	2705                	addiw	a4,a4,1
    80002f54:	2485                	addiw	s1,s1,1
    80002f56:	fd471ae3          	bne	a4,s4,80002f2a <balloc+0xc2>
    80002f5a:	bf61                	j	80002ef2 <balloc+0x8a>
    80002f5c:	7942                	ld	s2,48(sp)
    80002f5e:	79a2                	ld	s3,40(sp)
    80002f60:	7a02                	ld	s4,32(sp)
    80002f62:	6ae2                	ld	s5,24(sp)
    80002f64:	6b42                	ld	s6,16(sp)
    80002f66:	6ba2                	ld	s7,8(sp)
    80002f68:	6c02                	ld	s8,0(sp)
  printf("balloc: out of blocks\n");
    80002f6a:	00004517          	auipc	a0,0x4
    80002f6e:	4be50513          	addi	a0,a0,1214 # 80007428 <etext+0x428>
    80002f72:	d88fd0ef          	jal	800004fa <printf>
  return 0;
    80002f76:	4481                	li	s1,0
    80002f78:	b7bd                	j	80002ee6 <balloc+0x7e>

0000000080002f7a <bmap>:
// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
// returns 0 if out of disk space.
static uint
bmap(struct inode *ip, uint bn)
{
    80002f7a:	7179                	addi	sp,sp,-48
    80002f7c:	f406                	sd	ra,40(sp)
    80002f7e:	f022                	sd	s0,32(sp)
    80002f80:	ec26                	sd	s1,24(sp)
    80002f82:	e84a                	sd	s2,16(sp)
    80002f84:	e44e                	sd	s3,8(sp)
    80002f86:	1800                	addi	s0,sp,48
    80002f88:	89aa                	mv	s3,a0
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
    80002f8a:	47ad                	li	a5,11
    80002f8c:	02b7e363          	bltu	a5,a1,80002fb2 <bmap+0x38>
    if((addr = ip->addrs[bn]) == 0){
    80002f90:	02059793          	slli	a5,a1,0x20
    80002f94:	01e7d593          	srli	a1,a5,0x1e
    80002f98:	00b504b3          	add	s1,a0,a1
    80002f9c:	0504a903          	lw	s2,80(s1)
    80002fa0:	06091363          	bnez	s2,80003006 <bmap+0x8c>
      addr = balloc(ip->dev);
    80002fa4:	4108                	lw	a0,0(a0)
    80002fa6:	ec3ff0ef          	jal	80002e68 <balloc>
    80002faa:	892a                	mv	s2,a0
      if(addr == 0)
    80002fac:	cd29                	beqz	a0,80003006 <bmap+0x8c>
        return 0;
      ip->addrs[bn] = addr;
    80002fae:	c8a8                	sw	a0,80(s1)
    80002fb0:	a899                	j	80003006 <bmap+0x8c>
    }
    return addr;
  }
  bn -= NDIRECT;
    80002fb2:	ff45849b          	addiw	s1,a1,-12

  if(bn < NINDIRECT){
    80002fb6:	0ff00793          	li	a5,255
    80002fba:	0697e963          	bltu	a5,s1,8000302c <bmap+0xb2>
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0){
    80002fbe:	08052903          	lw	s2,128(a0)
    80002fc2:	00091b63          	bnez	s2,80002fd8 <bmap+0x5e>
      addr = balloc(ip->dev);
    80002fc6:	4108                	lw	a0,0(a0)
    80002fc8:	ea1ff0ef          	jal	80002e68 <balloc>
    80002fcc:	892a                	mv	s2,a0
      if(addr == 0)
    80002fce:	cd05                	beqz	a0,80003006 <bmap+0x8c>
    80002fd0:	e052                	sd	s4,0(sp)
        return 0;
      ip->addrs[NDIRECT] = addr;
    80002fd2:	08a9a023          	sw	a0,128(s3)
    80002fd6:	a011                	j	80002fda <bmap+0x60>
    80002fd8:	e052                	sd	s4,0(sp)
    }
    bp = bread(ip->dev, addr);
    80002fda:	85ca                	mv	a1,s2
    80002fdc:	0009a503          	lw	a0,0(s3)
    80002fe0:	c29ff0ef          	jal	80002c08 <bread>
    80002fe4:	8a2a                	mv	s4,a0
    a = (uint*)bp->data;
    80002fe6:	05850793          	addi	a5,a0,88
    if((addr = a[bn]) == 0){
    80002fea:	02049713          	slli	a4,s1,0x20
    80002fee:	01e75593          	srli	a1,a4,0x1e
    80002ff2:	00b784b3          	add	s1,a5,a1
    80002ff6:	0004a903          	lw	s2,0(s1)
    80002ffa:	00090e63          	beqz	s2,80003016 <bmap+0x9c>
      if(addr){
        a[bn] = addr;
        log_write(bp);
      }
    }
    brelse(bp);
    80002ffe:	8552                	mv	a0,s4
    80003000:	d11ff0ef          	jal	80002d10 <brelse>
    return addr;
    80003004:	6a02                	ld	s4,0(sp)
  }

  panic("bmap: out of range");
}
    80003006:	854a                	mv	a0,s2
    80003008:	70a2                	ld	ra,40(sp)
    8000300a:	7402                	ld	s0,32(sp)
    8000300c:	64e2                	ld	s1,24(sp)
    8000300e:	6942                	ld	s2,16(sp)
    80003010:	69a2                	ld	s3,8(sp)
    80003012:	6145                	addi	sp,sp,48
    80003014:	8082                	ret
      addr = balloc(ip->dev);
    80003016:	0009a503          	lw	a0,0(s3)
    8000301a:	e4fff0ef          	jal	80002e68 <balloc>
    8000301e:	892a                	mv	s2,a0
      if(addr){
    80003020:	dd79                	beqz	a0,80002ffe <bmap+0x84>
        a[bn] = addr;
    80003022:	c088                	sw	a0,0(s1)
        log_write(bp);
    80003024:	8552                	mv	a0,s4
    80003026:	617000ef          	jal	80003e3c <log_write>
    8000302a:	bfd1                	j	80002ffe <bmap+0x84>
    8000302c:	e052                	sd	s4,0(sp)
  panic("bmap: out of range");
    8000302e:	00004517          	auipc	a0,0x4
    80003032:	41250513          	addi	a0,a0,1042 # 80007440 <etext+0x440>
    80003036:	fa8fd0ef          	jal	800007de <panic>

000000008000303a <iget>:
{
    8000303a:	7179                	addi	sp,sp,-48
    8000303c:	f406                	sd	ra,40(sp)
    8000303e:	f022                	sd	s0,32(sp)
    80003040:	ec26                	sd	s1,24(sp)
    80003042:	e84a                	sd	s2,16(sp)
    80003044:	e44e                	sd	s3,8(sp)
    80003046:	e052                	sd	s4,0(sp)
    80003048:	1800                	addi	s0,sp,48
    8000304a:	89aa                	mv	s3,a0
    8000304c:	8a2e                	mv	s4,a1
  acquire(&itable.lock);
    8000304e:	0001b517          	auipc	a0,0x1b
    80003052:	ea250513          	addi	a0,a0,-350 # 8001def0 <itable>
    80003056:	b77fd0ef          	jal	80000bcc <acquire>
  empty = 0;
    8000305a:	4901                	li	s2,0
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    8000305c:	0001b497          	auipc	s1,0x1b
    80003060:	eac48493          	addi	s1,s1,-340 # 8001df08 <itable+0x18>
    80003064:	0001d697          	auipc	a3,0x1d
    80003068:	93468693          	addi	a3,a3,-1740 # 8001f998 <log>
    8000306c:	a039                	j	8000307a <iget+0x40>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    8000306e:	02090963          	beqz	s2,800030a0 <iget+0x66>
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    80003072:	08848493          	addi	s1,s1,136
    80003076:	02d48863          	beq	s1,a3,800030a6 <iget+0x6c>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
    8000307a:	449c                	lw	a5,8(s1)
    8000307c:	fef059e3          	blez	a5,8000306e <iget+0x34>
    80003080:	4098                	lw	a4,0(s1)
    80003082:	ff3716e3          	bne	a4,s3,8000306e <iget+0x34>
    80003086:	40d8                	lw	a4,4(s1)
    80003088:	ff4713e3          	bne	a4,s4,8000306e <iget+0x34>
      ip->ref++;
    8000308c:	2785                	addiw	a5,a5,1
    8000308e:	c49c                	sw	a5,8(s1)
      release(&itable.lock);
    80003090:	0001b517          	auipc	a0,0x1b
    80003094:	e6050513          	addi	a0,a0,-416 # 8001def0 <itable>
    80003098:	bc9fd0ef          	jal	80000c60 <release>
      return ip;
    8000309c:	8926                	mv	s2,s1
    8000309e:	a02d                	j	800030c8 <iget+0x8e>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    800030a0:	fbe9                	bnez	a5,80003072 <iget+0x38>
      empty = ip;
    800030a2:	8926                	mv	s2,s1
    800030a4:	b7f9                	j	80003072 <iget+0x38>
  if(empty == 0)
    800030a6:	02090a63          	beqz	s2,800030da <iget+0xa0>
  ip->dev = dev;
    800030aa:	01392023          	sw	s3,0(s2)
  ip->inum = inum;
    800030ae:	01492223          	sw	s4,4(s2)
  ip->ref = 1;
    800030b2:	4785                	li	a5,1
    800030b4:	00f92423          	sw	a5,8(s2)
  ip->valid = 0;
    800030b8:	04092023          	sw	zero,64(s2)
  release(&itable.lock);
    800030bc:	0001b517          	auipc	a0,0x1b
    800030c0:	e3450513          	addi	a0,a0,-460 # 8001def0 <itable>
    800030c4:	b9dfd0ef          	jal	80000c60 <release>
}
    800030c8:	854a                	mv	a0,s2
    800030ca:	70a2                	ld	ra,40(sp)
    800030cc:	7402                	ld	s0,32(sp)
    800030ce:	64e2                	ld	s1,24(sp)
    800030d0:	6942                	ld	s2,16(sp)
    800030d2:	69a2                	ld	s3,8(sp)
    800030d4:	6a02                	ld	s4,0(sp)
    800030d6:	6145                	addi	sp,sp,48
    800030d8:	8082                	ret
    panic("iget: no inodes");
    800030da:	00004517          	auipc	a0,0x4
    800030de:	37e50513          	addi	a0,a0,894 # 80007458 <etext+0x458>
    800030e2:	efcfd0ef          	jal	800007de <panic>

00000000800030e6 <iinit>:
{
    800030e6:	7179                	addi	sp,sp,-48
    800030e8:	f406                	sd	ra,40(sp)
    800030ea:	f022                	sd	s0,32(sp)
    800030ec:	ec26                	sd	s1,24(sp)
    800030ee:	e84a                	sd	s2,16(sp)
    800030f0:	e44e                	sd	s3,8(sp)
    800030f2:	1800                	addi	s0,sp,48
  initlock(&itable.lock, "itable");
    800030f4:	00004597          	auipc	a1,0x4
    800030f8:	37458593          	addi	a1,a1,884 # 80007468 <etext+0x468>
    800030fc:	0001b517          	auipc	a0,0x1b
    80003100:	df450513          	addi	a0,a0,-524 # 8001def0 <itable>
    80003104:	a45fd0ef          	jal	80000b48 <initlock>
  for(i = 0; i < NINODE; i++) {
    80003108:	0001b497          	auipc	s1,0x1b
    8000310c:	e1048493          	addi	s1,s1,-496 # 8001df18 <itable+0x28>
    80003110:	0001d997          	auipc	s3,0x1d
    80003114:	89898993          	addi	s3,s3,-1896 # 8001f9a8 <log+0x10>
    initsleeplock(&itable.inode[i].lock, "inode");
    80003118:	00004917          	auipc	s2,0x4
    8000311c:	35890913          	addi	s2,s2,856 # 80007470 <etext+0x470>
    80003120:	85ca                	mv	a1,s2
    80003122:	8526                	mv	a0,s1
    80003124:	5db000ef          	jal	80003efe <initsleeplock>
  for(i = 0; i < NINODE; i++) {
    80003128:	08848493          	addi	s1,s1,136
    8000312c:	ff349ae3          	bne	s1,s3,80003120 <iinit+0x3a>
}
    80003130:	70a2                	ld	ra,40(sp)
    80003132:	7402                	ld	s0,32(sp)
    80003134:	64e2                	ld	s1,24(sp)
    80003136:	6942                	ld	s2,16(sp)
    80003138:	69a2                	ld	s3,8(sp)
    8000313a:	6145                	addi	sp,sp,48
    8000313c:	8082                	ret

000000008000313e <ialloc>:
{
    8000313e:	7139                	addi	sp,sp,-64
    80003140:	fc06                	sd	ra,56(sp)
    80003142:	f822                	sd	s0,48(sp)
    80003144:	0080                	addi	s0,sp,64
  for(inum = 1; inum < sb.ninodes; inum++){
    80003146:	0001b717          	auipc	a4,0x1b
    8000314a:	d9672703          	lw	a4,-618(a4) # 8001dedc <sb+0xc>
    8000314e:	4785                	li	a5,1
    80003150:	06e7f063          	bgeu	a5,a4,800031b0 <ialloc+0x72>
    80003154:	f426                	sd	s1,40(sp)
    80003156:	f04a                	sd	s2,32(sp)
    80003158:	ec4e                	sd	s3,24(sp)
    8000315a:	e852                	sd	s4,16(sp)
    8000315c:	e456                	sd	s5,8(sp)
    8000315e:	e05a                	sd	s6,0(sp)
    80003160:	8aaa                	mv	s5,a0
    80003162:	8b2e                	mv	s6,a1
    80003164:	893e                	mv	s2,a5
    bp = bread(dev, IBLOCK(inum, sb));
    80003166:	0001ba17          	auipc	s4,0x1b
    8000316a:	d6aa0a13          	addi	s4,s4,-662 # 8001ded0 <sb>
    8000316e:	00495593          	srli	a1,s2,0x4
    80003172:	018a2783          	lw	a5,24(s4)
    80003176:	9dbd                	addw	a1,a1,a5
    80003178:	8556                	mv	a0,s5
    8000317a:	a8fff0ef          	jal	80002c08 <bread>
    8000317e:	84aa                	mv	s1,a0
    dip = (struct dinode*)bp->data + inum%IPB;
    80003180:	05850993          	addi	s3,a0,88
    80003184:	00f97793          	andi	a5,s2,15
    80003188:	079a                	slli	a5,a5,0x6
    8000318a:	99be                	add	s3,s3,a5
    if(dip->type == 0){  // a free inode
    8000318c:	00099783          	lh	a5,0(s3)
    80003190:	cb9d                	beqz	a5,800031c6 <ialloc+0x88>
    brelse(bp);
    80003192:	b7fff0ef          	jal	80002d10 <brelse>
  for(inum = 1; inum < sb.ninodes; inum++){
    80003196:	0905                	addi	s2,s2,1
    80003198:	00ca2703          	lw	a4,12(s4)
    8000319c:	0009079b          	sext.w	a5,s2
    800031a0:	fce7e7e3          	bltu	a5,a4,8000316e <ialloc+0x30>
    800031a4:	74a2                	ld	s1,40(sp)
    800031a6:	7902                	ld	s2,32(sp)
    800031a8:	69e2                	ld	s3,24(sp)
    800031aa:	6a42                	ld	s4,16(sp)
    800031ac:	6aa2                	ld	s5,8(sp)
    800031ae:	6b02                	ld	s6,0(sp)
  printf("ialloc: no inodes\n");
    800031b0:	00004517          	auipc	a0,0x4
    800031b4:	2c850513          	addi	a0,a0,712 # 80007478 <etext+0x478>
    800031b8:	b42fd0ef          	jal	800004fa <printf>
  return 0;
    800031bc:	4501                	li	a0,0
}
    800031be:	70e2                	ld	ra,56(sp)
    800031c0:	7442                	ld	s0,48(sp)
    800031c2:	6121                	addi	sp,sp,64
    800031c4:	8082                	ret
      memset(dip, 0, sizeof(*dip));
    800031c6:	04000613          	li	a2,64
    800031ca:	4581                	li	a1,0
    800031cc:	854e                	mv	a0,s3
    800031ce:	acffd0ef          	jal	80000c9c <memset>
      dip->type = type;
    800031d2:	01699023          	sh	s6,0(s3)
      log_write(bp);   // mark it allocated on the disk
    800031d6:	8526                	mv	a0,s1
    800031d8:	465000ef          	jal	80003e3c <log_write>
      brelse(bp);
    800031dc:	8526                	mv	a0,s1
    800031de:	b33ff0ef          	jal	80002d10 <brelse>
      return iget(dev, inum);
    800031e2:	0009059b          	sext.w	a1,s2
    800031e6:	8556                	mv	a0,s5
    800031e8:	e53ff0ef          	jal	8000303a <iget>
    800031ec:	74a2                	ld	s1,40(sp)
    800031ee:	7902                	ld	s2,32(sp)
    800031f0:	69e2                	ld	s3,24(sp)
    800031f2:	6a42                	ld	s4,16(sp)
    800031f4:	6aa2                	ld	s5,8(sp)
    800031f6:	6b02                	ld	s6,0(sp)
    800031f8:	b7d9                	j	800031be <ialloc+0x80>

00000000800031fa <iupdate>:
{
    800031fa:	1101                	addi	sp,sp,-32
    800031fc:	ec06                	sd	ra,24(sp)
    800031fe:	e822                	sd	s0,16(sp)
    80003200:	e426                	sd	s1,8(sp)
    80003202:	e04a                	sd	s2,0(sp)
    80003204:	1000                	addi	s0,sp,32
    80003206:	84aa                	mv	s1,a0
  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    80003208:	415c                	lw	a5,4(a0)
    8000320a:	0047d79b          	srliw	a5,a5,0x4
    8000320e:	0001b597          	auipc	a1,0x1b
    80003212:	cda5a583          	lw	a1,-806(a1) # 8001dee8 <sb+0x18>
    80003216:	9dbd                	addw	a1,a1,a5
    80003218:	4108                	lw	a0,0(a0)
    8000321a:	9efff0ef          	jal	80002c08 <bread>
    8000321e:	892a                	mv	s2,a0
  dip = (struct dinode*)bp->data + ip->inum%IPB;
    80003220:	05850793          	addi	a5,a0,88
    80003224:	40d8                	lw	a4,4(s1)
    80003226:	8b3d                	andi	a4,a4,15
    80003228:	071a                	slli	a4,a4,0x6
    8000322a:	97ba                	add	a5,a5,a4
  dip->type = ip->type;
    8000322c:	04449703          	lh	a4,68(s1)
    80003230:	00e79023          	sh	a4,0(a5)
  dip->major = ip->major;
    80003234:	04649703          	lh	a4,70(s1)
    80003238:	00e79123          	sh	a4,2(a5)
  dip->minor = ip->minor;
    8000323c:	04849703          	lh	a4,72(s1)
    80003240:	00e79223          	sh	a4,4(a5)
  dip->nlink = ip->nlink;
    80003244:	04a49703          	lh	a4,74(s1)
    80003248:	00e79323          	sh	a4,6(a5)
  dip->size = ip->size;
    8000324c:	44f8                	lw	a4,76(s1)
    8000324e:	c798                	sw	a4,8(a5)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
    80003250:	03400613          	li	a2,52
    80003254:	05048593          	addi	a1,s1,80
    80003258:	00c78513          	addi	a0,a5,12
    8000325c:	aa5fd0ef          	jal	80000d00 <memmove>
  log_write(bp);
    80003260:	854a                	mv	a0,s2
    80003262:	3db000ef          	jal	80003e3c <log_write>
  brelse(bp);
    80003266:	854a                	mv	a0,s2
    80003268:	aa9ff0ef          	jal	80002d10 <brelse>
}
    8000326c:	60e2                	ld	ra,24(sp)
    8000326e:	6442                	ld	s0,16(sp)
    80003270:	64a2                	ld	s1,8(sp)
    80003272:	6902                	ld	s2,0(sp)
    80003274:	6105                	addi	sp,sp,32
    80003276:	8082                	ret

0000000080003278 <idup>:
{
    80003278:	1101                	addi	sp,sp,-32
    8000327a:	ec06                	sd	ra,24(sp)
    8000327c:	e822                	sd	s0,16(sp)
    8000327e:	e426                	sd	s1,8(sp)
    80003280:	1000                	addi	s0,sp,32
    80003282:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    80003284:	0001b517          	auipc	a0,0x1b
    80003288:	c6c50513          	addi	a0,a0,-916 # 8001def0 <itable>
    8000328c:	941fd0ef          	jal	80000bcc <acquire>
  ip->ref++;
    80003290:	449c                	lw	a5,8(s1)
    80003292:	2785                	addiw	a5,a5,1
    80003294:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    80003296:	0001b517          	auipc	a0,0x1b
    8000329a:	c5a50513          	addi	a0,a0,-934 # 8001def0 <itable>
    8000329e:	9c3fd0ef          	jal	80000c60 <release>
}
    800032a2:	8526                	mv	a0,s1
    800032a4:	60e2                	ld	ra,24(sp)
    800032a6:	6442                	ld	s0,16(sp)
    800032a8:	64a2                	ld	s1,8(sp)
    800032aa:	6105                	addi	sp,sp,32
    800032ac:	8082                	ret

00000000800032ae <ilock>:
{
    800032ae:	1101                	addi	sp,sp,-32
    800032b0:	ec06                	sd	ra,24(sp)
    800032b2:	e822                	sd	s0,16(sp)
    800032b4:	e426                	sd	s1,8(sp)
    800032b6:	1000                	addi	s0,sp,32
  if(ip == 0 || ip->ref < 1)
    800032b8:	cd19                	beqz	a0,800032d6 <ilock+0x28>
    800032ba:	84aa                	mv	s1,a0
    800032bc:	451c                	lw	a5,8(a0)
    800032be:	00f05c63          	blez	a5,800032d6 <ilock+0x28>
  acquiresleep(&ip->lock);
    800032c2:	0541                	addi	a0,a0,16
    800032c4:	471000ef          	jal	80003f34 <acquiresleep>
  if(ip->valid == 0){
    800032c8:	40bc                	lw	a5,64(s1)
    800032ca:	cf89                	beqz	a5,800032e4 <ilock+0x36>
}
    800032cc:	60e2                	ld	ra,24(sp)
    800032ce:	6442                	ld	s0,16(sp)
    800032d0:	64a2                	ld	s1,8(sp)
    800032d2:	6105                	addi	sp,sp,32
    800032d4:	8082                	ret
    800032d6:	e04a                	sd	s2,0(sp)
    panic("ilock");
    800032d8:	00004517          	auipc	a0,0x4
    800032dc:	1b850513          	addi	a0,a0,440 # 80007490 <etext+0x490>
    800032e0:	cfefd0ef          	jal	800007de <panic>
    800032e4:	e04a                	sd	s2,0(sp)
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    800032e6:	40dc                	lw	a5,4(s1)
    800032e8:	0047d79b          	srliw	a5,a5,0x4
    800032ec:	0001b597          	auipc	a1,0x1b
    800032f0:	bfc5a583          	lw	a1,-1028(a1) # 8001dee8 <sb+0x18>
    800032f4:	9dbd                	addw	a1,a1,a5
    800032f6:	4088                	lw	a0,0(s1)
    800032f8:	911ff0ef          	jal	80002c08 <bread>
    800032fc:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + ip->inum%IPB;
    800032fe:	05850593          	addi	a1,a0,88
    80003302:	40dc                	lw	a5,4(s1)
    80003304:	8bbd                	andi	a5,a5,15
    80003306:	079a                	slli	a5,a5,0x6
    80003308:	95be                	add	a1,a1,a5
    ip->type = dip->type;
    8000330a:	00059783          	lh	a5,0(a1)
    8000330e:	04f49223          	sh	a5,68(s1)
    ip->major = dip->major;
    80003312:	00259783          	lh	a5,2(a1)
    80003316:	04f49323          	sh	a5,70(s1)
    ip->minor = dip->minor;
    8000331a:	00459783          	lh	a5,4(a1)
    8000331e:	04f49423          	sh	a5,72(s1)
    ip->nlink = dip->nlink;
    80003322:	00659783          	lh	a5,6(a1)
    80003326:	04f49523          	sh	a5,74(s1)
    ip->size = dip->size;
    8000332a:	459c                	lw	a5,8(a1)
    8000332c:	c4fc                	sw	a5,76(s1)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
    8000332e:	03400613          	li	a2,52
    80003332:	05b1                	addi	a1,a1,12
    80003334:	05048513          	addi	a0,s1,80
    80003338:	9c9fd0ef          	jal	80000d00 <memmove>
    brelse(bp);
    8000333c:	854a                	mv	a0,s2
    8000333e:	9d3ff0ef          	jal	80002d10 <brelse>
    ip->valid = 1;
    80003342:	4785                	li	a5,1
    80003344:	c0bc                	sw	a5,64(s1)
    if(ip->type == 0)
    80003346:	04449783          	lh	a5,68(s1)
    8000334a:	c399                	beqz	a5,80003350 <ilock+0xa2>
    8000334c:	6902                	ld	s2,0(sp)
    8000334e:	bfbd                	j	800032cc <ilock+0x1e>
      panic("ilock: no type");
    80003350:	00004517          	auipc	a0,0x4
    80003354:	14850513          	addi	a0,a0,328 # 80007498 <etext+0x498>
    80003358:	c86fd0ef          	jal	800007de <panic>

000000008000335c <iunlock>:
{
    8000335c:	1101                	addi	sp,sp,-32
    8000335e:	ec06                	sd	ra,24(sp)
    80003360:	e822                	sd	s0,16(sp)
    80003362:	e426                	sd	s1,8(sp)
    80003364:	e04a                	sd	s2,0(sp)
    80003366:	1000                	addi	s0,sp,32
  if(ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
    80003368:	c505                	beqz	a0,80003390 <iunlock+0x34>
    8000336a:	84aa                	mv	s1,a0
    8000336c:	01050913          	addi	s2,a0,16
    80003370:	854a                	mv	a0,s2
    80003372:	441000ef          	jal	80003fb2 <holdingsleep>
    80003376:	cd09                	beqz	a0,80003390 <iunlock+0x34>
    80003378:	449c                	lw	a5,8(s1)
    8000337a:	00f05b63          	blez	a5,80003390 <iunlock+0x34>
  releasesleep(&ip->lock);
    8000337e:	854a                	mv	a0,s2
    80003380:	3fb000ef          	jal	80003f7a <releasesleep>
}
    80003384:	60e2                	ld	ra,24(sp)
    80003386:	6442                	ld	s0,16(sp)
    80003388:	64a2                	ld	s1,8(sp)
    8000338a:	6902                	ld	s2,0(sp)
    8000338c:	6105                	addi	sp,sp,32
    8000338e:	8082                	ret
    panic("iunlock");
    80003390:	00004517          	auipc	a0,0x4
    80003394:	11850513          	addi	a0,a0,280 # 800074a8 <etext+0x4a8>
    80003398:	c46fd0ef          	jal	800007de <panic>

000000008000339c <itrunc>:

// Truncate inode (discard contents).
// Caller must hold ip->lock.
void
itrunc(struct inode *ip)
{
    8000339c:	7179                	addi	sp,sp,-48
    8000339e:	f406                	sd	ra,40(sp)
    800033a0:	f022                	sd	s0,32(sp)
    800033a2:	ec26                	sd	s1,24(sp)
    800033a4:	e84a                	sd	s2,16(sp)
    800033a6:	e44e                	sd	s3,8(sp)
    800033a8:	1800                	addi	s0,sp,48
    800033aa:	89aa                	mv	s3,a0
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
    800033ac:	05050493          	addi	s1,a0,80
    800033b0:	08050913          	addi	s2,a0,128
    800033b4:	a021                	j	800033bc <itrunc+0x20>
    800033b6:	0491                	addi	s1,s1,4
    800033b8:	01248b63          	beq	s1,s2,800033ce <itrunc+0x32>
    if(ip->addrs[i]){
    800033bc:	408c                	lw	a1,0(s1)
    800033be:	dde5                	beqz	a1,800033b6 <itrunc+0x1a>
      bfree(ip->dev, ip->addrs[i]);
    800033c0:	0009a503          	lw	a0,0(s3)
    800033c4:	a39ff0ef          	jal	80002dfc <bfree>
      ip->addrs[i] = 0;
    800033c8:	0004a023          	sw	zero,0(s1)
    800033cc:	b7ed                	j	800033b6 <itrunc+0x1a>
    }
  }

  if(ip->addrs[NDIRECT]){
    800033ce:	0809a583          	lw	a1,128(s3)
    800033d2:	ed89                	bnez	a1,800033ec <itrunc+0x50>
    brelse(bp);
    bfree(ip->dev, ip->addrs[NDIRECT]);
    ip->addrs[NDIRECT] = 0;
  }

  ip->size = 0;
    800033d4:	0409a623          	sw	zero,76(s3)
  iupdate(ip);
    800033d8:	854e                	mv	a0,s3
    800033da:	e21ff0ef          	jal	800031fa <iupdate>
}
    800033de:	70a2                	ld	ra,40(sp)
    800033e0:	7402                	ld	s0,32(sp)
    800033e2:	64e2                	ld	s1,24(sp)
    800033e4:	6942                	ld	s2,16(sp)
    800033e6:	69a2                	ld	s3,8(sp)
    800033e8:	6145                	addi	sp,sp,48
    800033ea:	8082                	ret
    800033ec:	e052                	sd	s4,0(sp)
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
    800033ee:	0009a503          	lw	a0,0(s3)
    800033f2:	817ff0ef          	jal	80002c08 <bread>
    800033f6:	8a2a                	mv	s4,a0
    for(j = 0; j < NINDIRECT; j++){
    800033f8:	05850493          	addi	s1,a0,88
    800033fc:	45850913          	addi	s2,a0,1112
    80003400:	a021                	j	80003408 <itrunc+0x6c>
    80003402:	0491                	addi	s1,s1,4
    80003404:	01248963          	beq	s1,s2,80003416 <itrunc+0x7a>
      if(a[j])
    80003408:	408c                	lw	a1,0(s1)
    8000340a:	dde5                	beqz	a1,80003402 <itrunc+0x66>
        bfree(ip->dev, a[j]);
    8000340c:	0009a503          	lw	a0,0(s3)
    80003410:	9edff0ef          	jal	80002dfc <bfree>
    80003414:	b7fd                	j	80003402 <itrunc+0x66>
    brelse(bp);
    80003416:	8552                	mv	a0,s4
    80003418:	8f9ff0ef          	jal	80002d10 <brelse>
    bfree(ip->dev, ip->addrs[NDIRECT]);
    8000341c:	0809a583          	lw	a1,128(s3)
    80003420:	0009a503          	lw	a0,0(s3)
    80003424:	9d9ff0ef          	jal	80002dfc <bfree>
    ip->addrs[NDIRECT] = 0;
    80003428:	0809a023          	sw	zero,128(s3)
    8000342c:	6a02                	ld	s4,0(sp)
    8000342e:	b75d                	j	800033d4 <itrunc+0x38>

0000000080003430 <iput>:
{
    80003430:	1101                	addi	sp,sp,-32
    80003432:	ec06                	sd	ra,24(sp)
    80003434:	e822                	sd	s0,16(sp)
    80003436:	e426                	sd	s1,8(sp)
    80003438:	1000                	addi	s0,sp,32
    8000343a:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    8000343c:	0001b517          	auipc	a0,0x1b
    80003440:	ab450513          	addi	a0,a0,-1356 # 8001def0 <itable>
    80003444:	f88fd0ef          	jal	80000bcc <acquire>
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    80003448:	4498                	lw	a4,8(s1)
    8000344a:	4785                	li	a5,1
    8000344c:	02f70063          	beq	a4,a5,8000346c <iput+0x3c>
  ip->ref--;
    80003450:	449c                	lw	a5,8(s1)
    80003452:	37fd                	addiw	a5,a5,-1
    80003454:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    80003456:	0001b517          	auipc	a0,0x1b
    8000345a:	a9a50513          	addi	a0,a0,-1382 # 8001def0 <itable>
    8000345e:	803fd0ef          	jal	80000c60 <release>
}
    80003462:	60e2                	ld	ra,24(sp)
    80003464:	6442                	ld	s0,16(sp)
    80003466:	64a2                	ld	s1,8(sp)
    80003468:	6105                	addi	sp,sp,32
    8000346a:	8082                	ret
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    8000346c:	40bc                	lw	a5,64(s1)
    8000346e:	d3ed                	beqz	a5,80003450 <iput+0x20>
    80003470:	04a49783          	lh	a5,74(s1)
    80003474:	fff1                	bnez	a5,80003450 <iput+0x20>
    80003476:	e04a                	sd	s2,0(sp)
    acquiresleep(&ip->lock);
    80003478:	01048913          	addi	s2,s1,16
    8000347c:	854a                	mv	a0,s2
    8000347e:	2b7000ef          	jal	80003f34 <acquiresleep>
    release(&itable.lock);
    80003482:	0001b517          	auipc	a0,0x1b
    80003486:	a6e50513          	addi	a0,a0,-1426 # 8001def0 <itable>
    8000348a:	fd6fd0ef          	jal	80000c60 <release>
    itrunc(ip);
    8000348e:	8526                	mv	a0,s1
    80003490:	f0dff0ef          	jal	8000339c <itrunc>
    ip->type = 0;
    80003494:	04049223          	sh	zero,68(s1)
    iupdate(ip);
    80003498:	8526                	mv	a0,s1
    8000349a:	d61ff0ef          	jal	800031fa <iupdate>
    ip->valid = 0;
    8000349e:	0404a023          	sw	zero,64(s1)
    releasesleep(&ip->lock);
    800034a2:	854a                	mv	a0,s2
    800034a4:	2d7000ef          	jal	80003f7a <releasesleep>
    acquire(&itable.lock);
    800034a8:	0001b517          	auipc	a0,0x1b
    800034ac:	a4850513          	addi	a0,a0,-1464 # 8001def0 <itable>
    800034b0:	f1cfd0ef          	jal	80000bcc <acquire>
    800034b4:	6902                	ld	s2,0(sp)
    800034b6:	bf69                	j	80003450 <iput+0x20>

00000000800034b8 <iunlockput>:
{
    800034b8:	1101                	addi	sp,sp,-32
    800034ba:	ec06                	sd	ra,24(sp)
    800034bc:	e822                	sd	s0,16(sp)
    800034be:	e426                	sd	s1,8(sp)
    800034c0:	1000                	addi	s0,sp,32
    800034c2:	84aa                	mv	s1,a0
  iunlock(ip);
    800034c4:	e99ff0ef          	jal	8000335c <iunlock>
  iput(ip);
    800034c8:	8526                	mv	a0,s1
    800034ca:	f67ff0ef          	jal	80003430 <iput>
}
    800034ce:	60e2                	ld	ra,24(sp)
    800034d0:	6442                	ld	s0,16(sp)
    800034d2:	64a2                	ld	s1,8(sp)
    800034d4:	6105                	addi	sp,sp,32
    800034d6:	8082                	ret

00000000800034d8 <ireclaim>:
  for (int inum = 1; inum < sb.ninodes; inum++) {
    800034d8:	0001b717          	auipc	a4,0x1b
    800034dc:	a0472703          	lw	a4,-1532(a4) # 8001dedc <sb+0xc>
    800034e0:	4785                	li	a5,1
    800034e2:	0ae7fe63          	bgeu	a5,a4,8000359e <ireclaim+0xc6>
{
    800034e6:	7139                	addi	sp,sp,-64
    800034e8:	fc06                	sd	ra,56(sp)
    800034ea:	f822                	sd	s0,48(sp)
    800034ec:	f426                	sd	s1,40(sp)
    800034ee:	f04a                	sd	s2,32(sp)
    800034f0:	ec4e                	sd	s3,24(sp)
    800034f2:	e852                	sd	s4,16(sp)
    800034f4:	e456                	sd	s5,8(sp)
    800034f6:	e05a                	sd	s6,0(sp)
    800034f8:	0080                	addi	s0,sp,64
    800034fa:	8aaa                	mv	s5,a0
  for (int inum = 1; inum < sb.ninodes; inum++) {
    800034fc:	84be                	mv	s1,a5
    struct buf *bp = bread(dev, IBLOCK(inum, sb));
    800034fe:	0001ba17          	auipc	s4,0x1b
    80003502:	9d2a0a13          	addi	s4,s4,-1582 # 8001ded0 <sb>
      printf("ireclaim: orphaned inode %d\n", inum);
    80003506:	00004b17          	auipc	s6,0x4
    8000350a:	faab0b13          	addi	s6,s6,-86 # 800074b0 <etext+0x4b0>
    8000350e:	a099                	j	80003554 <ireclaim+0x7c>
    80003510:	85ce                	mv	a1,s3
    80003512:	855a                	mv	a0,s6
    80003514:	fe7fc0ef          	jal	800004fa <printf>
      ip = iget(dev, inum);
    80003518:	85ce                	mv	a1,s3
    8000351a:	8556                	mv	a0,s5
    8000351c:	b1fff0ef          	jal	8000303a <iget>
    80003520:	89aa                	mv	s3,a0
    brelse(bp);
    80003522:	854a                	mv	a0,s2
    80003524:	fecff0ef          	jal	80002d10 <brelse>
    if (ip) {
    80003528:	00098f63          	beqz	s3,80003546 <ireclaim+0x6e>
      begin_op();
    8000352c:	786000ef          	jal	80003cb2 <begin_op>
      ilock(ip);
    80003530:	854e                	mv	a0,s3
    80003532:	d7dff0ef          	jal	800032ae <ilock>
      iunlock(ip);
    80003536:	854e                	mv	a0,s3
    80003538:	e25ff0ef          	jal	8000335c <iunlock>
      iput(ip);
    8000353c:	854e                	mv	a0,s3
    8000353e:	ef3ff0ef          	jal	80003430 <iput>
      end_op();
    80003542:	7da000ef          	jal	80003d1c <end_op>
  for (int inum = 1; inum < sb.ninodes; inum++) {
    80003546:	0485                	addi	s1,s1,1
    80003548:	00ca2703          	lw	a4,12(s4)
    8000354c:	0004879b          	sext.w	a5,s1
    80003550:	02e7fd63          	bgeu	a5,a4,8000358a <ireclaim+0xb2>
    80003554:	0004899b          	sext.w	s3,s1
    struct buf *bp = bread(dev, IBLOCK(inum, sb));
    80003558:	0044d593          	srli	a1,s1,0x4
    8000355c:	018a2783          	lw	a5,24(s4)
    80003560:	9dbd                	addw	a1,a1,a5
    80003562:	8556                	mv	a0,s5
    80003564:	ea4ff0ef          	jal	80002c08 <bread>
    80003568:	892a                	mv	s2,a0
    struct dinode *dip = (struct dinode *)bp->data + inum % IPB;
    8000356a:	05850793          	addi	a5,a0,88
    8000356e:	00f9f713          	andi	a4,s3,15
    80003572:	071a                	slli	a4,a4,0x6
    80003574:	97ba                	add	a5,a5,a4
    if (dip->type != 0 && dip->nlink == 0) {  // is an orphaned inode
    80003576:	00079703          	lh	a4,0(a5)
    8000357a:	c701                	beqz	a4,80003582 <ireclaim+0xaa>
    8000357c:	00679783          	lh	a5,6(a5)
    80003580:	dbc1                	beqz	a5,80003510 <ireclaim+0x38>
    brelse(bp);
    80003582:	854a                	mv	a0,s2
    80003584:	f8cff0ef          	jal	80002d10 <brelse>
    if (ip) {
    80003588:	bf7d                	j	80003546 <ireclaim+0x6e>
}
    8000358a:	70e2                	ld	ra,56(sp)
    8000358c:	7442                	ld	s0,48(sp)
    8000358e:	74a2                	ld	s1,40(sp)
    80003590:	7902                	ld	s2,32(sp)
    80003592:	69e2                	ld	s3,24(sp)
    80003594:	6a42                	ld	s4,16(sp)
    80003596:	6aa2                	ld	s5,8(sp)
    80003598:	6b02                	ld	s6,0(sp)
    8000359a:	6121                	addi	sp,sp,64
    8000359c:	8082                	ret
    8000359e:	8082                	ret

00000000800035a0 <fsinit>:
fsinit(int dev) {
    800035a0:	7179                	addi	sp,sp,-48
    800035a2:	f406                	sd	ra,40(sp)
    800035a4:	f022                	sd	s0,32(sp)
    800035a6:	ec26                	sd	s1,24(sp)
    800035a8:	e84a                	sd	s2,16(sp)
    800035aa:	e44e                	sd	s3,8(sp)
    800035ac:	1800                	addi	s0,sp,48
    800035ae:	892a                	mv	s2,a0
  bp = bread(dev, 1);
    800035b0:	4585                	li	a1,1
    800035b2:	e56ff0ef          	jal	80002c08 <bread>
    800035b6:	84aa                	mv	s1,a0
  memmove(sb, bp->data, sizeof(*sb));
    800035b8:	0001b997          	auipc	s3,0x1b
    800035bc:	91898993          	addi	s3,s3,-1768 # 8001ded0 <sb>
    800035c0:	02000613          	li	a2,32
    800035c4:	05850593          	addi	a1,a0,88
    800035c8:	854e                	mv	a0,s3
    800035ca:	f36fd0ef          	jal	80000d00 <memmove>
  brelse(bp);
    800035ce:	8526                	mv	a0,s1
    800035d0:	f40ff0ef          	jal	80002d10 <brelse>
  if(sb.magic != FSMAGIC)
    800035d4:	0009a703          	lw	a4,0(s3)
    800035d8:	102037b7          	lui	a5,0x10203
    800035dc:	04078793          	addi	a5,a5,64 # 10203040 <_entry-0x6fdfcfc0>
    800035e0:	02f71363          	bne	a4,a5,80003606 <fsinit+0x66>
  initlog(dev, &sb);
    800035e4:	0001b597          	auipc	a1,0x1b
    800035e8:	8ec58593          	addi	a1,a1,-1812 # 8001ded0 <sb>
    800035ec:	854a                	mv	a0,s2
    800035ee:	646000ef          	jal	80003c34 <initlog>
  ireclaim(dev);
    800035f2:	854a                	mv	a0,s2
    800035f4:	ee5ff0ef          	jal	800034d8 <ireclaim>
}
    800035f8:	70a2                	ld	ra,40(sp)
    800035fa:	7402                	ld	s0,32(sp)
    800035fc:	64e2                	ld	s1,24(sp)
    800035fe:	6942                	ld	s2,16(sp)
    80003600:	69a2                	ld	s3,8(sp)
    80003602:	6145                	addi	sp,sp,48
    80003604:	8082                	ret
    panic("invalid file system");
    80003606:	00004517          	auipc	a0,0x4
    8000360a:	eca50513          	addi	a0,a0,-310 # 800074d0 <etext+0x4d0>
    8000360e:	9d0fd0ef          	jal	800007de <panic>

0000000080003612 <stati>:

// Copy stat information from inode.
// Caller must hold ip->lock.
void
stati(struct inode *ip, struct stat *st)
{
    80003612:	1141                	addi	sp,sp,-16
    80003614:	e406                	sd	ra,8(sp)
    80003616:	e022                	sd	s0,0(sp)
    80003618:	0800                	addi	s0,sp,16
  st->dev = ip->dev;
    8000361a:	411c                	lw	a5,0(a0)
    8000361c:	c19c                	sw	a5,0(a1)
  st->ino = ip->inum;
    8000361e:	415c                	lw	a5,4(a0)
    80003620:	c1dc                	sw	a5,4(a1)
  st->type = ip->type;
    80003622:	04451783          	lh	a5,68(a0)
    80003626:	00f59423          	sh	a5,8(a1)
  st->nlink = ip->nlink;
    8000362a:	04a51783          	lh	a5,74(a0)
    8000362e:	00f59523          	sh	a5,10(a1)
  st->size = ip->size;
    80003632:	04c56783          	lwu	a5,76(a0)
    80003636:	e99c                	sd	a5,16(a1)
}
    80003638:	60a2                	ld	ra,8(sp)
    8000363a:	6402                	ld	s0,0(sp)
    8000363c:	0141                	addi	sp,sp,16
    8000363e:	8082                	ret

0000000080003640 <readi>:
readi(struct inode *ip, int user_dst, uint64 dst, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    80003640:	457c                	lw	a5,76(a0)
    80003642:	0ed7e663          	bltu	a5,a3,8000372e <readi+0xee>
{
    80003646:	7159                	addi	sp,sp,-112
    80003648:	f486                	sd	ra,104(sp)
    8000364a:	f0a2                	sd	s0,96(sp)
    8000364c:	eca6                	sd	s1,88(sp)
    8000364e:	e0d2                	sd	s4,64(sp)
    80003650:	fc56                	sd	s5,56(sp)
    80003652:	f85a                	sd	s6,48(sp)
    80003654:	f45e                	sd	s7,40(sp)
    80003656:	1880                	addi	s0,sp,112
    80003658:	8b2a                	mv	s6,a0
    8000365a:	8bae                	mv	s7,a1
    8000365c:	8a32                	mv	s4,a2
    8000365e:	84b6                	mv	s1,a3
    80003660:	8aba                	mv	s5,a4
  if(off > ip->size || off + n < off)
    80003662:	9f35                	addw	a4,a4,a3
    return 0;
    80003664:	4501                	li	a0,0
  if(off > ip->size || off + n < off)
    80003666:	0ad76b63          	bltu	a4,a3,8000371c <readi+0xdc>
    8000366a:	e4ce                	sd	s3,72(sp)
  if(off + n > ip->size)
    8000366c:	00e7f463          	bgeu	a5,a4,80003674 <readi+0x34>
    n = ip->size - off;
    80003670:	40d78abb          	subw	s5,a5,a3

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003674:	080a8b63          	beqz	s5,8000370a <readi+0xca>
    80003678:	e8ca                	sd	s2,80(sp)
    8000367a:	f062                	sd	s8,32(sp)
    8000367c:	ec66                	sd	s9,24(sp)
    8000367e:	e86a                	sd	s10,16(sp)
    80003680:	e46e                	sd	s11,8(sp)
    80003682:	4981                	li	s3,0
    uint addr = bmap(ip, off/BSIZE);
    if(addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off%BSIZE);
    80003684:	40000c93          	li	s9,1024
    if(either_copyout(user_dst, dst, bp->data + (off % BSIZE), m) == -1) {
    80003688:	5c7d                	li	s8,-1
    8000368a:	a80d                	j	800036bc <readi+0x7c>
    8000368c:	020d1d93          	slli	s11,s10,0x20
    80003690:	020ddd93          	srli	s11,s11,0x20
    80003694:	05890613          	addi	a2,s2,88
    80003698:	86ee                	mv	a3,s11
    8000369a:	963e                	add	a2,a2,a5
    8000369c:	85d2                	mv	a1,s4
    8000369e:	855e                	mv	a0,s7
    800036a0:	b6dfe0ef          	jal	8000220c <either_copyout>
    800036a4:	05850363          	beq	a0,s8,800036ea <readi+0xaa>
      brelse(bp);
      tot = -1;
      break;
    }
    brelse(bp);
    800036a8:	854a                	mv	a0,s2
    800036aa:	e66ff0ef          	jal	80002d10 <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    800036ae:	013d09bb          	addw	s3,s10,s3
    800036b2:	009d04bb          	addw	s1,s10,s1
    800036b6:	9a6e                	add	s4,s4,s11
    800036b8:	0559f363          	bgeu	s3,s5,800036fe <readi+0xbe>
    uint addr = bmap(ip, off/BSIZE);
    800036bc:	00a4d59b          	srliw	a1,s1,0xa
    800036c0:	855a                	mv	a0,s6
    800036c2:	8b9ff0ef          	jal	80002f7a <bmap>
    800036c6:	85aa                	mv	a1,a0
    if(addr == 0)
    800036c8:	c139                	beqz	a0,8000370e <readi+0xce>
    bp = bread(ip->dev, addr);
    800036ca:	000b2503          	lw	a0,0(s6)
    800036ce:	d3aff0ef          	jal	80002c08 <bread>
    800036d2:	892a                	mv	s2,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    800036d4:	3ff4f793          	andi	a5,s1,1023
    800036d8:	40fc873b          	subw	a4,s9,a5
    800036dc:	413a86bb          	subw	a3,s5,s3
    800036e0:	8d3a                	mv	s10,a4
    800036e2:	fae6f5e3          	bgeu	a3,a4,8000368c <readi+0x4c>
    800036e6:	8d36                	mv	s10,a3
    800036e8:	b755                	j	8000368c <readi+0x4c>
      brelse(bp);
    800036ea:	854a                	mv	a0,s2
    800036ec:	e24ff0ef          	jal	80002d10 <brelse>
      tot = -1;
    800036f0:	59fd                	li	s3,-1
      break;
    800036f2:	6946                	ld	s2,80(sp)
    800036f4:	7c02                	ld	s8,32(sp)
    800036f6:	6ce2                	ld	s9,24(sp)
    800036f8:	6d42                	ld	s10,16(sp)
    800036fa:	6da2                	ld	s11,8(sp)
    800036fc:	a831                	j	80003718 <readi+0xd8>
    800036fe:	6946                	ld	s2,80(sp)
    80003700:	7c02                	ld	s8,32(sp)
    80003702:	6ce2                	ld	s9,24(sp)
    80003704:	6d42                	ld	s10,16(sp)
    80003706:	6da2                	ld	s11,8(sp)
    80003708:	a801                	j	80003718 <readi+0xd8>
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    8000370a:	89d6                	mv	s3,s5
    8000370c:	a031                	j	80003718 <readi+0xd8>
    8000370e:	6946                	ld	s2,80(sp)
    80003710:	7c02                	ld	s8,32(sp)
    80003712:	6ce2                	ld	s9,24(sp)
    80003714:	6d42                	ld	s10,16(sp)
    80003716:	6da2                	ld	s11,8(sp)
  }
  return tot;
    80003718:	854e                	mv	a0,s3
    8000371a:	69a6                	ld	s3,72(sp)
}
    8000371c:	70a6                	ld	ra,104(sp)
    8000371e:	7406                	ld	s0,96(sp)
    80003720:	64e6                	ld	s1,88(sp)
    80003722:	6a06                	ld	s4,64(sp)
    80003724:	7ae2                	ld	s5,56(sp)
    80003726:	7b42                	ld	s6,48(sp)
    80003728:	7ba2                	ld	s7,40(sp)
    8000372a:	6165                	addi	sp,sp,112
    8000372c:	8082                	ret
    return 0;
    8000372e:	4501                	li	a0,0
}
    80003730:	8082                	ret

0000000080003732 <writei>:
writei(struct inode *ip, int user_src, uint64 src, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    80003732:	457c                	lw	a5,76(a0)
    80003734:	0ed7eb63          	bltu	a5,a3,8000382a <writei+0xf8>
{
    80003738:	7159                	addi	sp,sp,-112
    8000373a:	f486                	sd	ra,104(sp)
    8000373c:	f0a2                	sd	s0,96(sp)
    8000373e:	e8ca                	sd	s2,80(sp)
    80003740:	e0d2                	sd	s4,64(sp)
    80003742:	fc56                	sd	s5,56(sp)
    80003744:	f85a                	sd	s6,48(sp)
    80003746:	f45e                	sd	s7,40(sp)
    80003748:	1880                	addi	s0,sp,112
    8000374a:	8aaa                	mv	s5,a0
    8000374c:	8bae                	mv	s7,a1
    8000374e:	8a32                	mv	s4,a2
    80003750:	8936                	mv	s2,a3
    80003752:	8b3a                	mv	s6,a4
  if(off > ip->size || off + n < off)
    80003754:	00e687bb          	addw	a5,a3,a4
    80003758:	0cd7eb63          	bltu	a5,a3,8000382e <writei+0xfc>
    return -1;
  if(off + n > MAXFILE*BSIZE)
    8000375c:	00043737          	lui	a4,0x43
    80003760:	0cf76963          	bltu	a4,a5,80003832 <writei+0x100>
    80003764:	e4ce                	sd	s3,72(sp)
    return -1;

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003766:	0a0b0a63          	beqz	s6,8000381a <writei+0xe8>
    8000376a:	eca6                	sd	s1,88(sp)
    8000376c:	f062                	sd	s8,32(sp)
    8000376e:	ec66                	sd	s9,24(sp)
    80003770:	e86a                	sd	s10,16(sp)
    80003772:	e46e                	sd	s11,8(sp)
    80003774:	4981                	li	s3,0
    uint addr = bmap(ip, off/BSIZE);
    if(addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off%BSIZE);
    80003776:	40000c93          	li	s9,1024
    if(either_copyin(bp->data + (off % BSIZE), user_src, src, m) == -1) {
    8000377a:	5c7d                	li	s8,-1
    8000377c:	a825                	j	800037b4 <writei+0x82>
    8000377e:	020d1d93          	slli	s11,s10,0x20
    80003782:	020ddd93          	srli	s11,s11,0x20
    80003786:	05848513          	addi	a0,s1,88
    8000378a:	86ee                	mv	a3,s11
    8000378c:	8652                	mv	a2,s4
    8000378e:	85de                	mv	a1,s7
    80003790:	953e                	add	a0,a0,a5
    80003792:	ac5fe0ef          	jal	80002256 <either_copyin>
    80003796:	05850663          	beq	a0,s8,800037e2 <writei+0xb0>
      brelse(bp);
      break;
    }
    log_write(bp);
    8000379a:	8526                	mv	a0,s1
    8000379c:	6a0000ef          	jal	80003e3c <log_write>
    brelse(bp);
    800037a0:	8526                	mv	a0,s1
    800037a2:	d6eff0ef          	jal	80002d10 <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    800037a6:	013d09bb          	addw	s3,s10,s3
    800037aa:	012d093b          	addw	s2,s10,s2
    800037ae:	9a6e                	add	s4,s4,s11
    800037b0:	0369fc63          	bgeu	s3,s6,800037e8 <writei+0xb6>
    uint addr = bmap(ip, off/BSIZE);
    800037b4:	00a9559b          	srliw	a1,s2,0xa
    800037b8:	8556                	mv	a0,s5
    800037ba:	fc0ff0ef          	jal	80002f7a <bmap>
    800037be:	85aa                	mv	a1,a0
    if(addr == 0)
    800037c0:	c505                	beqz	a0,800037e8 <writei+0xb6>
    bp = bread(ip->dev, addr);
    800037c2:	000aa503          	lw	a0,0(s5)
    800037c6:	c42ff0ef          	jal	80002c08 <bread>
    800037ca:	84aa                	mv	s1,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    800037cc:	3ff97793          	andi	a5,s2,1023
    800037d0:	40fc873b          	subw	a4,s9,a5
    800037d4:	413b06bb          	subw	a3,s6,s3
    800037d8:	8d3a                	mv	s10,a4
    800037da:	fae6f2e3          	bgeu	a3,a4,8000377e <writei+0x4c>
    800037de:	8d36                	mv	s10,a3
    800037e0:	bf79                	j	8000377e <writei+0x4c>
      brelse(bp);
    800037e2:	8526                	mv	a0,s1
    800037e4:	d2cff0ef          	jal	80002d10 <brelse>
  }

  if(off > ip->size)
    800037e8:	04caa783          	lw	a5,76(s5)
    800037ec:	0327f963          	bgeu	a5,s2,8000381e <writei+0xec>
    ip->size = off;
    800037f0:	052aa623          	sw	s2,76(s5)
    800037f4:	64e6                	ld	s1,88(sp)
    800037f6:	7c02                	ld	s8,32(sp)
    800037f8:	6ce2                	ld	s9,24(sp)
    800037fa:	6d42                	ld	s10,16(sp)
    800037fc:	6da2                	ld	s11,8(sp)

  // write the i-node back to disk even if the size didn't change
  // because the loop above might have called bmap() and added a new
  // block to ip->addrs[].
  iupdate(ip);
    800037fe:	8556                	mv	a0,s5
    80003800:	9fbff0ef          	jal	800031fa <iupdate>

  return tot;
    80003804:	854e                	mv	a0,s3
    80003806:	69a6                	ld	s3,72(sp)
}
    80003808:	70a6                	ld	ra,104(sp)
    8000380a:	7406                	ld	s0,96(sp)
    8000380c:	6946                	ld	s2,80(sp)
    8000380e:	6a06                	ld	s4,64(sp)
    80003810:	7ae2                	ld	s5,56(sp)
    80003812:	7b42                	ld	s6,48(sp)
    80003814:	7ba2                	ld	s7,40(sp)
    80003816:	6165                	addi	sp,sp,112
    80003818:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    8000381a:	89da                	mv	s3,s6
    8000381c:	b7cd                	j	800037fe <writei+0xcc>
    8000381e:	64e6                	ld	s1,88(sp)
    80003820:	7c02                	ld	s8,32(sp)
    80003822:	6ce2                	ld	s9,24(sp)
    80003824:	6d42                	ld	s10,16(sp)
    80003826:	6da2                	ld	s11,8(sp)
    80003828:	bfd9                	j	800037fe <writei+0xcc>
    return -1;
    8000382a:	557d                	li	a0,-1
}
    8000382c:	8082                	ret
    return -1;
    8000382e:	557d                	li	a0,-1
    80003830:	bfe1                	j	80003808 <writei+0xd6>
    return -1;
    80003832:	557d                	li	a0,-1
    80003834:	bfd1                	j	80003808 <writei+0xd6>

0000000080003836 <namecmp>:

// Directories

int
namecmp(const char *s, const char *t)
{
    80003836:	1141                	addi	sp,sp,-16
    80003838:	e406                	sd	ra,8(sp)
    8000383a:	e022                	sd	s0,0(sp)
    8000383c:	0800                	addi	s0,sp,16
  return strncmp(s, t, DIRSIZ);
    8000383e:	4639                	li	a2,14
    80003840:	d34fd0ef          	jal	80000d74 <strncmp>
}
    80003844:	60a2                	ld	ra,8(sp)
    80003846:	6402                	ld	s0,0(sp)
    80003848:	0141                	addi	sp,sp,16
    8000384a:	8082                	ret

000000008000384c <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
{
    8000384c:	711d                	addi	sp,sp,-96
    8000384e:	ec86                	sd	ra,88(sp)
    80003850:	e8a2                	sd	s0,80(sp)
    80003852:	e4a6                	sd	s1,72(sp)
    80003854:	e0ca                	sd	s2,64(sp)
    80003856:	fc4e                	sd	s3,56(sp)
    80003858:	f852                	sd	s4,48(sp)
    8000385a:	f456                	sd	s5,40(sp)
    8000385c:	f05a                	sd	s6,32(sp)
    8000385e:	ec5e                	sd	s7,24(sp)
    80003860:	1080                	addi	s0,sp,96
  uint off, inum;
  struct dirent de;

  if(dp->type != T_DIR)
    80003862:	04451703          	lh	a4,68(a0)
    80003866:	4785                	li	a5,1
    80003868:	00f71f63          	bne	a4,a5,80003886 <dirlookup+0x3a>
    8000386c:	892a                	mv	s2,a0
    8000386e:	8aae                	mv	s5,a1
    80003870:	8bb2                	mv	s7,a2
    panic("dirlookup not DIR");

  for(off = 0; off < dp->size; off += sizeof(de)){
    80003872:	457c                	lw	a5,76(a0)
    80003874:	4481                	li	s1,0
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003876:	fa040a13          	addi	s4,s0,-96
    8000387a:	49c1                	li	s3,16
      panic("dirlookup read");
    if(de.inum == 0)
      continue;
    if(namecmp(name, de.name) == 0){
    8000387c:	fa240b13          	addi	s6,s0,-94
      inum = de.inum;
      return iget(dp->dev, inum);
    }
  }

  return 0;
    80003880:	4501                	li	a0,0
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003882:	e39d                	bnez	a5,800038a8 <dirlookup+0x5c>
    80003884:	a8b9                	j	800038e2 <dirlookup+0x96>
    panic("dirlookup not DIR");
    80003886:	00004517          	auipc	a0,0x4
    8000388a:	c6250513          	addi	a0,a0,-926 # 800074e8 <etext+0x4e8>
    8000388e:	f51fc0ef          	jal	800007de <panic>
      panic("dirlookup read");
    80003892:	00004517          	auipc	a0,0x4
    80003896:	c6e50513          	addi	a0,a0,-914 # 80007500 <etext+0x500>
    8000389a:	f45fc0ef          	jal	800007de <panic>
  for(off = 0; off < dp->size; off += sizeof(de)){
    8000389e:	24c1                	addiw	s1,s1,16
    800038a0:	04c92783          	lw	a5,76(s2)
    800038a4:	02f4fe63          	bgeu	s1,a5,800038e0 <dirlookup+0x94>
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    800038a8:	874e                	mv	a4,s3
    800038aa:	86a6                	mv	a3,s1
    800038ac:	8652                	mv	a2,s4
    800038ae:	4581                	li	a1,0
    800038b0:	854a                	mv	a0,s2
    800038b2:	d8fff0ef          	jal	80003640 <readi>
    800038b6:	fd351ee3          	bne	a0,s3,80003892 <dirlookup+0x46>
    if(de.inum == 0)
    800038ba:	fa045783          	lhu	a5,-96(s0)
    800038be:	d3e5                	beqz	a5,8000389e <dirlookup+0x52>
    if(namecmp(name, de.name) == 0){
    800038c0:	85da                	mv	a1,s6
    800038c2:	8556                	mv	a0,s5
    800038c4:	f73ff0ef          	jal	80003836 <namecmp>
    800038c8:	f979                	bnez	a0,8000389e <dirlookup+0x52>
      if(poff)
    800038ca:	000b8463          	beqz	s7,800038d2 <dirlookup+0x86>
        *poff = off;
    800038ce:	009ba023          	sw	s1,0(s7)
      return iget(dp->dev, inum);
    800038d2:	fa045583          	lhu	a1,-96(s0)
    800038d6:	00092503          	lw	a0,0(s2)
    800038da:	f60ff0ef          	jal	8000303a <iget>
    800038de:	a011                	j	800038e2 <dirlookup+0x96>
  return 0;
    800038e0:	4501                	li	a0,0
}
    800038e2:	60e6                	ld	ra,88(sp)
    800038e4:	6446                	ld	s0,80(sp)
    800038e6:	64a6                	ld	s1,72(sp)
    800038e8:	6906                	ld	s2,64(sp)
    800038ea:	79e2                	ld	s3,56(sp)
    800038ec:	7a42                	ld	s4,48(sp)
    800038ee:	7aa2                	ld	s5,40(sp)
    800038f0:	7b02                	ld	s6,32(sp)
    800038f2:	6be2                	ld	s7,24(sp)
    800038f4:	6125                	addi	sp,sp,96
    800038f6:	8082                	ret

00000000800038f8 <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode*
namex(char *path, int nameiparent, char *name)
{
    800038f8:	711d                	addi	sp,sp,-96
    800038fa:	ec86                	sd	ra,88(sp)
    800038fc:	e8a2                	sd	s0,80(sp)
    800038fe:	e4a6                	sd	s1,72(sp)
    80003900:	e0ca                	sd	s2,64(sp)
    80003902:	fc4e                	sd	s3,56(sp)
    80003904:	f852                	sd	s4,48(sp)
    80003906:	f456                	sd	s5,40(sp)
    80003908:	f05a                	sd	s6,32(sp)
    8000390a:	ec5e                	sd	s7,24(sp)
    8000390c:	e862                	sd	s8,16(sp)
    8000390e:	e466                	sd	s9,8(sp)
    80003910:	e06a                	sd	s10,0(sp)
    80003912:	1080                	addi	s0,sp,96
    80003914:	84aa                	mv	s1,a0
    80003916:	8b2e                	mv	s6,a1
    80003918:	8ab2                	mv	s5,a2
  struct inode *ip, *next;

  if(*path == '/')
    8000391a:	00054703          	lbu	a4,0(a0)
    8000391e:	02f00793          	li	a5,47
    80003922:	00f70f63          	beq	a4,a5,80003940 <namex+0x48>
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(myproc()->cwd);
    80003926:	f99fd0ef          	jal	800018be <myproc>
    8000392a:	15053503          	ld	a0,336(a0)
    8000392e:	94bff0ef          	jal	80003278 <idup>
    80003932:	8a2a                	mv	s4,a0
  while(*path == '/')
    80003934:	02f00913          	li	s2,47
  if(len >= DIRSIZ)
    80003938:	4c35                	li	s8,13
    memmove(name, s, DIRSIZ);
    8000393a:	4cb9                	li	s9,14

  while((path = skipelem(path, name)) != 0){
    ilock(ip);
    if(ip->type != T_DIR){
    8000393c:	4b85                	li	s7,1
    8000393e:	a879                	j	800039dc <namex+0xe4>
    ip = iget(ROOTDEV, ROOTINO);
    80003940:	4585                	li	a1,1
    80003942:	852e                	mv	a0,a1
    80003944:	ef6ff0ef          	jal	8000303a <iget>
    80003948:	8a2a                	mv	s4,a0
    8000394a:	b7ed                	j	80003934 <namex+0x3c>
      iunlockput(ip);
    8000394c:	8552                	mv	a0,s4
    8000394e:	b6bff0ef          	jal	800034b8 <iunlockput>
      return 0;
    80003952:	4a01                	li	s4,0
  if(nameiparent){
    iput(ip);
    return 0;
  }
  return ip;
}
    80003954:	8552                	mv	a0,s4
    80003956:	60e6                	ld	ra,88(sp)
    80003958:	6446                	ld	s0,80(sp)
    8000395a:	64a6                	ld	s1,72(sp)
    8000395c:	6906                	ld	s2,64(sp)
    8000395e:	79e2                	ld	s3,56(sp)
    80003960:	7a42                	ld	s4,48(sp)
    80003962:	7aa2                	ld	s5,40(sp)
    80003964:	7b02                	ld	s6,32(sp)
    80003966:	6be2                	ld	s7,24(sp)
    80003968:	6c42                	ld	s8,16(sp)
    8000396a:	6ca2                	ld	s9,8(sp)
    8000396c:	6d02                	ld	s10,0(sp)
    8000396e:	6125                	addi	sp,sp,96
    80003970:	8082                	ret
      iunlock(ip);
    80003972:	8552                	mv	a0,s4
    80003974:	9e9ff0ef          	jal	8000335c <iunlock>
      return ip;
    80003978:	bff1                	j	80003954 <namex+0x5c>
      iunlockput(ip);
    8000397a:	8552                	mv	a0,s4
    8000397c:	b3dff0ef          	jal	800034b8 <iunlockput>
      return 0;
    80003980:	8a4e                	mv	s4,s3
    80003982:	bfc9                	j	80003954 <namex+0x5c>
  len = path - s;
    80003984:	40998633          	sub	a2,s3,s1
    80003988:	00060d1b          	sext.w	s10,a2
  if(len >= DIRSIZ)
    8000398c:	09ac5063          	bge	s8,s10,80003a0c <namex+0x114>
    memmove(name, s, DIRSIZ);
    80003990:	8666                	mv	a2,s9
    80003992:	85a6                	mv	a1,s1
    80003994:	8556                	mv	a0,s5
    80003996:	b6afd0ef          	jal	80000d00 <memmove>
    8000399a:	84ce                	mv	s1,s3
  while(*path == '/')
    8000399c:	0004c783          	lbu	a5,0(s1)
    800039a0:	01279763          	bne	a5,s2,800039ae <namex+0xb6>
    path++;
    800039a4:	0485                	addi	s1,s1,1
  while(*path == '/')
    800039a6:	0004c783          	lbu	a5,0(s1)
    800039aa:	ff278de3          	beq	a5,s2,800039a4 <namex+0xac>
    ilock(ip);
    800039ae:	8552                	mv	a0,s4
    800039b0:	8ffff0ef          	jal	800032ae <ilock>
    if(ip->type != T_DIR){
    800039b4:	044a1783          	lh	a5,68(s4)
    800039b8:	f9779ae3          	bne	a5,s7,8000394c <namex+0x54>
    if(nameiparent && *path == '\0'){
    800039bc:	000b0563          	beqz	s6,800039c6 <namex+0xce>
    800039c0:	0004c783          	lbu	a5,0(s1)
    800039c4:	d7dd                	beqz	a5,80003972 <namex+0x7a>
    if((next = dirlookup(ip, name, 0)) == 0){
    800039c6:	4601                	li	a2,0
    800039c8:	85d6                	mv	a1,s5
    800039ca:	8552                	mv	a0,s4
    800039cc:	e81ff0ef          	jal	8000384c <dirlookup>
    800039d0:	89aa                	mv	s3,a0
    800039d2:	d545                	beqz	a0,8000397a <namex+0x82>
    iunlockput(ip);
    800039d4:	8552                	mv	a0,s4
    800039d6:	ae3ff0ef          	jal	800034b8 <iunlockput>
    ip = next;
    800039da:	8a4e                	mv	s4,s3
  while(*path == '/')
    800039dc:	0004c783          	lbu	a5,0(s1)
    800039e0:	01279763          	bne	a5,s2,800039ee <namex+0xf6>
    path++;
    800039e4:	0485                	addi	s1,s1,1
  while(*path == '/')
    800039e6:	0004c783          	lbu	a5,0(s1)
    800039ea:	ff278de3          	beq	a5,s2,800039e4 <namex+0xec>
  if(*path == 0)
    800039ee:	cb8d                	beqz	a5,80003a20 <namex+0x128>
  while(*path != '/' && *path != 0)
    800039f0:	0004c783          	lbu	a5,0(s1)
    800039f4:	89a6                	mv	s3,s1
  len = path - s;
    800039f6:	4d01                	li	s10,0
    800039f8:	4601                	li	a2,0
  while(*path != '/' && *path != 0)
    800039fa:	01278963          	beq	a5,s2,80003a0c <namex+0x114>
    800039fe:	d3d9                	beqz	a5,80003984 <namex+0x8c>
    path++;
    80003a00:	0985                	addi	s3,s3,1
  while(*path != '/' && *path != 0)
    80003a02:	0009c783          	lbu	a5,0(s3)
    80003a06:	ff279ce3          	bne	a5,s2,800039fe <namex+0x106>
    80003a0a:	bfad                	j	80003984 <namex+0x8c>
    memmove(name, s, len);
    80003a0c:	2601                	sext.w	a2,a2
    80003a0e:	85a6                	mv	a1,s1
    80003a10:	8556                	mv	a0,s5
    80003a12:	aeefd0ef          	jal	80000d00 <memmove>
    name[len] = 0;
    80003a16:	9d56                	add	s10,s10,s5
    80003a18:	000d0023          	sb	zero,0(s10) # fffffffffffff000 <end+0xffffffff7ffde428>
    80003a1c:	84ce                	mv	s1,s3
    80003a1e:	bfbd                	j	8000399c <namex+0xa4>
  if(nameiparent){
    80003a20:	f20b0ae3          	beqz	s6,80003954 <namex+0x5c>
    iput(ip);
    80003a24:	8552                	mv	a0,s4
    80003a26:	a0bff0ef          	jal	80003430 <iput>
    return 0;
    80003a2a:	4a01                	li	s4,0
    80003a2c:	b725                	j	80003954 <namex+0x5c>

0000000080003a2e <dirlink>:
{
    80003a2e:	715d                	addi	sp,sp,-80
    80003a30:	e486                	sd	ra,72(sp)
    80003a32:	e0a2                	sd	s0,64(sp)
    80003a34:	f84a                	sd	s2,48(sp)
    80003a36:	ec56                	sd	s5,24(sp)
    80003a38:	e85a                	sd	s6,16(sp)
    80003a3a:	0880                	addi	s0,sp,80
    80003a3c:	892a                	mv	s2,a0
    80003a3e:	8aae                	mv	s5,a1
    80003a40:	8b32                	mv	s6,a2
  if((ip = dirlookup(dp, name, 0)) != 0){
    80003a42:	4601                	li	a2,0
    80003a44:	e09ff0ef          	jal	8000384c <dirlookup>
    80003a48:	ed1d                	bnez	a0,80003a86 <dirlink+0x58>
    80003a4a:	fc26                	sd	s1,56(sp)
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003a4c:	04c92483          	lw	s1,76(s2)
    80003a50:	c4b9                	beqz	s1,80003a9e <dirlink+0x70>
    80003a52:	f44e                	sd	s3,40(sp)
    80003a54:	f052                	sd	s4,32(sp)
    80003a56:	4481                	li	s1,0
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003a58:	fb040a13          	addi	s4,s0,-80
    80003a5c:	49c1                	li	s3,16
    80003a5e:	874e                	mv	a4,s3
    80003a60:	86a6                	mv	a3,s1
    80003a62:	8652                	mv	a2,s4
    80003a64:	4581                	li	a1,0
    80003a66:	854a                	mv	a0,s2
    80003a68:	bd9ff0ef          	jal	80003640 <readi>
    80003a6c:	03351163          	bne	a0,s3,80003a8e <dirlink+0x60>
    if(de.inum == 0)
    80003a70:	fb045783          	lhu	a5,-80(s0)
    80003a74:	c39d                	beqz	a5,80003a9a <dirlink+0x6c>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003a76:	24c1                	addiw	s1,s1,16
    80003a78:	04c92783          	lw	a5,76(s2)
    80003a7c:	fef4e1e3          	bltu	s1,a5,80003a5e <dirlink+0x30>
    80003a80:	79a2                	ld	s3,40(sp)
    80003a82:	7a02                	ld	s4,32(sp)
    80003a84:	a829                	j	80003a9e <dirlink+0x70>
    iput(ip);
    80003a86:	9abff0ef          	jal	80003430 <iput>
    return -1;
    80003a8a:	557d                	li	a0,-1
    80003a8c:	a83d                	j	80003aca <dirlink+0x9c>
      panic("dirlink read");
    80003a8e:	00004517          	auipc	a0,0x4
    80003a92:	a8250513          	addi	a0,a0,-1406 # 80007510 <etext+0x510>
    80003a96:	d49fc0ef          	jal	800007de <panic>
    80003a9a:	79a2                	ld	s3,40(sp)
    80003a9c:	7a02                	ld	s4,32(sp)
  strncpy(de.name, name, DIRSIZ);
    80003a9e:	4639                	li	a2,14
    80003aa0:	85d6                	mv	a1,s5
    80003aa2:	fb240513          	addi	a0,s0,-78
    80003aa6:	b08fd0ef          	jal	80000dae <strncpy>
  de.inum = inum;
    80003aaa:	fb641823          	sh	s6,-80(s0)
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003aae:	4741                	li	a4,16
    80003ab0:	86a6                	mv	a3,s1
    80003ab2:	fb040613          	addi	a2,s0,-80
    80003ab6:	4581                	li	a1,0
    80003ab8:	854a                	mv	a0,s2
    80003aba:	c79ff0ef          	jal	80003732 <writei>
    80003abe:	1541                	addi	a0,a0,-16
    80003ac0:	00a03533          	snez	a0,a0
    80003ac4:	40a0053b          	negw	a0,a0
    80003ac8:	74e2                	ld	s1,56(sp)
}
    80003aca:	60a6                	ld	ra,72(sp)
    80003acc:	6406                	ld	s0,64(sp)
    80003ace:	7942                	ld	s2,48(sp)
    80003ad0:	6ae2                	ld	s5,24(sp)
    80003ad2:	6b42                	ld	s6,16(sp)
    80003ad4:	6161                	addi	sp,sp,80
    80003ad6:	8082                	ret

0000000080003ad8 <namei>:

struct inode*
namei(char *path)
{
    80003ad8:	1101                	addi	sp,sp,-32
    80003ada:	ec06                	sd	ra,24(sp)
    80003adc:	e822                	sd	s0,16(sp)
    80003ade:	1000                	addi	s0,sp,32
  char name[DIRSIZ];
  return namex(path, 0, name);
    80003ae0:	fe040613          	addi	a2,s0,-32
    80003ae4:	4581                	li	a1,0
    80003ae6:	e13ff0ef          	jal	800038f8 <namex>
}
    80003aea:	60e2                	ld	ra,24(sp)
    80003aec:	6442                	ld	s0,16(sp)
    80003aee:	6105                	addi	sp,sp,32
    80003af0:	8082                	ret

0000000080003af2 <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
    80003af2:	1141                	addi	sp,sp,-16
    80003af4:	e406                	sd	ra,8(sp)
    80003af6:	e022                	sd	s0,0(sp)
    80003af8:	0800                	addi	s0,sp,16
    80003afa:	862e                	mv	a2,a1
  return namex(path, 1, name);
    80003afc:	4585                	li	a1,1
    80003afe:	dfbff0ef          	jal	800038f8 <namex>
}
    80003b02:	60a2                	ld	ra,8(sp)
    80003b04:	6402                	ld	s0,0(sp)
    80003b06:	0141                	addi	sp,sp,16
    80003b08:	8082                	ret

0000000080003b0a <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
    80003b0a:	1101                	addi	sp,sp,-32
    80003b0c:	ec06                	sd	ra,24(sp)
    80003b0e:	e822                	sd	s0,16(sp)
    80003b10:	e426                	sd	s1,8(sp)
    80003b12:	e04a                	sd	s2,0(sp)
    80003b14:	1000                	addi	s0,sp,32
  struct buf *buf = bread(log.dev, log.start);
    80003b16:	0001c917          	auipc	s2,0x1c
    80003b1a:	e8290913          	addi	s2,s2,-382 # 8001f998 <log>
    80003b1e:	01892583          	lw	a1,24(s2)
    80003b22:	02492503          	lw	a0,36(s2)
    80003b26:	8e2ff0ef          	jal	80002c08 <bread>
    80003b2a:	84aa                	mv	s1,a0
  struct logheader *hb = (struct logheader *) (buf->data);
  int i;
  hb->n = log.lh.n;
    80003b2c:	02892603          	lw	a2,40(s2)
    80003b30:	cd30                	sw	a2,88(a0)
  for (i = 0; i < log.lh.n; i++) {
    80003b32:	00c05f63          	blez	a2,80003b50 <write_head+0x46>
    80003b36:	0001c717          	auipc	a4,0x1c
    80003b3a:	e8e70713          	addi	a4,a4,-370 # 8001f9c4 <log+0x2c>
    80003b3e:	87aa                	mv	a5,a0
    80003b40:	060a                	slli	a2,a2,0x2
    80003b42:	962a                	add	a2,a2,a0
    hb->block[i] = log.lh.block[i];
    80003b44:	4314                	lw	a3,0(a4)
    80003b46:	cff4                	sw	a3,92(a5)
  for (i = 0; i < log.lh.n; i++) {
    80003b48:	0711                	addi	a4,a4,4
    80003b4a:	0791                	addi	a5,a5,4
    80003b4c:	fec79ce3          	bne	a5,a2,80003b44 <write_head+0x3a>
  }
  bwrite(buf);
    80003b50:	8526                	mv	a0,s1
    80003b52:	98cff0ef          	jal	80002cde <bwrite>
  brelse(buf);
    80003b56:	8526                	mv	a0,s1
    80003b58:	9b8ff0ef          	jal	80002d10 <brelse>
}
    80003b5c:	60e2                	ld	ra,24(sp)
    80003b5e:	6442                	ld	s0,16(sp)
    80003b60:	64a2                	ld	s1,8(sp)
    80003b62:	6902                	ld	s2,0(sp)
    80003b64:	6105                	addi	sp,sp,32
    80003b66:	8082                	ret

0000000080003b68 <install_trans>:
  for (tail = 0; tail < log.lh.n; tail++) {
    80003b68:	0001c797          	auipc	a5,0x1c
    80003b6c:	e587a783          	lw	a5,-424(a5) # 8001f9c0 <log+0x28>
    80003b70:	0cf05163          	blez	a5,80003c32 <install_trans+0xca>
{
    80003b74:	715d                	addi	sp,sp,-80
    80003b76:	e486                	sd	ra,72(sp)
    80003b78:	e0a2                	sd	s0,64(sp)
    80003b7a:	fc26                	sd	s1,56(sp)
    80003b7c:	f84a                	sd	s2,48(sp)
    80003b7e:	f44e                	sd	s3,40(sp)
    80003b80:	f052                	sd	s4,32(sp)
    80003b82:	ec56                	sd	s5,24(sp)
    80003b84:	e85a                	sd	s6,16(sp)
    80003b86:	e45e                	sd	s7,8(sp)
    80003b88:	e062                	sd	s8,0(sp)
    80003b8a:	0880                	addi	s0,sp,80
    80003b8c:	8b2a                	mv	s6,a0
    80003b8e:	0001ca97          	auipc	s5,0x1c
    80003b92:	e36a8a93          	addi	s5,s5,-458 # 8001f9c4 <log+0x2c>
  for (tail = 0; tail < log.lh.n; tail++) {
    80003b96:	4981                	li	s3,0
      printf("recovering tail %d dst %d\n", tail, log.lh.block[tail]);
    80003b98:	00004c17          	auipc	s8,0x4
    80003b9c:	988c0c13          	addi	s8,s8,-1656 # 80007520 <etext+0x520>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    80003ba0:	0001ca17          	auipc	s4,0x1c
    80003ba4:	df8a0a13          	addi	s4,s4,-520 # 8001f998 <log>
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
    80003ba8:	40000b93          	li	s7,1024
    80003bac:	a025                	j	80003bd4 <install_trans+0x6c>
      printf("recovering tail %d dst %d\n", tail, log.lh.block[tail]);
    80003bae:	000aa603          	lw	a2,0(s5)
    80003bb2:	85ce                	mv	a1,s3
    80003bb4:	8562                	mv	a0,s8
    80003bb6:	945fc0ef          	jal	800004fa <printf>
    80003bba:	a839                	j	80003bd8 <install_trans+0x70>
    brelse(lbuf);
    80003bbc:	854a                	mv	a0,s2
    80003bbe:	952ff0ef          	jal	80002d10 <brelse>
    brelse(dbuf);
    80003bc2:	8526                	mv	a0,s1
    80003bc4:	94cff0ef          	jal	80002d10 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    80003bc8:	2985                	addiw	s3,s3,1
    80003bca:	0a91                	addi	s5,s5,4
    80003bcc:	028a2783          	lw	a5,40(s4)
    80003bd0:	04f9d563          	bge	s3,a5,80003c1a <install_trans+0xb2>
    if(recovering) {
    80003bd4:	fc0b1de3          	bnez	s6,80003bae <install_trans+0x46>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    80003bd8:	018a2583          	lw	a1,24(s4)
    80003bdc:	013585bb          	addw	a1,a1,s3
    80003be0:	2585                	addiw	a1,a1,1
    80003be2:	024a2503          	lw	a0,36(s4)
    80003be6:	822ff0ef          	jal	80002c08 <bread>
    80003bea:	892a                	mv	s2,a0
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
    80003bec:	000aa583          	lw	a1,0(s5)
    80003bf0:	024a2503          	lw	a0,36(s4)
    80003bf4:	814ff0ef          	jal	80002c08 <bread>
    80003bf8:	84aa                	mv	s1,a0
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
    80003bfa:	865e                	mv	a2,s7
    80003bfc:	05890593          	addi	a1,s2,88
    80003c00:	05850513          	addi	a0,a0,88
    80003c04:	8fcfd0ef          	jal	80000d00 <memmove>
    bwrite(dbuf);  // write dst to disk
    80003c08:	8526                	mv	a0,s1
    80003c0a:	8d4ff0ef          	jal	80002cde <bwrite>
    if(recovering == 0)
    80003c0e:	fa0b17e3          	bnez	s6,80003bbc <install_trans+0x54>
      bunpin(dbuf);
    80003c12:	8526                	mv	a0,s1
    80003c14:	9b4ff0ef          	jal	80002dc8 <bunpin>
    80003c18:	b755                	j	80003bbc <install_trans+0x54>
}
    80003c1a:	60a6                	ld	ra,72(sp)
    80003c1c:	6406                	ld	s0,64(sp)
    80003c1e:	74e2                	ld	s1,56(sp)
    80003c20:	7942                	ld	s2,48(sp)
    80003c22:	79a2                	ld	s3,40(sp)
    80003c24:	7a02                	ld	s4,32(sp)
    80003c26:	6ae2                	ld	s5,24(sp)
    80003c28:	6b42                	ld	s6,16(sp)
    80003c2a:	6ba2                	ld	s7,8(sp)
    80003c2c:	6c02                	ld	s8,0(sp)
    80003c2e:	6161                	addi	sp,sp,80
    80003c30:	8082                	ret
    80003c32:	8082                	ret

0000000080003c34 <initlog>:
{
    80003c34:	7179                	addi	sp,sp,-48
    80003c36:	f406                	sd	ra,40(sp)
    80003c38:	f022                	sd	s0,32(sp)
    80003c3a:	ec26                	sd	s1,24(sp)
    80003c3c:	e84a                	sd	s2,16(sp)
    80003c3e:	e44e                	sd	s3,8(sp)
    80003c40:	1800                	addi	s0,sp,48
    80003c42:	892a                	mv	s2,a0
    80003c44:	89ae                	mv	s3,a1
  initlock(&log.lock, "log");
    80003c46:	0001c497          	auipc	s1,0x1c
    80003c4a:	d5248493          	addi	s1,s1,-686 # 8001f998 <log>
    80003c4e:	00004597          	auipc	a1,0x4
    80003c52:	8f258593          	addi	a1,a1,-1806 # 80007540 <etext+0x540>
    80003c56:	8526                	mv	a0,s1
    80003c58:	ef1fc0ef          	jal	80000b48 <initlock>
  log.start = sb->logstart;
    80003c5c:	0149a583          	lw	a1,20(s3)
    80003c60:	cc8c                	sw	a1,24(s1)
  log.dev = dev;
    80003c62:	0324a223          	sw	s2,36(s1)
  struct buf *buf = bread(log.dev, log.start);
    80003c66:	854a                	mv	a0,s2
    80003c68:	fa1fe0ef          	jal	80002c08 <bread>
  log.lh.n = lh->n;
    80003c6c:	4d30                	lw	a2,88(a0)
    80003c6e:	d490                	sw	a2,40(s1)
  for (i = 0; i < log.lh.n; i++) {
    80003c70:	00c05f63          	blez	a2,80003c8e <initlog+0x5a>
    80003c74:	87aa                	mv	a5,a0
    80003c76:	0001c717          	auipc	a4,0x1c
    80003c7a:	d4e70713          	addi	a4,a4,-690 # 8001f9c4 <log+0x2c>
    80003c7e:	060a                	slli	a2,a2,0x2
    80003c80:	962a                	add	a2,a2,a0
    log.lh.block[i] = lh->block[i];
    80003c82:	4ff4                	lw	a3,92(a5)
    80003c84:	c314                	sw	a3,0(a4)
  for (i = 0; i < log.lh.n; i++) {
    80003c86:	0791                	addi	a5,a5,4
    80003c88:	0711                	addi	a4,a4,4
    80003c8a:	fec79ce3          	bne	a5,a2,80003c82 <initlog+0x4e>
  brelse(buf);
    80003c8e:	882ff0ef          	jal	80002d10 <brelse>

static void
recover_from_log(void)
{
  read_head();
  install_trans(1); // if committed, copy from log to disk
    80003c92:	4505                	li	a0,1
    80003c94:	ed5ff0ef          	jal	80003b68 <install_trans>
  log.lh.n = 0;
    80003c98:	0001c797          	auipc	a5,0x1c
    80003c9c:	d207a423          	sw	zero,-728(a5) # 8001f9c0 <log+0x28>
  write_head(); // clear the log
    80003ca0:	e6bff0ef          	jal	80003b0a <write_head>
}
    80003ca4:	70a2                	ld	ra,40(sp)
    80003ca6:	7402                	ld	s0,32(sp)
    80003ca8:	64e2                	ld	s1,24(sp)
    80003caa:	6942                	ld	s2,16(sp)
    80003cac:	69a2                	ld	s3,8(sp)
    80003cae:	6145                	addi	sp,sp,48
    80003cb0:	8082                	ret

0000000080003cb2 <begin_op>:
}

// called at the start of each FS system call.
void
begin_op(void)
{
    80003cb2:	1101                	addi	sp,sp,-32
    80003cb4:	ec06                	sd	ra,24(sp)
    80003cb6:	e822                	sd	s0,16(sp)
    80003cb8:	e426                	sd	s1,8(sp)
    80003cba:	e04a                	sd	s2,0(sp)
    80003cbc:	1000                	addi	s0,sp,32
  acquire(&log.lock);
    80003cbe:	0001c517          	auipc	a0,0x1c
    80003cc2:	cda50513          	addi	a0,a0,-806 # 8001f998 <log>
    80003cc6:	f07fc0ef          	jal	80000bcc <acquire>
  while(1){
    if(log.committing){
    80003cca:	0001c497          	auipc	s1,0x1c
    80003cce:	cce48493          	addi	s1,s1,-818 # 8001f998 <log>
      sleep(&log, &log.lock);
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGBLOCKS){
    80003cd2:	4979                	li	s2,30
    80003cd4:	a029                	j	80003cde <begin_op+0x2c>
      sleep(&log, &log.lock);
    80003cd6:	85a6                	mv	a1,s1
    80003cd8:	8526                	mv	a0,s1
    80003cda:	9dcfe0ef          	jal	80001eb6 <sleep>
    if(log.committing){
    80003cde:	509c                	lw	a5,32(s1)
    80003ce0:	fbfd                	bnez	a5,80003cd6 <begin_op+0x24>
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGBLOCKS){
    80003ce2:	4cd8                	lw	a4,28(s1)
    80003ce4:	2705                	addiw	a4,a4,1
    80003ce6:	0027179b          	slliw	a5,a4,0x2
    80003cea:	9fb9                	addw	a5,a5,a4
    80003cec:	0017979b          	slliw	a5,a5,0x1
    80003cf0:	5494                	lw	a3,40(s1)
    80003cf2:	9fb5                	addw	a5,a5,a3
    80003cf4:	00f95763          	bge	s2,a5,80003d02 <begin_op+0x50>
      // this op might exhaust log space; wait for commit.
      sleep(&log, &log.lock);
    80003cf8:	85a6                	mv	a1,s1
    80003cfa:	8526                	mv	a0,s1
    80003cfc:	9bafe0ef          	jal	80001eb6 <sleep>
    80003d00:	bff9                	j	80003cde <begin_op+0x2c>
    } else {
      log.outstanding += 1;
    80003d02:	0001c517          	auipc	a0,0x1c
    80003d06:	c9650513          	addi	a0,a0,-874 # 8001f998 <log>
    80003d0a:	cd58                	sw	a4,28(a0)
      release(&log.lock);
    80003d0c:	f55fc0ef          	jal	80000c60 <release>
      break;
    }
  }
}
    80003d10:	60e2                	ld	ra,24(sp)
    80003d12:	6442                	ld	s0,16(sp)
    80003d14:	64a2                	ld	s1,8(sp)
    80003d16:	6902                	ld	s2,0(sp)
    80003d18:	6105                	addi	sp,sp,32
    80003d1a:	8082                	ret

0000000080003d1c <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(void)
{
    80003d1c:	7139                	addi	sp,sp,-64
    80003d1e:	fc06                	sd	ra,56(sp)
    80003d20:	f822                	sd	s0,48(sp)
    80003d22:	f426                	sd	s1,40(sp)
    80003d24:	f04a                	sd	s2,32(sp)
    80003d26:	0080                	addi	s0,sp,64
  int do_commit = 0;

  acquire(&log.lock);
    80003d28:	0001c497          	auipc	s1,0x1c
    80003d2c:	c7048493          	addi	s1,s1,-912 # 8001f998 <log>
    80003d30:	8526                	mv	a0,s1
    80003d32:	e9bfc0ef          	jal	80000bcc <acquire>
  log.outstanding -= 1;
    80003d36:	4cdc                	lw	a5,28(s1)
    80003d38:	37fd                	addiw	a5,a5,-1
    80003d3a:	893e                	mv	s2,a5
    80003d3c:	ccdc                	sw	a5,28(s1)
  if(log.committing)
    80003d3e:	509c                	lw	a5,32(s1)
    80003d40:	ef9d                	bnez	a5,80003d7e <end_op+0x62>
    panic("log.committing");
  if(log.outstanding == 0){
    80003d42:	04091863          	bnez	s2,80003d92 <end_op+0x76>
    do_commit = 1;
    log.committing = 1;
    80003d46:	0001c497          	auipc	s1,0x1c
    80003d4a:	c5248493          	addi	s1,s1,-942 # 8001f998 <log>
    80003d4e:	4785                	li	a5,1
    80003d50:	d09c                	sw	a5,32(s1)
    // begin_op() may be waiting for log space,
    // and decrementing log.outstanding has decreased
    // the amount of reserved space.
    wakeup(&log);
  }
  release(&log.lock);
    80003d52:	8526                	mv	a0,s1
    80003d54:	f0dfc0ef          	jal	80000c60 <release>
}

static void
commit()
{
  if (log.lh.n > 0) {
    80003d58:	549c                	lw	a5,40(s1)
    80003d5a:	04f04c63          	bgtz	a5,80003db2 <end_op+0x96>
    acquire(&log.lock);
    80003d5e:	0001c497          	auipc	s1,0x1c
    80003d62:	c3a48493          	addi	s1,s1,-966 # 8001f998 <log>
    80003d66:	8526                	mv	a0,s1
    80003d68:	e65fc0ef          	jal	80000bcc <acquire>
    log.committing = 0;
    80003d6c:	0204a023          	sw	zero,32(s1)
    wakeup(&log);
    80003d70:	8526                	mv	a0,s1
    80003d72:	990fe0ef          	jal	80001f02 <wakeup>
    release(&log.lock);
    80003d76:	8526                	mv	a0,s1
    80003d78:	ee9fc0ef          	jal	80000c60 <release>
}
    80003d7c:	a02d                	j	80003da6 <end_op+0x8a>
    80003d7e:	ec4e                	sd	s3,24(sp)
    80003d80:	e852                	sd	s4,16(sp)
    80003d82:	e456                	sd	s5,8(sp)
    80003d84:	e05a                	sd	s6,0(sp)
    panic("log.committing");
    80003d86:	00003517          	auipc	a0,0x3
    80003d8a:	7c250513          	addi	a0,a0,1986 # 80007548 <etext+0x548>
    80003d8e:	a51fc0ef          	jal	800007de <panic>
    wakeup(&log);
    80003d92:	0001c497          	auipc	s1,0x1c
    80003d96:	c0648493          	addi	s1,s1,-1018 # 8001f998 <log>
    80003d9a:	8526                	mv	a0,s1
    80003d9c:	966fe0ef          	jal	80001f02 <wakeup>
  release(&log.lock);
    80003da0:	8526                	mv	a0,s1
    80003da2:	ebffc0ef          	jal	80000c60 <release>
}
    80003da6:	70e2                	ld	ra,56(sp)
    80003da8:	7442                	ld	s0,48(sp)
    80003daa:	74a2                	ld	s1,40(sp)
    80003dac:	7902                	ld	s2,32(sp)
    80003dae:	6121                	addi	sp,sp,64
    80003db0:	8082                	ret
    80003db2:	ec4e                	sd	s3,24(sp)
    80003db4:	e852                	sd	s4,16(sp)
    80003db6:	e456                	sd	s5,8(sp)
    80003db8:	e05a                	sd	s6,0(sp)
  for (tail = 0; tail < log.lh.n; tail++) {
    80003dba:	0001ca97          	auipc	s5,0x1c
    80003dbe:	c0aa8a93          	addi	s5,s5,-1014 # 8001f9c4 <log+0x2c>
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
    80003dc2:	0001ca17          	auipc	s4,0x1c
    80003dc6:	bd6a0a13          	addi	s4,s4,-1066 # 8001f998 <log>
    memmove(to->data, from->data, BSIZE);
    80003dca:	40000b13          	li	s6,1024
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
    80003dce:	018a2583          	lw	a1,24(s4)
    80003dd2:	012585bb          	addw	a1,a1,s2
    80003dd6:	2585                	addiw	a1,a1,1
    80003dd8:	024a2503          	lw	a0,36(s4)
    80003ddc:	e2dfe0ef          	jal	80002c08 <bread>
    80003de0:	84aa                	mv	s1,a0
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
    80003de2:	000aa583          	lw	a1,0(s5)
    80003de6:	024a2503          	lw	a0,36(s4)
    80003dea:	e1ffe0ef          	jal	80002c08 <bread>
    80003dee:	89aa                	mv	s3,a0
    memmove(to->data, from->data, BSIZE);
    80003df0:	865a                	mv	a2,s6
    80003df2:	05850593          	addi	a1,a0,88
    80003df6:	05848513          	addi	a0,s1,88
    80003dfa:	f07fc0ef          	jal	80000d00 <memmove>
    bwrite(to);  // write the log
    80003dfe:	8526                	mv	a0,s1
    80003e00:	edffe0ef          	jal	80002cde <bwrite>
    brelse(from);
    80003e04:	854e                	mv	a0,s3
    80003e06:	f0bfe0ef          	jal	80002d10 <brelse>
    brelse(to);
    80003e0a:	8526                	mv	a0,s1
    80003e0c:	f05fe0ef          	jal	80002d10 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    80003e10:	2905                	addiw	s2,s2,1
    80003e12:	0a91                	addi	s5,s5,4
    80003e14:	028a2783          	lw	a5,40(s4)
    80003e18:	faf94be3          	blt	s2,a5,80003dce <end_op+0xb2>
    write_log();     // Write modified blocks from cache to log
    write_head();    // Write header to disk -- the real commit
    80003e1c:	cefff0ef          	jal	80003b0a <write_head>
    install_trans(0); // Now install writes to home locations
    80003e20:	4501                	li	a0,0
    80003e22:	d47ff0ef          	jal	80003b68 <install_trans>
    log.lh.n = 0;
    80003e26:	0001c797          	auipc	a5,0x1c
    80003e2a:	b807ad23          	sw	zero,-1126(a5) # 8001f9c0 <log+0x28>
    write_head();    // Erase the transaction from the log
    80003e2e:	cddff0ef          	jal	80003b0a <write_head>
    80003e32:	69e2                	ld	s3,24(sp)
    80003e34:	6a42                	ld	s4,16(sp)
    80003e36:	6aa2                	ld	s5,8(sp)
    80003e38:	6b02                	ld	s6,0(sp)
    80003e3a:	b715                	j	80003d5e <end_op+0x42>

0000000080003e3c <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
    80003e3c:	1101                	addi	sp,sp,-32
    80003e3e:	ec06                	sd	ra,24(sp)
    80003e40:	e822                	sd	s0,16(sp)
    80003e42:	e426                	sd	s1,8(sp)
    80003e44:	e04a                	sd	s2,0(sp)
    80003e46:	1000                	addi	s0,sp,32
    80003e48:	84aa                	mv	s1,a0
  int i;

  acquire(&log.lock);
    80003e4a:	0001c917          	auipc	s2,0x1c
    80003e4e:	b4e90913          	addi	s2,s2,-1202 # 8001f998 <log>
    80003e52:	854a                	mv	a0,s2
    80003e54:	d79fc0ef          	jal	80000bcc <acquire>
  if (log.lh.n >= LOGBLOCKS)
    80003e58:	02892603          	lw	a2,40(s2)
    80003e5c:	47f5                	li	a5,29
    80003e5e:	04c7cc63          	blt	a5,a2,80003eb6 <log_write+0x7a>
    panic("too big a transaction");
  if (log.outstanding < 1)
    80003e62:	0001c797          	auipc	a5,0x1c
    80003e66:	b527a783          	lw	a5,-1198(a5) # 8001f9b4 <log+0x1c>
    80003e6a:	04f05c63          	blez	a5,80003ec2 <log_write+0x86>
    panic("log_write outside of trans");

  for (i = 0; i < log.lh.n; i++) {
    80003e6e:	4781                	li	a5,0
    80003e70:	04c05f63          	blez	a2,80003ece <log_write+0x92>
    if (log.lh.block[i] == b->blockno)   // log absorption
    80003e74:	44cc                	lw	a1,12(s1)
    80003e76:	0001c717          	auipc	a4,0x1c
    80003e7a:	b4e70713          	addi	a4,a4,-1202 # 8001f9c4 <log+0x2c>
  for (i = 0; i < log.lh.n; i++) {
    80003e7e:	4781                	li	a5,0
    if (log.lh.block[i] == b->blockno)   // log absorption
    80003e80:	4314                	lw	a3,0(a4)
    80003e82:	04b68663          	beq	a3,a1,80003ece <log_write+0x92>
  for (i = 0; i < log.lh.n; i++) {
    80003e86:	2785                	addiw	a5,a5,1
    80003e88:	0711                	addi	a4,a4,4
    80003e8a:	fef61be3          	bne	a2,a5,80003e80 <log_write+0x44>
      break;
  }
  log.lh.block[i] = b->blockno;
    80003e8e:	0621                	addi	a2,a2,8
    80003e90:	060a                	slli	a2,a2,0x2
    80003e92:	0001c797          	auipc	a5,0x1c
    80003e96:	b0678793          	addi	a5,a5,-1274 # 8001f998 <log>
    80003e9a:	97b2                	add	a5,a5,a2
    80003e9c:	44d8                	lw	a4,12(s1)
    80003e9e:	c7d8                	sw	a4,12(a5)
  if (i == log.lh.n) {  // Add new block to log?
    bpin(b);
    80003ea0:	8526                	mv	a0,s1
    80003ea2:	ef3fe0ef          	jal	80002d94 <bpin>
    log.lh.n++;
    80003ea6:	0001c717          	auipc	a4,0x1c
    80003eaa:	af270713          	addi	a4,a4,-1294 # 8001f998 <log>
    80003eae:	571c                	lw	a5,40(a4)
    80003eb0:	2785                	addiw	a5,a5,1
    80003eb2:	d71c                	sw	a5,40(a4)
    80003eb4:	a80d                	j	80003ee6 <log_write+0xaa>
    panic("too big a transaction");
    80003eb6:	00003517          	auipc	a0,0x3
    80003eba:	6a250513          	addi	a0,a0,1698 # 80007558 <etext+0x558>
    80003ebe:	921fc0ef          	jal	800007de <panic>
    panic("log_write outside of trans");
    80003ec2:	00003517          	auipc	a0,0x3
    80003ec6:	6ae50513          	addi	a0,a0,1710 # 80007570 <etext+0x570>
    80003eca:	915fc0ef          	jal	800007de <panic>
  log.lh.block[i] = b->blockno;
    80003ece:	00878693          	addi	a3,a5,8
    80003ed2:	068a                	slli	a3,a3,0x2
    80003ed4:	0001c717          	auipc	a4,0x1c
    80003ed8:	ac470713          	addi	a4,a4,-1340 # 8001f998 <log>
    80003edc:	9736                	add	a4,a4,a3
    80003ede:	44d4                	lw	a3,12(s1)
    80003ee0:	c754                	sw	a3,12(a4)
  if (i == log.lh.n) {  // Add new block to log?
    80003ee2:	faf60fe3          	beq	a2,a5,80003ea0 <log_write+0x64>
  }
  release(&log.lock);
    80003ee6:	0001c517          	auipc	a0,0x1c
    80003eea:	ab250513          	addi	a0,a0,-1358 # 8001f998 <log>
    80003eee:	d73fc0ef          	jal	80000c60 <release>
}
    80003ef2:	60e2                	ld	ra,24(sp)
    80003ef4:	6442                	ld	s0,16(sp)
    80003ef6:	64a2                	ld	s1,8(sp)
    80003ef8:	6902                	ld	s2,0(sp)
    80003efa:	6105                	addi	sp,sp,32
    80003efc:	8082                	ret

0000000080003efe <initsleeplock>:
#include "proc.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
    80003efe:	1101                	addi	sp,sp,-32
    80003f00:	ec06                	sd	ra,24(sp)
    80003f02:	e822                	sd	s0,16(sp)
    80003f04:	e426                	sd	s1,8(sp)
    80003f06:	e04a                	sd	s2,0(sp)
    80003f08:	1000                	addi	s0,sp,32
    80003f0a:	84aa                	mv	s1,a0
    80003f0c:	892e                	mv	s2,a1
  initlock(&lk->lk, "sleep lock");
    80003f0e:	00003597          	auipc	a1,0x3
    80003f12:	68258593          	addi	a1,a1,1666 # 80007590 <etext+0x590>
    80003f16:	0521                	addi	a0,a0,8
    80003f18:	c31fc0ef          	jal	80000b48 <initlock>
  lk->name = name;
    80003f1c:	0324b023          	sd	s2,32(s1)
  lk->locked = 0;
    80003f20:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    80003f24:	0204a423          	sw	zero,40(s1)
}
    80003f28:	60e2                	ld	ra,24(sp)
    80003f2a:	6442                	ld	s0,16(sp)
    80003f2c:	64a2                	ld	s1,8(sp)
    80003f2e:	6902                	ld	s2,0(sp)
    80003f30:	6105                	addi	sp,sp,32
    80003f32:	8082                	ret

0000000080003f34 <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
    80003f34:	1101                	addi	sp,sp,-32
    80003f36:	ec06                	sd	ra,24(sp)
    80003f38:	e822                	sd	s0,16(sp)
    80003f3a:	e426                	sd	s1,8(sp)
    80003f3c:	e04a                	sd	s2,0(sp)
    80003f3e:	1000                	addi	s0,sp,32
    80003f40:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    80003f42:	00850913          	addi	s2,a0,8
    80003f46:	854a                	mv	a0,s2
    80003f48:	c85fc0ef          	jal	80000bcc <acquire>
  while (lk->locked) {
    80003f4c:	409c                	lw	a5,0(s1)
    80003f4e:	c799                	beqz	a5,80003f5c <acquiresleep+0x28>
    sleep(lk, &lk->lk);
    80003f50:	85ca                	mv	a1,s2
    80003f52:	8526                	mv	a0,s1
    80003f54:	f63fd0ef          	jal	80001eb6 <sleep>
  while (lk->locked) {
    80003f58:	409c                	lw	a5,0(s1)
    80003f5a:	fbfd                	bnez	a5,80003f50 <acquiresleep+0x1c>
  }
  lk->locked = 1;
    80003f5c:	4785                	li	a5,1
    80003f5e:	c09c                	sw	a5,0(s1)
  lk->pid = myproc()->pid;
    80003f60:	95ffd0ef          	jal	800018be <myproc>
    80003f64:	591c                	lw	a5,48(a0)
    80003f66:	d49c                	sw	a5,40(s1)
  release(&lk->lk);
    80003f68:	854a                	mv	a0,s2
    80003f6a:	cf7fc0ef          	jal	80000c60 <release>
}
    80003f6e:	60e2                	ld	ra,24(sp)
    80003f70:	6442                	ld	s0,16(sp)
    80003f72:	64a2                	ld	s1,8(sp)
    80003f74:	6902                	ld	s2,0(sp)
    80003f76:	6105                	addi	sp,sp,32
    80003f78:	8082                	ret

0000000080003f7a <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
    80003f7a:	1101                	addi	sp,sp,-32
    80003f7c:	ec06                	sd	ra,24(sp)
    80003f7e:	e822                	sd	s0,16(sp)
    80003f80:	e426                	sd	s1,8(sp)
    80003f82:	e04a                	sd	s2,0(sp)
    80003f84:	1000                	addi	s0,sp,32
    80003f86:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    80003f88:	00850913          	addi	s2,a0,8
    80003f8c:	854a                	mv	a0,s2
    80003f8e:	c3ffc0ef          	jal	80000bcc <acquire>
  lk->locked = 0;
    80003f92:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    80003f96:	0204a423          	sw	zero,40(s1)
  wakeup(lk);
    80003f9a:	8526                	mv	a0,s1
    80003f9c:	f67fd0ef          	jal	80001f02 <wakeup>
  release(&lk->lk);
    80003fa0:	854a                	mv	a0,s2
    80003fa2:	cbffc0ef          	jal	80000c60 <release>
}
    80003fa6:	60e2                	ld	ra,24(sp)
    80003fa8:	6442                	ld	s0,16(sp)
    80003faa:	64a2                	ld	s1,8(sp)
    80003fac:	6902                	ld	s2,0(sp)
    80003fae:	6105                	addi	sp,sp,32
    80003fb0:	8082                	ret

0000000080003fb2 <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
    80003fb2:	7179                	addi	sp,sp,-48
    80003fb4:	f406                	sd	ra,40(sp)
    80003fb6:	f022                	sd	s0,32(sp)
    80003fb8:	ec26                	sd	s1,24(sp)
    80003fba:	e84a                	sd	s2,16(sp)
    80003fbc:	1800                	addi	s0,sp,48
    80003fbe:	84aa                	mv	s1,a0
  int r;
  
  acquire(&lk->lk);
    80003fc0:	00850913          	addi	s2,a0,8
    80003fc4:	854a                	mv	a0,s2
    80003fc6:	c07fc0ef          	jal	80000bcc <acquire>
  r = lk->locked && (lk->pid == myproc()->pid);
    80003fca:	409c                	lw	a5,0(s1)
    80003fcc:	ef81                	bnez	a5,80003fe4 <holdingsleep+0x32>
    80003fce:	4481                	li	s1,0
  release(&lk->lk);
    80003fd0:	854a                	mv	a0,s2
    80003fd2:	c8ffc0ef          	jal	80000c60 <release>
  return r;
}
    80003fd6:	8526                	mv	a0,s1
    80003fd8:	70a2                	ld	ra,40(sp)
    80003fda:	7402                	ld	s0,32(sp)
    80003fdc:	64e2                	ld	s1,24(sp)
    80003fde:	6942                	ld	s2,16(sp)
    80003fe0:	6145                	addi	sp,sp,48
    80003fe2:	8082                	ret
    80003fe4:	e44e                	sd	s3,8(sp)
  r = lk->locked && (lk->pid == myproc()->pid);
    80003fe6:	0284a983          	lw	s3,40(s1)
    80003fea:	8d5fd0ef          	jal	800018be <myproc>
    80003fee:	5904                	lw	s1,48(a0)
    80003ff0:	413484b3          	sub	s1,s1,s3
    80003ff4:	0014b493          	seqz	s1,s1
    80003ff8:	69a2                	ld	s3,8(sp)
    80003ffa:	bfd9                	j	80003fd0 <holdingsleep+0x1e>

0000000080003ffc <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
    80003ffc:	1141                	addi	sp,sp,-16
    80003ffe:	e406                	sd	ra,8(sp)
    80004000:	e022                	sd	s0,0(sp)
    80004002:	0800                	addi	s0,sp,16
  initlock(&ftable.lock, "ftable");
    80004004:	00003597          	auipc	a1,0x3
    80004008:	59c58593          	addi	a1,a1,1436 # 800075a0 <etext+0x5a0>
    8000400c:	0001c517          	auipc	a0,0x1c
    80004010:	ad450513          	addi	a0,a0,-1324 # 8001fae0 <ftable>
    80004014:	b35fc0ef          	jal	80000b48 <initlock>
}
    80004018:	60a2                	ld	ra,8(sp)
    8000401a:	6402                	ld	s0,0(sp)
    8000401c:	0141                	addi	sp,sp,16
    8000401e:	8082                	ret

0000000080004020 <filealloc>:

// Allocate a file structure.
struct file*
filealloc(void)
{
    80004020:	1101                	addi	sp,sp,-32
    80004022:	ec06                	sd	ra,24(sp)
    80004024:	e822                	sd	s0,16(sp)
    80004026:	e426                	sd	s1,8(sp)
    80004028:	1000                	addi	s0,sp,32
  struct file *f;

  acquire(&ftable.lock);
    8000402a:	0001c517          	auipc	a0,0x1c
    8000402e:	ab650513          	addi	a0,a0,-1354 # 8001fae0 <ftable>
    80004032:	b9bfc0ef          	jal	80000bcc <acquire>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    80004036:	0001c497          	auipc	s1,0x1c
    8000403a:	ac248493          	addi	s1,s1,-1342 # 8001faf8 <ftable+0x18>
    8000403e:	0001d717          	auipc	a4,0x1d
    80004042:	a5a70713          	addi	a4,a4,-1446 # 80020a98 <disk>
    if(f->ref == 0){
    80004046:	40dc                	lw	a5,4(s1)
    80004048:	cf89                	beqz	a5,80004062 <filealloc+0x42>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    8000404a:	02848493          	addi	s1,s1,40
    8000404e:	fee49ce3          	bne	s1,a4,80004046 <filealloc+0x26>
      f->ref = 1;
      release(&ftable.lock);
      return f;
    }
  }
  release(&ftable.lock);
    80004052:	0001c517          	auipc	a0,0x1c
    80004056:	a8e50513          	addi	a0,a0,-1394 # 8001fae0 <ftable>
    8000405a:	c07fc0ef          	jal	80000c60 <release>
  return 0;
    8000405e:	4481                	li	s1,0
    80004060:	a809                	j	80004072 <filealloc+0x52>
      f->ref = 1;
    80004062:	4785                	li	a5,1
    80004064:	c0dc                	sw	a5,4(s1)
      release(&ftable.lock);
    80004066:	0001c517          	auipc	a0,0x1c
    8000406a:	a7a50513          	addi	a0,a0,-1414 # 8001fae0 <ftable>
    8000406e:	bf3fc0ef          	jal	80000c60 <release>
}
    80004072:	8526                	mv	a0,s1
    80004074:	60e2                	ld	ra,24(sp)
    80004076:	6442                	ld	s0,16(sp)
    80004078:	64a2                	ld	s1,8(sp)
    8000407a:	6105                	addi	sp,sp,32
    8000407c:	8082                	ret

000000008000407e <filedup>:

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
    8000407e:	1101                	addi	sp,sp,-32
    80004080:	ec06                	sd	ra,24(sp)
    80004082:	e822                	sd	s0,16(sp)
    80004084:	e426                	sd	s1,8(sp)
    80004086:	1000                	addi	s0,sp,32
    80004088:	84aa                	mv	s1,a0
  acquire(&ftable.lock);
    8000408a:	0001c517          	auipc	a0,0x1c
    8000408e:	a5650513          	addi	a0,a0,-1450 # 8001fae0 <ftable>
    80004092:	b3bfc0ef          	jal	80000bcc <acquire>
  if(f->ref < 1)
    80004096:	40dc                	lw	a5,4(s1)
    80004098:	02f05063          	blez	a5,800040b8 <filedup+0x3a>
    panic("filedup");
  f->ref++;
    8000409c:	2785                	addiw	a5,a5,1
    8000409e:	c0dc                	sw	a5,4(s1)
  release(&ftable.lock);
    800040a0:	0001c517          	auipc	a0,0x1c
    800040a4:	a4050513          	addi	a0,a0,-1472 # 8001fae0 <ftable>
    800040a8:	bb9fc0ef          	jal	80000c60 <release>
  return f;
}
    800040ac:	8526                	mv	a0,s1
    800040ae:	60e2                	ld	ra,24(sp)
    800040b0:	6442                	ld	s0,16(sp)
    800040b2:	64a2                	ld	s1,8(sp)
    800040b4:	6105                	addi	sp,sp,32
    800040b6:	8082                	ret
    panic("filedup");
    800040b8:	00003517          	auipc	a0,0x3
    800040bc:	4f050513          	addi	a0,a0,1264 # 800075a8 <etext+0x5a8>
    800040c0:	f1efc0ef          	jal	800007de <panic>

00000000800040c4 <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
    800040c4:	7139                	addi	sp,sp,-64
    800040c6:	fc06                	sd	ra,56(sp)
    800040c8:	f822                	sd	s0,48(sp)
    800040ca:	f426                	sd	s1,40(sp)
    800040cc:	0080                	addi	s0,sp,64
    800040ce:	84aa                	mv	s1,a0
  struct file ff;

  acquire(&ftable.lock);
    800040d0:	0001c517          	auipc	a0,0x1c
    800040d4:	a1050513          	addi	a0,a0,-1520 # 8001fae0 <ftable>
    800040d8:	af5fc0ef          	jal	80000bcc <acquire>
  if(f->ref < 1)
    800040dc:	40dc                	lw	a5,4(s1)
    800040de:	04f05863          	blez	a5,8000412e <fileclose+0x6a>
    panic("fileclose");
  if(--f->ref > 0){
    800040e2:	37fd                	addiw	a5,a5,-1
    800040e4:	c0dc                	sw	a5,4(s1)
    800040e6:	04f04e63          	bgtz	a5,80004142 <fileclose+0x7e>
    800040ea:	f04a                	sd	s2,32(sp)
    800040ec:	ec4e                	sd	s3,24(sp)
    800040ee:	e852                	sd	s4,16(sp)
    800040f0:	e456                	sd	s5,8(sp)
    release(&ftable.lock);
    return;
  }
  ff = *f;
    800040f2:	0004a903          	lw	s2,0(s1)
    800040f6:	0094ca83          	lbu	s5,9(s1)
    800040fa:	0104ba03          	ld	s4,16(s1)
    800040fe:	0184b983          	ld	s3,24(s1)
  f->ref = 0;
    80004102:	0004a223          	sw	zero,4(s1)
  f->type = FD_NONE;
    80004106:	0004a023          	sw	zero,0(s1)
  release(&ftable.lock);
    8000410a:	0001c517          	auipc	a0,0x1c
    8000410e:	9d650513          	addi	a0,a0,-1578 # 8001fae0 <ftable>
    80004112:	b4ffc0ef          	jal	80000c60 <release>

  if(ff.type == FD_PIPE){
    80004116:	4785                	li	a5,1
    80004118:	04f90063          	beq	s2,a5,80004158 <fileclose+0x94>
    pipeclose(ff.pipe, ff.writable);
  } else if(ff.type == FD_INODE || ff.type == FD_DEVICE){
    8000411c:	3979                	addiw	s2,s2,-2
    8000411e:	4785                	li	a5,1
    80004120:	0527f563          	bgeu	a5,s2,8000416a <fileclose+0xa6>
    80004124:	7902                	ld	s2,32(sp)
    80004126:	69e2                	ld	s3,24(sp)
    80004128:	6a42                	ld	s4,16(sp)
    8000412a:	6aa2                	ld	s5,8(sp)
    8000412c:	a00d                	j	8000414e <fileclose+0x8a>
    8000412e:	f04a                	sd	s2,32(sp)
    80004130:	ec4e                	sd	s3,24(sp)
    80004132:	e852                	sd	s4,16(sp)
    80004134:	e456                	sd	s5,8(sp)
    panic("fileclose");
    80004136:	00003517          	auipc	a0,0x3
    8000413a:	47a50513          	addi	a0,a0,1146 # 800075b0 <etext+0x5b0>
    8000413e:	ea0fc0ef          	jal	800007de <panic>
    release(&ftable.lock);
    80004142:	0001c517          	auipc	a0,0x1c
    80004146:	99e50513          	addi	a0,a0,-1634 # 8001fae0 <ftable>
    8000414a:	b17fc0ef          	jal	80000c60 <release>
    begin_op();
    iput(ff.ip);
    end_op();
  }
}
    8000414e:	70e2                	ld	ra,56(sp)
    80004150:	7442                	ld	s0,48(sp)
    80004152:	74a2                	ld	s1,40(sp)
    80004154:	6121                	addi	sp,sp,64
    80004156:	8082                	ret
    pipeclose(ff.pipe, ff.writable);
    80004158:	85d6                	mv	a1,s5
    8000415a:	8552                	mv	a0,s4
    8000415c:	340000ef          	jal	8000449c <pipeclose>
    80004160:	7902                	ld	s2,32(sp)
    80004162:	69e2                	ld	s3,24(sp)
    80004164:	6a42                	ld	s4,16(sp)
    80004166:	6aa2                	ld	s5,8(sp)
    80004168:	b7dd                	j	8000414e <fileclose+0x8a>
    begin_op();
    8000416a:	b49ff0ef          	jal	80003cb2 <begin_op>
    iput(ff.ip);
    8000416e:	854e                	mv	a0,s3
    80004170:	ac0ff0ef          	jal	80003430 <iput>
    end_op();
    80004174:	ba9ff0ef          	jal	80003d1c <end_op>
    80004178:	7902                	ld	s2,32(sp)
    8000417a:	69e2                	ld	s3,24(sp)
    8000417c:	6a42                	ld	s4,16(sp)
    8000417e:	6aa2                	ld	s5,8(sp)
    80004180:	b7f9                	j	8000414e <fileclose+0x8a>

0000000080004182 <filestat>:

// Get metadata about file f.
// addr is a user virtual address, pointing to a struct stat.
int
filestat(struct file *f, uint64 addr)
{
    80004182:	715d                	addi	sp,sp,-80
    80004184:	e486                	sd	ra,72(sp)
    80004186:	e0a2                	sd	s0,64(sp)
    80004188:	fc26                	sd	s1,56(sp)
    8000418a:	f44e                	sd	s3,40(sp)
    8000418c:	0880                	addi	s0,sp,80
    8000418e:	84aa                	mv	s1,a0
    80004190:	89ae                	mv	s3,a1
  struct proc *p = myproc();
    80004192:	f2cfd0ef          	jal	800018be <myproc>
  struct stat st;
  
  if(f->type == FD_INODE || f->type == FD_DEVICE){
    80004196:	409c                	lw	a5,0(s1)
    80004198:	37f9                	addiw	a5,a5,-2
    8000419a:	4705                	li	a4,1
    8000419c:	04f76263          	bltu	a4,a5,800041e0 <filestat+0x5e>
    800041a0:	f84a                	sd	s2,48(sp)
    800041a2:	f052                	sd	s4,32(sp)
    800041a4:	892a                	mv	s2,a0
    ilock(f->ip);
    800041a6:	6c88                	ld	a0,24(s1)
    800041a8:	906ff0ef          	jal	800032ae <ilock>
    stati(f->ip, &st);
    800041ac:	fb840a13          	addi	s4,s0,-72
    800041b0:	85d2                	mv	a1,s4
    800041b2:	6c88                	ld	a0,24(s1)
    800041b4:	c5eff0ef          	jal	80003612 <stati>
    iunlock(f->ip);
    800041b8:	6c88                	ld	a0,24(s1)
    800041ba:	9a2ff0ef          	jal	8000335c <iunlock>
    if(copyout(p->pagetable, addr, (char *)&st, sizeof(st)) < 0)
    800041be:	46e1                	li	a3,24
    800041c0:	8652                	mv	a2,s4
    800041c2:	85ce                	mv	a1,s3
    800041c4:	05093503          	ld	a0,80(s2)
    800041c8:	c28fd0ef          	jal	800015f0 <copyout>
    800041cc:	41f5551b          	sraiw	a0,a0,0x1f
    800041d0:	7942                	ld	s2,48(sp)
    800041d2:	7a02                	ld	s4,32(sp)
      return -1;
    return 0;
  }
  return -1;
}
    800041d4:	60a6                	ld	ra,72(sp)
    800041d6:	6406                	ld	s0,64(sp)
    800041d8:	74e2                	ld	s1,56(sp)
    800041da:	79a2                	ld	s3,40(sp)
    800041dc:	6161                	addi	sp,sp,80
    800041de:	8082                	ret
  return -1;
    800041e0:	557d                	li	a0,-1
    800041e2:	bfcd                	j	800041d4 <filestat+0x52>

00000000800041e4 <fileread>:

// Read from file f.
// addr is a user virtual address.
int
fileread(struct file *f, uint64 addr, int n)
{
    800041e4:	7179                	addi	sp,sp,-48
    800041e6:	f406                	sd	ra,40(sp)
    800041e8:	f022                	sd	s0,32(sp)
    800041ea:	e84a                	sd	s2,16(sp)
    800041ec:	1800                	addi	s0,sp,48
  int r = 0;

  if(f->readable == 0)
    800041ee:	00854783          	lbu	a5,8(a0)
    800041f2:	cfd1                	beqz	a5,8000428e <fileread+0xaa>
    800041f4:	ec26                	sd	s1,24(sp)
    800041f6:	e44e                	sd	s3,8(sp)
    800041f8:	84aa                	mv	s1,a0
    800041fa:	89ae                	mv	s3,a1
    800041fc:	8932                	mv	s2,a2
    return -1;

  if(f->type == FD_PIPE){
    800041fe:	411c                	lw	a5,0(a0)
    80004200:	4705                	li	a4,1
    80004202:	04e78363          	beq	a5,a4,80004248 <fileread+0x64>
    r = piperead(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    80004206:	470d                	li	a4,3
    80004208:	04e78763          	beq	a5,a4,80004256 <fileread+0x72>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
      return -1;
    r = devsw[f->major].read(1, addr, n);
  } else if(f->type == FD_INODE){
    8000420c:	4709                	li	a4,2
    8000420e:	06e79a63          	bne	a5,a4,80004282 <fileread+0x9e>
    ilock(f->ip);
    80004212:	6d08                	ld	a0,24(a0)
    80004214:	89aff0ef          	jal	800032ae <ilock>
    if((r = readi(f->ip, 1, addr, f->off, n)) > 0)
    80004218:	874a                	mv	a4,s2
    8000421a:	5094                	lw	a3,32(s1)
    8000421c:	864e                	mv	a2,s3
    8000421e:	4585                	li	a1,1
    80004220:	6c88                	ld	a0,24(s1)
    80004222:	c1eff0ef          	jal	80003640 <readi>
    80004226:	892a                	mv	s2,a0
    80004228:	00a05563          	blez	a0,80004232 <fileread+0x4e>
      f->off += r;
    8000422c:	509c                	lw	a5,32(s1)
    8000422e:	9fa9                	addw	a5,a5,a0
    80004230:	d09c                	sw	a5,32(s1)
    iunlock(f->ip);
    80004232:	6c88                	ld	a0,24(s1)
    80004234:	928ff0ef          	jal	8000335c <iunlock>
    80004238:	64e2                	ld	s1,24(sp)
    8000423a:	69a2                	ld	s3,8(sp)
  } else {
    panic("fileread");
  }

  return r;
}
    8000423c:	854a                	mv	a0,s2
    8000423e:	70a2                	ld	ra,40(sp)
    80004240:	7402                	ld	s0,32(sp)
    80004242:	6942                	ld	s2,16(sp)
    80004244:	6145                	addi	sp,sp,48
    80004246:	8082                	ret
    r = piperead(f->pipe, addr, n);
    80004248:	6908                	ld	a0,16(a0)
    8000424a:	3a2000ef          	jal	800045ec <piperead>
    8000424e:	892a                	mv	s2,a0
    80004250:	64e2                	ld	s1,24(sp)
    80004252:	69a2                	ld	s3,8(sp)
    80004254:	b7e5                	j	8000423c <fileread+0x58>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
    80004256:	02451783          	lh	a5,36(a0)
    8000425a:	03079693          	slli	a3,a5,0x30
    8000425e:	92c1                	srli	a3,a3,0x30
    80004260:	4725                	li	a4,9
    80004262:	02d76863          	bltu	a4,a3,80004292 <fileread+0xae>
    80004266:	0792                	slli	a5,a5,0x4
    80004268:	0001b717          	auipc	a4,0x1b
    8000426c:	7d870713          	addi	a4,a4,2008 # 8001fa40 <devsw>
    80004270:	97ba                	add	a5,a5,a4
    80004272:	639c                	ld	a5,0(a5)
    80004274:	c39d                	beqz	a5,8000429a <fileread+0xb6>
    r = devsw[f->major].read(1, addr, n);
    80004276:	4505                	li	a0,1
    80004278:	9782                	jalr	a5
    8000427a:	892a                	mv	s2,a0
    8000427c:	64e2                	ld	s1,24(sp)
    8000427e:	69a2                	ld	s3,8(sp)
    80004280:	bf75                	j	8000423c <fileread+0x58>
    panic("fileread");
    80004282:	00003517          	auipc	a0,0x3
    80004286:	33e50513          	addi	a0,a0,830 # 800075c0 <etext+0x5c0>
    8000428a:	d54fc0ef          	jal	800007de <panic>
    return -1;
    8000428e:	597d                	li	s2,-1
    80004290:	b775                	j	8000423c <fileread+0x58>
      return -1;
    80004292:	597d                	li	s2,-1
    80004294:	64e2                	ld	s1,24(sp)
    80004296:	69a2                	ld	s3,8(sp)
    80004298:	b755                	j	8000423c <fileread+0x58>
    8000429a:	597d                	li	s2,-1
    8000429c:	64e2                	ld	s1,24(sp)
    8000429e:	69a2                	ld	s3,8(sp)
    800042a0:	bf71                	j	8000423c <fileread+0x58>

00000000800042a2 <filewrite>:
int
filewrite(struct file *f, uint64 addr, int n)
{
  int r, ret = 0;

  if(f->writable == 0)
    800042a2:	00954783          	lbu	a5,9(a0)
    800042a6:	10078e63          	beqz	a5,800043c2 <filewrite+0x120>
{
    800042aa:	711d                	addi	sp,sp,-96
    800042ac:	ec86                	sd	ra,88(sp)
    800042ae:	e8a2                	sd	s0,80(sp)
    800042b0:	e0ca                	sd	s2,64(sp)
    800042b2:	f456                	sd	s5,40(sp)
    800042b4:	f05a                	sd	s6,32(sp)
    800042b6:	1080                	addi	s0,sp,96
    800042b8:	892a                	mv	s2,a0
    800042ba:	8b2e                	mv	s6,a1
    800042bc:	8ab2                	mv	s5,a2
    return -1;

  if(f->type == FD_PIPE){
    800042be:	411c                	lw	a5,0(a0)
    800042c0:	4705                	li	a4,1
    800042c2:	02e78963          	beq	a5,a4,800042f4 <filewrite+0x52>
    ret = pipewrite(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    800042c6:	470d                	li	a4,3
    800042c8:	02e78a63          	beq	a5,a4,800042fc <filewrite+0x5a>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
      return -1;
    ret = devsw[f->major].write(1, addr, n);
  } else if(f->type == FD_INODE){
    800042cc:	4709                	li	a4,2
    800042ce:	0ce79e63          	bne	a5,a4,800043aa <filewrite+0x108>
    800042d2:	f852                	sd	s4,48(sp)
    // the maximum log transaction size, including
    // i-node, indirect block, allocation blocks,
    // and 2 blocks of slop for non-aligned writes.
    int max = ((MAXOPBLOCKS-1-1-2) / 2) * BSIZE;
    int i = 0;
    while(i < n){
    800042d4:	0ac05963          	blez	a2,80004386 <filewrite+0xe4>
    800042d8:	e4a6                	sd	s1,72(sp)
    800042da:	fc4e                	sd	s3,56(sp)
    800042dc:	ec5e                	sd	s7,24(sp)
    800042de:	e862                	sd	s8,16(sp)
    800042e0:	e466                	sd	s9,8(sp)
    int i = 0;
    800042e2:	4a01                	li	s4,0
      int n1 = n - i;
      if(n1 > max)
    800042e4:	6b85                	lui	s7,0x1
    800042e6:	c00b8b93          	addi	s7,s7,-1024 # c00 <_entry-0x7ffff400>
    800042ea:	6c85                	lui	s9,0x1
    800042ec:	c00c8c9b          	addiw	s9,s9,-1024 # c00 <_entry-0x7ffff400>
        n1 = max;

      begin_op();
      ilock(f->ip);
      if ((r = writei(f->ip, 1, addr + i, f->off, n1)) > 0)
    800042f0:	4c05                	li	s8,1
    800042f2:	a8ad                	j	8000436c <filewrite+0xca>
    ret = pipewrite(f->pipe, addr, n);
    800042f4:	6908                	ld	a0,16(a0)
    800042f6:	1fe000ef          	jal	800044f4 <pipewrite>
    800042fa:	a04d                	j	8000439c <filewrite+0xfa>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
    800042fc:	02451783          	lh	a5,36(a0)
    80004300:	03079693          	slli	a3,a5,0x30
    80004304:	92c1                	srli	a3,a3,0x30
    80004306:	4725                	li	a4,9
    80004308:	0ad76f63          	bltu	a4,a3,800043c6 <filewrite+0x124>
    8000430c:	0792                	slli	a5,a5,0x4
    8000430e:	0001b717          	auipc	a4,0x1b
    80004312:	73270713          	addi	a4,a4,1842 # 8001fa40 <devsw>
    80004316:	97ba                	add	a5,a5,a4
    80004318:	679c                	ld	a5,8(a5)
    8000431a:	cbc5                	beqz	a5,800043ca <filewrite+0x128>
    ret = devsw[f->major].write(1, addr, n);
    8000431c:	4505                	li	a0,1
    8000431e:	9782                	jalr	a5
    80004320:	a8b5                	j	8000439c <filewrite+0xfa>
      if(n1 > max)
    80004322:	2981                	sext.w	s3,s3
      begin_op();
    80004324:	98fff0ef          	jal	80003cb2 <begin_op>
      ilock(f->ip);
    80004328:	01893503          	ld	a0,24(s2)
    8000432c:	f83fe0ef          	jal	800032ae <ilock>
      if ((r = writei(f->ip, 1, addr + i, f->off, n1)) > 0)
    80004330:	874e                	mv	a4,s3
    80004332:	02092683          	lw	a3,32(s2)
    80004336:	016a0633          	add	a2,s4,s6
    8000433a:	85e2                	mv	a1,s8
    8000433c:	01893503          	ld	a0,24(s2)
    80004340:	bf2ff0ef          	jal	80003732 <writei>
    80004344:	84aa                	mv	s1,a0
    80004346:	00a05763          	blez	a0,80004354 <filewrite+0xb2>
        f->off += r;
    8000434a:	02092783          	lw	a5,32(s2)
    8000434e:	9fa9                	addw	a5,a5,a0
    80004350:	02f92023          	sw	a5,32(s2)
      iunlock(f->ip);
    80004354:	01893503          	ld	a0,24(s2)
    80004358:	804ff0ef          	jal	8000335c <iunlock>
      end_op();
    8000435c:	9c1ff0ef          	jal	80003d1c <end_op>

      if(r != n1){
    80004360:	02999563          	bne	s3,s1,8000438a <filewrite+0xe8>
        // error from writei
        break;
      }
      i += r;
    80004364:	01448a3b          	addw	s4,s1,s4
    while(i < n){
    80004368:	015a5963          	bge	s4,s5,8000437a <filewrite+0xd8>
      int n1 = n - i;
    8000436c:	414a87bb          	subw	a5,s5,s4
    80004370:	89be                	mv	s3,a5
      if(n1 > max)
    80004372:	fafbd8e3          	bge	s7,a5,80004322 <filewrite+0x80>
    80004376:	89e6                	mv	s3,s9
    80004378:	b76d                	j	80004322 <filewrite+0x80>
    8000437a:	64a6                	ld	s1,72(sp)
    8000437c:	79e2                	ld	s3,56(sp)
    8000437e:	6be2                	ld	s7,24(sp)
    80004380:	6c42                	ld	s8,16(sp)
    80004382:	6ca2                	ld	s9,8(sp)
    80004384:	a801                	j	80004394 <filewrite+0xf2>
    int i = 0;
    80004386:	4a01                	li	s4,0
    80004388:	a031                	j	80004394 <filewrite+0xf2>
    8000438a:	64a6                	ld	s1,72(sp)
    8000438c:	79e2                	ld	s3,56(sp)
    8000438e:	6be2                	ld	s7,24(sp)
    80004390:	6c42                	ld	s8,16(sp)
    80004392:	6ca2                	ld	s9,8(sp)
    }
    ret = (i == n ? n : -1);
    80004394:	034a9d63          	bne	s5,s4,800043ce <filewrite+0x12c>
    80004398:	8556                	mv	a0,s5
    8000439a:	7a42                	ld	s4,48(sp)
  } else {
    panic("filewrite");
  }

  return ret;
}
    8000439c:	60e6                	ld	ra,88(sp)
    8000439e:	6446                	ld	s0,80(sp)
    800043a0:	6906                	ld	s2,64(sp)
    800043a2:	7aa2                	ld	s5,40(sp)
    800043a4:	7b02                	ld	s6,32(sp)
    800043a6:	6125                	addi	sp,sp,96
    800043a8:	8082                	ret
    800043aa:	e4a6                	sd	s1,72(sp)
    800043ac:	fc4e                	sd	s3,56(sp)
    800043ae:	f852                	sd	s4,48(sp)
    800043b0:	ec5e                	sd	s7,24(sp)
    800043b2:	e862                	sd	s8,16(sp)
    800043b4:	e466                	sd	s9,8(sp)
    panic("filewrite");
    800043b6:	00003517          	auipc	a0,0x3
    800043ba:	21a50513          	addi	a0,a0,538 # 800075d0 <etext+0x5d0>
    800043be:	c20fc0ef          	jal	800007de <panic>
    return -1;
    800043c2:	557d                	li	a0,-1
}
    800043c4:	8082                	ret
      return -1;
    800043c6:	557d                	li	a0,-1
    800043c8:	bfd1                	j	8000439c <filewrite+0xfa>
    800043ca:	557d                	li	a0,-1
    800043cc:	bfc1                	j	8000439c <filewrite+0xfa>
    ret = (i == n ? n : -1);
    800043ce:	557d                	li	a0,-1
    800043d0:	7a42                	ld	s4,48(sp)
    800043d2:	b7e9                	j	8000439c <filewrite+0xfa>

00000000800043d4 <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
    800043d4:	7179                	addi	sp,sp,-48
    800043d6:	f406                	sd	ra,40(sp)
    800043d8:	f022                	sd	s0,32(sp)
    800043da:	ec26                	sd	s1,24(sp)
    800043dc:	e052                	sd	s4,0(sp)
    800043de:	1800                	addi	s0,sp,48
    800043e0:	84aa                	mv	s1,a0
    800043e2:	8a2e                	mv	s4,a1
  struct pipe *pi;

  pi = 0;
  *f0 = *f1 = 0;
    800043e4:	0005b023          	sd	zero,0(a1)
    800043e8:	00053023          	sd	zero,0(a0)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
    800043ec:	c35ff0ef          	jal	80004020 <filealloc>
    800043f0:	e088                	sd	a0,0(s1)
    800043f2:	c549                	beqz	a0,8000447c <pipealloc+0xa8>
    800043f4:	c2dff0ef          	jal	80004020 <filealloc>
    800043f8:	00aa3023          	sd	a0,0(s4)
    800043fc:	cd25                	beqz	a0,80004474 <pipealloc+0xa0>
    800043fe:	e84a                	sd	s2,16(sp)
    goto bad;
  if((pi = (struct pipe*)kalloc()) == 0)
    80004400:	ef8fc0ef          	jal	80000af8 <kalloc>
    80004404:	892a                	mv	s2,a0
    80004406:	c12d                	beqz	a0,80004468 <pipealloc+0x94>
    80004408:	e44e                	sd	s3,8(sp)
    goto bad;
  pi->readopen = 1;
    8000440a:	4985                	li	s3,1
    8000440c:	23352023          	sw	s3,544(a0)
  pi->writeopen = 1;
    80004410:	23352223          	sw	s3,548(a0)
  pi->nwrite = 0;
    80004414:	20052e23          	sw	zero,540(a0)
  pi->nread = 0;
    80004418:	20052c23          	sw	zero,536(a0)
  initlock(&pi->lock, "pipe");
    8000441c:	00003597          	auipc	a1,0x3
    80004420:	1c458593          	addi	a1,a1,452 # 800075e0 <etext+0x5e0>
    80004424:	f24fc0ef          	jal	80000b48 <initlock>
  (*f0)->type = FD_PIPE;
    80004428:	609c                	ld	a5,0(s1)
    8000442a:	0137a023          	sw	s3,0(a5)
  (*f0)->readable = 1;
    8000442e:	609c                	ld	a5,0(s1)
    80004430:	01378423          	sb	s3,8(a5)
  (*f0)->writable = 0;
    80004434:	609c                	ld	a5,0(s1)
    80004436:	000784a3          	sb	zero,9(a5)
  (*f0)->pipe = pi;
    8000443a:	609c                	ld	a5,0(s1)
    8000443c:	0127b823          	sd	s2,16(a5)
  (*f1)->type = FD_PIPE;
    80004440:	000a3783          	ld	a5,0(s4)
    80004444:	0137a023          	sw	s3,0(a5)
  (*f1)->readable = 0;
    80004448:	000a3783          	ld	a5,0(s4)
    8000444c:	00078423          	sb	zero,8(a5)
  (*f1)->writable = 1;
    80004450:	000a3783          	ld	a5,0(s4)
    80004454:	013784a3          	sb	s3,9(a5)
  (*f1)->pipe = pi;
    80004458:	000a3783          	ld	a5,0(s4)
    8000445c:	0127b823          	sd	s2,16(a5)
  return 0;
    80004460:	4501                	li	a0,0
    80004462:	6942                	ld	s2,16(sp)
    80004464:	69a2                	ld	s3,8(sp)
    80004466:	a01d                	j	8000448c <pipealloc+0xb8>

 bad:
  if(pi)
    kfree((char*)pi);
  if(*f0)
    80004468:	6088                	ld	a0,0(s1)
    8000446a:	c119                	beqz	a0,80004470 <pipealloc+0x9c>
    8000446c:	6942                	ld	s2,16(sp)
    8000446e:	a029                	j	80004478 <pipealloc+0xa4>
    80004470:	6942                	ld	s2,16(sp)
    80004472:	a029                	j	8000447c <pipealloc+0xa8>
    80004474:	6088                	ld	a0,0(s1)
    80004476:	c10d                	beqz	a0,80004498 <pipealloc+0xc4>
    fileclose(*f0);
    80004478:	c4dff0ef          	jal	800040c4 <fileclose>
  if(*f1)
    8000447c:	000a3783          	ld	a5,0(s4)
    fileclose(*f1);
  return -1;
    80004480:	557d                	li	a0,-1
  if(*f1)
    80004482:	c789                	beqz	a5,8000448c <pipealloc+0xb8>
    fileclose(*f1);
    80004484:	853e                	mv	a0,a5
    80004486:	c3fff0ef          	jal	800040c4 <fileclose>
  return -1;
    8000448a:	557d                	li	a0,-1
}
    8000448c:	70a2                	ld	ra,40(sp)
    8000448e:	7402                	ld	s0,32(sp)
    80004490:	64e2                	ld	s1,24(sp)
    80004492:	6a02                	ld	s4,0(sp)
    80004494:	6145                	addi	sp,sp,48
    80004496:	8082                	ret
  return -1;
    80004498:	557d                	li	a0,-1
    8000449a:	bfcd                	j	8000448c <pipealloc+0xb8>

000000008000449c <pipeclose>:

void
pipeclose(struct pipe *pi, int writable)
{
    8000449c:	1101                	addi	sp,sp,-32
    8000449e:	ec06                	sd	ra,24(sp)
    800044a0:	e822                	sd	s0,16(sp)
    800044a2:	e426                	sd	s1,8(sp)
    800044a4:	e04a                	sd	s2,0(sp)
    800044a6:	1000                	addi	s0,sp,32
    800044a8:	84aa                	mv	s1,a0
    800044aa:	892e                	mv	s2,a1
  acquire(&pi->lock);
    800044ac:	f20fc0ef          	jal	80000bcc <acquire>
  if(writable){
    800044b0:	02090763          	beqz	s2,800044de <pipeclose+0x42>
    pi->writeopen = 0;
    800044b4:	2204a223          	sw	zero,548(s1)
    wakeup(&pi->nread);
    800044b8:	21848513          	addi	a0,s1,536
    800044bc:	a47fd0ef          	jal	80001f02 <wakeup>
  } else {
    pi->readopen = 0;
    wakeup(&pi->nwrite);
  }
  if(pi->readopen == 0 && pi->writeopen == 0){
    800044c0:	2204b783          	ld	a5,544(s1)
    800044c4:	e785                	bnez	a5,800044ec <pipeclose+0x50>
    release(&pi->lock);
    800044c6:	8526                	mv	a0,s1
    800044c8:	f98fc0ef          	jal	80000c60 <release>
    kfree((char*)pi);
    800044cc:	8526                	mv	a0,s1
    800044ce:	d48fc0ef          	jal	80000a16 <kfree>
  } else
    release(&pi->lock);
}
    800044d2:	60e2                	ld	ra,24(sp)
    800044d4:	6442                	ld	s0,16(sp)
    800044d6:	64a2                	ld	s1,8(sp)
    800044d8:	6902                	ld	s2,0(sp)
    800044da:	6105                	addi	sp,sp,32
    800044dc:	8082                	ret
    pi->readopen = 0;
    800044de:	2204a023          	sw	zero,544(s1)
    wakeup(&pi->nwrite);
    800044e2:	21c48513          	addi	a0,s1,540
    800044e6:	a1dfd0ef          	jal	80001f02 <wakeup>
    800044ea:	bfd9                	j	800044c0 <pipeclose+0x24>
    release(&pi->lock);
    800044ec:	8526                	mv	a0,s1
    800044ee:	f72fc0ef          	jal	80000c60 <release>
}
    800044f2:	b7c5                	j	800044d2 <pipeclose+0x36>

00000000800044f4 <pipewrite>:

int
pipewrite(struct pipe *pi, uint64 addr, int n)
{
    800044f4:	7159                	addi	sp,sp,-112
    800044f6:	f486                	sd	ra,104(sp)
    800044f8:	f0a2                	sd	s0,96(sp)
    800044fa:	eca6                	sd	s1,88(sp)
    800044fc:	e8ca                	sd	s2,80(sp)
    800044fe:	e4ce                	sd	s3,72(sp)
    80004500:	e0d2                	sd	s4,64(sp)
    80004502:	fc56                	sd	s5,56(sp)
    80004504:	1880                	addi	s0,sp,112
    80004506:	84aa                	mv	s1,a0
    80004508:	8aae                	mv	s5,a1
    8000450a:	8a32                	mv	s4,a2
  int i = 0;
  struct proc *pr = myproc();
    8000450c:	bb2fd0ef          	jal	800018be <myproc>
    80004510:	89aa                	mv	s3,a0

  acquire(&pi->lock);
    80004512:	8526                	mv	a0,s1
    80004514:	eb8fc0ef          	jal	80000bcc <acquire>
  while(i < n){
    80004518:	0d405263          	blez	s4,800045dc <pipewrite+0xe8>
    8000451c:	f85a                	sd	s6,48(sp)
    8000451e:	f45e                	sd	s7,40(sp)
    80004520:	f062                	sd	s8,32(sp)
    80004522:	ec66                	sd	s9,24(sp)
    80004524:	e86a                	sd	s10,16(sp)
  int i = 0;
    80004526:	4901                	li	s2,0
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
      wakeup(&pi->nread);
      sleep(&pi->nwrite, &pi->lock);
    } else {
      char ch;
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    80004528:	f9f40c13          	addi	s8,s0,-97
    8000452c:	4b85                	li	s7,1
    8000452e:	5b7d                	li	s6,-1
      wakeup(&pi->nread);
    80004530:	21848d13          	addi	s10,s1,536
      sleep(&pi->nwrite, &pi->lock);
    80004534:	21c48c93          	addi	s9,s1,540
    80004538:	a82d                	j	80004572 <pipewrite+0x7e>
      release(&pi->lock);
    8000453a:	8526                	mv	a0,s1
    8000453c:	f24fc0ef          	jal	80000c60 <release>
      return -1;
    80004540:	597d                	li	s2,-1
    80004542:	7b42                	ld	s6,48(sp)
    80004544:	7ba2                	ld	s7,40(sp)
    80004546:	7c02                	ld	s8,32(sp)
    80004548:	6ce2                	ld	s9,24(sp)
    8000454a:	6d42                	ld	s10,16(sp)
  }
  wakeup(&pi->nread);
  release(&pi->lock);

  return i;
}
    8000454c:	854a                	mv	a0,s2
    8000454e:	70a6                	ld	ra,104(sp)
    80004550:	7406                	ld	s0,96(sp)
    80004552:	64e6                	ld	s1,88(sp)
    80004554:	6946                	ld	s2,80(sp)
    80004556:	69a6                	ld	s3,72(sp)
    80004558:	6a06                	ld	s4,64(sp)
    8000455a:	7ae2                	ld	s5,56(sp)
    8000455c:	6165                	addi	sp,sp,112
    8000455e:	8082                	ret
      wakeup(&pi->nread);
    80004560:	856a                	mv	a0,s10
    80004562:	9a1fd0ef          	jal	80001f02 <wakeup>
      sleep(&pi->nwrite, &pi->lock);
    80004566:	85a6                	mv	a1,s1
    80004568:	8566                	mv	a0,s9
    8000456a:	94dfd0ef          	jal	80001eb6 <sleep>
  while(i < n){
    8000456e:	05495a63          	bge	s2,s4,800045c2 <pipewrite+0xce>
    if(pi->readopen == 0 || killed(pr)){
    80004572:	2204a783          	lw	a5,544(s1)
    80004576:	d3f1                	beqz	a5,8000453a <pipewrite+0x46>
    80004578:	854e                	mv	a0,s3
    8000457a:	b75fd0ef          	jal	800020ee <killed>
    8000457e:	fd55                	bnez	a0,8000453a <pipewrite+0x46>
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
    80004580:	2184a783          	lw	a5,536(s1)
    80004584:	21c4a703          	lw	a4,540(s1)
    80004588:	2007879b          	addiw	a5,a5,512
    8000458c:	fcf70ae3          	beq	a4,a5,80004560 <pipewrite+0x6c>
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    80004590:	86de                	mv	a3,s7
    80004592:	01590633          	add	a2,s2,s5
    80004596:	85e2                	mv	a1,s8
    80004598:	0509b503          	ld	a0,80(s3)
    8000459c:	912fd0ef          	jal	800016ae <copyin>
    800045a0:	05650063          	beq	a0,s6,800045e0 <pipewrite+0xec>
      pi->data[pi->nwrite++ % PIPESIZE] = ch;
    800045a4:	21c4a783          	lw	a5,540(s1)
    800045a8:	0017871b          	addiw	a4,a5,1
    800045ac:	20e4ae23          	sw	a4,540(s1)
    800045b0:	1ff7f793          	andi	a5,a5,511
    800045b4:	97a6                	add	a5,a5,s1
    800045b6:	f9f44703          	lbu	a4,-97(s0)
    800045ba:	00e78c23          	sb	a4,24(a5)
      i++;
    800045be:	2905                	addiw	s2,s2,1
    800045c0:	b77d                	j	8000456e <pipewrite+0x7a>
    800045c2:	7b42                	ld	s6,48(sp)
    800045c4:	7ba2                	ld	s7,40(sp)
    800045c6:	7c02                	ld	s8,32(sp)
    800045c8:	6ce2                	ld	s9,24(sp)
    800045ca:	6d42                	ld	s10,16(sp)
  wakeup(&pi->nread);
    800045cc:	21848513          	addi	a0,s1,536
    800045d0:	933fd0ef          	jal	80001f02 <wakeup>
  release(&pi->lock);
    800045d4:	8526                	mv	a0,s1
    800045d6:	e8afc0ef          	jal	80000c60 <release>
  return i;
    800045da:	bf8d                	j	8000454c <pipewrite+0x58>
  int i = 0;
    800045dc:	4901                	li	s2,0
    800045de:	b7fd                	j	800045cc <pipewrite+0xd8>
    800045e0:	7b42                	ld	s6,48(sp)
    800045e2:	7ba2                	ld	s7,40(sp)
    800045e4:	7c02                	ld	s8,32(sp)
    800045e6:	6ce2                	ld	s9,24(sp)
    800045e8:	6d42                	ld	s10,16(sp)
    800045ea:	b7cd                	j	800045cc <pipewrite+0xd8>

00000000800045ec <piperead>:

int
piperead(struct pipe *pi, uint64 addr, int n)
{
    800045ec:	711d                	addi	sp,sp,-96
    800045ee:	ec86                	sd	ra,88(sp)
    800045f0:	e8a2                	sd	s0,80(sp)
    800045f2:	e4a6                	sd	s1,72(sp)
    800045f4:	e0ca                	sd	s2,64(sp)
    800045f6:	fc4e                	sd	s3,56(sp)
    800045f8:	f852                	sd	s4,48(sp)
    800045fa:	f456                	sd	s5,40(sp)
    800045fc:	1080                	addi	s0,sp,96
    800045fe:	84aa                	mv	s1,a0
    80004600:	892e                	mv	s2,a1
    80004602:	8ab2                	mv	s5,a2
  int i;
  struct proc *pr = myproc();
    80004604:	abafd0ef          	jal	800018be <myproc>
    80004608:	8a2a                	mv	s4,a0
  char ch;

  acquire(&pi->lock);
    8000460a:	8526                	mv	a0,s1
    8000460c:	dc0fc0ef          	jal	80000bcc <acquire>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004610:	2184a703          	lw	a4,536(s1)
    80004614:	21c4a783          	lw	a5,540(s1)
    if(killed(pr)){
      release(&pi->lock);
      return -1;
    }
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    80004618:	21848993          	addi	s3,s1,536
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    8000461c:	02f71763          	bne	a4,a5,8000464a <piperead+0x5e>
    80004620:	2244a783          	lw	a5,548(s1)
    80004624:	cf85                	beqz	a5,8000465c <piperead+0x70>
    if(killed(pr)){
    80004626:	8552                	mv	a0,s4
    80004628:	ac7fd0ef          	jal	800020ee <killed>
    8000462c:	e11d                	bnez	a0,80004652 <piperead+0x66>
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    8000462e:	85a6                	mv	a1,s1
    80004630:	854e                	mv	a0,s3
    80004632:	885fd0ef          	jal	80001eb6 <sleep>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004636:	2184a703          	lw	a4,536(s1)
    8000463a:	21c4a783          	lw	a5,540(s1)
    8000463e:	fef701e3          	beq	a4,a5,80004620 <piperead+0x34>
    80004642:	f05a                	sd	s6,32(sp)
    80004644:	ec5e                	sd	s7,24(sp)
    80004646:	e862                	sd	s8,16(sp)
    80004648:	a829                	j	80004662 <piperead+0x76>
    8000464a:	f05a                	sd	s6,32(sp)
    8000464c:	ec5e                	sd	s7,24(sp)
    8000464e:	e862                	sd	s8,16(sp)
    80004650:	a809                	j	80004662 <piperead+0x76>
      release(&pi->lock);
    80004652:	8526                	mv	a0,s1
    80004654:	e0cfc0ef          	jal	80000c60 <release>
      return -1;
    80004658:	59fd                	li	s3,-1
    8000465a:	a0a5                	j	800046c2 <piperead+0xd6>
    8000465c:	f05a                	sd	s6,32(sp)
    8000465e:	ec5e                	sd	s7,24(sp)
    80004660:	e862                	sd	s8,16(sp)
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004662:	4981                	li	s3,0
    if(pi->nread == pi->nwrite)
      break;
    ch = pi->data[pi->nread++ % PIPESIZE];
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    80004664:	faf40c13          	addi	s8,s0,-81
    80004668:	4b85                	li	s7,1
    8000466a:	5b7d                	li	s6,-1
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    8000466c:	05505163          	blez	s5,800046ae <piperead+0xc2>
    if(pi->nread == pi->nwrite)
    80004670:	2184a783          	lw	a5,536(s1)
    80004674:	21c4a703          	lw	a4,540(s1)
    80004678:	02f70b63          	beq	a4,a5,800046ae <piperead+0xc2>
    ch = pi->data[pi->nread++ % PIPESIZE];
    8000467c:	0017871b          	addiw	a4,a5,1
    80004680:	20e4ac23          	sw	a4,536(s1)
    80004684:	1ff7f793          	andi	a5,a5,511
    80004688:	97a6                	add	a5,a5,s1
    8000468a:	0187c783          	lbu	a5,24(a5)
    8000468e:	faf407a3          	sb	a5,-81(s0)
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    80004692:	86de                	mv	a3,s7
    80004694:	8662                	mv	a2,s8
    80004696:	85ca                	mv	a1,s2
    80004698:	050a3503          	ld	a0,80(s4)
    8000469c:	f55fc0ef          	jal	800015f0 <copyout>
    800046a0:	01650763          	beq	a0,s6,800046ae <piperead+0xc2>
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    800046a4:	2985                	addiw	s3,s3,1
    800046a6:	0905                	addi	s2,s2,1
    800046a8:	fd3a94e3          	bne	s5,s3,80004670 <piperead+0x84>
    800046ac:	89d6                	mv	s3,s5
      break;
  }
  wakeup(&pi->nwrite);  //DOC: piperead-wakeup
    800046ae:	21c48513          	addi	a0,s1,540
    800046b2:	851fd0ef          	jal	80001f02 <wakeup>
  release(&pi->lock);
    800046b6:	8526                	mv	a0,s1
    800046b8:	da8fc0ef          	jal	80000c60 <release>
    800046bc:	7b02                	ld	s6,32(sp)
    800046be:	6be2                	ld	s7,24(sp)
    800046c0:	6c42                	ld	s8,16(sp)
  return i;
}
    800046c2:	854e                	mv	a0,s3
    800046c4:	60e6                	ld	ra,88(sp)
    800046c6:	6446                	ld	s0,80(sp)
    800046c8:	64a6                	ld	s1,72(sp)
    800046ca:	6906                	ld	s2,64(sp)
    800046cc:	79e2                	ld	s3,56(sp)
    800046ce:	7a42                	ld	s4,48(sp)
    800046d0:	7aa2                	ld	s5,40(sp)
    800046d2:	6125                	addi	sp,sp,96
    800046d4:	8082                	ret

00000000800046d6 <flags2perm>:

static int loadseg(pde_t *, uint64, struct inode *, uint, uint);

// map ELF permissions to PTE permission bits.
int flags2perm(int flags)
{
    800046d6:	1141                	addi	sp,sp,-16
    800046d8:	e406                	sd	ra,8(sp)
    800046da:	e022                	sd	s0,0(sp)
    800046dc:	0800                	addi	s0,sp,16
    800046de:	87aa                	mv	a5,a0
    int perm = 0;
    if(flags & 0x1)
    800046e0:	0035151b          	slliw	a0,a0,0x3
    800046e4:	8921                	andi	a0,a0,8
      perm = PTE_X;
    if(flags & 0x2)
    800046e6:	8b89                	andi	a5,a5,2
    800046e8:	c399                	beqz	a5,800046ee <flags2perm+0x18>
      perm |= PTE_W;
    800046ea:	00456513          	ori	a0,a0,4
    return perm;
}
    800046ee:	60a2                	ld	ra,8(sp)
    800046f0:	6402                	ld	s0,0(sp)
    800046f2:	0141                	addi	sp,sp,16
    800046f4:	8082                	ret

00000000800046f6 <kexec>:
//
// the implementation of the exec() system call
//
int
kexec(char *path, char **argv)
{
    800046f6:	de010113          	addi	sp,sp,-544
    800046fa:	20113c23          	sd	ra,536(sp)
    800046fe:	20813823          	sd	s0,528(sp)
    80004702:	20913423          	sd	s1,520(sp)
    80004706:	21213023          	sd	s2,512(sp)
    8000470a:	1400                	addi	s0,sp,544
    8000470c:	892a                	mv	s2,a0
    8000470e:	dea43823          	sd	a0,-528(s0)
    80004712:	e0b43023          	sd	a1,-512(s0)
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pagetable_t pagetable = 0, oldpagetable;
  struct proc *p = myproc();
    80004716:	9a8fd0ef          	jal	800018be <myproc>
    8000471a:	84aa                	mv	s1,a0

  begin_op();
    8000471c:	d96ff0ef          	jal	80003cb2 <begin_op>

  // Open the executable file.
  if((ip = namei(path)) == 0){
    80004720:	854a                	mv	a0,s2
    80004722:	bb6ff0ef          	jal	80003ad8 <namei>
    80004726:	cd21                	beqz	a0,8000477e <kexec+0x88>
    80004728:	fbd2                	sd	s4,496(sp)
    8000472a:	8a2a                	mv	s4,a0
    end_op();
    return -1;
  }
  ilock(ip);
    8000472c:	b83fe0ef          	jal	800032ae <ilock>

  // Read the ELF header.
  if(readi(ip, 0, (uint64)&elf, 0, sizeof(elf)) != sizeof(elf))
    80004730:	04000713          	li	a4,64
    80004734:	4681                	li	a3,0
    80004736:	e5040613          	addi	a2,s0,-432
    8000473a:	4581                	li	a1,0
    8000473c:	8552                	mv	a0,s4
    8000473e:	f03fe0ef          	jal	80003640 <readi>
    80004742:	04000793          	li	a5,64
    80004746:	00f51a63          	bne	a0,a5,8000475a <kexec+0x64>
    goto bad;

  // Is this really an ELF file?
  if(elf.magic != ELF_MAGIC)
    8000474a:	e5042703          	lw	a4,-432(s0)
    8000474e:	464c47b7          	lui	a5,0x464c4
    80004752:	57f78793          	addi	a5,a5,1407 # 464c457f <_entry-0x39b3ba81>
    80004756:	02f70863          	beq	a4,a5,80004786 <kexec+0x90>

 bad:
  if(pagetable)
    proc_freepagetable(pagetable, sz);
  if(ip){
    iunlockput(ip);
    8000475a:	8552                	mv	a0,s4
    8000475c:	d5dfe0ef          	jal	800034b8 <iunlockput>
    end_op();
    80004760:	dbcff0ef          	jal	80003d1c <end_op>
  }
  return -1;
    80004764:	557d                	li	a0,-1
    80004766:	7a5e                	ld	s4,496(sp)
}
    80004768:	21813083          	ld	ra,536(sp)
    8000476c:	21013403          	ld	s0,528(sp)
    80004770:	20813483          	ld	s1,520(sp)
    80004774:	20013903          	ld	s2,512(sp)
    80004778:	22010113          	addi	sp,sp,544
    8000477c:	8082                	ret
    end_op();
    8000477e:	d9eff0ef          	jal	80003d1c <end_op>
    return -1;
    80004782:	557d                	li	a0,-1
    80004784:	b7d5                	j	80004768 <kexec+0x72>
    80004786:	f3da                	sd	s6,480(sp)
  if((pagetable = proc_pagetable(p)) == 0)
    80004788:	8526                	mv	a0,s1
    8000478a:	a3afd0ef          	jal	800019c4 <proc_pagetable>
    8000478e:	8b2a                	mv	s6,a0
    80004790:	26050d63          	beqz	a0,80004a0a <kexec+0x314>
    80004794:	ffce                	sd	s3,504(sp)
    80004796:	f7d6                	sd	s5,488(sp)
    80004798:	efde                	sd	s7,472(sp)
    8000479a:	ebe2                	sd	s8,464(sp)
    8000479c:	e7e6                	sd	s9,456(sp)
    8000479e:	e3ea                	sd	s10,448(sp)
    800047a0:	ff6e                	sd	s11,440(sp)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    800047a2:	e7042683          	lw	a3,-400(s0)
    800047a6:	e8845783          	lhu	a5,-376(s0)
    800047aa:	0e078763          	beqz	a5,80004898 <kexec+0x1a2>
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    800047ae:	4901                	li	s2,0
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    800047b0:	4d01                	li	s10,0
    if(readi(ip, 0, (uint64)&ph, off, sizeof(ph)) != sizeof(ph))
    800047b2:	03800d93          	li	s11,56
    if(ph.vaddr % PGSIZE != 0)
    800047b6:	6c85                	lui	s9,0x1
    800047b8:	fffc8793          	addi	a5,s9,-1 # fff <_entry-0x7ffff001>
    800047bc:	def43423          	sd	a5,-536(s0)

  for(i = 0; i < sz; i += PGSIZE){
    pa = walkaddr(pagetable, va + i);
    if(pa == 0)
      panic("loadseg: address should exist");
    if(sz - i < PGSIZE)
    800047c0:	6a85                	lui	s5,0x1
    800047c2:	a085                	j	80004822 <kexec+0x12c>
      panic("loadseg: address should exist");
    800047c4:	00003517          	auipc	a0,0x3
    800047c8:	e2450513          	addi	a0,a0,-476 # 800075e8 <etext+0x5e8>
    800047cc:	812fc0ef          	jal	800007de <panic>
    if(sz - i < PGSIZE)
    800047d0:	2901                	sext.w	s2,s2
      n = sz - i;
    else
      n = PGSIZE;
    if(readi(ip, 0, (uint64)pa, offset+i, n) != n)
    800047d2:	874a                	mv	a4,s2
    800047d4:	009c06bb          	addw	a3,s8,s1
    800047d8:	4581                	li	a1,0
    800047da:	8552                	mv	a0,s4
    800047dc:	e65fe0ef          	jal	80003640 <readi>
    800047e0:	22a91963          	bne	s2,a0,80004a12 <kexec+0x31c>
  for(i = 0; i < sz; i += PGSIZE){
    800047e4:	009a84bb          	addw	s1,s5,s1
    800047e8:	0334f263          	bgeu	s1,s3,8000480c <kexec+0x116>
    pa = walkaddr(pagetable, va + i);
    800047ec:	02049593          	slli	a1,s1,0x20
    800047f0:	9181                	srli	a1,a1,0x20
    800047f2:	95de                	add	a1,a1,s7
    800047f4:	855a                	mv	a0,s6
    800047f6:	fd4fc0ef          	jal	80000fca <walkaddr>
    800047fa:	862a                	mv	a2,a0
    if(pa == 0)
    800047fc:	d561                	beqz	a0,800047c4 <kexec+0xce>
    if(sz - i < PGSIZE)
    800047fe:	409987bb          	subw	a5,s3,s1
    80004802:	893e                	mv	s2,a5
    80004804:	fcfcf6e3          	bgeu	s9,a5,800047d0 <kexec+0xda>
    80004808:	8956                	mv	s2,s5
    8000480a:	b7d9                	j	800047d0 <kexec+0xda>
    sz = sz1;
    8000480c:	df843903          	ld	s2,-520(s0)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80004810:	2d05                	addiw	s10,s10,1
    80004812:	e0843783          	ld	a5,-504(s0)
    80004816:	0387869b          	addiw	a3,a5,56
    8000481a:	e8845783          	lhu	a5,-376(s0)
    8000481e:	06fd5e63          	bge	s10,a5,8000489a <kexec+0x1a4>
    if(readi(ip, 0, (uint64)&ph, off, sizeof(ph)) != sizeof(ph))
    80004822:	e0d43423          	sd	a3,-504(s0)
    80004826:	876e                	mv	a4,s11
    80004828:	e1840613          	addi	a2,s0,-488
    8000482c:	4581                	li	a1,0
    8000482e:	8552                	mv	a0,s4
    80004830:	e11fe0ef          	jal	80003640 <readi>
    80004834:	1db51d63          	bne	a0,s11,80004a0e <kexec+0x318>
    if(ph.type != ELF_PROG_LOAD)
    80004838:	e1842783          	lw	a5,-488(s0)
    8000483c:	4705                	li	a4,1
    8000483e:	fce799e3          	bne	a5,a4,80004810 <kexec+0x11a>
    if(ph.memsz < ph.filesz)
    80004842:	e4043483          	ld	s1,-448(s0)
    80004846:	e3843783          	ld	a5,-456(s0)
    8000484a:	1ef4e263          	bltu	s1,a5,80004a2e <kexec+0x338>
    if(ph.vaddr + ph.memsz < ph.vaddr)
    8000484e:	e2843783          	ld	a5,-472(s0)
    80004852:	94be                	add	s1,s1,a5
    80004854:	1ef4e063          	bltu	s1,a5,80004a34 <kexec+0x33e>
    if(ph.vaddr % PGSIZE != 0)
    80004858:	de843703          	ld	a4,-536(s0)
    8000485c:	8ff9                	and	a5,a5,a4
    8000485e:	1c079e63          	bnez	a5,80004a3a <kexec+0x344>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz, flags2perm(ph.flags))) == 0)
    80004862:	e1c42503          	lw	a0,-484(s0)
    80004866:	e71ff0ef          	jal	800046d6 <flags2perm>
    8000486a:	86aa                	mv	a3,a0
    8000486c:	8626                	mv	a2,s1
    8000486e:	85ca                	mv	a1,s2
    80004870:	855a                	mv	a0,s6
    80004872:	a31fc0ef          	jal	800012a2 <uvmalloc>
    80004876:	dea43c23          	sd	a0,-520(s0)
    8000487a:	1c050363          	beqz	a0,80004a40 <kexec+0x34a>
    if(loadseg(pagetable, ph.vaddr, ip, ph.off, ph.filesz) < 0)
    8000487e:	e2843b83          	ld	s7,-472(s0)
    80004882:	e2042c03          	lw	s8,-480(s0)
    80004886:	e3842983          	lw	s3,-456(s0)
  for(i = 0; i < sz; i += PGSIZE){
    8000488a:	00098463          	beqz	s3,80004892 <kexec+0x19c>
    8000488e:	4481                	li	s1,0
    80004890:	bfb1                	j	800047ec <kexec+0xf6>
    sz = sz1;
    80004892:	df843903          	ld	s2,-520(s0)
    80004896:	bfad                	j	80004810 <kexec+0x11a>
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    80004898:	4901                	li	s2,0
  iunlockput(ip);
    8000489a:	8552                	mv	a0,s4
    8000489c:	c1dfe0ef          	jal	800034b8 <iunlockput>
  end_op();
    800048a0:	c7cff0ef          	jal	80003d1c <end_op>
  p = myproc();
    800048a4:	81afd0ef          	jal	800018be <myproc>
    800048a8:	8aaa                	mv	s5,a0
  uint64 oldsz = p->sz;
    800048aa:	04853d03          	ld	s10,72(a0)
  sz = PGROUNDUP(sz);
    800048ae:	6985                	lui	s3,0x1
    800048b0:	19fd                	addi	s3,s3,-1 # fff <_entry-0x7ffff001>
    800048b2:	99ca                	add	s3,s3,s2
    800048b4:	77fd                	lui	a5,0xfffff
    800048b6:	00f9f9b3          	and	s3,s3,a5
  if((sz1 = uvmalloc(pagetable, sz, sz + (USERSTACK+1)*PGSIZE, PTE_W)) == 0)
    800048ba:	4691                	li	a3,4
    800048bc:	6609                	lui	a2,0x2
    800048be:	964e                	add	a2,a2,s3
    800048c0:	85ce                	mv	a1,s3
    800048c2:	855a                	mv	a0,s6
    800048c4:	9dffc0ef          	jal	800012a2 <uvmalloc>
    800048c8:	8a2a                	mv	s4,a0
    800048ca:	e105                	bnez	a0,800048ea <kexec+0x1f4>
    proc_freepagetable(pagetable, sz);
    800048cc:	85ce                	mv	a1,s3
    800048ce:	855a                	mv	a0,s6
    800048d0:	978fd0ef          	jal	80001a48 <proc_freepagetable>
  return -1;
    800048d4:	557d                	li	a0,-1
    800048d6:	79fe                	ld	s3,504(sp)
    800048d8:	7a5e                	ld	s4,496(sp)
    800048da:	7abe                	ld	s5,488(sp)
    800048dc:	7b1e                	ld	s6,480(sp)
    800048de:	6bfe                	ld	s7,472(sp)
    800048e0:	6c5e                	ld	s8,464(sp)
    800048e2:	6cbe                	ld	s9,456(sp)
    800048e4:	6d1e                	ld	s10,448(sp)
    800048e6:	7dfa                	ld	s11,440(sp)
    800048e8:	b541                	j	80004768 <kexec+0x72>
  uvmclear(pagetable, sz-(USERSTACK+1)*PGSIZE);
    800048ea:	75f9                	lui	a1,0xffffe
    800048ec:	95aa                	add	a1,a1,a0
    800048ee:	855a                	mv	a0,s6
    800048f0:	b95fc0ef          	jal	80001484 <uvmclear>
  stackbase = sp - USERSTACK*PGSIZE;
    800048f4:	7bfd                	lui	s7,0xfffff
    800048f6:	9bd2                	add	s7,s7,s4
  for(argc = 0; argv[argc]; argc++) {
    800048f8:	e0043783          	ld	a5,-512(s0)
    800048fc:	6388                	ld	a0,0(a5)
  sp = sz;
    800048fe:	8952                	mv	s2,s4
  for(argc = 0; argv[argc]; argc++) {
    80004900:	4481                	li	s1,0
    ustack[argc] = sp;
    80004902:	e9040c93          	addi	s9,s0,-368
    if(argc >= MAXARG)
    80004906:	02000c13          	li	s8,32
  for(argc = 0; argv[argc]; argc++) {
    8000490a:	cd21                	beqz	a0,80004962 <kexec+0x26c>
    sp -= strlen(argv[argc]) + 1;
    8000490c:	d18fc0ef          	jal	80000e24 <strlen>
    80004910:	0015079b          	addiw	a5,a0,1
    80004914:	40f907b3          	sub	a5,s2,a5
    sp -= sp % 16; // riscv sp must be 16-byte aligned
    80004918:	ff07f913          	andi	s2,a5,-16
    if(sp < stackbase)
    8000491c:	13796563          	bltu	s2,s7,80004a46 <kexec+0x350>
    if(copyout(pagetable, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
    80004920:	e0043d83          	ld	s11,-512(s0)
    80004924:	000db983          	ld	s3,0(s11)
    80004928:	854e                	mv	a0,s3
    8000492a:	cfafc0ef          	jal	80000e24 <strlen>
    8000492e:	0015069b          	addiw	a3,a0,1
    80004932:	864e                	mv	a2,s3
    80004934:	85ca                	mv	a1,s2
    80004936:	855a                	mv	a0,s6
    80004938:	cb9fc0ef          	jal	800015f0 <copyout>
    8000493c:	10054763          	bltz	a0,80004a4a <kexec+0x354>
    ustack[argc] = sp;
    80004940:	00349793          	slli	a5,s1,0x3
    80004944:	97e6                	add	a5,a5,s9
    80004946:	0127b023          	sd	s2,0(a5) # fffffffffffff000 <end+0xffffffff7ffde428>
  for(argc = 0; argv[argc]; argc++) {
    8000494a:	0485                	addi	s1,s1,1
    8000494c:	008d8793          	addi	a5,s11,8
    80004950:	e0f43023          	sd	a5,-512(s0)
    80004954:	008db503          	ld	a0,8(s11)
    80004958:	c509                	beqz	a0,80004962 <kexec+0x26c>
    if(argc >= MAXARG)
    8000495a:	fb8499e3          	bne	s1,s8,8000490c <kexec+0x216>
  sz = sz1;
    8000495e:	89d2                	mv	s3,s4
    80004960:	b7b5                	j	800048cc <kexec+0x1d6>
  ustack[argc] = 0;
    80004962:	00349793          	slli	a5,s1,0x3
    80004966:	f9078793          	addi	a5,a5,-112
    8000496a:	97a2                	add	a5,a5,s0
    8000496c:	f007b023          	sd	zero,-256(a5)
  sp -= (argc+1) * sizeof(uint64);
    80004970:	00148693          	addi	a3,s1,1
    80004974:	068e                	slli	a3,a3,0x3
    80004976:	40d90933          	sub	s2,s2,a3
  sp -= sp % 16;
    8000497a:	ff097913          	andi	s2,s2,-16
  sz = sz1;
    8000497e:	89d2                	mv	s3,s4
  if(sp < stackbase)
    80004980:	f57966e3          	bltu	s2,s7,800048cc <kexec+0x1d6>
  if(copyout(pagetable, sp, (char *)ustack, (argc+1)*sizeof(uint64)) < 0)
    80004984:	e9040613          	addi	a2,s0,-368
    80004988:	85ca                	mv	a1,s2
    8000498a:	855a                	mv	a0,s6
    8000498c:	c65fc0ef          	jal	800015f0 <copyout>
    80004990:	f2054ee3          	bltz	a0,800048cc <kexec+0x1d6>
  p->trapframe->a1 = sp;
    80004994:	058ab783          	ld	a5,88(s5) # 1058 <_entry-0x7fffefa8>
    80004998:	0727bc23          	sd	s2,120(a5)
  for(last=s=path; *s; s++)
    8000499c:	df043783          	ld	a5,-528(s0)
    800049a0:	0007c703          	lbu	a4,0(a5)
    800049a4:	cf11                	beqz	a4,800049c0 <kexec+0x2ca>
    800049a6:	0785                	addi	a5,a5,1
    if(*s == '/')
    800049a8:	02f00693          	li	a3,47
    800049ac:	a029                	j	800049b6 <kexec+0x2c0>
  for(last=s=path; *s; s++)
    800049ae:	0785                	addi	a5,a5,1
    800049b0:	fff7c703          	lbu	a4,-1(a5)
    800049b4:	c711                	beqz	a4,800049c0 <kexec+0x2ca>
    if(*s == '/')
    800049b6:	fed71ce3          	bne	a4,a3,800049ae <kexec+0x2b8>
      last = s+1;
    800049ba:	def43823          	sd	a5,-528(s0)
    800049be:	bfc5                	j	800049ae <kexec+0x2b8>
  safestrcpy(p->name, last, sizeof(p->name));
    800049c0:	4641                	li	a2,16
    800049c2:	df043583          	ld	a1,-528(s0)
    800049c6:	158a8513          	addi	a0,s5,344
    800049ca:	c24fc0ef          	jal	80000dee <safestrcpy>
  oldpagetable = p->pagetable;
    800049ce:	050ab503          	ld	a0,80(s5)
  p->pagetable = pagetable;
    800049d2:	056ab823          	sd	s6,80(s5)
  p->sz = sz;
    800049d6:	054ab423          	sd	s4,72(s5)
  p->trapframe->epc = elf.entry;  // initial program counter = main
    800049da:	058ab783          	ld	a5,88(s5)
    800049de:	e6843703          	ld	a4,-408(s0)
    800049e2:	ef98                	sd	a4,24(a5)
  p->trapframe->sp = sp; // initial stack pointer
    800049e4:	058ab783          	ld	a5,88(s5)
    800049e8:	0327b823          	sd	s2,48(a5)
  proc_freepagetable(oldpagetable, oldsz);
    800049ec:	85ea                	mv	a1,s10
    800049ee:	85afd0ef          	jal	80001a48 <proc_freepagetable>
  return argc; // this ends up in a0, the first argument to main(argc, argv)
    800049f2:	0004851b          	sext.w	a0,s1
    800049f6:	79fe                	ld	s3,504(sp)
    800049f8:	7a5e                	ld	s4,496(sp)
    800049fa:	7abe                	ld	s5,488(sp)
    800049fc:	7b1e                	ld	s6,480(sp)
    800049fe:	6bfe                	ld	s7,472(sp)
    80004a00:	6c5e                	ld	s8,464(sp)
    80004a02:	6cbe                	ld	s9,456(sp)
    80004a04:	6d1e                	ld	s10,448(sp)
    80004a06:	7dfa                	ld	s11,440(sp)
    80004a08:	b385                	j	80004768 <kexec+0x72>
    80004a0a:	7b1e                	ld	s6,480(sp)
    80004a0c:	b3b9                	j	8000475a <kexec+0x64>
    80004a0e:	df243c23          	sd	s2,-520(s0)
    proc_freepagetable(pagetable, sz);
    80004a12:	df843583          	ld	a1,-520(s0)
    80004a16:	855a                	mv	a0,s6
    80004a18:	830fd0ef          	jal	80001a48 <proc_freepagetable>
  if(ip){
    80004a1c:	79fe                	ld	s3,504(sp)
    80004a1e:	7abe                	ld	s5,488(sp)
    80004a20:	7b1e                	ld	s6,480(sp)
    80004a22:	6bfe                	ld	s7,472(sp)
    80004a24:	6c5e                	ld	s8,464(sp)
    80004a26:	6cbe                	ld	s9,456(sp)
    80004a28:	6d1e                	ld	s10,448(sp)
    80004a2a:	7dfa                	ld	s11,440(sp)
    80004a2c:	b33d                	j	8000475a <kexec+0x64>
    80004a2e:	df243c23          	sd	s2,-520(s0)
    80004a32:	b7c5                	j	80004a12 <kexec+0x31c>
    80004a34:	df243c23          	sd	s2,-520(s0)
    80004a38:	bfe9                	j	80004a12 <kexec+0x31c>
    80004a3a:	df243c23          	sd	s2,-520(s0)
    80004a3e:	bfd1                	j	80004a12 <kexec+0x31c>
    80004a40:	df243c23          	sd	s2,-520(s0)
    80004a44:	b7f9                	j	80004a12 <kexec+0x31c>
  sz = sz1;
    80004a46:	89d2                	mv	s3,s4
    80004a48:	b551                	j	800048cc <kexec+0x1d6>
    80004a4a:	89d2                	mv	s3,s4
    80004a4c:	b541                	j	800048cc <kexec+0x1d6>

0000000080004a4e <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
    80004a4e:	7179                	addi	sp,sp,-48
    80004a50:	f406                	sd	ra,40(sp)
    80004a52:	f022                	sd	s0,32(sp)
    80004a54:	ec26                	sd	s1,24(sp)
    80004a56:	e84a                	sd	s2,16(sp)
    80004a58:	1800                	addi	s0,sp,48
    80004a5a:	892e                	mv	s2,a1
    80004a5c:	84b2                	mv	s1,a2
  int fd;
  struct file *f;

  argint(n, &fd);
    80004a5e:	fdc40593          	addi	a1,s0,-36
    80004a62:	e35fd0ef          	jal	80002896 <argint>
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
    80004a66:	fdc42703          	lw	a4,-36(s0)
    80004a6a:	47bd                	li	a5,15
    80004a6c:	02e7e963          	bltu	a5,a4,80004a9e <argfd+0x50>
    80004a70:	e4ffc0ef          	jal	800018be <myproc>
    80004a74:	fdc42703          	lw	a4,-36(s0)
    80004a78:	01a70793          	addi	a5,a4,26
    80004a7c:	078e                	slli	a5,a5,0x3
    80004a7e:	953e                	add	a0,a0,a5
    80004a80:	611c                	ld	a5,0(a0)
    80004a82:	c385                	beqz	a5,80004aa2 <argfd+0x54>
    return -1;
  if(pfd)
    80004a84:	00090463          	beqz	s2,80004a8c <argfd+0x3e>
    *pfd = fd;
    80004a88:	00e92023          	sw	a4,0(s2)
  if(pf)
    *pf = f;
  return 0;
    80004a8c:	4501                	li	a0,0
  if(pf)
    80004a8e:	c091                	beqz	s1,80004a92 <argfd+0x44>
    *pf = f;
    80004a90:	e09c                	sd	a5,0(s1)
}
    80004a92:	70a2                	ld	ra,40(sp)
    80004a94:	7402                	ld	s0,32(sp)
    80004a96:	64e2                	ld	s1,24(sp)
    80004a98:	6942                	ld	s2,16(sp)
    80004a9a:	6145                	addi	sp,sp,48
    80004a9c:	8082                	ret
    return -1;
    80004a9e:	557d                	li	a0,-1
    80004aa0:	bfcd                	j	80004a92 <argfd+0x44>
    80004aa2:	557d                	li	a0,-1
    80004aa4:	b7fd                	j	80004a92 <argfd+0x44>

0000000080004aa6 <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
    80004aa6:	1101                	addi	sp,sp,-32
    80004aa8:	ec06                	sd	ra,24(sp)
    80004aaa:	e822                	sd	s0,16(sp)
    80004aac:	e426                	sd	s1,8(sp)
    80004aae:	1000                	addi	s0,sp,32
    80004ab0:	84aa                	mv	s1,a0
  int fd;
  struct proc *p = myproc();
    80004ab2:	e0dfc0ef          	jal	800018be <myproc>
    80004ab6:	862a                	mv	a2,a0

  for(fd = 0; fd < NOFILE; fd++){
    80004ab8:	0d050793          	addi	a5,a0,208
    80004abc:	4501                	li	a0,0
    80004abe:	46c1                	li	a3,16
    if(p->ofile[fd] == 0){
    80004ac0:	6398                	ld	a4,0(a5)
    80004ac2:	cb19                	beqz	a4,80004ad8 <fdalloc+0x32>
  for(fd = 0; fd < NOFILE; fd++){
    80004ac4:	2505                	addiw	a0,a0,1
    80004ac6:	07a1                	addi	a5,a5,8
    80004ac8:	fed51ce3          	bne	a0,a3,80004ac0 <fdalloc+0x1a>
      p->ofile[fd] = f;
      return fd;
    }
  }
  return -1;
    80004acc:	557d                	li	a0,-1
}
    80004ace:	60e2                	ld	ra,24(sp)
    80004ad0:	6442                	ld	s0,16(sp)
    80004ad2:	64a2                	ld	s1,8(sp)
    80004ad4:	6105                	addi	sp,sp,32
    80004ad6:	8082                	ret
      p->ofile[fd] = f;
    80004ad8:	01a50793          	addi	a5,a0,26
    80004adc:	078e                	slli	a5,a5,0x3
    80004ade:	963e                	add	a2,a2,a5
    80004ae0:	e204                	sd	s1,0(a2)
      return fd;
    80004ae2:	b7f5                	j	80004ace <fdalloc+0x28>

0000000080004ae4 <create>:
  return -1;
}

static struct inode*
create(char *path, short type, short major, short minor)
{
    80004ae4:	715d                	addi	sp,sp,-80
    80004ae6:	e486                	sd	ra,72(sp)
    80004ae8:	e0a2                	sd	s0,64(sp)
    80004aea:	fc26                	sd	s1,56(sp)
    80004aec:	f84a                	sd	s2,48(sp)
    80004aee:	f44e                	sd	s3,40(sp)
    80004af0:	ec56                	sd	s5,24(sp)
    80004af2:	e85a                	sd	s6,16(sp)
    80004af4:	0880                	addi	s0,sp,80
    80004af6:	8b2e                	mv	s6,a1
    80004af8:	89b2                	mv	s3,a2
    80004afa:	8936                	mv	s2,a3
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
    80004afc:	fb040593          	addi	a1,s0,-80
    80004b00:	ff3fe0ef          	jal	80003af2 <nameiparent>
    80004b04:	84aa                	mv	s1,a0
    80004b06:	10050a63          	beqz	a0,80004c1a <create+0x136>
    return 0;

  ilock(dp);
    80004b0a:	fa4fe0ef          	jal	800032ae <ilock>

  if((ip = dirlookup(dp, name, 0)) != 0){
    80004b0e:	4601                	li	a2,0
    80004b10:	fb040593          	addi	a1,s0,-80
    80004b14:	8526                	mv	a0,s1
    80004b16:	d37fe0ef          	jal	8000384c <dirlookup>
    80004b1a:	8aaa                	mv	s5,a0
    80004b1c:	c129                	beqz	a0,80004b5e <create+0x7a>
    iunlockput(dp);
    80004b1e:	8526                	mv	a0,s1
    80004b20:	999fe0ef          	jal	800034b8 <iunlockput>
    ilock(ip);
    80004b24:	8556                	mv	a0,s5
    80004b26:	f88fe0ef          	jal	800032ae <ilock>
    if(type == T_FILE && (ip->type == T_FILE || ip->type == T_DEVICE))
    80004b2a:	4789                	li	a5,2
    80004b2c:	02fb1463          	bne	s6,a5,80004b54 <create+0x70>
    80004b30:	044ad783          	lhu	a5,68(s5)
    80004b34:	37f9                	addiw	a5,a5,-2
    80004b36:	17c2                	slli	a5,a5,0x30
    80004b38:	93c1                	srli	a5,a5,0x30
    80004b3a:	4705                	li	a4,1
    80004b3c:	00f76c63          	bltu	a4,a5,80004b54 <create+0x70>
  ip->nlink = 0;
  iupdate(ip);
  iunlockput(ip);
  iunlockput(dp);
  return 0;
}
    80004b40:	8556                	mv	a0,s5
    80004b42:	60a6                	ld	ra,72(sp)
    80004b44:	6406                	ld	s0,64(sp)
    80004b46:	74e2                	ld	s1,56(sp)
    80004b48:	7942                	ld	s2,48(sp)
    80004b4a:	79a2                	ld	s3,40(sp)
    80004b4c:	6ae2                	ld	s5,24(sp)
    80004b4e:	6b42                	ld	s6,16(sp)
    80004b50:	6161                	addi	sp,sp,80
    80004b52:	8082                	ret
    iunlockput(ip);
    80004b54:	8556                	mv	a0,s5
    80004b56:	963fe0ef          	jal	800034b8 <iunlockput>
    return 0;
    80004b5a:	4a81                	li	s5,0
    80004b5c:	b7d5                	j	80004b40 <create+0x5c>
    80004b5e:	f052                	sd	s4,32(sp)
  if((ip = ialloc(dp->dev, type)) == 0){
    80004b60:	85da                	mv	a1,s6
    80004b62:	4088                	lw	a0,0(s1)
    80004b64:	ddafe0ef          	jal	8000313e <ialloc>
    80004b68:	8a2a                	mv	s4,a0
    80004b6a:	cd15                	beqz	a0,80004ba6 <create+0xc2>
  ilock(ip);
    80004b6c:	f42fe0ef          	jal	800032ae <ilock>
  ip->major = major;
    80004b70:	053a1323          	sh	s3,70(s4)
  ip->minor = minor;
    80004b74:	052a1423          	sh	s2,72(s4)
  ip->nlink = 1;
    80004b78:	4905                	li	s2,1
    80004b7a:	052a1523          	sh	s2,74(s4)
  iupdate(ip);
    80004b7e:	8552                	mv	a0,s4
    80004b80:	e7afe0ef          	jal	800031fa <iupdate>
  if(type == T_DIR){  // Create . and .. entries.
    80004b84:	032b0763          	beq	s6,s2,80004bb2 <create+0xce>
  if(dirlink(dp, name, ip->inum) < 0)
    80004b88:	004a2603          	lw	a2,4(s4)
    80004b8c:	fb040593          	addi	a1,s0,-80
    80004b90:	8526                	mv	a0,s1
    80004b92:	e9dfe0ef          	jal	80003a2e <dirlink>
    80004b96:	06054563          	bltz	a0,80004c00 <create+0x11c>
  iunlockput(dp);
    80004b9a:	8526                	mv	a0,s1
    80004b9c:	91dfe0ef          	jal	800034b8 <iunlockput>
  return ip;
    80004ba0:	8ad2                	mv	s5,s4
    80004ba2:	7a02                	ld	s4,32(sp)
    80004ba4:	bf71                	j	80004b40 <create+0x5c>
    iunlockput(dp);
    80004ba6:	8526                	mv	a0,s1
    80004ba8:	911fe0ef          	jal	800034b8 <iunlockput>
    return 0;
    80004bac:	8ad2                	mv	s5,s4
    80004bae:	7a02                	ld	s4,32(sp)
    80004bb0:	bf41                	j	80004b40 <create+0x5c>
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
    80004bb2:	004a2603          	lw	a2,4(s4)
    80004bb6:	00003597          	auipc	a1,0x3
    80004bba:	a5258593          	addi	a1,a1,-1454 # 80007608 <etext+0x608>
    80004bbe:	8552                	mv	a0,s4
    80004bc0:	e6ffe0ef          	jal	80003a2e <dirlink>
    80004bc4:	02054e63          	bltz	a0,80004c00 <create+0x11c>
    80004bc8:	40d0                	lw	a2,4(s1)
    80004bca:	00003597          	auipc	a1,0x3
    80004bce:	a4658593          	addi	a1,a1,-1466 # 80007610 <etext+0x610>
    80004bd2:	8552                	mv	a0,s4
    80004bd4:	e5bfe0ef          	jal	80003a2e <dirlink>
    80004bd8:	02054463          	bltz	a0,80004c00 <create+0x11c>
  if(dirlink(dp, name, ip->inum) < 0)
    80004bdc:	004a2603          	lw	a2,4(s4)
    80004be0:	fb040593          	addi	a1,s0,-80
    80004be4:	8526                	mv	a0,s1
    80004be6:	e49fe0ef          	jal	80003a2e <dirlink>
    80004bea:	00054b63          	bltz	a0,80004c00 <create+0x11c>
    dp->nlink++;  // for ".."
    80004bee:	04a4d783          	lhu	a5,74(s1)
    80004bf2:	2785                	addiw	a5,a5,1
    80004bf4:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    80004bf8:	8526                	mv	a0,s1
    80004bfa:	e00fe0ef          	jal	800031fa <iupdate>
    80004bfe:	bf71                	j	80004b9a <create+0xb6>
  ip->nlink = 0;
    80004c00:	040a1523          	sh	zero,74(s4)
  iupdate(ip);
    80004c04:	8552                	mv	a0,s4
    80004c06:	df4fe0ef          	jal	800031fa <iupdate>
  iunlockput(ip);
    80004c0a:	8552                	mv	a0,s4
    80004c0c:	8adfe0ef          	jal	800034b8 <iunlockput>
  iunlockput(dp);
    80004c10:	8526                	mv	a0,s1
    80004c12:	8a7fe0ef          	jal	800034b8 <iunlockput>
  return 0;
    80004c16:	7a02                	ld	s4,32(sp)
    80004c18:	b725                	j	80004b40 <create+0x5c>
    return 0;
    80004c1a:	8aaa                	mv	s5,a0
    80004c1c:	b715                	j	80004b40 <create+0x5c>

0000000080004c1e <sys_dup>:
{
    80004c1e:	7179                	addi	sp,sp,-48
    80004c20:	f406                	sd	ra,40(sp)
    80004c22:	f022                	sd	s0,32(sp)
    80004c24:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0)
    80004c26:	fd840613          	addi	a2,s0,-40
    80004c2a:	4581                	li	a1,0
    80004c2c:	4501                	li	a0,0
    80004c2e:	e21ff0ef          	jal	80004a4e <argfd>
    return -1;
    80004c32:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0)
    80004c34:	02054363          	bltz	a0,80004c5a <sys_dup+0x3c>
    80004c38:	ec26                	sd	s1,24(sp)
    80004c3a:	e84a                	sd	s2,16(sp)
  if((fd=fdalloc(f)) < 0)
    80004c3c:	fd843903          	ld	s2,-40(s0)
    80004c40:	854a                	mv	a0,s2
    80004c42:	e65ff0ef          	jal	80004aa6 <fdalloc>
    80004c46:	84aa                	mv	s1,a0
    return -1;
    80004c48:	57fd                	li	a5,-1
  if((fd=fdalloc(f)) < 0)
    80004c4a:	00054d63          	bltz	a0,80004c64 <sys_dup+0x46>
  filedup(f);
    80004c4e:	854a                	mv	a0,s2
    80004c50:	c2eff0ef          	jal	8000407e <filedup>
  return fd;
    80004c54:	87a6                	mv	a5,s1
    80004c56:	64e2                	ld	s1,24(sp)
    80004c58:	6942                	ld	s2,16(sp)
}
    80004c5a:	853e                	mv	a0,a5
    80004c5c:	70a2                	ld	ra,40(sp)
    80004c5e:	7402                	ld	s0,32(sp)
    80004c60:	6145                	addi	sp,sp,48
    80004c62:	8082                	ret
    80004c64:	64e2                	ld	s1,24(sp)
    80004c66:	6942                	ld	s2,16(sp)
    80004c68:	bfcd                	j	80004c5a <sys_dup+0x3c>

0000000080004c6a <sys_read>:
{
    80004c6a:	7179                	addi	sp,sp,-48
    80004c6c:	f406                	sd	ra,40(sp)
    80004c6e:	f022                	sd	s0,32(sp)
    80004c70:	1800                	addi	s0,sp,48
  argaddr(1, &p);
    80004c72:	fd840593          	addi	a1,s0,-40
    80004c76:	4505                	li	a0,1
    80004c78:	c3bfd0ef          	jal	800028b2 <argaddr>
  argint(2, &n);
    80004c7c:	fe440593          	addi	a1,s0,-28
    80004c80:	4509                	li	a0,2
    80004c82:	c15fd0ef          	jal	80002896 <argint>
  if(argfd(0, 0, &f) < 0)
    80004c86:	fe840613          	addi	a2,s0,-24
    80004c8a:	4581                	li	a1,0
    80004c8c:	4501                	li	a0,0
    80004c8e:	dc1ff0ef          	jal	80004a4e <argfd>
    80004c92:	87aa                	mv	a5,a0
    return -1;
    80004c94:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    80004c96:	0007ca63          	bltz	a5,80004caa <sys_read+0x40>
  return fileread(f, p, n);
    80004c9a:	fe442603          	lw	a2,-28(s0)
    80004c9e:	fd843583          	ld	a1,-40(s0)
    80004ca2:	fe843503          	ld	a0,-24(s0)
    80004ca6:	d3eff0ef          	jal	800041e4 <fileread>
}
    80004caa:	70a2                	ld	ra,40(sp)
    80004cac:	7402                	ld	s0,32(sp)
    80004cae:	6145                	addi	sp,sp,48
    80004cb0:	8082                	ret

0000000080004cb2 <sys_write>:
{
    80004cb2:	7179                	addi	sp,sp,-48
    80004cb4:	f406                	sd	ra,40(sp)
    80004cb6:	f022                	sd	s0,32(sp)
    80004cb8:	1800                	addi	s0,sp,48
  argaddr(1, &p);
    80004cba:	fd840593          	addi	a1,s0,-40
    80004cbe:	4505                	li	a0,1
    80004cc0:	bf3fd0ef          	jal	800028b2 <argaddr>
  argint(2, &n);
    80004cc4:	fe440593          	addi	a1,s0,-28
    80004cc8:	4509                	li	a0,2
    80004cca:	bcdfd0ef          	jal	80002896 <argint>
  if(argfd(0, 0, &f) < 0)
    80004cce:	fe840613          	addi	a2,s0,-24
    80004cd2:	4581                	li	a1,0
    80004cd4:	4501                	li	a0,0
    80004cd6:	d79ff0ef          	jal	80004a4e <argfd>
    80004cda:	87aa                	mv	a5,a0
    return -1;
    80004cdc:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    80004cde:	0007ca63          	bltz	a5,80004cf2 <sys_write+0x40>
  return filewrite(f, p, n);
    80004ce2:	fe442603          	lw	a2,-28(s0)
    80004ce6:	fd843583          	ld	a1,-40(s0)
    80004cea:	fe843503          	ld	a0,-24(s0)
    80004cee:	db4ff0ef          	jal	800042a2 <filewrite>
}
    80004cf2:	70a2                	ld	ra,40(sp)
    80004cf4:	7402                	ld	s0,32(sp)
    80004cf6:	6145                	addi	sp,sp,48
    80004cf8:	8082                	ret

0000000080004cfa <sys_close>:
{
    80004cfa:	1101                	addi	sp,sp,-32
    80004cfc:	ec06                	sd	ra,24(sp)
    80004cfe:	e822                	sd	s0,16(sp)
    80004d00:	1000                	addi	s0,sp,32
  if(argfd(0, &fd, &f) < 0)
    80004d02:	fe040613          	addi	a2,s0,-32
    80004d06:	fec40593          	addi	a1,s0,-20
    80004d0a:	4501                	li	a0,0
    80004d0c:	d43ff0ef          	jal	80004a4e <argfd>
    return -1;
    80004d10:	57fd                	li	a5,-1
  if(argfd(0, &fd, &f) < 0)
    80004d12:	02054063          	bltz	a0,80004d32 <sys_close+0x38>
  myproc()->ofile[fd] = 0;
    80004d16:	ba9fc0ef          	jal	800018be <myproc>
    80004d1a:	fec42783          	lw	a5,-20(s0)
    80004d1e:	07e9                	addi	a5,a5,26
    80004d20:	078e                	slli	a5,a5,0x3
    80004d22:	953e                	add	a0,a0,a5
    80004d24:	00053023          	sd	zero,0(a0)
  fileclose(f);
    80004d28:	fe043503          	ld	a0,-32(s0)
    80004d2c:	b98ff0ef          	jal	800040c4 <fileclose>
  return 0;
    80004d30:	4781                	li	a5,0
}
    80004d32:	853e                	mv	a0,a5
    80004d34:	60e2                	ld	ra,24(sp)
    80004d36:	6442                	ld	s0,16(sp)
    80004d38:	6105                	addi	sp,sp,32
    80004d3a:	8082                	ret

0000000080004d3c <sys_fstat>:
{
    80004d3c:	1101                	addi	sp,sp,-32
    80004d3e:	ec06                	sd	ra,24(sp)
    80004d40:	e822                	sd	s0,16(sp)
    80004d42:	1000                	addi	s0,sp,32
  argaddr(1, &st);
    80004d44:	fe040593          	addi	a1,s0,-32
    80004d48:	4505                	li	a0,1
    80004d4a:	b69fd0ef          	jal	800028b2 <argaddr>
  if(argfd(0, 0, &f) < 0)
    80004d4e:	fe840613          	addi	a2,s0,-24
    80004d52:	4581                	li	a1,0
    80004d54:	4501                	li	a0,0
    80004d56:	cf9ff0ef          	jal	80004a4e <argfd>
    80004d5a:	87aa                	mv	a5,a0
    return -1;
    80004d5c:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    80004d5e:	0007c863          	bltz	a5,80004d6e <sys_fstat+0x32>
  return filestat(f, st);
    80004d62:	fe043583          	ld	a1,-32(s0)
    80004d66:	fe843503          	ld	a0,-24(s0)
    80004d6a:	c18ff0ef          	jal	80004182 <filestat>
}
    80004d6e:	60e2                	ld	ra,24(sp)
    80004d70:	6442                	ld	s0,16(sp)
    80004d72:	6105                	addi	sp,sp,32
    80004d74:	8082                	ret

0000000080004d76 <sys_link>:
{
    80004d76:	7169                	addi	sp,sp,-304
    80004d78:	f606                	sd	ra,296(sp)
    80004d7a:	f222                	sd	s0,288(sp)
    80004d7c:	1a00                	addi	s0,sp,304
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80004d7e:	08000613          	li	a2,128
    80004d82:	ed040593          	addi	a1,s0,-304
    80004d86:	4501                	li	a0,0
    80004d88:	b47fd0ef          	jal	800028ce <argstr>
    return -1;
    80004d8c:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80004d8e:	0c054e63          	bltz	a0,80004e6a <sys_link+0xf4>
    80004d92:	08000613          	li	a2,128
    80004d96:	f5040593          	addi	a1,s0,-176
    80004d9a:	4505                	li	a0,1
    80004d9c:	b33fd0ef          	jal	800028ce <argstr>
    return -1;
    80004da0:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80004da2:	0c054463          	bltz	a0,80004e6a <sys_link+0xf4>
    80004da6:	ee26                	sd	s1,280(sp)
  begin_op();
    80004da8:	f0bfe0ef          	jal	80003cb2 <begin_op>
  if((ip = namei(old)) == 0){
    80004dac:	ed040513          	addi	a0,s0,-304
    80004db0:	d29fe0ef          	jal	80003ad8 <namei>
    80004db4:	84aa                	mv	s1,a0
    80004db6:	c53d                	beqz	a0,80004e24 <sys_link+0xae>
  ilock(ip);
    80004db8:	cf6fe0ef          	jal	800032ae <ilock>
  if(ip->type == T_DIR){
    80004dbc:	04449703          	lh	a4,68(s1)
    80004dc0:	4785                	li	a5,1
    80004dc2:	06f70663          	beq	a4,a5,80004e2e <sys_link+0xb8>
    80004dc6:	ea4a                	sd	s2,272(sp)
  ip->nlink++;
    80004dc8:	04a4d783          	lhu	a5,74(s1)
    80004dcc:	2785                	addiw	a5,a5,1
    80004dce:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    80004dd2:	8526                	mv	a0,s1
    80004dd4:	c26fe0ef          	jal	800031fa <iupdate>
  iunlock(ip);
    80004dd8:	8526                	mv	a0,s1
    80004dda:	d82fe0ef          	jal	8000335c <iunlock>
  if((dp = nameiparent(new, name)) == 0)
    80004dde:	fd040593          	addi	a1,s0,-48
    80004de2:	f5040513          	addi	a0,s0,-176
    80004de6:	d0dfe0ef          	jal	80003af2 <nameiparent>
    80004dea:	892a                	mv	s2,a0
    80004dec:	cd21                	beqz	a0,80004e44 <sys_link+0xce>
  ilock(dp);
    80004dee:	cc0fe0ef          	jal	800032ae <ilock>
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
    80004df2:	00092703          	lw	a4,0(s2)
    80004df6:	409c                	lw	a5,0(s1)
    80004df8:	04f71363          	bne	a4,a5,80004e3e <sys_link+0xc8>
    80004dfc:	40d0                	lw	a2,4(s1)
    80004dfe:	fd040593          	addi	a1,s0,-48
    80004e02:	854a                	mv	a0,s2
    80004e04:	c2bfe0ef          	jal	80003a2e <dirlink>
    80004e08:	02054b63          	bltz	a0,80004e3e <sys_link+0xc8>
  iunlockput(dp);
    80004e0c:	854a                	mv	a0,s2
    80004e0e:	eaafe0ef          	jal	800034b8 <iunlockput>
  iput(ip);
    80004e12:	8526                	mv	a0,s1
    80004e14:	e1cfe0ef          	jal	80003430 <iput>
  end_op();
    80004e18:	f05fe0ef          	jal	80003d1c <end_op>
  return 0;
    80004e1c:	4781                	li	a5,0
    80004e1e:	64f2                	ld	s1,280(sp)
    80004e20:	6952                	ld	s2,272(sp)
    80004e22:	a0a1                	j	80004e6a <sys_link+0xf4>
    end_op();
    80004e24:	ef9fe0ef          	jal	80003d1c <end_op>
    return -1;
    80004e28:	57fd                	li	a5,-1
    80004e2a:	64f2                	ld	s1,280(sp)
    80004e2c:	a83d                	j	80004e6a <sys_link+0xf4>
    iunlockput(ip);
    80004e2e:	8526                	mv	a0,s1
    80004e30:	e88fe0ef          	jal	800034b8 <iunlockput>
    end_op();
    80004e34:	ee9fe0ef          	jal	80003d1c <end_op>
    return -1;
    80004e38:	57fd                	li	a5,-1
    80004e3a:	64f2                	ld	s1,280(sp)
    80004e3c:	a03d                	j	80004e6a <sys_link+0xf4>
    iunlockput(dp);
    80004e3e:	854a                	mv	a0,s2
    80004e40:	e78fe0ef          	jal	800034b8 <iunlockput>
  ilock(ip);
    80004e44:	8526                	mv	a0,s1
    80004e46:	c68fe0ef          	jal	800032ae <ilock>
  ip->nlink--;
    80004e4a:	04a4d783          	lhu	a5,74(s1)
    80004e4e:	37fd                	addiw	a5,a5,-1
    80004e50:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    80004e54:	8526                	mv	a0,s1
    80004e56:	ba4fe0ef          	jal	800031fa <iupdate>
  iunlockput(ip);
    80004e5a:	8526                	mv	a0,s1
    80004e5c:	e5cfe0ef          	jal	800034b8 <iunlockput>
  end_op();
    80004e60:	ebdfe0ef          	jal	80003d1c <end_op>
  return -1;
    80004e64:	57fd                	li	a5,-1
    80004e66:	64f2                	ld	s1,280(sp)
    80004e68:	6952                	ld	s2,272(sp)
}
    80004e6a:	853e                	mv	a0,a5
    80004e6c:	70b2                	ld	ra,296(sp)
    80004e6e:	7412                	ld	s0,288(sp)
    80004e70:	6155                	addi	sp,sp,304
    80004e72:	8082                	ret

0000000080004e74 <sys_unlink>:
{
    80004e74:	7111                	addi	sp,sp,-256
    80004e76:	fd86                	sd	ra,248(sp)
    80004e78:	f9a2                	sd	s0,240(sp)
    80004e7a:	0200                	addi	s0,sp,256
  if(argstr(0, path, MAXPATH) < 0)
    80004e7c:	08000613          	li	a2,128
    80004e80:	f2040593          	addi	a1,s0,-224
    80004e84:	4501                	li	a0,0
    80004e86:	a49fd0ef          	jal	800028ce <argstr>
    80004e8a:	16054663          	bltz	a0,80004ff6 <sys_unlink+0x182>
    80004e8e:	f5a6                	sd	s1,232(sp)
  begin_op();
    80004e90:	e23fe0ef          	jal	80003cb2 <begin_op>
  if((dp = nameiparent(path, name)) == 0){
    80004e94:	fa040593          	addi	a1,s0,-96
    80004e98:	f2040513          	addi	a0,s0,-224
    80004e9c:	c57fe0ef          	jal	80003af2 <nameiparent>
    80004ea0:	84aa                	mv	s1,a0
    80004ea2:	c955                	beqz	a0,80004f56 <sys_unlink+0xe2>
  ilock(dp);
    80004ea4:	c0afe0ef          	jal	800032ae <ilock>
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
    80004ea8:	00002597          	auipc	a1,0x2
    80004eac:	76058593          	addi	a1,a1,1888 # 80007608 <etext+0x608>
    80004eb0:	fa040513          	addi	a0,s0,-96
    80004eb4:	983fe0ef          	jal	80003836 <namecmp>
    80004eb8:	12050463          	beqz	a0,80004fe0 <sys_unlink+0x16c>
    80004ebc:	00002597          	auipc	a1,0x2
    80004ec0:	75458593          	addi	a1,a1,1876 # 80007610 <etext+0x610>
    80004ec4:	fa040513          	addi	a0,s0,-96
    80004ec8:	96ffe0ef          	jal	80003836 <namecmp>
    80004ecc:	10050a63          	beqz	a0,80004fe0 <sys_unlink+0x16c>
    80004ed0:	f1ca                	sd	s2,224(sp)
  if((ip = dirlookup(dp, name, &off)) == 0)
    80004ed2:	f1c40613          	addi	a2,s0,-228
    80004ed6:	fa040593          	addi	a1,s0,-96
    80004eda:	8526                	mv	a0,s1
    80004edc:	971fe0ef          	jal	8000384c <dirlookup>
    80004ee0:	892a                	mv	s2,a0
    80004ee2:	0e050e63          	beqz	a0,80004fde <sys_unlink+0x16a>
    80004ee6:	edce                	sd	s3,216(sp)
  ilock(ip);
    80004ee8:	bc6fe0ef          	jal	800032ae <ilock>
  if(ip->nlink < 1)
    80004eec:	04a91783          	lh	a5,74(s2)
    80004ef0:	06f05863          	blez	a5,80004f60 <sys_unlink+0xec>
  if(ip->type == T_DIR && !isdirempty(ip)){
    80004ef4:	04491703          	lh	a4,68(s2)
    80004ef8:	4785                	li	a5,1
    80004efa:	06f70b63          	beq	a4,a5,80004f70 <sys_unlink+0xfc>
  memset(&de, 0, sizeof(de));
    80004efe:	fb040993          	addi	s3,s0,-80
    80004f02:	4641                	li	a2,16
    80004f04:	4581                	li	a1,0
    80004f06:	854e                	mv	a0,s3
    80004f08:	d95fb0ef          	jal	80000c9c <memset>
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80004f0c:	4741                	li	a4,16
    80004f0e:	f1c42683          	lw	a3,-228(s0)
    80004f12:	864e                	mv	a2,s3
    80004f14:	4581                	li	a1,0
    80004f16:	8526                	mv	a0,s1
    80004f18:	81bfe0ef          	jal	80003732 <writei>
    80004f1c:	47c1                	li	a5,16
    80004f1e:	08f51f63          	bne	a0,a5,80004fbc <sys_unlink+0x148>
  if(ip->type == T_DIR){
    80004f22:	04491703          	lh	a4,68(s2)
    80004f26:	4785                	li	a5,1
    80004f28:	0af70263          	beq	a4,a5,80004fcc <sys_unlink+0x158>
  iunlockput(dp);
    80004f2c:	8526                	mv	a0,s1
    80004f2e:	d8afe0ef          	jal	800034b8 <iunlockput>
  ip->nlink--;
    80004f32:	04a95783          	lhu	a5,74(s2)
    80004f36:	37fd                	addiw	a5,a5,-1
    80004f38:	04f91523          	sh	a5,74(s2)
  iupdate(ip);
    80004f3c:	854a                	mv	a0,s2
    80004f3e:	abcfe0ef          	jal	800031fa <iupdate>
  iunlockput(ip);
    80004f42:	854a                	mv	a0,s2
    80004f44:	d74fe0ef          	jal	800034b8 <iunlockput>
  end_op();
    80004f48:	dd5fe0ef          	jal	80003d1c <end_op>
  return 0;
    80004f4c:	4501                	li	a0,0
    80004f4e:	74ae                	ld	s1,232(sp)
    80004f50:	790e                	ld	s2,224(sp)
    80004f52:	69ee                	ld	s3,216(sp)
    80004f54:	a869                	j	80004fee <sys_unlink+0x17a>
    end_op();
    80004f56:	dc7fe0ef          	jal	80003d1c <end_op>
    return -1;
    80004f5a:	557d                	li	a0,-1
    80004f5c:	74ae                	ld	s1,232(sp)
    80004f5e:	a841                	j	80004fee <sys_unlink+0x17a>
    80004f60:	e9d2                	sd	s4,208(sp)
    80004f62:	e5d6                	sd	s5,200(sp)
    panic("unlink: nlink < 1");
    80004f64:	00002517          	auipc	a0,0x2
    80004f68:	6b450513          	addi	a0,a0,1716 # 80007618 <etext+0x618>
    80004f6c:	873fb0ef          	jal	800007de <panic>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    80004f70:	04c92703          	lw	a4,76(s2)
    80004f74:	02000793          	li	a5,32
    80004f78:	f8e7f3e3          	bgeu	a5,a4,80004efe <sys_unlink+0x8a>
    80004f7c:	e9d2                	sd	s4,208(sp)
    80004f7e:	e5d6                	sd	s5,200(sp)
    80004f80:	89be                	mv	s3,a5
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80004f82:	f0840a93          	addi	s5,s0,-248
    80004f86:	4a41                	li	s4,16
    80004f88:	8752                	mv	a4,s4
    80004f8a:	86ce                	mv	a3,s3
    80004f8c:	8656                	mv	a2,s5
    80004f8e:	4581                	li	a1,0
    80004f90:	854a                	mv	a0,s2
    80004f92:	eaefe0ef          	jal	80003640 <readi>
    80004f96:	01451d63          	bne	a0,s4,80004fb0 <sys_unlink+0x13c>
    if(de.inum != 0)
    80004f9a:	f0845783          	lhu	a5,-248(s0)
    80004f9e:	efb1                	bnez	a5,80004ffa <sys_unlink+0x186>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    80004fa0:	29c1                	addiw	s3,s3,16
    80004fa2:	04c92783          	lw	a5,76(s2)
    80004fa6:	fef9e1e3          	bltu	s3,a5,80004f88 <sys_unlink+0x114>
    80004faa:	6a4e                	ld	s4,208(sp)
    80004fac:	6aae                	ld	s5,200(sp)
    80004fae:	bf81                	j	80004efe <sys_unlink+0x8a>
      panic("isdirempty: readi");
    80004fb0:	00002517          	auipc	a0,0x2
    80004fb4:	68050513          	addi	a0,a0,1664 # 80007630 <etext+0x630>
    80004fb8:	827fb0ef          	jal	800007de <panic>
    80004fbc:	e9d2                	sd	s4,208(sp)
    80004fbe:	e5d6                	sd	s5,200(sp)
    panic("unlink: writei");
    80004fc0:	00002517          	auipc	a0,0x2
    80004fc4:	68850513          	addi	a0,a0,1672 # 80007648 <etext+0x648>
    80004fc8:	817fb0ef          	jal	800007de <panic>
    dp->nlink--;
    80004fcc:	04a4d783          	lhu	a5,74(s1)
    80004fd0:	37fd                	addiw	a5,a5,-1
    80004fd2:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    80004fd6:	8526                	mv	a0,s1
    80004fd8:	a22fe0ef          	jal	800031fa <iupdate>
    80004fdc:	bf81                	j	80004f2c <sys_unlink+0xb8>
    80004fde:	790e                	ld	s2,224(sp)
  iunlockput(dp);
    80004fe0:	8526                	mv	a0,s1
    80004fe2:	cd6fe0ef          	jal	800034b8 <iunlockput>
  end_op();
    80004fe6:	d37fe0ef          	jal	80003d1c <end_op>
  return -1;
    80004fea:	557d                	li	a0,-1
    80004fec:	74ae                	ld	s1,232(sp)
}
    80004fee:	70ee                	ld	ra,248(sp)
    80004ff0:	744e                	ld	s0,240(sp)
    80004ff2:	6111                	addi	sp,sp,256
    80004ff4:	8082                	ret
    return -1;
    80004ff6:	557d                	li	a0,-1
    80004ff8:	bfdd                	j	80004fee <sys_unlink+0x17a>
    iunlockput(ip);
    80004ffa:	854a                	mv	a0,s2
    80004ffc:	cbcfe0ef          	jal	800034b8 <iunlockput>
    goto bad;
    80005000:	790e                	ld	s2,224(sp)
    80005002:	69ee                	ld	s3,216(sp)
    80005004:	6a4e                	ld	s4,208(sp)
    80005006:	6aae                	ld	s5,200(sp)
    80005008:	bfe1                	j	80004fe0 <sys_unlink+0x16c>

000000008000500a <sys_open>:

uint64
sys_open(void)
{
    8000500a:	7131                	addi	sp,sp,-192
    8000500c:	fd06                	sd	ra,184(sp)
    8000500e:	f922                	sd	s0,176(sp)
    80005010:	0180                	addi	s0,sp,192
  int fd, omode;
  struct file *f;
  struct inode *ip;
  int n;

  argint(1, &omode);
    80005012:	f4c40593          	addi	a1,s0,-180
    80005016:	4505                	li	a0,1
    80005018:	87ffd0ef          	jal	80002896 <argint>
  if((n = argstr(0, path, MAXPATH)) < 0)
    8000501c:	08000613          	li	a2,128
    80005020:	f5040593          	addi	a1,s0,-176
    80005024:	4501                	li	a0,0
    80005026:	8a9fd0ef          	jal	800028ce <argstr>
    8000502a:	87aa                	mv	a5,a0
    return -1;
    8000502c:	557d                	li	a0,-1
  if((n = argstr(0, path, MAXPATH)) < 0)
    8000502e:	0a07c363          	bltz	a5,800050d4 <sys_open+0xca>
    80005032:	f526                	sd	s1,168(sp)

  begin_op();
    80005034:	c7ffe0ef          	jal	80003cb2 <begin_op>

  if(omode & O_CREATE){
    80005038:	f4c42783          	lw	a5,-180(s0)
    8000503c:	2007f793          	andi	a5,a5,512
    80005040:	c3dd                	beqz	a5,800050e6 <sys_open+0xdc>
    ip = create(path, T_FILE, 0, 0);
    80005042:	4681                	li	a3,0
    80005044:	4601                	li	a2,0
    80005046:	4589                	li	a1,2
    80005048:	f5040513          	addi	a0,s0,-176
    8000504c:	a99ff0ef          	jal	80004ae4 <create>
    80005050:	84aa                	mv	s1,a0
    if(ip == 0){
    80005052:	c549                	beqz	a0,800050dc <sys_open+0xd2>
      end_op();
      return -1;
    }
  }

  if(ip->type == T_DEVICE && (ip->major < 0 || ip->major >= NDEV)){
    80005054:	04449703          	lh	a4,68(s1)
    80005058:	478d                	li	a5,3
    8000505a:	00f71763          	bne	a4,a5,80005068 <sys_open+0x5e>
    8000505e:	0464d703          	lhu	a4,70(s1)
    80005062:	47a5                	li	a5,9
    80005064:	0ae7ee63          	bltu	a5,a4,80005120 <sys_open+0x116>
    80005068:	f14a                	sd	s2,160(sp)
    iunlockput(ip);
    end_op();
    return -1;
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
    8000506a:	fb7fe0ef          	jal	80004020 <filealloc>
    8000506e:	892a                	mv	s2,a0
    80005070:	c561                	beqz	a0,80005138 <sys_open+0x12e>
    80005072:	ed4e                	sd	s3,152(sp)
    80005074:	a33ff0ef          	jal	80004aa6 <fdalloc>
    80005078:	89aa                	mv	s3,a0
    8000507a:	0a054b63          	bltz	a0,80005130 <sys_open+0x126>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if(ip->type == T_DEVICE){
    8000507e:	04449703          	lh	a4,68(s1)
    80005082:	478d                	li	a5,3
    80005084:	0cf70363          	beq	a4,a5,8000514a <sys_open+0x140>
    f->type = FD_DEVICE;
    f->major = ip->major;
  } else {
    f->type = FD_INODE;
    80005088:	4789                	li	a5,2
    8000508a:	00f92023          	sw	a5,0(s2)
    f->off = 0;
    8000508e:	02092023          	sw	zero,32(s2)
  }
  f->ip = ip;
    80005092:	00993c23          	sd	s1,24(s2)
  f->readable = !(omode & O_WRONLY);
    80005096:	f4c42783          	lw	a5,-180(s0)
    8000509a:	0017f713          	andi	a4,a5,1
    8000509e:	00174713          	xori	a4,a4,1
    800050a2:	00e90423          	sb	a4,8(s2)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
    800050a6:	0037f713          	andi	a4,a5,3
    800050aa:	00e03733          	snez	a4,a4
    800050ae:	00e904a3          	sb	a4,9(s2)

  if((omode & O_TRUNC) && ip->type == T_FILE){
    800050b2:	4007f793          	andi	a5,a5,1024
    800050b6:	c791                	beqz	a5,800050c2 <sys_open+0xb8>
    800050b8:	04449703          	lh	a4,68(s1)
    800050bc:	4789                	li	a5,2
    800050be:	08f70d63          	beq	a4,a5,80005158 <sys_open+0x14e>
    itrunc(ip);
  }

  iunlock(ip);
    800050c2:	8526                	mv	a0,s1
    800050c4:	a98fe0ef          	jal	8000335c <iunlock>
  end_op();
    800050c8:	c55fe0ef          	jal	80003d1c <end_op>

  return fd;
    800050cc:	854e                	mv	a0,s3
    800050ce:	74aa                	ld	s1,168(sp)
    800050d0:	790a                	ld	s2,160(sp)
    800050d2:	69ea                	ld	s3,152(sp)
}
    800050d4:	70ea                	ld	ra,184(sp)
    800050d6:	744a                	ld	s0,176(sp)
    800050d8:	6129                	addi	sp,sp,192
    800050da:	8082                	ret
      end_op();
    800050dc:	c41fe0ef          	jal	80003d1c <end_op>
      return -1;
    800050e0:	557d                	li	a0,-1
    800050e2:	74aa                	ld	s1,168(sp)
    800050e4:	bfc5                	j	800050d4 <sys_open+0xca>
    if((ip = namei(path)) == 0){
    800050e6:	f5040513          	addi	a0,s0,-176
    800050ea:	9effe0ef          	jal	80003ad8 <namei>
    800050ee:	84aa                	mv	s1,a0
    800050f0:	c11d                	beqz	a0,80005116 <sys_open+0x10c>
    ilock(ip);
    800050f2:	9bcfe0ef          	jal	800032ae <ilock>
    if(ip->type == T_DIR && omode != O_RDONLY){
    800050f6:	04449703          	lh	a4,68(s1)
    800050fa:	4785                	li	a5,1
    800050fc:	f4f71ce3          	bne	a4,a5,80005054 <sys_open+0x4a>
    80005100:	f4c42783          	lw	a5,-180(s0)
    80005104:	d3b5                	beqz	a5,80005068 <sys_open+0x5e>
      iunlockput(ip);
    80005106:	8526                	mv	a0,s1
    80005108:	bb0fe0ef          	jal	800034b8 <iunlockput>
      end_op();
    8000510c:	c11fe0ef          	jal	80003d1c <end_op>
      return -1;
    80005110:	557d                	li	a0,-1
    80005112:	74aa                	ld	s1,168(sp)
    80005114:	b7c1                	j	800050d4 <sys_open+0xca>
      end_op();
    80005116:	c07fe0ef          	jal	80003d1c <end_op>
      return -1;
    8000511a:	557d                	li	a0,-1
    8000511c:	74aa                	ld	s1,168(sp)
    8000511e:	bf5d                	j	800050d4 <sys_open+0xca>
    iunlockput(ip);
    80005120:	8526                	mv	a0,s1
    80005122:	b96fe0ef          	jal	800034b8 <iunlockput>
    end_op();
    80005126:	bf7fe0ef          	jal	80003d1c <end_op>
    return -1;
    8000512a:	557d                	li	a0,-1
    8000512c:	74aa                	ld	s1,168(sp)
    8000512e:	b75d                	j	800050d4 <sys_open+0xca>
      fileclose(f);
    80005130:	854a                	mv	a0,s2
    80005132:	f93fe0ef          	jal	800040c4 <fileclose>
    80005136:	69ea                	ld	s3,152(sp)
    iunlockput(ip);
    80005138:	8526                	mv	a0,s1
    8000513a:	b7efe0ef          	jal	800034b8 <iunlockput>
    end_op();
    8000513e:	bdffe0ef          	jal	80003d1c <end_op>
    return -1;
    80005142:	557d                	li	a0,-1
    80005144:	74aa                	ld	s1,168(sp)
    80005146:	790a                	ld	s2,160(sp)
    80005148:	b771                	j	800050d4 <sys_open+0xca>
    f->type = FD_DEVICE;
    8000514a:	00f92023          	sw	a5,0(s2)
    f->major = ip->major;
    8000514e:	04649783          	lh	a5,70(s1)
    80005152:	02f91223          	sh	a5,36(s2)
    80005156:	bf35                	j	80005092 <sys_open+0x88>
    itrunc(ip);
    80005158:	8526                	mv	a0,s1
    8000515a:	a42fe0ef          	jal	8000339c <itrunc>
    8000515e:	b795                	j	800050c2 <sys_open+0xb8>

0000000080005160 <sys_mkdir>:

uint64
sys_mkdir(void)
{
    80005160:	7175                	addi	sp,sp,-144
    80005162:	e506                	sd	ra,136(sp)
    80005164:	e122                	sd	s0,128(sp)
    80005166:	0900                	addi	s0,sp,144
  char path[MAXPATH];
  struct inode *ip;

  begin_op();
    80005168:	b4bfe0ef          	jal	80003cb2 <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
    8000516c:	08000613          	li	a2,128
    80005170:	f7040593          	addi	a1,s0,-144
    80005174:	4501                	li	a0,0
    80005176:	f58fd0ef          	jal	800028ce <argstr>
    8000517a:	02054363          	bltz	a0,800051a0 <sys_mkdir+0x40>
    8000517e:	4681                	li	a3,0
    80005180:	4601                	li	a2,0
    80005182:	4585                	li	a1,1
    80005184:	f7040513          	addi	a0,s0,-144
    80005188:	95dff0ef          	jal	80004ae4 <create>
    8000518c:	c911                	beqz	a0,800051a0 <sys_mkdir+0x40>
    end_op();
    return -1;
  }
  iunlockput(ip);
    8000518e:	b2afe0ef          	jal	800034b8 <iunlockput>
  end_op();
    80005192:	b8bfe0ef          	jal	80003d1c <end_op>
  return 0;
    80005196:	4501                	li	a0,0
}
    80005198:	60aa                	ld	ra,136(sp)
    8000519a:	640a                	ld	s0,128(sp)
    8000519c:	6149                	addi	sp,sp,144
    8000519e:	8082                	ret
    end_op();
    800051a0:	b7dfe0ef          	jal	80003d1c <end_op>
    return -1;
    800051a4:	557d                	li	a0,-1
    800051a6:	bfcd                	j	80005198 <sys_mkdir+0x38>

00000000800051a8 <sys_mknod>:

uint64
sys_mknod(void)
{
    800051a8:	7135                	addi	sp,sp,-160
    800051aa:	ed06                	sd	ra,152(sp)
    800051ac:	e922                	sd	s0,144(sp)
    800051ae:	1100                	addi	s0,sp,160
  struct inode *ip;
  char path[MAXPATH];
  int major, minor;

  begin_op();
    800051b0:	b03fe0ef          	jal	80003cb2 <begin_op>
  argint(1, &major);
    800051b4:	f6c40593          	addi	a1,s0,-148
    800051b8:	4505                	li	a0,1
    800051ba:	edcfd0ef          	jal	80002896 <argint>
  argint(2, &minor);
    800051be:	f6840593          	addi	a1,s0,-152
    800051c2:	4509                	li	a0,2
    800051c4:	ed2fd0ef          	jal	80002896 <argint>
  if((argstr(0, path, MAXPATH)) < 0 ||
    800051c8:	08000613          	li	a2,128
    800051cc:	f7040593          	addi	a1,s0,-144
    800051d0:	4501                	li	a0,0
    800051d2:	efcfd0ef          	jal	800028ce <argstr>
    800051d6:	02054563          	bltz	a0,80005200 <sys_mknod+0x58>
     (ip = create(path, T_DEVICE, major, minor)) == 0){
    800051da:	f6841683          	lh	a3,-152(s0)
    800051de:	f6c41603          	lh	a2,-148(s0)
    800051e2:	458d                	li	a1,3
    800051e4:	f7040513          	addi	a0,s0,-144
    800051e8:	8fdff0ef          	jal	80004ae4 <create>
  if((argstr(0, path, MAXPATH)) < 0 ||
    800051ec:	c911                	beqz	a0,80005200 <sys_mknod+0x58>
    end_op();
    return -1;
  }
  iunlockput(ip);
    800051ee:	acafe0ef          	jal	800034b8 <iunlockput>
  end_op();
    800051f2:	b2bfe0ef          	jal	80003d1c <end_op>
  return 0;
    800051f6:	4501                	li	a0,0
}
    800051f8:	60ea                	ld	ra,152(sp)
    800051fa:	644a                	ld	s0,144(sp)
    800051fc:	610d                	addi	sp,sp,160
    800051fe:	8082                	ret
    end_op();
    80005200:	b1dfe0ef          	jal	80003d1c <end_op>
    return -1;
    80005204:	557d                	li	a0,-1
    80005206:	bfcd                	j	800051f8 <sys_mknod+0x50>

0000000080005208 <sys_chdir>:

uint64
sys_chdir(void)
{
    80005208:	7135                	addi	sp,sp,-160
    8000520a:	ed06                	sd	ra,152(sp)
    8000520c:	e922                	sd	s0,144(sp)
    8000520e:	e14a                	sd	s2,128(sp)
    80005210:	1100                	addi	s0,sp,160
  char path[MAXPATH];
  struct inode *ip;
  struct proc *p = myproc();
    80005212:	eacfc0ef          	jal	800018be <myproc>
    80005216:	892a                	mv	s2,a0
  
  begin_op();
    80005218:	a9bfe0ef          	jal	80003cb2 <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = namei(path)) == 0){
    8000521c:	08000613          	li	a2,128
    80005220:	f6040593          	addi	a1,s0,-160
    80005224:	4501                	li	a0,0
    80005226:	ea8fd0ef          	jal	800028ce <argstr>
    8000522a:	04054363          	bltz	a0,80005270 <sys_chdir+0x68>
    8000522e:	e526                	sd	s1,136(sp)
    80005230:	f6040513          	addi	a0,s0,-160
    80005234:	8a5fe0ef          	jal	80003ad8 <namei>
    80005238:	84aa                	mv	s1,a0
    8000523a:	c915                	beqz	a0,8000526e <sys_chdir+0x66>
    end_op();
    return -1;
  }
  ilock(ip);
    8000523c:	872fe0ef          	jal	800032ae <ilock>
  if(ip->type != T_DIR){
    80005240:	04449703          	lh	a4,68(s1)
    80005244:	4785                	li	a5,1
    80005246:	02f71963          	bne	a4,a5,80005278 <sys_chdir+0x70>
    iunlockput(ip);
    end_op();
    return -1;
  }
  iunlock(ip);
    8000524a:	8526                	mv	a0,s1
    8000524c:	910fe0ef          	jal	8000335c <iunlock>
  iput(p->cwd);
    80005250:	15093503          	ld	a0,336(s2)
    80005254:	9dcfe0ef          	jal	80003430 <iput>
  end_op();
    80005258:	ac5fe0ef          	jal	80003d1c <end_op>
  p->cwd = ip;
    8000525c:	14993823          	sd	s1,336(s2)
  return 0;
    80005260:	4501                	li	a0,0
    80005262:	64aa                	ld	s1,136(sp)
}
    80005264:	60ea                	ld	ra,152(sp)
    80005266:	644a                	ld	s0,144(sp)
    80005268:	690a                	ld	s2,128(sp)
    8000526a:	610d                	addi	sp,sp,160
    8000526c:	8082                	ret
    8000526e:	64aa                	ld	s1,136(sp)
    end_op();
    80005270:	aadfe0ef          	jal	80003d1c <end_op>
    return -1;
    80005274:	557d                	li	a0,-1
    80005276:	b7fd                	j	80005264 <sys_chdir+0x5c>
    iunlockput(ip);
    80005278:	8526                	mv	a0,s1
    8000527a:	a3efe0ef          	jal	800034b8 <iunlockput>
    end_op();
    8000527e:	a9ffe0ef          	jal	80003d1c <end_op>
    return -1;
    80005282:	557d                	li	a0,-1
    80005284:	64aa                	ld	s1,136(sp)
    80005286:	bff9                	j	80005264 <sys_chdir+0x5c>

0000000080005288 <sys_exec>:

uint64
sys_exec(void)
{
    80005288:	7105                	addi	sp,sp,-480
    8000528a:	ef86                	sd	ra,472(sp)
    8000528c:	eba2                	sd	s0,464(sp)
    8000528e:	1380                	addi	s0,sp,480
  char path[MAXPATH], *argv[MAXARG];
  int i;
  uint64 uargv, uarg;

  argaddr(1, &uargv);
    80005290:	e2840593          	addi	a1,s0,-472
    80005294:	4505                	li	a0,1
    80005296:	e1cfd0ef          	jal	800028b2 <argaddr>
  if(argstr(0, path, MAXPATH) < 0) {
    8000529a:	08000613          	li	a2,128
    8000529e:	f3040593          	addi	a1,s0,-208
    800052a2:	4501                	li	a0,0
    800052a4:	e2afd0ef          	jal	800028ce <argstr>
    800052a8:	87aa                	mv	a5,a0
    return -1;
    800052aa:	557d                	li	a0,-1
  if(argstr(0, path, MAXPATH) < 0) {
    800052ac:	0e07c063          	bltz	a5,8000538c <sys_exec+0x104>
    800052b0:	e7a6                	sd	s1,456(sp)
    800052b2:	e3ca                	sd	s2,448(sp)
    800052b4:	ff4e                	sd	s3,440(sp)
    800052b6:	fb52                	sd	s4,432(sp)
    800052b8:	f756                	sd	s5,424(sp)
    800052ba:	f35a                	sd	s6,416(sp)
    800052bc:	ef5e                	sd	s7,408(sp)
  }
  memset(argv, 0, sizeof(argv));
    800052be:	e3040a13          	addi	s4,s0,-464
    800052c2:	10000613          	li	a2,256
    800052c6:	4581                	li	a1,0
    800052c8:	8552                	mv	a0,s4
    800052ca:	9d3fb0ef          	jal	80000c9c <memset>
  for(i=0;; i++){
    if(i >= NELEM(argv)){
    800052ce:	84d2                	mv	s1,s4
  memset(argv, 0, sizeof(argv));
    800052d0:	89d2                	mv	s3,s4
    800052d2:	4901                	li	s2,0
      goto bad;
    }
    if(fetchaddr(uargv+sizeof(uint64)*i, (uint64*)&uarg) < 0){
    800052d4:	e2040a93          	addi	s5,s0,-480
      break;
    }
    argv[i] = kalloc();
    if(argv[i] == 0)
      goto bad;
    if(fetchstr(uarg, argv[i], PGSIZE) < 0)
    800052d8:	6b05                	lui	s6,0x1
    if(i >= NELEM(argv)){
    800052da:	02000b93          	li	s7,32
    if(fetchaddr(uargv+sizeof(uint64)*i, (uint64*)&uarg) < 0){
    800052de:	00391513          	slli	a0,s2,0x3
    800052e2:	85d6                	mv	a1,s5
    800052e4:	e2843783          	ld	a5,-472(s0)
    800052e8:	953e                	add	a0,a0,a5
    800052ea:	d22fd0ef          	jal	8000280c <fetchaddr>
    800052ee:	02054663          	bltz	a0,8000531a <sys_exec+0x92>
    if(uarg == 0){
    800052f2:	e2043783          	ld	a5,-480(s0)
    800052f6:	c7a1                	beqz	a5,8000533e <sys_exec+0xb6>
    argv[i] = kalloc();
    800052f8:	801fb0ef          	jal	80000af8 <kalloc>
    800052fc:	85aa                	mv	a1,a0
    800052fe:	00a9b023          	sd	a0,0(s3)
    if(argv[i] == 0)
    80005302:	cd01                	beqz	a0,8000531a <sys_exec+0x92>
    if(fetchstr(uarg, argv[i], PGSIZE) < 0)
    80005304:	865a                	mv	a2,s6
    80005306:	e2043503          	ld	a0,-480(s0)
    8000530a:	d4cfd0ef          	jal	80002856 <fetchstr>
    8000530e:	00054663          	bltz	a0,8000531a <sys_exec+0x92>
    if(i >= NELEM(argv)){
    80005312:	0905                	addi	s2,s2,1
    80005314:	09a1                	addi	s3,s3,8
    80005316:	fd7914e3          	bne	s2,s7,800052de <sys_exec+0x56>
    kfree(argv[i]);

  return ret;

 bad:
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    8000531a:	100a0a13          	addi	s4,s4,256
    8000531e:	6088                	ld	a0,0(s1)
    80005320:	cd31                	beqz	a0,8000537c <sys_exec+0xf4>
    kfree(argv[i]);
    80005322:	ef4fb0ef          	jal	80000a16 <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005326:	04a1                	addi	s1,s1,8
    80005328:	ff449be3          	bne	s1,s4,8000531e <sys_exec+0x96>
  return -1;
    8000532c:	557d                	li	a0,-1
    8000532e:	64be                	ld	s1,456(sp)
    80005330:	691e                	ld	s2,448(sp)
    80005332:	79fa                	ld	s3,440(sp)
    80005334:	7a5a                	ld	s4,432(sp)
    80005336:	7aba                	ld	s5,424(sp)
    80005338:	7b1a                	ld	s6,416(sp)
    8000533a:	6bfa                	ld	s7,408(sp)
    8000533c:	a881                	j	8000538c <sys_exec+0x104>
      argv[i] = 0;
    8000533e:	0009079b          	sext.w	a5,s2
    80005342:	e3040593          	addi	a1,s0,-464
    80005346:	078e                	slli	a5,a5,0x3
    80005348:	97ae                	add	a5,a5,a1
    8000534a:	0007b023          	sd	zero,0(a5)
  int ret = kexec(path, argv);
    8000534e:	f3040513          	addi	a0,s0,-208
    80005352:	ba4ff0ef          	jal	800046f6 <kexec>
    80005356:	892a                	mv	s2,a0
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005358:	100a0a13          	addi	s4,s4,256
    8000535c:	6088                	ld	a0,0(s1)
    8000535e:	c511                	beqz	a0,8000536a <sys_exec+0xe2>
    kfree(argv[i]);
    80005360:	eb6fb0ef          	jal	80000a16 <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005364:	04a1                	addi	s1,s1,8
    80005366:	ff449be3          	bne	s1,s4,8000535c <sys_exec+0xd4>
  return ret;
    8000536a:	854a                	mv	a0,s2
    8000536c:	64be                	ld	s1,456(sp)
    8000536e:	691e                	ld	s2,448(sp)
    80005370:	79fa                	ld	s3,440(sp)
    80005372:	7a5a                	ld	s4,432(sp)
    80005374:	7aba                	ld	s5,424(sp)
    80005376:	7b1a                	ld	s6,416(sp)
    80005378:	6bfa                	ld	s7,408(sp)
    8000537a:	a809                	j	8000538c <sys_exec+0x104>
  return -1;
    8000537c:	557d                	li	a0,-1
    8000537e:	64be                	ld	s1,456(sp)
    80005380:	691e                	ld	s2,448(sp)
    80005382:	79fa                	ld	s3,440(sp)
    80005384:	7a5a                	ld	s4,432(sp)
    80005386:	7aba                	ld	s5,424(sp)
    80005388:	7b1a                	ld	s6,416(sp)
    8000538a:	6bfa                	ld	s7,408(sp)
}
    8000538c:	60fe                	ld	ra,472(sp)
    8000538e:	645e                	ld	s0,464(sp)
    80005390:	613d                	addi	sp,sp,480
    80005392:	8082                	ret

0000000080005394 <sys_pipe>:

uint64
sys_pipe(void)
{
    80005394:	7139                	addi	sp,sp,-64
    80005396:	fc06                	sd	ra,56(sp)
    80005398:	f822                	sd	s0,48(sp)
    8000539a:	f426                	sd	s1,40(sp)
    8000539c:	0080                	addi	s0,sp,64
  uint64 fdarray; // user pointer to array of two integers
  struct file *rf, *wf;
  int fd0, fd1;
  struct proc *p = myproc();
    8000539e:	d20fc0ef          	jal	800018be <myproc>
    800053a2:	84aa                	mv	s1,a0

  argaddr(0, &fdarray);
    800053a4:	fd840593          	addi	a1,s0,-40
    800053a8:	4501                	li	a0,0
    800053aa:	d08fd0ef          	jal	800028b2 <argaddr>
  if(pipealloc(&rf, &wf) < 0)
    800053ae:	fc840593          	addi	a1,s0,-56
    800053b2:	fd040513          	addi	a0,s0,-48
    800053b6:	81eff0ef          	jal	800043d4 <pipealloc>
    return -1;
    800053ba:	57fd                	li	a5,-1
  if(pipealloc(&rf, &wf) < 0)
    800053bc:	0a054463          	bltz	a0,80005464 <sys_pipe+0xd0>
  fd0 = -1;
    800053c0:	fcf42223          	sw	a5,-60(s0)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
    800053c4:	fd043503          	ld	a0,-48(s0)
    800053c8:	edeff0ef          	jal	80004aa6 <fdalloc>
    800053cc:	fca42223          	sw	a0,-60(s0)
    800053d0:	08054163          	bltz	a0,80005452 <sys_pipe+0xbe>
    800053d4:	fc843503          	ld	a0,-56(s0)
    800053d8:	eceff0ef          	jal	80004aa6 <fdalloc>
    800053dc:	fca42023          	sw	a0,-64(s0)
    800053e0:	06054063          	bltz	a0,80005440 <sys_pipe+0xac>
      p->ofile[fd0] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    800053e4:	4691                	li	a3,4
    800053e6:	fc440613          	addi	a2,s0,-60
    800053ea:	fd843583          	ld	a1,-40(s0)
    800053ee:	68a8                	ld	a0,80(s1)
    800053f0:	a00fc0ef          	jal	800015f0 <copyout>
    800053f4:	00054e63          	bltz	a0,80005410 <sys_pipe+0x7c>
     copyout(p->pagetable, fdarray+sizeof(fd0), (char *)&fd1, sizeof(fd1)) < 0){
    800053f8:	4691                	li	a3,4
    800053fa:	fc040613          	addi	a2,s0,-64
    800053fe:	fd843583          	ld	a1,-40(s0)
    80005402:	95b6                	add	a1,a1,a3
    80005404:	68a8                	ld	a0,80(s1)
    80005406:	9eafc0ef          	jal	800015f0 <copyout>
    p->ofile[fd1] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  return 0;
    8000540a:	4781                	li	a5,0
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    8000540c:	04055c63          	bgez	a0,80005464 <sys_pipe+0xd0>
    p->ofile[fd0] = 0;
    80005410:	fc442783          	lw	a5,-60(s0)
    80005414:	07e9                	addi	a5,a5,26
    80005416:	078e                	slli	a5,a5,0x3
    80005418:	97a6                	add	a5,a5,s1
    8000541a:	0007b023          	sd	zero,0(a5)
    p->ofile[fd1] = 0;
    8000541e:	fc042783          	lw	a5,-64(s0)
    80005422:	07e9                	addi	a5,a5,26
    80005424:	078e                	slli	a5,a5,0x3
    80005426:	94be                	add	s1,s1,a5
    80005428:	0004b023          	sd	zero,0(s1)
    fileclose(rf);
    8000542c:	fd043503          	ld	a0,-48(s0)
    80005430:	c95fe0ef          	jal	800040c4 <fileclose>
    fileclose(wf);
    80005434:	fc843503          	ld	a0,-56(s0)
    80005438:	c8dfe0ef          	jal	800040c4 <fileclose>
    return -1;
    8000543c:	57fd                	li	a5,-1
    8000543e:	a01d                	j	80005464 <sys_pipe+0xd0>
    if(fd0 >= 0)
    80005440:	fc442783          	lw	a5,-60(s0)
    80005444:	0007c763          	bltz	a5,80005452 <sys_pipe+0xbe>
      p->ofile[fd0] = 0;
    80005448:	07e9                	addi	a5,a5,26
    8000544a:	078e                	slli	a5,a5,0x3
    8000544c:	97a6                	add	a5,a5,s1
    8000544e:	0007b023          	sd	zero,0(a5)
    fileclose(rf);
    80005452:	fd043503          	ld	a0,-48(s0)
    80005456:	c6ffe0ef          	jal	800040c4 <fileclose>
    fileclose(wf);
    8000545a:	fc843503          	ld	a0,-56(s0)
    8000545e:	c67fe0ef          	jal	800040c4 <fileclose>
    return -1;
    80005462:	57fd                	li	a5,-1
}
    80005464:	853e                	mv	a0,a5
    80005466:	70e2                	ld	ra,56(sp)
    80005468:	7442                	ld	s0,48(sp)
    8000546a:	74a2                	ld	s1,40(sp)
    8000546c:	6121                	addi	sp,sp,64
    8000546e:	8082                	ret

0000000080005470 <kernelvec>:
.globl kerneltrap
.globl kernelvec
.align 4
kernelvec:
        # make room to save registers.
        addi sp, sp, -256
    80005470:	7111                	addi	sp,sp,-256

        # save caller-saved registers.
        sd ra, 0(sp)
    80005472:	e006                	sd	ra,0(sp)
        # sd sp, 8(sp)
        sd gp, 16(sp)
    80005474:	e80e                	sd	gp,16(sp)
        sd tp, 24(sp)
    80005476:	ec12                	sd	tp,24(sp)
        sd t0, 32(sp)
    80005478:	f016                	sd	t0,32(sp)
        sd t1, 40(sp)
    8000547a:	f41a                	sd	t1,40(sp)
        sd t2, 48(sp)
    8000547c:	f81e                	sd	t2,48(sp)
        sd a0, 72(sp)
    8000547e:	e4aa                	sd	a0,72(sp)
        sd a1, 80(sp)
    80005480:	e8ae                	sd	a1,80(sp)
        sd a2, 88(sp)
    80005482:	ecb2                	sd	a2,88(sp)
        sd a3, 96(sp)
    80005484:	f0b6                	sd	a3,96(sp)
        sd a4, 104(sp)
    80005486:	f4ba                	sd	a4,104(sp)
        sd a5, 112(sp)
    80005488:	f8be                	sd	a5,112(sp)
        sd a6, 120(sp)
    8000548a:	fcc2                	sd	a6,120(sp)
        sd a7, 128(sp)
    8000548c:	e146                	sd	a7,128(sp)
        sd t3, 216(sp)
    8000548e:	edf2                	sd	t3,216(sp)
        sd t4, 224(sp)
    80005490:	f1f6                	sd	t4,224(sp)
        sd t5, 232(sp)
    80005492:	f5fa                	sd	t5,232(sp)
        sd t6, 240(sp)
    80005494:	f9fe                	sd	t6,240(sp)

        # call the C trap handler in trap.c
        call kerneltrap
    80005496:	a86fd0ef          	jal	8000271c <kerneltrap>

        # restore registers.
        ld ra, 0(sp)
    8000549a:	6082                	ld	ra,0(sp)
        # ld sp, 8(sp)
        ld gp, 16(sp)
    8000549c:	61c2                	ld	gp,16(sp)
        # not tp (contains hartid), in case we moved CPUs
        ld t0, 32(sp)
    8000549e:	7282                	ld	t0,32(sp)
        ld t1, 40(sp)
    800054a0:	7322                	ld	t1,40(sp)
        ld t2, 48(sp)
    800054a2:	73c2                	ld	t2,48(sp)
        ld a0, 72(sp)
    800054a4:	6526                	ld	a0,72(sp)
        ld a1, 80(sp)
    800054a6:	65c6                	ld	a1,80(sp)
        ld a2, 88(sp)
    800054a8:	6666                	ld	a2,88(sp)
        ld a3, 96(sp)
    800054aa:	7686                	ld	a3,96(sp)
        ld a4, 104(sp)
    800054ac:	7726                	ld	a4,104(sp)
        ld a5, 112(sp)
    800054ae:	77c6                	ld	a5,112(sp)
        ld a6, 120(sp)
    800054b0:	7866                	ld	a6,120(sp)
        ld a7, 128(sp)
    800054b2:	688a                	ld	a7,128(sp)
        ld t3, 216(sp)
    800054b4:	6e6e                	ld	t3,216(sp)
        ld t4, 224(sp)
    800054b6:	7e8e                	ld	t4,224(sp)
        ld t5, 232(sp)
    800054b8:	7f2e                	ld	t5,232(sp)
        ld t6, 240(sp)
    800054ba:	7fce                	ld	t6,240(sp)

        addi sp, sp, 256
    800054bc:	6111                	addi	sp,sp,256

        # return to whatever we were doing in the kernel.
        sret
    800054be:	10200073          	sret
	...

00000000800054ce <plicinit>:
// the riscv Platform Level Interrupt Controller (PLIC).
//

void
plicinit(void)
{
    800054ce:	1141                	addi	sp,sp,-16
    800054d0:	e406                	sd	ra,8(sp)
    800054d2:	e022                	sd	s0,0(sp)
    800054d4:	0800                	addi	s0,sp,16
  // set desired IRQ priorities non-zero (otherwise disabled).
  *(uint32*)(PLIC + UART0_IRQ*4) = 1;
    800054d6:	0c000737          	lui	a4,0xc000
    800054da:	4785                	li	a5,1
    800054dc:	d71c                	sw	a5,40(a4)
  *(uint32*)(PLIC + VIRTIO0_IRQ*4) = 1;
    800054de:	c35c                	sw	a5,4(a4)
}
    800054e0:	60a2                	ld	ra,8(sp)
    800054e2:	6402                	ld	s0,0(sp)
    800054e4:	0141                	addi	sp,sp,16
    800054e6:	8082                	ret

00000000800054e8 <plicinithart>:

void
plicinithart(void)
{
    800054e8:	1141                	addi	sp,sp,-16
    800054ea:	e406                	sd	ra,8(sp)
    800054ec:	e022                	sd	s0,0(sp)
    800054ee:	0800                	addi	s0,sp,16
  int hart = cpuid();
    800054f0:	b9afc0ef          	jal	8000188a <cpuid>
  
  // set enable bits for this hart's S-mode
  // for the uart and virtio disk.
  *(uint32*)PLIC_SENABLE(hart) = (1 << UART0_IRQ) | (1 << VIRTIO0_IRQ);
    800054f4:	0085171b          	slliw	a4,a0,0x8
    800054f8:	0c0027b7          	lui	a5,0xc002
    800054fc:	97ba                	add	a5,a5,a4
    800054fe:	40200713          	li	a4,1026
    80005502:	08e7a023          	sw	a4,128(a5) # c002080 <_entry-0x73ffdf80>

  // set this hart's S-mode priority threshold to 0.
  *(uint32*)PLIC_SPRIORITY(hart) = 0;
    80005506:	00d5151b          	slliw	a0,a0,0xd
    8000550a:	0c2017b7          	lui	a5,0xc201
    8000550e:	97aa                	add	a5,a5,a0
    80005510:	0007a023          	sw	zero,0(a5) # c201000 <_entry-0x73dff000>
}
    80005514:	60a2                	ld	ra,8(sp)
    80005516:	6402                	ld	s0,0(sp)
    80005518:	0141                	addi	sp,sp,16
    8000551a:	8082                	ret

000000008000551c <plic_claim>:

// ask the PLIC what interrupt we should serve.
int
plic_claim(void)
{
    8000551c:	1141                	addi	sp,sp,-16
    8000551e:	e406                	sd	ra,8(sp)
    80005520:	e022                	sd	s0,0(sp)
    80005522:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80005524:	b66fc0ef          	jal	8000188a <cpuid>
  int irq = *(uint32*)PLIC_SCLAIM(hart);
    80005528:	00d5151b          	slliw	a0,a0,0xd
    8000552c:	0c2017b7          	lui	a5,0xc201
    80005530:	97aa                	add	a5,a5,a0
  return irq;
}
    80005532:	43c8                	lw	a0,4(a5)
    80005534:	60a2                	ld	ra,8(sp)
    80005536:	6402                	ld	s0,0(sp)
    80005538:	0141                	addi	sp,sp,16
    8000553a:	8082                	ret

000000008000553c <plic_complete>:

// tell the PLIC we've served this IRQ.
void
plic_complete(int irq)
{
    8000553c:	1101                	addi	sp,sp,-32
    8000553e:	ec06                	sd	ra,24(sp)
    80005540:	e822                	sd	s0,16(sp)
    80005542:	e426                	sd	s1,8(sp)
    80005544:	1000                	addi	s0,sp,32
    80005546:	84aa                	mv	s1,a0
  int hart = cpuid();
    80005548:	b42fc0ef          	jal	8000188a <cpuid>
  *(uint32*)PLIC_SCLAIM(hart) = irq;
    8000554c:	00d5179b          	slliw	a5,a0,0xd
    80005550:	0c201737          	lui	a4,0xc201
    80005554:	97ba                	add	a5,a5,a4
    80005556:	c3c4                	sw	s1,4(a5)
}
    80005558:	60e2                	ld	ra,24(sp)
    8000555a:	6442                	ld	s0,16(sp)
    8000555c:	64a2                	ld	s1,8(sp)
    8000555e:	6105                	addi	sp,sp,32
    80005560:	8082                	ret

0000000080005562 <free_desc>:
}

// mark a descriptor as free.
static void
free_desc(int i)
{
    80005562:	1141                	addi	sp,sp,-16
    80005564:	e406                	sd	ra,8(sp)
    80005566:	e022                	sd	s0,0(sp)
    80005568:	0800                	addi	s0,sp,16
  if(i >= NUM)
    8000556a:	479d                	li	a5,7
    8000556c:	04a7ca63          	blt	a5,a0,800055c0 <free_desc+0x5e>
    panic("free_desc 1");
  if(disk.free[i])
    80005570:	0001b797          	auipc	a5,0x1b
    80005574:	52878793          	addi	a5,a5,1320 # 80020a98 <disk>
    80005578:	97aa                	add	a5,a5,a0
    8000557a:	0187c783          	lbu	a5,24(a5)
    8000557e:	e7b9                	bnez	a5,800055cc <free_desc+0x6a>
    panic("free_desc 2");
  disk.desc[i].addr = 0;
    80005580:	00451693          	slli	a3,a0,0x4
    80005584:	0001b797          	auipc	a5,0x1b
    80005588:	51478793          	addi	a5,a5,1300 # 80020a98 <disk>
    8000558c:	6398                	ld	a4,0(a5)
    8000558e:	9736                	add	a4,a4,a3
    80005590:	00073023          	sd	zero,0(a4) # c201000 <_entry-0x73dff000>
  disk.desc[i].len = 0;
    80005594:	6398                	ld	a4,0(a5)
    80005596:	9736                	add	a4,a4,a3
    80005598:	00072423          	sw	zero,8(a4)
  disk.desc[i].flags = 0;
    8000559c:	00071623          	sh	zero,12(a4)
  disk.desc[i].next = 0;
    800055a0:	00071723          	sh	zero,14(a4)
  disk.free[i] = 1;
    800055a4:	97aa                	add	a5,a5,a0
    800055a6:	4705                	li	a4,1
    800055a8:	00e78c23          	sb	a4,24(a5)
  wakeup(&disk.free[0]);
    800055ac:	0001b517          	auipc	a0,0x1b
    800055b0:	50450513          	addi	a0,a0,1284 # 80020ab0 <disk+0x18>
    800055b4:	94ffc0ef          	jal	80001f02 <wakeup>
}
    800055b8:	60a2                	ld	ra,8(sp)
    800055ba:	6402                	ld	s0,0(sp)
    800055bc:	0141                	addi	sp,sp,16
    800055be:	8082                	ret
    panic("free_desc 1");
    800055c0:	00002517          	auipc	a0,0x2
    800055c4:	09850513          	addi	a0,a0,152 # 80007658 <etext+0x658>
    800055c8:	a16fb0ef          	jal	800007de <panic>
    panic("free_desc 2");
    800055cc:	00002517          	auipc	a0,0x2
    800055d0:	09c50513          	addi	a0,a0,156 # 80007668 <etext+0x668>
    800055d4:	a0afb0ef          	jal	800007de <panic>

00000000800055d8 <virtio_disk_init>:
{
    800055d8:	1101                	addi	sp,sp,-32
    800055da:	ec06                	sd	ra,24(sp)
    800055dc:	e822                	sd	s0,16(sp)
    800055de:	e426                	sd	s1,8(sp)
    800055e0:	e04a                	sd	s2,0(sp)
    800055e2:	1000                	addi	s0,sp,32
  initlock(&disk.vdisk_lock, "virtio_disk");
    800055e4:	00002597          	auipc	a1,0x2
    800055e8:	09458593          	addi	a1,a1,148 # 80007678 <etext+0x678>
    800055ec:	0001b517          	auipc	a0,0x1b
    800055f0:	5d450513          	addi	a0,a0,1492 # 80020bc0 <disk+0x128>
    800055f4:	d54fb0ef          	jal	80000b48 <initlock>
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    800055f8:	100017b7          	lui	a5,0x10001
    800055fc:	4398                	lw	a4,0(a5)
    800055fe:	2701                	sext.w	a4,a4
    80005600:	747277b7          	lui	a5,0x74727
    80005604:	97678793          	addi	a5,a5,-1674 # 74726976 <_entry-0xb8d968a>
    80005608:	14f71863          	bne	a4,a5,80005758 <virtio_disk_init+0x180>
     *R(VIRTIO_MMIO_VERSION) != 2 ||
    8000560c:	100017b7          	lui	a5,0x10001
    80005610:	43dc                	lw	a5,4(a5)
    80005612:	2781                	sext.w	a5,a5
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    80005614:	4709                	li	a4,2
    80005616:	14e79163          	bne	a5,a4,80005758 <virtio_disk_init+0x180>
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    8000561a:	100017b7          	lui	a5,0x10001
    8000561e:	479c                	lw	a5,8(a5)
    80005620:	2781                	sext.w	a5,a5
     *R(VIRTIO_MMIO_VERSION) != 2 ||
    80005622:	12e79b63          	bne	a5,a4,80005758 <virtio_disk_init+0x180>
     *R(VIRTIO_MMIO_VENDOR_ID) != 0x554d4551){
    80005626:	100017b7          	lui	a5,0x10001
    8000562a:	47d8                	lw	a4,12(a5)
    8000562c:	2701                	sext.w	a4,a4
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    8000562e:	554d47b7          	lui	a5,0x554d4
    80005632:	55178793          	addi	a5,a5,1361 # 554d4551 <_entry-0x2ab2baaf>
    80005636:	12f71163          	bne	a4,a5,80005758 <virtio_disk_init+0x180>
  *R(VIRTIO_MMIO_STATUS) = status;
    8000563a:	100017b7          	lui	a5,0x10001
    8000563e:	0607a823          	sw	zero,112(a5) # 10001070 <_entry-0x6fffef90>
  *R(VIRTIO_MMIO_STATUS) = status;
    80005642:	4705                	li	a4,1
    80005644:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    80005646:	470d                	li	a4,3
    80005648:	dbb8                	sw	a4,112(a5)
  uint64 features = *R(VIRTIO_MMIO_DEVICE_FEATURES);
    8000564a:	10001737          	lui	a4,0x10001
    8000564e:	4b18                	lw	a4,16(a4)
  features &= ~(1 << VIRTIO_RING_F_INDIRECT_DESC);
    80005650:	c7ffe6b7          	lui	a3,0xc7ffe
    80005654:	75f68693          	addi	a3,a3,1887 # ffffffffc7ffe75f <end+0xffffffff47fddb87>
  *R(VIRTIO_MMIO_DRIVER_FEATURES) = features;
    80005658:	8f75                	and	a4,a4,a3
    8000565a:	100016b7          	lui	a3,0x10001
    8000565e:	d298                	sw	a4,32(a3)
  *R(VIRTIO_MMIO_STATUS) = status;
    80005660:	472d                	li	a4,11
    80005662:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    80005664:	07078793          	addi	a5,a5,112
  status = *R(VIRTIO_MMIO_STATUS);
    80005668:	439c                	lw	a5,0(a5)
    8000566a:	0007891b          	sext.w	s2,a5
  if(!(status & VIRTIO_CONFIG_S_FEATURES_OK))
    8000566e:	8ba1                	andi	a5,a5,8
    80005670:	0e078a63          	beqz	a5,80005764 <virtio_disk_init+0x18c>
  *R(VIRTIO_MMIO_QUEUE_SEL) = 0;
    80005674:	100017b7          	lui	a5,0x10001
    80005678:	0207a823          	sw	zero,48(a5) # 10001030 <_entry-0x6fffefd0>
  if(*R(VIRTIO_MMIO_QUEUE_READY))
    8000567c:	43fc                	lw	a5,68(a5)
    8000567e:	2781                	sext.w	a5,a5
    80005680:	0e079863          	bnez	a5,80005770 <virtio_disk_init+0x198>
  uint32 max = *R(VIRTIO_MMIO_QUEUE_NUM_MAX);
    80005684:	100017b7          	lui	a5,0x10001
    80005688:	5bdc                	lw	a5,52(a5)
    8000568a:	2781                	sext.w	a5,a5
  if(max == 0)
    8000568c:	0e078863          	beqz	a5,8000577c <virtio_disk_init+0x1a4>
  if(max < NUM)
    80005690:	471d                	li	a4,7
    80005692:	0ef77b63          	bgeu	a4,a5,80005788 <virtio_disk_init+0x1b0>
  disk.desc = kalloc();
    80005696:	c62fb0ef          	jal	80000af8 <kalloc>
    8000569a:	0001b497          	auipc	s1,0x1b
    8000569e:	3fe48493          	addi	s1,s1,1022 # 80020a98 <disk>
    800056a2:	e088                	sd	a0,0(s1)
  disk.avail = kalloc();
    800056a4:	c54fb0ef          	jal	80000af8 <kalloc>
    800056a8:	e488                	sd	a0,8(s1)
  disk.used = kalloc();
    800056aa:	c4efb0ef          	jal	80000af8 <kalloc>
    800056ae:	87aa                	mv	a5,a0
    800056b0:	e888                	sd	a0,16(s1)
  if(!disk.desc || !disk.avail || !disk.used)
    800056b2:	6088                	ld	a0,0(s1)
    800056b4:	0e050063          	beqz	a0,80005794 <virtio_disk_init+0x1bc>
    800056b8:	0001b717          	auipc	a4,0x1b
    800056bc:	3e873703          	ld	a4,1000(a4) # 80020aa0 <disk+0x8>
    800056c0:	cb71                	beqz	a4,80005794 <virtio_disk_init+0x1bc>
    800056c2:	cbe9                	beqz	a5,80005794 <virtio_disk_init+0x1bc>
  memset(disk.desc, 0, PGSIZE);
    800056c4:	6605                	lui	a2,0x1
    800056c6:	4581                	li	a1,0
    800056c8:	dd4fb0ef          	jal	80000c9c <memset>
  memset(disk.avail, 0, PGSIZE);
    800056cc:	0001b497          	auipc	s1,0x1b
    800056d0:	3cc48493          	addi	s1,s1,972 # 80020a98 <disk>
    800056d4:	6605                	lui	a2,0x1
    800056d6:	4581                	li	a1,0
    800056d8:	6488                	ld	a0,8(s1)
    800056da:	dc2fb0ef          	jal	80000c9c <memset>
  memset(disk.used, 0, PGSIZE);
    800056de:	6605                	lui	a2,0x1
    800056e0:	4581                	li	a1,0
    800056e2:	6888                	ld	a0,16(s1)
    800056e4:	db8fb0ef          	jal	80000c9c <memset>
  *R(VIRTIO_MMIO_QUEUE_NUM) = NUM;
    800056e8:	100017b7          	lui	a5,0x10001
    800056ec:	4721                	li	a4,8
    800056ee:	df98                	sw	a4,56(a5)
  *R(VIRTIO_MMIO_QUEUE_DESC_LOW) = (uint64)disk.desc;
    800056f0:	4098                	lw	a4,0(s1)
    800056f2:	08e7a023          	sw	a4,128(a5) # 10001080 <_entry-0x6fffef80>
  *R(VIRTIO_MMIO_QUEUE_DESC_HIGH) = (uint64)disk.desc >> 32;
    800056f6:	40d8                	lw	a4,4(s1)
    800056f8:	08e7a223          	sw	a4,132(a5)
  *R(VIRTIO_MMIO_DRIVER_DESC_LOW) = (uint64)disk.avail;
    800056fc:	649c                	ld	a5,8(s1)
    800056fe:	0007869b          	sext.w	a3,a5
    80005702:	10001737          	lui	a4,0x10001
    80005706:	08d72823          	sw	a3,144(a4) # 10001090 <_entry-0x6fffef70>
  *R(VIRTIO_MMIO_DRIVER_DESC_HIGH) = (uint64)disk.avail >> 32;
    8000570a:	9781                	srai	a5,a5,0x20
    8000570c:	08f72a23          	sw	a5,148(a4)
  *R(VIRTIO_MMIO_DEVICE_DESC_LOW) = (uint64)disk.used;
    80005710:	689c                	ld	a5,16(s1)
    80005712:	0007869b          	sext.w	a3,a5
    80005716:	0ad72023          	sw	a3,160(a4)
  *R(VIRTIO_MMIO_DEVICE_DESC_HIGH) = (uint64)disk.used >> 32;
    8000571a:	9781                	srai	a5,a5,0x20
    8000571c:	0af72223          	sw	a5,164(a4)
  *R(VIRTIO_MMIO_QUEUE_READY) = 0x1;
    80005720:	4785                	li	a5,1
    80005722:	c37c                	sw	a5,68(a4)
    disk.free[i] = 1;
    80005724:	00f48c23          	sb	a5,24(s1)
    80005728:	00f48ca3          	sb	a5,25(s1)
    8000572c:	00f48d23          	sb	a5,26(s1)
    80005730:	00f48da3          	sb	a5,27(s1)
    80005734:	00f48e23          	sb	a5,28(s1)
    80005738:	00f48ea3          	sb	a5,29(s1)
    8000573c:	00f48f23          	sb	a5,30(s1)
    80005740:	00f48fa3          	sb	a5,31(s1)
  status |= VIRTIO_CONFIG_S_DRIVER_OK;
    80005744:	00496913          	ori	s2,s2,4
  *R(VIRTIO_MMIO_STATUS) = status;
    80005748:	07272823          	sw	s2,112(a4)
}
    8000574c:	60e2                	ld	ra,24(sp)
    8000574e:	6442                	ld	s0,16(sp)
    80005750:	64a2                	ld	s1,8(sp)
    80005752:	6902                	ld	s2,0(sp)
    80005754:	6105                	addi	sp,sp,32
    80005756:	8082                	ret
    panic("could not find virtio disk");
    80005758:	00002517          	auipc	a0,0x2
    8000575c:	f3050513          	addi	a0,a0,-208 # 80007688 <etext+0x688>
    80005760:	87efb0ef          	jal	800007de <panic>
    panic("virtio disk FEATURES_OK unset");
    80005764:	00002517          	auipc	a0,0x2
    80005768:	f4450513          	addi	a0,a0,-188 # 800076a8 <etext+0x6a8>
    8000576c:	872fb0ef          	jal	800007de <panic>
    panic("virtio disk should not be ready");
    80005770:	00002517          	auipc	a0,0x2
    80005774:	f5850513          	addi	a0,a0,-168 # 800076c8 <etext+0x6c8>
    80005778:	866fb0ef          	jal	800007de <panic>
    panic("virtio disk has no queue 0");
    8000577c:	00002517          	auipc	a0,0x2
    80005780:	f6c50513          	addi	a0,a0,-148 # 800076e8 <etext+0x6e8>
    80005784:	85afb0ef          	jal	800007de <panic>
    panic("virtio disk max queue too short");
    80005788:	00002517          	auipc	a0,0x2
    8000578c:	f8050513          	addi	a0,a0,-128 # 80007708 <etext+0x708>
    80005790:	84efb0ef          	jal	800007de <panic>
    panic("virtio disk kalloc");
    80005794:	00002517          	auipc	a0,0x2
    80005798:	f9450513          	addi	a0,a0,-108 # 80007728 <etext+0x728>
    8000579c:	842fb0ef          	jal	800007de <panic>

00000000800057a0 <virtio_disk_rw>:
  return 0;
}

void
virtio_disk_rw(struct buf *b, int write)
{
    800057a0:	711d                	addi	sp,sp,-96
    800057a2:	ec86                	sd	ra,88(sp)
    800057a4:	e8a2                	sd	s0,80(sp)
    800057a6:	e4a6                	sd	s1,72(sp)
    800057a8:	e0ca                	sd	s2,64(sp)
    800057aa:	fc4e                	sd	s3,56(sp)
    800057ac:	f852                	sd	s4,48(sp)
    800057ae:	f456                	sd	s5,40(sp)
    800057b0:	f05a                	sd	s6,32(sp)
    800057b2:	ec5e                	sd	s7,24(sp)
    800057b4:	e862                	sd	s8,16(sp)
    800057b6:	1080                	addi	s0,sp,96
    800057b8:	89aa                	mv	s3,a0
    800057ba:	8b2e                	mv	s6,a1
  uint64 sector = b->blockno * (BSIZE / 512);
    800057bc:	00c52b83          	lw	s7,12(a0)
    800057c0:	001b9b9b          	slliw	s7,s7,0x1
    800057c4:	1b82                	slli	s7,s7,0x20
    800057c6:	020bdb93          	srli	s7,s7,0x20

  acquire(&disk.vdisk_lock);
    800057ca:	0001b517          	auipc	a0,0x1b
    800057ce:	3f650513          	addi	a0,a0,1014 # 80020bc0 <disk+0x128>
    800057d2:	bfafb0ef          	jal	80000bcc <acquire>
  for(int i = 0; i < NUM; i++){
    800057d6:	44a1                	li	s1,8
      disk.free[i] = 0;
    800057d8:	0001ba97          	auipc	s5,0x1b
    800057dc:	2c0a8a93          	addi	s5,s5,704 # 80020a98 <disk>
  for(int i = 0; i < 3; i++){
    800057e0:	4a0d                	li	s4,3
    idx[i] = alloc_desc();
    800057e2:	5c7d                	li	s8,-1
    800057e4:	a095                	j	80005848 <virtio_disk_rw+0xa8>
      disk.free[i] = 0;
    800057e6:	00fa8733          	add	a4,s5,a5
    800057ea:	00070c23          	sb	zero,24(a4)
    idx[i] = alloc_desc();
    800057ee:	c19c                	sw	a5,0(a1)
    if(idx[i] < 0){
    800057f0:	0207c563          	bltz	a5,8000581a <virtio_disk_rw+0x7a>
  for(int i = 0; i < 3; i++){
    800057f4:	2905                	addiw	s2,s2,1
    800057f6:	0611                	addi	a2,a2,4 # 1004 <_entry-0x7fffeffc>
    800057f8:	05490c63          	beq	s2,s4,80005850 <virtio_disk_rw+0xb0>
    idx[i] = alloc_desc();
    800057fc:	85b2                	mv	a1,a2
  for(int i = 0; i < NUM; i++){
    800057fe:	0001b717          	auipc	a4,0x1b
    80005802:	29a70713          	addi	a4,a4,666 # 80020a98 <disk>
    80005806:	4781                	li	a5,0
    if(disk.free[i]){
    80005808:	01874683          	lbu	a3,24(a4)
    8000580c:	fee9                	bnez	a3,800057e6 <virtio_disk_rw+0x46>
  for(int i = 0; i < NUM; i++){
    8000580e:	2785                	addiw	a5,a5,1
    80005810:	0705                	addi	a4,a4,1
    80005812:	fe979be3          	bne	a5,s1,80005808 <virtio_disk_rw+0x68>
    idx[i] = alloc_desc();
    80005816:	0185a023          	sw	s8,0(a1)
      for(int j = 0; j < i; j++)
    8000581a:	01205d63          	blez	s2,80005834 <virtio_disk_rw+0x94>
        free_desc(idx[j]);
    8000581e:	fa042503          	lw	a0,-96(s0)
    80005822:	d41ff0ef          	jal	80005562 <free_desc>
      for(int j = 0; j < i; j++)
    80005826:	4785                	li	a5,1
    80005828:	0127d663          	bge	a5,s2,80005834 <virtio_disk_rw+0x94>
        free_desc(idx[j]);
    8000582c:	fa442503          	lw	a0,-92(s0)
    80005830:	d33ff0ef          	jal	80005562 <free_desc>
  int idx[3];
  while(1){
    if(alloc3_desc(idx) == 0) {
      break;
    }
    sleep(&disk.free[0], &disk.vdisk_lock);
    80005834:	0001b597          	auipc	a1,0x1b
    80005838:	38c58593          	addi	a1,a1,908 # 80020bc0 <disk+0x128>
    8000583c:	0001b517          	auipc	a0,0x1b
    80005840:	27450513          	addi	a0,a0,628 # 80020ab0 <disk+0x18>
    80005844:	e72fc0ef          	jal	80001eb6 <sleep>
  for(int i = 0; i < 3; i++){
    80005848:	fa040613          	addi	a2,s0,-96
    8000584c:	4901                	li	s2,0
    8000584e:	b77d                	j	800057fc <virtio_disk_rw+0x5c>
  }

  // format the three descriptors.
  // qemu's virtio-blk.c reads them.

  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    80005850:	fa042503          	lw	a0,-96(s0)
    80005854:	00451693          	slli	a3,a0,0x4

  if(write)
    80005858:	0001b797          	auipc	a5,0x1b
    8000585c:	24078793          	addi	a5,a5,576 # 80020a98 <disk>
    80005860:	00a50713          	addi	a4,a0,10
    80005864:	0712                	slli	a4,a4,0x4
    80005866:	973e                	add	a4,a4,a5
    80005868:	01603633          	snez	a2,s6
    8000586c:	c710                	sw	a2,8(a4)
    buf0->type = VIRTIO_BLK_T_OUT; // write the disk
  else
    buf0->type = VIRTIO_BLK_T_IN; // read the disk
  buf0->reserved = 0;
    8000586e:	00072623          	sw	zero,12(a4)
  buf0->sector = sector;
    80005872:	01773823          	sd	s7,16(a4)

  disk.desc[idx[0]].addr = (uint64) buf0;
    80005876:	6398                	ld	a4,0(a5)
    80005878:	9736                	add	a4,a4,a3
  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    8000587a:	0a868613          	addi	a2,a3,168 # 100010a8 <_entry-0x6fffef58>
    8000587e:	963e                	add	a2,a2,a5
  disk.desc[idx[0]].addr = (uint64) buf0;
    80005880:	e310                	sd	a2,0(a4)
  disk.desc[idx[0]].len = sizeof(struct virtio_blk_req);
    80005882:	6390                	ld	a2,0(a5)
    80005884:	00d605b3          	add	a1,a2,a3
    80005888:	4741                	li	a4,16
    8000588a:	c598                	sw	a4,8(a1)
  disk.desc[idx[0]].flags = VRING_DESC_F_NEXT;
    8000588c:	4805                	li	a6,1
    8000588e:	01059623          	sh	a6,12(a1)
  disk.desc[idx[0]].next = idx[1];
    80005892:	fa442703          	lw	a4,-92(s0)
    80005896:	00e59723          	sh	a4,14(a1)

  disk.desc[idx[1]].addr = (uint64) b->data;
    8000589a:	0712                	slli	a4,a4,0x4
    8000589c:	963a                	add	a2,a2,a4
    8000589e:	05898593          	addi	a1,s3,88
    800058a2:	e20c                	sd	a1,0(a2)
  disk.desc[idx[1]].len = BSIZE;
    800058a4:	0007b883          	ld	a7,0(a5)
    800058a8:	9746                	add	a4,a4,a7
    800058aa:	40000613          	li	a2,1024
    800058ae:	c710                	sw	a2,8(a4)
  if(write)
    800058b0:	001b3613          	seqz	a2,s6
    800058b4:	0016161b          	slliw	a2,a2,0x1
    disk.desc[idx[1]].flags = 0; // device reads b->data
  else
    disk.desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
  disk.desc[idx[1]].flags |= VRING_DESC_F_NEXT;
    800058b8:	01066633          	or	a2,a2,a6
    800058bc:	00c71623          	sh	a2,12(a4)
  disk.desc[idx[1]].next = idx[2];
    800058c0:	fa842583          	lw	a1,-88(s0)
    800058c4:	00b71723          	sh	a1,14(a4)

  disk.info[idx[0]].status = 0xff; // device writes 0 on success
    800058c8:	00250613          	addi	a2,a0,2
    800058cc:	0612                	slli	a2,a2,0x4
    800058ce:	963e                	add	a2,a2,a5
    800058d0:	577d                	li	a4,-1
    800058d2:	00e60823          	sb	a4,16(a2)
  disk.desc[idx[2]].addr = (uint64) &disk.info[idx[0]].status;
    800058d6:	0592                	slli	a1,a1,0x4
    800058d8:	98ae                	add	a7,a7,a1
    800058da:	03068713          	addi	a4,a3,48
    800058de:	973e                	add	a4,a4,a5
    800058e0:	00e8b023          	sd	a4,0(a7)
  disk.desc[idx[2]].len = 1;
    800058e4:	6398                	ld	a4,0(a5)
    800058e6:	972e                	add	a4,a4,a1
    800058e8:	01072423          	sw	a6,8(a4)
  disk.desc[idx[2]].flags = VRING_DESC_F_WRITE; // device writes the status
    800058ec:	4689                	li	a3,2
    800058ee:	00d71623          	sh	a3,12(a4)
  disk.desc[idx[2]].next = 0;
    800058f2:	00071723          	sh	zero,14(a4)

  // record struct buf for virtio_disk_intr().
  b->disk = 1;
    800058f6:	0109a223          	sw	a6,4(s3)
  disk.info[idx[0]].b = b;
    800058fa:	01363423          	sd	s3,8(a2)

  // tell the device the first index in our chain of descriptors.
  disk.avail->ring[disk.avail->idx % NUM] = idx[0];
    800058fe:	6794                	ld	a3,8(a5)
    80005900:	0026d703          	lhu	a4,2(a3)
    80005904:	8b1d                	andi	a4,a4,7
    80005906:	0706                	slli	a4,a4,0x1
    80005908:	96ba                	add	a3,a3,a4
    8000590a:	00a69223          	sh	a0,4(a3)

  __sync_synchronize();
    8000590e:	0330000f          	fence	rw,rw

  // tell the device another avail ring entry is available.
  disk.avail->idx += 1; // not % NUM ...
    80005912:	6798                	ld	a4,8(a5)
    80005914:	00275783          	lhu	a5,2(a4)
    80005918:	2785                	addiw	a5,a5,1
    8000591a:	00f71123          	sh	a5,2(a4)

  __sync_synchronize();
    8000591e:	0330000f          	fence	rw,rw

  *R(VIRTIO_MMIO_QUEUE_NOTIFY) = 0; // value is queue number
    80005922:	100017b7          	lui	a5,0x10001
    80005926:	0407a823          	sw	zero,80(a5) # 10001050 <_entry-0x6fffefb0>

  // Wait for virtio_disk_intr() to say request has finished.
  while(b->disk == 1) {
    8000592a:	0049a783          	lw	a5,4(s3)
    sleep(b, &disk.vdisk_lock);
    8000592e:	0001b917          	auipc	s2,0x1b
    80005932:	29290913          	addi	s2,s2,658 # 80020bc0 <disk+0x128>
  while(b->disk == 1) {
    80005936:	84c2                	mv	s1,a6
    80005938:	01079a63          	bne	a5,a6,8000594c <virtio_disk_rw+0x1ac>
    sleep(b, &disk.vdisk_lock);
    8000593c:	85ca                	mv	a1,s2
    8000593e:	854e                	mv	a0,s3
    80005940:	d76fc0ef          	jal	80001eb6 <sleep>
  while(b->disk == 1) {
    80005944:	0049a783          	lw	a5,4(s3)
    80005948:	fe978ae3          	beq	a5,s1,8000593c <virtio_disk_rw+0x19c>
  }

  disk.info[idx[0]].b = 0;
    8000594c:	fa042903          	lw	s2,-96(s0)
    80005950:	00290713          	addi	a4,s2,2
    80005954:	0712                	slli	a4,a4,0x4
    80005956:	0001b797          	auipc	a5,0x1b
    8000595a:	14278793          	addi	a5,a5,322 # 80020a98 <disk>
    8000595e:	97ba                	add	a5,a5,a4
    80005960:	0007b423          	sd	zero,8(a5)
    int flag = disk.desc[i].flags;
    80005964:	0001b997          	auipc	s3,0x1b
    80005968:	13498993          	addi	s3,s3,308 # 80020a98 <disk>
    8000596c:	00491713          	slli	a4,s2,0x4
    80005970:	0009b783          	ld	a5,0(s3)
    80005974:	97ba                	add	a5,a5,a4
    80005976:	00c7d483          	lhu	s1,12(a5)
    int nxt = disk.desc[i].next;
    8000597a:	854a                	mv	a0,s2
    8000597c:	00e7d903          	lhu	s2,14(a5)
    free_desc(i);
    80005980:	be3ff0ef          	jal	80005562 <free_desc>
    if(flag & VRING_DESC_F_NEXT)
    80005984:	8885                	andi	s1,s1,1
    80005986:	f0fd                	bnez	s1,8000596c <virtio_disk_rw+0x1cc>
  free_chain(idx[0]);

  release(&disk.vdisk_lock);
    80005988:	0001b517          	auipc	a0,0x1b
    8000598c:	23850513          	addi	a0,a0,568 # 80020bc0 <disk+0x128>
    80005990:	ad0fb0ef          	jal	80000c60 <release>
}
    80005994:	60e6                	ld	ra,88(sp)
    80005996:	6446                	ld	s0,80(sp)
    80005998:	64a6                	ld	s1,72(sp)
    8000599a:	6906                	ld	s2,64(sp)
    8000599c:	79e2                	ld	s3,56(sp)
    8000599e:	7a42                	ld	s4,48(sp)
    800059a0:	7aa2                	ld	s5,40(sp)
    800059a2:	7b02                	ld	s6,32(sp)
    800059a4:	6be2                	ld	s7,24(sp)
    800059a6:	6c42                	ld	s8,16(sp)
    800059a8:	6125                	addi	sp,sp,96
    800059aa:	8082                	ret

00000000800059ac <virtio_disk_intr>:

void
virtio_disk_intr()
{
    800059ac:	1101                	addi	sp,sp,-32
    800059ae:	ec06                	sd	ra,24(sp)
    800059b0:	e822                	sd	s0,16(sp)
    800059b2:	e426                	sd	s1,8(sp)
    800059b4:	1000                	addi	s0,sp,32
  acquire(&disk.vdisk_lock);
    800059b6:	0001b497          	auipc	s1,0x1b
    800059ba:	0e248493          	addi	s1,s1,226 # 80020a98 <disk>
    800059be:	0001b517          	auipc	a0,0x1b
    800059c2:	20250513          	addi	a0,a0,514 # 80020bc0 <disk+0x128>
    800059c6:	a06fb0ef          	jal	80000bcc <acquire>
  // we've seen this interrupt, which the following line does.
  // this may race with the device writing new entries to
  // the "used" ring, in which case we may process the new
  // completion entries in this interrupt, and have nothing to do
  // in the next interrupt, which is harmless.
  *R(VIRTIO_MMIO_INTERRUPT_ACK) = *R(VIRTIO_MMIO_INTERRUPT_STATUS) & 0x3;
    800059ca:	100017b7          	lui	a5,0x10001
    800059ce:	53bc                	lw	a5,96(a5)
    800059d0:	8b8d                	andi	a5,a5,3
    800059d2:	10001737          	lui	a4,0x10001
    800059d6:	d37c                	sw	a5,100(a4)

  __sync_synchronize();
    800059d8:	0330000f          	fence	rw,rw

  // the device increments disk.used->idx when it
  // adds an entry to the used ring.

  while(disk.used_idx != disk.used->idx){
    800059dc:	689c                	ld	a5,16(s1)
    800059de:	0204d703          	lhu	a4,32(s1)
    800059e2:	0027d783          	lhu	a5,2(a5) # 10001002 <_entry-0x6fffeffe>
    800059e6:	04f70663          	beq	a4,a5,80005a32 <virtio_disk_intr+0x86>
    __sync_synchronize();
    800059ea:	0330000f          	fence	rw,rw
    int id = disk.used->ring[disk.used_idx % NUM].id;
    800059ee:	6898                	ld	a4,16(s1)
    800059f0:	0204d783          	lhu	a5,32(s1)
    800059f4:	8b9d                	andi	a5,a5,7
    800059f6:	078e                	slli	a5,a5,0x3
    800059f8:	97ba                	add	a5,a5,a4
    800059fa:	43dc                	lw	a5,4(a5)

    if(disk.info[id].status != 0)
    800059fc:	00278713          	addi	a4,a5,2
    80005a00:	0712                	slli	a4,a4,0x4
    80005a02:	9726                	add	a4,a4,s1
    80005a04:	01074703          	lbu	a4,16(a4) # 10001010 <_entry-0x6fffeff0>
    80005a08:	e321                	bnez	a4,80005a48 <virtio_disk_intr+0x9c>
      panic("virtio_disk_intr status");

    struct buf *b = disk.info[id].b;
    80005a0a:	0789                	addi	a5,a5,2
    80005a0c:	0792                	slli	a5,a5,0x4
    80005a0e:	97a6                	add	a5,a5,s1
    80005a10:	6788                	ld	a0,8(a5)
    b->disk = 0;   // disk is done with buf
    80005a12:	00052223          	sw	zero,4(a0)
    wakeup(b);
    80005a16:	cecfc0ef          	jal	80001f02 <wakeup>

    disk.used_idx += 1;
    80005a1a:	0204d783          	lhu	a5,32(s1)
    80005a1e:	2785                	addiw	a5,a5,1
    80005a20:	17c2                	slli	a5,a5,0x30
    80005a22:	93c1                	srli	a5,a5,0x30
    80005a24:	02f49023          	sh	a5,32(s1)
  while(disk.used_idx != disk.used->idx){
    80005a28:	6898                	ld	a4,16(s1)
    80005a2a:	00275703          	lhu	a4,2(a4)
    80005a2e:	faf71ee3          	bne	a4,a5,800059ea <virtio_disk_intr+0x3e>
  }

  release(&disk.vdisk_lock);
    80005a32:	0001b517          	auipc	a0,0x1b
    80005a36:	18e50513          	addi	a0,a0,398 # 80020bc0 <disk+0x128>
    80005a3a:	a26fb0ef          	jal	80000c60 <release>
}
    80005a3e:	60e2                	ld	ra,24(sp)
    80005a40:	6442                	ld	s0,16(sp)
    80005a42:	64a2                	ld	s1,8(sp)
    80005a44:	6105                	addi	sp,sp,32
    80005a46:	8082                	ret
      panic("virtio_disk_intr status");
    80005a48:	00002517          	auipc	a0,0x2
    80005a4c:	cf850513          	addi	a0,a0,-776 # 80007740 <etext+0x740>
    80005a50:	d8ffa0ef          	jal	800007de <panic>
	...

0000000080006000 <_trampoline>:
    80006000:	14051073          	csrw	sscratch,a0
    80006004:	02000537          	lui	a0,0x2000
    80006008:	357d                	addiw	a0,a0,-1 # 1ffffff <_entry-0x7e000001>
    8000600a:	0536                	slli	a0,a0,0xd
    8000600c:	02153423          	sd	ra,40(a0)
    80006010:	02253823          	sd	sp,48(a0)
    80006014:	02353c23          	sd	gp,56(a0)
    80006018:	04453023          	sd	tp,64(a0)
    8000601c:	04553423          	sd	t0,72(a0)
    80006020:	04653823          	sd	t1,80(a0)
    80006024:	04753c23          	sd	t2,88(a0)
    80006028:	f120                	sd	s0,96(a0)
    8000602a:	f524                	sd	s1,104(a0)
    8000602c:	fd2c                	sd	a1,120(a0)
    8000602e:	e150                	sd	a2,128(a0)
    80006030:	e554                	sd	a3,136(a0)
    80006032:	e958                	sd	a4,144(a0)
    80006034:	ed5c                	sd	a5,152(a0)
    80006036:	0b053023          	sd	a6,160(a0)
    8000603a:	0b153423          	sd	a7,168(a0)
    8000603e:	0b253823          	sd	s2,176(a0)
    80006042:	0b353c23          	sd	s3,184(a0)
    80006046:	0d453023          	sd	s4,192(a0)
    8000604a:	0d553423          	sd	s5,200(a0)
    8000604e:	0d653823          	sd	s6,208(a0)
    80006052:	0d753c23          	sd	s7,216(a0)
    80006056:	0f853023          	sd	s8,224(a0)
    8000605a:	0f953423          	sd	s9,232(a0)
    8000605e:	0fa53823          	sd	s10,240(a0)
    80006062:	0fb53c23          	sd	s11,248(a0)
    80006066:	11c53023          	sd	t3,256(a0)
    8000606a:	11d53423          	sd	t4,264(a0)
    8000606e:	11e53823          	sd	t5,272(a0)
    80006072:	11f53c23          	sd	t6,280(a0)
    80006076:	140022f3          	csrr	t0,sscratch
    8000607a:	06553823          	sd	t0,112(a0)
    8000607e:	00853103          	ld	sp,8(a0)
    80006082:	02053203          	ld	tp,32(a0)
    80006086:	01053283          	ld	t0,16(a0)
    8000608a:	00053303          	ld	t1,0(a0)
    8000608e:	12000073          	sfence.vma
    80006092:	18031073          	csrw	satp,t1
    80006096:	12000073          	sfence.vma
    8000609a:	9282                	jalr	t0

000000008000609c <userret>:
    8000609c:	12000073          	sfence.vma
    800060a0:	18051073          	csrw	satp,a0
    800060a4:	12000073          	sfence.vma
    800060a8:	02000537          	lui	a0,0x2000
    800060ac:	357d                	addiw	a0,a0,-1 # 1ffffff <_entry-0x7e000001>
    800060ae:	0536                	slli	a0,a0,0xd
    800060b0:	02853083          	ld	ra,40(a0)
    800060b4:	03053103          	ld	sp,48(a0)
    800060b8:	03853183          	ld	gp,56(a0)
    800060bc:	04053203          	ld	tp,64(a0)
    800060c0:	04853283          	ld	t0,72(a0)
    800060c4:	05053303          	ld	t1,80(a0)
    800060c8:	05853383          	ld	t2,88(a0)
    800060cc:	7120                	ld	s0,96(a0)
    800060ce:	7524                	ld	s1,104(a0)
    800060d0:	7d2c                	ld	a1,120(a0)
    800060d2:	6150                	ld	a2,128(a0)
    800060d4:	6554                	ld	a3,136(a0)
    800060d6:	6958                	ld	a4,144(a0)
    800060d8:	6d5c                	ld	a5,152(a0)
    800060da:	0a053803          	ld	a6,160(a0)
    800060de:	0a853883          	ld	a7,168(a0)
    800060e2:	0b053903          	ld	s2,176(a0)
    800060e6:	0b853983          	ld	s3,184(a0)
    800060ea:	0c053a03          	ld	s4,192(a0)
    800060ee:	0c853a83          	ld	s5,200(a0)
    800060f2:	0d053b03          	ld	s6,208(a0)
    800060f6:	0d853b83          	ld	s7,216(a0)
    800060fa:	0e053c03          	ld	s8,224(a0)
    800060fe:	0e853c83          	ld	s9,232(a0)
    80006102:	0f053d03          	ld	s10,240(a0)
    80006106:	0f853d83          	ld	s11,248(a0)
    8000610a:	10053e03          	ld	t3,256(a0)
    8000610e:	10853e83          	ld	t4,264(a0)
    80006112:	11053f03          	ld	t5,272(a0)
    80006116:	11853f83          	ld	t6,280(a0)
    8000611a:	7928                	ld	a0,112(a0)
    8000611c:	10200073          	sret
	...
