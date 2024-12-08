import re

from format import Opcode_itype, Opcode_jtype, Opcode_rtype, Register, Funct
from format import ConvertToDec, to_binary, CheckSyntax, split_instruction, SourceToBasic

# Xoá các chú thích, khoảng trống
def DeleteComment(code):
    cleaned_code = []
    for line in code:
        line = line.split('#')[0].strip()
        if line:
            cleaned_code.append(line)
    return cleaned_code

# Tính toán địa chỉ cho label
def CalculateImmediate(cleaned_code, start_address=0x00400000):
    address = start_address
    instructions_with_address = []  # Lưu địa chỉ của các lệnh

    for line in cleaned_code:
        if ':' in line:  # Dòng chứa label
            label, *rest = line.split(':', 1)  # Tách nhãn và phần còn lại
            label = label.strip()  # Xử lý nhãn (nếu cần sau này)
            if rest:  # Nếu có lệnh sau nhãn, xử lý nó
                rest_line = rest[0].strip()
                if rest_line:
                    instructions_with_address.append((address, rest_line))
            # Dòng chỉ có label sẽ không tạo địa chỉ mới
        else:
            instructions_with_address.append((address, line))
        address += 4  # Tăng địa chỉ lên 4 sau mỗi dòng lệnh

    return instructions_with_address

# Xây dựng bảng label và xoá label
def BuildLabelTable(cleaned_code, start_address=0x00400000):
    address = start_address
    labels = {}
    code_without_labels = []

    for line in cleaned_code:
        line = line.strip()
        if not line:  # Bỏ qua dòng trống
            continue
        if ':' in line:  # Dòng chứa label
            parts = line.split(':', 1)
            label = parts[0].strip()
            if label in labels:
                raise ValueError(f"Lỗi: Nhãn '{label}' bị trùng!")
            labels[label] = address  # Lưu địa chỉ của nhãn
            
            if len(parts) > 1 and parts[1].strip():  # Nếu có lệnh sau nhãn
                code_without_labels.append(parts[1].strip())  # Giữ lệnh
                address += 4  # Chỉ tăng địa chỉ nếu có lệnh
        else:  # Không phải nhãn, là một lệnh thông thường
            code_without_labels.append(line)
            address += 4

    return labels, code_without_labels

# Tạo mã nhị phân cho lệnh
def GenerateBinary(line, labels, current_address):
    parts = split_instruction(line)
    opcode = parts[0]   

    # Check R-type
    if opcode in Opcode_rtype:
        # jr: PC = R[rs]
        if opcode == "jr":
            rs = Register[parts[1]]
            return f"{Opcode_rtype[opcode]}{rs}000000000000000{Funct[opcode]}"
        # opcode rd, rs, rt
        rd, rs, rt = Register[parts[1]], Register[parts[2]], Register[parts[3]]

        return f"{Opcode_rtype[opcode]}{rs}{rt}{rd}00000{Funct[opcode]}"
        
    # Check I-type
    if opcode in Opcode_itype:
        # Check load, store ..
        if opcode in ["lw", "sw", "lbu", "lhu"]: # opcode rt, offset(rs)
            rt, offset, rs = Register[parts[1]], ConvertToDec(parts[2]),Register[parts[3]]
            return f"{Opcode_itype[opcode]}{rs}{rt}{to_binary(offset, 16)}"
        # Check ALU có immediate
        elif opcode in ["addi", "addiu", "andi", "ori"]: # opcode rt, rs, immediate
            rt, rs, immediate = Register[parts[1]], Register[parts[2]], ConvertToDec(parts[3])
            return f"{Opcode_itype[opcode]}{rs}{rt}{to_binary(immediate, 16)}"
        # Check branch có điều kiện
        elif opcode in ["beq", "bne"]:
            # opcode rs, rt, label
            rs, rt, label_jump = Register[parts[1]], Register[parts[2]], parts[3]
            if label_jump in labels:
                label_jump = (labels[label_jump] - current_address - 4) // 4
            return f"{Opcode_itype[opcode]}{rs}{rt}{to_binary(label_jump, 16)}"
        # Check load ..
        elif opcode == "lui": # lui rt, immediate
            rt, immediate = Register[parts[1]], ConvertToDec(parts[2])
            return f"{Opcode_itype[opcode]}00000{rt}{to_binary(immediate, 16)}"
    
    # Check J-type
    elif opcode in Opcode_jtype: # j, jal target
        target = parts[1]
        # Kiểm tra target có trong label?
        if target in labels:
            address = labels[parts[1]] // 4
        else:
            raise ValueError(f"Lỗi: Không có label {label_jump} ở {current_address}")

        return f"{Opcode_jtype[opcode]}{to_binary(address, 26)}"

    else:
        raise ValueError(f"Lỗi: Lệnh '{opcode}' không hợp lệ!")

# Chuyến 1 
def FirstPass(input_file):
    # Đọc file
    with open(input_file, "r") as file:
        lines = file.readlines()
    # 1.1 Xoá chú thích, khoảng trống
    lines = DeleteComment(lines)
    # 1.2 Kiểm tra cú pháp
    CheckSyntax(lines)
    # 1.3 Chuyển dạng source về basic
    lines = SourceToBasic(lines)
    # 1.4 Tính toán địa chỉ cho các lệnh
    instructions_with_address = CalculateImmediate(lines)

    # print("Instructions with addresses:")
    # for addr, instr in instructions_with_address:
    #     print(f"{hex(addr)}: {instr}")
    # 1.5 Tạo bảng label và xoá nhãn
    labels, cleaned_lines = BuildLabelTable(lines)

    return instructions_with_address, labels, cleaned_lines

# Chuyến 2:
def SecondPass(cleaned_lines, labels):
    binary_code = []
    current_address = 0x00400000
    for line in cleaned_lines:
        binary = GenerateBinary(line, labels, current_address)
        binary_code.append(binary)
        current_address += 4
    return binary_code

def main(input, output_bin, output_hex):
    # Chuyến 1
    instructions_with_address, labels, cleaned_lines = FirstPass(input)
    # Chuyến 2
    binary_code = SecondPass(cleaned_lines, labels)

    # Ghi binary vào file .bin
    with open(output_bin, "w") as file:
        for binary in binary_code:
            file.write(binary + "\n")
    
    # Ghi binary vào file .hex dưới dạng hex
    with open(output_hex, "w") as file:
        for binary_instructions in binary_code:
            binary_lines = binary_instructions.split('\n')

            for binary in binary_lines:
                # Chuyển binary thành hex (mỗi binary là 32-bit)
                hex_value = format(int(binary, 2), "08X")  # 32-bit hex (8 ký tự)
                file.write(hex_value + "\n")

    print("Biên dịch thành công!")

input = "test.asm"
output_bin = "output.bin"
output_hex = "output.hex"
main(input, output_bin, output_hex)

#------------------------------------------
# 1 số câu lệnh xem mã sau khi rút gọn
#------------------------------------------

# print("Instructions with addresses:")
# for addr, instr in instructions_with_address:
#     print(f"{hex(addr)}: {instr}")

# print("\nLabels with addresses:")
# for label, addr in labels.items():
#     print(f"{label}: {hex(addr)}")

# print("\nFinal cleaned code (no labels):")
# for line in final_code:
#     print(line)
#------------------------------------------------