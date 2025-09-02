#include "../kernel/types.h"
#include "../kernel/stat.h"
#include "user.h"

int main ( void )
 {
//  int stats [2];
//  int i ;
//  for ( i = 0; i < 2; i ++) {
//  if ( getstats(stats) == 0) {
//  // Access the elements using array indices .
//  printf (1 , " Scheduled % d times , ran for % d ticks \ n " , stats[0] , stats[1] ) ;
//  } else {
//  printf (2 , " getstats failed \ n " ) ;
//  }
//  sleep (10) ;
//  }
//  exit (1) ;

int stats[2];
  int i;

  for (i = 0; i < 2; i++) {
    if (getstats(stats) == 0) {
      // Just use printf without fd in riscv
      printf("Scheduled %d times, ran for %d ticks\n", stats[0], stats[1]);
    } else {
      printf("getstats failed\n");
    }
    sleep(10);
  }

  exit(0); // success exit code
 }