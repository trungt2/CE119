from flask import Flask, request, render_template
import subprocess
import os
from excute import FirstPass, SecondPass

app = Flask(__name__)

@app.route("/", methods=["GET", "POST"])
def code_editor():
    output = ""
    code = ""
    if request.method == "POST":
        code = request.form.get("code")
        # Chạy mã Assembly MIPS và lấy mã máy
        output = execute_mips_code(code)
    return render_template("editor.html", code=code, output=output)

def execute_mips_code(code):
    try:
        # Tạo thư mục uploads nếu chưa tồn tại
        os.makedirs('uploads', exist_ok=True)

        # Lưu mã Assembly MIPS vào file tạm thời
        temp_code = "uploads/temp_code.asm"
        with open(temp_code, "w") as f:
            f.write(code)

        instructions_with_address, labels, cleaned_lines = FirstPass(temp_code)
        machine_code = SecondPass(cleaned_lines, labels)

        # Chuyển các chuỗi nhị phân trong output thành hex
        hex_output = []
        for binary_code in machine_code:
            # Chuyển đổi nhị phân thành số thập lục phân
            hex_value = hex(int(binary_code, 2))[2:].upper().zfill(8)  # Loại bỏ '0x' và thêm 0 nếu cần
            hex_output.append(hex_value)

        # Trả về kết quả dưới dạng chuỗi hex, cách nhau bởi dấu cách
        return '\n'.join(hex_output)
    except Exception as e:
        return f"Error: {str(e)}"

if __name__ == "__main__":
    app.run(host='0.0.0.0', port=5000, debug=True)