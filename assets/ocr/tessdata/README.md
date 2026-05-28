# OCR 训练数据 - 按需下载

此目录的 tessdata 文件不打包到 APK 中，需要时从网络下载。

## 下载地址
- 中文简体：https://github.com/tesseract-ocr/tessdata/raw/main/chi_sim.traineddata
- 英文：https://github.com/tesseract-ocr/tessdata/raw/main/eng.traineddata

## 使用方式
首次使用 OCR 功能时，应用会自动检测本地是否存在 tessdata，如不存在则自动下载。

## 手动下载（可选）
如需离线使用，可手动将文件放入此目录：
- `chi_sim.traineddata` - 中文简体识别
- `eng.traineddata` - 英文识别