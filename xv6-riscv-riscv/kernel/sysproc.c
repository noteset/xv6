#include "types.h"
#include "riscv.h"
#include "defs.h"
#include "param.h"
#include "memlayout.h"
#include "spinlock.h"
#include "proc.h"

uint64
sys_exit(void)
{
  int n;
  argint(0, &n);
  exit(n);
  return 0;  // not reached
}

uint64
sys_getpid(void)
{
  return myproc()->pid;
}

uint64
sys_fork(void)
{
  return fork();
}

uint64
sys_wait(void)
{
  uint64 p;
  argaddr(0, &p);
  return wait(p);
}

uint64
sys_sbrk(void)
{
  uint64 addr;
  int n;

  argint(0, &n);
  addr = myproc()->sz;
  if(growproc(n) < 0)
    return -1;
  return addr;
}

uint64
sys_sleep(void)
{
  int n;
  uint ticks0;

  argint(0, &n);
  if(n < 0)
    n = 0;
  acquire(&tickslock);
  ticks0 = ticks;
  while(ticks - ticks0 < n){
    if(killed(myproc())){
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
  }
  release(&tickslock);
  return 0;
}

uint64
sys_kill(void)
{
  int pid;

  argint(0, &pid);
  return kill(pid);
}

// return how many clock tick interrupts have occurred
// since start.
uint64
sys_uptime(void)
{
  uint xticks;

  acquire(&tickslock);
  xticks = ticks;
  release(&tickslock);
  return xticks;
}

uint64
sys_strrev(void)
{
   char buf[128];   // Temporary buffer in kernel
    int len, i;

    // Get the length from syscall args
    argint(1, &len);

    // Copy string from user space into buf
    if (argstr(0, buf, sizeof(buf)) < 0)
        return -1;

    // Simple in-place reversal
    for (i = 0; i < len / 2; i++) {
        char tmp = buf[i];
        buf[i] = buf[len - i - 1];
        buf[len - i - 1] = tmp;
    }

    // Copy the reversed string back to user space
    // First syscall arg is address of original string in user space
    uint64 user_addr;
    argaddr(0, &user_addr);
    if (copyout(myproc()->pagetable, user_addr, buf, len) < 0)
        return -1;

    return 0;
}

uint64
sys_setflag(void)
{
  int flag;
  argint(0, &flag);
  //in risc-v argint() doesn't return anything
  myproc()->ugoodbro = flag;
  return 0;                    
}


uint64
sys_getflag(void)
{
    return myproc()->ugoodbro;
}

uint64
sys_getstats(void)
{
  // int *user_stats_ptr;

  // if(argstr(0,(void*)&user_stats_ptr,2*sizeof(int))<0)
  // return -1;

  // struct proc *p = myproc();
  // int kernel_stats[2];
  // kernel_stats[0]=p->sched_count;
  // kernel_stats[1]=p->run_ticks;

  // if(copyout(p->pagetable, (uint)user_stats_ptr, (char*)kernel_stats, sizeof(kernel_stats))<0) {
  //   return -1; 
  // }

  // return 0;


  uint64 user_stats_ptr;

  argaddr(0, &user_stats_ptr);

  struct proc *p = myproc();
  int kernel_stats[2];
  kernel_stats[0] = p->sched_count;
  kernel_stats[1] = p->run_ticks;

  // copy the stats back to user space
  if (copyout(p->pagetable, user_stats_ptr, (char*)kernel_stats, sizeof(kernel_stats)) < 0) {
    return -1;
  }

  return 0;

}
