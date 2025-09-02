
#include "../kernel/types.h"
#include "../kernel/stat.h"
#include "user.h"
int main(void) {
char buf[32] = "Kethu Shanmukha Reddy";
printf("Before: %s\n", buf);
strrev(buf, strlen(buf)); 
printf("After: %s\n", buf);
exit(1);
}