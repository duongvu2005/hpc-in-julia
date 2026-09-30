import dis

def fibonacci(n):
    a = 0
    b = 1
    while n > 0:
        a, b = b, (a + b)
        n -= 1

    return a

if __name__ == '__main__':
    output_filename = "python_bytecode.dis"

    with open(output_filename, "w") as f:
        dis.dis(fibonacci, file=f)
