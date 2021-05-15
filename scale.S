.intel_syntax noprefix
.global scale
.type scale, @function

.data
xy_log: .asciz "x %lu y %lu xS %lu yS %lu\n"
offs_s_log: .asciz "sourceOffs %lu"
offs_r_log: .asciz ", resultOffs %lu\n"

#include "helper_macros.S"
#define ASM_CODE
#include "bmp.h"

.text

// void scale(unsigned char *result, unsigned char *source, int width, int height, int scalingFactor, unsigned int padding);

#define resultPtr reg_arg_1
#define sourcePtr reg_arg_2
#define width reg_arg_3
#define height reg_arg_4
#define scalingFactor reg_arg_5
#define padding reg_arg_6
#define x r10
#define y r11
#define tmp r12
#define tmp_8 r12b
#define tmp_16 r12w
#define tmp2 r13
#define tmp2_8 r13b
#define tmp2_16 r13w
#define xScalingRemaining r14
#define yScalingRemaining r15

scale:
    endbr64
    setup_frame

    // Callee-saved, so we need to push them
    push r12
    push r13
    push r14
    push r15

    call algo

    pop r15
    pop r14
    pop r13
    pop r12

    cleanup_frame
    ret

algo:
    endbr64

    xor y, y        // y = 0
    jmp for_y_interpolated

for_y_interpolated_inc:
    inc y
    // if (y == height) for_y_end
    cmp y, height
    je for_y_end

for_y_interpolated:
    mov yScalingRemaining, scalingFactor

for_y:              // like: for (uint64_t y = 0; y < height; y++)
    cmp yScalingRemaining, 0
    jz for_y_interpolated_inc

    xor x, x        // x = 0
for_x:              // like: for (uint64_t x = 0; x < width; x++)

nearest_interpolation:
    // here we copy each pixel as often as scalingFactor specifies
    mov xScalingRemaining, scalingFactor


    call retrieve_pixel
for_ni_x:
    // uncomment for logging
    //printf4(xy_log, x, y, xScalingRemaining, yScalingRemaining)
    // This is going to be called {scalingFactor} times
    call write_pixel

    dec xScalingRemaining
    // if (xScalignRemaining != 0) for_ni_x
    cmp xScalingRemaining, 0
    jnz for_ni_x

for_x_continue:
    add x, BMP_BYTES_PP

    // if (x < width) for_x
    cmp x, width
    jl for_x
for_x_end:

for_y_continue:
    dec yScalingRemaining
    jmp for_y
for_y_end:

    ret

retrieve_pixel:
    endbr64

    // sourceOffs = y * width + x
    mov tmp2, width
    imul tmp2, y
    add tmp2, x

    // uncomment for logging
    //printf1(offs_s_log, tmp)
#if BMP_BYTES_PP == 3
    mov tmp_16, word ptr [sourcePtr+tmp2]
    shl tmp, 8
    add tmp2, 2
    mov tmp_8, byte ptr [sourcePtr+tmp2]
#elif BMP_BYTES_PP == 4
    mov tmp, qword ptr [sourcePtr+tmp2]
#endif

    ret

write_pixel:
    endbr64

    // resultOffs = (y * scalingFactor + yScalingRemaining - 1) * (width * scalingFactor + padding)
    //             + x * scalingFactor + (xScalingRemaining - 1) * BMP_BYTES_PP

    // y offset
    // y * scalingFactor + yScalingRemaining - 1
    mov tmp2, y
    imul tmp2, scalingFactor
    add tmp2, yScalingRemaining
    dec tmp2

    push tmp

    // (width * scalingFactor + padding)
    mov tmp, width
    imul tmp, scalingFactor
    add tmp, padding
    imul tmp2, tmp

    // x * scalingFactor
    mov tmp, x
    imul tmp, scalingFactor
    add tmp2, tmp

    // (xScalingRemaining - 1) * BMP_BYTES_PP
    mov tmp, xScalingRemaining
    dec tmp
    imul tmp, BMP_BYTES_PP
    add tmp2, tmp

    pop tmp

    // uncomment for logging
    //printf1(offs_r_log, tmp2)

#if BMP_BYTES_PP == 3
    add tmp2, 2
    mov byte ptr [resultPtr+tmp2], tmp_8
    sub tmp2, 2
    rol tmp, 48+8
    mov word ptr [resultPtr+tmp2], tmp_16
    ror tmp, 48+8
#else
    mov qword ptr [resultPtr+tmp2], tmp
#endif

    ret
             
