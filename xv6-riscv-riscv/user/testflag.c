#include "../kernel/types.h"
#include "../kernel/stat.h"
#include "user.h"

int
main(void)
{
    int val;

    setflag(1234);
    val = getflag();
    printf("After first setflag: userflag = %d\n", val);

    setflag(2390);
    val = getflag();
    printf("After second setflag: userflag = %d\n", val);

    exit(1);
}
