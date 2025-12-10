import requests
import sys
import os

# Java 后端上传接口地址
UPLOAD_URL = "http://localhost:3390/upload"

def upload(image_path):
    # 清理路径并校验文件
    image_path = image_path.strip().strip("'").strip('"')
    if not os.path.exists(image_path):
        print(f"上传失败：文件不存在 → {image_path}", file=sys.stderr)
        sys.exit(1)
    if not os.path.isfile(image_path):
        print(f"上传失败：不是有效文件 → {image_path}", file=sys.stderr)
        sys.exit(1)

    try:
        with open(image_path, "rb") as f:
            files = {"file": f}
            response = requests.post(UPLOAD_URL, files=files)
            # 校验响应状态码
            if response.status_code != 200:
                print(f"上传失败：接口返回异常状态码 → {response.status_code}", file=sys.stderr)
                sys.exit(1)
            # 直接取响应文本作为 URL（适配后端返回的纯字符串）
            image_url = response.text.strip()
            if not image_url:
                print("上传失败：接口返回空 URL", file=sys.stderr)
                sys.exit(1)
            # 输出 URL
            print(image_url)
    except Exception as e:
        print(f"上传异常：{str(e)}", file=sys.stderr)
        sys.exit(1)

if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("缺少图片路径参数！用法：python imgUpload.py 图片路径", file=sys.stderr)
        sys.exit(1)
    upload(sys.argv[1])
