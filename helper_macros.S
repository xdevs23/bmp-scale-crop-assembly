// printf is defined externally so we tell the assembler
.extern printf

// Argument registers
#define reg_arg_1 rdi
#define reg_arg_2 rsi
#define reg_arg_3 rdx
#define reg_arg_4 rcx
#define reg_arg_5 r8
#define reg_arg_6 r9

// pushes all registers onto stack
#define push_stack  \
    push reg_arg_1; \
    push reg_arg_2; \
    push reg_arg_3; \
    push reg_arg_4; \
    push reg_arg_5; \
    push reg_arg_6; \
    push r10;       \
    push r11;       \
    push rax;

// pops all registers from stack
#define pop_stack  \
    pop rax;        \
    pop r11;        \
    pop r10;        \
    pop reg_arg_6;  \
    pop reg_arg_5;  \
    pop reg_arg_4;  \
    pop reg_arg_3;  \
    pop reg_arg_2;  \
    pop reg_arg_1;

#define call_printf xor  rax, rax; \
                    call printf;

#define set_argument(number, value) mov reg_arg_##number##, value
#define set_argument_conststr(number, strname) \
                    lea reg_arg_##number##, [rip+strname]

#define printf0(conststr) \
                    push_stack; \
                    set_argument_conststr(1, conststr); \
                    call_printf; \
                    pop_stack;

#define printf1(conststr, arg1) \
                    push_stack; \
                    set_argument_conststr(1, conststr); \
                    set_argument(2, arg1); \
                    call_printf; \
                    pop_stack;

#define printf2(conststr, arg1, arg2) \
                    push_stack; \
                    set_argument_conststr(1, conststr); \
                    set_argument(2, arg1); \
                    set_argument(3, arg2); \
                    call_printf; \
                    pop_stack;

#define printf3(conststr, arg1, arg2, arg3) \
                    push_stack; \
                    set_argument_conststr(1, conststr); \
                    set_argument(2, arg1); \
                    set_argument(3, arg2); \
                    set_argument(4, arg3); \
                    call_printf; \
                    pop_stack;


#define printf4(conststr, arg1, arg2, arg3, arg4) \
                    push_stack; \
                    set_argument_conststr(1, conststr); \
                    set_argument(2, arg1); \
                    set_argument(3, arg2); \
                    set_argument(4, arg3); \
                    set_argument(5, arg4); \
                    call_printf; \
                    pop_stack;

#define setup_frame \
                    push rbp; \
                    mov rbp, rsp;

#define cleanup_frame \
                    mov rsp, rbp; \
                    pop rbp;

#define divide(dividend, divisor) \
                    push rdx; \
                    push rax; \
                    push rcx; \
                    mov rdx, dividend; \
                    shr rdx, 32; \
                    mov rax, dividend; \
                    shl rax, 32; \
                    shr rax, 32; \
                    mov rcx, divisor; \
                    div ecx; \
                    mov dividend, rax; \
                    pop rcx; \
                    pop rax; \
                    pop rdx;

#define modulus(dividend, divisor) \
                    push rdx; \
                    push rax; \
                    push rcx; \
                    mov rdx, dividend; \
                    shr rdx, 32; \
                    mov rax, dividend; \
                    shl rax, 32; \
                    shr rax, 32; \
                    mov rcx, divisor; \
                    div ecx; \
                    mov dividend, rdx; \
                    pop rcx; \
                    pop rax; \
                    pop rdx;

#define stack rsp
#define frame_offs 16
#define stack_args_start stack+frame_offs
#define argument(index) [stack_args_start+index*8]
