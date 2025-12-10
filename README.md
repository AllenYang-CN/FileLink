# FileLink

一个轻量级的文件上传和静态文件服务器，专为Markdown文档（如Typora）图片上传设计。

## 技术栈

- **后端框架**: Spring Boot 2.1.5
- **开发语言**: Java
- **辅助工具**: Python 3.x
- **核心依赖**: Hutool 5.8.36

## 功能特点

1. **文件上传服务**：提供HTTP接口，支持文件上传
2. **静态文件服务器**：Spring Boot内置静态文件服务
3. **Typora集成**：通过Python脚本实现Typora图片一键上传
4. **配置灵活**：支持自定义端口、存储路径和访问URL

## 快速开始

### 环境要求

- JDK 8+
- Maven 3.5+
- Python 3.x
- 可选：Typora（用于Markdown编辑和图片上传）

### 构建和运行

1. **克隆项目**

```bash
git clone https://github.com/yourusername/FileLink.git
cd FileLink
```

2. **构建项目**

```bash
mvn clean package
```

3. **运行项目**

```bash
java -jar target/FileLink-1.0-SNAPSHOT.jar --spring.config.location=config/application.properties
```

或者直接运行App类：

```bash
mvn spring-boot:run -Dspring.config.location=config/application.properties
```

4. **验证服务**

服务启动后，访问 `http://localhost:3390/file/` 可以查看静态文件目录内容（如果有文件的话）。

## 操作说明

### 1. 使用HTTP接口上传文件

**请求URL**: `http://localhost:3390/upload`
**请求方法**: POST
**请求参数**:
- `file`: 要上传的文件（multipart/form-data格式）

**示例请求**:

使用curl:

```bash
curl -X POST -F "file=@path/to/image.jpg" http://localhost:3390/upload
```

使用Postman:
1. 选择POST方法
2. 输入URL: `http://localhost:3390/upload`
3. 在Body标签页选择form-data
4. 键名输入`file`，类型选择File，值选择要上传的文件
5. 点击Send

**响应示例**:

```
http://localhost:3390/file/image.jpg
```

### 2. 使用Python脚本上传文件

#### 脚本说明

脚本位于 `script/imgUpload.py`，用于将本地图片上传到FileLink服务器并返回访问URL。

#### 配置脚本

编辑 `script/imgUpload.py` 文件，确保 `UPLOAD_URL` 与你的服务地址一致：

```python
# Java 后端上传接口地址
UPLOAD_URL = "http://localhost:3390/upload"
```

#### 使用方法

```bash
python script/imgUpload.py path/to/image.jpg
```

**输出示例**:

```
http://localhost:3390/file/image.jpg
```

### 3. Typora集成配置

将FileLink与Typora集成，可以实现Markdown文档中图片的一键上传。

#### 配置步骤

1. 打开Typora，点击 **文件** -> **偏好设置**
2. 在偏好设置窗口中，点击 **图像** 选项卡
3. 在 **上传服务设定** 中，选择 **自定义命令**
4. 在命令输入框中，输入Python脚本的完整路径：
   ```
   python "E:\WITSKY\CODE\GITHUB\FileLink\script\imgUpload.py" "{}"
   ```
5. 点击 **验证图片上传选项**，验证配置是否正确
6. 点击 **确定** 保存配置

#### 使用方法

在Typora中插入图片时，选择 **上传图片**，或者设置 **插入图片时自动上传**，即可将本地图片自动上传到FileLink服务器，并替换为在线URL。

## 最佳实践

### 1. 目录结构管理

建议在项目根目录创建 `static` 文件夹，用于存储上传的静态文件：

```
FileLink/
├── static/          # 静态文件存储目录
├── script/          # 脚本目录
├── config/          # 配置文件目录
├── src/             # 源代码目录
└── README.md        # 项目说明文档
```

### 2. 文件命名规范

- 上传的文件名应尽量简洁，避免使用特殊字符
- 建议使用有意义的文件名，便于后续查找和管理
- 对于批量上传的图片，可以使用日期前缀+序号的命名方式

### 3. 性能优化

- 定期清理不需要的静态文件，避免占用过多磁盘空间
- 对于大文件上传，可以考虑添加文件大小限制和分片上传功能
- 在生产环境中，可以考虑使用CDN加速静态文件访问

### 4. 安全性建议

- 在生产环境中，建议修改默认端口和访问路径
- 可以添加身份验证机制，限制文件上传权限
- 对于敏感文件，建议使用加密存储或访问控制

## 配置说明

配置文件位于 `config/application.properties`，主要配置项如下：

```properties
# 服务地址
server.address=localhost
# 服务端口
server.port=3390

# 静态文件配置
# 静态文件存储位置
spring.web.resources.static-locations=file:static/
# 静态文件访问上下文前缀
spring.mvc.static-path-pattern=/file/**
# 上传文件后的URL前缀
app.static-url-prefix=http://localhost:3390/file/

# 日志文件位置
logging.file=FileLink.log
```

### 配置项说明

| 配置项 | 说明 | 默认值 |
|--------|------|--------|
| server.address | 服务绑定的IP地址 | localhost |
| server.port | 服务监听的端口 | 3390 |
| spring.web.resources.static-locations | 静态文件存储位置 | file:static/ |
| spring.mvc.static-path-pattern | 静态文件访问路径模式 | /file/** |
| app.static-url-prefix | 上传文件后的URL前缀 | http://localhost:3390/file/ |
| logging.file | 日志文件存储位置 | FileLink.log |

## 目录结构

```
FileLink/
├── api/                  # API测试文件
│   └── upload.http       # HTTP接口测试脚本
├── config/               # 配置文件目录
│   └── application.properties  # 主配置文件
├── script/               # 脚本目录
│   └── imgUpload.py      # Python上传脚本
├── src/                  # 源代码目录
│   ├── main/             # 主源码
│   │   ├── java/         # Java源代码
│   │   │   └── com/      # 包名根目录
│   │   │       └── allen/# 项目包名
│   │   │           ├── App.java               # 应用入口
│   │   │           └── controller/            # 控制器目录
│   │   │               └── UploadController.java  # 上传控制器
│   │   └── resources/    # 资源文件目录
│   └── test/             # 测试代码目录
├── static/               # 静态文件存储目录
├── target/               # Maven构建输出目录
├── .gitignore            # Git忽略文件
├── pom.xml               # Maven项目文件
└── README.md             # 项目说明文档
```

## 常见问题

### 1. 文件上传失败

- 检查服务是否正常运行
- 检查文件路径是否正确
- 检查文件大小是否超过限制
- 查看日志文件 `FileLink.log` 获取详细错误信息

### 2. 静态文件无法访问

- 检查 `app.static-context-prefix` 配置是否正确
- 检查 `spring.web.resources.static-locations` 配置是否正确
- 检查文件是否已成功上传到指定目录

### 3. Typora上传失败

- 检查Python环境是否正确安装
- 检查脚本路径是否正确配置
- 确保FileLink服务正在运行
- 查看Typora控制台输出获取错误信息

## 扩展功能

### 添加文件大小限制

在 `application.properties` 中添加：

```properties
# 最大文件大小
spring.servlet.multipart.max-file-size=10MB
# 最大请求大小
spring.servlet.multipart.max-request-size=10MB
```

## 许可证

MIT License

## 贡献

欢迎提交Issue和Pull Request！

## 更新日志

### v1.0.0
- 初始版本发布
- 支持文件上传功能
- 支持静态文件服务
- 提供Typora集成脚本
