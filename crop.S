.intel_syntax noprefix
.global crop
.type crop, @function

.data
pct_d_d: .asciz "%d %d\n"
pct_d_d_d: .asciz "%d %d %d\n"
pct_d_d_d_d: .asciz "%d %d %d %d\n"
width_debug: .asciz "source width: %d, result width: %d\n"


#include "helper_macros.S"
.text

#define return_value rax
#define resultPtr rdi
#define sourcePtr rsi
#define cropX rdx
#define cropY rcx
#define width r8
#define height r9
#define tmp2 r10
#define y r11
#define x r12
#define tmp r14
#define tmp_8 r14b
#define sourceRowBytes r15

#define resultOffset tmp

// void crop(unsigned char *result, unsigned char *source, int x, int y, int width, int height, int sourceRowBytes)

// entry point
crop:
    endbr64
    setup_frame

    mov sourceRowBytes, qword ptr argument(0)

    push r12
    push r13
    push r14
    push r15

    call fun

    pop r15
    pop r14
    pop r13
    pop r12

    // Clean up frame
    cleanup_frame
    ret

fun:
    endbr64

    xor y, y // y = 0
for_y: // for (      // y < height// y++)

    xor x, x // x = 0
for_x: // for (      // x < width// )

    // uncomment for logging
    //printf4(pct_d_d_d_d, x, y, width, sourceRowBytes)
    mov tmp, width
    sub tmp, x
    // if (width - x >= 16)
    cmp tmp, 16
    // offs = ((cropY + y) * sourceRowBytes) + cropX + x
    mov tmp, cropY
    add tmp, y
    imul tmp, sourceRowBytes
    add tmp, cropX
    add tmp, x
    // offs = (y * width) + x
    mov tmp2, y
    imul tmp2, width
    add tmp2, x
    jge copy_batch
copy_byte:
    mov tmp_8, byte ptr [sourcePtr+tmp]
    mov byte ptr [resultPtr+tmp2], tmp_8

    inc x

    jmp for_x_continue
copy_batch:
    movdqu xmm0, [sourcePtr+tmp]
    movdqu [resultPtr+tmp2], xmm0

    add x, 16
for_x_continue:

    // if (x < width) jmp for_x
    cmp x, width
    jl for_x
for_x_end:

for_y_continue:
    inc y

    // if (y < height) jmp for_y
    cmp y, height
    jl for_y
for_y_end:

    ret

