#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <inttypes.h>

int64_t fibonacci(int n) {
    int64_t a = 0;
    int64_t b = 1;
    int64_t c;

    while (n > 0) {
        c = a + b;
        a = b;
        b = c;
        n--;
    }

    return a;
}

int main(int argc, char* argv[]) {
    int n = atoi(argv[1]);

    printf("%" PRIi64 "\n", fibonacci(n));
    return 0;
}
