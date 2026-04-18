# llama.cpp 自动化编译脚本 for Windows
# 使用方法: .\build_llama_windows.ps1

param(
    [string]$Platform = "windows",
    [string]$BuildType = "Release",
    [switch]$Help
)

# 设置错误处理
$ErrorActionPreference = "Stop"

# 脚本路径
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$ProjectRoot = Split-Path -Parent $ScriptDir
$BuildDir = Join-Path $ProjectRoot "build_llama"
$OutputDir = Join-Path $ProjectRoot "native_libs"

# 颜色输出函数
function Write-ColorOutput($ForegroundColor) {
    $fc = $host.UI.RawUI.ForegroundColor
    $host.UI.RawUI.ForegroundColor = $ForegroundColor
    if ($args) {
        Write-Output $args
    }
    $host.UI.RawUI.ForegroundColor = $fc
}

function Write-Success { Write-ColorOutput Green $args }
function Write-Info { Write-ColorOutput Yellow $args }
function Write-Error { Write-ColorOutput Red $args }

# 显示帮助信息
if ($Help) {
    Write-Host "llama.cpp 编译脚本 for Windows"
    Write-Host ""
    Write-Host "使用方法:"
    Write-Host "  .\build_llama_windows.ps1 [-BuildType <Release|Debug>]"
    Write-Host ""
    Write-Host "参数:"
    Write-Host "  -BuildType    编译类型 (默认: Release)"
    Write-Host "  -Help         显示此帮助信息"
    Write-Host ""
    Write-Host "前置要求:"
    Write-Host "  - Visual Studio 2022"
    Write-Host "  - CMake 3.20+"
    Write-Host "  - CUDA Toolkit 11.8+ (可选，用于CUDA加速)"
    exit 0
}

Write-Success "=== llama.cpp 编译脚本 (Windows) ==="
Write-Host "编译类型: $BuildType"
Write-Host "项目根目录: $ProjectRoot"
Write-Host "构建目录: $BuildDir"
Write-Host "输出目录: $OutputDir"

# 检查依赖
function Check-Dependencies {
    Write-Info "检查依赖..."

    # 检查CMake
    $cmake = Get-Command cmake -ErrorAction SilentlyContinue
    if (-not $cmake) {
        Write-Error "错误: CMake未安装"
        Write-Host "请安装CMake: winget install Kitware.CMake"
        exit 1
    }

    # 检查Visual Studio
    $vsWhere = "${env:ProgramFiles(x86)}\Microsoft Visual Studio\Installer\vswhere.exe"
    if (-not (Test-Path $vsWhere)) {
        Write-Error "错误: Visual Studio未安装"
        exit 1
    }

    # 检查CUDA (可选)
    $cudaPath = $env:CUDA_PATH
    if ($cudaPath) {
        Write-Success "检测到CUDA: $cudaPath"
    } else {
        Write-Info "未检测到CUDA，将编译CPU版本"
    }

    Write-Success "所有依赖已满足"
}

# 克隆llama.cpp仓库
function Clone-Repo {
    if (Test-Path "$BuildDir\llama.cpp") {
        Write-Info "llama.cpp已存在，跳过克隆"
        return
    }

    Write-Info "克隆llama.cpp仓库..."
    New-Item -ItemType Directory -Force -Path $BuildDir | Out-Null
    Push-Location $BuildDir

    git clone https://github.com/ggerganov/llama.cpp.git
    Pop-Location

    # 记录版本
    Push-Location "$BuildDir\llama.cpp"
    git rev-parse HEAD | Out-File "$BuildDir\LLAMA_VERSION.txt"
    Pop-Location

    Write-Success "克隆完成"
}

# 编译Windows版本
function Build-Windows {
    Write-Info "开始编译Windows版本..."

    Push-Location "$BuildDir\llama.cpp"

    $BuildPath = Join-Path $BuildDir "build_windows"
    New-Item -ItemType Directory -Force -Path $BuildPath | Out-Null

    # 检测CUDA
    $enableCuda = $false
    $cudaPath = $env:CUDA_PATH
    if ($cudaPath) {
        Write-Info "启用CUDA支持..."
        $enableCuda = $true
    }

    # CMake配置
    $cmakeArgs = @(
        "-B", $BuildPath,
        "-G", "Visual Studio 17 2022",
        "-A", "x64",
        "-DBUILD_SHARED_LIBS=ON",
        "-DCMAKE_BUILD_TYPE=$BuildType",
        "-DLLAMA_BUILD_EXAMPLES=OFF"
    )

    if ($enableCuda) {
        $cmakeArgs += "-DGGML_CUDA=ON"
        $cmakeArgs += "-DGGML_CUDA_FORCE_MMQ=ON"
    }

    & cmake $cmakeArgs

    # 编译
    & cmake --build $BuildPath --config $BuildType

    Pop-Location

    Write-Success "Windows编译完成"
}

# 复制编译产物
function Copy-Artifacts {
    Write-Info "复制编译产物..."

    New-Item -ItemType Directory -Force -Path $OutputDir | Out-Null
    New-Item -ItemType Directory -Force -Path "$OutputDir\windows" | Out-Null

    $BuildPath = Join-Path $BuildDir "build_windows"

    # 复制DLL文件
    Copy-Item "$BuildPath\src\$BuildType\llama.dll" "$OutputDir\windows\" -ErrorAction SilentlyContinue
    Copy-Item "$BuildPath\ggml\src\$BuildType\ggml.dll" "$OutputDir\windows\" -ErrorAction SilentlyContinue
    Copy-Item "$BuildPath\ggml\src\ggml-cuda\$BuildType\ggml-cuda.dll" "$OutputDir\windows\" -ErrorAction SilentlyContinue

    # 如果启用CUDA，复制CUDA运行时DLL
    $cudaPath = $env:CUDA_PATH
    if ($cudaPath) {
        $cudaBin = Join-Path $cudaPath "bin"

        # 复制必要的CUDA DLL
        $cudaDlls = @(
            "cudart64_*.dll",
            "cublas64_*.dll",
            "cublasLt64_*.dll"
        )

        foreach ($pattern in $cudaDlls) {
            $dlls = Get-ChildItem "$cudaBin\$pattern" -ErrorAction SilentlyContinue
            foreach ($dll in $dlls) {
                Copy-Item $dll.FullName "$OutputDir\windows\" -ErrorAction SilentlyContinue
            }
        }
    }

    Write-Success "Windows DLL已复制到: $OutputDir\windows"
}

# 集成到Flutter项目
function Integrate-ToFlutter {
    Write-Info "集成到Flutter项目..."

    $BinDir = Join-Path $ProjectRoot "windows\runner\bin"
    New-Item -ItemType Directory -Force -Path $BinDir | Out-Null

    # 复制所有DLL到bin目录
    Copy-Item "$OutputDir\windows\*.dll" $BinDir -ErrorAction SilentlyContinue

    Write-Success "DLL已集成到: $BinDir"
}

# 主流程
function Main {
    try {
        Check-Dependencies
        Clone-Repo
        Build-Windows
        Copy-Artifacts
        Integrate-ToFlutter

        Write-Success "=== 编译完成 ==="
        $version = Get-Content "$BuildDir\LLAMA_VERSION.txt" -ErrorAction SilentlyContinue
        Write-Host "版本信息: $version"
        Write-Host "编译产物位置: $OutputDir"
    }
    catch {
        Write-Error "编译失败: $_"
        exit 1
    }
}

# 执行主流程
Main
