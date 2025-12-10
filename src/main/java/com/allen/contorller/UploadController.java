package com.allen.contorller;

import cn.hutool.core.date.DatePattern;
import cn.hutool.core.date.DateUtil;
import cn.hutool.core.io.FileUtil;
import cn.hutool.core.util.CharUtil;
import cn.hutool.core.util.StrUtil;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.core.io.Resource;
import org.springframework.util.StopWatch;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.multipart.MultipartFile;

import java.io.File;

/**
 * @author Allen.Yang
 * @date 2025/12/3
 */
@RestController
public class UploadController {

    Logger log = LoggerFactory.getLogger(UploadController.class);

    @Value("${app.static-url-prefix}")
    private String urlPrefix;
    @Value("${spring.web.resources.static-locations:file:static}")
    private Resource resource;

    @PostMapping("/upload")
    public String upload(@RequestParam("file") MultipartFile file) {
        StopWatch stopWatch = new StopWatch();
        stopWatch.start();
        try {
            log.info("upload file: {}", file.getOriginalFilename());
            // 检查目录是否存在，不存在则创建
            FileUtil.mkdirsSafely(resource.getFile(), 3, 300);
            File localFile;
            // 如果文件名不为空，则使用文件名，否则使用UUID生成文件名
            if (StrUtil.isNotBlank(file.getOriginalFilename())) {
                localFile = FileUtil.file(resource.getFile().getAbsolutePath(), file.getOriginalFilename());
            } else {
                String fileName = DateUtil.format(DateUtil.date(), DatePattern.PURE_DATETIME_MS_PATTERN) + CharUtil.UNDERLINE + StrUtil.uuid();
                localFile = FileUtil.file(resource.getFile().getAbsolutePath(), fileName);
            }
            // 检查文件是否存在，存在则删除
            file.transferTo(localFile);
            return urlPrefix + file.getOriginalFilename();
        } catch (Exception e) {
            log.info("upload file error", e);
            return e.getMessage();
        } finally {
            stopWatch.stop();
            log.info("upload file cost: {}ms", stopWatch.getTotalTimeMillis());
        }
    }
}
