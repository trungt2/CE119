import re

Opcode_rtype = {
    # R-type
    "add": "000000", "addu": "000000", 
    "and": "000000","or": "000000" ,  
    "jr": "000000"
}

Opcode_itype = {
    # I-type 
    "addi": "001000", "addiu": "001001", 
    "andi": "001100", "ori": "001101",
    "beq": "000100", "bne": "000101", 
    "lbu": "100100", "lhu": "100101", "lw": "100011", "sw": "101011",
    "lui": "001111",
}

Opcode_jtype = {
    # J-type
    "j": "000010", "jal": "000011"
}

Funct = {
    "add": "100000", "addu": "100001", 
    "and": "100100", "or": "100101",
    "jr": "001000"
}

# Địa chỉ 32 thanh ghi
Register = {
    "$zero": "00000", "$at": "00001", "$v0": "00010", "$v1": "00011",
    "$a0": "00100", "$a1": "00101", "$a2": "00110", "$a3": "00111",
    "$t0": "01000", "$t1": "01001", "$t2": "01010", "$t3": "01011",
    "$t4": "01100", "$t5": "01101", "$t6": "01110", "$t7": "01111",
    "$s0": "10000", "$s1": "10001", "$s2": "10010", "$s3": "10011",
    "$s4": "10100", "$s5": "10101", "$s6": "10110", "$s7": "10111",
    "$t8": "11000", "$t9": "11001", "$k0": "11010", "$k1": "11011",
    "$gp": "11100", "$sp": "11101", "$fp": "11110", "$ra": "11111"
}

# Chuyển ALU có offset về ALU không offset
def process_line(line):
    # Loại bỏ khoảng trắng thừa
    line = line.strip()
    
    # Kiểm tra và trả về kết quả tương ứng
    if line.startswith("addiu"):
        return "addu"
    elif line.startswith("andi"):
        return "and"
    elif line.startswith("addi"):
        return "add"
    elif line.startswith("ori"):
        return "or"
    else:
        return "Không xác định"  # Khi không khớp với điều kiện nào

# Kiểm tra loại lệnh ALU có offset
def isALUoffset(line):
    # Loại bỏ khoảng trắng thừa ở đầu và cuối dòng
    line = line.strip()
    
    # Kiểm tra nếu chuỗi bắt đầu bằng một trong các từ đã cho
    return (line.startswith("addi") or 
            line.startswith("andi") or 
            line.startswith("addiu") or 
            line.startswith("ori"))
    
# chuyển dạng source về basic
def SourceToBasic(code):
    converted_code = []
    for line in code:
        line = line.strip()
        
        # Kiểm tra xem dòng có nhãn ở đầu hay không
        label = ""
        if ":" in line:
            label_part = line.split(":")
            label = label_part[0].strip()  # Lấy nhãn
            line = label_part[1].strip()  # Phần còn lại là mã lệnh
            
        # Kiểm tra nếu lệnh là `beq`
        if line.startswith("beq") or line.startswith("bne"):
            # beq rs, imme, label => addi $at, $zero, imme
            #                         beq $at, rs, label
            parts = line.split(',')
            opcode = parts[0].split()[0]
            rt, immediate, target_label = parts[0].split()[1], parts[1].strip(), parts[2].strip() 
            # Thay thế bằng hai lệnh: addi và beq
            if label:
                converted_code.append(f"{label}:")  # Thêm nhãn trước
            converted_code.append(f"addi $at, $zero, {immediate}")  
            converted_code.append(f"{opcode} $at, {rt}, {target_label}")
        elif isALUoffset(line):
            # Nếu imme > 16 bits cần chuyển sang: ví dụ addi rt, rs, imme
            # lui $at, imme/16
            # ori $at, $at, imme%16
            # (add|and|addu) rt, rs, $at
            parts = line.split(',')
            opcode = parts[0].split()[0]
            rt, rs, immediate = parts[0].split()[1], parts[1].strip(), ConvertToDec(parts[2].strip())
            if label:
                converted_code.append(f"{label}:")  # Thêm nhãn trước

            if immediate > 655535: # rs > 16 bits
                immediate_0 = immediate % 65536 # Thương
                immediate_1 = immediate // 65536  # Dư

                converted_code.append(f"lui $at, {immediate_1}")  
                converted_code.append(f"ori $at, $at, {immediate_0}")

                opcode = process_line(line)
                converted_code.append(f"{opcode} {rt}, {rs}, $at")
            else: 
                converted_code.append(f"{opcode} {rt}, {rs}, {immediate}")
        else: # Giữ nguyên các label, lệnh
            if label:
                converted_code.append(f"{label}: {line}") 
            else:
                converted_code.append(line) 
    return converted_code

#Chuyển đổi định dạng sang DEC
def ConvertToDec(immediate):
    # Dành cho Load, Store
    if immediate == "":  
        return 0
    # Dạng hex
    elif immediate.startswith("0x") or immediate.startswith("-0x"):  
        return int(immediate, 16)
    # Dạng dec
    else:  
        return int(immediate)
    
# Chuyển Dec to Bin với n bits 
def to_binary(value, n):
    if value < 0:
        value = (1 << n) + value  # Xử lý bù hai
    return f"{value & ((1 << n) - 1):0{n}b}"  

# Tách code thành các phần
def split_instruction(line):
    # Loại bỏ khoảng trắng thừa
    line = line.strip()
    # Tách bằng regex, giữ lại các thành phần hợp lệ
    parts = re.findall(r"[a-zA-Z0-9_$\-]+|0x[0-9a-fA-F]+|[-]?\d+", line)
    return [part for part in parts if part not in [',', '(', ')']]

# Kiểm tra cú pháp
def CheckSyntax(cleaned_code):
    # đọc cú pháp 
    instruction_regex = re.compile(
        # ALU không immediate
        r"^(add|addu|and|or)\s+\$\w+\s*,\s*\$\w+\s*,\s*\$\w+$|"
        # ALU có immediate
        r"^(addi|addiu|andi|ori)\s+\$\w+\s*,\s*\$\w+\s*,\s*-?(0x[0-9A-Fa-f]+|\d+)$|"
        # Load, store
        r"^(lw|sw|lbu|lhu)\s+\$\w+\s*,\s*(-?(0x[0-9A-Fa-f]+|\d+))?\(\$\w+\)$|"
        # Load ..
        r"^(lui)\s+\$\w+\s*,\s*(0x[0-9A-Fa-f]+|\d+)$|"
        # Branch có điều kiện
        r"^(beq|bne)\s+\$\w+\s*,\s*(-?\$\w+|-?0x[0-9a-fA-F]+|-?\d+)\s*,\s*\w+$|"
        # Jump Address || Label
        r"^(j|jal)\s+\w+$|"
        # Jump Register
        r"^(jr)\s+\$\w+$" 
    )

    # Check độ dài immediate dưới dạng 0x..
    def is_valid_number(value, max_bits=32, signed=True):
        try:
            if value.startswith("0x") or value.startswith("-0x"):
                num = int(value, 16)
            else:
                num = int(value)
            if signed:
                return -(2 ** (max_bits - 1)) <= num < (2 ** (max_bits - 1))
            else:
                return 0 <= num < (2 ** max_bits)
        except ValueError:
            return False

    def is_valid_register(register):
        """Kiểm tra thanh ghi có trong danh sách hợp lệ không."""
        return register in Register

    # Duyệt qua từng dòng mã
    for idx, line in enumerate(cleaned_code):
        if ':' in line:  # Dòng chứa nhãn
            label, *rest = line.split(':', 1)
            label = label.strip()
            if rest:  # Nếu có lệnh sau nhãn
                rest_line = rest[0].strip() 
                if rest_line and not instruction_regex.match(rest_line):
                    raise ValueError(f"Lỗi cú pháp ở dòng {idx + 1}: {line}")
                # Kiểm tra thanh ghi trong lệnh
                if rest_line:
                    registers = re.findall(r"\$\w+", rest_line)
                    for reg in registers:
                        if not is_valid_register(reg):
                            raise ValueError(f"Lỗi: Thanh ghi '{reg}' không hợp lệ ở dòng {idx + 1}: {line}")
                if "," in rest_line:
                    target_match = re.findall(r"(-?(?:0x[0-9A-Fa-f]+|\d+)|\w+)$", rest_line)
                    for target in target_match:
                        if target.isdigit() or target.startswith("0x") or target.startswith("-"):
                            # Kiểm tra giá trị của lui (16-bit unsigned)
                            if rest_line.startswith("lui") and not is_valid_number(target, max_bits=16, signed=False):
                                raise ValueError(f"Lỗi: Giá trị imm của `lui` không hợp lệ ở dòng {idx + 1}: {line}")
                            elif not is_valid_number(target):  # Kiểm tra giá trị khác
                                raise ValueError(f"Lỗi: Giá trị không hợp lệ ở dòng {idx + 1}: {line}")
        else:  # Dòng không chứa nhãn
            if not instruction_regex.match(line):
                raise ValueError(f"Lỗi cú pháp ở dòng {idx + 1}: {line}")
            # Kiểm tra thanh ghi trong lệnh
            registers = re.findall(r"\$\w+", line)
            for reg in registers:
                if not is_valid_register(reg):
                    raise ValueError(f"Lỗi: Thanh ghi '{reg}' không hợp lệ ở dòng {idx + 1}: {line}")
            if "," in line:
                target_match = re.findall(r"(-?(?:0x[0-9A-Fa-f]+|\d+)|\w+)$", line)
                for target in target_match:
                    if target.isdigit() or target.startswith("0x") or target.startswith("-"):
                        # Kiểm tra giá trị của lui (16-bit unsigned)
                        if line.startswith("lui") and not is_valid_number(target, max_bits=16, signed=False):
                            raise ValueError(f"Lỗi: Giá trị imm của `lui` không hợp lệ ở dòng {idx + 1}: {line}")
                        elif not is_valid_number(target):  # Kiểm tra giá trị khác
                            raise ValueError(f"Lỗi: Giá trị không hợp lệ ở dòng {idx + 1}: {line}")
                        